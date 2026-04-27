import /Dungeon/Meta as Meta
import /Dungeon/SavedScene as SavedScene
import /Dungeon/Scene as Scene
import /Dungeon/GameState as GameState
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/default_ui as default_ui
import /Dungeon/App/update_setup as update_setup
import /Dungeon/App/update_character_select as update_character_select
import /Dungeon/App/update_boosters as update_boosters
import /Dungeon/App/update_ultimate_preview as update_ultimate_preview
import /Dungeon/App/update_running as update_running
import /Dungeon/App/update_paused as update_paused
import /Dungeon/App/update_ultimate_cinematic as update_ultimate_cinematic
import /Dungeon/App/update_resume_prompt as update_resume_prompt
import /Dungeon/App/update_game_over as update_game_over
import /Dungeon/profile_helpers/set_selection_confirmed as set_selection_confirmed

def _next_state_scene(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match state:
    case dungeon{game_state{meta_state, setup{}, next_seed_value}, ui_value}:
      update_setup(evt, meta_state, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, character_select{preview_hero}, next_seed_value}, ui_value}:
      update_character_select(evt, meta_state, preview_hero, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, boosters{reward, reveal_index, return_to}, next_seed_value}, ui_value}:
      update_boosters(evt, meta_state, reward, reveal_index, return_to, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, ultimate_preview{fx}, next_seed_value}, ui_value}:
      update_ultimate_preview(evt, meta_state, fx, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, ultimate_cinematic{run_value, ticks_remaining}, next_seed_value}, ui_value}:
      update_ultimate_cinematic(evt, meta_state, run_value, ticks_remaining, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, running{run_value}, next_seed_value}, ui_value}:
      update_running(evt, meta_state, run_value, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, paused{run_value}, next_seed_value}, ui_value}:
      update_paused(evt, meta_state, run_value, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, resume_prompt{run_value}, next_seed_value}, ui_value}:
      update_resume_prompt(evt, meta_state, run_value, next_seed_value, ui_value)
    case dungeon{game_state{meta_state, game_over{run_value}, next_seed_value}, ui_value}:
      update_game_over(evt, meta_state, run_value, next_seed_value, ui_value)

def _restore_saved_scene(saved_scene: SavedScene) -> Scene:
  match saved_scene:
    case saved_setup{}:
      setup{}
    case saved_character_select{preview_hero}:
      setup{}
    case saved_boosters{reward, reveal_index}:
      setup{}
    case saved_running{run_value}:
      resume_prompt{run_value}

def _loaded_meta_for_scene(saved_scene: SavedScene, loaded_meta: Meta) -> Meta:
  match saved_scene:
    case saved_running{run_value}:
      loaded_meta
    case _:
      set_selection_confirmed(loaded_meta, 1)

def _apply_loaded_meta(loaded_meta: Meta, saved_scene: SavedScene, loaded_next_seed: U32, state: DungeonState) -> DungeonState:
  match state:
    case dungeon{game_state{old_meta, scene, seed}, ui}:
      dungeon{game_state{_loaded_meta_for_scene(saved_scene, loaded_meta), _restore_saved_scene(saved_scene), loaded_next_seed}, default_ui()}

def _next_state(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match evt:
    case loaded{loaded_meta, saved_scene, loaded_next_seed}:
      _apply_loaded_meta(loaded_meta, saved_scene, loaded_next_seed, state)
    case no_save{}:
      state
    case _:
      _next_state_scene(evt, state)
