import /HTML/
import /U32/ as U32
import /Dungeon/HeroDef as HeroDef
import /Dungeon/Weapon as Weapon
import /Dungeon/Tile as Tile
import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DamageOverlay as DamageOverlay
import /Dungeon/HpFx as HpFx
import /Dungeon/DmgFx as DmgFx
import /Dungeon/Impact as Impact
import /Dungeon/ImpactFx as ImpactFx
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/Board/indexing/board_get as board_get
import /Dungeon/Board/indexing/board_xy_pos as board_xy_pos
import /Dungeon/Board/indexing/same_pos as same_pos
import /Dungeon/config as config
import /Dungeon/hero_helpers/hero_at as hero_at
import /Dungeon/profile_helpers/selected_hero as selected_hero
import /Dungeon/View/selectors/meta_gold as meta_gold
import /Dungeon/View/selectors/dungeon_level_value as dungeon_level_value
import /Dungeon/View/selectors/remaining_value as remaining_value
import /Dungeon/View/selectors/ultimate_label as ultimate_label
import /Dungeon/View/selectors/ultimate_enabled as ultimate_enabled
import /Dungeon/View/selectors/game_over_modal_class as game_over_modal_class
import /Dungeon/View/menu/_full_button_overrides as _full_button_overrides
import /Dungeon/View/assets_and_labels/_dungeon_level_badge_backdrop as _dungeon_level_badge_backdrop
import /Dungeon/View/assets_and_labels/_dungeon_level_value_backdrop as _dungeon_level_value_backdrop
import /Dungeon/View/assets_and_labels/_gold_icon as _gold_icon
import /Dungeon/deck_counter_frames/idle_src as deck_counter_idle_src
import /Dungeon/deck_counter_animation/clip as deck_counter_clip
import /Dungeon/View/cards/_hero_card_values as _hero_card_values
import /Dungeon/View/cards/_tile_card as _tile_card
import /Dungeon/Content/ as Content
import /Midum/Button/ as Button
import /Midum/Button/Size
import /Midum/Card/ as Card
import /Midum/Image/ as Image
import /Midum/Layout/ as Layout

def _render_dungeon(meta_state: Meta, scene_value: Scene, run_value: Run, ui_value: UiState) -> HTML(DungeonEvent):
  hero_value = hero_at(config(), selected_hero(meta_state));
  <div every_ms={125, damage_tick{}}>
    {_dungeon_shell(
      Layout.frame(
        DungeonEvent,
        Layout.overlay(DungeonEvent, [
          Layout.top(DungeonEvent,
            Layout.frame(
              DungeonEvent,
              _dungeon_header(meta_state, scene_value, ui_value),
              [width_full{} height_fit{} inset_none{}]
            )
          )
          Layout.center(DungeonEvent,
            _board_grid(scene_value, run_value, ui_value, hero_value)
          )
            Layout.bottom(DungeonEvent,
              _ultimate_action(scene_value)
            )
            _board_modal_layer(scene_value)
          ]),
          [width_full{} height_full{} inset_none{}]
        )
    )}
  </div>

