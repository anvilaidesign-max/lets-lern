// Shared helpers for the content pipeline (ARCHITECTURE.md 12).
// Zero dependencies: runs on Node 22.18+ (native TypeScript type stripping).

import { createHash } from "node:crypto";
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
export const CONTENT_DIR = join(ROOT, "content");
export const REPO_ROOT = join(ROOT, "..");

export const TOPICS = [
  { code: "math", name: "Mathematics", icon: "calculate", sort_order: 1 },
  { code: "english", name: "English", icon: "menu_book", sort_order: 2 },
  { code: "french", name: "French", icon: "translate", sort_order: 3 },
  { code: "science", name: "Science", icon: "science", sort_order: 4 },
  { code: "politics", name: "Politics", icon: "account_balance", sort_order: 5 },
  { code: "economics", name: "Economics", icon: "trending_up", sort_order: 6 },
  { code: "finance", name: "Finance", icon: "savings", sort_order: 7 },
  { code: "relations", name: "International Relations", icon: "public", sort_order: 8 },
];

const TOPIC_CODES = new Set(TOPICS.map((t) => t.code));
const TYPES = new Set(["fact", "lesson", "challenge", "vocab", "phrase"]);
const SOURCED_TOPICS = new Set(["science", "politics", "economics", "finance", "relations"]);
const ALLOWED_KEYS = new Set([
  "id", "topic_code", "type", "title", "body", "statement", "is_true", "correct_answer",
  "explanation", "term", "translation", "example_sentence", "difficulty", "source_name",
  "source_url", "verified", "in_offline_pack", "is_active",
]);

export interface ContentItem {
  id?: string;
  topic_code: string;
  type: string;
  title: string;
  body: string;
  statement?: string;
  is_true?: boolean;
  correct_answer?: string;
  explanation?: string;
  term?: string;
  translation?: string;
  example_sentence?: string;
  difficulty?: number;
  source_name?: string;
  source_url?: string;
  verified?: boolean;
  in_offline_pack?: boolean;
  is_active?: boolean;
}

export interface LoadedItem {
  file: string;
  index: number;
  item: ContentItem;
}

/** Loads every content/*.json file except essay_prompts.json. */
export function loadContent(): LoadedItem[] {
  const files = readdirSync(CONTENT_DIR).filter((f) => f.endsWith(".json") && f !== "essay_prompts.json").sort();
  const all: LoadedItem[] = [];
  for (const file of files) {
    const data = JSON.parse(readFileSync(join(CONTENT_DIR, file), "utf8"));
    if (!Array.isArray(data)) throw new Error(`${file}: expected a JSON array`);
    data.forEach((item: ContentItem, index: number) => all.push({ file, index, item }));
  }
  return all;
}

export function loadEssayPrompts(): { topic_code: string; prompt: string }[] {
  return JSON.parse(readFileSync(join(CONTENT_DIR, "essay_prompts.json"), "utf8"));
}

