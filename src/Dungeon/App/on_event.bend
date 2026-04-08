import /App/
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/DungeonState as DungeonState
import /Dungeon/App/scene_flow/_next_state as _next_state
import /Dungeon/App/persistence/finalize_update as finalize_update

def on_event(evt: DungeonEvent, state: DungeonState) -> App/Update(DungeonState, DungeonEvent):
  next = _next_state(evt, state);
  finalize_update(state, next)
