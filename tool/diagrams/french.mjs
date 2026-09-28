import { C, svg, text, title, line, rect, circle, path, polygon, arrow, box } from "./kit.mjs";

export default {
  french_articles: (() => {
    const cols = [["Masculine", C.blue, C.blueLight], ["Feminine", C.red, C.redLight], ["Plural", C.purple, C.purpleLight]];
    const rows = [
      ["the", ["le livre", "la table", "les livres"], "l' before a vowel: l'ami, l'école"],
      ["a / some", ["un livre", "une table", "des livres"], ""],
      ["some (part of)", ["du pain", "de la bière", "des pâtes"], "de l' before a vowel: de l'eau"],
    ];
    let out = "";
    cols.forEach(([name, c, f], i) => { out += rect(220 + i * 185, 64, 170, 40, { fill: f, stroke: c }) + text(305 + i * 185, 90, name, { size: 17, color: c, weight: "bold" }); });
    rows.forEach(([label, cells, note], r) => {
      const y = 116 + r * 78;
      out += text(200, y + 34, label, { size: 16, color: C.ink, weight: "bold", anchor: "end" });
      cells.forEach((cell, i) => { out += rect(220 + i * 185, y, 170, 52, { fill: "#FFFFFF", stroke: C.grid }) + text(305 + i * 185, y + 33, cell, { size: 18, color: C.ink }); });
      if (note) out += text(590, y + 70, note, { size: 13, color: C.muted, italic: true });
    });
    out += rect(40, 356, 720, 74, { fill: C.yellowLight, stroke: C.yellow });
    out += text(400, 384, "Contractions:  à + le = au   ·   à + les = aux   ·   de + le = du   ·   de + les = des", { size: 16, color: C.ink, weight: "bold" });
    out += text(400, 412, "Je vais au marché. · Le prix du pain. · Après la négation: pas de pain.", { size: 15, color: C.muted, italic: true });
    return svg([title("French articles at a glance"), out].join("\n"));
  })(),

  french_tenses: (() => {
    const x0 = 70, x1 = 730, y = 210;
    const marks = [
      [0.1, "Passé composé", "J'ai mangé.", "a finished action", C.red, true],
      [0.28, "Imparfait", "Je mangeais.", "background, habits", C.orange, false],
      [0.5, "Présent", "Je mange.", "now, general truths", C.green, true],
      [0.72, "Futur proche", "Je vais manger.", "soon, planned", C.blue, false],
      [0.9, "Futur simple", "Je mangerai.", "later, predictions", C.purple, true],
    ];
    let out = arrow(x0, y, x1 + 20, y, { color: C.line, width: 5, head: 18 });
    out += text(x0, y + 40, "past", { size: 15, color: C.muted, anchor: "start" }) + text(x1, y + 40, "future", { size: 15, color: C.muted, anchor: "end" });
    for (const [t, name, eg, use, c, up] of marks) {
      const x = x0 + t * (x1 - x0);
      out += circle(x, y, 11, { fill: c, stroke: "#FFFFFF", width: 3 });
      const by = up ? y - 128 : y + 56;
      out += line(x, up ? y - 14 : y + 14, x, up ? by + 94 : by, { color: c, width: 2.5 });
      out += rect(x - 78, by, 156, 94, { fill: "#FFFFFF", stroke: c });
      out += text(x, by + 26, name, { size: 16, color: c, weight: "bold" });
      out += text(x, by + 52, eg, { size: 16, color: C.ink, weight: "bold" });
      out += text(x, by + 76, use, { size: 13, color: C.muted });
    }
    out += text(400, 432, "Hier, il pleuvait (imparfait) quand j'ai pris le bus (passé composé).", { size: 15, color: C.muted, italic: true });
    return svg([title("French tenses on a timeline"), out].join("\n"));
  })(),

  french_conversation: (() => {
    const lines = [
      ["left", "Bonjour madame ! Je voudrais un café, s'il vous plaît.", "Hello! I'd like a coffee, please."],
      ["right", "Bien sûr. Sur place ou à emporter ?", "Of course. Here or to take away?"],
      ["left", "Sur place. C'est combien ?", "Here. How much is it?"],
      ["right", "Deux euros cinquante.", "Two euros fifty."],
      ["left", "Voilà. Merci, bonne journée !", "Here you are. Thanks, have a good day!"],
    ];
    let out = "";
    lines.forEach(([side, fr, en], i) => {
      const y = 62 + i * 76, w = 520, left = side === "left";
      const x = left ? 40 : 800 - 40 - w;
      out += rect(x, y, w, 62, { fill: left ? C.blueLight : C.greenLight, stroke: left ? C.blue : C.green, rx: 18 });
      out += text(x + 18, y + 27, fr, { size: 17, color: C.ink, weight: "bold", anchor: "start" });
      out += text(x + 18, y + 50, en, { size: 13, color: C.muted, italic: true, anchor: "start" });
    });
    return svg([title("Au café: a real conversation"), out].join("\n"));
  })(),
};
