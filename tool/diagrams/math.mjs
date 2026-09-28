import { C, svg, text, title, line, rect, circle, path, polygon, arrow, plot, polyline, dot } from "./kit.mjs";

/** Axes for a plot area with tick labels. */
function axes(px, py, pw, ph, { x0, x1, ymin, ymax, xTicks = [], yTicks = [], xLabel = "x", yLabel = "y" }) {
  const sx = (x) => px + ((x - x0) / (x1 - x0)) * pw;
  const sy = (y) => py + ph - ((y - ymin) / (ymax - ymin)) * ph;
  let out = "";
  for (const t of xTicks) out += line(sx(t), py, sx(t), py + ph, { color: C.grid, width: 1.5 }) + text(sx(t), sy(0) + 22, String(t), { size: 14, color: C.muted });
  for (const t of yTicks) out += line(px, sy(t), px + pw, sy(t), { color: C.grid, width: 1.5 }) + text(sx(0) - 10, sy(t) + 5, String(t), { size: 14, color: C.muted, anchor: "end" });
  out += arrow(px, sy(0), px + pw + 14, sy(0), { color: C.line, width: 2.5 }) + arrow(sx(0), py + ph, sx(0), py - 14, { color: C.line, width: 2.5 });
  out += text(px + pw + 18, sy(0) + 6, xLabel, { size: 17, color: C.ink, weight: "bold", anchor: "start" });
  out += text(sx(0) + 10, py - 14, yLabel, { size: 17, color: C.ink, weight: "bold", anchor: "start" });
  return { out, sx, sy };
}

