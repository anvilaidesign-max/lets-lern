// Validates all content: cards (schema, lengths, sources, duplicates, simple
// arithmetic) and topic books (structure, quiz, sources).
// Usage: node scripts/validate.ts   Exits with code 1 on any problem.

import { findDuplicates, loadChapters, loadContent, loadEssayPrompts, validateChapter, validateItem, TOPICS } from "./lib.ts";
import type { Problem } from "./lib.ts";

const items = loadContent();
const problems: Problem[] = [];
for (const { file, index, item } of items) {
  problems.push(...validateItem(item, `${file}[${index}] "${item.title}"`));
}
problems.push(...findDuplicates(items));

const chapters = loadChapters();
for (const ch of chapters) problems.push(...validateChapter(ch));
const seenPositions = new Set<string>();
for (const ch of chapters) {
  const key = `${ch.topic_code}#${ch.position}`;
  if (seenPositions.has(key)) problems.push({ where: ch.file, message: `duplicate position ${ch.position} in ${ch.topic_code}` });
  seenPositions.add(key);
}

const active = items.filter(({ item }) => item.is_active !== false);
const perTopic = new Map<string, number>();
for (const { item } of active) perTopic.set(item.topic_code, (perTopic.get(item.topic_code) ?? 0) + 1);
const chaptersPerTopic = new Map<string, number>();
for (const ch of chapters) chaptersPerTopic.set(ch.topic_code, (chaptersPerTopic.get(ch.topic_code) ?? 0) + 1);

for (const topic of TOPICS) {
  const count = perTopic.get(topic.code) ?? 0;
  if (count < topic.min_items) problems.push({ where: topic.code, message: `only ${count} active cards (needs ${topic.min_items})` });
  const books = chaptersPerTopic.get(topic.code) ?? 0;
  if (books < 3) problems.push({ where: topic.code, message: `only ${books} chapters (needs 3)` });
}

const prompts = loadEssayPrompts();
if (prompts.length < 30) problems.push({ where: "essay_prompts.json", message: `only ${prompts.length} prompts (need 30+)` });

const questions = chapters.reduce((n, c) => n + c.quiz.length, 0);
console.log(`Checked ${items.length} cards (${active.length} active), ${chapters.length} chapters (${questions} quiz questions), ${prompts.length} essay prompts.`);
for (const topic of TOPICS) {
  console.log(`  ${topic.code.padEnd(12)} ${String(perTopic.get(topic.code) ?? 0).padStart(3)} cards  ${chaptersPerTopic.get(topic.code) ?? 0} chapters`);
}

if (problems.length > 0) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  - ${p.where}: ${p.message}`);
  process.exit(1);
}
console.log("\nAll content is valid.");
