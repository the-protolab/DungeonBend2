import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Weapon as Weapon
import /Dungeon/Tile as Tile
import /Dungeon/Board as Board
import /Dungeon/DrawResult as DrawResult
import /Dungeon/CombatResult as CombatResult
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/Run as Run
import /Dungeon/SwipeResult as SwipeResult
import /Dungeon/Direction as Direction
import /Dungeon/Deck/spawn_and_draw/draw_tile as draw_tile
import /Dungeon/Board/shift_after_move as shift_after_move
import /Dungeon/Combat/resolve_and_apply/resolve_monster as resolve_monster

def _min_u32(a: U32, b: U32) -> U32:
  _min_u32_flag(a < b, a, b)

def _min_u32_flag(a_lt_b: U32, a: U32, b: U32) -> U32:
  match a_lt_b:
    case 0:
      b
    case _:
      a

def _add_gold(meta_state: Meta, amount: U32) -> Meta:
  match meta_state:
    case meta{hero_level, gold}:
      meta{hero_level, gold + amount}

def _keep_run(meta_state: Meta, run_value: Run) -> SwipeResult:
  swipe_result{meta_state, keep_running{run_value}}

def _end_run(meta_state: Meta, run_value: Run) -> SwipeResult:
  swipe_result{meta_state, end_run{run_value}}

def _move_after_collect_from_draw(meta_state: Meta, hero_hp: U32, hero_max_hp: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), capacity: U32, ult_charge: U32, result: DrawResult, dir: Direction) -> SwipeResult:
  match result:
    case draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      _keep_run(
        meta_state,
        run{
          next_level,
          hero_hp,
          hero_max_hp,
          target_index,
          weapon_value,
          shift_after_move(board_value, hero_index, target_index, dir, spawn),
          deck_blueprint,
          next_counts,
          next_remaining,
          capacity,
          next_seed_value,
          ult_charge
        }
      )

def _move_after_collect(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Direction) -> SwipeResult:
  _move_after_collect_from_draw(
    meta_state,
    hero_hp,
    hero_max_hp,
    hero_index,
    target_index,
    weapon_value,
    board_value,
    deck_blueprint,
    capacity,
    ult_charge,
    draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, dungeon_level),
    dir
  )

def _combat_run(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32) -> Run:
  run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}

def _from_combat(meta_state: Meta, dungeon_level: U32, hero_max_hp: U32, hero_index: U32, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, result: CombatResult) -> SwipeResult:
  match result:
    case combat_result{next_hp, next_weapon, next_board, combat_continue{}}:
      _keep_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge))
    case combat_result{next_hp, next_weapon, next_board, combat_game_over{}}:
      _end_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge))

def _apply_to_tile(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Direction, target_index: U32, tile_value: Tile) -> SwipeResult:
  match tile_value:
    case none{}:
      _keep_run(meta_state, run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge})
    case monster{ref, hp}:
      _from_combat(
        meta_state,
        dungeon_level,
        hero_max_hp,
        hero_index,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        resolve_monster(config_value, board_value, hero_hp, weapon_value, target_index, ref, hp)
      )
    case sword{ref, dmg}:
      _move_after_collect(config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_index, target_index, weapon{ref, dmg}, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
    case potion{ref, heal}:
      _move_after_collect(config_value, meta_state, dungeon_level, _min_u32(hero_max_hp, hero_hp + heal), hero_max_hp, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
    case gold{amount}:
      _move_after_collect(config_value, _add_gold(meta_state, amount), dungeon_level, hero_hp, hero_max_hp, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
