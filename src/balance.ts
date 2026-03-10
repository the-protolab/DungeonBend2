import "./balance.css";

import { loadNormalizedBalance, serializeBalance, validateDraftBalance } from "./game/balance-data";
import { withBase } from "./game/base-url";
import type { BalanceData, ItemData } from "./game/types";

type EditorState = {
  draft: BalanceData | null;
  original: BalanceData | null;
  loading: boolean;
  error: string | null;
  validation: string | null;
};

var appRoot = document.querySelector<HTMLDivElement>("#app");

if (appRoot === null) {
  throw new Error("app root not found");
}

var app = appRoot;

var state: EditorState = {
  draft: null,
  original: null,
  loading: true,
  error: null,
  validation: null,
};

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll("\"", "&quot;");
}

function cloneBalance(balance: BalanceData): BalanceData {
  return JSON.parse(JSON.stringify(balance)) as BalanceData;
}

function validateDraft(): void {
  if (state.draft === null) {
    state.validation = "No draft loaded.";
    return;
  }

  try {
    validateDraftBalance(state.draft);
    state.validation = null;
  } catch (error) {
    state.validation = error instanceof Error ? error.message : "Unknown validation error";
  }

  updateValidationPanel();
}

function updateValidationPanel(): void {
  var panel = document.querySelector<HTMLElement>("[data-validation]");
  var exportButton = document.querySelector<HTMLButtonElement>("[data-action='export']");

  if (panel !== null) {
    panel.textContent = state.validation === null ? "Validation passed." : state.validation;
    panel.dataset.state = state.validation === null ? "valid" : "invalid";
  }

  if (exportButton !== null) {
    exportButton.disabled = state.validation !== null;
  }
}

function heroSection(): string {
  if (state.draft === null) {
    return "";
  }

  return state.draft.heroes.map((hero, heroIndex) => `
    <section class="editor-card">
      <div class="section-head">
        <h2>Hero ${heroIndex + 1}</h2>
        <button class="text-button" data-action="remove-hero" data-hero-index="${heroIndex}">Remove Hero</button>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>ID</th><th>Name</th><th>Sprite</th><th>Base Max HP</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><input data-entity="hero" data-hero-index="${heroIndex}" data-field="id" value="${escapeHtml(hero.id)}" /></td>
            <td><input data-entity="hero" data-hero-index="${heroIndex}" data-field="name" value="${escapeHtml(hero.name)}" /></td>
            <td><input data-entity="hero" data-hero-index="${heroIndex}" data-field="sprite" value="${escapeHtml(hero.sprite)}" /></td>
            <td><input type="number" min="0" step="1" data-entity="hero" data-hero-index="${heroIndex}" data-field="baseMaxHp" value="${hero.baseMaxHp}" /></td>
          </tr>
        </tbody>
      </table>
      <div class="section-head section-head--sub">
        <h3>Upgrades</h3>
        <button class="text-button" data-action="add-upgrade" data-hero-index="${heroIndex}">Add Upgrade</button>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>Level</th><th>Cost</th><th>Max HP</th><th></th></tr>
        </thead>
        <tbody>
          ${hero.upgrades.map((upgrade, upgradeIndex) => `
            <tr>
              <td><input type="number" min="0" step="1" data-entity="upgrade" data-hero-index="${heroIndex}" data-upgrade-index="${upgradeIndex}" data-field="level" value="${upgrade.level}" /></td>
              <td><input type="number" min="0" step="1" data-entity="upgrade" data-hero-index="${heroIndex}" data-upgrade-index="${upgradeIndex}" data-field="cost" value="${upgrade.cost}" /></td>
              <td><input type="number" min="0" step="1" data-entity="upgrade" data-hero-index="${heroIndex}" data-upgrade-index="${upgradeIndex}" data-field="maxHp" value="${upgrade.maxHp}" /></td>
              <td><button class="text-button" data-action="remove-upgrade" data-hero-index="${heroIndex}" data-upgrade-index="${upgradeIndex}">Remove</button></td>
            </tr>
          `).join("")}
        </tbody>
      </table>
    </section>
  `).join("");
}

