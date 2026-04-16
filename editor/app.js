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
  ["presentation", "Presentation"],
];

const state = {
  active: "overview",
  data: null,
  dirty: false,
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

function setStatus(message, kind = "") {
  statusNode.textContent = message;
  statusNode.className = `status ${kind}`.trim();
}

function markDirty() {
  state.dirty = true;
  setStatus("Unsaved changes");
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
  const res = await fetch("/api/game-data");
  const body = await res.json();
  if (!res.ok) {
    throw new Error((body.errors || ["Could not load data"]).join("\n"));
  }
  state.data = body.data;
  state.dirty = false;
  lockCurrentIds(state.data);
  render();
  setStatus("Data loaded", "success");
}

async function saveData() {
  if (!state.data) {
    return;
  }
  saveButton.disabled = true;
  setStatus("Saving JSON and regenerating Bend...");
  try {
    const res = await fetch("/api/game-data", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(state.data),
    });
    const body = await res.json();
    if (!res.ok || !body.ok) {
      setStatus((body.errors || ["Save failed"]).join("\n"), "error");
      return;
    }
    await loadData();
    setStatus("Saved JSON and regenerated Bend", "success");
  } catch (err) {
    setStatus(err.message, "error");
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

function addDatalist(root, id, values) {
  const list = document.createElement("datalist");
  list.id = id;
  values.forEach((value) => {
    const option = document.createElement("option");
    option.value = value;
    list.append(option);
  });
  root.append(list);
}

function uniqueId(prefix, rows) {
  let idx = rows.length + 1;
  const used = new Set(rows.map((row) => row.id));
  while (used.has(`${prefix}_${idx}`)) {
    idx += 1;
  }
  return `${prefix}_${idx}`;
}

function nextUpgradeLevel(heroId) {
  const levels = state.data.hero_upgrades
    .filter((row) => row.hero_id === heroId)
    .map((row) => Number(row.level) || 0);
  return Math.max(0, ...levels) + 1;
}

function hpLevelCount() {
  return Math.max(1, ...state.data.monsters.map((row) => row.hp_by_level.length));
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
  const p = document.createElement("p");
  p.textContent = description;
  copy.append(h2, p);

  const toolbar = document.createElement("div");
  toolbar.className = "toolbar";
  actions.forEach((action) => toolbar.append(action));
  header.append(copy, toolbar);
  return header;
}

function addButton(label, onClick) {
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = label;
  button.addEventListener("click", onClick);
  return button;
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

function cellInput(row, column) {
  const value = valueFor(row, column);
  const inputType = typeof column.type === "function" ? column.type(row) : column.type;
  const listId = typeof column.list === "function" ? column.list(row) : column.list;
  if (inputType === "checkbox") {
    const input = document.createElement("input");
    input.type = "checkbox";
    input.checked = Boolean(value);
    input.addEventListener("change", () => setValue(row, column, input.checked));
    return input;
  }

  if (inputType === "textarea") {
    const textarea = document.createElement("textarea");
    textarea.value = value ?? "";
    textarea.addEventListener("input", () => setValue(row, column, textarea.value));
    return textarea;
  }

  const input = document.createElement("input");
  input.type = inputType === "number" ? "number" : "text";
  input.value = value ?? "";
  if (listId) {
    input.setAttribute("list", listId);
  }
  if (column.locked && column.locked(row)) {
    input.disabled = true;
  }
  input.addEventListener("input", () => {
    const next = inputType === "number" ? Number(input.value) : input.value;
    setValue(row, column, next);
  });
  return input;
}

function spriteCell(row, column) {
  const wrap = document.createElement("div");
  wrap.className = "sprite-cell";
  const input = cellInput(row, column);
  const img = document.createElement("img");
  img.className = "sprite-preview";
  img.alt = "";
  img.src = valueFor(row, column) || "";
  img.addEventListener("error", () => {
    img.style.visibility = "hidden";
  });
  input.addEventListener("input", () => {
    img.style.visibility = "visible";
    img.src = input.value;
  });
  wrap.append(input, img);
  return wrap;
}

function renderTable(title, description, rows, columns, actions = []) {
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
      td.append(column.type === "sprite" ? spriteCell(row, column) : cellInput(row, column));
      tr.append(td);
    });
    tbody.append(tr);
  });

  table.append(thead, tbody);
  wrap.append(table);
  fragment.append(wrap);

  const note = document.createElement("p");
  note.className = "note";
  note.textContent = "Existing IDs are locked. Add new rows at the end to preserve save compatibility.";
  fragment.append(note);
  panel.replaceChildren(fragment);
}

