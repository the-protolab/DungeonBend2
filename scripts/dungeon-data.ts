import * as fs from "node:fs/promises";
import * as path from "node:path";

export type RawHero = {
  id: string;
  name: string;
  sprite: string;
  base_max_hp: number;
  unlock_cost: number;
  starts_unlocked: boolean;
};

export type RawHeroUpgrade = {
  hero_id: string;
  level: number;
  cost: number;
  max_hp: number;
};

export type RawMonster = {
  id: string;
  name: string;
  sprite: string;
  gold_drop: number;
  hp_by_level: number[];
};

export type RawWeapon = {
  id: string;
  name: string;
  sprite: string;
  dmg: number;
};

export type RawPotion = {
  id: string;
  name: string;
  sprite: string;
  heal: number;
};

export type RawDeckEntry = {
  card_id: string;
  count: number;
};

export type RawDecks = {
  base_deck: RawDeckEntry[];
};

export type RawPack = {
  id: string;
  name: string;
  price: number;
  reveal_count: number;
  allow_duplicates: boolean;
};

export type RawPackPoolEntry = {
  pack_id: string;
  card_id: string;
  weight: number;
};

export type RawBoosters = {
  packs: RawPack[];
  pool: RawPackPoolEntry[];
};

export type RawRules = {
  initial_seed: number;
  starting_gold: number;
  starting_selected_hero_id: string;
  starting_selection_confirmed: boolean;
  starting_dungeon_level: number;
  dungeon_level_increment_per_refill: number;
  ultimate_charge_required: number;
  ultimate_charge_per_move: number;
};

export type RawHeroPresentation = {
  hero_id: string;
  name_align: string;
  ultimate_icon: string;
};

export type RawContent = Record<string, string>;

export type GameData = {
  heroes: RawHero[];
  hero_upgrades: RawHeroUpgrade[];
  monsters: RawMonster[];
  weapons: RawWeapon[];
  potions: RawPotion[];
  decks: RawDecks;
  boosters: RawBoosters;
  rules: RawRules;
  presentation: {
    heroes: RawHeroPresentation[];
  };
  content: {
    en: RawContent;
  };
};

type CardKind = "hero" | "monster" | "weapon" | "potion";

type CardIndex = {
  kind: CardKind;
  index: number;
};

const DATA_FILES = {
  heroes: "data/game/heroes.json",
  hero_upgrades: "data/game/hero_upgrades.json",
  monsters: "data/game/monsters.json",
  weapons: "data/game/weapons.json",
  potions: "data/game/potions.json",
  decks: "data/game/decks.json",
  boosters: "data/game/boosters.json",
  rules: "data/game/rules.json",
  presentationHeroes: "data/presentation/heroes.json",
  contentEn: "data/content/en.json",
} as const;

const STATIC_CONTENT_KEYS = [
  "item.gold.name",
  "card.empty",
  "stat.hp",
  "stat.dmg",
  "stat.heal",
  "stat.gold",
  "ui.menu.start",
  "ui.menu.boosters",
  "ui.menu.back",
  "ui.menu.characters",
  "ui.topbar.gold",
  "ui.topbar.boosters",
  "ui.topbar.cards",
  "ui.dungeon.level",
  "ui.dungeon.pause",
  "ui.pause.eyebrow",
  "ui.pause.title",
  "ui.pause.body",
  "ui.pause.resume",
  "ui.hero.levelPrefixLong",
  "ui.hero.levelPrefixShort",
  "ui.hero.unarmed",
  "ui.ultimate.label",
  "ui.upgrade.maxLevel",
  "ui.upgrade.maxLevelShort",
  "ui.upgrade.upgrade",
  "ui.upgrade.upgradePrefix",
  "ui.upgrade.maxShort",
  "ui.character.locked",
  "ui.character.boosterHint",
  "ui.character.preview",
  "ui.character.equipped",
  "ui.character.buy",
  "ui.character.select",
  "ui.character.selected",
  "ui.booster.packAlt",
  "ui.booster.copiesPrefix",
  "ui.booster.done",
  "ui.booster.next",
  "ui.booster.back",
  "ui.booster.buyMorePrefix",
  "ui.booster.buyPrefix",
  "ui.booster.open",
  "ui.booster.currencySuffix",
  "ui.gameOver.resumeEyebrow",
  "ui.gameOver.resumeTitle",
  "ui.gameOver.resumeBody",
  "ui.gameOver.endEyebrow",
  "ui.gameOver.title",
  "ui.gameOver.ok",
  "ui.gameOver.resumeDungeon",
  "ui.gameOver.mainMenu",
  "fallback.monster.name",
  "fallback.weapon.name",
  "fallback.potion.name",
] as const;