function monsterSection(): string {
  if (state.draft === null) {
    return "";
  }

  return `
    <section class="editor-card">
      <div class="section-head">
        <h2>Monsters</h2>
        <button class="text-button" data-action="add-monster">Add Monster</button>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>ID</th><th>Name</th><th>Sprite</th><th>HP Per Level</th><th>Gold Drop</th><th></th></tr>
        </thead>
        <tbody>
          ${state.draft.monsters.map((monster, index) => `
            <tr>
              <td><input data-entity="monster" data-index="${index}" data-field="id" value="${escapeHtml(monster.id)}" /></td>
              <td><input data-entity="monster" data-index="${index}" data-field="name" value="${escapeHtml(monster.name)}" /></td>
              <td><input data-entity="monster" data-index="${index}" data-field="sprite" value="${escapeHtml(monster.sprite)}" /></td>
              <td><input data-entity="monster" data-index="${index}" data-field="hpByLevel" value="${monster.hpByLevel.join(", ")}" /></td>
              <td><input type="number" min="0" step="1" data-entity="monster" data-index="${index}" data-field="goldDrop" value="${monster.goldDrop}" /></td>
              <td><button class="text-button" data-action="remove-monster" data-index="${index}">Remove</button></td>
            </tr>
          `).join("")}
        </tbody>
      </table>
    </section>
  `;
}

function itemFields(item: ItemData, index: number): string {
  if (item.kind === "sword") {
    return `<td><input type="number" min="0" step="1" data-entity="item" data-index="${index}" data-field="dmg" value="${item.dmg}" /></td>`;
  }
  if (item.kind === "potion") {
    return `<td><input type="number" min="0" step="1" data-entity="item" data-index="${index}" data-field="heal" value="${item.heal}" /></td>`;
  }
  return `<td class="sheet-table__muted">Auto</td>`;
}

function itemSection(): string {
  if (state.draft === null) {
    return "";
  }

  return `
    <section class="editor-card">
      <div class="section-head">
        <h2>Items</h2>
        <button class="text-button" data-action="add-item">Add Item</button>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>ID</th><th>Name</th><th>Kind</th><th>Sprite</th><th>Value</th><th></th></tr>
        </thead>
        <tbody>
          ${state.draft.items.map((item, index) => `
            <tr>
              <td><input data-entity="item" data-index="${index}" data-field="id" value="${escapeHtml(item.id)}" /></td>
              <td><input data-entity="item" data-index="${index}" data-field="name" value="${escapeHtml(item.name)}" /></td>
              <td>
                <select data-entity="item" data-index="${index}" data-field="kind">
                  <option value="sword" ${item.kind === "sword" ? "selected" : ""}>sword</option>
                  <option value="potion" ${item.kind === "potion" ? "selected" : ""}>potion</option>
                  <option value="gold" ${item.kind === "gold" ? "selected" : ""}>gold</option>
                </select>
              </td>
              <td><input data-entity="item" data-index="${index}" data-field="sprite" value="${escapeHtml(item.sprite)}" /></td>
              ${itemFields(item, index)}
              <td><button class="text-button" data-action="remove-item" data-index="${index}">Remove</button></td>
            </tr>
          `).join("")}
        </tbody>
      </table>
    </section>
  `;
}

function deckSection(): string {
  if (state.draft === null) {
    return "";
  }

  return `
    <section class="editor-card">
      <div class="section-head">
        <h2>Deck</h2>
        <button class="text-button" data-action="add-deck-entry">Add Deck Entry</button>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>Base Size</th><th>Card ID</th><th>Count</th><th></th></tr>
        </thead>
        <tbody>
          ${state.draft.deck.entries.map((entry, index) => `
            <tr>
              <td>${index === 0 ? `<input type="number" min="0" step="1" data-entity="deck" data-field="baseSize" value="${state.draft?.deck.baseSize ?? 0}" />` : ""}</td>
              <td><input data-entity="deck-entry" data-index="${index}" data-field="cardId" value="${escapeHtml(entry.cardId)}" /></td>
              <td><input type="number" min="0" step="1" data-entity="deck-entry" data-index="${index}" data-field="count" value="${entry.count}" /></td>
              <td><button class="text-button" data-action="remove-deck-entry" data-index="${index}">Remove</button></td>
            </tr>
          `).join("")}
        </tbody>
      </table>
    </section>
  `;
}

function economySection(): string {
  if (state.draft === null) {
    return "";
  }

  return `
    <section class="editor-card">
      <div class="section-head">
        <h2>Economy</h2>
      </div>
      <table class="sheet-table">
        <thead>
          <tr><th>Default Hero ID</th><th>Starting Gold</th><th>Starting Dungeon Level</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><input data-entity="economy" data-field="defaultHeroId" value="${escapeHtml(state.draft.economy.defaultHeroId)}" /></td>
            <td><input type="number" min="0" step="1" data-entity="economy" data-field="startingGold" value="${state.draft.economy.startingGold}" /></td>
            <td><input type="number" min="0" step="1" data-entity="economy" data-field="startingDungeonLevel" value="${state.draft.economy.startingDungeonLevel}" /></td>
          </tr>
        </tbody>
      </table>
    </section>
  `;
}

function renderLoading(): string {
  return `
    <main class="editor-shell editor-shell--loading">
      <p class="editor-eyebrow">DungeonBend Balance</p>
      <h1>Loading...</h1>
    </main>
  `;
}