function renderOverview() {
  const data = state.data;
  const fragment = document.createDocumentFragment();
  fragment.append(panelHeader("Overview", "Current data shape and editable lever groups"));
  const grid = document.createElement("div");
  grid.className = "grid";
  [
    ["Heroes", data.heroes.length],
    ["Hero upgrades", data.hero_upgrades.length],
    ["Monsters", data.monsters.length],
    ["Weapons", data.weapons.length],
    ["Potions", data.potions.length],
    ["Base deck rows", data.decks.base_deck.length],
    ["Booster packs", data.boosters.packs.length],
    ["Booster pool rows", data.boosters.pool.length],
    ["Dungeon levels", hpLevelCount()],
  ].forEach(([label, value]) => {
    const item = document.createElement("div");
    item.className = "metric";
    const strong = document.createElement("strong");
    strong.textContent = value;
    const span = document.createElement("span");
    span.textContent = label;
    item.append(strong, span);
    grid.append(item);
  });
  fragment.append(grid);
  const note = document.createElement("p");
  note.className = "note";
  note.textContent = "Save writes the split JSON files and regenerates the Bend config modules. Build docs is intentionally separate.";
  fragment.append(note);
  panel.replaceChildren(fragment);
}

function renderRules() {
  const rows = [
    ["initial_seed", "Initial Seed", "number"],
    ["starting_gold", "Starting Gold", "number"],
    ["starting_selected_hero_id", "Starting Hero", "text", "hero-options"],
    ["starting_selection_confirmed", "Selection Confirmed", "checkbox"],
    ["starting_dungeon_level", "Starting Dungeon Level", "number"],
    ["dungeon_level_increment_per_refill", "Dungeon Level Increment Per Refill", "number"],
    ["ultimate_charge_required", "Ultimate Charge Required", "number"],
    ["ultimate_charge_per_move", "Ultimate Charge Per Move", "number"],
  ].map(([key, label, type, list]) => ({ key, label, type, list }));

  const tableRows = rows.map((row) => ({
    key: row.key,
    label: row.label,
    type: row.type,
    list: row.list,
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
        list: (row) => row.list,
        get: (row) => state.data.rules[row.key],
        set: (row, value) => {
          state.data.rules[row.key] = row.type === "number" ? Number(value) : value;
        },
      },
    ]
  );
}

function renderHeroes() {
  renderTable(
    "Heroes",
    "Character unlock and HP levers",
    state.data.heroes,
    [
      { label: "id", key: "id", locked: (row) => state.locks.heroes.has(row.id) },
      { label: "name", key: "name" },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "base_max_hp", key: "base_max_hp", type: "number" },
      { label: "unlock_cost", key: "unlock_cost", type: "number" },
      { label: "starts_unlocked", key: "starts_unlocked", type: "checkbox" },
    ],
    [
      addButton("Add hero", () => {
        state.data.heroes.push({
          id: uniqueId("hero", state.data.heroes),
          name: "New Hero",
          sprite: "assets/player-boy.png",
          base_max_hp: 1,
          unlock_cost: 0,
          starts_unlocked: false,
        });
        markDirty();
        render();
      }),
    ]
  );
}

