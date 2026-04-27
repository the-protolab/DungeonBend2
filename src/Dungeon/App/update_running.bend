import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Weapon as Weapon
import /Dungeon/BoardDraw as BoardDraw
import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/RunAdvance as RunAdvance
import /Dungeon/SwipeResult as SwipeResult
import /Dungeon/Direction as Direction
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/config as config
import /Dungeon/Run/apply_swipe as apply_swipe
import /Dungeon/App/state_helpers/_state as _state
import /Dungeon/App/ui_fx/_next_ui_from_turn as _next_ui_from_turn
import /Dungeon/App/ui_fx/_advance_with_charge as _advance_with_charge
import /Dungeon/App/ui_fx/_step_ui_fx as _step_ui_fx
import /Dungeon/UltimateCutins/duration_ticks_for_hero_ref as duration_ticks_for_hero_ref
import /Dungeon/rules/ultimate_charge_required as ultimate_charge_required

def _state_from_swipe(result: SwipeResult, current_run: Run, next_seed_value: U32, current_ui: UiState, dir: Direction) -> DungeonState:
  match result:
    case swipe_result{next_meta, next_advance}:
      _state_from_advance(_advance_with_charge(current_run, next_advance), next_meta, current_run, next_seed_value, current_ui, dir)

def _state_from_advance(advance: RunAdvance, next_meta: Meta, current_run: Run, next_seed_value: U32, current_ui: UiState, dir: Direction) -> DungeonState:
  match advance:
    case keep_running{next_run}:
      _state(next_meta, running{next_run}, next_seed_value, _next_ui_from_turn(current_run, next_run, current_ui, dir))
    case end_run{next_run}:
      _state(next_meta, game_over{next_run}, next_seed_value, _next_ui_from_turn(current_run, next_run, current_ui, dir))

def _apply_turn(meta_state: Meta, run_value: Run, next_seed_value: U32, dir: Direction, current_ui: UiState) -> DungeonState:
  _state_from_swipe(apply_swipe(config(), meta_state, run_value, dir), run_value, next_seed_value, current_ui, dir)

def _run_hero_ref(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      hero_ref

def _start_ultimate_cinematic(meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  _state(meta_state, ultimate_cinematic{run_value, duration_ticks_for_hero_ref(_run_hero_ref(run_value))}, next_seed_value, ui_value)

def _ultimate_ready_charge(ult_charge: U32) -> U32:
  _ultimate_ready_charge_flag(ult_charge < ultimate_charge_required())

def _ultimate_ready_charge_flag(charge_lt_required: U32) -> U32:
  match charge_lt_required:
    case 0:
      1
    case _:
      0

def _ultimate_ready(run_value: Run) -> U32:
  _ultimate_ready_match(run_value)

def _ultimate_ready_match(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _ultimate_ready_charge(ult_charge)

def _update_running_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  _update_running_ultimate_ready(_ultimate_ready(run_value), meta_state, run_value, next_seed_value, ui_value)

def _update_running_ultimate_ready(ultimate_ready_value: U32, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match ultimate_ready_value:
    case 0:
      _state(meta_state, running{run_value}, next_seed_value, ui_value)
    case _:
      _start_ultimate_cinematic(meta_state, run_value, next_seed_value, ui_value)

def update_running(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case damage_tick{}:
      _state(meta_state, running{run_value}, next_seed_value, _step_ui_fx(ui_value))
    case pause_dungeon{}:
      _state(meta_state, paused{run_value}, next_seed_value, ui_value)
    case ultimate{}:
      _update_running_ultimate(meta_state, run_value, next_seed_value, ui_value)
    case move{dir}:
      _apply_turn(meta_state, run_value, next_seed_value, dir, ui_value)
    case _:
      _state(meta_state, running{run_value}, next_seed_value, ui_value)