function renderError(error: string): string {
  return `
    <main class="editor-shell editor-shell--loading">
      <p class="editor-eyebrow">DungeonBend Balance</p>
      <h1>Setup Error</h1>
      <p>${escapeHtml(error)}</p>
    </main>
  `;
}

function renderEditor(): string {
  return `
    <main class="editor-shell">
      <header class="editor-topbar">
        <div>
          <p class="editor-eyebrow">DungeonBend Balance</p>
          <h1>Spreadsheet Editor</h1>
        </div>
        <div class="editor-topbar__actions">
          <a class="editor-link" href="${withBase()}">Game</a>
          <button class="editor-button" data-action="reset">Reset</button>
          <button class="editor-button editor-button--primary" data-action="export">Export JSON</button>
        </div>
      </header>
      <section class="validation-panel" data-validation></section>
      <section class="editor-card">
        <div class="section-head">
          <h2>Heroes</h2>
          <button class="text-button" data-action="add-hero">Add Hero</button>
        </div>
      </section>
      ${heroSection()}
      ${monsterSection()}
      ${itemSection()}
      ${deckSection()}
      ${economySection()}
    </main>
  `;
}

function rerenderEditor(): void {
  if (state.loading) {
    app.innerHTML = renderLoading();
    return;
  }
  if (state.error !== null) {
    app.innerHTML = renderError(state.error);
    return;
  }
  app.innerHTML = renderEditor();
  updateValidationPanel();
}

function mutateHero(heroIndex: number, field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  var hero = state.draft.heroes[heroIndex];
  if (field === "baseMaxHp") {
    hero.baseMaxHp = Number(value) || 0;
    return;
  }
  if (field === "id" || field === "name" || field === "sprite") {
    (hero as Record<string, unknown>)[field] = value;
  }
}

function mutateUpgrade(heroIndex: number, upgradeIndex: number, field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  var upgrade = state.draft.heroes[heroIndex].upgrades[upgradeIndex];
  (upgrade as Record<string, unknown>)[field] = Number(value) || 0;
}

function mutateMonster(index: number, field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  var monster = state.draft.monsters[index];
  if (field === "goldDrop") {
    monster.goldDrop = Number(value) || 0;
    return;
  }
  if (field === "hpByLevel") {
    monster.hpByLevel = value.split(",").map(part => Number(part.trim())).filter(number => !Number.isNaN(number));
    return;
  }
  (monster as Record<string, unknown>)[field] = value;
}

function mutateItem(index: number, field: string, value: string): void {
  if (state.draft === null) {
    return;
  }

  var current = state.draft.items[index];

  if (field === "kind") {
    if (value === current.kind) {
      return;
    }
    if (value === "sword") {
      state.draft.items[index] = {
        id: current.id,
        name: current.name,
        kind: "sword",
        sprite: current.sprite,
        dmg: 1,
      };
    }
    if (value === "potion") {
      state.draft.items[index] = {
        id: current.id,
        name: current.name,
        kind: "potion",
        sprite: current.sprite,
        heal: 1,
      };
    }
    if (value === "gold") {
      state.draft.items[index] = {
        id: current.id,
        name: current.name,
        kind: "gold",
        sprite: current.sprite,
      };
    }
    rerenderEditor();
    validateDraft();
    return;
  }

  if (field === "id" || field === "name" || field === "sprite") {
    (current as Record<string, unknown>)[field] = value;
    return;
  }

  if (field === "dmg" && current.kind === "sword") {
    current.dmg = Number(value) || 0;
  }
  if (field === "heal" && current.kind === "potion") {
    current.heal = Number(value) || 0;
  }
}

function mutateDeck(field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  if (field === "baseSize") {
    state.draft.deck.baseSize = Number(value) || 0;
  }
}

function mutateDeckEntry(index: number, field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  var entry = state.draft.deck.entries[index];
  if (field === "count") {
    entry.count = Number(value) || 0;
    return;
  }
  entry.cardId = value;
}

function mutateEconomy(field: string, value: string): void {
  if (state.draft === null) {
    return;
  }
  if (field === "defaultHeroId") {
    state.draft.economy.defaultHeroId = value;
    return;
  }
  (state.draft.economy as Record<string, unknown>)[field] = Number(value) || 0;
}

function handleInput(target: HTMLInputElement | HTMLSelectElement): void {
  var entity = target.dataset.entity;
  var field = target.dataset.field ?? "";
  var heroIndex = Number(target.dataset.heroIndex ?? "-1");
  var upgradeIndex = Number(target.dataset.upgradeIndex ?? "-1");
  var index = Number(target.dataset.index ?? "-1");
  var value = target.value;

  if (entity === "hero") {
    mutateHero(heroIndex, field, value);
  }
  if (entity === "upgrade") {
    mutateUpgrade(heroIndex, upgradeIndex, field, value);
  }
  if (entity === "monster") {
    mutateMonster(index, field, value);
  }
  if (entity === "item") {
    mutateItem(index, field, value);
  }
  if (entity === "deck") {
    mutateDeck(field, value);
  }
  if (entity === "deck-entry") {
    mutateDeckEntry(index, field, value);
  }
  if (entity === "economy") {
    mutateEconomy(field, value);
  }

  validateDraft();
}

