// Checks that every source_url responds. Usage: node scripts/check-links.ts

import { loadContent } from "./lib.ts";

const urls = [...new Set(loadContent().map(({ item }) => item.source_url).filter((u): u is string => !!u))];
console.log(`Checking ${urls.length} unique source URLs...`);

const broken: string[] = [];
const queue = [...urls];

const ATTEMPTS = 5;

async function check(url: string): Promise<void> {
  for (let attempt = 1; attempt <= ATTEMPTS; attempt++) {
    try {
      const res = await fetch(url, {
        method: "GET",
        redirect: "follow",
        headers: { "User-Agent": "DailyMindContentPipeline/1.0 (link check)" },
        signal: AbortSignal.timeout(20_000),
      });
      await res.body?.cancel();
      if (res.ok) return;
      // 429 means "slow down", not "broken": back off and retry.
      if (res.status !== 429 || attempt === ATTEMPTS) {
        broken.push(`${res.status} ${url}`);
        return;
      }
    } catch (error) {
      if (attempt === ATTEMPTS) broken.push(`ERR ${url} (${error})`);
    }
    await new Promise((r) => setTimeout(r, 2000 * attempt));
  }
}

async function worker(): Promise<void> {
  while (queue.length > 0) {
    const url = queue.shift()!;
    await check(url);
  }
}

await Promise.all(Array.from({ length: 3 }, worker));

if (broken.length > 0) {
  console.error(`\n${broken.length} broken link(s):`);
  for (const b of broken) console.error(`  - ${b}`);
  process.exit(1);
}
console.log("All links respond.");
