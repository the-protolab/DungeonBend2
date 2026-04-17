const tabs = [
  ["overview", "Overview"],
  ["rules", "Rules"],
  ["heroes", "Heroes"],
  ["hero_upgrades", "Hero Upgrades"],
  ["monsters", "Monsters"],
  ["weapons", "Weapons"],
  ["potions", "Potions"],
  ["base_deck", "Base Deck"],
  ["booster_packs", "Booster Packs"],
  ["booster_pool", "Booster Pool"],
  ["content", "Content"],
  ["validation", "Validation"],
];

const boosterColorTokens = ["green", "blue", "red", "yellow", "teal", "pink", "lime", "violet", "gray", "amber"];
const boosterColorSet = new Set(boosterColorTokens);

const staticContentKeys = [
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
];

const staticContentDefaults = {
  "item.gold.name": "Gold",
  "card.empty": "Empty",
  "stat.hp": "HP",
  "stat.dmg": "DMG",
  "stat.heal": "HEAL",
  "stat.gold": "GOLD",
  "ui.menu.start": "Start",
  "ui.menu.boosters": "BOOSTERS",
  "ui.menu.back": "BACK",
  "ui.menu.characters": "Characters",
  "ui.topbar.gold": "Gold",
  "ui.topbar.boosters": "Boosters",
  "ui.topbar.cards": "Cards",
  "ui.dungeon.level": "DUNGEON LEVEL",
  "ui.hero.levelPrefixLong": "Hero Lv ",
  "ui.hero.levelPrefixShort": "LV: ",
  "ui.hero.unarmed": "Unarmed",
  "ui.ultimate.label": "ULTIMATE",
  "ui.upgrade.maxLevel": "Max Level",
  "ui.upgrade.maxLevelShort": "MAX LEVEL",
  "ui.upgrade.upgrade": "UPGRADE",
  "ui.upgrade.upgradePrefix": "Upgrade - ",
  "ui.upgrade.maxShort": "MAX",
  "ui.character.locked": "LOCKED",
  "ui.character.preview": "PREVIEW",
  "ui.character.equipped": "EQUIPPED",
  "ui.character.buy": "BUY",
  "ui.character.select": "SELECT",
  "ui.character.selected": "SELECTED",
  "ui.booster.packAlt": "Booster Pack",
  "ui.booster.copiesPrefix": "COPIES: ",
  "ui.booster.done": "Done",
  "ui.booster.next": "Next",
  "ui.booster.back": "Back",
  "ui.booster.buyMorePrefix": "Buy More - ",
  "ui.booster.buyPrefix": "Buy - ",
  "ui.booster.open": "Open",
  "ui.booster.currencySuffix": "g",
  "ui.gameOver.resumeEyebrow": "Dungeon interrupted",
  "ui.gameOver.resumeTitle": "Resume run?",
  "ui.gameOver.resumeBody": "You left in the middle of this run.",
  "ui.gameOver.endEyebrow": "Run ended",
  "ui.gameOver.title": "Game Over",
  "ui.gameOver.ok": "OK",
  "ui.gameOver.resumeDungeon": "Resume dungeon",
  "ui.gameOver.mainMenu": "Main menu",
  "fallback.monster.name": "Monster",
  "fallback.weapon.name": "Sword",
  "fallback.potion.name": "Potion",
};

const state = {
  active: "overview",
  data: null,
  dirty: false,
  selectedHeroId: "",
  upgradeView: "curve",
  editorMetadata: {
    pack_colors: {},
  },
  versions: [],
  versionsOpen: false,
  assets: [],
  serverErrors: [],
  assetErrors: new Set(),
  locks: {
    heroes: new Set(),
    monsters: new Set(),
    weapons: new Set(),
    potions: new Set(),
    packs: new Set(),
  },
};

const panel = document.getElementById("panel");
const tabsNode = document.getElementById("tabs");
const statusNode = document.getElementById("status");
const saveButton = document.getElementById("save-button");
const reloadButton = document.getElementById("reload-button");
const buildButton = document.getElementById("build-button");
const versionsButton = document.getElementById("versions-button");
const versionsOverlay = document.getElementById("versions-overlay");
const versionsDrawer = document.getElementById("versions-drawer");

function setStatus(message, kind = "") {
  statusNode.textContent = message;
  statusNode.className = `status ${kind}`.trim();
}

function markDirty() {
  state.dirty = true;
  setStatus("Unsaved changes");
}

function normalizeDataShape(data) {
  data.content = data.content || {};
  data.content.en = data.content.en || {};
  data.presentation = data.presentation || {};
  data.presentation.heroes = data.presentation.heroes || [];
}

function normalizeEditorMetadataShape(metadata) {
  const packColors = metadata && typeof metadata.pack_colors === "object" && !Array.isArray(metadata.pack_colors)
    ? metadata.pack_colors
    : {};
  return {
    pack_colors: Object.fromEntries(Object.entries(packColors).filter(([, color]) => typeof color === "string")),
  };
}

function lockCurrentIds(data) {
  state.locks.heroes = new Set(data.heroes.map((row) => row.id));
  state.locks.monsters = new Set(data.monsters.map((row) => row.id));
  state.locks.weapons = new Set(data.weapons.map((row) => row.id));
  state.locks.potions = new Set(data.potions.map((row) => row.id));
  state.locks.packs = new Set(data.boosters.packs.map((row) => row.id));
}

async function loadData() {
  setStatus("Loading data...");
  const [res, assetsRes] = await Promise.all([
    fetch("/api/game-data"),
    fetch("/api/assets"),
  ]);
  const body = await res.json();
  if (!res.ok) {
    throw new Error((body.errors || ["Could not load data"]).join("\n"));
  }
  const assetsBody = assetsRes.ok ? await assetsRes.json() : { assets: [] };
  normalizeDataShape(body.data);
  state.data = body.data;
  const normalizedHeroUpgradeLevels = Boolean(body.normalizedHeroUpgradeLevels) || normalizeAllHeroUpgradeLevels();
  state.editorMetadata = normalizeEditorMetadataShape(body.editorMetadata);
  state.assets = Array.isArray(assetsBody.assets) ? assetsBody.assets : [];
  state.serverErrors = body.errors || [];
  state.assetErrors.clear();
  state.dirty = normalizedHeroUpgradeLevels;
  lockCurrentIds(state.data);
  if (!state.selectedHeroId || !heroById(state.selectedHeroId)) {
    state.selectedHeroId = state.data.heroes[0]?.id || "";
  }
  render();
  if (normalizedHeroUpgradeLevels) {
    setStatus("Hero upgrade levels were renumbered. Save to update JSON.");
  } else {
    setStatus(state.serverErrors.length > 0 ? "Data loaded with validation warnings" : "Data loaded", state.serverErrors.length > 0 ? "error" : "success");
  }
}

async function saveData() {
  if (!state.data) {
    return false;
  }
  saveButton.disabled = true;
  setStatus("Saving JSON and regenerating Bend...");
  try {
    normalizeAllHeroUpgradeLevels();
    updateLegacyNamesFromContent();
    const res = await fetch("/api/game-data", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        data: state.data,
        editorMetadata: editorMetadataForSave(),
      }),
    });
    const body = await res.json();
    state.serverErrors = body.errors || [];
    if (!res.ok || !body.ok) {
      setStatus(state.serverErrors.length > 0 ? state.serverErrors.join("\n") : "Save failed", "error");
      if (state.active === "validation") {
        render();
      }
      return false;
    }
    await loadData();
    setStatus("Saved JSON and regenerated Bend", "success");
    return true;
  } catch (err) {
    setStatus(err.message, "error");
    return false;
  } finally {
    saveButton.disabled = false;
  }
}

async function buildDocs() {
  buildButton.disabled = true;
  setStatus("Building docs...");
  try {
    const res = await fetch("/api/build-docs", { method: "POST" });
    const body = await res.json();
    if (!res.ok || !body.ok) {
      setStatus(body.output || "Build failed", "error");
      return;
    }
    setStatus(body.output || "Docs built", "success");
  } catch (err) {
    setStatus(err.message, "error");
  } finally {
    buildButton.disabled = false;
  }
}

function formatVersionDate(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value || "";
  }
  return date.toLocaleString();
}

