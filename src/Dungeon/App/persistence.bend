import /App/
import /Dungeon/meta_to_string as meta_to_string
import /Dungeon/Meta as Meta
import /Dungeon/Scene as Scene
import /Dungeon/GameState as GameState
import /Dungeon/UiState as UiState
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState

def _get_meta(state: DungeonState) -> Meta:
  match state:
    case dungeon{game_state{meta_state, scene, seed}, ui}:
      meta_state

def _meta_changed(prev: Meta, next: Meta) -> U32:
  match prev next:
    case meta{pl, pg} meta{nl, ng}:
      _either_changed(pl === nl, pg === ng)

def _either_changed(level_same: U32, gold_same: U32) -> U32:
  match level_same gold_same:
    case 0 _: 1
    case _ 0: 1
    case _ _: 0

def _maybe_save(changed: U32, next_state: DungeonState) -> App/Update(DungeonState, DungeonEvent):
  match changed:
    case 0:
      update{next_state, none{}}
    case _:
      update{next_state, store_set{"dungeon_meta", meta_to_string(_get_meta(next_state))}}

def finalize_update(prev_state: DungeonState, next_state: DungeonState) -> App/Update(DungeonState, DungeonEvent):
  _maybe_save(_meta_changed(_get_meta(prev_state), _get_meta(next_state)), next_state)
