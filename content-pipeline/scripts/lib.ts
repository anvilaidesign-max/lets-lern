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
  { code: "math", name: "Mathematics", icon: "calculate", sort_order: 1, min_items: 40 },
  { code: "english", name: "English", icon: "menu_book", sort_order: 2, min_items: 40 },
  { code: "french", name: "French", icon: "translate", sort_order: 3, min_items: 40 },
  { code: "science", name: "Science", icon: "science", sort_order: 4, min_items: 40 },
  { code: "tech", name: "Technology", icon: "memory", sort_order: 5, min_items: 25 },
  { code: "engineering", name: "Electronics Engineering", icon: "electrical_services", sort_order: 6, min_items: 25 },
  { code: "medicine", name: "Medicine", icon: "medical_services", sort_order: 7, min_items: 25 },
  { code: "law", name: "Law", icon: "gavel", sort_order: 8, min_items: 25 },
  { code: "politics", name: "Politics", icon: "account_balance", sort_order: 9, min_items: 40 },
  { code: "economics", name: "Economics", icon: "trending_up", sort_order: 10, min_items: 40 },
  { code: "finance", name: "Finance", icon: "savings", sort_order: 11, min_items: 40 },
  { code: "business", name: "Business & Startups", icon: "rocket_launch", sort_order: 12, min_items: 25 },
  { code: "relations", name: "International Relations", icon: "public", sort_order: 13, min_items: 40 },
];

const TOPIC_CODES = new Set(TOPICS.map((t) => t.code));
const TYPES = new Set(["fact", "lesson", "challenge", "vocab", "phrase"]);
const SOURCED_TOPICS = new Set(["science", "politics", "economics", "finance", "relations", "tech", "engineering", "medicine", "law", "business"]);
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

// ---------------------------------------------------------------------------
// Topic books: content/chapters/<topic>/<nn>-<slug>.md
//
// ---
// topic: engineering
// position: 1
// title: DC circuits
// summary: One or two sentences.
// difficulty: 1
// sources:
// - Name | https://...
// ---
// Body in light markup (## heading, - bullet, > callout, **bold**).
//
// # Key points
// - point
//
// # Quiz
// Q: question?
// - wrong option
// * correct option
// - wrong option
// > explanation
// ---------------------------------------------------------------------------

export const CHAPTERS_DIR = join(CONTENT_DIR, "chapters");

export interface QuizQuestion {
  question: string;
  options: string[];
  answer: number;
  explanation: string;
}

export interface Chapter {
  id: string;
  topic_code: string;
  position: number;
  title: string;
  summary: string;
  difficulty: number;
  body: string;
  key_points: string[];
  quiz: QuizQuestion[];
  sources: { name: string; url: string }[];
  file: string;
}

export function chapterId(topic: string, position: number): string {
  return stableUuid(`chapter|${topic}|${position}`);
}

export function parseChapter(text: string, file: string): Chapter {
  const src = text.replace(/\r\n/g, "\n");
  const fm = src.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!fm) throw new Error(`${file}: missing front matter`);
  const meta: Record<string, string> = {};
  const sources: { name: string; url: string }[] = [];
  let inSources = false;
  for (const line of fm[1].split("\n")) {
    if (inSources && line.startsWith("- ")) {
      const [name, url] = line.slice(2).split("|").map((s) => s.trim());
      sources.push({ name, url });
      continue;
    }
    inSources = false;
    const m = line.match(/^(\w+):\s*(.*)$/);
    if (!m) continue;
    if (m[1] === "sources") inSources = true;
    else meta[m[1]] = m[2].trim();
  }

  const rest = fm[2];
  const kpIndex = rest.indexOf("\n# Key points");
  const quizIndex = rest.indexOf("\n# Quiz");
  if (kpIndex < 0 || quizIndex < 0) throw new Error(`${file}: needs "# Key points" and "# Quiz" sections`);
  const body = rest.slice(0, kpIndex).trim();
  const keyPoints = rest.slice(kpIndex, quizIndex).split("\n").filter((l) => l.startsWith("- ")).map((l) => l.slice(2).trim());

  const quiz: QuizQuestion[] = [];
  for (const block of rest.slice(quizIndex).split(/\nQ:\s*/).slice(1)) {
    const lines = block.split("\n");
    const question = lines[0].trim();
    const options: string[] = [];
    let answer = -1;
    const explanation: string[] = [];
    for (const l of lines.slice(1)) {
      if (l.startsWith("* ")) {
        answer = options.length;
        options.push(l.slice(2).trim());
      } else if (l.startsWith("- ")) {
        options.push(l.slice(2).trim());
      } else if (l.startsWith("> ")) {
        explanation.push(l.slice(2).trim());
      }
    }
    quiz.push({ question, options, answer, explanation: explanation.join(" ") });
  }

  const topic = meta.topic ?? "";
  const position = Number(meta.position);
  return {
    id: chapterId(topic, position),
    topic_code: topic,
    position,
    title: meta.title ?? "",
    summary: meta.summary ?? "",
    difficulty: Number(meta.difficulty ?? 1),
    body,
    key_points: keyPoints,
    quiz,
    sources,
    file,
  };
}

