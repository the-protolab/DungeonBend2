import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as process from "node:process";
import { pathToFileURL } from "node:url";
import { generateDungeonConfig as generateDungeonData } from "./dungeon-data.ts";

async function loadPatchedBend(cwd: string) {
  const bendSrcDir = path.resolve(cwd, "../Bend2/bend-ts/src");
  const patchedRoot = path.resolve(process.env.TMPDIR ?? "/tmp", `dungeonbend-bend-ts-src-${process.pid}`);
  const typeAnalysisPath = path.join(patchedRoot, "Compile/ToJS/TypeAnalysis.ts");
  const compilerPath = path.join(patchedRoot, "Compile/ToJS/Compiler.ts");
  const originalForceType = `export function force_type(book: Core.Book, typ: Core.Term | null): Core.Term | null {
  if (typ === null) {
    return null;
  }
  return Core.wnf_force(book, typ);
}`;
  const patchedForceType = `export function force_type(book: Core.Book, typ: Core.Term | null): Core.Term | null {
  if (typ === null) {
    return null;
  }
  try {
    return Core.wnf_force(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
}`;
  const originalNativeType = `export function native_type(book: Core.Book | null, typ: Core.Term | null): "char" | "string" | "vector" | null {
  if (book === null) {
    return null;
  }
  var typ = force_type(book, typ);
  if (typ === null || typ.$ !== "ADT") {
    return null;
  }
  if (adt_is_char(book, typ)) {
    return "char";
  }
  if (adt_is_string(book, typ)) {
    return "string";
  }
  if (adt_is_vector(book, typ)) {
    return "vector";
  }
  return null;
}`;
  const originalCtrFlds = `export function ctr_flds(
  book: Core.Book | null,
  typ: Core.Term | null,
  nam: string,
): Core.TeleFld[] | null {
  if (book === null) {
    return null;
  }
  var adt = force_type(book, typ);
  if (adt === null || adt.$ !== "ADT") {
    return null;
  }
  var [ctr] = Core.take_constructor(adt, nam);
  if (ctr === null) {
    return null;
  }
  return Core.tele_flds(ctr.fds);
}`;
  const patchedCtrFlds = `export function ctr_flds(
  book: Core.Book | null,
  typ: Core.Term | null,
  nam: string,
): Core.TeleFld[] | null {
  if (book === null) {
    return null;
  }
  let adt: Core.Term | null = null;
  try {
    adt = force_type(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  if (adt === null || adt.$ !== "ADT") {
    return null;
  }
  var [ctr] = Core.take_constructor(adt, nam);
  if (ctr === null) {
    return null;
  }
  try {
    return Core.tele_flds(ctr.fds);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
}`;
  const patchedEmitStringCtr = `function emit_string_ctr(st: Types.EmitState, dst: string, trm: Core.Ctr, ctx: Types.EmitCtx): void {
  function unwrap(tm: Core.Term): Core.Term {
    while (tm.$ === "Ann" || tm.$ === "Red") {
      tm = tm.$ === "Ann" ? tm.val : tm.rgt;
    }
    return tm;
  }
  var cur: Core.Term = trm;
  var out = "";
  while (true) {
    cur = unwrap(cur);
    if (cur.$ !== "Ctr") {
      break;
    }
    if (cur.nam === "nil") {
      Emit.emit_set(st, dst, JSON.stringify(out));
      return;
    }
    if (cur.nam !== "cons" || cur.fds.length !== 2) {
      break;
    }
    var hed_tm = unwrap(cur.fds[0]);
    if (hed_tm.$ !== "Ctr" || hed_tm.nam !== "char" || hed_tm.fds.length !== 1) {
      break;
    }
    var chr_tm = unwrap(hed_tm.fds[0]);
    if (chr_tm.$ !== "W32") {
      break;
    }
    out += String.fromCharCode((chr_tm.val >>> 0) & 0xFFFF);
    cur = cur.fds[1];
  }
  if (trm.nam === "nil") {
    Emit.emit_set(st, dst, '""');
    return;
  }
  var hed = emit_sub(st, trm.fds[0], ctx);
  var rst = emit_sub(st, trm.fds[1], ctx);
  Emit.emit_set(st, dst, "(" + hed + " + " + rst + ")");
}`;
  const emitStringCtrPattern = /function emit_string_ctr\(st: Types\.EmitState, dst: string, trm: Core\.Ctr, ctx: Types\.EmitCtx\): void \{[\s\S]*?\n\}/;
  const patchedNativeType = `export function native_type(book: Core.Book | null, typ: Core.Term | null): "char" | "string" | "vector" | null {
  if (book === null) {
    return null;
  }
  try {
    var typ = force_type(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  if (typ === null || typ.$ !== "ADT") {
    return null;
  }
  try {
    if (adt_is_char(book, typ)) {
      return "char";
    }
    if (adt_is_string(book, typ)) {
      return "string";
    }
    if (adt_is_vector(book, typ)) {
      return "vector";
    }
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  return null;
}`;

  await fs.rm(patchedRoot, { recursive: true, force: true });
  await fs.cp(bendSrcDir, patchedRoot, { recursive: true });

  const typeAnalysisSource = await fs.readFile(typeAnalysisPath, "utf8");
  const compilerSource = await fs.readFile(compilerPath, "utf8");
  if (!typeAnalysisSource.includes(originalForceType)) {
    throw new Error("Could not locate Bend TypeAnalysis.force_type for patching");
  }
  if (!typeAnalysisSource.includes(originalNativeType)) {
    throw new Error("Could not locate Bend TypeAnalysis.native_type for patching");
  }
  if (!typeAnalysisSource.includes(originalCtrFlds)) {
    throw new Error("Could not locate Bend TypeAnalysis.ctr_flds for patching");
  }
  if (!emitStringCtrPattern.test(compilerSource)) {
    throw new Error("Could not locate Bend Compiler.emit_string_ctr for patching");
  }
  await fs.writeFile(
    typeAnalysisPath,
    typeAnalysisSource
      .replace(originalForceType, patchedForceType)
      .replace(originalNativeType, patchedNativeType)
      .replace(originalCtrFlds, patchedCtrFlds)
  );
  await fs.writeFile(compilerPath, compilerSource.replace(emitStringCtrPattern, patchedEmitStringCtr));

  return import(`${pathToFileURL(path.join(patchedRoot, "Bend.ts")).href}?ts=${Date.now()}`);
}

