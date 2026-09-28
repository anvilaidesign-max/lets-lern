import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box } from "./kit.mjs";

export default {
  court_hierarchy: svg([
    title("Zimbabwe's courts"),
    box(270, 62, 260, 58, "Constitutional Court", { fill: C.purpleLight, stroke: C.purple, size: 18, sub: "final say on the Constitution" }),
    box(220, 132, 360, 58, "Supreme Court", { fill: C.blueLight, stroke: C.blue, size: 18, sub: "final court of appeal" }),
    box(90, 202, 280, 58, "High Court", { fill: C.tealLight, stroke: C.teal, size: 18, sub: "serious cases, appeals, reviews" }),
    box(385, 202, 160, 58, "Labour Court", { fill: C.tealLight, stroke: C.teal, size: 16, sub: "employment" }),
    box(560, 202, 170, 58, "Administrative", { fill: C.tealLight, stroke: C.teal, size: 16, sub: "tax, licences, land" }),
    box(90, 272, 640, 58, "Magistrates' courts", { fill: C.orangeLight, stroke: C.orange, size: 18, sub: "most criminal and civil cases start here" }),
    box(90, 342, 640, 58, "Local courts (chiefs and headmen)", { fill: C.yellowLight, stroke: C.yellow, size: 18, sub: "customary law disputes" }),
    arrow(50, 390, 50, 80, { color: C.red, width: 4, head: 16 }),
    `<text x="30" y="235" font-family="Arial, Helvetica, sans-serif" font-size="16" font-weight="bold" fill="${C.red}" text-anchor="middle" transform="rotate(-90 30 235)">appeals go up</text>`,
    text(400, 432, "Specialised courts sit alongside the High Court; appeals from them go to the Supreme Court.", { size: 14, color: C.muted, italic: true }),
  ].join("\n")),

  contract_elements: svg([
    title("What makes a valid contract"),
    box(30, 70, 130, 52, "Offer", { fill: C.blueLight, stroke: C.blue }),
    text(185, 104, "+", { size: 30, color: C.ink, weight: "bold" }),
    box(210, 70, 150, 52, "Acceptance", { fill: C.blueLight, stroke: C.blue }),
    arrow(362, 96, 400, 96, { width: 3 }),
    box(402, 70, 150, 52, "Agreement", { fill: C.purpleLight, stroke: C.purple }),
    ...[["Serious intention", 30], ["Capacity (18+)", 222], ["Lawful and possible", 414], ["Formalities if any", 606]].map(([t, x]) => box(x, 158, 170, 44, t, { fill: "#F8FAFC", stroke: C.grid, size: 15 })),
    text(400, 146, "plus all of these", { size: 14, color: C.muted, italic: true }),
    path("M115,202 L115,222 L691,222 L691,202", { stroke: C.muted, width: 2.5 }),
    line(307, 202, 307, 222, { color: C.muted, width: 2.5 }), line(499, 202, 499, 222, { color: C.muted, width: 2.5 }),
    
    arrow(400, 222, 400, 250, { width: 3 }),
    box(280, 252, 240, 54, "Valid contract", { fill: C.greenLight, stroke: C.green, size: 19 }),
    text(400, 338, "If one side breaks it, the other may claim:", { size: 16, color: C.red, weight: "bold" }),
    box(60, 358, 210, 58, "Specific performance", { fill: C.redLight, stroke: C.red, size: 15, sub: "do what you promised" }),
    box(295, 358, 210, 58, "Damages", { fill: C.redLight, stroke: C.red, size: 15, sub: "money for the loss" }),
    box(530, 358, 210, 58, "Cancellation", { fill: C.redLight, stroke: C.red, size: 15, sub: "if the breach is serious" }),
  ].join("\n")),

  criminal_process: svg([
    title("A criminal case, step by step"),
    ...[["Arrest", "told the reason", C.red, C.redLight], ["Court in 48 h", "bail is the norm", C.orange, C.orangeLight], ["Trial", "state proves guilt", C.blue, C.blueLight], ["Verdict", "guilty or not", C.purple, C.purpleLight], ["Appeal", "higher court", C.green, C.greenLight]].map(([t, s, c, f], i) => {
      const x = 22 + i * 155;
      return box(x, 80, 136, 76, t, { fill: f, stroke: c, size: 17, sub: s }) + (i < 4 ? arrow(x + 136, 118, x + 153, 118, { width: 2.5 }) : "");
    }),
    text(400, 205, "How sure must the court be?", { size: 19, color: C.ink, weight: "bold" }),
    // civil gauge
    text(60, 250, "Civil case", { size: 16, color: C.teal, weight: "bold", anchor: "start" }),
    rect(200, 234, 520, 24, { fill: "#F1F5F9", stroke: C.grid, rx: 12 }),
    rect(200, 234, 275, 24, { fill: C.tealLight, stroke: C.teal, rx: 12 }),
    text(488, 252, "more likely than not (> 50%)", { size: 14, color: C.teal, weight: "bold", anchor: "start" }),
    // criminal gauge
    text(60, 305, "Criminal case", { size: 16, color: C.red, weight: "bold", anchor: "start" }),
    rect(200, 289, 520, 24, { fill: "#F1F5F9", stroke: C.grid, rx: 12 }),
    rect(200, 289, 500, 24, { fill: C.redLight, stroke: C.red, rx: 12 }),
    text(450, 306, "beyond reasonable doubt", { size: 14, color: C.red, weight: "bold" }),
    rect(80, 350, 640, 70, { fill: C.yellowLight, stroke: C.yellow }),
    text(400, 380, "Presumed innocent until proven guilty", { size: 18, color: C.ink, weight: "bold" }),
    text(400, 405, "The accused never has to prove innocence.", { size: 15, color: C.muted }),
  ].join("\n")),

  ip_types: svg([
    title("Four ways to protect ideas"),
    ...[
      ["Patent", "inventions", "must register", "about 20 years", C.blue, C.blueLight],
      ["Copyright", "code, books, music", "automatic", "decades after death", C.purple, C.purpleLight],
      ["Trademark", "names and logos", "register to be safe", "renewable forever", C.orange, C.orangeLight],
      ["Trade secret", "recipes, know-how", "keep it secret", "as long as secret", C.green, C.greenLight],
    ].map(([name, what, how, long, c, f], i) => {
      const x = 24 + i * 192;
      return rect(x, 70, 176, 300, { fill: f, stroke: c }) +
        circle(x + 88, 125, 34, { fill: "#FFFFFF", stroke: c, width: 4 }) +
        text(x + 88, 136, ["P", "©", "™", "S"][i], { size: 32, color: c, weight: "bold" }) +
        text(x + 88, 195, name, { size: 20, color: C.ink, weight: "bold" }) +
        text(x + 88, 232, "Protects", { size: 13, color: C.muted }) + text(x + 88, 252, what, { size: 15, color: C.ink, weight: "bold" }) +
        text(x + 88, 288, "How", { size: 13, color: C.muted }) + text(x + 88, 308, how, { size: 15, color: C.ink, weight: "bold" }) +
        text(x + 88, 340, "Lasts", { size: 13, color: C.muted }) + text(x + 88, 358, long, { size: 15, color: C.ink, weight: "bold" });
    }),
    text(400, 412, "Code is protected by copyright automatically; a new technical method may be patentable.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
