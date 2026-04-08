import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Weapon as Weapon
import /Dungeon/Board as Board
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/Run as Run
import /Dungeon/SwipeResult as SwipeResult
import /Dungeon/Direction as Direction
import /Dungeon/Run/apply_to_tile/_apply_to_tile as _apply_to_tile
import /Dungeon/Board/indexing/adjacent_pos as adjacent_pos
import /Dungeon/Board/indexing/board_index as board_index
import /Dungeon/Board/indexing/board_get_pos as board_get_pos

def _keep_run(meta_state: Meta, run_value: Run) -> SwipeResult:
  swipe_result{meta_state, keep_running{run_value}}

def apply_swipe(config_value: Config, meta_state: Meta, run_value: Run, dir: Direction) -> SwipeResult:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      _apply_swipe_target(
        config_value,
        meta_state,
        dungeon_level,
        hero_hp,
        hero_max_hp,
        hero_index,
        weapon_value,
        board_value,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        dir,
        adjacent_pos(hero_index, dir)
      )

def _apply_swipe_target(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Direction, target: Maybe(Nat/V2)) -> SwipeResult:
  match target:
    case none{}:
      _keep_run(meta_state, run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge})
    case some{target_pos}:
      _apply_to_tile(
        config_value,
        meta_state,
        dungeon_level,
        hero_hp,
        hero_max_hp,
        hero_index,
        weapon_value,
        board_value,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        dir,
        board_index(target_pos),
        board_get_pos(board_value, target_pos)
      )