type RawHero = {
  id: string;
  name: string;
  sprite: string;
  base_max_hp: number;
  unlock_cost: number;
  upgrades: RawUpgrade[];
};

type RawHeroPresentation = {
  hero_id: string;
  name_align: string;
  ultimate_title: string;
  ultimate_icon: string;
  ultimate_description: string;
};

type RawHeroPresentationConfig = {
  heroes: RawHeroPresentation[];
};

type RawMonster = {
  id: string;
  name: string;
  sprite: string;
  gold_drop: number;
  hp_levels: number[];
};

type RawSword = {
  id: string;
  name: string;
  sprite: string;
  dmg: number;
};

type RawPotion = {
  id: string;
  name: string;
  sprite: string;
  heal: number;
};

type RawUpgrade = {
  cost: number;
  max_hp: number;
};

type RawDeckEntry = {
  card_id: string;
  count: number;
};

type RawPack = {
  id: string;
  name: string;
  price: number;
  reveal_count: number;
  allow_duplicates: boolean;
};

type RawPackPoolEntry = {
  pack_id: string;
  card_id: string;
  weight: number;
};

type RawDungeonConfig = {
  cards: {
    heroes: RawHero[];
    monsters: RawMonster[];
    swords: RawSword[];
    potions: RawPotion[];
  };
  base_deck: RawDeckEntry[];
  booster_packs: RawPack[];
  booster_pack_pool: RawPackPoolEntry[];
  economy: {
    starting_dungeon_level: number;
  };
};

type CardKind = "hero" | "monster" | "sword" | "potion";

type CardIndex = {
  kind: CardKind;
  index: number;
};

function fail(message: string): never {
  throw new Error(`Dungeon config error: ${message}`);
}

function validatePositiveInt(value: number, label: string): number {
  if (!Number.isInteger(value) || value <= 0) {
    fail(`${label} must be a positive integer`);
  }
  return value;
}

function validateNonNegativeInt(value: number, label: string): number {
  if (!Number.isInteger(value) || value < 0) {
    fail(`${label} must be a non-negative integer`);
  }
  return value;
}

function validateString(value: string, label: string): string {
  if (typeof value !== "string" || value.trim() === "") {
    fail(`${label} must be a non-empty string`);
  }
  return value;
}

