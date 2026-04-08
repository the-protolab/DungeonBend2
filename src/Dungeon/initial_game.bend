import /Dungeon/GameState as GameState
import /Dungeon/Scene as Scene
import /Dungeon/default_meta as default_meta
import /Dungeon/initial_seed as initial_seed

def initial_game() -> GameState:
  game_state{default_meta(), setup{}, initial_seed()}
