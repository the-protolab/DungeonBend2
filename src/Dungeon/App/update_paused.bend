import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/default_ui as default_ui
import /Dungeon/App/state_helpers/_state as _state

def update_paused(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case resume_dungeon{}:
      _state(meta_state, running{run_value}, next_seed_value, ui_value)
    case abandon_dungeon{}:
      _state(meta_state, setup{}, next_seed_value, default_ui())
    case _:
      _state(meta_state, paused{run_value}, next_seed_value, ui_value)
