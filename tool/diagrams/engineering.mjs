import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box, plot, polyline, resistorH, resistorV, dot } from "./kit.mjs";

/** Diode from (x1,y1) to (x2,y2): current flows towards (x2,y2). */
function diode(x1, y1, x2, y2, color = C.purple) {
  const mx = (x1 + x2) / 2, my = (y1 + y2) / 2;
  const a = Math.atan2(y2 - y1, x2 - x1);
  const s = 14;
  const tip = [mx + Math.cos(a) * s * 0.6, my + Math.sin(a) * s * 0.6];
  const back = [mx - Math.cos(a) * s * 0.6, my - Math.sin(a) * s * 0.6];
  const n = [Math.cos(a + Math.PI / 2) * s * 0.75, Math.sin(a + Math.PI / 2) * s * 0.75];
  const tri = [tip, [back[0] + n[0], back[1] + n[1]], [back[0] - n[0], back[1] - n[1]]].map(([x, y]) => [+x.toFixed(1), +y.toFixed(1)]);
  return line(x1, y1, x2, y2) + polygon(tri, { fill: color }) +
    line(tip[0] + n[0], tip[1] + n[1], tip[0] - n[0], tip[1] - n[1], { color, width: 3.5 });
}

function ground(x, y) {
  return line(x, y, x, y + 12) + line(x - 18, y + 12, x + 18, y + 12) + line(x - 11, y + 19, x + 11, y + 19) + line(x - 4, y + 26, x + 4, y + 26);
}

function capacitorV(x, y1, y2, label) {
  const m = (y1 + y2) / 2;
  return line(x, y1, x, m - 7) + line(x, m + 7, x, y2) +
    line(x - 22, m - 7, x + 22, m - 7, { color: C.blue, width: 4 }) + line(x - 22, m + 7, x + 22, m + 7, { color: C.blue, width: 4 }) +
    (label ? text(x + 30, m + 6, label, { size: 16, color: C.blue, weight: "bold", anchor: "start" }) : "");
}