function bendString(value: string): string {
  return JSON.stringify(value);
}

function indent(size: number): string {
  return " ".repeat(size);
}

function bendList(items: string[], size: number): string {
  if (items.length === 0) {
    return "[]";
  }
  const outer = indent(size);
  const inner = indent(size + 2);
  return `[\n${items.map((item) => `${inner}${item}`).join(",\n")}\n${outer}]`;
}

function renderPresentationAlign(value: string, label: string): string {
  switch (validateString(value, label)) {
    case "left":
      return "presentation_left{}";
    case "center":
      return "presentation_center{}";
    case "right":
      return "presentation_right{}";
    default:
      fail(`${label} must be "left", "center", or "right"`);
  }
}

function buildCardIndexes(raw: RawDungeonConfig): Map<string, CardIndex> {
  const indexes = new Map<string, CardIndex>();
  const push = (id: string, card: CardIndex) => {
    if (indexes.has(id)) {
      fail(`duplicate card id "${id}"`);
    }
    indexes.set(id, card);
  };

  push("hero", { kind: "hero", index: 0 });
  raw.cards.monsters.forEach((monster, index) => {
    push(validateString(monster.id, `cards.monsters[${index}].id`), { kind: "monster", index });
  });
  raw.cards.swords.forEach((sword, index) => {
    push(validateString(sword.id, `cards.swords[${index}].id`), { kind: "sword", index });
  });
  raw.cards.potions.forEach((potion, index) => {
    push(validateString(potion.id, `cards.potions[${index}].id`), { kind: "potion", index });
  });

  return indexes;
}

function renderCardRef(card: CardIndex): string {
  switch (card.kind) {
    case "hero":
      return "hero_card{}";
    case "monster":
      return `monster_card{${card.index}}`;
    case "sword":
      return `sword_card{${card.index}}`;
    case "potion":
      return `potion_card{${card.index}}`;
  }
}

function renderDeckEntry(card: CardIndex, count: number): string {
  switch (card.kind) {
    case "hero":
      return `hero_entry{${count}}`;
    case "monster":
      return `monster_entry{${card.index}, ${count}}`;
    case "sword":
      return `sword_entry{${card.index}, ${count}}`;
    case "potion":
      return `potion_entry{${card.index}, ${count}}`;
  }
}