async function loadVersions() {
  const res = await fetch("/api/versions");
  const body = await res.json();
  if (!res.ok) {
    throw new Error((body.errors || ["Could not load versions"]).join("\n"));
  }
  state.versions = Array.isArray(body.versions) ? body.versions : [];
  renderVersionsDrawer();
}

function openVersions() {
  state.versionsOpen = true;
  renderVersionsDrawer();
  loadVersions().catch((err) => setStatus(err.message, "error"));
}

function closeVersions() {
  state.versionsOpen = false;
  renderVersionsDrawer();
}

async function saveCurrentAsVersion() {
  const label = window.prompt("Version name");
  if (label === null || label.trim() === "") {
    return;
  }
  if (state.dirty) {
    const shouldSave = window.confirm("Save current editor changes before creating this version?");
    if (!shouldSave) {
      return;
    }
    const saved = await saveData();
    if (!saved) {
      return;
    }
  }
  versionsButton.disabled = true;
  setStatus("Saving version...");
  try {
    const res = await fetch("/api/versions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ label }),
    });
    const body = await res.json();
    if (!res.ok || !body.ok) {
      setStatus((body.errors || ["Could not save version"]).join("\n"), "error");
      return;
    }
    await loadVersions();
    setStatus(`Saved version: ${body.version.label}`, "success");
  } catch (err) {
    setStatus(err.message, "error");
  } finally {
    versionsButton.disabled = false;
  }
}

async function restoreVersion(version) {
  if (state.dirty) {
    const discard = window.confirm("Restore will discard unsaved editor changes. Continue?");
    if (!discard) {
      return;
    }
  }
  const confirmed = window.confirm(`Restore "${version.label}"?\n\nThis will overwrite the current JSON files and regenerate Bend.`);
  if (!confirmed) {
    return;
  }
  versionsButton.disabled = true;
  setStatus("Restoring version...");
  try {
    const res = await fetch("/api/versions/restore", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ slug: version.slug }),
    });
    const body = await res.json();
    if (!res.ok || !body.ok) {
      setStatus((body.errors || ["Could not restore version"]).join("\n"), "error");
      return;
    }
    await loadData();
    await loadVersions();
    setStatus(`Restored version: ${version.label}`, "success");
  } catch (err) {
    setStatus(err.message, "error");
  } finally {
    versionsButton.disabled = false;
  }
}

function renderVersionsDrawer() {
  versionsOverlay.hidden = !state.versionsOpen;
  versionsDrawer.hidden = !state.versionsOpen;
  if (!state.versionsOpen) {
    versionsDrawer.replaceChildren();
    return;
  }

  const header = document.createElement("div");
  header.className = "versions-header";
  const copy = document.createElement("div");
  const title = document.createElement("h2");
  title.textContent = "Versions";
  const subtitle = document.createElement("p");
  subtitle.textContent = "JSON saved versions";
  copy.append(title, subtitle);
  header.append(copy, addButton("Close", closeVersions));

  const body = document.createElement("div");
  body.className = "versions-body";
  body.append(addButton("Save current as version", saveCurrentAsVersion, "primary"));

  const list = document.createElement("div");
  list.className = "version-list";
  if (state.versions.length === 0) {
    const empty = document.createElement("p");
    empty.className = "version-empty";
    empty.textContent = "No saved versions yet.";
    list.append(empty);
  } else {
    state.versions.forEach((version) => {
      const row = document.createElement("div");
      row.className = "version-row";
      const label = document.createElement("strong");
      label.textContent = version.label;
      const date = document.createElement("span");
      date.textContent = formatVersionDate(version.created_at);
      const actions = document.createElement("div");
      actions.className = "version-actions";
      actions.append(addButton("Restore", () => restoreVersion(version)));
      row.append(label, date, actions);
      list.append(row);
    });
  }
  body.append(list);
  versionsDrawer.replaceChildren(header, body);
}

function content() {
  return state.data.content.en;
}

function heroNameKey(heroId) {
  return `hero.${heroId}.name`;
}

function heroUltimateTitleKey(heroId) {
  return `hero.${heroId}.ultimateTitle`;
}

function heroUltimateDescKey(heroId) {
  return `hero.${heroId}.ultimateDesc`;
}

function monsterNameKey(id) {
  return `monster.${id}.name`;
}

function weaponNameKey(id) {
  return `weapon.${id}.name`;
}

function potionNameKey(id) {
  return `potion.${id}.name`;
}

function boosterNameKey(id) {
  return `booster.${id}.name`;
}

function displayContent(key, fallback = "") {
  return content()[key] ?? fallback;
}

function setContent(key, value) {
  content()[key] = value;
  updateLegacyNameFromKey(key, value);
  markDirty();
}

function requiredContentKeys() {
  const keys = new Set(staticContentKeys);
  state.data.heroes.forEach((hero) => {
    keys.add(heroNameKey(hero.id));
    keys.add(heroUltimateTitleKey(hero.id));
    keys.add(heroUltimateDescKey(hero.id));
  });
  state.data.monsters.forEach((monster) => keys.add(monsterNameKey(monster.id)));
  state.data.weapons.forEach((weapon) => keys.add(weaponNameKey(weapon.id)));
  state.data.potions.forEach((potion) => keys.add(potionNameKey(potion.id)));
  state.data.boosters.packs.forEach((pack) => keys.add(boosterNameKey(pack.id)));
  return [...keys].sort();
}

function ensureContentKey(key, fallback) {
  if (typeof content()[key] !== "string" || content()[key].trim() === "") {
    content()[key] = fallback;
  }
}

function repairMissingContent(mark = false) {
  state.data.heroes.forEach((hero) => {
    ensureContentKey(heroNameKey(hero.id), hero.name || hero.id);
    ensureContentKey(heroUltimateTitleKey(hero.id), "Ultimate");
    ensureContentKey(heroUltimateDescKey(hero.id), "Refills the dungeon with new cards while keeping the hero in place.");
  });
  state.data.monsters.forEach((monster) => ensureContentKey(monsterNameKey(monster.id), monster.name || monster.id));
  state.data.weapons.forEach((weapon) => ensureContentKey(weaponNameKey(weapon.id), weapon.name || weapon.id));
  state.data.potions.forEach((potion) => ensureContentKey(potionNameKey(potion.id), potion.name || potion.id));
  state.data.boosters.packs.forEach((pack) => ensureContentKey(boosterNameKey(pack.id), pack.name || pack.id));
  staticContentKeys.forEach((key) => ensureContentKey(key, staticContentDefaults[key] ?? key));
  updateLegacyNamesFromContent();
  if (mark) {
    markDirty();
    render();
  }
}

function updateLegacyNameFromKey(key, value) {
  const hero = state.data.heroes.find((row) => key === heroNameKey(row.id));
  if (hero) {
    hero.name = value;
  }
  const monster = state.data.monsters.find((row) => key === monsterNameKey(row.id));
  if (monster) {
    monster.name = value;
  }
  const weapon = state.data.weapons.find((row) => key === weaponNameKey(row.id));
  if (weapon) {
    weapon.name = value;
  }
  const potion = state.data.potions.find((row) => key === potionNameKey(row.id));
  if (potion) {
    potion.name = value;
  }
  const pack = state.data.boosters.packs.find((row) => key === boosterNameKey(row.id));
  if (pack) {
    pack.name = value;
  }
}

function updateLegacyNamesFromContent() {
  state.data.heroes.forEach((hero) => {
    hero.name = displayContent(heroNameKey(hero.id), hero.name);
  });
  state.data.monsters.forEach((monster) => {
    monster.name = displayContent(monsterNameKey(monster.id), monster.name);
  });
  state.data.weapons.forEach((weapon) => {
    weapon.name = displayContent(weaponNameKey(weapon.id), weapon.name);
  });
  state.data.potions.forEach((potion) => {
    potion.name = displayContent(potionNameKey(potion.id), potion.name);
  });
  state.data.boosters.packs.forEach((pack) => {
    pack.name = displayContent(boosterNameKey(pack.id), pack.name);
  });
}

function heroById(heroId) {
  return state.data?.heroes.find((hero) => hero.id === heroId);
}

function packColors() {
  state.editorMetadata.pack_colors = state.editorMetadata.pack_colors || {};
  return state.editorMetadata.pack_colors;
}

function defaultPackColor(packId) {
  const index = Math.max(0, state.data.boosters.packs.findIndex((pack) => pack.id === packId));
  return boosterColorTokens[index % boosterColorTokens.length];
}

