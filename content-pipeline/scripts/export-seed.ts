// Writes the offline seed pack shipped inside the app (ARCHITECTURE.md 12.4):
// assets/seed/content_seed.json, every item verified and in the offline pack.
//
// Usage: node scripts/export-seed.ts
// Bump happens automatically: the version is the export time (YYYYMMDDHH), so
// the app reloads the pack after an update.

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { findDuplicates, loadContent, loadEssayPrompts, REPO_ROOT, stableUuid, TOPICS, validateItem, withId } from "./lib.ts";

const loaded = loadContent();
const problems = [
  ...loaded.flatMap(({ file, index, item }) => validateItem(item, `${file}[${index}]`)),
  ...findDuplicates(loaded),
];
if (problems.length > 0) {
  console.error("Validation failed. Run `node scripts/validate.ts` for details.");
  process.exit(1);
}

const now = new Date();
const version = Number(now.toISOString().slice(0, 13).replace(/[-T]/g, ""));
const generatedAt = now.toISOString();

const items = loaded.map(({ item }) => ({
  ...withId(item),
  difficulty: item.difficulty ?? 1,
  verified: true,
  in_offline_pack: true,
  is_active: true,
  updated_at: generatedAt,
}));

const essayPrompts = loadEssayPrompts().map((p) => ({ id: stableUuid(`prompt|${p.prompt}`), ...p }));

const pack = { version, generated_at: generatedAt, topics: TOPICS, essay_prompts: essayPrompts, items };
const dir = join(REPO_ROOT, "assets", "seed");
mkdirSync(dir, { recursive: true });
writeFileSync(join(dir, "content_seed.json"), JSON.stringify(pack));
console.log(`Wrote assets/seed/content_seed.json: v${version}, ${items.length} items, ${essayPrompts.length} prompts.`);
