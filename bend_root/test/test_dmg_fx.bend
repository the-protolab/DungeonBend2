import /dungeon/app/DungeonState
import /dungeon/app/DungeonEvent
import /dungeon/app/on_event as on_event
import /dungeon/logic/Meta
import /dungeon/logic/Run
import /dungeon/logic/Board
import /dungeon/logic/Tile
import /dungeon/logic/Weapon
import /dungeon/logic/Board/empty_board as empty_board
import /dungeon/logic/Board/board_set as board_set

def _eq_u32(a: U32, b: U32) -> U32:
  match a === b:
    case 0:
      0
    case _:
      1

def _is_dmg_up_fx(value: U32) -> U32:
  match value === 1:
    case 0:
      _eq_u32(value, 2)
    case _:
      1

def _is_dmg_down_fx(value: U32) -> U32:
  match value === 3:
    case 0:
      _eq_u32(value, 4)
    case _:
      1

def _run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon) -> Run:
  run{
    1,
    hero_hp,
    hero_max_hp,
    4,
    weapon_value,
    board_value,
    [deck_entry{1, 0, 1}],
    [deck_entry{1, 0, 1}],
    1,
    20,
    5,
    0
  }

def _weapon_damage(weapon_value: Weapon) -> U32:
  match weapon_value:
    case no_weapon{}:
      0
    case weapon{ref, dmg}:
      dmg

def _assert_dmg_fx(
  after_pickup: DungeonState,
  after_pickup_clear: DungeonState,
  after_hit: DungeonState,
  after_hit_clear: DungeonState,
) -> U32:
  match after_pickup:
    case run_screen{meta_a, run_a, next_seed_a, hp_fx_a, dmg_fx_a}:
      match run_a:
        case run{lvl_a, hp_a, max_a, idx_a, weapon_a, board_a, deck_a, draw_a, rem_a, cap_a, seed_a, status_a}:
          match after_pickup_clear:
            case run_screen{meta_b, run_b, next_seed_b, hp_fx_b, dmg_fx_b}:
              match run_b:
                case run{lvl_b, hp_b, max_b, idx_b, weapon_b, board_b, deck_b, draw_b, rem_b, cap_b, seed_b, status_b}:
                  match after_hit:
                    case run_screen{meta_c, run_c, next_seed_c, hp_fx_c, dmg_fx_c}:
                      match run_c:
                        case run{lvl_c, hp_c, max_c, idx_c, weapon_c, board_c, deck_c, draw_c, rem_c, cap_c, seed_c, status_c}:
                          match after_hit_clear:
                            case run_screen{meta_d, run_d, next_seed_d, hp_fx_d, dmg_fx_d}:
                              match run_d:
                                case run{lvl_d, hp_d, max_d, idx_d, weapon_d, board_d, deck_d, draw_d, rem_d, cap_d, seed_d, status_d}:
                                  _eq_u32(idx_a, 1)
                                  * _eq_u32(_weapon_damage(weapon_a), 5)
                                  * _eq_u32(hp_fx_a, 0)
                                  * _is_dmg_up_fx(dmg_fx_a)
                                  * _eq_u32(idx_b, 0)
                                  * _eq_u32(_weapon_damage(weapon_b), 5)
                                  * _eq_u32(dmg_fx_b, 0)
                                  * _eq_u32(idx_c, 4)
                                  * _eq_u32(_weapon_damage(weapon_c), 2)
                                  * _eq_u32(hp_fx_c, 0)
                                  * _is_dmg_down_fx(dmg_fx_c)
                                  * _eq_u32(idx_d, 4)
                                  * _eq_u32(_weapon_damage(weapon_d), 2)
                                  * _eq_u32(dmg_fx_d, 0)
                            case _:
                              0
                    case _:
                      0
            case _:
              0
    case _:
      0

def main() -> U32:
  pickup_board = board_set(board_set(empty_board(), 1, sword{0, 5}), 0, gold{2});
  hit_board = board_set(empty_board(), 1, monster{0, 3});
  pickup_state = on_event(turn_up{}, run_screen{meta{0, 0}, _run_with(pickup_board, 10, 10, no_weapon{}), 9, 0, 0});
  pickup_clear_state = on_event(turn_left{}, pickup_state);
  hit_state = on_event(turn_up{}, run_screen{meta{0, 0}, _run_with(hit_board, 10, 10, weapon{0, 5}), 9, 0, 0});
  hit_clear_state = on_event(turn_left{}, hit_state);
  _assert_dmg_fx(pickup_state, pickup_clear_state, hit_state, hit_clear_state)

def test_dmg_fx() -> U32:
  main()
