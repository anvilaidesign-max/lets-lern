// score-essay (ARCHITECTURE.md 9.3). Two steps:
//   1. { essay_id }                  -> reads the handwriting, returns the text
//   2. { essay_id, confirmed_text }  -> scores the confirmed text out of 20
//
// Dependencies are injected so the handler can be tested without Supabase or
// a real AI provider.

import { AiError } from "./ai_client.ts";
import type { AiClient } from "./ai_client.ts";
import { corsHeaders, errorResponse, isUuid, jsonResponse, readJsonBody } from "./http.ts";
import { parseEssayScore, ValidationError } from "./validation.ts";
import type { EssayScore } from "./validation.ts";

export const ESSAY_DAILY_LIMIT = 5;
export const ESSAY_TIMEOUT_MS = 60_000;
export const MIN_ESSAY_CHARS = 30;
export const MAX_ESSAY_CHARS = 15_000;

export const SCORING_SYSTEM_PROMPT =
  `You are a strict, honest English writing examiner. Never flatter.
Score the essay out of 20 using this rubric: ideas (5), structure (5),
grammar and punctuation (5), spelling and vocabulary (5).
Be fair: a score of 10/20 is average for an adult learner.
Quote the user's exact mistakes and give the correction and a one line reason.
Identify the single biggest habit the writer must fix.
Return ONLY valid JSON matching this schema, no other text:
{
  "score_total": int,
  "breakdown": {"ideas": int, "structure": int, "grammar": int, "spelling_vocab": int},
  "breakdown_comments": {"ideas": str, "structure": str, "grammar": str, "spelling_vocab": str},
  "mistakes": [{"original": str, "correction": str, "reason": str}],
  "biggest_habit": str,
  "corrected_version": str,
  "next_exercise": str
}`;

export interface EssayRow {
  id: string;
  user_id: string;
  prompt: string;
  image_path: string;
  extracted_text: string | null;
  score_total: number | null;
  score_breakdown: unknown;
  feedback: unknown;
  status: "pending" | "done" | "failed";
}

export interface ScoreEssayDeps {
  getUserId(req: Request): Promise<string | null>;
  getEssay(id: string): Promise<EssayRow | null>;
  updateEssay(id: string, patch: Record<string, unknown>): Promise<void>;
  downloadImage(path: string): Promise<{ bytes: Uint8Array; mimeType: string }>;
  incrementUsage(userId: string, kind: "essay" | "game", limit: number): Promise<boolean>;
  ai: AiClient;
  log?: (...args: unknown[]) => void;
}

export function resultFromRow(row: EssayRow): Record<string, unknown> {
  const breakdown = (row.score_breakdown ?? {}) as Record<string, unknown>;
  const feedback = (row.feedback ?? {}) as Record<string, unknown>;
  return {
    score_total: row.score_total,
    breakdown: breakdown.breakdown ?? null,
    breakdown_comments: breakdown.comments ?? null,
    mistakes: feedback.mistakes ?? [],
    biggest_habit: feedback.biggest_habit ?? "",
    corrected_version: feedback.corrected_version ?? "",
    next_exercise: feedback.next_exercise ?? "",
  };
}

function aiErrorResponse(error: unknown): Response {
  if (error instanceof AiError) {
    if (error.kind === "timeout") {
      return errorResponse(504, "timeout", "The AI took too long to answer. Please try again.");
    }
    if (error.kind === "config") {
      return errorResponse(503, "not_configured", "Essay scoring is not set up yet.");
    }
  }
  return errorResponse(502, "ai_unavailable", "The AI service is not available right now. Please try again later.");
}

async function scoreWithRetry(ai: AiClient, prompt: string, text: string): Promise<EssayScore> {
  const messages = [
    { role: "system" as const, content: SCORING_SYSTEM_PROMPT },
    {
      role: "user" as const,
      content: `Essay prompt: ${prompt}\n\nEssay:\n${text}\n\nReturn the json object only.`,
    },
  ];
  let lastError: unknown;
  // Invalid JSON is retried once, then reported (ARCHITECTURE.md 9.1).
  for (let attempt = 0; attempt < 2; attempt++) {
    const raw = await ai.chat(messages, {
      jsonMode: true,
      timeoutMs: ESSAY_TIMEOUT_MS,
      maxTokens: 6000,
      temperature: 0.2,
    });
    try {
      return parseEssayScore(raw);
    } catch (error) {
      if (!(error instanceof ValidationError)) throw error;
      lastError = error;
    }
  }
  throw lastError;
}

