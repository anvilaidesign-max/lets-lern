import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, dot } from "./kit.mjs";

export default {
  cpu_memory: svg([
    title("Inside a computer: the CPU cycle and memory"),
    circle(200, 250, 120, { fill: "#F8FAFC", stroke: C.grid, width: 2 }),
    box(140, 100, 120, 52, "Fetch", { fill: C.blueLight, stroke: C.blue }),
    box(250, 300, 120, 52, "Decode", { fill: C.purpleLight, stroke: C.purple }),
    box(30, 300, 120, 52, "Execute", { fill: C.orangeLight, stroke: C.orange }),
    arrow(265, 140, 305, 292, { color: C.muted, width: 2.5 }), arrow(248, 355, 152, 355, { color: C.muted, width: 2.5 }), arrow(95, 296, 145, 150, { color: C.muted, width: 2.5 }),
    text(200, 255, "billions of", { size: 15, color: C.muted }), text(200, 275, "times a second", { size: 15, color: C.muted }),
    // memory pyramid
    polygon([[590, 90], [520, 180], [660, 180]], { fill: C.redLight, stroke: C.red, width: 2 }),
    polygon([[520, 180], [660, 180], [700, 260], [480, 260]], { fill: C.orangeLight, stroke: C.orange, width: 2 }),
    polygon([[480, 260], [700, 260], [750, 350], [430, 350]], { fill: C.greenLight, stroke: C.green, width: 2 }),
    text(590, 162, "registers", { size: 14, color: C.ink, weight: "bold" }), text(590, 176, "& cache", { size: 12, color: C.ink }),
    text(590, 228, "RAM", { size: 17, color: C.ink, weight: "bold" }), text(590, 248, "fast, forgets without power", { size: 12, color: C.muted }),
    text(590, 310, "Storage (SSD)", { size: 17, color: C.ink, weight: "bold" }), text(590, 332, "big, keeps data, slower", { size: 12, color: C.muted }),
    arrow(770, 110, 770, 340, { color: C.muted, width: 2 }), text(762, 230, "bigger", { size: 13, color: C.muted, anchor: "end" }),
    arrow(410, 340, 410, 110, { color: C.muted, width: 2 }), text(402, 230, "faster", { size: 13, color: C.muted, anchor: "end" }),
    rect(160, 390, 480, 44, { fill: C.yellowLight, stroke: C.yellow }),
    text(400, 418, "1 byte = 8 bits = 256 values · 1011 (binary) = 11", { size: 16, color: C.ink, weight: "bold" }),
  ].join("\n")),

  internet_path: svg([
    title("How a web page reaches your phone"),
    box(20, 180, 110, 70, ["Phone"], { fill: C.blueLight, stroke: C.blue, sub: "browser" }),
    box(165, 180, 110, 70, ["Router /"], { fill: C.tealLight, stroke: C.teal, sub: "cell tower" }),
    box(310, 180, 110, 70, ["Your ISP"], { fill: C.purpleLight, stroke: C.purple, sub: "network" }),
    box(455, 180, 130, 70, ["Undersea"], { fill: C.orangeLight, stroke: C.orange, sub: "fibre cable" }),
    box(620, 180, 150, 70, ["Data centre"], { fill: C.greenLight, stroke: C.green, sub: "web server" }),
    arrow(130, 205, 163, 205), arrow(275, 205, 308, 205), arrow(420, 205, 453, 205), arrow(585, 205, 618, 205),
    arrow(618, 232, 585, 232, { color: C.green }), arrow(453, 232, 420, 232, { color: C.green }), arrow(308, 232, 275, 232, { color: C.green }), arrow(163, 232, 130, 232, { color: C.green }),
    text(400, 280, "request →   ← packets of the page (HTTPS, encrypted)", { size: 15, color: C.muted, italic: true }),
    // DNS
    box(300, 70, 200, 60, ["DNS lookup"], { fill: C.yellowLight, stroke: C.yellow, sub: "name → IP address" }),
    arrow(95, 178, 298, 108, { color: C.yellow, width: 2.5, dash: "7 5" }),
    text(40, 100, "1. where is example.com?", { size: 14, color: C.ink, anchor: "start" }),
    // layers
    rect(40, 320, 720, 110, { fill: "#F8FAFC", stroke: C.grid }),
    box(60, 340, 155, 70, "HTTP / HTTPS", { fill: C.blueLight, stroke: C.blue, size: 15, sub: "the web page" }),
    box(235, 340, 155, 70, "TCP / UDP", { fill: C.purpleLight, stroke: C.purple, size: 15, sub: "reliable delivery" }),
    box(410, 340, 155, 70, "IP", { fill: C.orangeLight, stroke: C.orange, size: 15, sub: "addresses, routing" }),
    box(585, 340, 155, 70, "Links", { fill: C.greenLight, stroke: C.green, size: 15, sub: "Wi-Fi, 4G, fibre" }),
  ].join("\n")),

  neural_network: (() => {
    const layers = [[3, 90, C.blue, "input"], [4, 290, C.purple, "hidden"], [4, 490, C.purple, "hidden"], [2, 690, C.green, "output"]];
    const pos = layers.map(([n, x]) => Array.from({ length: n }, (_, i) => [x, 240 + (i - (n - 1) / 2) * 75]));
    let edges = "", nodes = "";
    for (let l = 0; l < pos.length - 1; l++) for (const a of pos[l]) for (const b of pos[l + 1]) edges += line(a[0], a[1], b[0], b[1], { color: "#CBD5E1", width: 2 });
    layers.forEach(([, x, color, label], l) => {
      for (const [px, py] of pos[l]) nodes += circle(px, py, 22, { fill: "#FFFFFF", stroke: color, width: 4 });
      nodes += text(x, 400, label, { size: 17, color, weight: "bold" });
    });
    return svg([
      title("A neural network: layers of simple units"),
      edges, nodes,
      text(90, 108, "pixels", { size: 14, color: C.muted }), text(690, 150, "cat?", { size: 14, color: C.muted }),
      text(400, 432, "Training adjusts the weights on every connection to reduce the error", { size: 16, color: C.ink, weight: "bold" }),
    ].join("\n"));
  })(),

  public_key: svg([
    title("Public-key encryption"),
    circle(110, 170, 38, { fill: C.blueLight, stroke: C.blue }), text(110, 177, "Tendai", { size: 15, color: C.blue, weight: "bold" }),
    circle(690, 170, 38, { fill: C.greenLight, stroke: C.green }), text(690, 177, "Rudo", { size: 15, color: C.green, weight: "bold" }),
    // Rudo's keys
    rect(610, 240, 160, 44, { fill: C.orangeLight, stroke: C.orange }), text(690, 268, "public key", { size: 15, color: C.ink, weight: "bold" }),
    rect(610, 300, 160, 44, { fill: C.redLight, stroke: C.red }), text(690, 328, "private key", { size: 15, color: C.ink, weight: "bold" }),
    text(690, 368, "kept secret by Rudo", { size: 13, color: C.red }),
    arrow(608, 262, 150, 196, { color: C.orange, width: 2.5, dash: "7 5" }), text(420, 205, "1. Rudo shares her public key with anyone", { size: 14, color: C.orange }),
    // message
    box(160, 280, 150, 60, "“Meet at 5”", { fill: "#FFFFFF", stroke: C.muted, size: 16, weight: "normal" }),
    arrow(310, 310, 360, 310), text(335, 296, "lock", { size: 12, color: C.muted }),
    box(362, 280, 150, 60, "x9#Qp!r", { fill: C.grid, stroke: C.muted, size: 18 }),
    arrow(512, 310, 606, 322), text(560, 300, "2. send", { size: 13, color: C.muted }),
    text(437, 360, "only the private key can unlock it", { size: 14, color: C.red, weight: "bold" }),
    rect(120, 390, 560, 46, { fill: C.yellowLight, stroke: C.yellow }),
    text(400, 419, "HTTPS uses this to agree a key, then fast AES for the data", { size: 16, color: C.ink, weight: "bold" }),
  ].join("\n")),
};
