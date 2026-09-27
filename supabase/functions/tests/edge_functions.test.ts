// Edge Function tests (ARCHITECTURE.md 14): auth rejection, rate limit,
// invalid AI JSON retry. Run with:  node --test supabase/functions/tests/
// (Node 22.18+ strips TypeScript types natively; Deno can run them too.)

import { test } from "node:test";
import assert from "node:assert/strict";

import { handleScoreEssay } from "../_shared/score_essay.ts";
import type { EssayRow, ScoreEssayDeps } from "../_shared/score_essay.ts";
import { handleAiGameTurn } from "../_shared/ai_game.ts";
import type { AiGameDeps, GameSession } from "../_shared/ai_game.ts";
import { handleContentUpdates } from "../_shared/content_updates.ts";
import type { ContentRow } from "../_shared/content_updates.ts";
import { parseEssayScore, parseGameTurn, ValidationError } from "../_shared/validation.ts";
import type { AiClient } from "../_shared/ai_client.ts";

const USER = "11111111-1111-1111-1111-111111111111";
const ESSAY_ID = "22222222-2222-2222-2222-222222222222";

const VALID_SCORE = JSON.stringify({
  score_total: 11,
  breakdown: { ideas: 3, structure: 3, grammar: 2, spelling_vocab: 3 },
  breakdown_comments: { ideas: "ok", structure: "ok", grammar: "weak", spelling_vocab: "ok" },
  mistakes: [{ original: "recieve", correction: "receive", reason: "i before e" }],
  biggest_habit: "Check spelling.",
  corrected_version: "I receive a lot of letters.",
  next_exercise: "Write five sentences.",
});

function post(body: unknown, auth = true): Request {
  return new Request("http://localhost/fn", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(auth ? { Authorization: "Bearer token" } : {}),
    },
    body: JSON.stringify(body),
  });
}

function fakeAi(chatAnswers: string[], handwriting = "I recieve alot of leters evry week."): AiClient & { chatCalls: number; visionCalls: number } {
  const ai = {
    chatCalls: 0,
    visionCalls: 0,
    async chat() {
      const answer = chatAnswers[Math.min(ai.chatCalls, chatAnswers.length - 1)];
      ai.chatCalls++;
      return answer;
    },
    async readHandwriting() {
      ai.visionCalls++;
      return handwriting;
    },
  };
  return ai;
}

function essayDeps(overrides: Partial<ScoreEssayDeps> = {}, essay?: Partial<EssayRow>) {
  const row: EssayRow = {
    id: ESSAY_ID,
    user_id: USER,
    prompt: "Why read?",
    image_path: `${USER}/${ESSAY_ID}.jpg`,
    extracted_text: null,
    score_total: null,
    score_breakdown: null,
    feedback: null,
    status: "pending",
    ...essay,
  };
  const updates: Record<string, unknown>[] = [];
  const deps: ScoreEssayDeps = {
    getUserId: async (req) => (req.headers.get("Authorization") ? USER : null),
    getEssay: async (id) => (id === row.id ? row : null),
    updateEssay: async (_id, patch) => {
      updates.push(patch);
    },
    downloadImage: async () => ({ bytes: new Uint8Array([1, 2, 3]), mimeType: "image/jpeg" }),
    incrementUsage: async () => true,
    ai: fakeAi([VALID_SCORE]),
    ...overrides,
  };
  return { deps, updates, row };
}

// ---------------------------------------------------------------- score-essay

test("score-essay rejects requests without auth", async () => {
  const { deps } = essayDeps();
  const res = await handleScoreEssay(post({ essay_id: ESSAY_ID }, false), deps);
  assert.equal(res.status, 401);
  assert.equal((await res.json()).error, "unauthorized");
});

test("score-essay hides essays owned by someone else", async () => {
  const { deps } = essayDeps({}, { user_id: "33333333-3333-3333-3333-333333333333" });
  const res = await handleScoreEssay(post({ essay_id: ESSAY_ID }), deps);
  assert.equal(res.status, 404);
});

test("score-essay enforces the daily rate limit", async () => {
  const ai = fakeAi([VALID_SCORE]);
  const { deps } = essayDeps({ incrementUsage: async () => false, ai });
  const res = await handleScoreEssay(post({ essay_id: ESSAY_ID }), deps);
  assert.equal(res.status, 429);
  assert.equal((await res.json()).error, "rate_limited");
  assert.equal(ai.visionCalls, 0);
});

test("score-essay step 1 returns the exact transcription", async () => {
  const { deps, updates } = essayDeps();
  const res = await handleScoreEssay(post({ essay_id: ESSAY_ID }), deps);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.step, "transcribed");
  assert.equal(body.extracted_text, "I recieve alot of leters evry week.");
  assert.equal(updates[0].extracted_text, "I recieve alot of leters evry week.");
});

test("score-essay retries once on invalid AI JSON, then succeeds", async () => {
  const ai = fakeAi(["not json at all", VALID_SCORE]);
  const { deps, updates } = essayDeps({ ai });
  const res = await handleScoreEssay(
    post({ essay_id: ESSAY_ID, confirmed_text: "I recieve alot of leters evry week and I read them all." }),
    deps,
  );
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.step, "scored");
  assert.equal(body.result.score_total, 11);
  assert.equal(ai.chatCalls, 2);
  assert.equal(updates.at(-1)?.status, "done");
});

