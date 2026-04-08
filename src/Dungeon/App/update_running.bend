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
import /Dungeon/default_ui as default_ui
import /Dungeon/Board/indexing/empty_board as empty_board
import /Dungeon/Run/refill/_refill_non_hero_slots as _refill_non_hero_slots
import /Dungeon/Run/apply_swipe as apply_swipe
import /Dungeon/App/state_helpers/_state as _state
import /Dungeon/App/ui_fx/_next_ui_from_turn as _next_ui_from_turn
import /Dungeon/App/ui_fx/_advance_with_charge as _advance_with_charge

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

def _ultimate_run_from_values(hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, deck_blueprint: List(DeckEntry), capacity: U32, stage: BoardDraw) -> Run:
  match stage:
    case board_draw{next_board, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, hero_index, weapon_value, next_board, deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0}

def _use_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      stage = _refill_non_hero_slots(config(), empty_board(), hero_index, deck_blueprint, draw_counts, remaining, seed, dungeon_level);
      _state(meta_state, running{_ultimate_run_from_values(hero_hp, hero_max_hp, hero_index, weapon_value, deck_blueprint, capacity, stage)}, next_seed_value, default_ui())

def _ultimate_ready_charge(ult_charge: U32) -> U32:
  match ult_charge:
    case 6:
      1
    case _:
      0

def _ultimate_ready(run_value: Run) -> U32:
  _ultimate_ready_match(run_value)

def _ultimate_ready_match(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      _ultimate_ready_charge(ult_charge)

def _update_running_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  _update_running_ultimate_ready(_ultimate_ready(run_value), meta_state, run_value, next_seed_value, ui_value)

def _update_running_ultimate_ready(ultimate_ready_value: U32, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match ultimate_ready_value:
    case 0:
      _state(meta_state, running{run_value}, next_seed_value, ui_value)
    case _:
      _use_ultimate(meta_state, run_value, next_seed_value)

def update_running(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case ultimate{}:
      _update_running_ultimate(meta_state, run_value, next_seed_value, ui_value)
    case move{dir}:
      _apply_turn(meta_state, run_value, next_seed_value, dir, ui_value)
    case _:
      _state(meta_state, running{run_value}, next_seed_value, ui_value)
