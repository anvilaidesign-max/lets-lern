// ai-game-turn (ARCHITECTURE.md 9.4).
// Request:  { session_id | null, topic_code, mode, user_message }
// Response: { session_id, ai_message, options, score, finished, correct }

import { AiError } from "./ai_client.ts";
import type { AiClient, ChatMessage } from "./ai_client.ts";
import { corsHeaders, errorResponse, isUuid, jsonResponse, readJsonBody } from "./http.ts";
import { parseGameTurn, ValidationError } from "./validation.ts";
import type { GameTurn } from "./validation.ts";

export const GAME_DAILY_LIMIT = 100;
export const GAME_TIMEOUT_MS = 30_000;
export const MAX_QUESTIONS = 10;
export const CONTEXT_MESSAGES = 20;
export const END_MESSAGE = "__end__";

export const TOPIC_NAMES: Record<string, string> = {
  math: "Mathematics",
  english: "English",
  french: "French",
  science: "Science",
  politics: "Politics",
  economics: "Economics",
  finance: "Finance",
  relations: "International Relations",
  tech: "Technology",
  engineering: "Electronics Engineering",
  medicine: "Medicine",
  law: "Law",
  business: "Business and Startups",
};

export const LEVELS = ["basics", "mixed", "advanced"] as const;
export type Level = typeof LEVELS[number];

const LEVEL_RULES: Record<Level, string> = {
  basics: "Pitch everything at foundation level: plain words, one idea at a time.",
  mixed: "Mix foundation and intermediate questions, rising in difficulty as the game goes on.",
  advanced: "Pitch at university level: precise terminology, formulas and worked numbers where relevant, no trivial questions.",
};