/** Deterministic UUID (v5 style, SHA-1) so the same item always gets the same id. */
export function stableUuid(key: string): string {
  const hash = createHash("sha1").update(`daily-mind:${key}`).digest();
  const b = Buffer.from(hash.subarray(0, 16));
  b[6] = (b[6] & 0x0f) | 0x50;
  b[8] = (b[8] & 0x3f) | 0x80;
  const hex = b.toString("hex");
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

export function itemKey(item: ContentItem): string {
  return [item.topic_code, item.type, item.title, item.statement ?? item.term ?? ""].join("|");
}

export function withId(item: ContentItem): ContentItem & { id: string } {
  return { ...item, id: item.id ?? stableUuid(itemKey(item)) };
}

const norm = (s: string) => s.toLowerCase().replace(/\s+/g, " ").trim();

/** Numbers like "1,024" or "0.25" or "−3". */
function num(s: string): number {
  return Number(s.replace(/,/g, "").replace(/−/g, "-").replace(/[()]/g, ""));
}

/**
 * Checks simple arithmetic challenges ("7 × 7 = 45", "15% of 200 = 30") so a
 * statement marked true really is true and one marked false really is false.
 * Returns null when the statement is not a simple pattern.
 */
export function checkArithmetic(statement: string): boolean | null {
  const s = statement.replace(/\s+/g, " ").trim();
  const pct = s.match(/^([\d.,]+)% of ([\d.,]+) = ([\d.,−-]+)$/);
  if (pct) return Math.abs((num(pct[1]) / 100) * num(pct[2]) - num(pct[3])) < 1e-9;
  const op = s.match(/^(\(?[−-]?[\d.,]+\)?) ([×x÷/+−-]) (\(?[−-]?[\d.,]+\)?) = (\(?[−-]?[\d.,]+\)?)$/);
  if (!op) return null;
  const [a, sym, b, c] = [num(op[1]), op[2], num(op[3]), num(op[4])];
  const result = sym === "×" || sym === "x" ? a * b
    : sym === "÷" || sym === "/" ? a / b
    : sym === "+" ? a + b
    : a - b;
  return Math.abs(result - c) < 1e-9;
}

export interface Problem {
  where: string;
  message: string;
}

/** Schema, length and rule checks for one item (ARCHITECTURE.md 12.1). */
export function validateItem(item: ContentItem, where: string): Problem[] {
  const problems: Problem[] = [];
  const add = (message: string) => problems.push({ where, message });

  for (const key of Object.keys(item)) {
    if (!ALLOWED_KEYS.has(key)) add(`unknown field "${key}"`);
  }
  if (!TOPIC_CODES.has(item.topic_code)) add(`unknown topic_code "${item.topic_code}"`);
  if (!TYPES.has(item.type)) add(`unknown type "${item.type}"`);
  if (typeof item.title !== "string" || item.title.trim().length < 3) add("title is missing");
  else if (item.title.length >= 60) add(`title is ${item.title.length} chars (must be under 60)`);
  if (typeof item.body !== "string" || item.body.trim().length < 3) add("body is missing");
  else if (item.body.length >= 400) add(`body is ${item.body.length} chars (must be under 400)`);
  if (item.difficulty !== undefined && ![1, 2, 3].includes(item.difficulty)) add("difficulty must be 1, 2 or 3");

  if (item.type === "challenge") {
    if (!item.statement) add("challenge needs a statement");
    else if (item.statement.length >= 100) add(`statement is ${item.statement.length} chars (must be under 100)`);
    if (typeof item.is_true !== "boolean") add("challenge needs is_true");
    if (!item.correct_answer) add("challenge needs correct_answer");
    if (!item.explanation) add("challenge needs an explanation");
    if (item.statement && typeof item.is_true === "boolean") {
      const actual = checkArithmetic(item.statement);
      if (actual !== null && actual !== item.is_true) {
        add(`arithmetic check: "${item.statement}" is actually ${actual ? "true" : "false"}`);
      }
    }
  }
  if ((item.type === "vocab" || item.type === "phrase") && !item.term) add(`${item.type} needs a term`);

  const needsSource = SOURCED_TOPICS.has(item.topic_code) && (item.type === "fact" || item.type === "lesson");
  if (needsSource && (!item.source_name || !item.source_url)) add("facts and lessons in this topic need source_name and source_url");
  if (item.source_url && !/^https:\/\/[^\s]+$/.test(item.source_url)) add("source_url must be an https URL");
  if (item.id && !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(item.id)) add("id must be a UUID");
  return problems;
}

/** Finds duplicate titles, statements and terms within a topic. */
export function findDuplicates(items: LoadedItem[]): Problem[] {
  const problems: Problem[] = [];
  const seen = new Map<string, string>();
  for (const { file, index, item } of items) {
    const where = `${file}[${index}]`;
    const keys = [`title:${item.topic_code}:${norm(item.title ?? "")}`];
    if (item.statement) keys.push(`statement:${norm(item.statement)}`);
    if (item.term) keys.push(`term:${item.topic_code}:${norm(item.term)}`);
    for (const key of keys) {
      const first = seen.get(key);
      if (first) problems.push({ where, message: `duplicate of ${first} (${key.split(":")[0]})` });
      else seen.set(key, where);
    }
  }
  return problems;
}

/** Reads KEY=VALUE lines from content-pipeline/.env (never committed). */
export function readEnv(): Record<string, string> {
  const env: Record<string, string> = { ...process.env } as Record<string, string>;
  const path = join(ROOT, ".env");
  if (existsSync(path)) {
    for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
      const match = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (match && !env[match[1]]) env[match[1]] = match[2].replace(/^["']|["']$/g, "");
    }
  }
  return env;
}
