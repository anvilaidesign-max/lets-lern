import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box } from "./kit.mjs";

export default {
  separation_powers: svg([
    title("Separation of powers: checks and balances"),
    box(290, 62, 220, 84, "Legislature", { fill: C.blueLight, stroke: C.blue, size: 20, sub: "Parliament makes laws" }),
    box(40, 300, 230, 84, "Executive", { fill: C.orangeLight, stroke: C.orange, size: 20, sub: "President and Cabinet" }),
    box(530, 300, 230, 84, "Judiciary", { fill: C.purpleLight, stroke: C.purple, size: 20, sub: "courts interpret laws" }),
    arrow(300, 150, 200, 292, { color: C.blue, width: 3 }), text(170, 205, "passes budget,", { size: 14, color: C.blue, anchor: "end" }), text(170, 223, "can impeach", { size: 14, color: C.blue, anchor: "end" }),
    arrow(230, 296, 330, 154, { color: C.orange, width: 3 }), text(302, 250, "signs or", { size: 14, color: C.orange, anchor: "start" }), text(302, 268, "vetoes bills", { size: 14, color: C.orange, anchor: "start" }),
    arrow(530, 322, 274, 322, { color: C.purple, width: 3 }), text(400, 312, "rules actions unlawful", { size: 14, color: C.purple }),
    arrow(274, 362, 530, 362, { color: C.orange, width: 3 }), text(400, 382, "appoints judges", { size: 14, color: C.orange }),
    arrow(580, 296, 490, 154, { color: C.purple, width: 3 }), text(598, 205, "strikes down", { size: 14, color: C.purple, anchor: "start" }), text(598, 223, "unconstitutional laws", { size: 14, color: C.purple, anchor: "start" }),
    text(400, 430, "No branch holds all the power; each can limit the others.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),

  electoral_systems: (() => {
    const parties = [["Party A", 40, 62, C.blue], ["Party B", 35, 36, C.orange], ["Party C", 25, 2, C.green]];
    const sections = [["Votes won", 1, 78], ["Seats: first-past-the-post", 2, 196], ["Seats: proportional representation", 1, 314]];
    let out = "";
    for (const [label, col, y0] of sections) {
      out += text(60, y0, label, { size: 17, color: C.ink, weight: "bold", anchor: "start" });
      parties.forEach((p, i) => {
        const pct = p[col], c = p[3], y = y0 + 12 + i * 30;
        out += text(150, y + 17, p[0], { size: 14, color: C.muted, anchor: "end" });
        out += rect(160, y, Math.max(pct, 1) * 4.6, 22, { fill: c, stroke: c, rx: 6 });
        out += text(170 + Math.max(pct, 1) * 4.6, y + 17, `${pct}%`, { size: 14, color: C.ink, weight: "bold", anchor: "start" });
      });
    }
    out += text(400, 432, "Same votes, very different parliaments (illustrative example).", { size: 15, color: C.muted, italic: true });
    return svg([title("How the voting system shapes parliament"), out].join("\n"));
  })(),
  zim_timeline: (() => {
    const events = [
      ["1100s–1400s", "Great Zimbabwe", C.orange],
      ["1890", "Colonial rule", C.muted],
      ["1896–97", "First Chimurenga", C.red],
      ["1965", "Smith's UDI", C.muted],
      ["1966–79", "Liberation war", C.red],
      ["1980", "Independence", C.green],
      ["2008", "Hyperinflation", C.orange],
      ["2013", "New constitution", C.blue],
      ["2017", "Mugabe resigns", C.purple],
    ];
    const x0 = 80, x1 = 720, y = 240;
    let out = line(x0, y, x1, y, { color: C.line, width: 5 });
    events.forEach(([year, label, c], i) => {
      const x = x0 + (i * (x1 - x0)) / (events.length - 1);
      const up = i % 2 === 0;
      out += circle(x, y, 11, { fill: c, stroke: "#FFFFFF", width: 3 });
      out += line(x, up ? y - 14 : y + 14, x, up ? y - 62 : y + 62, { color: c, width: 2.5 });
      out += text(x, up ? y - 92 : y + 88, year, { size: 15, color: c, weight: "bold" });
      out += text(x, up ? y - 72 : y + 108, label, { size: 14, color: C.ink, weight: "bold" });
    });
    return svg([
      title("Zimbabwe: key moments"),
      out,
      text(400, 420, "18 April 1980: Southern Rhodesia becomes independent Zimbabwe.", { size: 15, color: C.muted, italic: true }),
    ].join("\n"));
  })(),
};
