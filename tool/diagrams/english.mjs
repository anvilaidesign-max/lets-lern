import { C, svg, text, title, line, rect, polygon, arrow, box } from "./kit.mjs";

const word = (x, w, label, role, color, fill) =>
  rect(x, 90, w, 54, { fill, stroke: color }) + text(x + w / 2, 124, label, { size: 19, color: C.ink, weight: "bold" }) +
  line(x + w / 2, 146, x + w / 2, 168, { color, width: 2.5 }) + text(x + w / 2, 188, role, { size: 15, color, weight: "bold" });

export default {
  sentence_parts: svg([
    title("The parts of a sentence"),
    word(30, 170, "The engineer", "subject", C.blue, C.blueLight),
    word(210, 110, "tested", "verb", C.red, C.redLight),
    word(330, 190, "the new circuit", "object", C.green, C.greenLight),
    word(530, 120, "carefully", "adverb", C.purple, C.purpleLight),
    word(660, 110, "today.", "time", C.orange, C.orangeLight),
    text(400, 232, "Who did it? · What happened? · To what? · How? · When?", { size: 15, color: C.muted, italic: true }),
    rect(30, 256, 740, 170, { fill: "#F8FAFC", stroke: C.grid }),
    text(50, 288, "Simple:", { size: 16, color: C.blue, weight: "bold", anchor: "start" }),
    text(160, 288, "The motor stopped.", { size: 16, color: C.ink, anchor: "start" }),
    text(50, 330, "Compound:", { size: 16, color: C.orange, weight: "bold", anchor: "start" }),
    text(160, 330, "The motor stopped, and the alarm sounded.", { size: 16, color: C.ink, anchor: "start" }),
    text(160, 352, "two main clauses joined by and, but, or, so", { size: 13, color: C.muted, anchor: "start" }),
    text(50, 394, "Complex:", { size: 16, color: C.purple, weight: "bold", anchor: "start" }),
    text(160, 394, "When the fuse blew, the motor stopped.", { size: 16, color: C.ink, anchor: "start" }),
    text(160, 416, "a dependent clause (when, because, although) + a main clause", { size: 13, color: C.muted, anchor: "start" }),
  ].join("\n")),

  peel_paragraph: svg([
    title("Build a strong paragraph: PEEL"),
    ...[
      ["P", "Point", "State your main idea in one sentence.", "Solar power suits rural clinics.", C.blue, C.blueLight],
      ["E", "Evidence", "Give facts, data, examples or a source.", "It needs no grid and runs fridges for vaccines.", C.orange, C.orangeLight],
      ["E", "Explain", "Show how the evidence proves the point.", "So clinics can store medicine despite load-shedding.", C.purple, C.purpleLight],
      ["L", "Link", "Connect back to your argument or the next idea.", "This is why solar should come first in rural plans.", C.green, C.greenLight],
    ].map(([k, name, what, eg, c, f], i) => {
      const y = 64 + i * 92;
      return rect(30, y, 740, 80, { fill: f, stroke: c }) +
        rect(44, y + 14, 52, 52, { fill: c, stroke: c, rx: 10 }) + text(70, y + 50, k, { size: 28, color: "#FFFFFF", weight: "bold" }) +
        text(112, y + 32, name, { size: 18, color: C.ink, weight: "bold", anchor: "start" }) +
        text(220, y + 32, what, { size: 15, color: C.ink, anchor: "start" }) +
        text(112, y + 60, `e.g. "${eg}"`, { size: 14, color: C.muted, italic: true, anchor: "start" });
    }),
  ].join("\n")),

  rhetoric_triangle: svg([
    title("Three ways to persuade"),
    polygon([[400, 80], [150, 380], [650, 380]], { fill: "#F8FAFC", stroke: C.grid, width: 3 }),
    box(300, 62, 200, 76, "Ethos", { fill: C.blueLight, stroke: C.blue, size: 22, sub: "trust in the speaker" }),
    box(40, 330, 220, 76, "Pathos", { fill: C.redLight, stroke: C.red, size: 22, sub: "the audience's feelings" }),
    box(540, 330, 220, 76, "Logos", { fill: C.greenLight, stroke: C.green, size: 22, sub: "logic and evidence" }),
    text(400, 232, "Your message", { size: 20, color: C.ink, weight: "bold" }),
    text(400, 258, "strongest when all three work together", { size: 14, color: C.muted, italic: true }),
    text(175, 210, "\"As an engineer with", { size: 13, color: C.blue, italic: true, anchor: "end" }), text(175, 228, "ten years on site...\"", { size: 13, color: C.blue, italic: true, anchor: "end" }),
    text(625, 210, "\"Outages cost us", { size: 13, color: C.green, italic: true, anchor: "start" }), text(625, 228, "12% of output.\"", { size: 13, color: C.green, italic: true, anchor: "start" }),
    text(400, 432, "\"Imagine a nurse delivering a baby by phone torchlight.\"  (pathos)", { size: 14, color: C.red, italic: true }),
  ].join("\n")),
};
