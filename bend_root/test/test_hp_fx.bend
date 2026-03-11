import /dungeon/app/DungeonState
import /dungeon/app/DungeonEvent
import /dungeon/app/on_event as on_event
import /dungeon/logic/Meta
import /dungeon/logic/Run
import /dungeon/logic/Board
import /dungeon/logic/Tile
import /dungeon/logic/Board/empty_board as empty_board
import /dungeon/logic/Board/board_set as board_set

def _eq_u32(a: U32, b: U32) -> U32:
  match a === b:
    case 0:
      0
    case _:
      1

def _is_heal_fx(value: U32) -> U32:
  match value === 1:
    case 0:
      _eq_u32(value, 2)
    case _:
      1

def _is_hurt_fx(value: U32) -> U32:
  match value === 3:
    case 0:
      _eq_u32(value, 4)
    case _:
      1

def _run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32) -> Run:
  run{
    1,
    hero_hp,
    hero_max_hp,
    4,
    no_weapon{},
    board_value,
    [deck_entry{1, 0, 1}],
    [deck_entry{1, 0, 1}],
    1,
    20,
    5,
    0
  }

def _assert_hp_fx(
  after_heal: DungeonState,
  after_heal_clear: DungeonState,
  after_hurt: DungeonState,
  after_hurt_clear: DungeonState,
  after_capped_heal: DungeonState,
) -> U32:
  match after_heal:
    case run_screen{meta_a, run_a, next_seed_a, hp_fx_a, dmg_fx_a}:
      match run_a:
        case run{lvl_a, hp_a, max_a, idx_a, weapon_a, board_a, deck_a, draw_a, rem_a, cap_a, seed_a, status_a}:
          match after_heal_clear:
            case run_screen{meta_b, run_b, next_seed_b, hp_fx_b, dmg_fx_b}:
              match run_b:
                case run{lvl_b, hp_b, max_b, idx_b, weapon_b, board_b, deck_b, draw_b, rem_b, cap_b, seed_b, status_b}:
                  match after_hurt:
                    case run_screen{meta_c, run_c, next_seed_c, hp_fx_c, dmg_fx_c}:
                      match run_c:
                        case run{lvl_c, hp_c, max_c, idx_c, weapon_c, board_c, deck_c, draw_c, rem_c, cap_c, seed_c, status_c}:
                          match after_hurt_clear:
                            case run_screen{meta_d, run_d, next_seed_d, hp_fx_d, dmg_fx_d}:
                              match run_d:
                                case run{lvl_d, hp_d, max_d, idx_d, weapon_d, board_d, deck_d, draw_d, rem_d, cap_d, seed_d, status_d}:
                                  match after_capped_heal:
                                    case run_screen{meta_e, run_e, next_seed_e, hp_fx_e, dmg_fx_e}:
                                      match run_e:
                                        case run{lvl_e, hp_e, max_e, idx_e, weapon_e, board_e, deck_e, draw_e, rem_e, cap_e, seed_e, status_e}:
                                          _eq_u32(hp_a, 10)
                                          * _eq_u32(idx_a, 3)
                                          * _is_heal_fx(hp_fx_a)
                                          * _eq_u32(dmg_fx_a, 0)
                                          * _eq_u32(hp_b, 10)
                                          * _eq_u32(idx_b, 3)
                                          * _eq_u32(hp_fx_b, 0)
                                          * _eq_u32(dmg_fx_b, 0)
                                          * _eq_u32(hp_c, 4)
                                          * _eq_u32(idx_c, 4)
                                          * _is_hurt_fx(hp_fx_c)
                                          * _eq_u32(dmg_fx_c, 0)
                                          * _eq_u32(hp_d, 4)
                                          * _eq_u32(idx_d, 1)
                                          * _eq_u32(hp_fx_d, 0)
                                          * _eq_u32(dmg_fx_d, 0)
                                          * _eq_u32(hp_e, 10)
                                          * _eq_u32(idx_e, 3)
                                          * _eq_u32(hp_fx_e, 0)
                                          * _eq_u32(dmg_fx_e, 0)
                                    case _:
                                      0
                            case _:
                              0
                    case _:
                      0
            case _:
              0
    case _:
      0

def main() -> U32:
  potion_board = board_set(empty_board(), 3, potion{0, 4});
  hurt_board = board_set(board_set(empty_board(), 1, monster{0, 6}), 0, gold{2});
  healed_state = on_event(turn_left{}, run_screen{meta{0, 0}, _run_with(potion_board, 8, 10), 9, 0, 0});
  heal_cleared_state = on_event(turn_up{}, healed_state);
  hurt_state = on_event(turn_up{}, run_screen{meta{0, 0}, _run_with(hurt_board, 10, 10), 9, 0, 0});
  hurt_cleared_state = on_event(turn_up{}, hurt_state);
  capped_heal_state = on_event(turn_left{}, run_screen{meta{0, 0}, _run_with(potion_board, 10, 10), 9, 0, 0});
  _assert_hp_fx(healed_state, heal_cleared_state, hurt_state, hurt_cleared_state, capped_heal_state)

def test_hp_fx() -> U32:
  main()
