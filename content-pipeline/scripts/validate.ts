// Validates all content files: schema rules, lengths, sources, duplicates and
// simple arithmetic. Usage: node scripts/validate.ts
// Exits with code 1 if any problem is found.

import { findDuplicates, loadContent, loadEssayPrompts, validateItem, TOPICS } from "./lib.ts";
import type { Problem } from "./lib.ts";

const items = loadContent();
const problems: Problem[] = [];
for (const { file, index, item } of items) {
  problems.push(...validateItem(item, `${file}[${index}] "${item.title}"`));
}
problems.push(...findDuplicates(items));

const perTopic = new Map<string, number>();
for (const { item } of items) perTopic.set(item.topic_code, (perTopic.get(item.topic_code) ?? 0) + 1);
for (const topic of TOPICS) {
  const count = perTopic.get(topic.code) ?? 0;
  if (count < 40) problems.push({ where: topic.code, message: `only ${count} items (seed pack needs at least 40)` });
}

const prompts = loadEssayPrompts();
if (prompts.length < 30) problems.push({ where: "essay_prompts.json", message: `only ${prompts.length} prompts (need 30+)` });

console.log(`Checked ${items.length} items and ${prompts.length} essay prompts.`);
for (const topic of TOPICS) console.log(`  ${topic.code.padEnd(10)} ${perTopic.get(topic.code) ?? 0}`);

if (problems.length > 0) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  - ${p.where}: ${p.message}`);
  process.exit(1);
}
console.log("\nAll content is valid.");