/** Keeps the learner description short and on one line. */
export function cleanLearner(value: unknown): string {
  if (typeof value !== "string") return "";
  return value.replace(/[\r\n"`]+/g, " ").trim().slice(0, 80);
}

export const GAME_MODES = ["teach", "quiz", "true_false"] as const;
export type GameMode = typeof GAME_MODES[number];

export interface StoredMessage {
  role: "user" | "assistant";
  content: string;
}

export interface GameSession {
  id: string;
  user_id: string;
  topic_code: string;
  mode: GameMode;
  messages: StoredMessage[];
  score: number;
}

export interface AiGameDeps {
  getUserId(req: Request): Promise<string | null>;
  getSession(id: string): Promise<GameSession | null>;
  createSession(row: { user_id: string; topic_code: string; mode: GameMode }): Promise<GameSession>;
  saveSession(id: string, patch: { messages: StoredMessage[]; score: number }): Promise<void>;
  incrementUsage(userId: string, kind: "essay" | "game", limit: number): Promise<boolean>;
  ai: AiClient;
  log?: (...args: unknown[]) => void;
}

const MODE_RULES: Record<GameMode, string> = {
  teach:
    "Teach a mini lesson in 3 to 5 short messages. Give each lesson message the options [\"Continue\"]. " +
    "After the lesson, ask one multiple choice question with 3 or 4 options, then keep teaching and asking.",
  quiz:
    "Ask multiple choice questions one at a time, each with 3 or 4 options. " +
    "After the user answers, say if they were right, explain briefly, then ask the next question in the same message.",
  true_false:
    "Make one statement at a time and ask if it is true or false. Some statements must be deliberately false. " +
    "Always use the options [\"True\", \"False\"]. After the user answers, say if they were right, explain briefly, " +
    "then give the next statement in the same message.",
};

export function buildSystemPrompt(
  topicName: string,
  mode: GameMode,
  answered: number,
  level: Level = "mixed",
  learner = "",
): string {
  return `You are a friendly but honest tutor for an adult learner.
Topic: ${topicName}. Mode: ${mode}.
${learner ? `About the learner: ${learner}. Use examples that fit this background.\n` : ""}Level: ${level}. ${LEVEL_RULES[level]}
Keep every message under 80 words.
Only state facts you are confident are correct. If unsure, say so.
For politics, be neutral and present facts, not opinions.
When the user is wrong, say so clearly and explain why.
${MODE_RULES[mode]}
Set "correct" to true or false only when the user's last message answered a question, otherwise null.
The game has ${MAX_QUESTIONS} questions. Questions answered so far: ${answered}.
When ${MAX_QUESTIONS} questions have been answered, give a short summary, set "finished" to true and "options" to null.
Return ONLY JSON: {"ai_message": str, "options": [str] or null,
"correct": bool or null, "finished": bool}`;
}

/** Number of questions the user has answered, based on stored AI turns. */
export function answeredCount(messages: StoredMessage[]): number {
  let count = 0;
  for (const m of messages) {
    if (m.role !== "assistant") continue;
    try {
      const parsed = JSON.parse(m.content) as { correct?: unknown };
      if (typeof parsed.correct === "boolean") count++;
    } catch {
      // Ignore malformed history entries.
    }
  }
  return count;
}

async function turnWithRetry(ai: AiClient, messages: ChatMessage[]): Promise<GameTurn> {
  let lastError: unknown;
  for (let attempt = 0; attempt < 2; attempt++) {
    const raw = await ai.chat(messages, {
      jsonMode: true,
      timeoutMs: GAME_TIMEOUT_MS,
      maxTokens: 800,
      temperature: 0.7,
    });
    try {
      return parseGameTurn(raw);
    } catch (error) {
      if (!(error instanceof ValidationError)) throw error;
      lastError = error;
    }
  }
  throw lastError;
}

export async function handleAiGameTurn(req: Request, deps: AiGameDeps): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return errorResponse(405, "method_not_allowed", "Use POST.");

  const userId = await deps.getUserId(req);
  if (!userId) return errorResponse(401, "unauthorized", "Please sign in again.");

  const body = await readJsonBody(req);
  if (!body) return errorResponse(400, "bad_request", "Invalid request body.");

  const userMessage = typeof body.user_message === "string" ? body.user_message.trim() : "";
  if (userMessage.length > 500) {
    return errorResponse(400, "bad_request", "Your message is too long.");
  }

  let session: GameSession | null = null;
  if (body.session_id !== undefined && body.session_id !== null) {
    if (!isUuid(body.session_id)) return errorResponse(400, "bad_request", "Invalid session_id.");
    session = await deps.getSession(body.session_id);
    if (!session || session.user_id !== userId) {
      return errorResponse(404, "not_found", "Game not found. Start a new game.");
    }
  }

  if (!session) {
    const topic = body.topic_code;
    const mode = body.mode;
    if (typeof topic !== "string" || !(topic in TOPIC_NAMES)) {
      return errorResponse(400, "bad_request", "Unknown topic.");
    }
    if (typeof mode !== "string" || !(GAME_MODES as readonly string[]).includes(mode)) {
      return errorResponse(400, "bad_request", "Unknown game mode.");
    }
    if (userMessage.toLowerCase() === END_MESSAGE) {
      return errorResponse(400, "bad_request", "There is no game to end.");
    }
    session = await deps.createSession({ user_id: userId, topic_code: topic, mode: mode as GameMode });
  }

  const answered = answeredCount(session.messages);

  // "End" button: finish without calling the AI (and without using the limit).
  if (userMessage.toLowerCase() === END_MESSAGE) {
    const summary = answered === 0
      ? "Game ended. Come back any time for another round."
      : `Game over. You scored ${session.score} out of ${answered}. Well done for practising!`;
    return jsonResponse({
      session_id: session.id,
      ai_message: summary,
      options: null,
      score: session.score,
      finished: true,
      correct: null,
    });
  }

  const allowed = await deps.incrementUsage(userId, "game", GAME_DAILY_LIMIT);
  if (!allowed) {
    return errorResponse(
      429,
      "rate_limited",
      `You have reached today's limit of ${GAME_DAILY_LIMIT} game turns. Try again tomorrow.`,
    );
  }

  const topicName = TOPIC_NAMES[session.topic_code] ?? session.topic_code;
  const level: Level = (LEVELS as readonly string[]).includes(body.level as string) ? body.level as Level : "mixed";
  const content = userMessage === "" ? "Start the game." : userMessage;
  const context: ChatMessage[] = [
    { role: "system", content: buildSystemPrompt(topicName, session.mode, answered, level, cleanLearner(body.learner)) },
    ...session.messages.slice(-CONTEXT_MESSAGES),
    { role: "user", content },
  ];

  let turn: GameTurn;
  try {
    turn = await turnWithRetry(deps.ai, context);
  } catch (error) {
    deps.log?.("ai game turn failed", error);
    if (error instanceof ValidationError) {
      return errorResponse(502, "invalid_ai_response", "The AI returned an unexpected answer. Please try again.");
    }
    if (error instanceof AiError && error.kind === "timeout") {
      return errorResponse(504, "timeout", "The AI took too long to answer. Please try again.");
    }
    if (error instanceof AiError && error.kind === "config") {
      return errorResponse(503, "not_configured", "The AI game is not set up yet.");
    }
    return errorResponse(502, "ai_unavailable", "The AI service is not available right now. Please try again later.");
  }

  // The first turn of a game cannot grade an answer.
  if (session.messages.length === 0) turn.correct = null;

  const score = session.score + (turn.correct === true ? 1 : 0);
  const answeredNow = answered + (turn.correct === null ? 0 : 1);

  if (answeredNow >= MAX_QUESTIONS && !turn.finished) {
    turn.finished = true;
    turn.options = null;
    turn.ai_message = `${turn.ai_message}\n\nThat was question ${MAX_QUESTIONS}. Final score: ${score} out of ${answeredNow}.`;
  }
  if (!turn.finished && session.mode === "true_false") {
    turn.options = ["True", "False"];
  }

  const messages: StoredMessage[] = [
    ...session.messages,
    { role: "user", content },
    { role: "assistant", content: JSON.stringify(turn) },
  ].slice(-60);

  await deps.saveSession(session.id, { messages, score });

  return jsonResponse({
    session_id: session.id,
    ai_message: turn.ai_message,
    options: turn.options,
    score,
    finished: turn.finished,
    correct: turn.correct,
  });
}
