import /HTML/
import /HTML/Attr
import /U32/ as U32
import /Dungeon/Upgrade as Upgrade
import /Dungeon/MonsterDef as MonsterDef
import /Dungeon/SwordDef as SwordDef
import /Dungeon/PotionDef as PotionDef
import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Weapon as Weapon
import /Dungeon/Tile as Tile
import /Dungeon/Board as Board
import /Dungeon/BoardDraw as BoardDraw
import /Dungeon/Board/indexing/board_get as board_get
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/Run as Run
import /Dungeon/RunSlot as RunSlot
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/config as config
import /Dungeon/Deck/counts_pick/hero_max_hp as hero_max_hp
import /Dungeon/Deck/counts_pick/nth_upgrade as nth_upgrade
import /Dungeon/App/on_event/_state_from_run as _state_from_run
import /Dungeon/App/on_event/_start as _start
import /Dungeon/App/on_event/_hero_hp as _hero_hp
import /Dungeon/App/on_event/_weapon_dmg as _weapon_dmg
import /Dungeon/App/on_event/_hero_dmg as _hero_dmg
import /Dungeon/App/on_event/_run_status as _run_status
import /Dungeon/App/on_event/_run_ult_charge as _run_ult_charge
import /Dungeon/App/on_event/_run_with_ult_charge as _run_with_ult_charge
import /Dungeon/App/on_event/_run_charge_after_gain as _run_charge_after_gain
import /Dungeon/App/on_event/_run_moved as _run_moved
import /Dungeon/App/on_event/_next_ult_charge as _next_ult_charge
import /Dungeon/App/on_event/_phase_from_run as _phase_from_run
import /Dungeon/App/on_event/_phase as _phase
import /Dungeon/App/on_event/_has_run as _has_run
import /Dungeon/App/on_event/_is_idle as _is_idle
import /Dungeon/App/on_event/_is_active_run as _is_active_run
import /Dungeon/App/on_event/_is_game_over as _is_game_over
import /Dungeon/App/on_event/_is_game_over_run as _is_game_over_run
import /Dungeon/App/on_event/_is_game_over_status as _is_game_over_status
import /Dungeon/App/on_event/_can_upgrade as _can_upgrade
import /Dungeon/App/on_event/_toggle_heal_fx as _toggle_heal_fx
import /Dungeon/App/on_event/_toggle_hurt_fx as _toggle_hurt_fx
import /Dungeon/App/on_event/_toggle_dmg_up_fx as _toggle_dmg_up_fx
import /Dungeon/App/on_event/_toggle_dmg_down_fx as _toggle_dmg_down_fx
import /Dungeon/App/on_event/_next_hp_fx_values as _next_hp_fx_values
import /Dungeon/App/on_event/_next_hp_fx as _next_hp_fx
import /Dungeon/App/on_event/_next_dmg_fx_values as _next_dmg_fx_values
import /Dungeon/App/on_event/_next_dmg_fx as _next_dmg_fx
import /Dungeon/App/on_event/_toggle_impact_hit_fx as _toggle_impact_hit_fx
import /Dungeon/App/on_event/_toggle_impact_kill_fx as _toggle_impact_kill_fx
import /Dungeon/App/on_event/_run_hero_index as _run_hero_index
import /Dungeon/App/on_event/_run_board as _run_board
import /Dungeon/App/on_event/_impact_none as _impact_none
import /Dungeon/App/on_event/_impact_hit as _impact_hit
import /Dungeon/App/on_event/_impact_kill as _impact_kill
import /Dungeon/App/on_event/_impact_from_monster_hp as _impact_from_monster_hp
import /Dungeon/App/on_event/_impact_from_monster_next as _impact_from_monster_next
import /Dungeon/App/on_event/_impact_from_target_tile as _impact_from_target_tile
import /Dungeon/App/on_event/_impact_from_turn as _impact_from_turn
import /Dungeon/App/on_event/_state_from_swipe_impact as _state_from_swipe_impact
import /Dungeon/App/on_event/_state_from_swipe as _state_from_swipe
import /Dungeon/App/on_event/_apply_turn as _apply_turn
import /Dungeon/App/on_event/_ultimate_run_from_values as _ultimate_run_from_values
import /Dungeon/App/on_event/_use_ultimate as _use_ultimate
import /Dungeon/App/on_event/_ultimate_ready_charge as _ultimate_ready_charge
import /Dungeon/App/on_event/_ultimate_ready as _ultimate_ready
import /Dungeon/App/on_event/_can_afford_upgrade as _can_afford_upgrade
import /Dungeon/App/on_event/_can_afford_upgrade_gold as _can_afford_upgrade_gold
import /Dungeon/App/on_event/_idle_event as _idle_event
import /Dungeon/App/on_event/_active_run_ultimate as _active_run_ultimate
import /Dungeon/App/on_event/_active_run_event as _active_run_event
import /Dungeon/App/on_event/_ended_run_event as _ended_run_event
import /Dungeon/App/key_event as key_event
import /Dungeon/View/css as css
import /Dungeon/View/assets_and_labels/_hero_name as _hero_name
import /Dungeon/View/assets_and_labels/_hero_sprite as _hero_sprite
import /Dungeon/View/assets_and_labels/_gold_name as _gold_name
import /Dungeon/View/assets_and_labels/_gold_sprite as _gold_sprite
import /Dungeon/View/assets_and_labels/_monster_name as _monster_name
import /Dungeon/View/assets_and_labels/_monster_sprite as _monster_sprite
import /Dungeon/View/assets_and_labels/_sword_name as _sword_name
import /Dungeon/View/assets_and_labels/_sword_sprite as _sword_sprite
import /Dungeon/View/assets_and_labels/_potion_name as _potion_name
import /Dungeon/View/assets_and_labels/_potion_sprite as _potion_sprite
import /Dungeon/View/assets_and_labels/_tile_name as _tile_name
import /Dungeon/View/assets_and_labels/_tile_sprite as _tile_sprite
import /Dungeon/View/assets_and_labels/_tile_badge as _tile_badge

