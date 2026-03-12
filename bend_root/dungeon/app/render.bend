import /U32/show as show
import /dungeon/data/config as config
import /dungeon/logic/Meta
import /dungeon/logic/Run
import /dungeon/logic/Tile
import /dungeon/logic/Weapon
import /dungeon/logic/Config
import /dungeon/logic/Upgrade
import /dungeon/logic/Deck/hero_max_hp as logic_hero_max_hp
import /dungeon/logic/Deck/nth_upgrade as nth_upgrade
import /dungeon/logic/Board/board_get as board_get
import /dungeon/app/DungeonState
import /dungeon/app/DungeonEvent
import /dungeon/app/key_event
import /dungeon/app/css

def render(state: DungeonState) -> HTML(DungeonEvent):
  match state:
    case hub{meta_state, next_seed}:
      _frame("shell shell--hub", 0, 0, _hub_children(meta_state))
    case run_screen{meta_state, run_value, next_seed, hp_fx, dmg_fx}:
      _frame("shell shell--run", hp_fx, dmg_fx, _run_children(meta_state, run_value, 0, hp_fx, dmg_fx))
    case game_over{meta_state, run_value, next_seed, hp_fx, dmg_fx}:
      _frame("shell shell--run", hp_fx, dmg_fx, _run_children(meta_state, run_value, 1, hp_fx, dmg_fx))

def _frame(shell_class: String, hp_fx: U32, dmg_fx: U32, kids: List(HTML(DungeonEvent))) -> HTML(DungeonEvent):
  <div class="page">
    <style>{text{css()}}</style>
    <main {..._shell_attrs(shell_class, hp_fx, dmg_fx)}>
      {...kids}
    </main>
  </div>

def _shell_attrs(shell_class: String, hp_fx: U32, dmg_fx: U32) -> List(Attr(DungeonEvent)):
  [attr{"class", shell_class}, on_key_down{key_event}]

def _hub_children(meta_state: Meta) -> List(HTML(DungeonEvent)):
  [
    <header class="topbar topbar--hub">
      <div class="brand-lockup">
        <p class="eyebrow">DungeonBend</p>
        <h1 class="title">Dungeon setup</h1>
      </div>
    </header>,
    <section class="hub">
      <div class="hub__hero">
        {_hero_card_hub(meta_state)}
      </div>
      <div class="hub__meta">
        <div class="stat-panel">
          <span class="stat-panel__label">Total Gold</span>
          <strong class="stat-panel__value">{text{_meta_gold(meta_state)}}</strong>
        </div>
        <div class="stat-panel">
          <span class="stat-panel__label">Hero HP</span>
          <strong class="stat-panel__value">{text{_hub_hp_label(meta_state)}}</strong>
        </div>
        <div class="hub__actions">
          <a href="dungeon.html" class="button">Start Dungeon</a>
          <button {..._upgrade_attrs(meta_state)}>
            {text{_upgrade_label(meta_state)}}
          </button>
        </div>
      </div>
    </section>
  ]

def _run_children(meta_state: Meta, run_value: Run, is_game_over: U32, hp_fx: U32, dmg_fx: U32) -> List(HTML(DungeonEvent)):
  match is_game_over:
    case 0:
      [
        _run_header(meta_state, run_value),
        _run_board(run_value, hp_fx, dmg_fx),
        _run_footer()
      ]
    case _:
      [
        _run_header(meta_state, run_value),
        _run_board(run_value, hp_fx, dmg_fx),
        _run_footer(),
        _game_over_overlay()
      ]

def _run_header(meta_state: Meta, run_value: Run) -> HTML(DungeonEvent):
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      <header class="run-head">
        <div class="run-head__group">
          <p class="run-stat">{text{"Dungeon Lv: " ++ show(dungeon_level)}}</p>
          <p class="run-stat run-stat--muted">{text{"Cards Remaining: " ++ show(remaining) ++ "/" ++ show(capacity)}}</p>
        </div>
        <div class="run-head__group run-head__group--right">
          <p class="run-stat">{text{"Coins: " ++ _meta_gold(meta_state)}}</p>
          <a href="index.html" class="text-action">Menu</a>
        </div>
      </header>

def _run_board(run_value: Run, hp_fx: U32, dmg_fx: U32) -> HTML(DungeonEvent):
  <section class="board-shell">
    <div class="board">{..._board_cards(run_value, hp_fx, dmg_fx, 0)}</div>
  </section>

def _run_footer() -> HTML(DungeonEvent):
  <footer class="run-foot">
    <p class="run-hint">Controls: Arrow Keys or WASD. Refresh resets the session meta.</p>
  </footer>