function packColor(packId) {
  return packColors()[packId] || defaultPackColor(packId);
}

function displayPackColor(packId) {
  const color = packColor(packId);
  return boosterColorSet.has(color) ? color : "gray";
}

function setPackColor(packId, color) {
  packColors()[packId] = color;
  markDirty();
}

function editorMetadataForSave() {
  const nextColors = {};
  state.data.boosters.packs.forEach((pack) => {
    nextColors[pack.id] = packColor(pack.id);
  });
  return { pack_colors: nextColors };
}

function packColorPicker(pack) {
  const currentColor = displayPackColor(pack.id);
  const wrap = document.createElement("div");
  wrap.className = "pack-color-picker";

  const trigger = document.createElement("button");
  trigger.type = "button";
  trigger.className = `pack-color-current pack-color-${currentColor}`;
  trigger.setAttribute("aria-label", `Pack color: ${currentColor}`);
  trigger.title = currentColor;
  trigger.addEventListener("click", (event) => {
    event.preventDefault();
    event.stopPropagation();
    openPackColorPalette(pack, trigger);
  });
  wrap.append(trigger);
  return wrap;
}

function closePackColorPalette() {
  document.querySelectorAll(".pack-color-palette").forEach((node) => node.remove());
  document.removeEventListener("click", closePackColorPalette);
  window.removeEventListener("resize", closePackColorPalette);
  window.removeEventListener("scroll", closePackColorPalette, true);
}

function openPackColorPalette(pack, trigger) {
  closePackColorPalette();
  const currentColor = displayPackColor(pack.id);
  const palette = document.createElement("div");
  palette.className = "pack-color-palette";
  boosterColorTokens.forEach((color) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `pack-color-swatch pack-color-${color}${color === currentColor ? " active" : ""}`;
    button.setAttribute("aria-label", color);
    button.title = color;
    button.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      setPackColor(pack.id, color);
      closePackColorPalette();
      render();
    });
    palette.append(button);
  });

  const rect = trigger.getBoundingClientRect();
  palette.style.left = `${Math.round(rect.left)}px`;
  palette.style.top = `${Math.round(rect.bottom + 6)}px`;
  document.body.append(palette);
  setTimeout(() => {
    document.addEventListener("click", closePackColorPalette);
    window.addEventListener("resize", closePackColorPalette);
    window.addEventListener("scroll", closePackColorPalette, true);
  }, 0);
}

function presentationForHero(heroId) {
  return state.data.presentation.heroes.find((row) => row.hero_id === heroId);
}

function ensureHeroPresentation(heroId) {
  let row = presentationForHero(heroId);
  if (!row) {
    row = {
      hero_id: heroId,
      name_align: "center",
      ultimate_icon: "assets/item-sword.png",
    };
    state.data.presentation.heroes.push(row);
  }
  return row;
}

function upgradesForHero(heroId) {
  return state.data.hero_upgrades
    .filter((row) => row.hero_id === heroId)
    .slice()
    .sort((a, b) => a.level - b.level);
}

function ensureHeroUpgrade(hero) {
  if (upgradesForHero(hero.id).length === 0) {
    state.data.hero_upgrades.push({
      hero_id: hero.id,
      level: 1,
      cost: 1,
      max_hp: Math.max(1, Number(hero.base_max_hp) + 1),
    });
  }
}

function ensureHeroBundle(hero) {
  ensureHeroPresentation(hero.id);
  ensureHeroUpgrade(hero);
  ensureContentKey(heroNameKey(hero.id), hero.name || "New Hero");
  ensureContentKey(heroUltimateTitleKey(hero.id), "Ultimate");
  ensureContentKey(heroUltimateDescKey(hero.id), "Refills the dungeon with new cards while keeping the hero in place.");
  updateLegacyNamesFromContent();
}

function cardIds() {
  const data = state.data;
  return [
    "hero",
    ...data.monsters.map((row) => row.id),
    ...data.weapons.map((row) => row.id),
    ...data.potions.map((row) => row.id),
  ];
}

function nonHeroCardIds() {
  return cardIds().filter((id) => id !== "hero");
}

function boosterCardOptions() {
  return [
    ...state.data.monsters.map((monster) => [
      monster.id,
      `${displayContent(monsterNameKey(monster.id), monster.name)} (Monster)`,
    ]),
    ...state.data.weapons.map((weapon) => [
      weapon.id,
      `${displayContent(weaponNameKey(weapon.id), weapon.name)} (Weapon)`,
    ]),
    ...state.data.potions.map((potion) => [
      potion.id,
      `${displayContent(potionNameKey(potion.id), potion.name)} (Potion)`,
    ]),
  ];
}

function boosterCardIds() {
  return boosterCardOptions().map(([id]) => id);
}

function uniqueId(prefix, rows) {
  let idx = rows.length + 1;
  const used = new Set(rows.map((row) => row.id));
  while (used.has(`${prefix}_${idx}`)) {
    idx += 1;
  }
  return `${prefix}_${idx}`;
}

function hpLevelCount() {
  return Math.max(1, ...state.data.monsters.map((row) => row.hp_by_level.length));
}

function heroCurveSummary(hero) {
  const rows = upgradesForHero(hero.id);
  const finalHp = rows.length > 0 ? rows[rows.length - 1].max_hp : hero.base_max_hp;
  const totalCost = rows.reduce((sum, row) => sum + (Number(row.cost) || 0), 0);
  const hpGain = finalHp - hero.base_max_hp;
  return {
    levels: rows.length,
    finalHp,
    totalCost,
    hpGain,
    avgHpCost: totalCost > 0 ? (hpGain / totalCost).toFixed(3) : "--",
  };
}

function normalizeAllHeroUpgradeLevels() {
  if (!state.data?.heroes || !state.data?.hero_upgrades) {
    return false;
  }
  let changed = false;
  state.data.heroes.forEach((hero) => {
    const rows = upgradesForHero(hero.id);
    rows.forEach((row, index) => {
      const nextLevel = index + 1;
      if (row.level !== nextLevel) {
        row.level = nextLevel;
        changed = true;
      }
    });
  });
  return changed;
}

function normalizeAndMarkHeroUpgradeLevels() {
  if (normalizeAllHeroUpgradeLevels()) {
    markDirty();
  }
}

function renderTabs() {
  tabsNode.replaceChildren();
  tabs.forEach(([id, label]) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = id === state.active ? "tab active" : "tab";
    button.textContent = label;
    button.addEventListener("click", () => {
      state.active = id;
      render();
    });
    tabsNode.append(button);
  });
}

function panelHeader(title, description, actions = []) {
  const header = document.createElement("div");
  header.className = "panel-header";

  const copy = document.createElement("div");
  const h2 = document.createElement("h2");
  h2.textContent = title;
  copy.append(h2);
  if (description) {
    const p = document.createElement("p");
    p.textContent = description;
    copy.append(p);
  }

  const toolbar = document.createElement("div");
  toolbar.className = "toolbar";
  actions.forEach((action) => toolbar.append(action));
  header.append(copy, toolbar);
  return header;
}

function addButton(label, onClick, className = "") {
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = label;
  if (className) {
    button.className = className;
  }
  button.addEventListener("click", onClick);
  return button;
}

function viewButton(label, active, onClick) {
  const button = addButton(label, onClick);
  button.className = active ? "segmented active" : "segmented";
  return button;
}

function selectInput(value, options, onChange) {
  const select = document.createElement("select");
  const normalizedOptions = options.slice();
  if (value !== undefined && value !== "" && !normalizedOptions.some(([optionValue]) => optionValue === value)) {
    normalizedOptions.unshift([value, `Unknown: ${value}`]);
  }
  normalizedOptions.forEach(([optionValue, label]) => {
    const option = document.createElement("option");
    option.value = optionValue;
    option.textContent = label;
    select.append(option);
  });
  select.value = value;
  if (normalizedOptions.length === 0) {
    select.disabled = true;
  }
  select.addEventListener("change", () => onChange(select.value));
  return select;
}

function assetOptions() {
  return state.assets.map((asset) => [asset, asset]);
}

function assetIsKnown(value) {
  return state.assets.length === 0 || state.assets.includes(value);
}

