import /HTML/
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/View/frame/_frame as _frame
import /Dungeon/View/frame/_screen_root as _screen_root

def render(state: DungeonState) -> HTML(DungeonEvent):
  match state:
    case dungeon{game_state{meta_state, scene_value, next_seed_value}, ui_value}:
      _frame(_screen_root(meta_state, scene_value, ui_value))