test("score-essay returns a clear error after two invalid AI answers", async () => {
  const ai = fakeAi(["{bad", "{\"score_total\": 3}"]);
  const { deps } = essayDeps({ ai });
  const res = await handleScoreEssay(
    post({ essay_id: ESSAY_ID, confirmed_text: "I recieve alot of leters evry week and I read them all." }),
    deps,
  );
  assert.equal(res.status, 502);
  assert.equal((await res.json()).error, "invalid_ai_response");
  assert.equal(ai.chatCalls, 2);
});

test("score-essay rejects text that is too short", async () => {
  const { deps } = essayDeps();
  const res = await handleScoreEssay(post({ essay_id: ESSAY_ID, confirmed_text: "Too short." }), deps);
  assert.equal(res.status, 400);
});

// --------------------------------------------------------------- ai-game-turn

function gameDeps(ai: AiClient, allowed = true) {
  const sessions = new Map<string, GameSession>();
  const deps: AiGameDeps = {
    getUserId: async (req) => (req.headers.get("Authorization") ? USER : null),
    getSession: async (id) => sessions.get(id) ?? null,
    createSession: async (row) => {
      const session: GameSession = { id: "44444444-4444-4444-4444-444444444444", messages: [], score: 0, ...row };
      sessions.set(session.id, session);
      return session;
    },
    saveSession: async (id, patch) => {
      const s = sessions.get(id)!;
      sessions.set(id, { ...s, ...patch });
    },
    incrementUsage: async () => allowed,
    ai,
  };
  return { deps, sessions };
}

test("ai-game-turn rejects requests without auth", async () => {
  const { deps } = gameDeps(fakeAi(["{}"]));
  const res = await handleAiGameTurn(post({ topic_code: "math", mode: "quiz", user_message: "" }, false), deps);
  assert.equal(res.status, 401);
});

test("ai-game-turn enforces the daily rate limit", async () => {
  const { deps } = gameDeps(fakeAi(["{}"]), false);
  const res = await handleAiGameTurn(post({ topic_code: "math", mode: "quiz", user_message: "" }), deps);
  assert.equal(res.status, 429);
});

test("ai-game-turn retries invalid JSON and scores correct answers", async () => {
  const first = JSON.stringify({ ai_message: "Is 7 x 7 = 45?", options: ["True", "False"], correct: null, finished: false });
  const second = JSON.stringify({ ai_message: "Right! Next: 2 + 2 = 5?", options: ["True", "False"], correct: true, finished: false });
  const ai = fakeAi([first, "oops", second]);
  const { deps } = gameDeps(ai);

  const r1 = await handleAiGameTurn(post({ topic_code: "math", mode: "true_false", user_message: "" }), deps);
  const b1 = await r1.json();
  assert.equal(r1.status, 200);
  assert.deepEqual(b1.options, ["True", "False"]);

  const r2 = await handleAiGameTurn(post({ session_id: b1.session_id, user_message: "False" }), deps);
  const b2 = await r2.json();
  assert.equal(r2.status, 200);
  assert.equal(b2.score, 1);
  assert.equal(ai.chatCalls, 3);
});

test("ai-game-turn ends without calling the AI", async () => {
  const first = JSON.stringify({ ai_message: "Q1?", options: ["A", "B", "C"], correct: null, finished: false });
  const ai = fakeAi([first]);
  const { deps } = gameDeps(ai);
  const r1 = await (await handleAiGameTurn(post({ topic_code: "science", mode: "quiz", user_message: "" }), deps)).json();
  const res = await handleAiGameTurn(post({ session_id: r1.session_id, user_message: "__end__" }), deps);
  const body = await res.json();
  assert.equal(body.finished, true);
  assert.equal(ai.chatCalls, 1);
});

// --------------------------------------------------------- get-content-updates

test("get-content-updates requires auth and paginates with a cursor", async () => {
  const rows: ContentRow[] = [
    { id: "a", updated_at: "2026-01-01T00:00:00.000001+00:00", is_active: true, verified: true, title: "A" },
    { id: "b", updated_at: "2026-01-01T00:00:00.000001+00:00", is_active: false, verified: true, title: "B" },
  ];
  const deps = {
    getUserId: async (req: Request) => (req.headers.get("Authorization") ? USER : null),
    fetchUpdates: async () => rows,
    now: () => new Date("2026-02-01T00:00:00Z"),
  };
  assert.equal((await handleContentUpdates(post({}, false), deps)).status, 401);

  const res = await handleContentUpdates(post({ limit: 2 }), deps);
  const body = await res.json();
  assert.equal(body.items.length, 2);
  assert.equal(body.items[0].title, "A");
  assert.deepEqual(body.items[1], { id: "b", is_active: false, updated_at: rows[1].updated_at });
  assert.deepEqual(body.next_cursor, { since: rows[1].updated_at, after_id: "b" });
});

// ----------------------------------------------------------------- validation

test("parseEssayScore recomputes the total and accepts fenced JSON", () => {
  const score = parseEssayScore("```json\n" + VALID_SCORE.replace('"score_total":11', '"score_total":19') + "\n```");
  assert.equal(score.score_total, 11);
});

test("parseEssayScore rejects out-of-range scores", () => {
  const bad = JSON.parse(VALID_SCORE);
  bad.breakdown.ideas = 9;
  assert.throws(() => parseEssayScore(JSON.stringify(bad)), ValidationError);
});

test("parseGameTurn drops options when finished", () => {
  const turn = parseGameTurn(JSON.stringify({ ai_message: "Done", options: ["A", "B"], correct: true, finished: true }));
  assert.equal(turn.options, null);
  assert.equal(turn.finished, true);
});