function textInput(value, onInput, options = {}) {
  const input = document.createElement(options.multiline ? "textarea" : "input");
  if (!options.multiline) {
    input.type = "text";
  }
  input.value = value ?? "";
  if (options.list) {
    input.setAttribute("list", options.list);
  }
  if (options.disabled) {
    input.disabled = true;
  }
  input.addEventListener("input", () => onInput(input.value));
  return input;
}

function numberInput(value, onInput, options = {}) {
  const input = document.createElement("input");
  input.type = "number";
  input.value = value ?? 0;
  if (options.disabled) {
    input.disabled = true;
  }
  input.addEventListener("input", () => onInput(Number(input.value)));
  return input;
}

function unitNumberInput(value, unit, onInput) {
  const wrap = document.createElement("div");
  wrap.className = "unit-input";
  const input = numberInput(value, onInput);
  const label = document.createElement("span");
  label.textContent = unit;
  wrap.append(input, label);
  return wrap;
}

function checkboxInput(value, onChange) {
  const input = document.createElement("input");
  input.type = "checkbox";
  input.checked = Boolean(value);
  input.addEventListener("change", () => onChange(input.checked));
  return input;
}

function field(label, control, hint = "") {
  const wrap = document.createElement("label");
  wrap.className = "field";
  const span = document.createElement("span");
  span.textContent = label;
  wrap.append(span, control);
  if (hint) {
    const note = document.createElement("small");
    note.textContent = hint;
    wrap.append(note);
  }
  return wrap;
}

function statPill(label, value) {
  const item = document.createElement("div");
  item.className = "metric compact";
  const strong = document.createElement("strong");
  strong.textContent = value;
  const span = document.createElement("span");
  span.textContent = label;
  item.append(strong, span);
  return item;
}

function overviewLinkPill(label, value, targetTab) {
  const item = statPill(label, value);
  item.classList.add("overview-link");
  item.tabIndex = 0;
  item.role = "button";
  item.setAttribute("aria-label", `Open ${label}`);
  item.addEventListener("click", () => {
    state.active = targetTab;
    render();
  });
  item.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      state.active = targetTab;
      render();
    }
  });
  return item;
}

function valueFor(row, column) {
  if (column.get) {
    return column.get(row);
  }
  return row[column.key];
}

function setValue(row, column, value) {
  if (column.set) {
    column.set(row, value);
  } else {
    row[column.key] = value;
  }
  markDirty();
}

function applyCellValidity(input, row, column) {
  if (!column.invalid) {
    return;
  }
  const message = column.invalid(row, valueFor(row, column));
  input.classList.toggle("invalid-input", Boolean(message));
  input.title = message || "";
}

function cellInput(row, column) {
  const value = valueFor(row, column);
  const inputType = typeof column.type === "function" ? column.type(row) : column.type;
  const listId = typeof column.list === "function" ? column.list(row) : column.list;
  const options = typeof column.options === "function" ? column.options(row) : column.options;
  if (inputType === "checkbox") {
    const input = checkboxInput(value, (next) => {
      setValue(row, column, next);
      applyCellValidity(input, row, column);
    });
    applyCellValidity(input, row, column);
    return input;
  }

  if (inputType === "select") {
    const input = selectInput(value, options || [], (next) => {
      setValue(row, column, next);
      applyCellValidity(input, row, column);
    });
    if (column.locked && column.locked(row)) {
      input.disabled = true;
    }
    applyCellValidity(input, row, column);
    return input;
  }

  const input = inputType === "number"
    ? numberInput(value, (next) => {
        setValue(row, column, next);
        applyCellValidity(input, row, column);
      })
    : textInput(value, (next) => {
        setValue(row, column, next);
        applyCellValidity(input, row, column);
      }, { multiline: inputType === "textarea", list: listId, disabled: column.locked && column.locked(row) });
  if (inputType === "number" && column.locked && column.locked(row)) {
    input.disabled = true;
  }
  applyCellValidity(input, row, column);
  return input;
}

function spriteCell(row, column) {
  const wrap = document.createElement("div");
  wrap.className = "sprite-cell";
  const input = selectInput(valueFor(row, column) || "", assetOptions(), (next) => {
    setValue(row, column, next);
    img.style.visibility = "visible";
    img.src = next;
    input.classList.toggle("invalid-input", !assetIsKnown(next));
    input.title = assetIsKnown(next) ? "" : `Unknown asset: ${next}`;
  });
  if (column.locked && column.locked(row)) {
    input.disabled = true;
  }
  input.classList.toggle("invalid-input", !assetIsKnown(valueFor(row, column)));
  input.title = assetIsKnown(valueFor(row, column)) ? "" : `Unknown asset: ${valueFor(row, column)}`;
  const img = document.createElement("img");
  img.className = "sprite-preview";
  img.alt = "";
  img.src = valueFor(row, column) || "";
  img.addEventListener("error", () => {
    img.style.visibility = "hidden";
    input.classList.add("invalid-input");
    input.title = `Asset did not load: ${input.value}`;
    state.assetErrors.add(`Asset did not load: ${input.value}`);
  });
  wrap.append(input, img);
  return wrap;
}

function renderTable(title, description, rows, columns, actions = [], noteText = "Existing IDs are locked. Add new rows at the end to preserve save compatibility.") {
  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader(title, description, actions));

  const wrap = document.createElement("div");
  wrap.className = "table-wrap";
  const table = document.createElement("table");
  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  columns.forEach((column) => {
    const th = document.createElement("th");
    th.textContent = column.label;
    headRow.append(th);
  });
  thead.append(headRow);

  const tbody = document.createElement("tbody");
  rows.forEach((row) => {
    const tr = document.createElement("tr");
    columns.forEach((column) => {
      const td = document.createElement("td");
      if (column.render) {
        td.append(column.render(row));
      } else {
        td.append(column.type === "sprite" ? spriteCell(row, column) : cellInput(row, column));
      }
      tr.append(td);
    });
    tbody.append(tr);
  });

  table.append(thead, tbody);
  wrap.append(table);
  fragment.append(wrap);

  if (noteText) {
    const note = document.createElement("p");
    note.className = "note";
    note.textContent = noteText;
    fragment.append(note);
  }
  panel.replaceChildren(fragment);
}

function renderOverview() {
  const data = state.data;
  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader("Overview", "Current data shape and editable lever groups"));
  const issues = validationIssues();
  const grid = document.createElement("div");
  grid.className = "grid";
  [
    ["Heroes", data.heroes.length, "heroes"],
    ["Hero upgrades", data.hero_upgrades.length, "hero_upgrades"],
    ["Monsters", data.monsters.length, "monsters"],
    ["Weapons", data.weapons.length, "weapons"],
    ["Potions", data.potions.length, "potions"],
    ["Base deck rows", data.decks.base_deck.length, "base_deck"],
    ["Booster packs", data.boosters.packs.length, "booster_packs"],
    ["Booster pool rows", data.boosters.pool.length, "booster_pool"],
    ["Content keys", Object.keys(content()).length, "content"],
    ["Validation issues", issues.length, "validation"],
  ].forEach(([label, value, targetTab]) => grid.append(overviewLinkPill(label, value, targetTab)));
  fragment.append(grid);
  const note = document.createElement("p");
  note.className = "note";
  note.textContent = "Save writes the split JSON files and regenerates the Bend config modules. Build docs regenerates data before compiling.";
  fragment.append(note);
  panel.replaceChildren(fragment);
}

function renderRules() {
  const rows = [
    { key: "initial_seed", label: "Initial Seed", type: "number" },
    { key: "starting_gold", label: "Starting Gold", type: "number" },
    {
      key: "starting_selected_hero_id",
      label: "Starting Hero",
      type: "select",
      options: () => state.data.heroes.map((hero) => [hero.id, `${displayContent(heroNameKey(hero.id), hero.name)} (${hero.id})`]),
    },
    { key: "starting_selection_confirmed", label: "Selection Confirmed", type: "checkbox" },
    { key: "starting_dungeon_level", label: "Starting Dungeon Level", type: "number" },
    { key: "dungeon_level_increment_per_refill", label: "Dungeon Level Increment Per Refill", type: "number" },
    { key: "ultimate_charge_required", label: "Ultimate Charge Required", type: "number" },
    { key: "ultimate_charge_per_move", label: "Ultimate Charge Per Move", type: "number" },
  ];

  const tableRows = rows.map((row) => ({
    key: row.key,
    label: row.label,
    type: row.type,
    options: row.options,
  }));

  renderTable(
    "Rules",
    "Global balance rules promoted from hardcoded values",
    tableRows,
    [
      { label: "Rule", key: "label" },
      {
        label: "Value",
        key: "key",
        type: (row) => row.type,
        options: (row) => (typeof row.options === "function" ? row.options(row) : row.options),
        get: (row) => state.data.rules[row.key],
        set: (row, value) => {
          state.data.rules[row.key] = row.type === "number" ? Number(value) : value;
        },
        invalid: (row, value) => (row.key === "starting_selected_hero_id" && !heroById(value) ? "Unknown hero id" : ""),
      },
    ],
    [],
    ""
  );
}

