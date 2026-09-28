// Builds every book illustration into assets/diagrams/*.svg.
// Usage: node tool/diagrams/build.mjs
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "..", "..", "assets", "diagrams");
mkdirSync(out, { recursive: true });

const groups = ["engineering", "math", "science", "tech", "medicine", "law", "business", "finance", "economics", "politics", "relations", "english", "french"];
let count = 0;
for (const g of groups) {
  let mod;
  try {
    mod = await import(`./${g}.mjs`);
  } catch (e) {
    if (e.code === "ERR_MODULE_NOT_FOUND") continue;
    throw e;
  }
  for (const [name, content] of Object.entries(mod.default)) {
    writeFileSync(join(out, `${name}.svg`), content);
    count++;
  }
}
console.log(`Wrote ${count} diagrams to assets/diagrams/`);