function renderHeroUpgrades() {
  renderTable(
    "Hero Upgrades",
    "Upgrade cost and max HP by hero level",
    state.data.hero_upgrades,
    [
      { label: "hero_id", key: "hero_id", list: "hero-options" },
      { label: "level", key: "level", type: "number" },
      { label: "cost", key: "cost", type: "number" },
      { label: "max_hp", key: "max_hp", type: "number" },
    ],
    [
      addButton("Add upgrade", () => {
        const heroId = state.data.heroes[0]?.id || "";
        state.data.hero_upgrades.push({
          hero_id: heroId,
          level: nextUpgradeLevel(heroId),
          cost: 1,
          max_hp: 1,
        });
        markDirty();
        render();
      }),
    ]
  );
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
      { label: "id", key: "id", locked: (row) => state.locks.monsters.has(row.id) },
      { label: "name", key: "name" },
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
        state.data.monsters.push({
          id: uniqueId("monster", state.data.monsters),
          name: "New Monster",
          sprite: "assets/enemy-rat.png",
          gold_drop: 1,
          hp_by_level: Array.from({ length: hpLevelCount() }, () => 1),
        });
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
      { label: "id", key: "id", locked: (row) => state.locks.weapons.has(row.id) },
      { label: "name", key: "name" },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "dmg", key: "dmg", type: "number" },
    ],
    [
      addButton("Add weapon", () => {
        state.data.weapons.push({
          id: uniqueId("weapon", state.data.weapons),
          name: "Sword",
          sprite: "assets/item-sword.png",
          dmg: 1,
        });
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
      { label: "id", key: "id", locked: (row) => state.locks.potions.has(row.id) },
      { label: "name", key: "name" },
      { label: "sprite", key: "sprite", type: "sprite" },
      { label: "heal", key: "heal", type: "number" },
    ],
    [
      addButton("Add potion", () => {
        state.data.potions.push({
          id: uniqueId("potion", state.data.potions),
          name: "Potion",
          sprite: "assets/item-potion.png",
          heal: 1,
        });
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
      { label: "card_id", key: "card_id", list: "card-options", locked: (row) => row.card_id === "hero" },
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

function renderBoosterPacks() {
  renderTable(
    "Booster Packs",
    "Pack price and reveal settings",
    state.data.boosters.packs,
    [
      { label: "id", key: "id", locked: (row) => state.locks.packs.has(row.id) },
      { label: "name", key: "name" },
      { label: "price", key: "price", type: "number" },
      { label: "reveal_count", key: "reveal_count", type: "number" },
      { label: "allow_duplicates", key: "allow_duplicates", type: "checkbox" },
    ],
    [
      addButton("Add pack", () => {
        state.data.boosters.packs.push({
          id: uniqueId("pack", state.data.boosters.packs),
          name: "New Pack",
          price: 1,
          reveal_count: 1,
          allow_duplicates: false,
        });
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
      { label: "pack_id", key: "pack_id", list: "pack-options" },
      { label: "card_id", key: "card_id", list: "nonhero-card-options" },
      { label: "weight", key: "weight", type: "number" },
    ],
    [
      addButton("Add pool row", () => {
        state.data.boosters.pool.push({
          pack_id: state.data.boosters.packs[0]?.id || "",
          card_id: nonHeroCardIds()[0] || "",
          weight: 1,
        });
        markDirty();
        render();
      }),
    ]
  );
}

function renderPresentation() {
  renderTable(
    "Presentation",
    "Text and icon fields separate from balance",
    state.data.presentation.heroes,
    [
      { label: "hero_id", key: "hero_id", list: "hero-options", locked: (row) => state.locks.heroes.has(row.hero_id) },
      { label: "name_align", key: "name_align", list: "align-options" },
      { label: "ultimate_title", key: "ultimate_title" },
      { label: "ultimate_icon", key: "ultimate_icon", type: "sprite" },
      { label: "ultimate_description", key: "ultimate_description", type: "textarea" },
    ],
    [
      addButton("Add presentation", () => {
        const missingHero = state.data.heroes.find(
          (hero) => !state.data.presentation.heroes.some((row) => row.hero_id === hero.id)
        );
        state.data.presentation.heroes.push({
          hero_id: missingHero?.id || state.data.heroes[0]?.id || "",
          name_align: "center",
          ultimate_title: "Ultimate",
          ultimate_icon: "assets/item-sword.png",
          ultimate_description: "Refills the dungeon with new cards while keeping the hero in place.",
        });
        markDirty();
        render();
      }),
    ]
  );
}

function render() {
  if (!state.data) {
    return;
  }
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
    case "presentation":
      renderPresentation();
      break;
  }

  addDatalist(panel, "hero-options", state.data.heroes.map((row) => row.id));
  addDatalist(panel, "card-options", cardIds());
  addDatalist(panel, "nonhero-card-options", nonHeroCardIds());
  addDatalist(panel, "pack-options", state.data.boosters.packs.map((row) => row.id));
  addDatalist(panel, "align-options", ["left", "center", "right"]);
}

saveButton.addEventListener("click", saveData);
reloadButton.addEventListener("click", () => {
  loadData().catch((err) => setStatus(err.message, "error"));
});
buildButton.addEventListener("click", buildDocs);

loadData().catch((err) => setStatus(err.message, "error"));