function renameHeroId(hero, nextId) {
  const previousId = hero.id;
  if (previousId === nextId) {
    return;
  }
  hero.id = nextId;
  state.data.hero_upgrades.forEach((upgrade) => {
    if (upgrade.hero_id === previousId) {
      upgrade.hero_id = nextId;
    }
  });
  const presentation = presentationForHero(previousId);
  if (presentation) {
    presentation.hero_id = nextId;
  }
  if (state.data.rules.starting_selected_hero_id === previousId) {
    state.data.rules.starting_selected_hero_id = nextId;
  }
  moveContentKey(heroNameKey(previousId), heroNameKey(nextId), hero.name || nextId);
  moveContentKey(heroUltimateTitleKey(previousId), heroUltimateTitleKey(nextId), "Ultimate");
  moveContentKey(heroUltimateDescKey(previousId), heroUltimateDescKey(nextId), "Refills the dungeon with new cards while keeping the hero in place.");
  if (state.selectedHeroId === previousId) {
    state.selectedHeroId = nextId;
  }
}

function renameCardId(row, nextId, keyForId) {
  const previousId = row.id;
  if (previousId === nextId) {
    return;
  }
  row.id = nextId;
  state.data.decks.base_deck.forEach((entry) => {
    if (entry.card_id === previousId) {
      entry.card_id = nextId;
    }
  });
  state.data.boosters.pool.forEach((entry) => {
    if (entry.card_id === previousId) {
      entry.card_id = nextId;
    }
  });
  moveContentKey(keyForId(previousId), keyForId(nextId), row.name || nextId);
}

function renamePackId(pack, nextId) {
  const previousId = pack.id;
  if (previousId === nextId) {
    return;
  }
  const previousColor = packColor(previousId);
  pack.id = nextId;
  state.data.boosters.pool.forEach((entry) => {
    if (entry.pack_id === previousId) {
      entry.pack_id = nextId;
    }
  });
  moveContentKey(boosterNameKey(previousId), boosterNameKey(nextId), pack.name || nextId);
  packColors()[nextId] = previousColor;
  delete packColors()[previousId];
}

function moveContentKey(from, to, fallback) {
  if (from === to) {
    return;
  }
  content()[to] = content()[from] ?? fallback;
  delete content()[from];
}

function renderHeroes() {
  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader("Heroes", "Character setup, art, ultimate icon, and upgrade summaries", [
    addButton("Add hero", () => {
      const id = uniqueId("hero", state.data.heroes);
      const hero = {
        id,
        name: "New Hero",
        sprite: "assets/player-boy.png",
        base_max_hp: 1,
        unlock_cost: 0,
        starts_unlocked: false,
      };
      state.data.heroes.push(hero);
      state.selectedHeroId = id;
      ensureHeroBundle(hero);
      markDirty();
      render();
    }, "primary"),
  ]));

  const list = document.createElement("div");
  list.className = "entity-list";
  state.data.heroes.forEach((hero) => {
    ensureHeroBundle(hero);
    const presentation = ensureHeroPresentation(hero.id);
    const summary = heroCurveSummary(hero);
    const card = document.createElement("section");
    card.className = "entity-card";

    const header = document.createElement("div");
    header.className = "entity-card__header";
    const title = document.createElement("h3");
    title.textContent = displayContent(heroNameKey(hero.id), hero.name);
    const meta = document.createElement("span");
    meta.textContent = hero.starts_unlocked ? "Unlocked" : "Locked";
    header.append(title, meta);

    const fields = document.createElement("div");
    fields.className = "field-grid";
    fields.append(
      field("id", textInput(hero.id, (value) => {
        renameHeroId(hero, value);
        markDirty();
        render();
      }, { disabled: state.locks.heroes.has(hero.id) })),
      field("display name", textInput(displayContent(heroNameKey(hero.id), hero.name), (value) => setContent(heroNameKey(hero.id), value))),
      field("sprite", spriteInlineInput(hero.sprite, (value) => {
        hero.sprite = value;
        markDirty();
      })),
      field("base_max_hp", numberInput(hero.base_max_hp, (value) => {
        hero.base_max_hp = value;
        markDirty();
        render();
      })),
      field("unlock_cost", numberInput(hero.unlock_cost, (value) => {
        hero.unlock_cost = value;
        markDirty();
      })),
      field("starts_unlocked", checkboxInput(hero.starts_unlocked, (value) => {
        hero.starts_unlocked = value;
        markDirty();
        render();
      })),
      field("ultimate_icon", spriteInlineInput(presentation.ultimate_icon, (value) => {
        presentation.ultimate_icon = value;
        markDirty();
      }))
    );

    const summaryNode = document.createElement("p");
    summaryNode.className = "note";
    summaryNode.textContent = `Content: hero.${hero.id}.* | Upgrades: ${summary.levels} levels, HP ${hero.base_max_hp} -> ${summary.finalHp}, total cost ${summary.totalCost}`;
    card.append(header, fields, summaryNode);
    list.append(card);
  });

  fragment.append(list);
  panel.replaceChildren(fragment);
}

function spriteInlineInput(value, onInput) {
  const row = { value };
  return spriteCell(row, {
    label: "asset",
    key: "value",
    type: "sprite",
    set: (_, next) => {
      row.value = next;
      onInput(next);
    },
  });
}

function addUpgradeLevel(heroId) {
  const hero = heroById(heroId);
  const rows = upgradesForHero(heroId);
  const previous = rows[rows.length - 1];
  state.data.hero_upgrades.push({
    hero_id: heroId,
    level: rows.length + 1,
    cost: previous ? Math.max(1, previous.cost) : 1,
    max_hp: previous ? previous.max_hp + 1 : Math.max(1, Number(hero?.base_max_hp) + 1),
  });
  normalizeAllHeroUpgradeLevels();
  markDirty();
  render();
}

function removeLastUpgradeLevel(heroId) {
  const rows = upgradesForHero(heroId);
  if (rows.length <= 1) {
    return;
  }
  const last = rows[rows.length - 1];
  const index = state.data.hero_upgrades.indexOf(last);
  if (index >= 0) {
    state.data.hero_upgrades.splice(index, 1);
  }
  normalizeAllHeroUpgradeLevels();
  markDirty();
  render();
}

function duplicateCurve(targetHeroId, sourceHeroId) {
  if (!sourceHeroId || sourceHeroId === targetHeroId) {
    return;
  }
  const targetHero = heroById(targetHeroId);
  const sourceHero = heroById(sourceHeroId);
  const targetName = targetHero ? displayContent(heroNameKey(targetHero.id), targetHero.name) : targetHeroId;
  const sourceName = sourceHero ? displayContent(heroNameKey(sourceHero.id), sourceHero.name) : sourceHeroId;
  const confirmed = window.confirm(`Replace ${targetName}'s upgrade curve with ${sourceName}'s curve?`);
  if (!confirmed) {
    return;
  }
  state.data.hero_upgrades = state.data.hero_upgrades.filter((row) => row.hero_id !== targetHeroId);
  upgradesForHero(sourceHeroId).forEach((row) => {
    state.data.hero_upgrades.push({
      hero_id: targetHeroId,
      level: row.level,
      cost: row.cost,
      max_hp: row.max_hp,
    });
  });
  normalizeAllHeroUpgradeLevels();
  markDirty();
  render();
}

