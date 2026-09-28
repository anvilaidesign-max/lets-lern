import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, polyline, dot } from "./kit.mjs";

export default {
  lean_loop: svg([
    title("Build, measure, learn"),
    circle(290, 245, 150, { fill: "#F8FAFC", stroke: C.grid, width: 2 }),
    box(215, 70, 150, 56, "Build", { fill: C.blueLight, stroke: C.blue, size: 19, sub: "smallest test" }),
    box(385, 300, 150, 56, "Measure", { fill: C.orangeLight, stroke: C.orange, size: 19, sub: "real behaviour" }),
    box(45, 300, 150, 56, "Learn", { fill: C.greenLight, stroke: C.green, size: 19, sub: "what's true?" }),
    path("M372,110 Q450,170 455,292", { stroke: C.muted, width: 3 }), polygon([[455, 298], [447, 282], [463, 283]], { fill: C.muted }),
    path("M380,352 Q290,410 200,352", { stroke: C.muted, width: 3 }), polygon([[196, 349], [214, 348], [206, 362]], { fill: C.muted }),
    path("M115,296 Q125,170 205,110", { stroke: C.muted, width: 3 }), polygon([[212, 104], [203, 120], [196, 107]], { fill: C.muted }),
    text(450, 190, "product", { size: 14, color: C.muted, italic: true, anchor: "start" }),
    text(290, 410, "data", { size: 14, color: C.muted, italic: true }),
    text(128, 190, "ideas", { size: 14, color: C.muted, italic: true, anchor: "end" }),
    text(290, 240, "as fast and", { size: 16, color: C.ink, weight: "bold" }), text(290, 262, "cheap as possible", { size: 16, color: C.ink, weight: "bold" }),
    rect(575, 90, 200, 290, { fill: C.yellowLight, stroke: C.yellow }),
    text(675, 125, "Then decide:", { size: 18, color: C.ink, weight: "bold" }),
    box(595, 150, 160, 74, "Persevere", { fill: C.greenLight, stroke: C.green, size: 17, sub: "it's working" }),
    box(595, 240, 160, 74, "Pivot", { fill: C.orangeLight, stroke: C.orange, size: 17, sub: "change one big thing" }),
    text(675, 350, "Slack began as a game;", { size: 13, color: C.muted }), text(675, 368, "Instagram as Burbn", { size: 13, color: C.muted }),
  ].join("\n")),

  funding_stages: (() => {
    const steps = [["Pre-seed", "idea, team", C.yellow, C.yellowLight, "100%"], ["Seed", "first product", C.orange, C.orangeLight, "80%"], ["Series A", "it works: scale", C.red, C.redLight, "64%"], ["Series B", "expand fast", C.purple, C.purpleLight, "51%"], ["Series C+", "dominate", C.blue, C.blueLight, "43%"], ["Exit", "sale or IPO", C.green, C.greenLight, ""]];
    let out = "";
    steps.forEach(([name, sub, c, f, own], i) => {
      const x = 30 + i * 125, h = 60 + i * 34, y = 330 - h;
      out += rect(x, y, 112, h, { fill: f, stroke: c });
      out += text(x + 56, y + 26, name, { size: 16, color: C.ink, weight: "bold" }) + text(x + 56, y + 46, sub, { size: 12, color: C.muted });
      if (own) out += text(x + 56, 380, own, { size: 17, color: C.blue, weight: "bold" });
    });
    out += arrow(40, 70, 170, 70, { color: C.green, width: 3 }) + text(40, 60, "valuation rises each round if you grow", { size: 14, color: C.green, weight: "bold", anchor: "start" });
    out += line(30, 330, 770, 330, { color: C.line, width: 2.5 });
    out += text(30, 354, "Founders' stake after each round:", { size: 13, color: C.muted, anchor: "start" });
    out += text(400, 412, "Each round sells about 20% of the company: founders own less of something far more valuable.", { size: 14, color: C.muted, italic: true });
    out += text(400, 432, "(illustrative numbers)", { size: 12, color: C.muted });
    return svg([title("How startups raise money"), out].join("\n"));
  })(),

  runway_chart: (() => {
    const px = 80, py = 80, pw = 520, ph = 270, months = 18, max = 700;
    const X = (m) => px + (m / months) * pw, Y = (v) => py + ph - (v / max) * ph;
    const flat = [], grow = [];
    let cashA = 600, cashB = 600, rev = 10;
    for (let m = 0; m <= months; m++) {
      flat.push(`${X(m).toFixed(1)},${Y(Math.max(0, cashA)).toFixed(1)}`);
      grow.push(`${X(m).toFixed(1)},${Y(cashB).toFixed(1)}`);
      cashA -= 50; rev *= 1.2; cashB -= Math.max(-40, 60 - rev);
    }
    let grid = "";
    for (let v = 0; v <= 600; v += 200) grid += line(px, Y(v), px + pw, Y(v), { color: C.grid, width: 1.5 }) + text(px - 10, Y(v) + 5, `${v}k`, { size: 13, color: C.muted, anchor: "end" });
    for (let m = 0; m <= months; m += 6) grid += text(X(m), py + ph + 22, `${m}`, { size: 13, color: C.muted });
    return svg([
      title("Burn rate and runway"),
      grid,
      line(px, py + ph, px + pw, py + ph, { width: 2.5 }), line(px, py - 10, px, py + ph, { width: 2.5 }),
      polyline(flat.join(" "), { stroke: C.red, width: 4 }),
      polyline(grow.join(" "), { stroke: C.green, width: 4 }),
      dot(X(12), Y(0), 7, C.red), text(X(12) + 12, Y(0) - 14, "cash runs out: month 12", { size: 14, color: C.red, weight: "bold", anchor: "start" }),
      text(px + pw / 2, py + ph + 44, "months", { size: 14, color: C.muted }),
      rect(620, 90, 160, 250, { fill: "#F8FAFC", stroke: C.grid }),
      text(700, 122, "Runway =", { size: 17, color: C.ink, weight: "bold" }), text(700, 146, "cash ÷ burn", { size: 17, color: C.ink, weight: "bold" }),
      text(700, 180, "600k ÷ 50k", { size: 15, color: C.muted }), text(700, 200, "= 12 months", { size: 15, color: C.muted }),
      line(640, 232, 670, 232, { color: C.red, width: 4 }), text(678, 237, "flat burn", { size: 13, color: C.ink, anchor: "start" }),
      line(640, 262, 670, 262, { color: C.green, width: 4 }), text(678, 267, "revenue grows", { size: 13, color: C.ink, anchor: "start" }),
      text(700, 300, "Growing revenue can", { size: 13, color: C.muted }), text(700, 318, "reach profit in time", { size: 13, color: C.muted }),
    ].join("\n"));
  })(),

  five_forces: svg([
    title("Porter's five forces"),
    box(290, 180, 220, 90, ["Rivalry among", "competitors"], { fill: C.redLight, stroke: C.red, size: 18 }),
    box(290, 62, 220, 72, "Threat of new entrants", { fill: C.blueLight, stroke: C.blue, size: 15, sub: "how easy to start up?" }),
    box(290, 316, 220, 72, "Threat of substitutes", { fill: C.purpleLight, stroke: C.purple, size: 15, sub: "other ways to solve it" }),
    box(30, 189, 200, 72, "Supplier power", { fill: C.orangeLight, stroke: C.orange, size: 16, sub: "can they squeeze you?" }),
    box(570, 189, 200, 72, "Buyer power", { fill: C.greenLight, stroke: C.green, size: 16, sub: "can customers switch?" }),
    arrow(400, 136, 400, 176, { width: 3 }), arrow(400, 314, 400, 274, { width: 3 }),
    arrow(232, 225, 286, 225, { width: 3 }), arrow(568, 225, 514, 225, { width: 3 }),
    text(400, 425, "The stronger the forces, the harder it is for anyone in the industry to make a profit.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
