// Small helpers for drawing the book illustrations as SVG.
// All diagrams use an 800 x 450 canvas, a white background and one palette,
// so they look like one set. Rendered in the app with flutter_svg.

export const C = {
  ink: "#0F172A",
  text: "#334155",
  muted: "#64748B",
  line: "#334155",
  grid: "#E2E8F0",
  blue: "#2563EB",
  blueLight: "#DBEAFE",
  orange: "#F97316",
  orangeLight: "#FFEDD5",
  green: "#16A34A",
  greenLight: "#DCFCE7",
  red: "#DC2626",
  redLight: "#FEE2E2",
  purple: "#7C3AED",
  purpleLight: "#EDE9FE",
  yellow: "#EAB308",
  yellowLight: "#FEF9C3",
  teal: "#0D9488",
  tealLight: "#CCFBF1",
  pink: "#DB2777",
  pinkLight: "#FCE7F3",
};

const FONT = "Arial, Helvetica, sans-serif";

export function svg(body, { w = 800, h = 450 } = {}) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}">
<rect x="0" y="0" width="${w}" height="${h}" rx="18" fill="#FFFFFF"/>
${body}
</svg>
`;
}

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

export function text(x, y, s, { size = 18, color = C.text, weight = "normal", anchor = "middle", italic = false } = {}) {
  return `<text x="${x}" y="${y}" font-family="${FONT}" font-size="${size}" font-weight="${weight}"${italic ? ' font-style="italic"' : ""} fill="${color}" text-anchor="${anchor}">${esc(s)}</text>`;
}

export const title = (s) => text(400, 38, s, { size: 24, color: C.ink, weight: "bold" });

export function line(x1, y1, x2, y2, { color = C.line, width = 3, dash = null, cap = "round" } = {}) {
  return `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-width="${width}" stroke-linecap="${cap}"${dash ? ` stroke-dasharray="${dash}"` : ""}/>`;
}

export function rect(x, y, w, h, { fill = C.blueLight, stroke = C.blue, width = 2.5, rx = 12 } = {}) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}" fill="${fill}" stroke="${stroke}" stroke-width="${width}"/>`;
}

export function circle(cx, cy, r, { fill = "#FFFFFF", stroke = C.line, width = 3 } = {}) {
  return `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${width}"/>`;
}

export function path(d, { stroke = C.line, width = 3, fill = "none", dash = null } = {}) {
  return `<path d="${d}" stroke="${stroke}" stroke-width="${width}" fill="${fill}" stroke-linejoin="round" stroke-linecap="round"${dash ? ` stroke-dasharray="${dash}"` : ""}/>`;
}

export function polygon(points, { fill = C.line, stroke = "none", width = 0 } = {}) {
  return `<polygon points="${points.map((p) => p.join(",")).join(" ")}" fill="${fill}" stroke="${stroke}" stroke-width="${width}"/>`;
}

/** Straight arrow with a filled head (no SVG markers; flutter_svg-safe). */
export function arrow(x1, y1, x2, y2, { color = C.line, width = 3, head = 12, dash = null } = {}) {
  const a = Math.atan2(y2 - y1, x2 - x1);
  const bx = x2 - Math.cos(a) * head, by = y2 - Math.sin(a) * head;
  const left = [bx + Math.cos(a + Math.PI / 2) * head * 0.55, by + Math.sin(a + Math.PI / 2) * head * 0.55];
  const right = [bx + Math.cos(a - Math.PI / 2) * head * 0.55, by + Math.sin(a - Math.PI / 2) * head * 0.55];
  return line(x1, y1, bx, by, { color, width, dash }) + polygon([[x2, y2], left, right].map(([x, y]) => [+x.toFixed(1), +y.toFixed(1)]), { fill: color });
}

/** Box with centred multi-line label. */
export function box(x, y, w, h, label, { fill = C.blueLight, stroke = C.blue, color = C.ink, size = 17, weight = "bold", sub = null, subColor = C.muted } = {}) {
  const lines = Array.isArray(label) ? label : [label];
  const total = lines.length * (size + 4) + (sub ? size : 0);
  let y0 = y + h / 2 - total / 2 + size;
  let out = rect(x, y, w, h, { fill, stroke });
  for (const l of lines) {
    out += text(x + w / 2, y0, l, { size, color, weight });
    y0 += size + 4;
  }
  if (sub) out += text(x + w / 2, y0 + 2, sub, { size: size - 3, color: subColor });
  return out;
}

/** Polyline through a function y = f(x) mapped into a plot area. */
export function plot(f, { x0, x1, px, py, pw, ph, ymin, ymax, steps = 160 }) {
  const pts = [];
  for (let i = 0; i <= steps; i++) {
    const x = x0 + ((x1 - x0) * i) / steps;
    const y = f(x);
    const sx = px + ((x - x0) / (x1 - x0)) * pw;
    const sy = py + ph - ((y - ymin) / (ymax - ymin)) * ph;
    pts.push(`${sx.toFixed(1)},${sy.toFixed(1)}`);
  }
  return pts.join(" ");
}

export function polyline(points, { stroke = C.blue, width = 4, fill = "none", dash = null } = {}) {
  return `<polyline points="${points}" stroke="${stroke}" stroke-width="${width}" fill="${fill}" stroke-linejoin="round" stroke-linecap="round"${dash ? ` stroke-dasharray="${dash}"` : ""}/>`;
}

/** Resistor zigzag between two points on a horizontal line. */
export function resistorH(x1, x2, y, { color = C.orange, label = null } = {}) {
  const n = 6, w = (x2 - x1) / (n + 1);
  let d = `M${x1},${y} L${x1 + w / 2},${y}`;
  for (let i = 0; i < n; i++) d += ` L${(x1 + w / 2 + w * (i + 0.5)).toFixed(1)},${y + (i % 2 === 0 ? -12 : 12)}`;
  d += ` L${x2 - w / 2},${y} L${x2},${y}`;
  return path(d, { stroke: color, width: 3.5 }) + (label ? text((x1 + x2) / 2, y - 22, label, { size: 17, color, weight: "bold" }) : "");
}

/** Resistor zigzag on a vertical line. */
export function resistorV(x, y1, y2, { color = C.orange, label = null, labelSide = 1 } = {}) {
  const n = 6, h = (y2 - y1) / (n + 1);
  let d = `M${x},${y1} L${x},${y1 + h / 2}`;
  for (let i = 0; i < n; i++) d += ` L${x + (i % 2 === 0 ? -12 : 12)},${(y1 + h / 2 + h * (i + 0.5)).toFixed(1)}`;
  d += ` L${x},${y2 - h / 2} L${x},${y2}`;
  return path(d, { stroke: color, width: 3.5 }) + (label ? text(x + 24 * labelSide, (y1 + y2) / 2 + 6, label, { size: 17, color, weight: "bold", anchor: labelSide > 0 ? "start" : "end" }) : "");
}

export function dot(x, y, r = 5, color = C.line) {
  return `<circle cx="${x}" cy="${y}" r="${r}" fill="${color}"/>`;
}
