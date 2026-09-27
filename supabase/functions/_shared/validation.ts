// Validation of AI JSON output (ARCHITECTURE.md 9.1, 13.8).

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ValidationError";
  }
}

/** Parses a JSON object, tolerating a surrounding ```json fence. */
export function parseJsonObject(raw: string): Record<string, unknown> {
  let text = raw.trim();
  const fence = text.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  if (fence) text = fence[1];
  let value: unknown;
  try {
    value = JSON.parse(text);
  } catch {
    throw new ValidationError("AI answer is not valid JSON.");
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new ValidationError("AI answer is not a JSON object.");
  }
  return value as Record<string, unknown>;
}

function requireString(obj: Record<string, unknown>, key: string, maxLen = 20000): string {
  const value = obj[key];
  if (typeof value !== "string") {
    throw new ValidationError(`"${key}" must be a string.`);
  }
  return value.slice(0, maxLen);
}

function requireScore(obj: Record<string, unknown>, key: string, max: number): number {
  const value = obj[key];
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new ValidationError(`"${key}" must be a number.`);
  }
  const rounded = Math.round(value);
  if (rounded < 0 || rounded > max) {
    throw new ValidationError(`"${key}" must be between 0 and ${max}.`);
  }
  return rounded;
}

function requireObject(obj: Record<string, unknown>, key: string): Record<string, unknown> {
  const value = obj[key];
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new ValidationError(`"${key}" must be an object.`);
  }
  return value as Record<string, unknown>;
}

export interface EssayMistake {
  original: string;
  correction: string;
  reason: string;
}

export interface EssayScore {
  score_total: number;
  breakdown: { ideas: number; structure: number; grammar: number; spelling_vocab: number };
  breakdown_comments: { ideas: string; structure: string; grammar: string; spelling_vocab: string };
  mistakes: EssayMistake[];
  biggest_habit: string;
  corrected_version: string;
  next_exercise: string;
}

const CATEGORIES = ["ideas", "structure", "grammar", "spelling_vocab"] as const;

/**
 * Validates the essay scoring JSON (schema in ARCHITECTURE.md 9.3).
 * score_total is recomputed from the breakdown so the numbers always agree.
 */
export function parseEssayScore(raw: string): EssayScore {
  const obj = parseJsonObject(raw);
  const breakdownRaw = requireObject(obj, "breakdown");
  const commentsRaw = requireObject(obj, "breakdown_comments");

  const breakdown = {
    ideas: requireScore(breakdownRaw, "ideas", 5),
    structure: requireScore(breakdownRaw, "structure", 5),
    grammar: requireScore(breakdownRaw, "grammar", 5),
    spelling_vocab: requireScore(breakdownRaw, "spelling_vocab", 5),
  };
  const breakdown_comments = {
    ideas: "",
    structure: "",
    grammar: "",
    spelling_vocab: "",
  };
  for (const key of CATEGORIES) {
    const value = commentsRaw[key];
    breakdown_comments[key] = typeof value === "string" ? value.slice(0, 1000) : "";
  }

  const mistakesRaw = obj["mistakes"];
  if (!Array.isArray(mistakesRaw)) {
    throw new ValidationError('"mistakes" must be an array.');
  }
  const mistakes: EssayMistake[] = [];
  for (const entry of mistakesRaw.slice(0, 50)) {
    if (!entry || typeof entry !== "object") continue;
    const m = entry as Record<string, unknown>;
    if (typeof m.original !== "string" || typeof m.correction !== "string") continue;
    mistakes.push({
      original: m.original.slice(0, 500),
      correction: m.correction.slice(0, 500),
      reason: typeof m.reason === "string" ? m.reason.slice(0, 500) : "",
    });
  }

  const score_total = breakdown.ideas + breakdown.structure + breakdown.grammar +
    breakdown.spelling_vocab;

  return {
    score_total,
    breakdown,
    breakdown_comments,
    mistakes,
    biggest_habit: requireString(obj, "biggest_habit", 1000),
    corrected_version: requireString(obj, "corrected_version"),
    next_exercise: typeof obj.next_exercise === "string" ? obj.next_exercise.slice(0, 1000) : "",
  };
}

export interface GameTurn {
  ai_message: string;
  options: string[] | null;
  correct: boolean | null;
  finished: boolean;
}

/** Validates one AI game turn (ARCHITECTURE.md 9.4). */
export function parseGameTurn(raw: string): GameTurn {
  const obj = parseJsonObject(raw);
  const message = obj.ai_message;
  if (typeof message !== "string" || message.trim() === "") {
    throw new ValidationError('"ai_message" must be a non-empty string.');
  }

  let options: string[] | null = null;
  if (Array.isArray(obj.options)) {
    const cleaned = obj.options
      .filter((o): o is string => typeof o === "string" && o.trim() !== "")
      .map((o) => o.trim().slice(0, 120))
      .slice(0, 6);
    options = cleaned.length >= 2 ? cleaned : null;
  } else if (obj.options !== null && obj.options !== undefined) {
    throw new ValidationError('"options" must be an array or null.');
  }

  const correct = typeof obj.correct === "boolean" ? obj.correct : null;
  const finished = obj.finished === true;

  return {
    ai_message: message.trim().slice(0, 1200),
    options: finished ? null : options,
    correct,
    finished,
  };
}
