import "./game.css";

import { resolveSprite } from "./game/assets";
import { loadNormalizedBalance } from "./game/balance-data";
import { withBase } from "./game/base-url";
import { applySwipe, startRun, upgradeHero } from "./game/core";
import { nextUpgradeCost } from "./game/normalize";
import { loadMetaState, saveMetaState } from "./game/storage";
import { bindSwipe } from "./game/swipe";
import type {
  CoreBoardTile,
  Direction,
  MetaState,
  NormalizedBalance,
  RunState,
} from "./game/types";

type AppModel = {
  balance: NormalizedBalance | null;
  meta: MetaState | null;
  run: RunState | null;
  loading: boolean;
  error: string | null;
};

var appRoot = document.querySelector<HTMLDivElement>("#app");

if (appRoot === null) {
  throw new Error("app root not found");
}

var app = appRoot;

var state: AppModel = {
  balance: null,
  meta: null,
  run: null,
  loading: true,
  error: null,
};

var cleanupSwipe: (() => void) | null = null;

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll("\"", "&quot;");
}

function heroMaxHp(balance: NormalizedBalance, heroLevel: number): number {
  if (heroLevel <= 0) {
    return balance.hero.baseMaxHp;
  }
  var step = balance.hero.upgrades[heroLevel - 1];
  return step === undefined ? balance.hero.upgrades[balance.hero.upgrades.length - 1]?.maxHp ?? balance.hero.baseMaxHp : step.maxHp;
}

function nextUpgradeLabel(balance: NormalizedBalance, meta: MetaState): string {
  var cost = nextUpgradeCost(balance, meta.heroLevel);
  if (cost === null) {
    return "MAX LEVEL";
  }
  return "UPGRADE - " + cost;
}

function tileLabel(tile: CoreBoardTile, balance: NormalizedBalance): string {
  switch (tile.tag) {
    case "none":
      return "Empty";
    case "monster":
      return balance.monsterOrder[tile.ref]?.name ?? "Monster";
    case "sword":
      return balance.swordOrder[tile.ref]?.name ?? "Sword";
    case "potion":
      return balance.potionOrder[tile.ref]?.name ?? "Potion";
    case "gold":
      return balance.goldItem.name;
  }
}

function tileSprite(tile: CoreBoardTile, balance: NormalizedBalance): string {
  switch (tile.tag) {
    case "none":
      return "";
    case "monster":
      return resolveSprite(balance.monsterOrder[tile.ref]?.sprite ?? "");
    case "sword":
      return resolveSprite(balance.swordOrder[tile.ref]?.sprite ?? "");
    case "potion":
      return resolveSprite(balance.potionOrder[tile.ref]?.sprite ?? "");
    case "gold":
      return resolveSprite(balance.goldItem.sprite);
  }
}

function tileBadge(tile: CoreBoardTile): string {
  switch (tile.tag) {
    case "monster":
      return "HP " + tile.hp;
    case "sword":
      return "DMG " + tile.dmg;
    case "potion":
      return "HEAL " + tile.heal;
    case "gold":
      return "GOLD " + tile.amount;
    case "none":
      return "";
  }
}

function heroWeaponBadge(run: RunState): string {
  if (run.weapon.tag === "none") {
    return "";
  }
  return "DMG " + run.weapon.dmg;
}

function renderHeroCard(balance: NormalizedBalance, run: RunState | null, hub: boolean): string {
  var image = resolveSprite(balance.hero.sprite);
  var hp = run === null ? heroMaxHp(balance, state.meta?.heroLevel ?? 0) : run.heroHp;
  var maxHp = run === null ? heroMaxHp(balance, state.meta?.heroLevel ?? 0) : run.heroMaxHp;
  var weaponBadge = run === null ? "" : heroWeaponBadge(run);
  var classes = hub ? "card card--hero card--hub" : "card card--hero";

  return `
    <article class="${classes}">
      <div class="card__badge card__badge--hp">HP ${hp}/${maxHp}</div>
      ${weaponBadge === "" ? "" : `<div class="card__badge card__badge--value">${weaponBadge}</div>`}
      <div class="card__art-wrap">
        <img class="card__art" src="${image}" alt="${escapeHtml(balance.hero.name)}" />
      </div>
      <div class="card__label">${escapeHtml(balance.hero.name)}</div>
    </article>
  `;
}