function renderHeroUpgrades() {
  normalizeAndMarkHeroUpgradeLevels();
  if (!heroById(state.selectedHeroId)) {
    state.selectedHeroId = state.data.heroes[0]?.id || "";
  }
  const selectedHero = heroById(state.selectedHeroId);
  const actions = [
    viewButton("Edit curve", state.upgradeView === "curve", () => {
      state.upgradeView = "curve";
      render();
    }),
    viewButton("Compare heroes", state.upgradeView === "compare", () => {
      state.upgradeView = "compare";
      render();
    }),
  ];

  if (!selectedHero) {
    panel.replaceChildren(panelHeader("Hero Upgrades", "Create a hero before editing upgrade curves"));
    return;
  }

  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader("Hero Upgrades", "", actions));
  if (state.upgradeView === "compare") {
    fragment.append(renderHeroUpgradeCompare());
  } else {
    fragment.append(renderHeroUpgradeCurve(selectedHero));
  }
  panel.replaceChildren(fragment);
}

function renderHeroUpgradeCurve(hero) {
  const fragment = document.createDocumentFragment();
  const layout = document.createElement("div");
  layout.className = "hero-upgrade-layout";
  const heroName = displayContent(heroNameKey(hero.id), hero.name);
  const summary = heroCurveSummary(hero);

  const heroPicker = document.createElement("section");
  heroPicker.className = "hero-upgrade-section hero-upgrade-hero-section";
  const heroPickerTitle = document.createElement("h3");
  heroPickerTitle.textContent = "Editing";

  const heroPickerControl = document.createElement("details");
  heroPickerControl.className = "hero-upgrade-picker";
  const heroPickerSummary = document.createElement("summary");
  heroPickerSummary.className = "hero-upgrade-picker__summary";
  const heroSprite = document.createElement("img");
  heroSprite.className = "hero-upgrade-picker__sprite";
  heroSprite.src = hero.sprite;
  heroSprite.alt = "";
  const heroCopy = document.createElement("div");
  heroCopy.className = "hero-upgrade-picker__copy";
  const heroNameNode = document.createElement("strong");
  heroNameNode.textContent = heroName;
  const heroIdNode = document.createElement("span");
  heroIdNode.textContent = hero.id;
  heroCopy.append(heroNameNode, heroIdNode);
  const heroPickerMeta = document.createElement("span");
  heroPickerMeta.className = "hero-upgrade-picker__meta";
  heroPickerMeta.textContent = "Change hero";
  heroPickerSummary.append(heroSprite, heroCopy, heroPickerMeta);
  const heroPickerList = document.createElement("div");
  heroPickerList.className = "hero-upgrade-picker__list";
  state.data.heroes.forEach((row) => {
    const option = document.createElement("button");
    option.type = "button";
    option.className = row.id === hero.id ? "hero-upgrade-picker__option active" : "hero-upgrade-picker__option";
    const optionSprite = document.createElement("img");
    optionSprite.src = row.sprite;
    optionSprite.alt = "";
    const optionCopy = document.createElement("span");
    const optionName = document.createElement("strong");
    optionName.textContent = displayContent(heroNameKey(row.id), row.name);
    const optionId = document.createElement("small");
    optionId.textContent = row.id;
    optionCopy.append(optionName, optionId);
    option.append(optionSprite, optionCopy);
    option.addEventListener("click", () => {
      if (row.id === state.selectedHeroId) {
        heroPickerControl.removeAttribute("open");
        return;
      }
      state.selectedHeroId = row.id;
      render();
    });
    heroPickerList.append(option);
  });
  heroPickerControl.append(heroPickerSummary, heroPickerList);

  const heroSummary = document.createElement("div");
  heroSummary.className = "hero-upgrade-context-summary";
  [
    ["Starts", `${hero.base_max_hp} HP`],
    ["Ends", `${summary.finalHp} HP`],
    ["Total cost", `${summary.totalCost} gold`],
    ["Gain", `${summary.hpGain >= 0 ? "+" : ""}${summary.hpGain} HP`],
  ].forEach(([label, value]) => {
    const item = document.createElement("span");
    const itemLabel = document.createElement("small");
    itemLabel.textContent = label;
    const itemValue = document.createElement("strong");
    itemValue.textContent = value;
    item.append(itemLabel, itemValue);
    heroSummary.append(item);
  });

  heroPicker.append(heroPickerTitle, heroPickerControl, heroSummary);
  layout.append(heroPicker);

  const rows = upgradesForHero(hero.id);
  const tableRows = rows.map((row, index) => ({
    row,
    previousHp: index === 0 ? hero.base_max_hp : rows[index - 1].max_hp,
  }));
  const curveSection = document.createElement("section");
  curveSection.className = "hero-upgrade-section hero-upgrade-curve-section";
  const curveTitle = document.createElement("h3");
  curveTitle.textContent = `Upgrade curve for ${heroName}`;
  const curveHint = document.createElement("p");
  curveHint.className = "hero-upgrade-section-note";
  curveHint.textContent = "Edit cost and resulting max HP.";
  const wrap = document.createElement("div");
  wrap.className = "table-wrap hero-upgrade-table-wrap";
  const table = document.createElement("table");
  table.className = "hero-upgrade-table";
  const thead = document.createElement("thead");
  const head = document.createElement("tr");
  ["Upgrade", "Cost", "Max HP after upgrade", "HP gained"].forEach((label) => {
    const th = document.createElement("th");
    th.textContent = label;
    head.append(th);
  });
  thead.append(head);
  const tbody = document.createElement("tbody");
  tableRows.forEach(({ row, previousHp }) => {
    const tr = document.createElement("tr");
    const upgradeTd = document.createElement("td");
    upgradeTd.className = "hero-upgrade-read-cell";
    upgradeTd.textContent = `LV ${row.level} -> ${row.level + 1}`;

    const costTd = document.createElement("td");
    costTd.className = "hero-upgrade-edit-cell";
    costTd.append(unitNumberInput(row.cost, "gold", (value) => {
      row.cost = value;
      normalizeAllHeroUpgradeLevels();
      markDirty();
      render();
    }));

    const hpTd = document.createElement("td");
    hpTd.className = "hero-upgrade-edit-cell";
    hpTd.append(unitNumberInput(row.max_hp, "HP", (value) => {
      row.max_hp = value;
      normalizeAllHeroUpgradeLevels();
      markDirty();
      render();
    }));

    const gainTd = document.createElement("td");
    gainTd.className = "hero-upgrade-read-cell hero-upgrade-gain-cell";
    gainTd.textContent = `${row.max_hp - previousHp >= 0 ? "+" : ""}${row.max_hp - previousHp}`;

    [upgradeTd, costTd, hpTd, gainTd].forEach((td) => {
      tr.append(td);
    });
    tbody.append(tr);
  });
  table.append(thead, tbody);
  wrap.append(table);
  const tableActions = document.createElement("div");
  tableActions.className = "hero-upgrade-actions";
  tableActions.append(addButton("Add upgrade level", () => addUpgradeLevel(hero.id)));
  const removeButton = addButton("Remove last level", () => removeLastUpgradeLevel(hero.id));
  removeButton.disabled = rows.length <= 1;
  tableActions.append(removeButton);
  curveSection.append(curveTitle, curveHint, wrap, tableActions);
  layout.append(curveSection);

  const copySection = document.createElement("details");
  copySection.className = "hero-upgrade-section hero-upgrade-more-actions";
  const copySummary = document.createElement("summary");
  copySummary.textContent = "More actions";
  const copyBody = document.createElement("div");
  copyBody.className = "hero-upgrade-more-actions__body";
  const copyTitle = document.createElement("h3");
  copyTitle.textContent = "Start from another hero's curve";
  const copyNote = document.createElement("p");
  copyNote.className = "hero-upgrade-section-note";
  copyNote.textContent = `Copying replaces ${heroName}'s current upgrade curve.`;
  const copyRow = document.createElement("div");
  copyRow.className = "hero-upgrade-copy-row";
  let copyButton;
  const sourceSelect = selectInput(
    "",
    [["", "Choose hero to copy from..."], ...state.data.heroes.filter((row) => row.id !== hero.id).map((row) => [row.id, displayContent(heroNameKey(row.id), row.name)])],
    (value) => {
      if (copyButton) {
        copyButton.disabled = !value;
      }
    }
  );
  copyButton = addButton("Copy curve", () => duplicateCurve(hero.id, sourceSelect.value));
  copyButton.disabled = true;
  copyRow.append(field("Source hero", sourceSelect), copyButton);
  copyBody.append(copyTitle, copyNote, copyRow);
  copySection.append(copySummary, copyBody);
  layout.append(copySection);

  fragment.append(layout);
  return fragment;
}

