import /dungeon/data/config as config
import /dungeon/logic/Meta
import /dungeon/logic/Run
import /dungeon/logic/SwipeResult
import /dungeon/logic/Weapon
import /dungeon/logic/Deck/next_seed as next_seed
import /dungeon/logic/Run/start_run as start_run
import /dungeon/logic/Run/upgrade_hero as upgrade_hero
import /dungeon/logic/Run/apply_swipe as apply_swipe
import /dungeon/app/DungeonState
import /dungeon/app/DungeonEvent

def _state_from_run(meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> DungeonState:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      current = (run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status} :: Run);
      match status === 0:
        case 0:
          (game_over{meta_state, current, next_seed_value, hp_fx, dmg_fx} :: DungeonState)
        case _:
          (run_screen{meta_state, current, next_seed_value, hp_fx, dmg_fx} :: DungeonState)

def _start(meta_state: Meta, seed: U32) -> DungeonState:
  next = next_seed(seed);
  _state_from_run(meta_state, start_run(config(), meta_state, seed), next, 0, 0)

def _hero_hp(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_hp

def _weapon_dmg(weapon_value: Weapon) -> U32:
  match weapon_value:
    case no_weapon{}:
      0
    case weapon{ref, dmg}:
      dmg

def _hero_dmg(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      _weapon_dmg(weapon)

def _toggle_heal_fx(hp_fx: U32) -> U32:
  match hp_fx === 1:
    case 0:
      1
    case _:
      2

def _toggle_hurt_fx(hp_fx: U32) -> U32:
  match hp_fx === 3:
    case 0:
      3
    case _:
      4

def _toggle_dmg_up_fx(dmg_fx: U32) -> U32:
  match dmg_fx === 1:
    case 0:
      1
    case _:
      2

def _toggle_dmg_down_fx(dmg_fx: U32) -> U32:
  match dmg_fx === 3:
    case 0:
      3
    case _:
      4

def _next_hp_fx(current_run: Run, next_run: Run, current_hp_fx: U32) -> U32:
  current_hp = _hero_hp(current_run);
  next_hp = _hero_hp(next_run);
  match current_hp < next_hp:
    case 0:
      match next_hp < current_hp:
        case 0:
          0
        case _:
          _toggle_hurt_fx(current_hp_fx)
    case _:
      _toggle_heal_fx(current_hp_fx)

def _next_dmg_fx(current_run: Run, next_run: Run, current_dmg_fx: U32) -> U32:
  current_dmg = _hero_dmg(current_run);
  next_dmg = _hero_dmg(next_run);
  match current_dmg < next_dmg:
    case 0:
      match next_dmg < current_dmg:
        case 0:
          0
        case _:
          _toggle_dmg_down_fx(current_dmg_fx)
    case _:
      _toggle_dmg_up_fx(current_dmg_fx)

def _state_from_swipe(result: SwipeResult, current_run: Run, next_seed_value: U32, current_hp_fx: U32, current_dmg_fx: U32) -> DungeonState:
  match result:
    case swipe_result{next_meta, next_run}:
      _state_from_run(
        next_meta,
        next_run,
        next_seed_value,
        _next_hp_fx(current_run, next_run, current_hp_fx),
        _next_dmg_fx(current_run, next_run, current_dmg_fx)
      )

def _apply_turn(meta_state: Meta, run_value: Run, next_seed_value: U32, dir: U32, current_hp_fx: U32, current_dmg_fx: U32) -> DungeonState:
  result = (apply_swipe(config(), meta_state, run_value, dir) :: SwipeResult);
  _state_from_swipe(result, run_value, next_seed_value, current_hp_fx, current_dmg_fx)

def _hub_event(evt: DungeonEvent, meta_state: Meta, next_seed_value: U32) -> DungeonState:
  match evt:
    case start{}:
      _start(meta_state, next_seed_value)
    case restart{}:
      _start(meta_state, next_seed_value)
    case upgrade{}:
      hub{upgrade_hero(config(), meta_state), next_seed_value}
    case _:
      hub{meta_state, next_seed_value}

def _run_event(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> DungeonState:
  match evt:
    case turn_up{}:
      _apply_turn(meta_state, run_value, next_seed_value, 0, hp_fx, dmg_fx)
    case turn_down{}:
      _apply_turn(meta_state, run_value, next_seed_value, 1, hp_fx, dmg_fx)
    case turn_left{}:
      _apply_turn(meta_state, run_value, next_seed_value, 2, hp_fx, dmg_fx)
    case turn_right{}:
      _apply_turn(meta_state, run_value, next_seed_value, 3, hp_fx, dmg_fx)
    case back_to_hub{}:
      hub{meta_state, next_seed_value}
    case restart{}:
      _start(meta_state, next_seed_value)
    case _:
      run_screen{meta_state, run_value, next_seed_value, hp_fx, dmg_fx}

def _game_over_event(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> DungeonState:
  match evt:
    case start{}:
      _start(meta_state, next_seed_value)
    case restart{}:
      _start(meta_state, next_seed_value)
    case back_to_hub{}:
      hub{meta_state, next_seed_value}
    case _:
      game_over{meta_state, run_value, next_seed_value, hp_fx, dmg_fx}

def on_event(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match state:
    case hub{meta_state, next_seed}:
      _hub_event(evt, meta_state, next_seed)
    case run_screen{meta_state, run_value, next_seed, hp_fx, dmg_fx}:
      _run_event(evt, meta_state, run_value, next_seed, hp_fx, dmg_fx)
    case game_over{meta_state, run_value, next_seed, hp_fx, dmg_fx}:
      _game_over_event(evt, meta_state, run_value, next_seed, hp_fx, dmg_fx)