function heroNameKey(heroId: string): string {
  return `hero.${heroId}.name`;
}

function heroLoreKey(heroId: string): string {
  return `hero.${heroId}.lore`;
}

function heroUltimateTitleKey(heroId: string): string {
  return `hero.${heroId}.ultimateTitle`;
}

function heroUltimateDescKey(heroId: string): string {
  return `hero.${heroId}.ultimateDesc`;
}

function monsterNameKey(id: string): string {
  return `monster.${id}.name`;
}

function weaponNameKey(id: string): string {
  return `weapon.${id}.name`;
}

function potionNameKey(id: string): string {
  return `potion.${id}.name`;
}

function boosterNameKey(id: string): string {
  return `booster.${id}.name`;
}

function fail(message: string): never {
  throw new Error(`Dungeon data error: ${message}`);
}

async function readJson<T>(cwd: string, relPath: string): Promise<T> {
  return (await Bun.file(path.resolve(cwd, relPath)).json()) as T;
}

function jsonBlock(value: unknown): string {
  return `${JSON.stringify(value, null, 2)}\n`;
}

async function readGameDataFiles(cwd: string): Promise<GameData> {
  return {
    heroes: await readJson<RawHero[]>(cwd, DATA_FILES.heroes),
    hero_upgrades: await readJson<RawHeroUpgrade[]>(cwd, DATA_FILES.hero_upgrades),
    monsters: await readJson<RawMonster[]>(cwd, DATA_FILES.monsters),
    weapons: await readJson<RawWeapon[]>(cwd, DATA_FILES.weapons),
    potions: await readJson<RawPotion[]>(cwd, DATA_FILES.potions),
    decks: await readJson<RawDecks>(cwd, DATA_FILES.decks),
    boosters: await readJson<RawBoosters>(cwd, DATA_FILES.boosters),
    rules: await readJson<RawRules>(cwd, DATA_FILES.rules),
    presentation: {
      heroes: await readJson<RawHeroPresentation[]>(cwd, DATA_FILES.presentationHeroes),
    },
    content: {
      en: await readJson<RawContent>(cwd, DATA_FILES.contentEn),
    },
  };
}

export function normalizeHeroUpgradeLevels(data: GameData): boolean {
  if (!Array.isArray(data?.heroes) || !Array.isArray(data?.hero_upgrades)) {
    return false;
  }

  let changed = false;
  data.heroes.forEach((hero) => {
    if (typeof hero?.id !== "string") {
      return;
    }
    const rows = data.hero_upgrades
      .filter((upgrade) => upgrade?.hero_id === hero.id)
      .slice()
      .sort((a, b) => {
        const left = Number.isFinite(Number(a?.level)) ? Number(a.level) : Number.MAX_SAFE_INTEGER;
        const right = Number.isFinite(Number(b?.level)) ? Number(b.level) : Number.MAX_SAFE_INTEGER;
        return left - right;
      });
    rows.forEach((upgrade, index) => {
      const nextLevel = index + 1;
      if (upgrade.level !== nextLevel) {
        upgrade.level = nextLevel;
        changed = true;
      }
    });
  });
  return changed;
}

export async function loadGameData(cwd: string): Promise<GameData> {
  const data = await readGameDataFiles(cwd);
  assertValidGameData(data);
  return data;
}

export async function loadGameDataForEditor(cwd: string): Promise<{ data: GameData; normalizedHeroUpgradeLevels: boolean }> {
  const data = await readGameDataFiles(cwd);
  const normalizedHeroUpgradeLevels = normalizeHeroUpgradeLevels(data);
  assertValidGameData(data);
  return { data, normalizedHeroUpgradeLevels };
}

