import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Board as Board
import /Dungeon/BoardDraw as BoardDraw
import /Dungeon/DrawResult as DrawResult
import /Dungeon/Config as Config
import /Dungeon/Deck/spawn_and_draw/draw_tile as draw_tile
import /Dungeon/Board/indexing/board_set as board_set

def _draw_into_slot(board_value: Board, slot: U32, result: DrawResult) -> BoardDraw:
  match result:
    case draw_result{tile, next_counts, next_remaining, next_seed, next_level}:
      board_draw{board_set(board_value, slot, tile), next_counts, next_remaining, next_seed, next_level}

def _draw_step(config_value: Config, board_value: Board, slot: U32, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, seed: U32, level: U32) -> BoardDraw:
  _draw_into_slot(board_value, slot, draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, level))

def _draw_non_hero_step(config_value: Config, hero_index: U32, slot: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board_value, counts, remaining, seed, level}:
      _draw_non_hero_step_match(slot === hero_index, config_value, board_value, slot, blueprint, counts, remaining, seed, level)

def _draw_non_hero_step_match(is_hero_slot: U32, config_value: Config, board_value: Board, slot: U32, blueprint: List(DeckEntry), counts: List(DeckEntry), remaining: U32, seed: U32, level: U32) -> BoardDraw:
  match is_hero_slot:
    case 0:
      _draw_step(config_value, board_value, slot, blueprint, counts, remaining, seed, level)
    case _:
      board_draw{board_value, counts, remaining, seed, level}

def _refill_after_1(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board1, counts1, remaining1, seed1, level1}:
      _refill_after_2(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 1, blueprint, board_draw{board1, counts1, remaining1, seed1, level1}))

def _refill_after_2(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board2, counts2, remaining2, seed2, level2}:
      _refill_after_3(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 2, blueprint, board_draw{board2, counts2, remaining2, seed2, level2}))

def _refill_after_3(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board3, counts3, remaining3, seed3, level3}:
      _refill_after_4(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 3, blueprint, board_draw{board3, counts3, remaining3, seed3, level3}))

def _refill_after_4(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board4, counts4, remaining4, seed4, level4}:
      _refill_after_5(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 4, blueprint, board_draw{board4, counts4, remaining4, seed4, level4}))

def _refill_after_5(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board5, counts5, remaining5, seed5, level5}:
      _refill_after_6(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 5, blueprint, board_draw{board5, counts5, remaining5, seed5, level5}))

def _refill_after_6(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board6, counts6, remaining6, seed6, level6}:
      _refill_after_7(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 6, blueprint, board_draw{board6, counts6, remaining6, seed6, level6}))

def _refill_after_7(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board7, counts7, remaining7, seed7, level7}:
      _refill_after_8(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 7, blueprint, board_draw{board7, counts7, remaining7, seed7, level7}))

def _refill_after_8(config_value: Config, hero_index: U32, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board8, counts8, remaining8, seed8, level8}:
      _draw_non_hero_step(config_value, hero_index, 8, blueprint, board_draw{board8, counts8, remaining8, seed8, level8})

def _refill_non_hero_slots(config_value: Config, board_value: Board, hero_index: U32, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, seed: U32, level: U32) -> BoardDraw:
  _refill_after_1(
    config_value,
    hero_index,
    deck_blueprint,
    _draw_non_hero_step(config_value, hero_index, 0, deck_blueprint, board_draw{board_value, draw_counts, remaining, seed, level})
  )