def render(state: DungeonState) -> HTML(DungeonEvent):
  match state:
    case dungeon{meta_state, idle_run{}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      _frame(_shell_children(meta_state, idle_run{}, 0, 0, 9, 0))
    case dungeon{meta_state, run_slot{run_value}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      _frame(_shell_children(meta_state, run_slot{run_value}, hp_fx, dmg_fx, impact_idx, impact_fx))

def _frame(kids: List(HTML(DungeonEvent))) -> HTML(DungeonEvent):
  <div class="page" tabindex="0" autofocus="autofocus" style="outline:none" on_key_down={key_event}>
    <style>{text{css()}}</style>
    <main class="shell shell--dungeon">
      {...kids}
    </main>
  </div>

def _shell_children(meta_state: Meta, current_run: RunSlot, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> List(HTML(DungeonEvent)):
  [
    _dashboard_header(meta_state),
    _status_panel(current_run),
    _controls_panel(meta_state, current_run),
    _board_node(current_run, meta_state, hp_fx, dmg_fx, impact_idx, impact_fx)
  ]

def _dashboard_header(meta_state: Meta) -> HTML(DungeonEvent):
  <header class="topbar">
    <p class="resource-bar">
      <span class="resource-bar__label">Gold</span>
      <strong class="resource-bar__value">{text{_meta_gold(meta_state)}}</strong>
    </p>
  </header>

def _status_panel(current_run: RunSlot) -> HTML(DungeonEvent):
  <section class="status-panel">
    <div class="status-panel__head">
      <p class={_phase_chip_class(current_run)}>{text{_phase_badge(current_run)}}</p>
      <div class="status-meta-row">
        {_status_meta_chip("Lv", _dungeon_level_value(current_run))}
        {_status_meta_chip("Cards", _remaining_value(current_run))}
        {_status_meta_chip("Weapon", _weapon_value(current_run))}
      </div>
    </div>
  </section>

def _status_meta_chip(label: String, value: String) -> HTML(DungeonEvent):
  <p class="status-meta-chip">
    <span class="status-meta-chip__label">{text{label}}</span>
    <strong class="status-meta-chip__value">{text{value}}</strong>
  </p>

def _controls_panel(meta_state: Meta, current_run: RunSlot) -> HTML(DungeonEvent):
  <section class="controls">
    <button {..._start_attrs(current_run)}>
      {text{"Start"}}
    </button>
    <div class="upgrade-slot">
      <button {..._upgrade_attrs(meta_state, current_run)}>
        {text{_upgrade_label(meta_state)}}
      </button>
      <p class="upgrade-slot__meta">{text{_hero_level_text(meta_state)}}</p>
    </div>
  </section>

def _board_node(current_run: RunSlot, meta_state: Meta, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> HTML(DungeonEvent):
  match current_run:
    case idle_run{}:
      cells = U32.grid(HTML(DungeonEvent), 3, 3, _idle_board_slot(meta_state));
      <section class={_board_shell_class_idle()}>
        <div class="board">{...cells}</div>
        {_ultimate_button(idle_run{})}
        {_board_overlay_idle()}
      </section>
    case run_slot{run_value}:
      cells = U32.grid(HTML(DungeonEvent), 3, 3, _board_slot(run_value, hp_fx, dmg_fx, impact_idx, impact_fx));
      <section class={_board_shell_class_run(run_value)}>
        <div class="board">{...cells}</div>
        {_ultimate_button(run_slot{run_value})}
        {_board_overlay_run(run_value)}
      </section>

def _board_shell_class_idle() -> String:
  "board-shell"

def _board_shell_class_run(run_value: Run) -> String:
  over = _is_game_over_run(run_value);
  _board_shell_class_flag(over)

def _board_shell_class_flag(over: U32) -> String:
  match over:
    case 0:
      "board-shell"
    case _:
      "board-shell board-shell--over"

def _board_overlay_idle() -> HTML(DungeonEvent):
  <div class="game-over-modal"></div>

def _board_overlay_run(run_value: Run) -> HTML(DungeonEvent):
  <div class={_game_over_modal_class(run_value)}>
    <div class="game-over-card">
      <p class="game-over-card__eyebrow">{text{"Run encerrada"}}</p>
      <h2 class="game-over-card__title">{text{"Game Over"}}</h2>
      <button {..._button_attrs("button", ok{}, 1)}>
        {text{"OK"}}
      </button>
    </div>
  </div>

def _game_over_modal_class(run_value: Run) -> String:
  over = _is_game_over_run(run_value);
  _game_over_modal_class_flag(over)

def _game_over_modal_class_flag(over: U32) -> String:
  match over:
    case 0:
      "game-over-modal"
    case _:
      "game-over-modal game-over-modal--visible"

def _idle_board_card(meta_state: Meta, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  match idx === 4:
    case 0:
      _idle_placeholder_card()
    case _:
      _hero_card_idle(meta_state)

def _idle_placeholder_card() -> HTML(DungeonEvent):
  <article class="card card--empty card--idle">
    <div class="card__empty">Ready</div>
  </article>

def _hero_card_idle(meta_state: Meta) -> HTML(DungeonEvent):
  max_hp = _hero_max_hp(meta_state);
  _hero_card_values(max_hp, max_hp, no_weapon{}, 0, 0)

def _idle_board_slot(meta_state: Meta, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  <div class={_board_slot_class(idx, 9, 0)}>
    {_idle_board_card(meta_state, x, y)}
  </div>

def _board_card_at(run_value: Run, hp_fx: U32, dmg_fx: U32, idx: U32) -> HTML(DungeonEvent):
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status, ult_charge}:
      match hero_index === idx:
        case 0:
          _tile_card(board_get(board_value, idx))
        case _:
          _hero_card_values(hero_hp, hero_max_hp, weapon, hp_fx, dmg_fx)

def _board_card(run_value: Run, hp_fx: U32, dmg_fx: U32, x: U32, y: U32) -> HTML(DungeonEvent):
  _board_card_at(run_value, hp_fx, dmg_fx, x + (y * 3))

def _board_slot(run_value: Run, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  <div class={_board_slot_class(idx, impact_idx, impact_fx)}>
    {_board_card_at(run_value, hp_fx, dmg_fx, idx)}
  </div>

def _board_slot_class(idx: U32, impact_idx: U32, impact_fx: U32) -> String:
  matched = idx === impact_idx;
  _board_slot_class_matched(matched, impact_fx)

def _board_slot_class_matched(matched: U32, impact_fx: U32) -> String:
  match matched:
    case 0:
      "board-slot"
    case _:
      _board_slot_impact_class(impact_fx)

def _board_slot_impact_class(impact_fx: U32) -> String:
  match impact_fx:
    case 1:
      "board-slot board-slot--impact-a"
    case 2:
      "board-slot board-slot--impact-b"
    case 3:
      "board-slot board-slot--kill-a"
    case 4:
      "board-slot board-slot--kill-b"
    case _:
      "board-slot"

def _hero_card_values(hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, hp_fx: U32, dmg_fx: U32) -> HTML(DungeonEvent):
  <article class={_hero_card_class(dmg_fx)} data-dmg={_hero_damage_attr(weapon_value)}>
    <div class={_hero_hp_badge_class(hp_fx)}>{text{"HP " ++ U32.show(hero_hp) ++ "/" ++ U32.show(hero_max_hp)}}</div>
    <div class="card__art-wrap">
      <img class="card__art" src={_hero_sprite()} alt={_hero_name()} />
    </div>
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
      "DMG " ++ U32.show(dmg)

def _tile_card(tile: Tile) -> HTML(DungeonEvent):
  match tile:
    case none{}:
      <article class="card card--empty">
        <div class="card__empty">Empty</div>
      </article>
    case monster{ref, hp}:
      _filled_tile_card(monster{ref, hp}, "card card--tile card--monster")
    case sword{ref, dmg}:
      _filled_tile_card(sword{ref, dmg}, "card card--tile card--sword")
    case potion{ref, heal}:
      _filled_tile_card(potion{ref, heal}, "card card--tile card--potion")
    case gold{amount}:
      _filled_tile_card(gold{amount}, "card card--tile card--gold")

def _filled_tile_card(tile: Tile, class_name: String) -> HTML(DungeonEvent):
  <article class={class_name}>
    {_tile_badge_node(tile)}
    <div class="card__art-wrap">
      <img class="card__art" src={_tile_sprite(tile)} alt={_tile_name(tile)} />
    </div>
  </article>

def _tile_badge_node(tile: Tile) -> HTML(DungeonEvent):
  <div class="card__badge card__badge--value">{text{_tile_badge(tile)}}</div>

def _meta_gold(meta_state: Meta) -> String:
  match meta_state:
    case meta{hero_level, gold}:
      U32.show(gold)

def _hero_level(meta_state: Meta) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      hero_level

def _hero_level_text(meta_state: Meta) -> String:
  "Hero Lv " ++ U32.show(_hero_level(meta_state))

def _dungeon_level_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--"
    case run_slot{run_value}:
      _dungeon_level_value_from_run(run_value)

def _dungeon_level_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status, ult_charge}:
      U32.show(dungeon_level)

def _remaining_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--/--"
    case run_slot{run_value}:
      _remaining_value_from_run(run_value)

def _remaining_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status, ult_charge}:
      U32.show(remaining) ++ "/" ++ U32.show(capacity)

def _weapon_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--"
    case run_slot{run_value}:
      _weapon_value_from_run(run_value)

def _weapon_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status, ult_charge}:
      _weapon_value_from_weapon(weapon)

def _ultimate_label_charge(ult_charge: U32) -> String:
  "ULTIMATE " ++ U32.show(ult_charge) ++ "/6"

def _ultimate_label(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      _ultimate_label_charge(0)
    case run_slot{run_value}:
      _ultimate_label_charge(_run_ult_charge(run_value))

def _ultimate_enabled_run(run_value: Run) -> U32:
  match _is_game_over_run(run_value):
    case 0:
      _ultimate_ready(run_value)
    case _:
      0

def _ultimate_enabled(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _ultimate_enabled_run(run_value)

def _ultimate_attrs(current_run: RunSlot) -> List(Attr(DungeonEvent)):
  _button_attrs("button button--ultimate", ultimate{}, _ultimate_enabled(current_run))

def _ultimate_button(current_run: RunSlot) -> HTML(DungeonEvent):
  <button {..._ultimate_attrs(current_run)}>
    {text{_ultimate_label(current_run)}}
  </button>

def _weapon_value_from_weapon(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      "Unarmed"
    case weapon{ref, dmg}:
      "DMG " ++ U32.show(dmg)

def _phase_badge(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "Idle"
    case run_slot{run_value}:
      _phase_badge_run(run_value)

def _phase_badge_run(run_value: Run) -> String:
  _phase_badge_status(_run_status(run_value))

def _phase_badge_status(status: U32) -> String:
  _phase_badge_hit(status === 0)

def _phase_badge_hit(hit: U32) -> String:
  match hit:
    case 0:
      "Game Over"
    case _:
      "Run Active"

def _phase_chip_class(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "status-chip status-chip--idle"
    case run_slot{run_value}:
      _phase_chip_class_run(run_value)

def _phase_chip_class_run(run_value: Run) -> String:
  _phase_chip_class_status(_run_status(run_value))

def _phase_chip_class_status(status: U32) -> String:
  _phase_chip_class_hit(status === 0)

def _phase_chip_class_hit(hit: U32) -> String:
  match hit:
    case 0:
      "status-chip status-chip--over"
    case _:
      "status-chip status-chip--active"

def _button_attrs_enabled(class_name: String, evt: DungeonEvent) -> List(Attr(DungeonEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, on_click{evt}]

def _button_attrs_disabled(class_name: String) -> List(Attr(DungeonEvent)):
  [attr{"type", "button"}, attr{"class", class_name ++ " button--disabled"}, on_click{ignore{}}]

def _button_attrs(class_name: String, evt: DungeonEvent, enabled: U32) -> List(Attr(DungeonEvent)):
  match enabled:
    case 0:
      _button_attrs_disabled(class_name)
    case _:
      _button_attrs_enabled(class_name, evt)

def _start_attrs(current_run: RunSlot) -> List(Attr(DungeonEvent)):
  _button_attrs("button", start{}, _is_idle(current_run))

def _upgrade_enabled(meta_state: Meta, current_run: RunSlot, cost: U32) -> U32:
  match _can_upgrade(current_run):
    case 0:
      0
    case _:
      _can_afford_upgrade(meta_state, cost)

def _upgrade_label_cost(cost: U32) -> String:
  match cost === 0:
    case 0:
      "Upgrade - " ++ U32.show(cost)
    case _:
      "Max Level"

def _upgrade_label(meta_state: Meta) -> String:
  _upgrade_label_cost(_next_upgrade_cost(meta_state))

def _upgrade_attrs(meta_state: Meta, current_run: RunSlot) -> List(Attr(DungeonEvent)):
  cost = _next_upgrade_cost(meta_state);
  _button_attrs("button button--secondary", upgrade{}, _upgrade_enabled(meta_state, current_run, cost))

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
      hero_max_hp(hero_base_max_hp, upgrades, hero_level)

def _next_upgrade_cost_from_config(cfg: Config, hero_level: U32) -> U32:
  match cfg:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      _upgrade_cost_or_zero(nth_upgrade(upgrades, hero_level))

def _hero_max_hp(meta_state: Meta) -> U32:
  _hero_max_hp_from_config(config(), _hero_level(meta_state))

def _next_upgrade_cost(meta_state: Meta) -> U32:
  _next_upgrade_cost_from_config(config(), _hero_level(meta_state))