function renderTileCard(balance: NormalizedBalance, tile: CoreBoardTile): string {
  if (tile.tag === "none") {
    return `
      <article class="card card--empty">
        <div class="card__empty">Empty</div>
      </article>
    `;
  }

  var badge = tileBadge(tile);
  var sprite = tileSprite(tile, balance);

  return `
    <article class="card card--tile card--${tile.tag}">
      ${badge === "" ? "" : `<div class="card__badge card__badge--value">${escapeHtml(badge)}</div>`}
      <div class="card__art-wrap">
        <img class="card__art" src="${sprite}" alt="${escapeHtml(tileLabel(tile, balance))}" />
      </div>
      <div class="card__label">${escapeHtml(tileLabel(tile, balance))}</div>
    </article>
  `;
}

function renderBoard(balance: NormalizedBalance, run: RunState): string {
  var cards: string[] = [];
  for (var index = 0; index < 9; index += 1) {
    if (run.heroIndex === index) {
      cards.push(renderHeroCard(balance, run, false));
      continue;
    }
    cards.push(renderTileCard(balance, run.board[index]));
  }
  return cards.join("");
}

function renderHub(balance: NormalizedBalance, meta: MetaState): string {
  var maxHp = heroMaxHp(balance, meta.heroLevel);
  var upgradeCost = nextUpgradeCost(balance, meta.heroLevel);
  var disabled = upgradeCost === null || meta.gold < upgradeCost ? "disabled" : "";

  return `
    <main class="shell">
      <header class="topbar">
        <div>
          <p class="eyebrow">DungeonBend</p>
          <h1 class="title">Dungeon setup</h1>
        </div>
        <a class="link-button" href="${withBase("balance.html")}">Balance Tool</a>
      </header>
      <section class="hub">
        <div class="hub__hero">
          ${renderHeroCard(balance, null, true)}
        </div>
        <div class="hub__meta">
          <div class="stat-panel">
            <span class="stat-panel__label">Total Gold</span>
            <strong class="stat-panel__value">${meta.gold}</strong>
          </div>
          <div class="stat-panel">
            <span class="stat-panel__label">Hero HP</span>
            <strong class="stat-panel__value">${maxHp}/${maxHp}</strong>
          </div>
          <div class="hub__actions">
            <button class="button" data-action="start">Start Dungeon</button>
            <button class="button button--secondary" data-action="upgrade" ${disabled}>
              ${escapeHtml(nextUpgradeLabel(balance, meta))}
            </button>
          </div>
        </div>
      </section>
    </main>
  `;
}

function renderRunView(balance: NormalizedBalance, meta: MetaState, run: RunState): string {
  var overlay = run.status === "game_over"
    ? `
      <div class="overlay">
        <div class="overlay__panel">
          <h2>Game Over</h2>
          <p>The run ended. Your gold and hero upgrades were kept.</p>
          <div class="overlay__actions">
            <button class="button" data-action="restart">Restart</button>
            <button class="button button--secondary" data-action="back">Return to Hub</button>
          </div>
        </div>
      </div>
    `
    : "";

  return `
    <main class="shell shell--run">
      <header class="topbar topbar--run">
        <div class="topbar__stats">
          <div class="stat-panel">
            <span class="stat-panel__label">Dungeon Level</span>
            <strong class="stat-panel__value">${run.dungeonLevel}</strong>
          </div>
          <div class="stat-panel">
            <span class="stat-panel__label">Remaining Cards</span>
            <strong class="stat-panel__value">${run.remaining}/${run.capacity}</strong>
          </div>
          <div class="stat-panel">
            <span class="stat-panel__label">Total Gold</span>
            <strong class="stat-panel__value">${meta.gold}</strong>
          </div>
        </div>
        <button class="link-button" data-action="back">Hub</button>
      </header>
      <section class="board-shell">
        <div class="board-copy">
          <p class="eyebrow">Swipe to move</p>
          <h1 class="title">Dungeon Room</h1>
          <p class="subtitle">Touch, drag, or use arrow keys or WASD to target an adjacent tile.</p>
        </div>
        <div class="board" data-board>
          ${renderBoard(balance, run)}
        </div>
      </section>
      ${overlay}
    </main>
  `;
}