export default {
  ohms_law_circuit: svg([
    title("Ohm's law: V = I × R"),
    // loop
    line(80, 150, 180, 150), resistorH(180, 320, 150), text(250, 190, "R = 470 Ω", { size: 17, color: C.orange, weight: "bold" }), line(320, 150, 430, 150),
    line(430, 150, 430, 219), circle(430, 245, 26, { stroke: C.green }), text(430, 253, "A", { size: 22, color: C.green, weight: "bold" }), line(430, 271, 430, 390),
    line(430, 390, 80, 390), line(80, 390, 80, 262),
    // battery
    line(56, 250, 104, 250, { color: C.blue, width: 5 }), line(66, 262, 94, 262, { color: C.blue, width: 5 }), line(80, 250, 80, 150),
    text(40, 245, "+", { size: 22, color: C.blue, weight: "bold" }), text(40, 290, "12 V", { size: 17, color: C.blue, weight: "bold" }),
    // voltmeter across R
    circle(250, 88, 24, { stroke: C.purple }), text(250, 96, "V", { size: 22, color: C.purple, weight: "bold" }),
    line(180, 150, 180, 88, { color: C.purple, dash: "6 6", width: 2.5 }), line(180, 88, 226, 88, { color: C.purple, dash: "6 6", width: 2.5 }),
    line(320, 150, 320, 88, { color: C.purple, dash: "6 6", width: 2.5 }), line(274, 88, 320, 88, { color: C.purple, dash: "6 6", width: 2.5 }),
    // current arrow
    arrow(345, 128, 400, 128, { color: C.red }), text(372, 118, "I = 25.5 mA", { size: 15, color: C.red, weight: "bold" }),
    text(255, 425, "Ammeter in series · voltmeter in parallel", { size: 16, color: C.muted, italic: true }),
    // formula triangle
    polygon([[630, 110], [510, 320], [750, 320]], { fill: C.orangeLight, stroke: C.orange, width: 3 }),
    line(569, 216, 691, 216, { color: C.orange, width: 3 }), line(630, 216, 630, 320, { color: C.orange, width: 3 }),
    text(630, 190, "V", { size: 40, color: C.ink, weight: "bold" }),
    text(585, 290, "I", { size: 40, color: C.ink, weight: "bold" }), text(675, 290, "R", { size: 40, color: C.ink, weight: "bold" }),
    text(630, 360, "Cover the one you want:", { size: 16, color: C.muted }),
    text(630, 386, "V = I × R   I = V ÷ R   R = V ÷ I", { size: 16, color: C.ink, weight: "bold" }),
  ].join("\n")),

  ac_sine_power: svg([
    title("AC: peak, RMS and the power triangle"),
    line(50, 230, 440, 230, { color: C.grid, width: 2 }), line(60, 90, 60, 370, { color: C.grid, width: 2 }),
    polyline(plot((t) => Math.sin(t), { x0: 0, x1: 4 * Math.PI, px: 60, py: 110, pw: 370, ph: 240, ymin: -1, ymax: 1 }), { stroke: C.blue, width: 4 }),
    line(60, 110, 440, 110, { color: C.red, dash: "8 6", width: 2.5 }), text(445, 106, "peak 325 V", { size: 15, color: C.red, weight: "bold", anchor: "start" }),
    line(60, 145, 440, 145, { color: C.green, dash: "8 6", width: 2.5 }), text(445, 150, "RMS 230 V", { size: 15, color: C.green, weight: "bold", anchor: "start" }),
    arrow(60, 395, 245, 395, { color: C.muted, width: 2 }), arrow(245, 395, 60, 395, { color: C.muted, width: 2 }),
    text(152, 418, "one cycle = 20 ms (50 Hz)", { size: 15, color: C.muted }),
    text(250, 440, "V_rms = V_peak ÷ √2", { size: 16, color: C.ink, weight: "bold" }),
    // power triangle
    polygon([[560, 340], [760, 340], [760, 180]], { fill: C.yellowLight, stroke: "none" }),
    line(560, 340, 760, 340, { color: C.green, width: 5 }), line(760, 340, 760, 180, { color: C.purple, width: 5 }), line(560, 340, 760, 180, { color: C.orange, width: 5 }),
    path("M610,340 A50,50 0 0,0 599,309", { stroke: C.ink, width: 2 }), text(625, 326, "φ", { size: 20, color: C.ink, weight: "bold" }),
    text(660, 368, "P real power (W)", { size: 15, color: C.green, weight: "bold" }),
    text(770, 265, "Q", { size: 17, color: C.purple, weight: "bold", anchor: "start" }), text(770, 285, "(var)", { size: 13, color: C.purple, anchor: "start" }),
    text(630, 245, "S (VA)", { size: 16, color: C.orange, weight: "bold" }),
    text(660, 404, "power factor = P ÷ S = cos φ", { size: 16, color: C.ink, weight: "bold" }),
  ].join("\n")),

  bridge_rectifier: svg([
    title("Full-wave bridge rectifier with smoothing"),
    // AC source
    circle(90, 230, 28, { stroke: C.teal }), path("M76,230 Q83,216 90,230 Q97,244 104,230", { stroke: C.teal, width: 3 }),
    text(90, 290, "AC in", { size: 15, color: C.teal, weight: "bold" }),
    line(90, 202, 90, 120), line(90, 120, 300, 120), line(90, 258, 90, 340), line(90, 340, 300, 340),
    // bridge (T top, B bottom, L left = DC−, R right = DC+)
    diode(220, 230, 300, 120), diode(220, 230, 300, 340), diode(300, 120, 380, 230), diode(300, 340, 380, 230),
    dot(300, 120), dot(300, 340), dot(220, 230), dot(380, 230),
    // DC− goes down with a hop over the AC wire
    line(220, 230, 220, 328), path("M220,328 A12,12 0 0,1 220,352", { width: 3 }), line(220, 352, 220, 395), line(220, 395, 470, 395), line(470, 395, 470, 310),
    // DC+ rail
    line(380, 230, 470, 230), line(470, 230, 470, 150),
    line(470, 150, 700, 150), line(470, 310, 700, 310),
    capacitorV(560, 150, 310, "C"),
    resistorV(680, 150, 310, { label: "Load", labelSide: -1 }),
    text(720, 156, "+", { size: 24, color: C.red, weight: "bold", anchor: "start" }), text(720, 318, "−", { size: 24, color: C.blue, weight: "bold", anchor: "start" }),
    // waveforms
    polyline(plot((t) => Math.abs(Math.sin(t)), { x0: 0, x1: 3 * Math.PI, px: 480, py: 360, pw: 130, ph: 60, ymin: 0, ymax: 1 }), { stroke: C.orange, width: 3 }),
    text(545, 438, "after bridge: 100 Hz", { size: 13, color: C.orange }),
    polyline(plot((t) => 0.85 + 0.12 * Math.abs(Math.sin(t)), { x0: 0, x1: 3 * Math.PI, px: 640, py: 360, pw: 130, ph: 60, ymin: 0, ymax: 1 }), { stroke: C.green, width: 3 }),
    text(705, 438, "smoothed DC", { size: 13, color: C.green }),
    text(300, 190, "4 diodes", { size: 14, color: C.purple, weight: "bold" }),
  ].join("\n")),

  transistor_relay: svg([
    title("Transistor switch driving a relay"),
    box(40, 230, 170, 80, "Micro-controller", { fill: C.blueLight, stroke: C.blue, size: 16, sub: "pin: 5 V" }),
    line(210, 270, 240, 270), resistorH(240, 360, 270, { label: "R_B 2.2 kΩ" }), line(360, 270, 405, 270),
    // NPN
    circle(430, 270, 42, { stroke: C.ink, width: 2.5 }),
    line(410, 245, 410, 295, { width: 5 }),
    line(410, 258, 450, 235), line(450, 235, 450, 200),
    line(410, 282, 450, 305), polygon([[450, 305], [432, 303], [441, 290]], { fill: C.ink }), line(450, 305, 450, 350),
    ground(450, 350),
    text(478, 245, "C", { size: 14, color: C.muted, anchor: "start" }), text(392, 265, "B", { size: 14, color: C.muted, anchor: "end" }), text(478, 318, "E", { size: 14, color: C.muted, anchor: "start" }),
    text(355, 330, "NPN", { size: 16, color: C.ink, weight: "bold" }),
    // relay coil
    rect(425, 115, 50, 85, { fill: C.orangeLight, stroke: C.orange }), text(450, 163, "coil", { size: 14, color: C.orange, weight: "bold" }),
    line(450, 115, 450, 85), line(450, 85, 600, 85), text(610, 91, "+12 V", { size: 18, color: C.red, weight: "bold", anchor: "start" }),
    // flyback diode
    line(450, 200, 560, 200), line(560, 200, 560, 175), diode(560, 175, 560, 110, C.purple), line(560, 110, 560, 85), dot(450, 200), dot(560, 85),
    text(578, 150, "flyback", { size: 15, color: C.purple, weight: "bold", anchor: "start" }), text(578, 170, "diode", { size: 15, color: C.purple, weight: "bold", anchor: "start" }),
    // currents
    arrow(250, 300, 330, 300, { color: C.red, width: 2.5 }), text(290, 322, "I_B ≈ 2 mA", { size: 14, color: C.red, weight: "bold" }),
    arrow(495, 205, 495, 255, { color: C.red, width: 2.5 }), text(505, 236, "I_C = 60 mA", { size: 14, color: C.red, weight: "bold", anchor: "start" }),
    text(400, 420, "A small base current switches a larger collector current. The diode absorbs the coil's spike.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),

  inverting_amplifier: svg([
    title("Inverting amplifier"),
    polygon([[380, 150], [380, 330], [530, 240]], { fill: C.blueLight, stroke: C.blue, width: 3 }),
    text(398, 207, "−", { size: 26, color: C.ink, weight: "bold" }), text(398, 292, "+", { size: 24, color: C.ink, weight: "bold" }),
    text(80, 206, "V_in", { size: 18, color: C.ink, weight: "bold", anchor: "end" }), dot(90, 200),
    line(90, 200, 140, 200), resistorH(140, 270, 200, { label: "R_in 10 kΩ" }), line(270, 200, 380, 200), dot(330, 200),
    line(330, 200, 330, 110), line(330, 110, 380, 110), resistorH(380, 540, 110, { label: "R_f 100 kΩ", color: C.green }), line(540, 110, 600, 110), line(600, 110, 600, 240),
    line(530, 240, 680, 240), dot(600, 240), dot(680, 240), text(690, 246, "V_out", { size: 18, color: C.ink, weight: "bold", anchor: "start" }),
    line(380, 280, 330, 280), line(330, 280, 330, 320), ground(330, 320),
    text(330, 232, "virtual ground (0 V)", { size: 14, color: C.purple, italic: true }),
    rect(215, 370, 370, 58, { fill: C.yellowLight, stroke: C.yellow }),
    text(400, 406, "Gain = −R_f ÷ R_in = −100 ÷ 10 = −10", { size: 18, color: C.ink, weight: "bold" }),
  ].join("\n")),

  vfd_block: svg([
    title("Inside a variable frequency drive (VFD)"),
    box(20, 140, 120, 90, ["Mains"], { fill: C.tealLight, stroke: C.teal, sub: "3~ 50 Hz" }),
    box(175, 140, 125, 90, ["Rectifier"], { fill: C.purpleLight, stroke: C.purple, sub: "diodes" }),
    box(335, 140, 125, 90, ["DC bus"], { fill: C.yellowLight, stroke: C.yellow, sub: "capacitors" }),
    box(495, 140, 125, 90, ["Inverter"], { fill: C.orangeLight, stroke: C.orange, sub: "IGBTs + PWM" }),
    arrow(140, 185, 173, 185), arrow(300, 185, 333, 185), arrow(460, 185, 493, 185), arrow(620, 185, 668, 185),
    circle(715, 185, 45, { fill: C.blueLight, stroke: C.blue }), text(715, 183, "M", { size: 28, color: C.blue, weight: "bold" }), text(715, 206, "3~", { size: 15, color: C.blue }),
    // waveforms
    polyline(plot((t) => Math.sin(t), { x0: 0, x1: 4 * Math.PI, px: 30, py: 260, pw: 100, ph: 50, ymin: -1, ymax: 1 }), { stroke: C.teal, width: 3 }),
    polyline(plot((t) => Math.abs(Math.sin(t)), { x0: 0, x1: 4 * Math.PI, px: 187, py: 260, pw: 100, ph: 50, ymin: 0, ymax: 1 }), { stroke: C.purple, width: 3 }),
    line(347, 272, 447, 272, { color: C.yellow, width: 4 }), text(397, 305, "steady DC", { size: 13, color: C.muted }),
    path("M507,300 L515,300 L515,265 L522,265 L522,300 L532,300 L532,262 L548,262 L548,300 L556,300 L556,262 L575,262 L575,300 L585,300 L585,265 L592,265 L592,300 L605,300", { stroke: C.orange, width: 2.5 }),
    polyline(plot((t) => Math.sin(t), { x0: 0, x1: 2 * Math.PI, px: 665, py: 260, pw: 100, ph: 50, ymin: -1, ymax: 1 }), { stroke: C.blue, width: 3 }),
    text(715, 330, "any frequency", { size: 13, color: C.muted }),
    rect(110, 355, 580, 70, { fill: "#F8FAFC", stroke: C.grid }),
    text(400, 385, "Speed follows frequency: n_s = 120 × f ÷ p", { size: 19, color: C.ink, weight: "bold" }),
    text(400, 412, "Half speed on a fan ≈ one eighth of the power (affinity laws)", { size: 16, color: C.green, weight: "bold" }),
  ].join("\n")),

  current_loop: svg([
    title("The 4–20 mA current loop"),
    box(40, 110, 160, 110, ["24 V DC", "supply"], { fill: C.redLight, stroke: C.red, size: 18 }),
    box(560, 90, 200, 120, ["Pressure", "transmitter"], { fill: C.tealLight, stroke: C.teal, size: 18, sub: "0–10 bar" }),
    box(330, 250, 170, 90, ["PLC analogue", "input"], { fill: C.blueLight, stroke: C.blue, size: 16, sub: "250 Ω → 1–5 V" }),
    line(200, 140, 560, 140, { color: C.red, width: 4 }), arrow(330, 140, 400, 140, { color: C.red, width: 4 }),
    line(660, 210, 660, 295, { color: C.red, width: 4 }), line(660, 295, 500, 295, { color: C.red, width: 4 }),
    line(330, 295, 120, 295, { color: C.red, width: 4 }), line(120, 295, 120, 220, { color: C.red, width: 4 }),
    text(400, 125, "same current everywhere in the loop", { size: 14, color: C.red, italic: true }),
    // scale
    rect(60, 375, 400, 22, { fill: C.greenLight, stroke: C.green, rx: 6 }), line(260, 372, 260, 400, { color: C.green, width: 2 }),
    text(60, 424, "4 mA = 0%", { size: 15, color: C.ink, weight: "bold", anchor: "start" }),
    text(260, 424, "12 mA = 50%", { size: 15, color: C.ink, weight: "bold" }),
    text(460, 424, "20 mA = 100%", { size: 15, color: C.ink, weight: "bold", anchor: "end" }),
    text(640, 395, "0 mA = broken wire!", { size: 18, color: C.red, weight: "bold" }),
    text(640, 420, "live zero makes faults visible", { size: 14, color: C.muted }),
  ].join("\n")),

  plc_scan_ladder: svg([
    title("PLC scan cycle and a seal-in rung"),
    circle(190, 245, 110, { fill: "#F8FAFC", stroke: C.grid, width: 2 }),
    box(130, 95, 120, 50, "1 Read inputs", { fill: C.greenLight, stroke: C.green, size: 14 }),
    box(250, 220, 120, 50, "2 Run program", { fill: C.blueLight, stroke: C.blue, size: 14 }),
    box(130, 345, 120, 50, "3 Write outputs", { fill: C.orangeLight, stroke: C.orange, size: 14 }),
    box(10, 220, 120, 50, "4 Comms, checks", { fill: C.purpleLight, stroke: C.purple, size: 14 }),
    arrow(255, 140, 290, 215, { color: C.muted, width: 2.5 }), arrow(290, 275, 255, 345, { color: C.muted, width: 2.5 }),
    arrow(125, 350, 90, 275, { color: C.muted, width: 2.5 }), arrow(90, 215, 125, 140, { color: C.muted, width: 2.5 }),
    text(190, 250, "every few ms", { size: 14, color: C.muted, italic: true }),
    // ladder rung
    line(420, 90, 420, 400, { width: 5 }), line(770, 90, 770, 400, { width: 5 }),
    line(420, 170, 470, 170), line(470, 150, 470, 190, { color: C.green, width: 4 }), line(490, 150, 490, 190, { color: C.green, width: 4 }), text(480, 135, "Start", { size: 15, color: C.green, weight: "bold" }),
    line(490, 170, 560, 170),
    line(440, 170, 440, 260), line(440, 260, 470, 260), line(470, 240, 470, 280, { color: C.blue, width: 4 }), line(490, 240, 490, 280, { color: C.blue, width: 4 }), line(490, 260, 540, 260), line(540, 260, 540, 170), dot(440, 170), dot(540, 170),
    text(480, 305, "Motor (seal-in)", { size: 14, color: C.blue, weight: "bold" }),
    line(560, 150, 560, 190, { color: C.red, width: 4 }), line(580, 150, 580, 190, { color: C.red, width: 4 }), line(556, 192, 584, 148, { color: C.red, width: 3 }), text(570, 135, "Stop (NC)", { size: 15, color: C.red, weight: "bold" }),
    line(580, 170, 670, 170), path("M680,150 A20,20 0 0,0 680,190", { width: 3.5, stroke: C.orange }), path("M710,150 A20,20 0 0,1 710,190", { width: 3.5, stroke: C.orange }), line(720, 170, 770, 170),
    text(695, 135, "Motor", { size: 15, color: C.orange, weight: "bold" }),
    rect(440, 330, 310, 60, { fill: C.yellowLight, stroke: C.yellow }),
    text(595, 367, "Motor = (Start OR Motor) AND NOT Stop", { size: 15, color: C.ink, weight: "bold" }),
  ].join("\n")),
};
