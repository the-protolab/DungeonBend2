import /Dungeon/Meta as Meta
import /Dungeon/Scene as Scene
import /Dungeon/GameState as GameState
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/App/update_setup as update_setup
import /Dungeon/App/update_running as update_running
import /Dungeon/App/update_game_over as update_game_over

def _next_state_scene(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match state:
    case dungeon{game_state{meta_state, setup{}, next_seed_value}, ui_value}:
      update_setup(evt, meta_state, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, running{run_value}, next_seed_value}, ui_value}:
      update_running(evt, meta_state, run_value, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, game_over{run_value}, next_seed_value}, ui_value}:
      update_game_over(evt, meta_state, run_value, next_seed_value, ui_value)

def _apply_loaded_meta(loaded_meta: Meta, state: DungeonState) -> DungeonState:
  match state:
    case dungeon{game_state{old_meta, scene, seed}, ui}:
      dungeon{game_state{loaded_meta, scene, seed}, ui}

def _next_state(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match evt:
    case loaded{hero_level, gold}:
      _apply_loaded_meta(meta{hero_level, gold}, state)
    case no_save{}:
      state
    case _:
      _next_state_scene(evt, state)