export async function handleScoreEssay(req: Request, deps: ScoreEssayDeps): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return errorResponse(405, "method_not_allowed", "Use POST.");

  const userId = await deps.getUserId(req);
  if (!userId) return errorResponse(401, "unauthorized", "Please sign in again.");

  const body = await readJsonBody(req);
  if (!body || !isUuid(body.essay_id)) {
    return errorResponse(400, "bad_request", "A valid essay_id is required.");
  }
  const essayId = body.essay_id;

  const essay = await deps.getEssay(essayId);
  if (!essay || essay.user_id !== userId) {
    return errorResponse(404, "not_found", "Essay not found.");
  }

  if (essay.status === "done" && essay.score_total !== null) {
    return jsonResponse({ step: "scored", essay_id: essayId, result: resultFromRow(essay) });
  }

  const confirmed = body.confirmed_text;

  // Step 1: transcribe the photo.
  if (confirmed === undefined || confirmed === null) {
    if (essay.extracted_text) {
      return jsonResponse({
        step: "transcribed",
        essay_id: essayId,
        extracted_text: essay.extracted_text,
      });
    }

    const allowed = await deps.incrementUsage(userId, "essay", ESSAY_DAILY_LIMIT);
    if (!allowed) {
      return errorResponse(
        429,
        "rate_limited",
        `You have reached today's limit of ${ESSAY_DAILY_LIMIT} essays. Try again tomorrow.`,
      );
    }

    let image: { bytes: Uint8Array; mimeType: string };
    try {
      image = await deps.downloadImage(essay.image_path);
    } catch (error) {
      deps.log?.("downloadImage failed", error);
      return errorResponse(404, "image_missing", "We could not find the essay photo. Please upload it again.");
    }

    let text: string;
    try {
      text = await deps.ai.readHandwriting(image.bytes, image.mimeType, {
        timeoutMs: ESSAY_TIMEOUT_MS,
      });
    } catch (error) {
      deps.log?.("readHandwriting failed", error);
      return aiErrorResponse(error);
    }

    if (text.replace(/\[unclear\]/g, "").trim().length < 10) {
      return errorResponse(
        422,
        "unreadable",
        "We could not read enough text from the photo. Try a clearer photo in good light.",
      );
    }

    await deps.updateEssay(essayId, { extracted_text: text, error_message: null });
    return jsonResponse({ step: "transcribed", essay_id: essayId, extracted_text: text });
  }

  // Step 2: score the text the user confirmed.
  if (typeof confirmed !== "string") {
    return errorResponse(400, "bad_request", "confirmed_text must be text.");
  }
  const text = confirmed.trim();
  if (text.length < MIN_ESSAY_CHARS) {
    return errorResponse(400, "too_short", "The essay is too short to score. Write a few more sentences.");
  }
  if (text.length > MAX_ESSAY_CHARS) {
    return errorResponse(400, "too_long", "The essay is too long to score.");
  }

  let score: EssayScore;
  try {
    score = await scoreWithRetry(deps.ai, essay.prompt, text);
  } catch (error) {
    deps.log?.("scoring failed", error);
    if (error instanceof ValidationError) {
      await deps.updateEssay(essayId, { error_message: "invalid AI response" });
      return errorResponse(502, "invalid_ai_response", "The AI returned an unexpected answer. Please try again.");
    }
    return aiErrorResponse(error);
  }

  await deps.updateEssay(essayId, {
    extracted_text: text,
    score_total: score.score_total,
    score_breakdown: { breakdown: score.breakdown, comments: score.breakdown_comments },
    feedback: {
      mistakes: score.mistakes,
      biggest_habit: score.biggest_habit,
      corrected_version: score.corrected_version,
      next_exercise: score.next_exercise,
    },
    status: "done",
    error_message: null,
  });

  return jsonResponse({ step: "scored", essay_id: essayId, result: score });
}
