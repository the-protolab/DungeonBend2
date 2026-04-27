import /HTML/
import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/App/key_event as key_event
import /Dungeon/View/css as css
import /Dungeon/View/assets_and_labels/_dungeon_bg as _dungeon_bg
import /Dungeon/View/menu/_render_menu as _render_menu
import /Dungeon/View/menu/_render_character_select as _render_character_select
import /Dungeon/View/boosters/_render_boosters as _render_boosters
import /Dungeon/View/ultimate_preview/_render_ultimate_preview as _render_ultimate_preview
import /Dungeon/View/board/_render_dungeon as _render_dungeon
import /Dungeon/UltimateCutins/cutin_spec_for_hero_ref as cutin_spec_for_hero_ref
import /Dungeon/UltimateCutins/_render_ultimate_cutin as _render_ultimate_cutin
import /Midum/screen as screen

def _frame(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  screen(
    DungeonEvent,
    <div class="page" tabindex="0" autofocus="autofocus" style="outline:none" on_key_down={key_event}>
      <style>{text{css()}}</style>
      <img
        class="page-preload-image"
        src={_dungeon_bg()}
        alt=""
        aria-hidden="true"
        loading="eager"
        decoding="async"
        fetchpriority="high"
      />
      {body}
    </div>
  )

def _screen_root(meta_state: Meta, scene_value: Scene, ui_value: UiState) -> HTML(DungeonEvent):
  match scene_value:
    case setup{}:
      _render_menu(meta_state)
    case character_select{preview_hero}:
      _render_character_select(meta_state, preview_hero)
    case boosters{reward, reveal_index, return_to}:
      _render_boosters(meta_state, reward, reveal_index)
    case ultimate_preview{fx}:
      _render_ultimate_preview(meta_state, fx)
    case ultimate_cinematic{run_value, ticks_remaining}:
      _render_ultimate_cinematic_scene(meta_state, run_value, ticks_remaining, ui_value)
    case running{run_value}:
      _render_dungeon(meta_state, running{run_value}, run_value, ui_value)
    case paused{run_value}:
      _render_dungeon(meta_state, paused{run_value}, run_value, ui_value)
    case resume_prompt{run_value}:
      _render_dungeon(meta_state, resume_prompt{run_value}, run_value, ui_value)
    case game_over{run_value}:
      _render_dungeon(meta_state, game_over{run_value}, run_value, ui_value)

def _render_ultimate_cinematic_scene(meta_state: Meta, run_value: Run, ticks_remaining: U32, ui_value: UiState) -> HTML(DungeonEvent):
  <div class="screen-root-stack">
    {_render_dungeon(meta_state, ultimate_cinematic{run_value, ticks_remaining}, run_value, ui_value)}
    {_render_ultimate_cinematic_overlay(run_value)}
  </div>

def _render_ultimate_cinematic_overlay(run_value: Run) -> HTML(DungeonEvent):
  <div class="ultimate-cinematic-overlay" aria-hidden="true">
    {_render_ultimate_cutin(cutin_spec_for_hero_ref(_run_hero_ref(run_value)), "ultimate-cutin-stage--play-a")}
  </div>

def _run_hero_ref(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      hero_ref
