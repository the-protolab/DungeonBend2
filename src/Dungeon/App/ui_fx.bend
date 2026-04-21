import /Dungeon/Weapon as Weapon
import /Dungeon/Tile as Tile
import /Dungeon/Board as Board
import /Dungeon/Run as Run
import /Dungeon/RunAdvance as RunAdvance
import /Dungeon/Direction as Direction
import /Dungeon/UiState as UiState
import /Dungeon/HpFx as HpFx
import /Dungeon/DmgFx as DmgFx
import /Dungeon/Impact as Impact
import /Dungeon/ImpactFx as ImpactFx
import /Dungeon/DamageOverlay as DamageOverlay
import /Dungeon/DeckCounterFx as DeckCounterFx
import /Dungeon/Board/indexing/adjacent_pos as adjacent_pos
import /Dungeon/Board/indexing/board_get_pos as board_get_pos
import /Dungeon/monster_damage_animation/clip as monster_damage_clip
import /Dungeon/deck_counter_animation/clip as deck_counter_clip
import /Dungeon/rules/ultimate_charge_required as ultimate_charge_required
import /Dungeon/rules/ultimate_charge_per_move as ultimate_charge_per_move
import /Midum/Image/ as Image

def _hero_hp(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      hero_hp

def _weapon_dmg(weapon_value: Weapon) -> U32:
  match weapon_value:
    case no_weapon{}:
      0
    case weapon{ref, dmg}:
      dmg

def _hero_dmg(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      _weapon_dmg(weapon)

def _run_ult_charge(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      ult_charge

def _run_with_ult_charge(run_value: Run, next_ult_charge: U32) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, next_ult_charge}

def _run_charge_after_gain(current_charge: U32) -> U32:
  _min_u32(ultimate_charge_required(), current_charge + ultimate_charge_per_move())

def _min_u32(a: U32, b: U32) -> U32:
  _min_u32_flag(a < b, a, b)

def _min_u32_flag(a_lt_b: U32, a: U32, b: U32) -> U32:
  match a_lt_b:
    case 0:
      b
    case _:
      a

def _run_hero_index(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      hero_index

def _run_board(run_value: Run) -> Board:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      board_value

def _run_moved(current_run: Run, next_run: Run) -> U32:
  _run_moved_match(_run_hero_index(current_run) === _run_hero_index(next_run))

def _run_moved_match(same_index: U32) -> U32:
  match same_index:
    case 0:
      1
    case _:
      0

def _next_ult_charge(current_run: Run, next_run: Run) -> U32:
  _next_ult_charge_move(_run_moved(current_run, next_run), current_run)

def _next_ult_charge_move(did_move: U32, current_run: Run) -> U32:
  match did_move:
    case 0:
      _run_ult_charge(current_run)
    case _:
      _run_charge_after_gain(_run_ult_charge(current_run))

def _toggle_heal_fx(hp_fx: HpFx) -> HpFx:
  match hp_fx:
    case hp_fx_heal_a{}:
      hp_fx_heal_b{}
    case _:
      hp_fx_heal_a{}

def _toggle_hurt_fx(hp_fx: HpFx) -> HpFx:
  match hp_fx:
    case hp_fx_hurt_a{}:
      hp_fx_hurt_b{}
    case _:
      hp_fx_hurt_a{}

def _toggle_dmg_up_fx(dmg_fx: DmgFx) -> DmgFx:
  match dmg_fx:
    case dmg_fx_up_a{}:
      dmg_fx_up_b{}
    case _:
      dmg_fx_up_a{}

def _toggle_dmg_down_fx(dmg_fx: DmgFx) -> DmgFx:
  match dmg_fx:
    case dmg_fx_down_a{}:
      dmg_fx_down_b{}
    case _:
      dmg_fx_down_a{}

def _next_hp_fx_values(current_hp: U32, next_hp: U32, current_hp_fx: HpFx) -> HpFx:
  _next_hp_fx_gain(current_hp < next_hp, current_hp, next_hp, current_hp_fx)

def _next_hp_fx_gain(hp_grew: U32, current_hp: U32, next_hp: U32, current_hp_fx: HpFx) -> HpFx:
  match hp_grew:
    case 0:
      _next_hp_fx_loss(next_hp < current_hp, current_hp_fx)
    case _:
      _toggle_heal_fx(current_hp_fx)

def _next_hp_fx_loss(hp_dropped: U32, current_hp_fx: HpFx) -> HpFx:
  match hp_dropped:
    case 0:
      hp_fx_none{}
    case _:
      _toggle_hurt_fx(current_hp_fx)

def _next_hp_fx(current_run: Run, next_run: Run, current_hp_fx: HpFx) -> HpFx:
  _next_hp_fx_values(_hero_hp(current_run), _hero_hp(next_run), current_hp_fx)

def _next_dmg_fx_values(current_dmg: U32, next_dmg: U32, current_dmg_fx: DmgFx) -> DmgFx:
  _next_dmg_fx_gain(current_dmg < next_dmg, current_dmg, next_dmg, current_dmg_fx)

def _next_dmg_fx_gain(dmg_grew: U32, current_dmg: U32, next_dmg: U32, current_dmg_fx: DmgFx) -> DmgFx:
  match dmg_grew:
    case 0:
      _next_dmg_fx_loss(next_dmg < current_dmg, current_dmg_fx)
    case _:
      _toggle_dmg_up_fx(current_dmg_fx)

def _next_dmg_fx_loss(dmg_dropped: U32, current_dmg_fx: DmgFx) -> DmgFx:
  match dmg_dropped:
    case 0:
      dmg_fx_none{}
    case _:
      _toggle_dmg_down_fx(current_dmg_fx)

def _next_dmg_fx(current_run: Run, next_run: Run, current_dmg_fx: DmgFx) -> DmgFx:
  _next_dmg_fx_values(_hero_dmg(current_run), _hero_dmg(next_run), current_dmg_fx)

def _toggle_impact_hit_fx(current_impact: Impact) -> ImpactFx:
  match current_impact:
    case impact{pos, impact_hit_a{}}:
      impact_hit_b{}
    case _:
      impact_hit_a{}

def _toggle_impact_kill_fx(current_impact: Impact) -> ImpactFx:
  match current_impact:
    case impact{pos, impact_kill_a{}}:
      impact_kill_b{}
    case _:
      impact_kill_a{}

def _impact_hit(target_pos: Nat/V2, current_impact: Impact) -> Impact:
  impact{target_pos, _toggle_impact_hit_fx(current_impact)}

def _impact_kill(target_pos: Nat/V2, current_impact: Impact) -> Impact:
  impact{target_pos, _toggle_impact_kill_fx(current_impact)}

def _impact_from_monster_hp(target_pos: Nat/V2, prev_hp: U32, next_hp: U32, current_impact: Impact) -> Impact:
  _impact_from_monster_drop(next_hp < prev_hp, target_pos, current_impact)

def _impact_from_monster_drop(monster_took_damage: U32, target_pos: Nat/V2, current_impact: Impact) -> Impact:
  match monster_took_damage:
    case 0:
      no_impact{}
    case _:
      _impact_hit(target_pos, current_impact)

def _impact_from_monster_next(target_pos: Nat/V2, prev_hp: U32, next_tile: Tile, current_impact: Impact) -> Impact:
  match next_tile:
    case monster{next_ref, next_hp}:
      _impact_from_monster_hp(target_pos, prev_hp, next_hp, current_impact)
    case gold{amount}:
      _impact_kill(target_pos, current_impact)
    case _:
      no_impact{}

def _impact_from_target_tile(target_pos: Nat/V2, prev_tile: Tile, next_tile: Tile, current_impact: Impact) -> Impact:
  match prev_tile:
    case monster{ref, prev_hp}:
      _impact_from_monster_next(target_pos, prev_hp, next_tile, current_impact)
    case _:
      no_impact{}

def _impact_from_target_pos(target_pos: Nat/V2, current_run: Run, next_run: Run, current_impact: Impact) -> Impact:
  _impact_from_target_tile(target_pos, board_get_pos(_run_board(current_run), target_pos), board_get_pos(_run_board(next_run), target_pos), current_impact)

def _impact_from_turn(current_run: Run, next_run: Run, dir: Direction, current_impact: Impact) -> Impact:
  _impact_from_adjacent(adjacent_pos(_run_hero_index(current_run), dir), current_run, next_run, current_impact)

def _impact_from_adjacent(target: Maybe(Nat/V2), current_run: Run, next_run: Run, current_impact: Impact) -> Impact:
  match target:
    case none{}:
      no_impact{}
    case some{target_pos}:
      _impact_from_target_pos(target_pos, current_run, next_run, current_impact)

def _damage_overlay_from_impact(prev_tile: Tile, current_overlay: DamageOverlay, impact_value: Impact) -> DamageOverlay:
  match impact_value:
    case no_impact{}:
      current_overlay
    case impact{pos, trigger}:
      damage_overlay{pos, trigger, prev_tile, Image.reset_state()}

def _damage_overlay_from_target_tile(target_pos: Nat/V2, prev_tile: Tile, next_tile: Tile, current_overlay: DamageOverlay, current_impact: Impact) -> DamageOverlay:
  _damage_overlay_from_impact(prev_tile, current_overlay, _impact_from_target_tile(target_pos, prev_tile, next_tile, current_impact))

def _damage_overlay_from_target_pos(target_pos: Nat/V2, current_run: Run, next_run: Run, current_overlay: DamageOverlay, current_impact: Impact) -> DamageOverlay:
  _damage_overlay_from_target_tile(target_pos, board_get_pos(_run_board(current_run), target_pos), board_get_pos(_run_board(next_run), target_pos), current_overlay, current_impact)

def _damage_overlay_from_turn(current_run: Run, next_run: Run, dir: Direction, current_overlay: DamageOverlay, current_impact: Impact) -> DamageOverlay:
  _damage_overlay_from_adjacent(adjacent_pos(_run_hero_index(current_run), dir), current_run, next_run, current_overlay, current_impact)

def _damage_overlay_from_adjacent(target: Maybe(Nat/V2), current_run: Run, next_run: Run, current_overlay: DamageOverlay, current_impact: Impact) -> DamageOverlay:
  match target:
    case none{}:
      current_overlay
    case some{target_pos}:
      _damage_overlay_from_target_pos(target_pos, current_run, next_run, current_overlay, current_impact)

def _step_damage_overlay(current_overlay: DamageOverlay) -> DamageOverlay:
  match current_overlay:
    case no_damage_overlay{}:
      no_damage_overlay{}
    case damage_overlay{pos, trigger, base_tile, overlay_state}:
      match Image.step(monster_damage_clip(), 125n, overlay_state):
        case step{state: next_state, cycled, finished_now}:
          match finished_now:
            case true{}:
              no_damage_overlay{}
            case false{}:
              damage_overlay{pos, trigger, base_tile, next_state}

def _next_deck_counter_fx_move(did_move: U32, current_fx: DeckCounterFx) -> DeckCounterFx:
  match did_move:
    case 0:
      current_fx
    case _:
      deck_counter_playing{Image.reset_state()}

def _next_deck_counter_fx(current_run: Run, next_run: Run, current_fx: DeckCounterFx) -> DeckCounterFx:
  _next_deck_counter_fx_move(_run_moved(current_run, next_run), current_fx)

def _step_deck_counter_fx(current_fx: DeckCounterFx) -> DeckCounterFx:
  match current_fx:
    case deck_counter_idle{}:
      deck_counter_idle{}
    case deck_counter_playing{current_state}:
      match Image.step(deck_counter_clip(), 125n, current_state):
        case step{state: next_state, cycled, finished_now}:
          match finished_now:
            case true{}:
              deck_counter_idle{}
            case false{}:
              deck_counter_playing{next_state}

def _step_ui_fx(ui_value: UiState) -> UiState:
  match ui_value:
    case ui_state{current_hp_fx, current_dmg_fx, current_impact, current_damage_overlay, current_deck_counter_fx}:
      ui_state{
        current_hp_fx,
        current_dmg_fx,
        current_impact,
        _step_damage_overlay(current_damage_overlay),
        _step_deck_counter_fx(current_deck_counter_fx)
      }

def _next_ui_from_turn(current_run: Run, next_run: Run, current_ui: UiState, dir: Direction) -> UiState:
  match current_ui:
    case ui_state{current_hp_fx, current_dmg_fx, current_impact, current_damage_overlay, current_deck_counter_fx}:
      ui_state{
        _next_hp_fx(current_run, next_run, current_hp_fx),
        _next_dmg_fx(current_run, next_run, current_dmg_fx),
        _impact_from_turn(current_run, next_run, dir, current_impact),
        _damage_overlay_from_turn(current_run, next_run, dir, current_damage_overlay, current_impact),
        _next_deck_counter_fx(current_run, next_run, current_deck_counter_fx)
      }

def _advance_with_charge(current_run: Run, advance: RunAdvance) -> RunAdvance:
  match advance:
    case keep_running{next_run}:
      keep_running{_run_with_ult_charge(next_run, _next_ult_charge(current_run, next_run))}
    case end_run{next_run}:
      end_run{_run_with_ult_charge(next_run, _next_ult_charge(current_run, next_run))}