def _dungeon_shell(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  Layout.shell(
    DungeonEvent,
    body,
    [
      max_width_px{value: 640n}
      height_viewport{}
      overflow_hidden{}
      safe_area{}
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n}
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _deck_counter_overrides() -> List(Midum/Image/Override):
  []

def _deck_counter_visual(ui_value: UiState) -> HTML(DungeonEvent):
  match ui_value:
    case ui_state{hp_fx, dmg_fx, impact, damage_overlay, deck_counter_fx}:
      match deck_counter_fx:
        case deck_counter_idle{}:
          <div class="dungeon-resource__deck-visual">
            {Image.view(DungeonEvent, deck_counter_idle_src(), Content.ui_topbar_cards(), _deck_counter_overrides())}
          </div>
        case deck_counter_playing{deck_counter_state}:
          <div class="dungeon-resource__deck-visual">
            {Image.animated(DungeonEvent, deck_counter_state, deck_counter_clip(), Content.ui_topbar_cards(), _deck_counter_overrides())}
          </div>

def _dungeon_deck_counter(scene_value: Scene, ui_value: UiState) -> HTML(DungeonEvent):
  <p class="dungeon-resource dungeon-resource--deck">
    {_deck_counter_visual(ui_value)}
    <strong class="dungeon-resource__value">{text{remaining_value(scene_value)}}</strong>
  </p>

def _dungeon_header(meta_state: Meta, scene_value: Scene, ui_value: UiState) -> HTML(DungeonEvent):
  <header class="topbar topbar--dungeon">
    <div class="dungeon-topbar__left">
      {_dungeon_resource(_gold_icon(), Content.ui_topbar_gold(), meta_gold(meta_state), "dungeon-resource--gold")}
    </div>
    <div class="dungeon-topbar__center">
      {_dungeon_level(scene_value)}
    </div>
    <div class="dungeon-topbar__right">
      {_dungeon_deck_counter(scene_value, ui_value)}
    </div>
  </header>

def _dungeon_resource(src: String, alt: String, value: String, role_class: String) -> HTML(DungeonEvent):
  <p class={"dungeon-resource " ++ role_class}>
    <img class="dungeon-resource__icon" src={src} alt={alt} />
    <strong class="dungeon-resource__value">{text{value}}</strong>
  </p>

def _dungeon_level(scene_value: Scene) -> HTML(DungeonEvent):
  <div class="dungeon-level">
    <div class="dungeon-level__badge-frame">
      <div class="dungeon-level__badge-art">
        {Image.view(DungeonEvent, _dungeon_level_badge_backdrop(), "", [])}
      </div>
      <span class="dungeon-level__badge-text">{text{Content.ui_dungeon_level()}}</span>
    </div>
    <div class="dungeon-level__value-frame">
      <div class="dungeon-level__value-art">
        {Image.view(DungeonEvent, _dungeon_level_value_backdrop(), "", [])}
      </div>
      <strong class="dungeon-level__value-text">{text{dungeon_level_value(scene_value)}}</strong>
    </div>
  </div>

def _board_grid(scene_value: Scene, run_value: Run, ui_value: UiState, hero_value: HeroDef) -> HTML(DungeonEvent):
  cells = U32.grid(HTML(DungeonEvent), 3, 3, _board_slot(run_value, ui_value, hero_value));
  <div class={_board_class(scene_value)}>{...cells}</div>

def _ultimate_action(scene_value: Scene) -> HTML(DungeonEvent):
  <div class="ultimate-action">
    {_ultimate_button(scene_value)}
  </div>

def _board_class(scene_value: Scene) -> String:
  match scene_value:
    case resume_prompt{run_value}:
      "board board--over"
    case game_over{run_value}:
      "board board--over"
    case _:
      "board"

def _board_modal_layer(scene_value: Scene) -> HTML(DungeonEvent):
  match scene_value:
    case setup{}:
      text{""}
    case character_select{preview_hero}:
      text{""}
    case boosters{reward, reveal_index}:
      text{""}
    case running{run_value}:
      text{""}
    case resume_prompt{run_value}:
      Layout.center(DungeonEvent, _resume_prompt_modal(scene_value))
    case game_over{run_value}:
      Layout.center(DungeonEvent, _game_over_modal(scene_value))

def _resume_prompt_modal(scene_value: Scene) -> HTML(DungeonEvent):
  <div class={game_over_modal_class(scene_value)}>
    {Card.neutral(
      DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{Content.ui_game_over_resume_eyebrow()}}</p>
        <h2 class="game-over-card__title">{text{Content.ui_game_over_resume_title()}}</h2>
        <p class="game-over-card__body">{text{Content.ui_game_over_resume_body()}}</p>
        <section class="game-over-card__actions">
          <div class="menu-secondary-action game-over-card__secondary">
            {_resume_menu_button()}
          </div>
          <div class="menu-start-action game-over-card__primary">
            {_resume_dungeon_button()}
          </div>
        </section>
      </div>,
      [padding_md{}]
    )}
  </div>

def _game_over_modal(scene_value: Scene) -> HTML(DungeonEvent):
  <div class={game_over_modal_class(scene_value)}>
    {Card.neutral(
      DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{Content.ui_game_over_end_eyebrow()}}</p>
        <h2 class="game-over-card__title">{text{Content.ui_game_over_title()}}</h2>
        <div class="game-over-card__action">
          {_game_over_ok_button()}
        </div>
      </div>,
      [padding_md{}]
    )}
  </div>