export default {
  quadratic_roots: (() => {
    const A = axes(60, 80, 400, 330, { x0: -1, x1: 6, ymin: -2, ymax: 12, xTicks: [1, 2, 3, 4, 5], yTicks: [2, 4, 6, 8, 10] });
    const f = (x) => x * x - 5 * x + 6;
    return svg([
      title("A parabola and its roots"),
      A.out,
      polyline(plot(f, { x0: -0.6, x1: 5.6, px: A.sx(-0.6), py: 0, pw: A.sx(5.6) - A.sx(-0.6), ph: 0, ymin: 0, ymax: 1 }).split(" ").map((p, i) => {
        const x = -0.6 + (6.2 * i) / 160;
        return `${A.sx(x).toFixed(1)},${A.sy(f(x)).toFixed(1)}`;
      }).join(" "), { stroke: C.blue, width: 4 }),
      dot(A.sx(2), A.sy(0), 8, C.red), dot(A.sx(3), A.sy(0), 8, C.red), dot(A.sx(2.5), A.sy(-0.25), 7, C.green),
      text(A.sx(2) - 6, A.sy(0) + 40, "x = 2", { size: 16, color: C.red, weight: "bold", anchor: "end" }),
      text(A.sx(3) + 6, A.sy(0) + 40, "x = 3", { size: 16, color: C.red, weight: "bold", anchor: "start" }),
      text(A.sx(2.5), A.sy(-0.25) + 58, "vertex", { size: 14, color: C.green, weight: "bold" }),
      rect(500, 110, 270, 250, { fill: "#F8FAFC", stroke: C.grid }),
      text(635, 150, "y = x² − 5x + 6", { size: 22, color: C.blue, weight: "bold" }),
      text(635, 190, "= (x − 2)(x − 3)", { size: 20, color: C.ink }),
      text(635, 235, "Roots: where y = 0", { size: 17, color: C.red, weight: "bold" }),
      text(635, 280, "Quadratic formula:", { size: 16, color: C.muted }),
      text(635, 312, "x = (−b ± √(b² − 4ac)) ÷ 2a", { size: 17, color: C.ink, weight: "bold" }),
      text(635, 342, "b² − 4ac = 25 − 24 = 1 > 0", { size: 15, color: C.muted }),
    ].join("\n"));
  })(),

  derivative_tangent: (() => {
    const A = axes(60, 80, 420, 320, { x0: 0, x1: 4, ymin: 0, ymax: 10, xTicks: [1, 2, 3], yTicks: [2, 4, 6, 8], yLabel: "y = x²/2 + 1" });
    const f = (x) => (x * x) / 2 + 1;
    const pts = [];
    for (let i = 0; i <= 120; i++) { const x = 0.1 + (3.9 * i) / 120; pts.push(`${A.sx(x).toFixed(1)},${A.sy(f(x)).toFixed(1)}`); }
    // tangent at x=2: slope 2, y = 3 + 2(x-2)
    const tan = (x) => 3 + 2 * (x - 2);
    // secant from x=2 to x=3.2
    const sec = (x) => 3 + ((f(3.2) - 3) / 1.2) * (x - 2);
    return svg([
      title("The derivative is the slope of the tangent"),
      A.out,
      polyline(pts.join(" "), { stroke: C.blue, width: 4 }),
      line(A.sx(0.6), A.sy(tan(0.6)), A.sx(3.6), A.sy(tan(3.6)), { color: C.orange, width: 3.5 }),
      line(A.sx(1.2), A.sy(sec(1.2)), A.sx(3.6), A.sy(sec(3.6)), { color: C.purple, width: 2.5, dash: "8 6" }),
      dot(A.sx(2), A.sy(3), 8, C.red), dot(A.sx(3.2), A.sy(f(3.2)), 6, C.purple),
      text(A.sx(2) + 12, A.sy(3) + 26, "(2, 3)", { size: 15, color: C.red, weight: "bold", anchor: "start" }),
      rect(520, 110, 250, 250, { fill: "#F8FAFC", stroke: C.grid }),
      text(645, 150, "f(x) = x²/2 + 1", { size: 19, color: C.blue, weight: "bold" }),
      text(645, 186, "f′(x) = x", { size: 19, color: C.ink, weight: "bold" }),
      text(645, 226, "tangent at x = 2:", { size: 16, color: C.orange, weight: "bold" }),
      text(645, 250, "slope = f′(2) = 2", { size: 16, color: C.orange }),
      text(645, 290, "secant (dashed):", { size: 16, color: C.purple, weight: "bold" }),
      text(645, 314, "an average slope; shrink", { size: 15, color: C.purple }),
      text(645, 336, "the gap to get the tangent", { size: 15, color: C.purple }),
    ].join("\n"));
  })(),

  integral_area: (() => {
    const A = axes(60, 80, 420, 320, { x0: 0, x1: 4, ymin: 0, ymax: 10, xTicks: [1, 2, 3], yTicks: [2, 4, 6, 8] });
    const f = (x) => x * x / 2 + 1;
    let bars = "";
    const n = 8, a = 0, b = 3, w = (b - a) / n;
    for (let i = 0; i < n; i++) {
      const x = a + i * w, h = f(x + w / 2);
      bars += rect(A.sx(x), A.sy(h), A.sx(x + w) - A.sx(x), A.sy(0) - A.sy(h), { fill: C.greenLight, stroke: C.green, width: 1.5, rx: 0 });
    }
    const pts = [];
    for (let i = 0; i <= 120; i++) { const x = (4 * i) / 120; pts.push(`${A.sx(x).toFixed(1)},${A.sy(f(x)).toFixed(1)}`); }
    return svg([
      title("An integral adds up thin strips: the area"),
      bars,
      A.out,
      polyline(pts.join(" "), { stroke: C.blue, width: 4 }),
      text(A.sx(1.5), A.sy(1.2), "area", { size: 20, color: C.green, weight: "bold" }),
      rect(520, 110, 250, 250, { fill: "#F8FAFC", stroke: C.grid }),
      text(645, 150, "∫₀³ (x²/2 + 1) dx", { size: 20, color: C.ink, weight: "bold" }),
      text(645, 192, "= [x³/6 + x]₀³", { size: 18, color: C.ink }),
      text(645, 228, "= 27/6 + 3 = 7.5", { size: 18, color: C.green, weight: "bold" }),
      text(645, 272, "8 strips give ≈ 7.48", { size: 15, color: C.muted }),
      text(645, 296, "more strips → exact area", { size: 15, color: C.muted }),
      text(645, 330, "F(b) − F(a)", { size: 17, color: C.blue, weight: "bold" }),
    ].join("\n"));
  })(),

  matrix_rotation: (() => {
    const cx = 230, cy = 250, s = 55;
    const P = (x, y) => [cx + x * s, cy - y * s];
    let grid = "";
    for (let i = -3; i <= 3; i++) grid += line(...P(i, -3), ...P(i, 3), { color: C.grid, width: 1.5 }) + line(...P(-3, i), ...P(3, i), { color: C.grid, width: 1.5 });
    const v = [3, 1];
    const th = Math.PI / 2;
    const r = [v[0] * Math.cos(th) - v[1] * Math.sin(th), v[0] * Math.sin(th) + v[1] * Math.cos(th)];
    return svg([
      title("A matrix transforms vectors: rotation by 90°"),
      grid,
      arrow(...P(-3.2, 0), ...P(3.3, 0), { color: C.line, width: 2 }), arrow(...P(0, -3.2), ...P(0, 3.3), { color: C.line, width: 2 }),
      arrow(...P(0, 0), ...P(v[0], v[1]), { color: C.blue, width: 5, head: 16 }),
      arrow(...P(0, 0), ...P(r[0], r[1]), { color: C.orange, width: 5, head: 16 }),
      text(...P(v[0] + 0.1, v[1] + 0.3), "v = (3, 1)", { size: 17, color: C.blue, weight: "bold" }),
      text(...P(r[0] - 0.1, r[1] + 0.35), "Rv = (−1, 3)", { size: 17, color: C.orange, weight: "bold" }),
      path(`M${P(1.2, 0.4).join(",")} A1,1 0 0,0 ${P(-0.4, 1.2).join(",")}`, { stroke: C.muted, width: 2, dash: "5 5" }),
      rect(470, 90, 310, 300, { fill: "#F8FAFC", stroke: C.grid }),
      text(625, 128, "R = [ 0  −1 ]", { size: 22, color: C.ink, weight: "bold" }),
      text(625, 158, "      [ 1   0 ]", { size: 22, color: C.ink, weight: "bold" }),
      text(625, 205, "Rv = (0·3 + (−1)·1, 1·3 + 0·1)", { size: 16, color: C.muted }),
      text(625, 232, "= (−1, 3)", { size: 18, color: C.orange, weight: "bold" }),
      text(625, 280, "det R = 0·0 − (−1)·1 = 1", { size: 17, color: C.ink }),
      text(625, 306, "area is preserved", { size: 15, color: C.muted }),
      text(625, 350, "rows × columns, order matters", { size: 15, color: C.purple, weight: "bold" }),
    ].join("\n"));
  })(),

  normal_curve: (() => {
    const px = 60, pw = 680, py = 90, ph = 270;
    const f = (z) => Math.exp(-z * z / 2);
    const sx = (z) => px + ((z + 3.5) / 7) * pw;
    const sy = (y) => py + ph - y * ph * 0.95;
    const band = (a, b, fill) => {
      const pts = [`${sx(a).toFixed(1)},${sy(0).toFixed(1)}`];
      for (let i = 0; i <= 60; i++) { const z = a + ((b - a) * i) / 60; pts.push(`${sx(z).toFixed(1)},${sy(f(z)).toFixed(1)}`); }
      pts.push(`${sx(b).toFixed(1)},${sy(0).toFixed(1)}`);
      return `<polygon points="${pts.join(" ")}" fill="${fill}"/>`;
    };
    const curve = [];
    for (let i = 0; i <= 200; i++) { const z = -3.5 + (7 * i) / 200; curve.push(`${sx(z).toFixed(1)},${sy(f(z)).toFixed(1)}`); }
    let ticks = "";
    for (const z of [-3, -2, -1, 0, 1, 2, 3]) ticks += line(sx(z), sy(0), sx(z), sy(0) + 8, { width: 2 }) + text(sx(z), sy(0) + 28, z === 0 ? "μ" : `${z > 0 ? "+" : "−"}${Math.abs(z)}σ`, { size: 16, color: C.ink, weight: "bold" });
    return svg([
      title("The normal distribution: 68–95–99.7"),
      band(-3, 3, C.yellowLight), band(-2, 2, C.greenLight), band(-1, 1, C.blueLight),
      polyline(curve.join(" "), { stroke: C.blue, width: 4 }),
      line(sx(-3.5), sy(0), sx(3.5), sy(0), { width: 2.5 }), ticks,
      text(sx(0), sy(0.45), "68%", { size: 24, color: C.blue, weight: "bold" }),
      text(sx(1.55), sy(0.2), "95%", { size: 19, color: C.green, weight: "bold" }),
      text(sx(-1.55), sy(0.2), "95%", { size: 19, color: C.green, weight: "bold" }),
      text(sx(2.6), sy(0.1), "99.7%", { size: 16, color: C.yellow, weight: "bold" }),
      text(sx(-2.6), sy(0.1), "99.7%", { size: 16, color: C.yellow, weight: "bold" }),
      text(400, 438, "Resistors of 100 Ω with σ = 1 Ω: 95% measure between 98 and 102 Ω", { size: 15, color: C.muted, italic: true }),
    ].join("\n"));
  })(),

  complex_plane: (() => {
    const cx = 250, cy = 260, s = 36;
    const P = (x, y) => [cx + x * s, cy - y * s];
    let grid = "";
    for (let i = -4; i <= 5; i++) grid += line(...P(i, -4.5), ...P(i, 5), { color: C.grid, width: 1.2 });
    for (let i = -4; i <= 5; i++) grid += line(...P(-4.5, i), ...P(5.5, i), { color: C.grid, width: 1.2 });
    const unit = [];
    for (let i = 0; i <= 100; i++) { const a = (2 * Math.PI * i) / 100; unit.push(`${P(Math.cos(a) * 5, Math.sin(a) * 5).map((v) => v.toFixed(1)).join(",")}`); }
    return svg([
      title("The complex plane: 3 + j4 = 5∠53.1°"),
      grid,
      polyline(unit.join(" "), { stroke: C.purple, width: 2, dash: "6 6" }),
      arrow(...P(-4.8, 0), ...P(5.8, 0), { color: C.line, width: 2.5 }), arrow(...P(0, -4.8), ...P(0, 5.4), { color: C.line, width: 2.5 }),
      text(...P(5.6, -0.6), "Re", { size: 17, color: C.ink, weight: "bold" }), text(...P(0.55, 5.2), "Im (j)", { size: 17, color: C.ink, weight: "bold" }),
      line(...P(3, 0), ...P(3, 4), { color: C.green, width: 2.5, dash: "7 5" }),
      arrow(...P(0, 0), ...P(3, 4), { color: C.blue, width: 5, head: 16 }), dot(...P(3, 4), 6, C.blue),
      text(...P(3.3, 4.3), "3 + j4", { size: 18, color: C.blue, weight: "bold" }),
      text(...P(1.2, 2.6), "r = 5", { size: 17, color: C.blue, weight: "bold" }),
      text(...P(3.6, 2), "4", { size: 16, color: C.green, weight: "bold" }), text(...P(1.5, -0.6), "3", { size: 16, color: C.green, weight: "bold" }),
      path(`M${P(1.2, 0).join(",")} A43,43 0 0,0 ${P(0.72, 0.96).join(",")}`, { stroke: C.orange, width: 3 }),
      text(...P(1.6, 0.55), "θ", { size: 18, color: C.orange, weight: "bold" }),
      rect(500, 90, 280, 300, { fill: "#F8FAFC", stroke: C.grid }),
      text(640, 130, "r = √(3² + 4²) = 5", { size: 18, color: C.ink, weight: "bold" }),
      text(640, 164, "θ = arctan(4/3) ≈ 53.1°", { size: 17, color: C.ink }),
      text(640, 212, "e^(jθ) = cos θ + j sin θ", { size: 17, color: C.purple, weight: "bold" }),
      text(640, 240, "dashed circle: |z| = 5", { size: 14, color: C.purple }),
      text(640, 288, "Multiply: × lengths,", { size: 16, color: C.muted }),
      text(640, 312, "+ angles", { size: 16, color: C.muted }),
      text(640, 356, "Z_L = jωL · Z_C = 1/(jωC)", { size: 16, color: C.orange, weight: "bold" }),
    ].join("\n"));
  })(),
};