def _game_over_overlay() -> HTML(DungeonEvent):
  <div class="overlay">
    <div class="overlay__panel">
      <h2>Game Over</h2>
      <p>The run ended. Restart keeps the in-page meta. Going back to the menu drops it until Bend2 exposes cross-page save.</p>
      <div class="overlay__actions">
        <button type="button" class="button" on_click={restart{}}>Restart</button>
        <a href="index.html" class="button button--secondary">Return to Menu</a>
      </div>
    </div>
  </div>

def _board_cards(run_value: Run, hp_fx: U32, dmg_fx: U32, idx: U32) -> List(HTML(DungeonEvent)):
  match idx === 9:
    case 0:
      (_board_card(run_value, hp_fx, dmg_fx, idx)<>_board_cards(run_value, hp_fx, dmg_fx, idx + 1) :: List(HTML(DungeonEvent)))
    case _:
      ([] :: List(HTML(DungeonEvent)))

def _board_card(run_value: Run, hp_fx: U32, dmg_fx: U32, idx: U32) -> HTML(DungeonEvent):
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      match hero_index === idx:
        case 0:
          _tile_card(board_get(board_value, idx))
        case _:
          _hero_card_values(hero_hp, hero_max_hp, weapon, hp_fx, dmg_fx)

def _hero_card_hub(meta_state: Meta) -> HTML(DungeonEvent):
  max_hp = _hero_max_hp(meta_state);
  <article class="card card--hero card--hub">
    <div class="card__badge card__badge--hp">{text{"HP " ++ show(max_hp) ++ "/" ++ show(max_hp)}}</div>
    <div class="card__art-wrap">
      <img class="card__art" src={_hero_sprite()} alt={_hero_name()} />
    </div>
    <div class="card__label">{text{_hero_name()}}</div>
  </article>

def _hero_card_values(hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, hp_fx: U32, dmg_fx: U32) -> HTML(DungeonEvent):
  <article class={_hero_card_class(dmg_fx)} data-dmg={_hero_damage_attr(weapon_value)}>
    <div class={_hero_hp_badge_class(hp_fx)}>{text{"HP " ++ show(hero_hp) ++ "/" ++ show(hero_max_hp)}}</div>
    <div class="card__art-wrap">
      <img class="card__art" src={_hero_sprite()} alt={_hero_name()} />
    </div>
    <div class="card__label">{text{_hero_name()}}</div>
  </article>

def _hero_card_class(dmg_fx: U32) -> String:
  match dmg_fx:
    case 1:
      "card card--hero card--hero-dmg-up-a"
    case 2:
      "card card--hero card--hero-dmg-up-b"
    case 3:
      "card card--hero card--hero-dmg-down-a"
    case 4:
      "card card--hero card--hero-dmg-down-b"
    case _:
      "card card--hero"

def _hero_hp_badge_class(hp_fx: U32) -> String:
  match hp_fx:
    case 1:
      "card__badge card__badge--hp card__badge--hp-heal-a"
    case 2:
      "card__badge card__badge--hp card__badge--hp-heal-b"
    case 3:
      "card__badge card__badge--hp card__badge--hp-hurt-a"
    case 4:
      "card__badge card__badge--hp card__badge--hp-hurt-b"
    case _:
      "card__badge card__badge--hp"