def _board_idx(x: U32, y: U32) -> U32:
  x + (y * 3)

def _board_card_at(run_value: Run, ui_value: UiState, hero_value: HeroDef, idx: U32, pos: Nat/V2) -> HTML(DungeonEvent):
  match run_value ui_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge} ui_state{hp_fx, dmg_fx, impact, damage_overlay, deck_counter_fx}:
      _board_card_identity(hero_index === idx, hero_value, hero_hp, hero_max_hp, weapon, hp_fx, dmg_fx, board_get(board_value, idx), pos, damage_overlay)

def _board_card_identity(is_hero: U32, hero_value: HeroDef, hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, hp_fx: HpFx, dmg_fx: DmgFx, tile_value: Tile, pos: Nat/V2, damage_overlay: DamageOverlay) -> HTML(DungeonEvent):
  match is_hero:
    case 0:
      _tile_card(tile_value, pos, damage_overlay)
    case _:
      _hero_card_values(hero_value, hero_hp, hero_max_hp, weapon_value, hp_fx, dmg_fx)

def _board_slot(run_value: Run, ui_value: UiState, hero_value: HeroDef, x: U32, y: U32) -> HTML(DungeonEvent):
  _board_slot_at(run_value, ui_value, hero_value, _board_idx(x, y), board_xy_pos(x, y))

def _board_slot_at(run_value: Run, ui_value: UiState, hero_value: HeroDef, idx: U32, pos: Nat/V2) -> HTML(DungeonEvent):
  match ui_value:
    case ui_state{hp_fx, dmg_fx, impact_value, damage_overlay, deck_counter_fx}:
      _board_slot_node(idx, pos, impact_value, _board_card_at(run_value, ui_value, hero_value, idx, pos))

def _board_slot_node(idx: U32, pos: Nat/V2, impact_value: Impact, body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  <div class={_board_slot_class(pos, impact_value)}>
    {body}
  </div>

def _board_slot_class(pos: Nat/V2, impact_value: Impact) -> String:
  match impact_value:
    case no_impact{}:
      "board-slot"
    case impact{impact_pos, fx}:
      _board_slot_class_match(same_pos(pos, impact_pos), fx)

def _board_slot_class_match(matched: U32, impact_fx: ImpactFx) -> String:
  match matched:
    case 0:
      "board-slot"
    case _:
      _board_slot_impact_class(impact_fx)

def _board_slot_impact_class(impact_fx: ImpactFx) -> String:
  match impact_fx:
    case impact_hit_a{}:
      "board-slot board-slot--impact-a"
    case impact_hit_b{}:
      "board-slot board-slot--impact-b"
    case impact_kill_a{}:
      "board-slot board-slot--kill-a"
    case impact_kill_b{}:
      "board-slot board-slot--kill-b"

def _ultimate_button(scene_value: Scene) -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    ultimate{},
    large{},
    ultimate_label(scene_value),
    _full_button_overrides(ultimate_enabled(scene_value))
  )

def _game_over_ok_button() -> HTML(DungeonEvent):
  Button.primary(DungeonEvent, ok{}, medium{}, Content.ui_game_over_ok(), [width_full{}])

def _resume_dungeon_button() -> HTML(DungeonEvent):
  Button.primary(DungeonEvent, resume_dungeon{}, large{}, Content.ui_game_over_resume_dungeon(), [width_full{}])

def _resume_menu_button() -> HTML(DungeonEvent):
  Button.secondary(DungeonEvent, abandon_dungeon{}, medium{}, Content.ui_game_over_main_menu(), [width_full{}])
