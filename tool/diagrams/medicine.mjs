import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, plot, polyline, dot } from "./kit.mjs";

export default {
  heart_circulation: svg([
    title("The heart: two pumps, two circuits"),
    // lungs (top) and body (bottom)
    box(300, 60, 200, 55, "Lungs", { fill: C.pinkLight, stroke: C.pink, size: 18, sub: "pick up O₂, drop CO₂" }),
    box(300, 370, 200, 55, "Body", { fill: C.orangeLight, stroke: C.orange, size: 18, sub: "cells use O₂" }),
    // heart chambers
    rect(280, 160, 115, 80, { fill: "#DBEAFE", stroke: C.blue }), text(337, 195, "Right", { size: 15, color: C.blue, weight: "bold" }), text(337, 215, "atrium", { size: 14, color: C.blue }),
    rect(280, 245, 115, 90, { fill: "#BFDBFE", stroke: C.blue }), text(337, 285, "Right", { size: 15, color: C.blue, weight: "bold" }), text(337, 305, "ventricle", { size: 14, color: C.blue }),
    rect(405, 160, 115, 80, { fill: "#FEE2E2", stroke: C.red }), text(462, 195, "Left", { size: 15, color: C.red, weight: "bold" }), text(462, 215, "atrium", { size: 14, color: C.red }),
    rect(405, 245, 115, 90, { fill: "#FECACA", stroke: C.red, width: 4 }), text(462, 285, "Left", { size: 15, color: C.red, weight: "bold" }), text(462, 305, "ventricle", { size: 14, color: C.red }),
    // circulation paths
    path("M280,300 C200,300 200,90 298,90", { stroke: C.blue, width: 5 }), polygon([[298, 90], [284, 82], [284, 98]], { fill: C.blue }),
    text(185, 190, "to lungs", { size: 15, color: C.blue, weight: "bold", anchor: "end" }),
    path("M502,90 C600,90 600,200 522,200", { stroke: C.red, width: 5 }), polygon([[522, 200], [536, 192], [536, 208]], { fill: C.red }),
    text(610, 150, "back, full of O₂", { size: 15, color: C.red, weight: "bold", anchor: "start" }),
    path("M520,300 C640,300 640,398 502,398", { stroke: C.red, width: 5 }), polygon([[502, 398], [516, 390], [516, 406]], { fill: C.red }),
    text(650, 350, "to the body", { size: 15, color: C.red, weight: "bold", anchor: "start" }),
    path("M298,398 C150,398 150,200 278,200", { stroke: C.blue, width: 5 }), polygon([[278, 200], [264, 192], [264, 208]], { fill: C.blue }),
    text(150, 330, "back, low in O₂", { size: 15, color: C.blue, weight: "bold", anchor: "end" }),
    text(400, 150, "SA node sets the beat", { size: 13, color: C.muted, italic: true }),
  ].join("\n")),

  immune_memory: (() => {
    const px = 70, py = 90, pw = 460, ph = 260;
    const pts = [];
    for (let i = 0; i <= 300; i++) { const t = (100 * i) / 300; const s = (v) => 1 / (1 + Math.exp(-v)); const y = 0.18 * Math.exp(-Math.pow(t - 14, 2) / 40) + 0.04 * s(t - 18) + 1.0 * Math.exp(-Math.pow(t - 72, 2) / 110) * s((t - 61) * 1.2); pts.push(`${(px + (t / 100) * pw).toFixed(1)},${(py + ph - y * ph * 0.85).toFixed(1)}`); }
    return svg([
      title("How a vaccine trains immune memory"),
      arrow(px, py + ph, px + pw + 14, py + ph, { width: 2.5 }), arrow(px, py + ph, px, py - 10, { width: 2.5 }),
      text(px + pw + 10, py + ph + 26, "time", { size: 15, color: C.muted }),
      text(px + 8, py - 12, "antibodies", { size: 15, color: C.muted, anchor: "start" }),
      polyline(pts.join(" "), { stroke: C.blue, width: 4 }),
      arrow(px + 10, py + ph + 42, px + 10, py + ph + 6, { color: C.green, width: 3 }), text(px + 18, py + ph + 44, "vaccine", { size: 14, color: C.green, weight: "bold", anchor: "start" }),
      arrow(px + 0.6 * pw, py + ph + 42, px + 0.6 * pw, py + ph + 6, { color: C.red, width: 3 }), text(px + 0.6 * pw + 8, py + ph + 44, "real germ", { size: 14, color: C.red, weight: "bold", anchor: "start" }),
      text(px + 0.14 * pw, py + ph - 70, "slow, small", { size: 14, color: C.blue }),
      text(px + 0.72 * pw + 26, py + 50, "fast + strong", { size: 15, color: C.blue, weight: "bold", anchor: "start" }), text(px + 0.72 * pw + 26, py + 70, "= memory!", { size: 15, color: C.blue, weight: "bold", anchor: "start" }),
      rect(560, 100, 210, 250, { fill: "#F8FAFC", stroke: C.grid }),
      text(665, 132, "Your defenders", { size: 17, color: C.ink, weight: "bold" }),
      text(665, 170, "B cells → antibodies", { size: 15, color: C.blue, weight: "bold" }),
      text(665, 205, "T cells → kill infected", { size: 15, color: C.purple, weight: "bold" }),
      text(665, 225, "cells", { size: 15, color: C.purple, weight: "bold" }),
      text(665, 262, "Memory cells → quick", { size: 15, color: C.green, weight: "bold" }),
      text(665, 282, "response next time", { size: 15, color: C.green, weight: "bold" }),
      text(665, 322, "HIV attacks CD4 T cells", { size: 13, color: C.red }),
    ].join("\n"));
  })(),

  drug_half_life: (() => {
    const px = 70, py = 80, pw = 480, ph = 280;
    const pts = [];
    for (let i = 0; i <= 200; i++) { const t = (24 * i) / 200; pts.push(`${(px + (t / 24) * pw).toFixed(1)},${(py + ph - Math.pow(0.5, t / 4) * ph).toFixed(1)}`); }
    let marks = "";
    [[4, 50], [8, 25], [12, 12.5], [16, 6.25]].forEach(([t, v]) => {
      const x = px + (t / 24) * pw, y = py + ph - (v / 100) * ph;
      marks += line(x, y, x, py + ph, { color: C.grid, width: 2, dash: "5 4" }) + dot(x, y, 6, C.orange) + text(x + 8, y - 8, `${v} mg`, { size: 14, color: C.orange, weight: "bold", anchor: "start" });
      marks += text(x, py + ph + 22, `${t} h`, { size: 14, color: C.muted });
    });
    return svg([
      title("Half-life: the level halves every 4 hours"),
      arrow(px, py + ph, px + pw + 14, py + ph, { width: 2.5 }), arrow(px, py + ph, px, py - 12, { width: 2.5 }),
      text(px - 8, py + 5, "100 mg", { size: 14, color: C.muted, anchor: "end" }),
      polyline(pts.join(" "), { stroke: C.blue, width: 4 }),
      marks,
      rect(580, 100, 190, 240, { fill: "#F8FAFC", stroke: C.grid }),
      text(675, 135, "After 4–5", { size: 17, color: C.ink, weight: "bold" }), text(675, 158, "half-lives the", { size: 17, color: C.ink, weight: "bold" }), text(675, 181, "drug is mostly gone", { size: 17, color: C.ink, weight: "bold" }),
      text(675, 230, "Regular doses reach", { size: 15, color: C.muted }), text(675, 252, "a steady state in", { size: 15, color: C.muted }), text(675, 274, "about the same time", { size: 15, color: C.muted }),
      text(310, 420, "time since the dose", { size: 15, color: C.muted }),
    ].join("\n"));
  })(),

  first_aid_steps: svg([
    title("First steps in an emergency: DRSABC"),
    ...[["D", "Danger", "make it safe", C.red, C.redLight], ["R", "Response", "talk, tap", C.orange, C.orangeLight], ["S", "Send", "call for help", C.yellow, C.yellowLight], ["A", "Airway", "tilt head, lift chin", C.green, C.greenLight], ["B", "Breathing", "look, listen, feel", C.teal, C.tealLight], ["C", "CPR", "if not breathing", C.blue, C.blueLight]].map(([k, name, what, color, fill], i) => {
      const x = 30 + i * 125;
      return rect(x, 90, 112, 150, { fill, stroke: color }) + circle(x + 56, 132, 26, { fill: color, stroke: color }) + text(x + 56, 142, k, { size: 26, color: "#FFFFFF", weight: "bold" }) +
        text(x + 56, 190, name, { size: 16, color: C.ink, weight: "bold" }) + text(x + 56, 218, what, { size: 12, color: C.muted }) + (i < 5 ? arrow(x + 112, 165, x + 124, 165, { width: 2 }) : "");
    }),
    rect(40, 275, 720, 145, { fill: "#F8FAFC", stroke: C.grid }),
    text(400, 310, "CPR for adults", { size: 20, color: C.ink, weight: "bold" }),
    text(220, 350, "centre of the chest", { size: 16, color: C.blue, weight: "bold" }),
    text(400, 350, "5–6 cm deep", { size: 16, color: C.blue, weight: "bold" }),
    text(580, 350, "100–120 per minute", { size: 16, color: C.blue, weight: "bold" }),
    text(400, 395, "Use an AED as soon as one arrives. Hands-only CPR is far better than nothing.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
