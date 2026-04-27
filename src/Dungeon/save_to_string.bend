import /U32/ as U32
import /Dungeon/Scene as Scene
import /Dungeon/GameState as GameState
import /Dungeon/UiState as UiState
import /Dungeon/DungeonState as DungeonState
import /Dungeon/meta_to_string as meta_to_string
import /Dungeon/run_snapshot_to_string/run_core_string as run_core_string
import /Dungeon/run_snapshot_to_string/run_weapon_string as run_weapon_string
import /Dungeon/run_snapshot_to_string/run_board_string as run_board_string
import /Dungeon/run_snapshot_to_string/run_blueprint_string as run_blueprint_string
import /Dungeon/run_snapshot_to_string/run_counts_string as run_counts_string

def save_to_string(state: DungeonState) -> String:
  match state:
    case dungeon{game_state{meta_state, scene_value, next_seed}, ui_value}:
      String/join(
        [
          meta_to_string(meta_state),
          U32.show(next_seed),
          _saved_scene_kind(scene_value),
          _saved_run_core(scene_value),
          _saved_run_weapon(scene_value),
          _saved_run_board(scene_value),
          _saved_run_blueprint(scene_value),
          _saved_run_counts(scene_value)
        ],
        "|"
      )

def _saved_scene_kind(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      "1"
    case running{run_value}:
      "1"
    case paused{run_value}:
      "1"
    case resume_prompt{run_value}:
      "1"
    case _:
      "0"

def _saved_run_core(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      run_core_string(run_value)
    case running{run_value}:
      run_core_string(run_value)
    case paused{run_value}:
      run_core_string(run_value)
    case resume_prompt{run_value}:
      run_core_string(run_value)
    case _:
      ""

def _saved_run_weapon(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      run_weapon_string(run_value)
    case running{run_value}:
      run_weapon_string(run_value)
    case paused{run_value}:
      run_weapon_string(run_value)
    case resume_prompt{run_value}:
      run_weapon_string(run_value)
    case _:
      "0"

def _saved_run_board(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      run_board_string(run_value)
    case running{run_value}:
      run_board_string(run_value)
    case paused{run_value}:
      run_board_string(run_value)
    case resume_prompt{run_value}:
      run_board_string(run_value)
    case _:
      ""

def _saved_run_blueprint(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      run_blueprint_string(run_value)
    case running{run_value}:
      run_blueprint_string(run_value)
    case paused{run_value}:
      run_blueprint_string(run_value)
    case resume_prompt{run_value}:
      run_blueprint_string(run_value)
    case _:
      ""

def _saved_run_counts(scene_value: Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      run_counts_string(run_value)
    case running{run_value}:
      run_counts_string(run_value)
    case paused{run_value}:
      run_counts_string(run_value)
    case resume_prompt{run_value}:
      run_counts_string(run_value)
    case _:
      ""