function renderConfigModule(raw: RawDungeonConfig): string {
  const cardIndexes = buildCardIndexes(raw);

  if (!Array.isArray(raw.cards.heroes) || raw.cards.heroes.length === 0) {
    fail("cards.heroes must contain at least one hero");
  }

  const heroIds = new Set<string>();
  const heroes = raw.cards.heroes.map((hero, index) => {
    const heroId = validateString(hero.id, `cards.heroes[${index}].id`);
    if (heroIds.has(heroId)) {
      fail(`duplicate hero id "${heroId}"`);
    }
    heroIds.add(heroId);
    validateString(hero.name, `cards.heroes[${index}].name`);
    validateString(hero.sprite, `cards.heroes[${index}].sprite`);
    validatePositiveInt(hero.base_max_hp, `cards.heroes[${index}].base_max_hp`);
    validateNonNegativeInt(hero.unlock_cost, `cards.heroes[${index}].unlock_cost`);
    if (!Array.isArray(hero.upgrades) || hero.upgrades.length === 0) {
      fail(`cards.heroes[${index}].upgrades must contain at least one upgrade step`);
    }
    const upgrades = hero.upgrades.map((upgrade, upgradeIndex) => {
      validatePositiveInt(upgrade.cost, `cards.heroes[${index}].upgrades[${upgradeIndex}].cost`);
      validatePositiveInt(upgrade.max_hp, `cards.heroes[${index}].upgrades[${upgradeIndex}].max_hp`);
      return `upgrade{${upgrade.cost}, ${upgrade.max_hp}}`;
    });
    return `hero_def{${bendString(heroId)}, ${bendString(hero.name)}, ${bendString(hero.sprite)}, ${hero.base_max_hp}, ${hero.unlock_cost}, ${bendList(upgrades, 6)}}`;
  });

  const monsterDefs = raw.cards.monsters.map((monster, index) => {
    validateString(monster.name, `cards.monsters[${index}].name`);
    validateString(monster.sprite, `cards.monsters[${index}].sprite`);
    validatePositiveInt(monster.gold_drop, `cards.monsters[${index}].gold_drop`);
    if (!Array.isArray(monster.hp_levels) || monster.hp_levels.length === 0) {
      fail(`cards.monsters[${index}].hp_levels must have at least one entry`);
    }
    const hpLevels = monster.hp_levels.map((value, levelIndex) =>
      String(validatePositiveInt(value, `cards.monsters[${index}].hp_levels[${levelIndex}]`))
    );
    return `monster_def{${bendString(monster.name)}, ${bendString(monster.sprite)}, ${monster.gold_drop}, ${bendList(hpLevels, 6)}}`;
  });

  const swordDefs = raw.cards.swords.map((sword, index) => {
    validateString(sword.name, `cards.swords[${index}].name`);
    validateString(sword.sprite, `cards.swords[${index}].sprite`);
    validatePositiveInt(sword.dmg, `cards.swords[${index}].dmg`);
    return `sword_def{${bendString(sword.name)}, ${bendString(sword.sprite)}, ${sword.dmg}}`;
  });

  const potionDefs = raw.cards.potions.map((potion, index) => {
    validateString(potion.name, `cards.potions[${index}].name`);
    validateString(potion.sprite, `cards.potions[${index}].sprite`);
    validatePositiveInt(potion.heal, `cards.potions[${index}].heal`);
    return `potion_def{${bendString(potion.name)}, ${bendString(potion.sprite)}, ${potion.heal}}`;
  });

  const baseDeck = raw.base_deck.map((entry, index) => {
    const cardId = validateString(entry.card_id, `base_deck[${index}].card_id`);
    const card = cardIndexes.get(cardId);
    if (card === undefined) {
      fail(`base_deck[${index}] references unknown card_id "${cardId}"`);
    }
    return renderDeckEntry(card, validatePositiveInt(entry.count, `base_deck[${index}].count`));
  });

  if (baseDeck.length === 0) {
    fail("base_deck must contain at least one entry");
  }

  const packIndexById = new Map<string, number>();
  raw.booster_packs.forEach((pack, index) => {
    const packId = validateString(pack.id, `booster_packs[${index}].id`);
    if (packIndexById.has(packId)) {
      fail(`duplicate booster pack id "${packId}"`);
    }
    packIndexById.set(packId, index);
  });

  if (raw.booster_packs.length === 0) {
    fail("booster_packs must contain at least one pack");
  }

  const packPools = new Map<string, RawPackPoolEntry[]>();
  raw.booster_pack_pool.forEach((entry, index) => {
    const packId = validateString(entry.pack_id, `booster_pack_pool[${index}].pack_id`);
    const cardId = validateString(entry.card_id, `booster_pack_pool[${index}].card_id`);
    const card = cardIndexes.get(cardId);
    if (card === undefined) {
      fail(`booster_pack_pool[${index}] references unknown card_id "${cardId}"`);
    }
    if (card.kind === "hero") {
      fail(`booster_pack_pool[${index}] cannot reference the hero card`);
    }
    if (!packIndexById.has(packId)) {
      fail(`booster_pack_pool[${index}] references unknown pack_id "${packId}"`);
    }
    validatePositiveInt(entry.weight, `booster_pack_pool[${index}].weight`);
    const existing = packPools.get(packId) ?? [];
    if (existing.some((current) => current.card_id === cardId)) {
      fail(`pack "${packId}" contains duplicated pool entry for "${cardId}"`);
    }
    existing.push(entry);
    packPools.set(packId, existing);
  });

  const packs = raw.booster_packs.map((pack, index) => {
    validateString(pack.name, `booster_packs[${index}].name`);
    validatePositiveInt(pack.price, `booster_packs[${index}].price`);
    validatePositiveInt(pack.reveal_count, `booster_packs[${index}].reveal_count`);
    const poolEntries = packPools.get(pack.id) ?? [];
    if (poolEntries.length === 0) {
      fail(`booster pack "${pack.id}" is missing pool entries`);
    }
    if (!pack.allow_duplicates && poolEntries.length < pack.reveal_count) {
      fail(`booster pack "${pack.id}" needs at least ${pack.reveal_count} unique pool cards`);
    }
    const renderedPool = poolEntries.map((entry) => {
      const card = cardIndexes.get(entry.card_id);
      if (card === undefined) {
        fail(`booster pack "${pack.id}" references unknown card "${entry.card_id}"`);
      }
      return `pack_pool_entry{${renderCardRef(card)}, ${entry.weight}}`;
    });
    return `pack_def{${bendString(pack.name)}, ${pack.price}, ${pack.reveal_count}, ${pack.allow_duplicates ? 1 : 0}, ${bendList(renderedPool, 6)}}`;
  });

  validatePositiveInt(raw.economy.starting_dungeon_level, "economy.starting_dungeon_level");

  return [
    "import /Dungeon/Config as Config",
    "import /Dungeon/HeroDef as HeroDef",
    "import /Dungeon/Upgrade as Upgrade",
    "import /Dungeon/MonsterDef as MonsterDef",
    "import /Dungeon/SwordDef as SwordDef",
    "import /Dungeon/PotionDef as PotionDef",
    "import /Dungeon/DeckEntry as DeckEntry",
    "import /Dungeon/CardRef as CardRef",
    "import /Dungeon/PackPoolEntry as PackPoolEntry",
    "import /Dungeon/PackDef as PackDef",
    "",
    "def generated_config() -> Config:",
    "  config{",
    `    ${bendList(heroes, 4)},`,
    `    ${bendList(monsterDefs, 4)},`,
    `    ${bendList(swordDefs, 4)},`,
    `    ${bendList(potionDefs, 4)},`,
    `    ${bendList(baseDeck, 4)},`,
    `    ${bendList(packs, 4)},`,
    `    ${raw.economy.starting_dungeon_level}`,
    "  }",
    "",
  ].join("\n");
}

