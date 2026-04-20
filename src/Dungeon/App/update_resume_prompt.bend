import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/default_ui as default_ui
import /Dungeon/App/state_helpers/_state as _state
import /Dungeon/App/ui_fx/_step_ui_damage_overlay as _step_ui_damage_overlay

def update_resume_prompt(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case damage_tick{}:
      _state(meta_state, resume_prompt{run_value}, next_seed_value, _step_ui_damage_overlay(ui_value))
    case resume_dungeon{}:
      _state(meta_state, running{run_value}, next_seed_value, default_ui())
    case abandon_dungeon{}:
      _state(meta_state, setup{}, next_seed_value, default_ui())
    case _:
      _state(meta_state, resume_prompt{run_value}, next_seed_value, ui_value)