export function loadChapters(): Chapter[] {
  if (!existsSync(CHAPTERS_DIR)) return [];
  const chapters: Chapter[] = [];
  for (const topic of readdirSync(CHAPTERS_DIR).sort()) {
    const dir = join(CHAPTERS_DIR, topic);
    for (const file of readdirSync(dir).filter((f) => f.endsWith(".md")).sort()) {
      chapters.push(parseChapter(readFileSync(join(dir, file), "utf8"), `chapters/${topic}/${file}`));
    }
  }
  return chapters;
}

export function validateChapter(ch: Chapter): Problem[] {
  const problems: Problem[] = [];
  const add = (message: string) => problems.push({ where: ch.file, message });
  if (!TOPIC_CODES.has(ch.topic_code)) add(`unknown topic "${ch.topic_code}"`);
  if (!Number.isInteger(ch.position) || ch.position < 1) add("position must be a whole number from 1");
  if (ch.title.length < 3 || ch.title.length > 80) add("title must be 3-80 characters");
  if (ch.summary.length < 20 || ch.summary.length > 300) add("summary must be 20-300 characters");
  if (![1, 2, 3].includes(ch.difficulty)) add("difficulty must be 1, 2 or 3");
  if (ch.body.length < 1500) add(`body is only ${ch.body.length} characters (min 1500)`);
  if (ch.body.length > 14000) add(`body is ${ch.body.length} characters (max 14000)`);
  if (ch.key_points.length < 3 || ch.key_points.length > 8) add("needs 3-8 key points");
  if (ch.quiz.length < 4 || ch.quiz.length > 8) add(`needs 4-8 quiz questions (has ${ch.quiz.length})`);
  ch.quiz.forEach((q, i) => {
    if (q.question.length < 8) add(`quiz ${i + 1}: question is missing`);
    if (q.options.length < 2 || q.options.length > 4) add(`quiz ${i + 1}: needs 2-4 options`);
    if (q.answer < 0) add(`quiz ${i + 1}: mark the correct option with "* "`);
    if (!q.explanation) add(`quiz ${i + 1}: needs an explanation line starting with "> "`);
    if (new Set(q.options.map(norm)).size !== q.options.length) add(`quiz ${i + 1}: duplicate options`);
  });
  const figures = [...ch.body.matchAll(/^!\[([^\]]*)\]\(([a-z0-9_\-]+)\)$/gm)];
  if (figures.length < 1) add("needs at least one illustration: ![caption](diagram_name)");
  for (const f of figures) {
    if (!existsSync(join(REPO_ROOT, "assets", "diagrams", `${f[2]}.svg`))) add(`missing diagram assets/diagrams/${f[2]}.svg`);
    if (f[1].length < 5) add(`diagram ${f[2]} needs a caption`);
  }
  if (ch.sources.length < 1) add("needs at least one source");
  for (const s of ch.sources) {
    if (!s.name || !/^https:\/\/\S+$/.test(s.url ?? "")) add(`bad source line "${s.name} | ${s.url}"`);
  }
  for (const line of [...ch.body.split("\n"), ...ch.key_points]) {
    const stray = strayMarkup(line);
    if (stray) add(`stray "${stray}" (nested or unclosed markup) in: ${line.slice(0, 70)}`);
  }
  return problems;
}

// Mirrors ChapterMarkup.inline in the app: **bold**, ~~struck~~, *italic*, `code`.
// Anything left over would show as literal symbols in the reader.
const INLINE = /\*\*[^*]+\*\*|~~[^~]+~~|\*[^*\s][^*]*\*|`[^`]+`/g;

function strayMarkup(line: string): string | null {
  if (/^!\[/.test(line)) return null;
  const rest = line.replace(/^\s*(- |> |#+ )/, "").replace(INLINE, "");
  return rest.includes("~~") ? "~~" : rest.includes("*") ? "*" : null;
}