function addHero(): void {
  if (state.draft === null) {
    return;
  }
  state.draft.heroes.push({
    id: "hero_" + (state.draft.heroes.length + 1),
    name: "Hero",
    sprite: "hero_knight",
    baseMaxHp: 10,
    upgrades: [],
  });
}

function addUpgrade(heroIndex: number): void {
  if (state.draft === null) {
    return;
  }
  var hero = state.draft.heroes[heroIndex];
  var level = hero.upgrades.length + 1;
  hero.upgrades.push({
    level,
    cost: 10 * level,
    maxHp: hero.upgrades.length === 0 ? hero.baseMaxHp + 2 : hero.upgrades[hero.upgrades.length - 1].maxHp + 2,
  });
}

function addMonster(): void {
  if (state.draft === null) {
    return;
  }
  state.draft.monsters.push({
    id: "monster_" + (state.draft.monsters.length + 1),
    name: "Monster",
    sprite: "monster_slime",
    hpByLevel: [1, 2, 3],
    goldDrop: 1,
  });
}

function addItem(): void {
  if (state.draft === null) {
    return;
  }
  state.draft.items.push({
    id: "item_" + (state.draft.items.length + 1),
    name: "Sword",
    kind: "sword",
    sprite: "sword_bronze",
    dmg: 1,
  });
}

function addDeckEntry(): void {
  if (state.draft === null) {
    return;
  }
  state.draft.deck.entries.push({
    cardId: state.draft.heroes[0]?.id ?? "",
    count: 1,
  });
}

function exportDraft(): void {
  if (state.draft === null || state.validation !== null) {
    return;
  }
  var blob = new Blob([serializeBalance(state.draft)], { type: "application/json" });
  var url = URL.createObjectURL(blob);
  var link = document.createElement("a");
  link.href = url;
  link.download = "balance.json";
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function handleAction(action: string, element: HTMLElement): void {
  if (state.draft === null) {
    return;
  }

  if (action === "add-hero") {
    addHero();
  }
  if (action === "remove-hero") {
    state.draft.heroes.splice(Number(element.dataset.heroIndex), 1);
  }
  if (action === "add-upgrade") {
    addUpgrade(Number(element.dataset.heroIndex));
  }
  if (action === "remove-upgrade") {
    state.draft.heroes[Number(element.dataset.heroIndex)].upgrades.splice(Number(element.dataset.upgradeIndex), 1);
  }
  if (action === "add-monster") {
    addMonster();
  }
  if (action === "remove-monster") {
    state.draft.monsters.splice(Number(element.dataset.index), 1);
  }
  if (action === "add-item") {
    addItem();
  }
  if (action === "remove-item") {
    state.draft.items.splice(Number(element.dataset.index), 1);
  }
  if (action === "add-deck-entry") {
    addDeckEntry();
  }
  if (action === "remove-deck-entry") {
    state.draft.deck.entries.splice(Number(element.dataset.index), 1);
  }
  if (action === "reset" && state.original !== null) {
    state.draft = cloneBalance(state.original);
  }
  if (action === "export") {
    exportDraft();
    return;
  }

  rerenderEditor();
  validateDraft();
}

app.addEventListener("input", event => {
  var target = event.target;
  if (!(target instanceof HTMLInputElement) && !(target instanceof HTMLSelectElement)) {
    return;
  }
  handleInput(target);
});

app.addEventListener("click", event => {
  var target = event.target;
  if (!(target instanceof HTMLElement)) {
    return;
  }
  var actionTarget = target.closest<HTMLElement>("[data-action]");
  if (actionTarget === null) {
    return;
  }
  handleAction(actionTarget.dataset.action ?? "", actionTarget);
});

async function bootstrap(): Promise<void> {
  app.innerHTML = renderLoading();

  try {
    var loaded = await loadNormalizedBalance();
    var draft = cloneBalance(loaded.balance);
    state = {
      draft,
      original: cloneBalance(loaded.balance),
      loading: false,
      error: null,
      validation: null,
    };
    rerenderEditor();
    validateDraft();
  } catch (error) {
    state = {
      draft: null,
      original: null,
      loading: false,
      error: error instanceof Error ? error.message : "Unknown error",
      validation: null,
    };
    app.innerHTML = renderError(state.error ?? "Unknown error");
  }
}

void bootstrap();
