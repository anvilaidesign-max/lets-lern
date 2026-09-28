// Writes the offline seed pack shipped inside the app (ARCHITECTURE.md 12.4):
// assets/seed/content_seed.json with cards, topic books and essay prompts.
//
// Usage: node scripts/export-seed.ts
// The version is the export time (YYYYMMDDHHmm), so the app reloads the pack
// after an update.

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  findDuplicates, loadChapters, loadContent, loadEssayPrompts, REPO_ROOT, stableUuid, TOPICS, validateChapter, validateItem, withId,
} from "./lib.ts";

// --allow-partial ships only chapters that already pass validation (for test
// builds while books are still being written). Cards must always be valid.
const allowPartial = process.argv.includes("--allow-partial");
const loaded = loadContent();
const allChapters = loadChapters();
const chapters = allowPartial ? allChapters.filter((c) => validateChapter(c).length === 0) : allChapters;
if (allowPartial) console.log(`Partial export: ${chapters.length} of ${allChapters.length} chapters are complete.`);
const problems = [
  ...loaded.flatMap(({ file, index, item }) => validateItem(item, `${file}[${index}]`)),
  ...findDuplicates(loaded),
  ...chapters.flatMap(validateChapter),
];
if (problems.length > 0) {
  console.error("Validation failed. Run `node scripts/validate.ts` for details.");
  process.exit(1);
}

const now = new Date();
const version = Number(now.toISOString().slice(0, 16).replace(/[-T:]/g, ""));
const generatedAt = now.toISOString();

// Retired cards ship too, marked inactive, so phones that already have them
// switch them off.
const items = loaded.map(({ item }) => ({
  ...withId(item),
  difficulty: item.difficulty ?? 1,
  verified: true,
  in_offline_pack: true,
  is_active: item.is_active !== false,
  updated_at: generatedAt,
}));
const activeCount = items.filter((i) => i.is_active).length;

const books = chapters.map(({ file: _file, ...ch }) => ({ ...ch, is_active: true, verified: true, updated_at: generatedAt }));

const essayPrompts = loadEssayPrompts().map((p) => ({ id: stableUuid(`prompt|${p.prompt}`), ...p }));
const topics = TOPICS.map(({ min_items: _min, ...t }) => t);

const pack = { version, generated_at: generatedAt, topics, essay_prompts: essayPrompts, items, chapters: books };
const dir = join(REPO_ROOT, "assets", "seed");
mkdirSync(dir, { recursive: true });
writeFileSync(join(dir, "content_seed.json"), JSON.stringify(pack));
console.log(`Wrote assets/seed/content_seed.json: v${version}, ${activeCount} active cards (${items.length - activeCount} retired), ${books.length} chapters, ${essayPrompts.length} prompts.`);