function renderHeroPresentationModule(rawConfig: RawDungeonConfig, rawPresentation: RawHeroPresentationConfig): string {
  if (!Array.isArray(rawPresentation.heroes)) {
    fail("hero.presentation heroes must be a list");
  }

  const presentationByHeroId = new Map<string, RawHeroPresentation>();
  rawPresentation.heroes.forEach((presentation, index) => {
    const heroId = validateString(presentation.hero_id, `hero.presentation.heroes[${index}].hero_id`);
    if (presentationByHeroId.has(heroId)) {
      fail(`duplicate hero presentation for "${heroId}"`);
    }
    validateString(presentation.ultimate_title, `hero.presentation.heroes[${index}].ultimate_title`);
    validateString(presentation.ultimate_icon, `hero.presentation.heroes[${index}].ultimate_icon`);
    validateString(presentation.ultimate_description, `hero.presentation.heroes[${index}].ultimate_description`);
    renderPresentationAlign(presentation.name_align, `hero.presentation.heroes[${index}].name_align`);
    presentationByHeroId.set(heroId, presentation);
  });

  const heroIds = new Set(rawConfig.cards.heroes.map((hero, index) => validateString(hero.id, `cards.heroes[${index}].id`)));
  presentationByHeroId.forEach((presentation, heroId) => {
    if (!heroIds.has(heroId)) {
      fail(`hero.presentation references unknown hero_id "${heroId}"`);
    }
  });

  const presentations = rawConfig.cards.heroes.map((hero, index) => {
    const heroId = validateString(hero.id, `cards.heroes[${index}].id`);
    const presentation = presentationByHeroId.get(heroId);
    if (presentation === undefined) {
      fail(`hero.presentation is missing hero_id "${heroId}"`);
    }
    return `hero_presentation{${bendString(heroId)}, ${renderPresentationAlign(presentation.name_align, `hero.presentation["${heroId}"].name_align`)}, ${bendString(presentation.ultimate_title)}, ${bendString(presentation.ultimate_icon)}, ${bendString(presentation.ultimate_description)}}`;
  });

  return [
    "import /Dungeon/HeroPresentation as HeroPresentation",
    "import /Dungeon/PresentationAlign as PresentationAlign",
    "",
    "def generated_hero_presentation() -> List(HeroPresentation):",
    `  ${bendList(presentations, 2)}`,
    "",
  ].join("\n");
}

async function generateDungeonConfig(cwd: string): Promise<void> {
  const dataPath = path.resolve(cwd, "data/dungeon.config.json");
  const presentationPath = path.resolve(cwd, "data/hero.presentation.json");
  const outPath = path.resolve(cwd, "src/Dungeon/generated_config.bend");
  const presentationOutPath = path.resolve(cwd, "src/Dungeon/generated_hero_presentation.bend");
  const raw = (await Bun.file(dataPath).json()) as RawDungeonConfig;
  const rawPresentation = (await Bun.file(presentationPath).json()) as RawHeroPresentationConfig;
  await Bun.write(outPath, renderConfigModule(raw));
  await Bun.write(presentationOutPath, renderHeroPresentationModule(raw, rawPresentation));
}

