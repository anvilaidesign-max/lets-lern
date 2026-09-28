import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, polyline, dot } from "./kit.mjs";

export default {
  supply_demand: (() => {
    const px = 90, py = 70, pw = 440, ph = 300;
    const P = (q, p) => [px + q * pw, py + ph - p * ph];
    const seg = (a, b, opts) => line(...P(...a), ...P(...b), opts);
    const e1 = P(0.5, 0.5), e2 = P(0.6, 0.6);
    return svg([
      title("Supply and demand"),
      arrow(px, py + ph, px + pw + 20, py + ph, { width: 2.5 }), arrow(px, py + ph, px, py - 14, { width: 2.5 }),
      text(px + pw + 16, py + ph + 26, "quantity", { size: 15, color: C.muted, anchor: "end" }),
      text(px - 12, py - 2, "price", { size: 15, color: C.muted, anchor: "end" }),
      seg([0.1, 0.1], [0.9, 0.9], { color: C.blue, width: 4 }), text(...P(0.92, 0.93), "Supply", { size: 16, color: C.blue, weight: "bold", anchor: "start" }),
      seg([0.1, 0.9], [0.9, 0.1], { color: C.red, width: 4 }), text(...P(0.92, 0.07), "Demand", { size: 16, color: C.red, weight: "bold", anchor: "start" }),
      seg([0.2, 1.0], [0.95, 0.25], { color: C.red, width: 3, dash: "8 6" }), text(...P(0.2, 1.03), "Demand rises", { size: 14, color: C.red, anchor: "start" }),
      arrow(...P(0.36, 0.6), ...P(0.46, 0.7), { color: C.red, width: 2.5 }),
      line(e1[0], e1[1], e1[0], py + ph, { color: C.muted, width: 2, dash: "5 4" }), line(px, e1[1], e1[0], e1[1], { color: C.muted, width: 2, dash: "5 4" }),
      line(e2[0], e2[1], e2[0], py + ph, { color: C.green, width: 2, dash: "5 4" }), line(px, e2[1], e2[0], e2[1], { color: C.green, width: 2, dash: "5 4" }),
      dot(e1[0], e1[1], 8, C.ink), dot(e2[0], e2[1], 8, C.green),
      text(px - 8, e1[1] + 5, "P₁", { size: 15, color: C.ink, weight: "bold", anchor: "end" }), text(px - 8, e2[1] + 5, "P₂", { size: 15, color: C.green, weight: "bold", anchor: "end" }),
      text(e1[0], py + ph + 22, "Q₁", { size: 15, color: C.ink, weight: "bold" }), text(e2[0], py + ph + 22, "Q₂", { size: 15, color: C.green, weight: "bold" }),
      rect(580, 90, 200, 260, { fill: "#F8FAFC", stroke: C.grid }),
      text(680, 122, "Equilibrium", { size: 17, color: C.ink, weight: "bold" }),
      text(680, 146, "where the curves cross", { size: 13, color: C.muted }),
      text(680, 190, "If demand rises:", { size: 15, color: C.green, weight: "bold" }),
      text(680, 214, "price goes up", { size: 15, color: C.ink }), text(680, 236, "quantity goes up", { size: 15, color: C.ink }),
      text(680, 280, "Price set too low?", { size: 15, color: C.red, weight: "bold" }),
      text(680, 304, "shortages and", { size: 15, color: C.ink }), text(680, 326, "empty shelves", { size: 15, color: C.ink }),
    ].join("\n"));
  })(),

  inflation_erosion: (() => {
    const px = 80, py = 70, pw = 500, ph = 300, years = 10;
    const X = (y) => px + (y / years) * pw, Y = (v) => py + ph - (v / 100) * ph;
    const rates = [[0.02, C.green, "2% a year"], [0.1, C.orange, "10% a year"], [0.5, C.red, "50% a year"]];
    let lines = "", labels = "";
    for (const [r, c, name] of rates) {
      const pts = [];
      for (let i = 0; i <= 100; i++) { const y = (years * i) / 100; pts.push(`${X(y).toFixed(1)},${Y(100 / Math.pow(1 + r, y)).toFixed(1)}`); }
      lines += polyline(pts.join(" "), { stroke: c, width: 4 });
      const end = 100 / Math.pow(1 + r, years);
      labels += text(X(years) + 10, Y(end) + 5, `${Math.round(end)}`, { size: 15, color: c, weight: "bold", anchor: "start" });
    }
    let grid = "";
    for (let v = 0; v <= 100; v += 25) grid += line(px, Y(v), px + pw, Y(v), { color: C.grid, width: 1.5 }) + text(px - 10, Y(v) + 5, `${v}`, { size: 13, color: C.muted, anchor: "end" });
    for (let y = 0; y <= years; y += 2) grid += text(X(y), py + ph + 22, `${y}`, { size: 13, color: C.muted });
    return svg([
      title("What 100 buys after years of inflation"),
      grid,
      line(px, py + ph, px + pw, py + ph, { width: 2.5 }), line(px, py - 8, px, py + ph, { width: 2.5 }),
      lines, labels,
      text(px + pw / 2, py + ph + 44, "years", { size: 14, color: C.muted }),
      rect(630, 110, 150, 150, { fill: "#F8FAFC", stroke: C.grid }),
      ...rates.map(([, c, name], i) => line(648, 142 + i * 36, 676, 142 + i * 36, { color: c, width: 4 }) + text(684, 147 + i * 36, name, { size: 14, color: C.ink, anchor: "start" })),
      text(705, 300, "Zimbabwe 2008:", { size: 14, color: C.red, weight: "bold" }), text(705, 320, "prices doubled", { size: 14, color: C.red }), text(705, 340, "about every day", { size: 14, color: C.red }),
    ].join("\n"));
  })(),

  circular_flow: svg([
    title("The circular flow of the economy"),
    box(40, 180, 190, 90, "Households", { fill: C.blueLight, stroke: C.blue, size: 20, sub: "people" }),
    box(570, 180, 190, 90, "Firms", { fill: C.orangeLight, stroke: C.orange, size: 20, sub: "businesses" }),
    path("M135,176 C135,80 665,80 665,176", { stroke: C.green, width: 4 }), polygon([[665, 178], [657, 162], [673, 162]], { fill: C.green }),
    text(400, 92, "spending on goods and services (money)", { size: 15, color: C.green, weight: "bold" }),
    path("M640,176 C640,118 160,118 160,176", { stroke: C.purple, width: 3, dash: "8 6" }), polygon([[160, 178], [152, 162], [168, 162]], { fill: C.purple }),
    text(400, 158, "goods and services", { size: 14, color: C.purple }),
    path("M665,274 C665,370 135,370 135,274", { stroke: C.green, width: 4 }), polygon([[135, 272], [127, 288], [143, 288]], { fill: C.green }),
    text(400, 372, "wages, rent, profits (money)", { size: 15, color: C.green, weight: "bold" }),
    path("M160,274 C160,330 640,330 640,274", { stroke: C.purple, width: 3, dash: "8 6" }), polygon([[640, 272], [632, 288], [648, 288]], { fill: C.purple }),
    text(400, 300, "labour, land, capital", { size: 14, color: C.purple }),
    box(300, 195, 200, 60, "Government, banks, trade", { fill: C.yellowLight, stroke: C.yellow, size: 14, sub: "taxes, loans, exports" }),
    text(400, 425, "GDP = C + I + G + (X − M): one economy's spending, measured once.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
