import { C, svg, text, title, line, rect, circle, arrow, box } from "./kit.mjs";

export default {
  un_system: svg([
    title("The United Nations system"),
    box(40, 70, 230, 100, "General Assembly", { fill: C.blueLight, stroke: C.blue, size: 18, sub: "all 193 members, one vote each" }),
    box(285, 70, 230, 100, "Security Council", { fill: C.redLight, stroke: C.red, size: 18, sub: "15 members; can bind states" }),
    box(530, 70, 230, 100, "Secretariat", { fill: C.greenLight, stroke: C.green, size: 18, sub: "led by the Secretary-General" }),
    box(40, 190, 230, 80, "International Court of Justice", { fill: C.purpleLight, stroke: C.purple, size: 14, sub: "disputes between states" }),
    box(285, 190, 230, 80, "ECOSOC", { fill: C.tealLight, stroke: C.teal, size: 18, sub: "economic and social work" }),
    box(530, 190, 230, 80, "Agencies and funds", { fill: C.orangeLight, stroke: C.orange, size: 16, sub: "WHO, UNICEF, WFP, UNHCR" }),
    rect(40, 292, 720, 128, { fill: "#F8FAFC", stroke: C.grid }),
    text(400, 322, "Security Council", { size: 17, color: C.red, weight: "bold" }),
    ...["China", "France", "Russia", "UK", "USA"].map((n, i) => circle(110 + i * 70, 364, 26, { fill: C.redLight, stroke: C.red }) + text(110 + i * 70, 369, n, { size: 12, color: C.ink, weight: "bold" })),
    text(250, 408, "5 permanent members with a veto", { size: 14, color: C.red, weight: "bold" }),
    ...Array.from({ length: 10 }, (_, i) => circle(500 + (i % 5) * 44, 348 + Math.floor(i / 5) * 34, 13, { fill: "#FFFFFF", stroke: C.muted, width: 2 })),
    text(588, 408, "10 elected for 2 years", { size: 14, color: C.muted, weight: "bold" }),
  ].join("\n")),

  african_blocs: svg([
    title("Africa's institutions"),
    box(250, 62, 300, 72, "African Union", { fill: C.greenLight, stroke: C.green, size: 20, sub: "55 member states · Addis Ababa" }),
    line(400, 134, 400, 158, { color: C.muted, width: 2.5 }), line(80, 158, 720, 158, { color: C.muted, width: 2.5 }),
    ...[["SADC", "Southern", true], ["COMESA", "East/South", true], ["EAC", "East", false], ["ECOWAS", "West", false], ["ECCAS", "Central", false], ["IGAD", "Horn", false]].map(([name, region, zim], i) => {
      const x = 30 + i * 125;
      return line(x + 50, 158, x + 50, 176, { color: C.muted, width: 2.5 }) + box(x, 178, 100, 70, name, { fill: zim ? C.yellowLight : "#F8FAFC", stroke: zim ? C.yellow : C.grid, size: 17, sub: region });
    }),
    text(560, 272, "Zimbabwe belongs to the highlighted ones", { size: 14, color: C.muted, italic: true }),
    box(160, 300, 480, 80, "AfCFTA: African Continental Free Trade Area", { fill: C.blueLight, stroke: C.blue, size: 17, sub: "one market of about 1.4 billion people · trading since 2021" }),
    arrow(250, 250, 250, 296, { color: C.blue, width: 3 }),
    text(400, 420, "Goal: lower tariffs and barriers so Africa trades more with itself.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),

  power_spectrum: svg([
    title("How states get what they want"),
    rect(40, 90, 720, 30, { fill: "#F1F5F9", stroke: C.grid, rx: 15 }),
    `<defs><linearGradient id="g" x1="0" x2="1"><stop offset="0" stop-color="${C.red}"/><stop offset="0.5" stop-color="${C.yellow}"/><stop offset="1" stop-color="${C.green}"/></linearGradient></defs>`,
    `<rect x="40" y="90" width="720" height="30" rx="15" fill="url(#g)"/>`,
    text(40, 78, "Hard power: coerce", { size: 16, color: C.red, weight: "bold", anchor: "start" }),
    text(760, 78, "Soft power: attract", { size: 16, color: C.green, weight: "bold", anchor: "end" }),
    ...[["Military force", 70], ["Sanctions", 205], ["Aid and trade deals", 360], ["Diplomacy", 510], ["Culture, ideas, education", 655]].map(([t, x]) => line(x + 30, 122, x + 30, 150, { color: C.muted, width: 2 }) + text(x + 30, 170, t, { size: 14, color: C.ink, weight: "bold" })),
    text(400, 222, "Three ways to explain world politics", { size: 18, color: C.ink, weight: "bold" }),
    box(40, 240, 230, 150, "Realism", { fill: C.redLight, stroke: C.red, size: 19, sub: "power and security first" }),
    box(285, 240, 230, 150, "Liberalism", { fill: C.blueLight, stroke: C.blue, size: 19, sub: "trade and institutions help" }),
    box(530, 240, 230, 150, "Constructivism", { fill: C.purpleLight, stroke: C.purple, size: 19, sub: "ideas and identity matter" }),
    text(400, 425, "Most real events need more than one lens to explain.", { size: 15, color: C.muted, italic: true }),
  ].join("\n")),
};