function patchAppRuntime(html: string): string {
  const childPatchBuggy = [
    "    var nxt = __app_patch(kid, prev.kids[i], next.kids[i], dispatch, kidSvg);",
    "    if (nxt !== kid) {",
      "      dom.replaceChild(nxt, kid);",
    "    }",
  ].join("\n");

  const childPatchFixed = [
    "    var nxt = __app_patch(kid, prev.kids[i], next.kids[i], dispatch, kidSvg);",
    "    if (nxt !== kid && kid.parentNode === dom) {",
    "      dom.replaceChild(nxt, kid);",
    "    }",
  ].join("\n");

  const replaceBuggy = [
    "function __app_replace(dom, view, dispatch, svg) {",
    "  var nxt = __app_mount(view, dispatch, svg);",
    "  __app_dispose(dom);",
    "  dom.replaceWith(nxt);",
    "  return nxt;",
    "}",
  ].join("\n");

  const replaceFixed = [
    "function __app_replace(dom, view, dispatch, svg) {",
    "  var nxt = __app_mount(view, dispatch, svg);",
    "  __app_dispose(dom);",
    "  return nxt;",
    "}",
  ].join("\n");

  const stepBuggy = [
    "    dom  = __app_patch(dom, view, next, step, false);",
    "    view = next;",
  ].join("\n");

  const stepFixed = [
    "    dom  = __app_patch(dom, view, next, step, false);",
    "    if (dom.parentNode !== root) {",
    "      root.replaceChildren(dom);",
    "    }",
    "    view = next;",
  ].join("\n");

  let out = html;
  // Bend's JS backend sometimes emits discard bindings such as `var #_$5 = x$4;`
  // which are invalid identifiers in JS and crash the app before first render.
  out = out.replace(/#_\$(\d+)/g, (_match, suffix) => `_discard_$${suffix}`);
  if (out.includes(childPatchBuggy)) {
    out = out.replace(childPatchBuggy, childPatchFixed);
  }
  if (out.includes(replaceBuggy)) {
    out = out.replace(replaceBuggy, replaceFixed);
  }
  if (out.includes(stepBuggy)) {
    out = out.replace(stepBuggy, stepFixed);
  }
  // Inject a global keydown listener so arrow keys work without clicking the
  // board first.  The listener finds the .page element and, if it is not
  // already the event target, re-dispatches the key event on it.
  const globalKeyPatch = [
    "document.addEventListener(\"keydown\", function(e) {",
    "  var page = document.querySelector(\".page\");",
    "  if (page && e.target !== page) {",
    "    page.dispatchEvent(new KeyboardEvent(\"keydown\", {",
    "      key: e.key, code: e.code, keyCode: e.keyCode,",
    "      bubbles: false, cancelable: true",
    "    }));",
    "    e.preventDefault();",
    "  }",
    "});",
  ].join("\n");

  out = out.replace("</script>", globalKeyPatch + "\n</script>");

  return out;
}

function usage(): never {
  console.error("usage: bun scripts/build.ts <input.bend> <output.html>");
  process.exit(1);
}

const input = process.argv[2];
const output = process.argv[3];

if (input === undefined || output === undefined) {
  usage();
}

const cwd = process.cwd();
const file = path.resolve(cwd, input);
const out = path.resolve(cwd, output);
const preludeDir = path.resolve(cwd, process.env.BEND_PRELUDE_DIR ?? "../Bend2/prelude");

await generateDungeonData(cwd);
const Bend = await loadPatchedBend(cwd);

const loaded = Bend.Loader.load_book(file, { prelude_dir: preludeDir, strict: true });
const ok = Bend.Core.check_book(loaded.book, {
  show_ok: false,
  write: process.stderr.write.bind(process.stderr),
});

if (!ok) {
  process.exit(1);
}

const html = patchAppRuntime(Bend.ToJS.page(loaded.book, {
  main_name: loaded.main,
  title: path.basename(file, ".bend"),
}));

await Bun.write(out, html);
