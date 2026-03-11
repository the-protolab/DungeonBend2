import /dungeon/data/config as config
import /dungeon/data/default_meta as default_meta
import /dungeon/data/initial_seed as initial_seed
import /dungeon/logic/Meta
import /dungeon/logic/Run
import /dungeon/logic/Deck/next_seed as next_seed
import /dungeon/logic/Run/start_run as start_run
import /dungeon/app/DungeonState
import /dungeon/app/DungeonEvent
import /dungeon/app/render as render
import /dungeon/app/on_event as on_event

def _state_from_run(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      current = (run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status} :: Run);
      match status === 0:
        case 0:
          (game_over{meta_state, current, next_seed_value, 0, 0} :: DungeonState)
        case _:
          (run_screen{meta_state, current, next_seed_value, 0, 0} :: DungeonState)

def _initial_state(meta_state: Meta, seed: U32) -> DungeonState:
  next = next_seed(seed);
  _state_from_run(meta_state, start_run(config(), meta_state, seed), next)

main : App =
  app{
    DungeonState,
    DungeonEvent,
    _initial_state(default_meta(), initial_seed()),
    render,
    on_event
  }
