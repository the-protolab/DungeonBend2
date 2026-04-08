import /Dungeon/Meta as Meta
import /Dungeon/Scene as Scene
import /Dungeon/GameState as GameState
import /Dungeon/UiState as UiState
import /Dungeon/DungeonState as DungeonState
import /Dungeon/config as config
import /Dungeon/default_ui as default_ui
import /Dungeon/Deck/counts_pick/next_seed as next_seed
import /Dungeon/Run/start_run as start_run

def _state(meta_state: Meta, scene_value: Scene, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  dungeon{game_state{meta_state, scene_value, next_seed_value}, ui_value}

def _start(meta_state: Meta, seed: U32) -> DungeonState:
  _state(meta_state, running{start_run(config(), meta_state, seed)}, next_seed(seed), default_ui())
