import { C, svg, text, title, line, rect, circle, arrow, box, polyline, dot } from "./kit.mjs";

export default {
  compound_growth: (() => {
    const px = 80, py = 70, pw = 500, ph = 300, years = 30, max = 18000;
    const X = (y) => px + (y / years) * pw, Y = (v) => py + ph - (v / max) * ph;
    const simple = [], compound = [];
    for (let y = 0; y <= years; y++) {
      simple.push(`${X(y).toFixed(1)},${Y(1000 + 100 * y).toFixed(1)}`);
      compound.push(`${X(y).toFixed(1)},${Y(1000 * Math.pow(1.1, y)).toFixed(1)}`);
    }
    let grid = "";
    for (let v = 0; v <= 18000; v += 6000) grid += line(px, Y(v), px + pw, Y(v), { color: C.grid, width: 1.5 }) + text(px - 10, Y(v) + 5, v.toLocaleString("en-US"), { size: 13, color: C.muted, anchor: "end" });
    for (let y = 0; y <= years; y += 10) grid += text(X(y), py + ph + 22, `${y}`, { size: 13, color: C.muted });
    return svg([
      title("1,000 at 10% a year: simple vs compound"),
      grid,
      line(px, py + ph, px + pw, py + ph, { width: 2.5 }), line(px, py - 8, px, py + ph, { width: 2.5 }),
      polyline(simple.join(" "), { stroke: C.orange, width: 4 }),
      polyline(compound.join(" "), { stroke: C.green, width: 4 }),
      dot(X(30), Y(4000), 6, C.orange), text(X(30) - 8, Y(4000) - 12, "4,000", { size: 15, color: C.orange, weight: "bold", anchor: "end" }),
      dot(X(30), Y(17449), 6, C.green), text(X(30) - 10, Y(17449) + 4, "17,449", { size: 15, color: C.green, weight: "bold", anchor: "end" }),
      text(px + pw / 2, py + ph + 44, "years", { size: 14, color: C.muted }),
      rect(600, 80, 180, 280, { fill: "#F8FAFC", stroke: C.grid }),
      line(620, 110, 650, 110, { color: C.green, width: 4 }), text(658, 115, "compound", { size: 14, color: C.ink, anchor: "start" }),
      line(620, 138, 650, 138, { color: C.orange, width: 4 }), text(658, 143, "simple", { size: 14, color: C.ink, anchor: "start" }),
      text(690, 190, "FV = PV × (1 + r)ⁿ", { size: 16, color: C.ink, weight: "bold" }),
      text(690, 240, "Rule of 72:", { size: 15, color: C.ink, weight: "bold" }),
      text(690, 262, "years to double", { size: 14, color: C.muted }), text(690, 282, "≈ 72 ÷ rate", { size: 14, color: C.muted }),
      text(690, 316, "72 ÷ 10 ≈ 7 years", { size: 14, color: C.green, weight: "bold" }),
    ].join("\n"));
  })(),

  risk_return: (() => {
    const px = 90, py = 70, pw = 560, ph = 290;
    const assets = [
      ["Cash savings", 0.05, 0.08, C.muted],
      ["Government bonds", 0.18, 0.2, C.blue],
      ["Corporate bonds", 0.3, 0.3, C.teal],
      ["Property", 0.45, 0.45, C.orange],
      ["Share index fund", 0.6, 0.6, C.green, true],
      ["Single company", 0.8, 0.6, C.purple],
      ["Startups", 0.93, 0.85, C.red, true],
    ];
    let pts = "";
    for (const [name, r, ret, c, left] of assets) {
      const x = px + r * pw, y = py + ph - ret * ph;
      pts += circle(x, y, 13, { fill: c, stroke: "#FFFFFF", width: 3 }) + text(x + (left ? -20 : 20), y + 5, name, { size: 15, color: C.ink, weight: "bold", anchor: left ? "end" : "start" });
    }
    return svg([
      title("Risk and return go together"),
      arrow(px, py + ph, px + pw + 20, py + ph, { width: 2.5 }), arrow(px, py + ph, px, py - 14, { width: 2.5 }),
      text(px + pw / 2, py + ph + 30, "risk: how much the value swings", { size: 15, color: C.muted }),
      `<text x="50" y="${py + ph / 2}" font-family="Arial, Helvetica, sans-serif" font-size="15" fill="${C.muted}" text-anchor="middle" transform="rotate(-90 50 ${py + ph / 2})">expected long-run return</text>`,
      line(px + 20, py + ph - 10, px + pw - 10, py + 20, { color: C.grid, width: 3, dash: "8 6" }),
      pts,
      rect(560, 380, 225, 56, { fill: C.yellowLight, stroke: C.yellow }),
      text(672, 403, "One company: more risk,", { size: 14, color: C.ink, weight: "bold" }), text(672, 424, "no extra reward. Diversify.", { size: 14, color: C.ink, weight: "bold" }),
    ].join("\n"));
  })(),

  balance_sheet: svg([
    title("The balance sheet always balances"),
    text(210, 80, "What the company OWNS", { size: 17, color: C.blue, weight: "bold" }),
    text(590, 80, "Where the money CAME FROM", { size: 17, color: C.purple, weight: "bold" }),
    box(90, 95, 240, 80, "Cash", { fill: C.blueLight, stroke: C.blue, sub: "and money owed by customers" }),
    box(90, 180, 240, 70, "Stock", { fill: C.blueLight, stroke: C.blue, sub: "goods not yet sold" }),
    box(90, 255, 240, 110, "Equipment, buildings", { fill: C.blueLight, stroke: C.blue, sub: "long-term assets" }),
    box(470, 95, 240, 120, "Liabilities", { fill: C.orangeLight, stroke: C.orange, sub: "loans, unpaid suppliers" }),
    box(470, 220, 240, 145, "Equity", { fill: C.purpleLight, stroke: C.purple, sub: "owners' money + kept profits" }),
    text(400, 240, "=", { size: 48, color: C.ink, weight: "bold" }),
    text(210, 395, "Assets", { size: 20, color: C.blue, weight: "bold" }),
    text(590, 395, "Liabilities + Equity", { size: 20, color: C.purple, weight: "bold" }),
    text(400, 432, "A snapshot on one day. Profit over the year adds to equity.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