function attachHubEvents(): void {
  var start = document.querySelector<HTMLButtonElement>("[data-action='start']");
  var upgrade = document.querySelector<HTMLButtonElement>("[data-action='upgrade']");

  start?.addEventListener("click", () => {
    if (state.balance === null || state.meta === null) {
      return;
    }
    state.run = startRun(state.balance, state.meta, Date.now());
    render();
  });

  upgrade?.addEventListener("click", () => {
    if (state.balance === null || state.meta === null) {
      return;
    }
    state.meta = upgradeHero(state.balance, state.meta);
    saveMetaState(state.meta);
    render();
  });
}

function attachRunEvents(): void {
  var board = document.querySelector<HTMLElement>("[data-board]");
  if (board !== null) {
    cleanupSwipe = bindSwipe(board, handleSwipe);
  }

  var restart = document.querySelector<HTMLButtonElement>("[data-action='restart']");
  var back = document.querySelectorAll<HTMLButtonElement>("[data-action='back']");

  restart?.addEventListener("click", () => {
    if (state.balance === null || state.meta === null) {
      return;
    }
    state.run = startRun(state.balance, state.meta, Date.now());
    render();
  });

  back.forEach(button => {
    button.addEventListener("click", () => {
      state.run = null;
      render();
    });
  });
}

function handleSwipe(direction: Direction): void {
  if (state.balance === null || state.meta === null || state.run === null) {
    return;
  }
  var result = applySwipe(state.balance, state.meta, state.run, direction);
  state.meta = result.meta;
  state.run = result.run;
  saveMetaState(state.meta);
  render();
}

function directionFromKey(key: string): Direction | null {
  if (key === "ArrowUp") {
    return "up";
  }
  if (key === "ArrowDown") {
    return "down";
  }
  if (key === "ArrowLeft") {
    return "left";
  }
  if (key === "ArrowRight") {
    return "right";
  }

  var normalized = key.toLowerCase();
  if (normalized === "w") {
    return "up";
  }
  if (normalized === "s") {
    return "down";
  }
  if (normalized === "a") {
    return "left";
  }
  if (normalized === "d") {
    return "right";
  }

  return null;
}

function renderLoading(): string {
  return `
    <main class="shell shell--loading">
      <p class="eyebrow">DungeonBend</p>
      <h1 class="title">Loading...</h1>
    </main>
  `;
}

function renderError(error: string): string {
  return `
    <main class="shell shell--loading">
      <p class="eyebrow">DungeonBend</p>
      <h1 class="title">Setup Error</h1>
      <p class="subtitle">${escapeHtml(error)}</p>
    </main>
  `;
}

function render(): void {
  cleanupSwipe?.();
  cleanupSwipe = null;

  if (state.loading) {
    app.innerHTML = renderLoading();
    return;
  }

  if (state.error !== null) {
    app.innerHTML = renderError(state.error);
    return;
  }

  if (state.balance === null || state.meta === null) {
    app.innerHTML = renderError("Application state is incomplete.");
    return;
  }

  if (state.run === null) {
    app.innerHTML = renderHub(state.balance, state.meta);
    attachHubEvents();
    return;
  }

  app.innerHTML = renderRunView(state.balance, state.meta, state.run);
  attachRunEvents();
}

async function bootstrap(): Promise<void> {
  render();

  try {
    var balance = await loadNormalizedBalance();
    var meta = loadMetaState(balance);
    if (meta.heroId !== balance.hero.id) {
      meta = { ...meta, heroId: balance.hero.id };
      saveMetaState(meta);
    }
    state = {
      balance,
      meta,
      run: null,
      loading: false,
      error: null,
    };
  } catch (error) {
    state = {
      balance: null,
      meta: null,
      run: null,
      loading: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }

  render();
}

window.addEventListener("keydown", event => {
  if (state.run === null) {
    return;
  }

  var direction = directionFromKey(event.key);

  if (direction === null) {
    return;
  }

  event.preventDefault();
  handleSwipe(direction);
});

void bootstrap();
