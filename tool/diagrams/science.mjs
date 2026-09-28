import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, plot, polyline, dot } from "./kit.mjs";

export default {
  forces_car: svg([
    title("Forces on a moving car: F = m × a"),
    line(40, 330, 760, 330, { color: C.muted, width: 3 }),
    // car body
    path("M200,300 L200,250 Q205,235 225,232 L300,230 L340,190 Q350,182 365,182 L470,182 Q488,182 500,195 L540,232 L590,236 Q610,240 612,258 L612,300 Z", { fill: C.blueLight, stroke: C.blue, width: 3 }),
    path("M355,196 L470,196 Q480,196 488,205 L515,232 L335,232 Z", { fill: "#FFFFFF", stroke: C.blue, width: 2.5 }),
    circle(270, 305, 26, { fill: C.ink, stroke: C.ink }), circle(270, 305, 10, { fill: C.grid, stroke: C.grid }),
    circle(540, 305, 26, { fill: C.ink, stroke: C.ink }), circle(540, 305, 10, { fill: C.grid, stroke: C.grid }),
    // forces
    arrow(612, 262, 740, 262, { color: C.green, width: 6, head: 18 }), text(680, 250, "driving force", { size: 16, color: C.green, weight: "bold" }),
    arrow(200, 262, 90, 262, { color: C.red, width: 6, head: 18 }), text(145, 250, "friction + drag", { size: 16, color: C.red, weight: "bold" }),
    arrow(405, 250, 405, 405, { color: C.purple, width: 6, head: 18 }), text(418, 398, "weight = m × g", { size: 16, color: C.purple, weight: "bold", anchor: "start" }),
    arrow(330, 330, 330, 160, { color: C.orange, width: 5, head: 16 }), text(318, 178, "reaction", { size: 16, color: C.orange, weight: "bold", anchor: "end" }),
    rect(40, 70, 260, 72, { fill: "#F8FAFC", stroke: C.grid }),
    text(170, 100, "Net force = 3600 N", { size: 17, color: C.ink, weight: "bold" }),
    text(170, 126, "1200 kg car → a = 3 m/s²", { size: 15, color: C.muted }),
    rect(520, 70, 250, 72, { fill: "#F8FAFC", stroke: C.grid }),
    text(645, 100, "Kinetic energy = ½mv²", { size: 17, color: C.ink, weight: "bold" }),
    text(645, 126, "double the speed → 4× energy", { size: 15, color: C.red }),
  ].join("\n")),

  em_spectrum: (() => {
    const bands = [
      ["Radio", C.blueLight, C.blue, "FM, Wi-Fi, 4G"],
      ["Micro-wave", C.tealLight, C.teal, "radar, ovens"],
      ["Infra-red", C.redLight, C.red, "heat, remotes"],
      ["Visible", "#FFFFFF", C.ink, "400–700 nm"],
      ["Ultra-violet", C.purpleLight, C.purple, "sunburn"],
      ["X-rays", C.grid, C.muted, "medical images"],
      ["Gamma", C.yellowLight, C.yellow, "nuclear decay"],
    ];
    const x0 = 40, w = 102, y = 130;
    let out = "";
    bands.forEach(([name, fill, stroke, use], i) => {
      const x = x0 + i * w;
      out += rect(x, y, w - 6, 90, { fill, stroke, rx: 10 });
      out += text(x + (w - 6) / 2, y + 42, name.split("-")[0] + (name.includes("-") ? "-" : ""), { size: 15, color: C.ink, weight: "bold" });
      if (name.includes("-")) out += text(x + (w - 6) / 2, y + 62, name.split("-")[1], { size: 15, color: C.ink, weight: "bold" });
      out += text(x + (w - 6) / 2, y + 118, use, { size: 13, color: C.muted });
    });
    // rainbow in the visible band
    const vx = x0 + 3 * w;
    const rainbow = ["#EF4444", "#F97316", "#EAB308", "#22C55E", "#3B82F6", "#6366F1", "#8B5CF6"];
    rainbow.forEach((c, i) => { out += `<rect x="${vx + 6 + i * 12.5}" y="${y + 70}" width="12.5" height="12" fill="${c}"/>`; });
    // wave getting shorter
    out += polyline(plot((x) => Math.sin(x * x * 0.9), { x0: 0.6, x1: 9, px: 40, py: 280, pw: 710, ph: 60, ymin: -1, ymax: 1, steps: 700 }), { stroke: C.blue, width: 2.5 });
    out += arrow(60, 375, 740, 375, { color: C.orange, width: 3 });
    out += text(400, 402, "higher frequency · shorter wavelength · more energy per photon", { size: 16, color: C.orange, weight: "bold" });
    out += text(400, 432, "all travel at c ≈ 3 × 10⁸ m/s:  c = f × λ", { size: 17, color: C.ink, weight: "bold" });
    return svg([title("The electromagnetic spectrum"), out].join("\n"));
  })(),

  photoelectric: svg([
    title("The photoelectric effect: light comes in photons"),
    rect(300, 300, 200, 60, { fill: C.grid, stroke: C.muted }), text(400, 337, "metal", { size: 18, color: C.ink, weight: "bold" }),
    // red light: no electrons
    path("M110,110 q10,-12 20,0 t20,0 t20,0 t20,0 t20,0 t20,0 t20,0 t20,0", { stroke: C.red, width: 3 }),
    arrow(270, 110, 330, 290, { color: C.red, width: 3 }),
    text(160, 90, "red light (low f)", { size: 16, color: C.red, weight: "bold" }),
    text(150, 170, "no electrons, however bright", { size: 14, color: C.red }),
    // blue light: electrons
    path("M470,110 q6,-12 12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0 t12,0", { stroke: C.blue, width: 3 }),
    arrow(630, 110, 470, 290, { color: C.blue, width: 3 }),
    text(620, 90, "blue / UV light (high f)", { size: 16, color: C.blue, weight: "bold" }),
    circle(560, 250, 9, { fill: C.yellow, stroke: C.orange, width: 2 }), text(560, 255, "e", { size: 11, color: C.ink, weight: "bold" }),
    arrow(470, 300, 545, 258, { color: C.orange, width: 2.5 }),
    circle(610, 205, 9, { fill: C.yellow, stroke: C.orange, width: 2 }), text(610, 210, "e", { size: 11, color: C.ink, weight: "bold" }),
    arrow(490, 300, 596, 214, { color: C.orange, width: 2.5 }),
    text(650, 275, "electrons ejected", { size: 15, color: C.orange, weight: "bold", anchor: "start" }),
    rect(170, 385, 460, 50, { fill: C.yellowLight, stroke: C.yellow }),
    text(400, 417, "Energy of one photon: E = h × f", { size: 19, color: C.ink, weight: "bold" }),
  ].join("\n")),

  dna_helix: (() => {
    let out = "";
    const x0 = 70, x1 = 480, amp = 70, cy = 240;
    const pairs = [["A", "T"], ["G", "C"], ["T", "A"], ["C", "G"], ["A", "T"], ["G", "C"], ["C", "G"], ["T", "A"], ["G", "C"], ["A", "T"]];
    const colors = { A: C.red, T: C.yellow, G: C.green, C: C.blue };
    pairs.forEach(([a, b], i) => {
      const x = x0 + 20 + i * ((x1 - x0 - 40) / (pairs.length - 1));
      const t = ((x - x0) / (x1 - x0)) * 3 * Math.PI;
      const y1 = cy - Math.sin(t) * amp, y2 = cy + Math.sin(t) * amp;
      const m = (y1 + y2) / 2;
      out += line(x, y1, x, m, { color: colors[a], width: 7, cap: "butt" }) + line(x, m, x, y2, { color: colors[b], width: 7, cap: "butt" });
    });
    out += polyline(plot((x) => Math.sin(((x - x0) / (x1 - x0)) * 3 * Math.PI), { x0, x1, px: x0, py: cy - amp, pw: x1 - x0, ph: 2 * amp, ymin: -1, ymax: 1 }), { stroke: C.purple, width: 6 });
    out += polyline(plot((x) => -Math.sin(((x - x0) / (x1 - x0)) * 3 * Math.PI), { x0, x1, px: x0, py: cy - amp, pw: x1 - x0, ph: 2 * amp, ymin: -1, ymax: 1 }), { stroke: C.teal, width: 6 });
    out += rect(520, 90, 250, 150, { fill: "#F8FAFC", stroke: C.grid });
    out += text(645, 120, "Base pairs", { size: 18, color: C.ink, weight: "bold" });
    out += rect(545, 138, 24, 16, { fill: C.red, stroke: C.red, rx: 3 }) + text(578, 152, "A — T", { size: 17, color: C.ink, weight: "bold", anchor: "start" }) + rect(650, 138, 24, 16, { fill: C.yellow, stroke: C.yellow, rx: 3 });
    out += rect(545, 175, 24, 16, { fill: C.green, stroke: C.green, rx: 3 }) + text(578, 189, "G — C", { size: 17, color: C.ink, weight: "bold", anchor: "start" }) + rect(650, 175, 24, 16, { fill: C.blue, stroke: C.blue, rx: 3 });
    out += text(645, 224, "A pairs with T, G with C", { size: 14, color: C.muted });
    out += box(520, 270, 70, 50, "DNA", { fill: C.purpleLight, stroke: C.purple, size: 16 });
    out += arrow(592, 295, 612, 295, { width: 2.5 });
    out += box(614, 270, 70, 50, "RNA", { fill: C.orangeLight, stroke: C.orange, size: 16 });
    out += arrow(686, 295, 704, 295, { width: 2.5 });
    out += box(706, 270, 74, 50, "Protein", { fill: C.greenLight, stroke: C.green, size: 14 });
    out += text(650, 350, "transcription → translation", { size: 14, color: C.muted });
    out += text(270, 380, "the double helix (Watson, Crick, Franklin, 1953)", { size: 15, color: C.muted, italic: true });
    return svg([title("DNA: the code of life"), out].join("\n"));
  })(),
};