export async function writeGameData(cwd: string, data: GameData): Promise<void> {
  assertValidGameData(data);
  await fs.mkdir(path.resolve(cwd, "data/game"), { recursive: true });
  await fs.mkdir(path.resolve(cwd, "data/presentation"), { recursive: true });
  await fs.mkdir(path.resolve(cwd, "data/content"), { recursive: true });
  await Promise.all([
    Bun.write(path.resolve(cwd, DATA_FILES.heroes), jsonBlock(data.heroes)),
    Bun.write(path.resolve(cwd, DATA_FILES.hero_upgrades), jsonBlock(data.hero_upgrades)),
    Bun.write(path.resolve(cwd, DATA_FILES.monsters), jsonBlock(data.monsters)),
    Bun.write(path.resolve(cwd, DATA_FILES.weapons), jsonBlock(data.weapons)),
    Bun.write(path.resolve(cwd, DATA_FILES.potions), jsonBlock(data.potions)),
    Bun.write(path.resolve(cwd, DATA_FILES.decks), jsonBlock(data.decks)),
    Bun.write(path.resolve(cwd, DATA_FILES.boosters), jsonBlock(data.boosters)),
    Bun.write(path.resolve(cwd, DATA_FILES.rules), jsonBlock(data.rules)),
    Bun.write(path.resolve(cwd, DATA_FILES.presentationHeroes), jsonBlock(data.presentation.heroes)),
    Bun.write(path.resolve(cwd, DATA_FILES.contentEn), jsonBlock(data.content.en)),
  ]);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isPositiveInt(value: unknown): value is number {
  return Number.isInteger(value) && Number(value) > 0;
}

function isNonNegativeInt(value: unknown): value is number {
  return Number.isInteger(value) && Number(value) >= 0;
}

function addStringError(errors: string[], value: unknown, label: string): void {
  if (typeof value !== "string" || value.trim() === "") {
    errors.push(`${label} must be a non-empty string`);
  }
}

function addPositiveIntError(errors: string[], value: unknown, label: string): void {
  if (!isPositiveInt(value)) {
    errors.push(`${label} must be a positive integer`);
  }
}

function addNonNegativeIntError(errors: string[], value: unknown, label: string): void {
  if (!isNonNegativeInt(value)) {
    errors.push(`${label} must be a non-negative integer`);
  }
}

function addBooleanError(errors: string[], value: unknown, label: string): void {
  if (typeof value !== "boolean") {
    errors.push(`${label} must be true or false`);
  }
}

function uniqueId(errors: string[], ids: Set<string>, id: unknown, label: string): void {
  addStringError(errors, id, label);
  if (typeof id !== "string" || id.trim() === "") {
    return;
  }
  if (ids.has(id)) {
    errors.push(`duplicate id "${id}" in ${label}`);
  }
  ids.add(id);
}

function requireArray<T>(errors: string[], value: T[] | unknown, label: string): T[] {
  if (!Array.isArray(value)) {
    errors.push(`${label} must be a list`);
    return [];
  }
  return value as T[];
}

function requireContent(data: GameData, key: string, label = `content.en["${key}"]`): string {
  const value = data.content?.en?.[key];
  if (typeof value !== "string" || value.trim() === "") {
    fail(`${label} must be a non-empty string`);
  }
  return value;
}

function requiredContentKeys(data: GameData): string[] {
  const keys = new Set<string>(STATIC_CONTENT_KEYS);
  (Array.isArray(data.heroes) ? data.heroes : []).forEach((hero) => {
    if (typeof hero?.id === "string" && hero.id.trim() !== "") {
      keys.add(heroNameKey(hero.id));
      keys.add(heroLoreKey(hero.id));
      keys.add(heroUltimateTitleKey(hero.id));
      keys.add(heroUltimateDescKey(hero.id));
    }
  });
  (Array.isArray(data.monsters) ? data.monsters : []).forEach((monster) => {
    if (typeof monster?.id === "string" && monster.id.trim() !== "") {
      keys.add(monsterNameKey(monster.id));
    }
  });
  (Array.isArray(data.weapons) ? data.weapons : []).forEach((weapon) => {
    if (typeof weapon?.id === "string" && weapon.id.trim() !== "") {
      keys.add(weaponNameKey(weapon.id));
    }
  });
  (Array.isArray(data.potions) ? data.potions : []).forEach((potion) => {
    if (typeof potion?.id === "string" && potion.id.trim() !== "") {
      keys.add(potionNameKey(potion.id));
    }
  });
  (Array.isArray(data.boosters?.packs) ? data.boosters.packs : []).forEach((pack) => {
    if (typeof pack?.id === "string" && pack.id.trim() !== "") {
      keys.add(boosterNameKey(pack.id));
    }
  });
  return [...keys].sort();
}

function addContentErrors(errors: string[], data: GameData): void {
  if (!isRecord(data.content)) {
    errors.push("content must be an object");
    return;
  }
  if (!isRecord(data.content.en)) {
    errors.push("content.en must be an object");
    return;
  }
  requiredContentKeys(data).forEach((key) => {
    addStringError(errors, data.content.en[key], `content.en["${key}"]`);
  });
}

export function getGameDataErrors(data: GameData): string[] {
  const errors: string[] = [];
  if (!isRecord(data)) {
    return ["game data must be an object"];
  }

  const heroes = requireArray<RawHero>(errors, data.heroes, "heroes");
  const upgrades = requireArray<RawHeroUpgrade>(errors, data.hero_upgrades, "hero_upgrades");
  const monsters = requireArray<RawMonster>(errors, data.monsters, "monsters");
  const weapons = requireArray<RawWeapon>(errors, data.weapons, "weapons");
  const potions = requireArray<RawPotion>(errors, data.potions, "potions");
  const baseDeck = requireArray<RawDeckEntry>(errors, data.decks?.base_deck, "decks.base_deck");
  const packs = requireArray<RawPack>(errors, data.boosters?.packs, "boosters.packs");
  const pool = requireArray<RawPackPoolEntry>(errors, data.boosters?.pool, "boosters.pool");
  const presentations = requireArray<RawHeroPresentation>(errors, data.presentation?.heroes, "presentation.heroes");
  addContentErrors(errors, data);

  if (heroes.length === 0) {
    errors.push("heroes must contain at least one hero");
  }
  if (monsters.length === 0) {
    errors.push("monsters must contain at least one monster");
  }
  if (baseDeck.length === 0) {
    errors.push("decks.base_deck must contain at least one entry");
  }
  if (packs.length === 0) {
    errors.push("boosters.packs must contain at least one pack");
  }

  const heroIds = new Set<string>();
  heroes.forEach((hero, index) => {
    uniqueId(errors, heroIds, hero?.id, `heroes[${index}].id`);
    addStringError(errors, hero?.name, `heroes[${index}].name`);
    addStringError(errors, hero?.sprite, `heroes[${index}].sprite`);
    addPositiveIntError(errors, hero?.base_max_hp, `heroes[${index}].base_max_hp`);
    addNonNegativeIntError(errors, hero?.unlock_cost, `heroes[${index}].unlock_cost`);
    addBooleanError(errors, hero?.starts_unlocked, `heroes[${index}].starts_unlocked`);
  });

  const cardIds = new Map<string, CardKind>();
  cardIds.set("hero", "hero");
  const pushCardId = (id: unknown, kind: CardKind, label: string) => {
    addStringError(errors, id, label);
    if (typeof id !== "string" || id.trim() === "") {
      return;
    }
    if (cardIds.has(id)) {
      errors.push(`duplicate card id "${id}" in ${label}`);
    }
    cardIds.set(id, kind);
  };

  let hpLevelCount: number | null = null;
  monsters.forEach((monster, index) => {
    pushCardId(monster?.id, "monster", `monsters[${index}].id`);
    addStringError(errors, monster?.name, `monsters[${index}].name`);
    addStringError(errors, monster?.sprite, `monsters[${index}].sprite`);
    addPositiveIntError(errors, monster?.gold_drop, `monsters[${index}].gold_drop`);
    const hpByLevel = requireArray<number>(errors, monster?.hp_by_level, `monsters[${index}].hp_by_level`);
    if (hpByLevel.length === 0) {
      errors.push(`monsters[${index}].hp_by_level must have at least one entry`);
    }
    if (hpLevelCount === null) {
      hpLevelCount = hpByLevel.length;
    } else if (hpByLevel.length !== hpLevelCount) {
      errors.push(`monsters[${index}].hp_by_level must contain ${hpLevelCount} levels`);
    }
    hpByLevel.forEach((value, levelIndex) => {
      addPositiveIntError(errors, value, `monsters[${index}].hp_by_level[${levelIndex}]`);
    });
  });

  weapons.forEach((weapon, index) => {
    pushCardId(weapon?.id, "weapon", `weapons[${index}].id`);
    addStringError(errors, weapon?.name, `weapons[${index}].name`);
    addStringError(errors, weapon?.sprite, `weapons[${index}].sprite`);
    addPositiveIntError(errors, weapon?.dmg, `weapons[${index}].dmg`);
  });

  potions.forEach((potion, index) => {
    pushCardId(potion?.id, "potion", `potions[${index}].id`);
    addStringError(errors, potion?.name, `potions[${index}].name`);
    addStringError(errors, potion?.sprite, `potions[${index}].sprite`);
    addPositiveIntError(errors, potion?.heal, `potions[${index}].heal`);
  });

  const upgradesByHero = new Map<string, RawHeroUpgrade[]>();
  upgrades.forEach((upgrade, index) => {
    addStringError(errors, upgrade?.hero_id, `hero_upgrades[${index}].hero_id`);
    if (typeof upgrade?.hero_id === "string" && !heroIds.has(upgrade.hero_id)) {
      errors.push(`hero_upgrades[${index}] references unknown hero_id "${upgrade.hero_id}"`);
    }
    addPositiveIntError(errors, upgrade?.level, `hero_upgrades[${index}].level`);
    addPositiveIntError(errors, upgrade?.cost, `hero_upgrades[${index}].cost`);
    addPositiveIntError(errors, upgrade?.max_hp, `hero_upgrades[${index}].max_hp`);
    if (typeof upgrade?.hero_id === "string") {
      const rows = upgradesByHero.get(upgrade.hero_id) ?? [];
      rows.push(upgrade);
      upgradesByHero.set(upgrade.hero_id, rows);
    }
  });

  heroes.forEach((hero) => {
    const rows = (upgradesByHero.get(hero.id) ?? []).slice().sort((a, b) => a.level - b.level);
    if (rows.length === 0) {
      errors.push(`hero "${hero.id}" must have at least one upgrade`);
    }
    rows.forEach((upgrade, index) => {
      if (upgrade.level !== index + 1) {
        errors.push(`hero "${hero.id}" upgrades must use contiguous levels starting at 1`);
      }
    });
  });

  let heroEntryCount = 0;
  baseDeck.forEach((entry, index) => {
    addStringError(errors, entry?.card_id, `decks.base_deck[${index}].card_id`);
    if (typeof entry?.card_id === "string" && !cardIds.has(entry.card_id)) {
      errors.push(`decks.base_deck[${index}] references unknown card_id "${entry.card_id}"`);
    }
    if (entry?.card_id === "hero") {
      heroEntryCount += 1;
    }
    addPositiveIntError(errors, entry?.count, `decks.base_deck[${index}].count`);
  });
  if (heroEntryCount !== 1) {
    errors.push("decks.base_deck must contain exactly one hero entry");
  }

  const packIds = new Set<string>();
  packs.forEach((pack, index) => {
    uniqueId(errors, packIds, pack?.id, `boosters.packs[${index}].id`);
    addStringError(errors, pack?.name, `boosters.packs[${index}].name`);
    addPositiveIntError(errors, pack?.price, `boosters.packs[${index}].price`);
    addPositiveIntError(errors, pack?.reveal_count, `boosters.packs[${index}].reveal_count`);
    addBooleanError(errors, pack?.allow_duplicates, `boosters.packs[${index}].allow_duplicates`);
  });

  const poolByPack = new Map<string, RawPackPoolEntry[]>();
  pool.forEach((entry, index) => {
    addStringError(errors, entry?.pack_id, `boosters.pool[${index}].pack_id`);
    addStringError(errors, entry?.card_id, `boosters.pool[${index}].card_id`);
    if (typeof entry?.pack_id === "string" && !packIds.has(entry.pack_id)) {
      errors.push(`boosters.pool[${index}] references unknown pack_id "${entry.pack_id}"`);
    }
    if (typeof entry?.card_id === "string") {
      const kind = cardIds.get(entry.card_id);
      if (kind === undefined) {
        errors.push(`boosters.pool[${index}] references unknown card_id "${entry.card_id}"`);
      } else if (kind === "hero") {
        errors.push(`boosters.pool[${index}] cannot reference the hero card`);
      }
    }
    addPositiveIntError(errors, entry?.weight, `boosters.pool[${index}].weight`);
    if (typeof entry?.pack_id === "string") {
      const rows = poolByPack.get(entry.pack_id) ?? [];
      rows.push(entry);
      poolByPack.set(entry.pack_id, rows);
    }
  });

  packs.forEach((pack) => {
    const rows = poolByPack.get(pack.id) ?? [];
    if (rows.length === 0) {
      errors.push(`booster pack "${pack.id}" is missing pool entries`);
    }
    const poolCardIds = new Set<string>();
    rows.forEach((entry) => {
      if (poolCardIds.has(entry.card_id)) {
        errors.push(`booster pack "${pack.id}" contains duplicated pool entry for "${entry.card_id}"`);
      }
      poolCardIds.add(entry.card_id);
    });
    if (!pack.allow_duplicates && rows.length < pack.reveal_count) {
      errors.push(`booster pack "${pack.id}" needs at least ${pack.reveal_count} unique pool cards`);
    }
  });

  const presentationIds = new Set<string>();
  presentations.forEach((presentation, index) => {
    addStringError(errors, presentation?.hero_id, `presentation.heroes[${index}].hero_id`);
    if (typeof presentation?.hero_id === "string") {
      if (presentationIds.has(presentation.hero_id)) {
        errors.push(`duplicate presentation for hero_id "${presentation.hero_id}"`);
      }
      presentationIds.add(presentation.hero_id);
      if (!heroIds.has(presentation.hero_id)) {
        errors.push(`presentation.heroes[${index}] references unknown hero_id "${presentation.hero_id}"`);
      }
    }
    if (!["left", "center", "right"].includes(String(presentation?.name_align))) {
      errors.push(`presentation.heroes[${index}].name_align must be "left", "center", or "right"`);
    }
    addStringError(errors, presentation?.ultimate_icon, `presentation.heroes[${index}].ultimate_icon`);
  });
  heroes.forEach((hero) => {
    if (!presentationIds.has(hero.id)) {
      errors.push(`presentation is missing hero_id "${hero.id}"`);
    }
  });

  addPositiveIntError(errors, data.rules?.initial_seed, "rules.initial_seed");
  addNonNegativeIntError(errors, data.rules?.starting_gold, "rules.starting_gold");
  addStringError(errors, data.rules?.starting_selected_hero_id, "rules.starting_selected_hero_id");
  if (typeof data.rules?.starting_selected_hero_id === "string" && !heroIds.has(data.rules.starting_selected_hero_id)) {
    errors.push(`rules.starting_selected_hero_id references unknown hero_id "${data.rules.starting_selected_hero_id}"`);
  }
  addBooleanError(errors, data.rules?.starting_selection_confirmed, "rules.starting_selection_confirmed");
  addPositiveIntError(errors, data.rules?.starting_dungeon_level, "rules.starting_dungeon_level");
  addPositiveIntError(errors, data.rules?.dungeon_level_increment_per_refill, "rules.dungeon_level_increment_per_refill");
  addPositiveIntError(errors, data.rules?.ultimate_charge_required, "rules.ultimate_charge_required");
  addPositiveIntError(errors, data.rules?.ultimate_charge_per_move, "rules.ultimate_charge_per_move");

  return errors;
}

export function assertValidGameData(data: GameData): void {
  const errors = getGameDataErrors(data);
  if (errors.length > 0) {
    fail(errors.join("\n"));
  }
}

function assetRefs(data: GameData): Array<{ label: string; value: string }> {
  return [
    ...data.heroes.map((hero, index) => ({ label: `heroes[${index}].sprite`, value: hero.sprite })),
    ...data.monsters.map((monster, index) => ({ label: `monsters[${index}].sprite`, value: monster.sprite })),
    ...data.weapons.map((weapon, index) => ({ label: `weapons[${index}].sprite`, value: weapon.sprite })),
    ...data.potions.map((potion, index) => ({ label: `potions[${index}].sprite`, value: potion.sprite })),
    ...data.presentation.heroes.map((presentation, index) => ({
      label: `presentation.heroes[${index}].ultimate_icon`,
      value: presentation.ultimate_icon,
    })),
  ];
}

async function getAssetErrors(cwd: string, data: GameData): Promise<string[]> {
  const errors: string[] = [];
  await Promise.all(
    assetRefs(data).map(async (asset) => {
      if (typeof asset.value !== "string" || asset.value.trim() === "") {
        return;
      }
      if (!asset.value.startsWith("assets/")) {
        errors.push(`${asset.label} must point to a local assets/ path`);
        return;
      }
      try {
        await fs.access(path.resolve(cwd, asset.value));
      } catch {
        errors.push(`${asset.label} points to missing asset "${asset.value}"`);
      }
    })
  );
  return errors.sort();
}

export async function getGameDataErrorsWithAssets(cwd: string, data: GameData): Promise<string[]> {
  const errors = getGameDataErrors(data);
  if (errors.length > 0) {
    return errors;
  }
  return getAssetErrors(cwd, data);
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

function contentFunctionName(key: string): string {
  const withWordBoundaries = key.replace(/([a-z0-9])([A-Z])/g, "$1_$2");
  const body = withWordBoundaries
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return body.length > 0 ? body : "unnamed";
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

function buildCardIndexes(data: GameData): Map<string, CardIndex> {
  const indexes = new Map<string, CardIndex>();
  const push = (id: string, card: CardIndex) => {
    if (indexes.has(id)) {
      fail(`duplicate card id "${id}"`);
    }
    indexes.set(id, card);
  };

  push("hero", { kind: "hero", index: 0 });
  data.monsters.forEach((monster, index) => {
    push(validateString(monster.id, `monsters[${index}].id`), { kind: "monster", index });
  });
  data.weapons.forEach((weapon, index) => {
    push(validateString(weapon.id, `weapons[${index}].id`), { kind: "weapon", index });
  });
  data.potions.forEach((potion, index) => {
    push(validateString(potion.id, `potions[${index}].id`), { kind: "potion", index });
  });

  return indexes;
}

function renderCardRef(card: CardIndex): string {
  switch (card.kind) {
    case "hero":
      return "hero_card{}";
    case "monster":
      return `monster_card{${card.index}}`;
    case "weapon":
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
    case "weapon":
      return `sword_entry{${card.index}, ${count}}`;
    case "potion":
      return `potion_entry{${card.index}, ${count}}`;
  }
}

function heroUpgradesFor(data: GameData, heroId: string): RawHeroUpgrade[] {
  return data.hero_upgrades
    .filter((upgrade) => upgrade.hero_id === heroId)
    .slice()
    .sort((a, b) => a.level - b.level);
}

export function renderConfigModule(data: GameData): string {
  assertValidGameData(data);
  const cardIndexes = buildCardIndexes(data);

  const heroes = data.heroes.map((hero, index) => {
    const heroId = validateString(hero.id, `heroes[${index}].id`);
    const heroName = requireContent(data, heroNameKey(heroId));
    validateString(hero.sprite, `heroes[${index}].sprite`);
    validatePositiveInt(hero.base_max_hp, `heroes[${index}].base_max_hp`);
    validateNonNegativeInt(hero.unlock_cost, `heroes[${index}].unlock_cost`);
    const upgrades = heroUpgradesFor(data, heroId).map((upgrade, upgradeIndex) => {
      validatePositiveInt(upgrade.cost, `hero_upgrades["${heroId}"][${upgradeIndex}].cost`);
      validatePositiveInt(upgrade.max_hp, `hero_upgrades["${heroId}"][${upgradeIndex}].max_hp`);
      return `upgrade{${upgrade.cost}, ${upgrade.max_hp}}`;
    });
    return `hero_def{${bendString(heroId)}, ${bendString(heroName)}, ${bendString(hero.sprite)}, ${hero.base_max_hp}, ${hero.unlock_cost}, ${hero.starts_unlocked ? 1 : 0}, ${bendList(upgrades, 6)}}`;
  });

  const monsterDefs = data.monsters.map((monster, index) => {
    const monsterId = validateString(monster.id, `monsters[${index}].id`);
    const monsterName = requireContent(data, monsterNameKey(monsterId));
    validateString(monster.sprite, `monsters[${index}].sprite`);
    validatePositiveInt(monster.gold_drop, `monsters[${index}].gold_drop`);
    const hpLevels = monster.hp_by_level.map((value, levelIndex) =>
      String(validatePositiveInt(value, `monsters[${index}].hp_by_level[${levelIndex}]`))
    );
    return `monster_def{${bendString(monsterName)}, ${bendString(monster.sprite)}, ${monster.gold_drop}, ${bendList(hpLevels, 6)}}`;
  });

  const swordDefs = data.weapons.map((weapon, index) => {
    const weaponId = validateString(weapon.id, `weapons[${index}].id`);
    const weaponName = requireContent(data, weaponNameKey(weaponId));
    validateString(weapon.sprite, `weapons[${index}].sprite`);
    validatePositiveInt(weapon.dmg, `weapons[${index}].dmg`);
    return `sword_def{${bendString(weaponName)}, ${bendString(weapon.sprite)}, ${weapon.dmg}}`;
  });

  const potionDefs = data.potions.map((potion, index) => {
    const potionId = validateString(potion.id, `potions[${index}].id`);
    const potionName = requireContent(data, potionNameKey(potionId));
    validateString(potion.sprite, `potions[${index}].sprite`);
    validatePositiveInt(potion.heal, `potions[${index}].heal`);
    return `potion_def{${bendString(potionName)}, ${bendString(potion.sprite)}, ${potion.heal}}`;
  });

  const baseDeck = data.decks.base_deck.map((entry, index) => {
    const cardId = validateString(entry.card_id, `decks.base_deck[${index}].card_id`);
    const card = cardIndexes.get(cardId);
    if (card === undefined) {
      fail(`decks.base_deck[${index}] references unknown card_id "${cardId}"`);
    }
    return renderDeckEntry(card, validatePositiveInt(entry.count, `decks.base_deck[${index}].count`));
  });

  const packIndexById = new Map<string, number>();
  data.boosters.packs.forEach((pack, index) => {
    const packId = validateString(pack.id, `boosters.packs[${index}].id`);
    if (packIndexById.has(packId)) {
      fail(`duplicate booster pack id "${packId}"`);
    }
    packIndexById.set(packId, index);
  });

  const packPools = new Map<string, RawPackPoolEntry[]>();
  data.boosters.pool.forEach((entry, index) => {
    const packId = validateString(entry.pack_id, `boosters.pool[${index}].pack_id`);
    const cardId = validateString(entry.card_id, `boosters.pool[${index}].card_id`);
    const card = cardIndexes.get(cardId);
    if (card === undefined) {
      fail(`boosters.pool[${index}] references unknown card_id "${cardId}"`);
    }
    if (card.kind === "hero") {
      fail(`boosters.pool[${index}] cannot reference the hero card`);
    }
    if (!packIndexById.has(packId)) {
      fail(`boosters.pool[${index}] references unknown pack_id "${packId}"`);
    }
    validatePositiveInt(entry.weight, `boosters.pool[${index}].weight`);
    const existing = packPools.get(packId) ?? [];
    if (existing.some((current) => current.card_id === cardId)) {
      fail(`pack "${packId}" contains duplicated pool entry for "${cardId}"`);
    }
    existing.push(entry);
    packPools.set(packId, existing);
  });

  const packs = data.boosters.packs.map((pack, index) => {
    const packName = requireContent(data, boosterNameKey(pack.id));
    validatePositiveInt(pack.price, `boosters.packs[${index}].price`);
    validatePositiveInt(pack.reveal_count, `boosters.packs[${index}].reveal_count`);
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
    return `pack_def{${bendString(packName)}, ${pack.price}, ${pack.reveal_count}, ${pack.allow_duplicates ? 1 : 0}, ${bendList(renderedPool, 6)}}`;
  });

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
    `    ${data.rules.starting_dungeon_level}`,
    "  }",
    "",
  ].join("\n");
}

export function renderRulesModule(data: GameData): string {
  assertValidGameData(data);
  const selectedHero = data.heroes.findIndex((hero) => hero.id === data.rules.starting_selected_hero_id);
  if (selectedHero < 0) {
    fail(`rules.starting_selected_hero_id references unknown hero_id "${data.rules.starting_selected_hero_id}"`);
  }

  return [
    "def generated_initial_seed() -> U32:",
    `  ${data.rules.initial_seed}`,
    "",
    "def generated_starting_gold() -> U32:",
    `  ${data.rules.starting_gold}`,
    "",
    "def generated_starting_selected_hero() -> U32:",
    `  ${selectedHero}`,
    "",
    "def generated_starting_selection_confirmed() -> U32:",
    `  ${data.rules.starting_selection_confirmed ? 1 : 0}`,
    "",
    "def generated_starting_dungeon_level() -> U32:",
    `  ${data.rules.starting_dungeon_level}`,
    "",
    "def generated_dungeon_level_increment_per_refill() -> U32:",
    `  ${data.rules.dungeon_level_increment_per_refill}`,
    "",
    "def generated_ultimate_charge_required() -> U32:",
    `  ${data.rules.ultimate_charge_required}`,
    "",
    "def generated_ultimate_charge_per_move() -> U32:",
    `  ${data.rules.ultimate_charge_per_move}`,
    "",
  ].join("\n");
}

export function renderHeroPresentationModule(data: GameData): string {
  assertValidGameData(data);

  const presentationByHeroId = new Map<string, RawHeroPresentation>();
  data.presentation.heroes.forEach((presentation, index) => {
    const heroId = validateString(presentation.hero_id, `presentation.heroes[${index}].hero_id`);
    if (presentationByHeroId.has(heroId)) {
      fail(`duplicate hero presentation for "${heroId}"`);
    }
    validateString(presentation.ultimate_icon, `presentation.heroes[${index}].ultimate_icon`);
    renderPresentationAlign(presentation.name_align, `presentation.heroes[${index}].name_align`);
    presentationByHeroId.set(heroId, presentation);
  });

  const presentations = data.heroes.map((hero) => {
    const presentation = presentationByHeroId.get(hero.id);
    if (presentation === undefined) {
      fail(`presentation is missing hero_id "${hero.id}"`);
    }
    const lore = requireContent(data, heroLoreKey(hero.id));
    const ultimateTitle = requireContent(data, heroUltimateTitleKey(hero.id));
    const ultimateDesc = requireContent(data, heroUltimateDescKey(hero.id));
    return `hero_presentation{${bendString(hero.id)}, ${renderPresentationAlign(presentation.name_align, `presentation["${hero.id}"].name_align`)}, ${bendString(lore)}, ${bendString(ultimateTitle)}, ${bendString(presentation.ultimate_icon)}, ${bendString(ultimateDesc)}}`;
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

export function renderContentModule(data: GameData): string {
  assertValidGameData(data);
  const keys = [...new Set([...Object.keys(data.content.en), ...requiredContentKeys(data)])].sort();
  const usedNames = new Set<string>();
  const functions = keys.map((key) => {
    let name = contentFunctionName(key);
    let suffix = 2;
    while (usedNames.has(name)) {
      name = `${contentFunctionName(key)}_${suffix}`;
      suffix += 1;
    }
    usedNames.add(name);
    return [`def ${name}() -> String:`, `  ${bendString(requireContent(data, key))}`].join("\n");
  });
  return [...functions, ""].join("\n\n");
}

export async function generateDungeonConfig(cwd: string): Promise<void> {
  const data = await loadGameData(cwd);
  await Promise.all([
    Bun.write(path.resolve(cwd, "src/Dungeon/generated_config.bend"), renderConfigModule(data)),
    Bun.write(path.resolve(cwd, "src/Dungeon/generated_hero_presentation.bend"), renderHeroPresentationModule(data)),
    Bun.write(path.resolve(cwd, "src/Dungeon/generated_rules.bend"), renderRulesModule(data)),
    Bun.write(path.resolve(cwd, "src/Dungeon/generated_content.bend"), renderContentModule(data)),
  ]);
}
