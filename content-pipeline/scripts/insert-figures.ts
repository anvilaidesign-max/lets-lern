// One-off helper: inserts book illustrations into chapter markdown, just
// before a given heading. Skips a chapter that already shows that figure.
//
// Usage: node scripts/insert-figures.ts

import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { REPO_ROOT } from "./lib.ts";

type Figure = { file: string; before: string; name: string; caption: string };

const FIGURES: Figure[] = [
  { file: "math/01-algebra-functions.md", before: "## Exponentials", name: "quadratic_roots", caption: "y = x² − 5x + 6 crosses the x-axis at its roots, x = 2 and x = 3; the vertex sits halfway between." },
  { file: "math/02-derivatives.md", before: "## Derivatives in electronics", name: "derivative_tangent", caption: "The derivative at a point is the slope of the tangent line touching the curve there." },
  { file: "math/03-integrals.md", before: "## Two useful techniques", name: "integral_area", caption: "Thin strips under the curve add up to the area; make them thinner and the sum becomes the integral." },
  { file: "math/04-linear-algebra.md", before: "## Eigenvalues and eigenvectors", name: "matrix_rotation", caption: "The rotation matrix R turns every vector 90° anticlockwise: (3, 1) becomes (−1, 3)." },
  { file: "math/05-probability-statistics.md", before: "## Why the normal distribution is everywhere", name: "normal_curve", caption: "About 68% of values fall within 1 standard deviation of the mean, 95% within 2 and 99.7% within 3." },
  { file: "math/06-complex-transforms.md", before: "## Euler's formula", name: "complex_plane", caption: "The same number in two forms: 3 + j4 in rectangular form is 5∠53.1° in polar form." },
  { file: "science/01-forces-energy.md", before: "## Momentum", name: "forces_car", caption: "Only the unbalanced (net) force accelerates the car; weight and the road's reaction cancel out." },
  { file: "science/02-electricity-magnetism.md", before: "# Key points", name: "em_spectrum", caption: "Radio waves, light and X-rays are the same thing, electromagnetic waves, at different frequencies." },
  { file: "science/03-modern-physics.md", before: "## Waves, particles and uncertainty", name: "photoelectric", caption: "Brighter red light still frees no electrons; each photon's energy E = hf is what matters." },
  { file: "science/04-chemistry-life.md", before: "## Cells and evolution", name: "dna_helix", caption: "DNA's two strands are held together by base pairs; genes are read into RNA, then built into proteins." },
  { file: "tech/01-how-computers-work.md", before: "## From code to instructions", name: "cpu_memory", caption: "The CPU fetches, decodes and executes instructions; memory trades speed for size." },
  { file: "tech/02-how-the-internet-works.md", before: "## The physical internet", name: "internet_path", caption: "Your request is looked up in DNS, then travels as packets through routers, your ISP and undersea cables." },
  { file: "tech/03-ai-machine-learning.md", before: "## Large language models", name: "neural_network", caption: "Each connection has a weight; training nudges millions or billions of weights to reduce the error." },
  { file: "tech/04-cybersecurity.md", before: "## Digital signatures and certificates", name: "public_key", caption: "Anyone can lock a message with Rudo's public key, but only her private key can unlock it." },
  { file: "medicine/01-heart-blood-lungs.md", before: "## The heart's own electricity", name: "heart_circulation", caption: "The right side pumps blood to the lungs; the stronger left side pumps it around the body." },
  { file: "medicine/02-infection-immunity.md", before: "## Malaria", name: "immune_memory", caption: "A vaccine gives a small first response; the real germ later meets a fast, strong memory response." },
  { file: "medicine/03-how-medicines-work.md", before: "## The therapeutic window", name: "drug_half_life", caption: "With a 4-hour half-life, a 100 mg dose falls to 50, 25, 12.5 then 6.25 mg." },
  { file: "medicine/04-first-aid.md", before: "## The recovery position", name: "first_aid_steps", caption: "Work through DRSABC in order, and start CPR if the person is not breathing normally." },
];

const dir = join(REPO_ROOT, "content-pipeline", "content", "chapters");
let changed = 0;
for (const f of FIGURES) {
  const path = join(dir, f.file);
  const text = readFileSync(path, "utf8").replace(/\r\n/g, "\n");
  if (text.includes(`](${f.name})`)) continue;
  const at = text.indexOf(`\n${f.before}\n`);
  if (at < 0) throw new Error(`${f.file}: heading "${f.before}" not found`);
  const next = `${text.slice(0, at + 1)}![${f.caption}](${f.name})\n\n${text.slice(at + 1)}`;
  writeFileSync(path, next);
  changed++;
}
console.log(`Inserted ${changed} figures.`);