function renderHeroUpgradeCompare() {
  const maxLevels = Math.max(1, ...state.data.heroes.map((hero) => upgradesForHero(hero.id).length));
  const wrap = document.createElement("div");
  wrap.className = "table-wrap";
  const table = document.createElement("table");
  const thead = document.createElement("thead");
  const head = document.createElement("tr");
  ["Hero", "Base HP", "Final HP", "Total Cost", "HP Gain"].forEach((label) => {
    const th = document.createElement("th");
    th.textContent = label;
    head.append(th);
  });
  for (let level = 1; level <= maxLevels; level += 1) {
    ["Cost", "HP"].forEach((suffix) => {
      const th = document.createElement("th");
      th.textContent = `L${level} ${suffix}`;
      head.append(th);
    });
  }
  const actionTh = document.createElement("th");
  actionTh.textContent = "Action";
  head.append(actionTh);
  thead.append(head);

  const tbody = document.createElement("tbody");
  state.data.heroes.forEach((hero) => {
    const summary = heroCurveSummary(hero);
    const rows = upgradesForHero(hero.id);
    const tr = document.createElement("tr");
    [displayContent(heroNameKey(hero.id), hero.name), hero.base_max_hp, summary.finalHp, summary.totalCost, `+${summary.hpGain}`].forEach((value) => {
      const td = document.createElement("td");
      td.textContent = value;
      tr.append(td);
    });
    for (let level = 1; level <= maxLevels; level += 1) {
      const row = rows.find((upgrade) => upgrade.level === level);
      const costTd = document.createElement("td");
      const hpTd = document.createElement("td");
      if (row) {
        costTd.textContent = row.cost;
        hpTd.textContent = row.max_hp;
      } else {
        costTd.textContent = "--";
        hpTd.textContent = "--";
      }
      tr.append(costTd, hpTd);
    }
    const actionTd = document.createElement("td");
    actionTd.append(addButton("Edit curve", () => {
      state.selectedHeroId = hero.id;
      state.upgradeView = "curve";
      render();
    }));
    tr.append(actionTd);
    tbody.append(tr);
  });
  table.append(thead, tbody);
  wrap.append(table);
  return wrap;
}

function renderMonsters() {
  const levelColumns = Array.from({ length: hpLevelCount() }, (_, index) => ({
    label: `hp_level_${index + 1}`,
    type: "number",
    get: (row) => row.hp_by_level[index] ?? 1,
    set: (row, value) => {
      row.hp_by_level[index] = Number(value);
    },
  }));
  renderTable(
    "Monsters",
    "Gold drops and HP by dungeon level",
    state.data.monsters,
    [
      {
        label: "id",
        key: "id",
        locked: (row) => state.locks.monsters.has(row.id),
        set: (row, value) => renameCardId(row, value, monsterNameKey),
      },
      {
        label: "name",
        key: "name",
        get: (row) => displayContent(monsterNameKey(row.id), row.name),
        set: (row, value) => {
          row.name = value;
          content()[monsterNameKey(row.id)] = value;
        },
      },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "gold_drop", key: "gold_drop", type: "number" },
      ...levelColumns,
    ],
    [
      addButton("Add HP level", () => {
        state.data.monsters.forEach((row) => {
          row.hp_by_level.push(row.hp_by_level[row.hp_by_level.length - 1] || 1);
        });
        markDirty();
        render();
      }),
      addButton("Add monster", () => {
        const monster = {
          id: uniqueId("monster", state.data.monsters),
          name: "New Monster",
          sprite: "assets/enemy-rat.png",
          gold_drop: 1,
          hp_by_level: Array.from({ length: hpLevelCount() }, () => 1),
        };
        state.data.monsters.push(monster);
        ensureContentKey(monsterNameKey(monster.id), monster.name);
        markDirty();
        render();
      }),
    ]
  );
}

function renderWeapons() {
  renderTable(
    "Weapons",
    "Damage values for sword cards",
    state.data.weapons,
    [
      {
        label: "id",
        key: "id",
        locked: (row) => state.locks.weapons.has(row.id),
        set: (row, value) => renameCardId(row, value, weaponNameKey),
      },
      {
        label: "name",
        key: "name",
        get: (row) => displayContent(weaponNameKey(row.id), row.name),
        set: (row, value) => {
          row.name = value;
          content()[weaponNameKey(row.id)] = value;
        },
      },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "dmg", key: "dmg", type: "number" },
    ],
    [
      addButton("Add weapon", () => {
        const weapon = {
          id: uniqueId("weapon", state.data.weapons),
          name: "Sword",
          sprite: "assets/item-sword.png",
          dmg: 1,
        };
        state.data.weapons.push(weapon);
        ensureContentKey(weaponNameKey(weapon.id), weapon.name);
        markDirty();
        render();
      }),
    ]
  );
}

function renderPotions() {
  renderTable(
    "Potions",
    "Healing values for potion cards",
    state.data.potions,
    [
      {
        label: "id",
        key: "id",
        locked: (row) => state.locks.potions.has(row.id),
        set: (row, value) => renameCardId(row, value, potionNameKey),
      },
      {
        label: "name",
        key: "name",
        get: (row) => displayContent(potionNameKey(row.id), row.name),
        set: (row, value) => {
          row.name = value;
          content()[potionNameKey(row.id)] = value;
        },
      },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "heal", key: "heal", type: "number" },
    ],
    [
      addButton("Add potion", () => {
        const potion = {
          id: uniqueId("potion", state.data.potions),
          name: "Potion",
          sprite: "assets/item-potion.png",
          heal: 1,
        };
        state.data.potions.push(potion);
        ensureContentKey(potionNameKey(potion.id), potion.name);
        markDirty();
        render();
      }),
    ]
  );
}

function renderBaseDeck() {
  renderTable(
    "Base Deck",
    "Base dungeon card counts",
    state.data.decks.base_deck,
    [
      {
        label: "card_id",
        key: "card_id",
        type: "select",
        options: () => cardIds().map((id) => [id, id]),
        locked: (row) => row.card_id === "hero",
        invalid: (_, value) => (!cardIds().includes(value) ? "Unknown card id" : ""),
      },
      { label: "count", key: "count", type: "number" },
    ],
    [
      addButton("Add deck row", () => {
        state.data.decks.base_deck.push({
          card_id: nonHeroCardIds()[0] || "hero",
          count: 1,
        });
        markDirty();
        render();
      }),
    ]
  );
}

function firstAvailablePoolCard(packId) {
  const used = new Set(state.data.boosters.pool.filter((row) => row.pack_id === packId).map((row) => row.card_id));
  const ids = boosterCardIds();
  return ids.find((id) => !used.has(id)) || ids[0] || "";
}

function renderBoosterPacks() {
  renderTable(
    "Booster Packs",
    "Pack price and reveal settings",
    state.data.boosters.packs,
    [
      {
        label: "",
        render: (pack) => packColorPicker(pack),
      },
      {
        label: "id",
        key: "id",
        locked: (row) => state.locks.packs.has(row.id),
        set: (row, value) => renamePackId(row, value),
      },
      {
        label: "name",
        key: "name",
        get: (row) => displayContent(boosterNameKey(row.id), row.name),
        set: (row, value) => {
          row.name = value;
          content()[boosterNameKey(row.id)] = value;
        },
      },
      { label: "price", key: "price", type: "number" },
      { label: "reveal_count", key: "reveal_count", type: "number" },
      { label: "allow_duplicates", key: "allow_duplicates", type: "checkbox" },
    ],
    [
      addButton("Add pack", () => {
        const pack = {
          id: uniqueId("pack", state.data.boosters.packs),
          name: "New Pack",
          price: 1,
          reveal_count: 1,
          allow_duplicates: false,
        };
        state.data.boosters.packs.push(pack);
        packColors()[pack.id] = defaultPackColor(pack.id);
        ensureContentKey(boosterNameKey(pack.id), pack.name);
        const cardId = firstAvailablePoolCard(pack.id);
        if (cardId) {
          state.data.boosters.pool.push({ pack_id: pack.id, card_id: cardId, weight: 1 });
        }
        markDirty();
        render();
      }),
    ]
  );
}

