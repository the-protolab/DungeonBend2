import /Dungeon/Meta as Meta
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/config as config
import /Dungeon/default_ui as default_ui
import /Dungeon/App/state_helpers/_state as _state
import /Dungeon/App/state_helpers/_start as _start
import /Dungeon/Run/upgrade_hero as upgrade_hero

def update_setup(evt: DungeonEvent, meta_state: Meta, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case start{}:
      _start(meta_state, next_seed_value)
    case upgrade{}:
      _state(upgrade_hero(config(), meta_state), setup{}, next_seed_value, default_ui())
    case _:
      _state(meta_state, setup{}, next_seed_value, ui_value)
