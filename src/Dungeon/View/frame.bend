import /HTML/
import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/Scene as Scene
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/App/key_event as key_event
import /Dungeon/View/css as css
import /Dungeon/View/menu/_render_menu as _render_menu
import /Dungeon/View/board/_render_dungeon as _render_dungeon
import /Midum/screen as screen

def _frame(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  screen(
    DungeonEvent,
    <div class="page" tabindex="0" autofocus="autofocus" style="outline:none" on_key_down={key_event}>
      <style>{text{css()}}</style>
      {body}
    </div>
  )

def _screen_root(meta_state: Meta, scene_value: Scene, ui_value: UiState) -> HTML(DungeonEvent):
  match scene_value:
    case setup{}:
      _render_menu(meta_state)
    case running{run_value}:
      _render_dungeon(meta_state, running{run_value}, run_value, ui_value)
    case game_over{run_value}:
      _render_dungeon(meta_state, game_over{run_value}, run_value, ui_value)
