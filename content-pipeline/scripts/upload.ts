// Upserts content into Supabase with the service role key (ARCHITECTURE.md 12.2).
//
// Usage: node scripts/upload.ts [--verified] [--offline-pack] [--dry-run]
//
// Everything uploads with verified = false unless --verified is passed after
// the review step. Needs SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in the
// environment or in content-pipeline/.env (never commit that file).

import { findDuplicates, loadChapters, loadContent, readEnv, validateChapter, validateItem, withId } from "./lib.ts";

const args = new Set(process.argv.slice(2));
const verified = args.has("--verified");
const offlinePack = args.has("--offline-pack");
const dryRun = args.has("--dry-run");

const loaded = loadContent();
const chapters = loadChapters();
const problems = [
  ...loaded.flatMap(({ file, index, item }) => validateItem(item, `${file}[${index}]`)),
  ...findDuplicates(loaded),
  ...chapters.flatMap(validateChapter),
];
if (problems.length > 0) {
  console.error("Validation failed. Run `node scripts/validate.ts` for details.");
  process.exit(1);
}

const rows = loaded.map(({ item }) => {
  const withIdItem = withId(item);
  return {
    id: withIdItem.id,
    topic_code: item.topic_code,
    type: item.type,
    title: item.title,
    body: item.body,
    statement: item.statement ?? null,
    is_true: item.is_true ?? null,
    correct_answer: item.correct_answer ?? null,
    explanation: item.explanation ?? null,
    term: item.term ?? null,
    translation: item.translation ?? null,
    example_sentence: item.example_sentence ?? null,
    difficulty: item.difficulty ?? 1,
    source_name: item.source_name ?? null,
    source_url: item.source_url ?? null,
    verified: item.verified ?? verified,
    in_offline_pack: item.in_offline_pack ?? offlinePack,
    is_active: item.is_active ?? true,
  };
});

if (dryRun) {
  console.log(`Dry run: would upsert ${rows.length} items and ${chapters.length} chapters (verified=${verified}, offline_pack=${offlinePack}).`);
  process.exit(0);
}

const env = readEnv();
const url = env.SUPABASE_URL;
const key = env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) {
  console.error("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (in content-pipeline/.env).");
  process.exit(1);
}

async function upsert(table: string, rows: Record<string, unknown>[]): Promise<void> {
  for (let i = 0; i < rows.length; i += 200) {
    const batch = rows.slice(i, i + 200);
    const res = await fetch(`${url}/rest/v1/${table}?on_conflict=id`, {
      method: "POST",
      headers: {
        apikey: key!,
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
        Prefer: "resolution=merge-duplicates,return=minimal",
      },
      body: JSON.stringify(batch),
    });
    if (!res.ok) {
      console.error(`Upload to ${table} failed at batch ${i / 200 + 1}: ${res.status} ${await res.text()}`);
      process.exit(1);
    }
    console.log(`${table}: upserted ${Math.min(i + 200, rows.length)} / ${rows.length}`);
  }
}

await upsert("content_items", rows);
await upsert(
  "chapters",
  chapters.map(({ file: _file, ...ch }) => ({ ...ch, verified: verified, is_active: true })),
);
console.log("Done.");