def _hero_damage_attr(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      ""
    case weapon{ref, dmg}:
      "DMG " ++ show(dmg)

def _tile_card(tile: Tile) -> HTML(DungeonEvent):
  match tile:
    case none{}:
      <article class="card card--empty">
        <div class="card__empty">Empty</div>
      </article>
    case monster{ref, hp}:
      _filled_tile_card((monster{ref, hp} :: Tile), "card card--tile card--monster")
    case sword{ref, dmg}:
      _filled_tile_card((sword{ref, dmg} :: Tile), "card card--tile card--sword")
    case potion{ref, heal}:
      _filled_tile_card((potion{ref, heal} :: Tile), "card card--tile card--potion")
    case gold{amount}:
      _filled_tile_card((gold{amount} :: Tile), "card card--tile card--gold")

def _filled_tile_card(tile: Tile, class_name: String) -> HTML(DungeonEvent):
  <article class={class_name}>
    {_tile_badge_node(tile)}
    <div class="card__art-wrap">
      <img class="card__art" src={_tile_sprite(tile)} alt={_tile_name(tile)} />
    </div>
    <div class="card__label">{text{_tile_name(tile)}}</div>
  </article>

def _tile_badge_node(tile: Tile) -> HTML(DungeonEvent):
  <div class="card__badge card__badge--value">{text{_tile_badge(tile)}}</div>

def _meta_gold(meta_state: Meta) -> String:
  match meta_state:
    case meta{hero_level, gold}:
      show(gold)

def _hero_level(meta_state: Meta) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      hero_level

def _hub_hp_label(meta_state: Meta) -> String:
  max_hp = _hero_max_hp(meta_state);
  show(max_hp) ++ "/" ++ show(max_hp)

def _upgrade_label(meta_state: Meta) -> String:
  cost = _next_upgrade_cost(meta_state);
  match cost === 0:
    case 0:
      "UPGRADE - " ++ show(cost)
    case _:
      "MAX LEVEL"

def _upgrade_attrs(meta_state: Meta) -> List(Attr(DungeonEvent)):
  cost = _next_upgrade_cost(meta_state);
  match cost === 0:
    case 0:
      _upgrade_affordance(meta_state, cost)
    case _:
      [attr{"type", "button"}, attr{"class", "button button--secondary"}, on_click{upgrade{}}, attr{"disabled", "disabled"}]

def _upgrade_affordance(meta_state: Meta, cost: U32) -> List(Attr(DungeonEvent)):
  match meta_state:
    case meta{hero_level, gold}:
      match gold < cost:
        case 0:
          ([attr{"type", "button"}, attr{"class", "button button--secondary"}, on_click{upgrade{}}] :: List(Attr(DungeonEvent)))
        case _:
          ([attr{"type", "button"}, attr{"class", "button button--secondary"}, on_click{upgrade{}}, attr{"disabled", "disabled"}] :: List(Attr(DungeonEvent)))

def _hero_name() -> String:
  "Knight"

def _hero_sprite() -> String:
  "assets/hero.png"

def _gold_name() -> String:
  "Gold"

def _gold_sprite() -> String:
  "assets/drop-gold-chest.png"

def _monster_name(ref: U32) -> String:
  match ref:
    case 0:
      "Slime"
    case 1:
      "Ghoul"
    case 2:
      "Shade"
    case 3:
      "Brute"
    case _:
      "Monster"

def _monster_sprite(ref: U32) -> String:
  match ref:
    case 0:
      "assets/mob1.png"
    case 1:
      "assets/mob2.png"
    case 2:
      "assets/mob3.png"
    case 3:
      "assets/mob4.png"
    case _:
      ""

def _sword_name(ref: U32) -> String:
  match ref:
    case 0:
      "Bronze Sword"
    case 1:
      "Iron Sword"
    case 2:
      "Relic Sword"
    case _:
      "Sword"

def _sword_sprite(ref: U32) -> String:
  match ref:
    case 0:
      "assets/sword1.png"
    case 1:
      "assets/sword2.png"
    case 2:
      "assets/sword3.png"
    case _:
      ""

def _potion_name(ref: U32) -> String:
  "Potion"

def _potion_sprite(ref: U32) -> String:
  "assets/potion.png"

def _tile_name(tile: Tile) -> String:
  match tile:
    case none{}:
      "Empty"
    case monster{ref, hp}:
      _monster_name(ref)
    case sword{ref, dmg}:
      _sword_name(ref)
    case potion{ref, heal}:
      _potion_name(ref)
    case gold{amount}:
      _gold_name()

def _tile_sprite(tile: Tile) -> String:
  match tile:
    case none{}:
      ""
    case monster{ref, hp}:
      _monster_sprite(ref)
    case sword{ref, dmg}:
      _sword_sprite(ref)
    case potion{ref, heal}:
      _potion_sprite(ref)
    case gold{amount}:
      _gold_sprite()

def _tile_badge(tile: Tile) -> String:
  match tile:
    case none{}:
      ""
    case monster{ref, hp}:
      "HP " ++ show(hp)
    case sword{ref, dmg}:
      "DMG " ++ show(dmg)
    case potion{ref, heal}:
      "HEAL " ++ show(heal)
    case gold{amount}:
      "GOLD " ++ show(amount)

def _upgrade_cost_or_zero(step: Upgrade) -> U32:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp === 0:
        case 0:
          cost
        case _:
          0

def _hero_max_hp_from_config(cfg: Config, hero_level: U32) -> U32:
  match cfg:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      logic_hero_max_hp(hero_base_max_hp, upgrades, hero_level)

def _next_upgrade_cost_from_config(cfg: Config, hero_level: U32) -> U32:
  match cfg:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      _upgrade_cost_or_zero(nth_upgrade(upgrades, hero_level))

def _hero_max_hp(meta_state: Meta) -> U32:
  _hero_max_hp_from_config(config(), _hero_level(meta_state))

def _next_upgrade_cost(meta_state: Meta) -> U32:
  _next_upgrade_cost_from_config(config(), _hero_level(meta_state))