function renderBoosterPool() {
  renderTable(
    "Booster Pool",
    "Weighted cards available in each pack",
    state.data.boosters.pool,
    [
      {
        label: "",
        render: (row) => {
          const marker = document.createElement("span");
          marker.className = `pack-color-stripe pack-color-${displayPackColor(row.pack_id)}`;
          marker.title = `${row.pack_id}: ${packColor(row.pack_id)}`;
          return marker;
        },
      },
      {
        label: "pack_id",
        key: "pack_id",
        type: "select",
        options: () => state.data.boosters.packs.map((pack) => [pack.id, `${displayContent(boosterNameKey(pack.id), pack.name)} (${pack.id})`]),
        invalid: (_, value) => (!state.data.boosters.packs.some((pack) => pack.id === value) ? "Unknown pack id" : ""),
      },
      {
        label: "card_id",
        key: "card_id",
        type: "select",
        options: () => boosterCardOptions(),
        invalid: (_, value) => (!boosterCardIds().includes(value) ? "Unknown booster card id" : ""),
      },
      { label: "weight", key: "weight", type: "number" },
    ],
    [
      addButton("Add pool row", () => {
        const packId = state.data.boosters.packs[0]?.id || "";
        state.data.boosters.pool.push({
          pack_id: packId,
          card_id: firstAvailablePoolCard(packId),
          weight: 1,
        });
        markDirty();
        render();
      }),
    ]
  );
}

function renderContent() {
  const rows = Object.keys(content()).sort().map((key) => ({ key }));
  renderTable(
    "Content: en",
    "Single-locale copy source for names, labels, buttons, and descriptions",
    rows,
    [
      { label: "Key", key: "key", locked: () => true },
      {
        label: "Text",
        key: "key",
        type: (row) => (String(content()[row.key] || "").length > 64 ? "textarea" : "text"),
        get: (row) => content()[row.key],
        set: (row, value) => {
          setContent(row.key, value);
        },
      },
    ],
    [
      addButton("Repair missing keys", () => repairMissingContent(true)),
    ],
    "Content is the source for user-facing text. Visual metadata stays on the relevant editor screen."
  );
}

function validationIssues() {
  const errors = new Set(state.serverErrors);
  localValidationIssues().forEach((issue) => errors.add(issue));
  state.assetErrors.forEach((issue) => errors.add(issue));
  return [...errors].sort();
}

function localValidationIssues() {
  const issues = [];
  if (!state.data) {
    return issues;
  }
  const heroIds = new Set();
  state.data.heroes.forEach((hero) => {
    if (!hero.id) {
      issues.push("hero id must be non-empty");
    }
    if (heroIds.has(hero.id)) {
      issues.push(`duplicate hero id "${hero.id}"`);
    }
    heroIds.add(hero.id);
    if (upgradesForHero(hero.id).length === 0) {
      issues.push(`hero "${hero.id}" must have at least one upgrade`);
    }
    if (!presentationForHero(hero.id)) {
      issues.push(`presentation is missing hero_id "${hero.id}"`);
    }
  });

  state.data.hero_upgrades.forEach((upgrade) => {
    if (!heroIds.has(upgrade.hero_id)) {
      issues.push(`upgrade references unknown hero_id "${upgrade.hero_id}"`);
    }
    if (!Number.isInteger(upgrade.cost) || upgrade.cost <= 0) {
      issues.push(`upgrade for "${upgrade.hero_id}" level ${upgrade.level} must have positive cost`);
    }
    if (!Number.isInteger(upgrade.max_hp) || upgrade.max_hp <= 0) {
      issues.push(`upgrade for "${upgrade.hero_id}" level ${upgrade.level} must have positive max_hp`);
    }
  });
  state.data.heroes.forEach((hero) => {
    upgradesForHero(hero.id).forEach((upgrade, index) => {
      if (upgrade.level !== index + 1) {
        issues.push(`hero "${hero.id}" upgrades must use contiguous levels starting at 1`);
      }
    });
  });

  requiredContentKeys().forEach((key) => {
    if (typeof content()[key] !== "string" || content()[key].trim() === "") {
      issues.push(`content.en["${key}"] must be a non-empty string`);
    }
  });

  [
    ...state.data.heroes.map((row) => ["hero sprite", row.sprite]),
    ...state.data.monsters.map((row) => ["monster sprite", row.sprite]),
    ...state.data.weapons.map((row) => ["weapon sprite", row.sprite]),
    ...state.data.potions.map((row) => ["potion sprite", row.sprite]),
    ...state.data.presentation.heroes.map((row) => ["ultimate icon", row.ultimate_icon]),
  ].forEach(([label, value]) => {
    if (state.assets.length > 0 && !state.assets.includes(value)) {
      issues.push(`${label} references unknown asset "${value}"`);
    }
  });

  const cardIdSet = new Set(cardIds());
  state.data.decks.base_deck.forEach((row) => {
    if (!cardIdSet.has(row.card_id)) {
      issues.push(`base deck references unknown card_id "${row.card_id}"`);
    }
  });
  const boosterCardIdSet = new Set(boosterCardIds());
  const packIds = new Set(state.data.boosters.packs.map((pack) => pack.id));
  Object.entries(packColors()).forEach(([packId, color]) => {
    if (!packIds.has(packId)) {
      issues.push(`editor booster metadata references unknown pack_id "${packId}"`);
    }
    if (!boosterColorSet.has(color)) {
      issues.push(`editor booster metadata for "${packId}" must use a valid pack color`);
    }
  });
  const poolByPack = new Map();
  state.data.boosters.pool.forEach((row) => {
    if (!packIds.has(row.pack_id)) {
      issues.push(`booster pool references unknown pack_id "${row.pack_id}"`);
    }
    if (!boosterCardIdSet.has(row.card_id)) {
      issues.push(`booster pool references invalid card_id "${row.card_id}"`);
    }
    const key = `${row.pack_id}:${row.card_id}`;
    if (poolByPack.has(key)) {
      issues.push(`booster pack "${row.pack_id}" has duplicate pool card "${row.card_id}"`);
    }
    poolByPack.set(key, row);
  });
  state.data.boosters.packs.forEach((pack) => {
    const rows = state.data.boosters.pool.filter((row) => row.pack_id === pack.id);
    if (rows.length === 0) {
      issues.push(`booster pack "${pack.id}" is missing pool entries`);
    }
    if (!pack.allow_duplicates && rows.length < pack.reveal_count) {
      issues.push(`booster pack "${pack.id}" needs at least ${pack.reveal_count} unique pool cards`);
    }
  });
  return issues;
}

function renderValidation() {
  const issues = validationIssues();
  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader("Validation", "Current schema, reference, content, and asset checks", [
    addButton("Repair missing content", () => repairMissingContent(true)),
  ]));
  if (issues.length === 0) {
    const ok = document.createElement("p");
    ok.className = "validation-ok";
    ok.textContent = "No validation issues found.";
    fragment.append(ok);
  } else {
    const list = document.createElement("ul");
    list.className = "validation-list";
    issues.forEach((issue) => {
      const item = document.createElement("li");
      item.textContent = issue;
      list.append(item);
    });
    fragment.append(list);
  }
  panel.replaceChildren(fragment);
}

function render() {
  if (!state.data) {
    return;
  }
  normalizeDataShape(state.data);
  renderTabs();
  panel.replaceChildren();

  switch (state.active) {
    case "overview":
      renderOverview();
      break;
    case "rules":
      renderRules();
      break;
    case "heroes":
      renderHeroes();
      break;
    case "hero_upgrades":
      renderHeroUpgrades();
      break;
    case "monsters":
      renderMonsters();
      break;
    case "weapons":
      renderWeapons();
      break;
    case "potions":
      renderPotions();
      break;
    case "base_deck":
      renderBaseDeck();
      break;
    case "booster_packs":
      renderBoosterPacks();
      break;
    case "booster_pool":
      renderBoosterPool();
      break;
    case "content":
      renderContent();
      break;
    case "validation":
      renderValidation();
      break;
  }

}

saveButton.addEventListener("click", saveData);
versionsButton.addEventListener("click", openVersions);
versionsOverlay.addEventListener("click", closeVersions);
reloadButton.addEventListener("click", () => {
  loadData().catch((err) => setStatus(err.message, "error"));
});
buildButton.addEventListener("click", buildDocs);

loadData().catch((err) => setStatus(err.message, "error"));
