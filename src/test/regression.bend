import /main/ as Dungeon
import /main/Meta
import /main/Run
import /main/Board
import /main/Tile
import /main/Weapon
import /main/SwipeResult
import /main/DeckEntry
import /main/DungeonState
import /main/DungeonEvent
import /main/RunSlot

def _eq_u32(a: U32, b: U32) -> U32:
  match a === b:
    case 0:
      0
    case _:
      1

def _meta_from_swipe(result: SwipeResult) -> Meta:
  match result:
    case swipe_result{next_meta, next_run}:
      next_meta

def _run_from_swipe(result: SwipeResult) -> Run:
  match result:
    case swipe_result{next_meta, next_run}:
      next_run

def _slot(tile: Tile) -> U32:
  match tile:
    case none{}:
      0
    case _:
      1

def _populated(board_value: Board, idx: U32) -> U32:
  match idx === 9:
    case 0:
      _slot(Dungeon.board_get(board_value, idx)) + _populated(board_value, idx + 1)
    case _:
      0

def _is_gold(tile: Tile, amount: U32) -> U32:
  match tile:
    case gold{got}:
      _eq_u32(got, amount)
    case _:
      0

def _is_sword(tile: Tile, ref: U32, dmg: U32) -> U32:
  match tile:
    case sword{got_ref, got_dmg}:
      _eq_u32(got_ref, ref) * _eq_u32(got_dmg, dmg)
    case _:
      0

def _is_monster(tile: Tile, ref: U32, hp: U32) -> U32:
  match tile:
    case monster{got_ref, got_hp}:
      _eq_u32(got_ref, ref) * _eq_u32(got_hp, hp)
    case _:
      0

def _is_potion(tile: Tile, ref: U32, heal: U32) -> U32:
  match tile:
    case potion{got_ref, got_heal}:
      _eq_u32(got_ref, ref) * _eq_u32(got_heal, heal)
    case _:
      0

def _weapon_damage(weapon_value: Weapon) -> U32:
  match weapon_value:
    case no_weapon{}:
      0
    case weapon{ref, dmg}:
      dmg

def _state_meta(state: DungeonState) -> Meta:
  match state:
    case dungeon{meta_state, current_run, next_seed_value, hp_fx, dmg_fx}:
      meta_state

def _state_run(state: DungeonState) -> RunSlot:
  match state:
    case dungeon{meta_state, current_run, next_seed_value, hp_fx, dmg_fx}:
      current_run

def _state_next_seed(state: DungeonState) -> U32:
  match state:
    case dungeon{meta_state, current_run, next_seed_value, hp_fx, dmg_fx}:
      next_seed_value

def _state_hp_fx(state: DungeonState) -> U32:
  match state:
    case dungeon{meta_state, current_run, next_seed_value, hp_fx, dmg_fx}:
      hp_fx

def _state_dmg_fx(state: DungeonState) -> U32:
  match state:
    case dungeon{meta_state, current_run, next_seed_value, hp_fx, dmg_fx}:
      dmg_fx

def _meta_level(meta_state: Meta) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      hero_level

def _meta_gold(meta_state: Meta) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      gold

def _run_hp(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_hp

def _run_max_hp(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_max_hp

def _run_index(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_index

def _run_weapon(run_value: Run) -> Weapon:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      weapon

def _run_board(run_value: Run) -> Board:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      board_value

def _run_remaining(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      remaining

def _run_seed(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      seed

def _run_status(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      status

def _maybe_has_run(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      1

def _maybe_run_hp(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _run_hp(run_value)

def _maybe_run_max_hp(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _run_max_hp(run_value)

def _maybe_run_index(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _run_index(run_value)

def _maybe_run_weapon_dmg(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _weapon_damage(_run_weapon(run_value))

def _maybe_run_board(current_run: RunSlot) -> Board:
  match current_run:
    case idle_run{}:
      Dungeon.empty_board()
    case run_slot{run_value}:
      _run_board(run_value)

def _maybe_run_remaining(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _run_remaining(run_value)

def _maybe_run_seed(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _run_seed(run_value)

def _maybe_run_status(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      2
    case run_slot{run_value}:
      _run_status(run_value)

def _assert_idle_state(state: DungeonState, level: U32, gold: U32, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> U32:
  match state:
    case dungeon{meta{got_level, got_gold}, idle_run{}, got_seed, got_hp_fx, got_dmg_fx}:
      _eq_u32(got_level, level)
      * _eq_u32(got_gold, gold)
      * _eq_u32(got_seed, next_seed_value)
      * _eq_u32(got_hp_fx, hp_fx)
      * _eq_u32(got_dmg_fx, dmg_fx)
    case _:
      0

def _idle_state(meta_state: Meta, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> DungeonState:
  dungeon{meta_state, idle_run{}, next_seed_value, hp_fx, dmg_fx}

def _state_with_run(meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32) -> DungeonState:
  dungeon{meta_state, run_slot{run_value}, next_seed_value, hp_fx, dmg_fx}

def _app_run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, status: U32) -> Run:
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
    status
  }

# Start run

def _assert_start_run(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      _eq_u32(hero_index, 4)
      * _eq_u32(_populated(board_value, 0), 8)
      * _eq_u32(remaining, 11)
      * _eq_u32(capacity, 20)
      * _eq_u32(status, 0)

def test_start_run() -> U32:
  _assert_start_run(Dungeon.start_run(Dungeon.config(), Dungeon.default_meta(), Dungeon.initial_seed()))

# Upgrade hero

def _assert_upgrade_pair(affordable: Meta, blocked: Meta) -> U32:
  match affordable:
    case meta{level_a, gold_a}:
      match blocked:
        case meta{level_b, gold_b}:
          _eq_u32(level_a, 1)
          * _eq_u32(gold_a, 5)
          * _eq_u32(level_b, 0)
          * _eq_u32(gold_b, 5)

def test_upgrade_hero() -> U32:
  _assert_upgrade_pair(
    Dungeon.upgrade_hero(Dungeon.config(), meta{0, 25}),
    Dungeon.upgrade_hero(Dungeon.config(), meta{0, 5})
  )

# Items

def _items_run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32) -> Run:
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

def _assert_items(gold_meta: Meta, gold_run: Run, potion_run: Run) -> U32:
  match gold_meta:
    case meta{gold_level, gold_value}:
      match gold_run:
        case run{lvl_a, hp_a, max_a, idx_a, weapon_a, board_a, deck_a, draw_a, rem_a, cap_a, seed_a, status_a}:
          match potion_run:
            case run{lvl_b, hp_b, max_b, idx_b, weapon_b, board_b, deck_b, draw_b, rem_b, cap_b, seed_b, status_b}:
              _eq_u32(gold_value, 4)
              * _eq_u32(idx_a, 1)
              * _is_sword(Dungeon.board_get(board_a, 4), 0, 5)
              * _is_sword(Dungeon.board_get(board_a, 7), 0, 5)
              * _eq_u32(hp_b, 10)
              * _eq_u32(idx_b, 3)

def test_items() -> U32:
  gold_board = Dungeon.board_set(Dungeon.board_set(Dungeon.empty_board(), 1, gold{3}), 7, sword{0, 5});
  potion_board = Dungeon.board_set(Dungeon.empty_board(), 3, potion{0, 4});
  gold_result = Dungeon.apply_swipe(Dungeon.config(), meta{0, 1}, _items_run_with(gold_board, 10, 10), 0);
  potion_result = Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _items_run_with(potion_board, 8, 10), 2);
  _assert_items(_meta_from_swipe(gold_result), _run_from_swipe(gold_result), _run_from_swipe(potion_result))

# Combat unarmed

def _unarmed_run_with(board_value: Board, hero_hp: U32) -> Run:
  run{
    1,
    hero_hp,
    10,
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

def _assert_unarmed(win_run: Run, equal_run: Run, lower_run: Run) -> U32:
  match win_run:
    case run{lvl_a, hp_a, max_a, idx_a, weapon_a, board_a, deck_a, draw_a, rem_a, cap_a, seed_a, status_a}:
      match equal_run:
        case run{lvl_b, hp_b, max_b, idx_b, weapon_b, board_b, deck_b, draw_b, rem_b, cap_b, seed_b, status_b}:
          match lower_run:
            case run{lvl_c, hp_c, max_c, idx_c, weapon_c, board_c, deck_c, draw_c, rem_c, cap_c, seed_c, status_c}:
              _eq_u32(hp_a, 4)
              * _eq_u32(idx_a, 4)
              * _is_gold(Dungeon.board_get(board_a, 1), 3)
              * _eq_u32(status_a, 0)
              * _eq_u32(hp_b, 0)
              * _eq_u32(status_b, 1)
              * _eq_u32(hp_c, 0)
              * _eq_u32(status_c, 1)

def test_combat_unarmed() -> U32:
  _assert_unarmed(
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _unarmed_run_with(Dungeon.board_set(Dungeon.empty_board(), 1, monster{0, 6}), 10), 0)),
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _unarmed_run_with(Dungeon.board_set(Dungeon.empty_board(), 1, monster{0, 3}), 3), 0)),
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _unarmed_run_with(Dungeon.board_set(Dungeon.empty_board(), 1, monster{1, 8}), 4), 0))
  )

# Combat weapon

def _weapon_run_with(board_value: Board, hero_hp: U32, weapon_value: Weapon) -> Run:
  run{
    1,
    hero_hp,
    10,
    4,
    weapon_value,
    board_value,
    [deck_entry{2, 0, 1}],
    [deck_entry{2, 0, 1}],
    1,
    20,
    5,
    0
  }

def _assert_weapon_state(
  weapon_a: Weapon,
  weapon_b: Weapon,
  weapon_c: Weapon,
  hp_a: U32,
  board_a: Board,
  board_b: Board,
  idx_c: U32,
  rem_c: U32,
  seed_c: U32,
  board_c: Board,
) -> U32:
  match weapon_a:
    case weapon{ref_a, dmg_a}:
      match weapon_b:
        case no_weapon{}:
          match weapon_c:
            case no_weapon{}:
              _eq_u32(hp_a, 8)
              * _eq_u32(dmg_a, 2)
              * _is_gold(Dungeon.board_get(board_a, 1), 3)
              * _is_gold(Dungeon.board_get(board_b, 1), 4)
              * _eq_u32(idx_c, 4)
              * _eq_u32(rem_c, 1)
              * _eq_u32(seed_c, 5)
              * _is_monster(Dungeon.board_get(board_c, 1), 2, 2)
              * _is_potion(Dungeon.board_get(board_c, 7), 0, 4)
            case _:
              0
        case _:
          0
    case _:
      0

def _assert_weapon_runs(run_a: Run, run_b: Run, run_c: Run) -> U32:
  match run_a:
    case run{lvl_a, hp_a, max_a, idx_a, weapon_a, board_a, deck_a, draw_a, rem_a, cap_a, seed_a, status_a}:
      match run_b:
        case run{lvl_b, hp_b, max_b, idx_b, weapon_b, board_b, deck_b, draw_b, rem_b, cap_b, seed_b, status_b}:
          match run_c:
            case run{lvl_c, hp_c, max_c, idx_c, weapon_c, board_c, deck_c, draw_c, rem_c, cap_c, seed_c, status_c}:
              _assert_weapon_state(weapon_a, weapon_b, weapon_c, hp_a, board_a, board_b, idx_c, rem_c, seed_c, board_c)

def test_combat_weapon() -> U32:
  lower_board = Dungeon.board_set(Dungeon.board_set(Dungeon.empty_board(), 1, monster{2, 7}), 7, potion{0, 4});
  _assert_weapon_runs(
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _weapon_run_with(Dungeon.board_set(Dungeon.empty_board(), 1, monster{0, 3}), 8, weapon{0, 5}), 0)),
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _weapon_run_with(Dungeon.board_set(Dungeon.empty_board(), 1, monster{1, 5}), 8, weapon{0, 5}), 0)),
    _run_from_swipe(Dungeon.apply_swipe(Dungeon.config(), meta{0, 0}, _weapon_run_with(lower_board, 9, weapon{0, 5}), 0))
  )

# App state regressions

def _assert_app_start_state(started_run: RunSlot, started: DungeonState) -> U32:
  match started_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _assert_start_run(run_value)
      * _eq_u32(_meta_level(_state_meta(started)), 0)
      * _eq_u32(_meta_gold(_state_meta(started)), 0)
      * _eq_u32(_state_next_seed(started), Dungeon.next_seed(Dungeon.initial_seed()))
      * _eq_u32(_state_hp_fx(started), 0)
      * _eq_u32(_state_dmg_fx(started), 0)

def _assert_app_restart_state(restarted_run: RunSlot, restarted: DungeonState) -> U32:
  match restarted_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _assert_start_run(run_value)
      * _eq_u32(_meta_level(_state_meta(restarted)), 1)
      * _eq_u32(_meta_gold(_state_meta(restarted)), 5)
      * _eq_u32(_run_hp(run_value), 14)
      * _eq_u32(_run_max_hp(run_value), 14)
      * _eq_u32(_state_next_seed(restarted), Dungeon.next_seed(9))
      * _eq_u32(_state_hp_fx(restarted), 0)
      * _eq_u32(_state_dmg_fx(restarted), 0)

def test_app_start_from_idle() -> U32:
  started = Dungeon.on_event(start{}, Dungeon.init);
  _assert_app_start_state(_state_run(started), started)

def test_app_upgrade_idle() -> U32:
  upgraded = Dungeon.on_event(upgrade{}, _idle_state(meta{0, 25}, 9, 1, 2));
  _assert_idle_state(upgraded, 1, 5, 9, 0, 0)

def test_app_upgrade_blocked_during_run() -> U32:
  active_state = _state_with_run(meta{0, 25}, _app_run_with(Dungeon.empty_board(), 11, 11, no_weapon{}, 0), 9, 1, 2);
  after_upgrade = Dungeon.on_event(upgrade{}, active_state);
  _eq_u32(_meta_level(_state_meta(after_upgrade)), 0)
  * _eq_u32(_meta_gold(_state_meta(after_upgrade)), 25)
  * _eq_u32(_state_next_seed(after_upgrade), 9)
  * _eq_u32(_state_hp_fx(after_upgrade), 1)
  * _eq_u32(_state_dmg_fx(after_upgrade), 2)
  * _eq_u32(_maybe_run_status(_state_run(after_upgrade)), 0)
  * _eq_u32(_maybe_run_hp(_state_run(after_upgrade)), 11)
  * _eq_u32(_maybe_run_max_hp(_state_run(after_upgrade)), 11)

def test_app_upgrade_after_game_over() -> U32:
  over_state = _state_with_run(meta{0, 25}, _app_run_with(Dungeon.empty_board(), 0, 11, no_weapon{}, 1), 9, 3, 4);
  after_upgrade = Dungeon.on_event(upgrade{}, over_state);
  _eq_u32(_meta_level(_state_meta(after_upgrade)), 1)
  * _eq_u32(_meta_gold(_state_meta(after_upgrade)), 5)
  * _eq_u32(_state_next_seed(after_upgrade), 9)
  * _eq_u32(_state_hp_fx(after_upgrade), 0)
  * _eq_u32(_state_dmg_fx(after_upgrade), 0)
  * _eq_u32(_maybe_has_run(_state_run(after_upgrade)), 1)
  * _eq_u32(_maybe_run_status(_state_run(after_upgrade)), 1)
  * _eq_u32(_maybe_run_max_hp(_state_run(after_upgrade)), 11)

def test_app_restart_preserves_meta() -> U32:
  restarted = Dungeon.on_event(restart{}, _state_with_run(meta{1, 5}, _app_run_with(Dungeon.empty_board(), 0, 14, no_weapon{}, 1), 9, 3, 4));
  _assert_app_restart_state(_state_run(restarted), restarted)

def test_idle_move_is_noop() -> U32:
  _assert_idle_state(Dungeon.on_event(turn_up{}, Dungeon.init), 0, 0, Dungeon.initial_seed(), 0, 0)

# HP FX

def _hp_fx_run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32) -> Run:
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

def _assert_hp_fx(
  after_heal: DungeonState,
  after_heal_clear: DungeonState,
  after_hurt: DungeonState,
  after_hurt_clear: DungeonState,
  after_capped_heal: DungeonState,
) -> U32:
  _eq_u32(_maybe_run_hp(_state_run(after_heal)), 10)
  * _eq_u32(_maybe_run_index(_state_run(after_heal)), 3)
  * _is_heal_fx(_state_hp_fx(after_heal))
  * _eq_u32(_state_dmg_fx(after_heal), 0)
  * _eq_u32(_maybe_run_hp(_state_run(after_heal_clear)), 10)
  * _eq_u32(_maybe_run_index(_state_run(after_heal_clear)), 3)
  * _eq_u32(_state_hp_fx(after_heal_clear), 0)
  * _eq_u32(_state_dmg_fx(after_heal_clear), 0)
  * _eq_u32(_maybe_run_hp(_state_run(after_hurt)), 4)
  * _eq_u32(_maybe_run_index(_state_run(after_hurt)), 4)
  * _is_hurt_fx(_state_hp_fx(after_hurt))
  * _eq_u32(_state_dmg_fx(after_hurt), 0)
  * _eq_u32(_maybe_run_hp(_state_run(after_hurt_clear)), 4)
  * _eq_u32(_maybe_run_index(_state_run(after_hurt_clear)), 1)
  * _eq_u32(_state_hp_fx(after_hurt_clear), 0)
  * _eq_u32(_state_dmg_fx(after_hurt_clear), 0)
  * _eq_u32(_maybe_run_hp(_state_run(after_capped_heal)), 10)
  * _eq_u32(_maybe_run_index(_state_run(after_capped_heal)), 3)
  * _eq_u32(_state_hp_fx(after_capped_heal), 0)
  * _eq_u32(_state_dmg_fx(after_capped_heal), 0)

def test_hp_fx() -> U32:
  potion_board = Dungeon.board_set(Dungeon.empty_board(), 3, potion{0, 4});
  hurt_board = Dungeon.board_set(Dungeon.board_set(Dungeon.empty_board(), 1, monster{0, 6}), 0, gold{2});
  healed_state = Dungeon.on_event(turn_left{}, _state_with_run(meta{0, 0}, _hp_fx_run_with(potion_board, 8, 10), 9, 0, 0));
  heal_cleared_state = Dungeon.on_event(turn_up{}, healed_state);
  hurt_state = Dungeon.on_event(turn_up{}, _state_with_run(meta{0, 0}, _hp_fx_run_with(hurt_board, 10, 10), 9, 0, 0));
  hurt_cleared_state = Dungeon.on_event(turn_up{}, hurt_state);
  capped_heal_state = Dungeon.on_event(turn_left{}, _state_with_run(meta{0, 0}, _hp_fx_run_with(potion_board, 10, 10), 9, 0, 0));
  _assert_hp_fx(healed_state, heal_cleared_state, hurt_state, hurt_cleared_state, capped_heal_state)

# Damage FX

def _dmg_fx_run_with(board_value: Board, hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon) -> Run:
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

def _assert_dmg_fx(
  after_pickup: DungeonState,
  after_pickup_clear: DungeonState,
  after_hit: DungeonState,
  after_hit_clear: DungeonState,
) -> U32:
  _eq_u32(_maybe_run_index(_state_run(after_pickup)), 1)
  * _eq_u32(_maybe_run_weapon_dmg(_state_run(after_pickup)), 5)
  * _eq_u32(_state_hp_fx(after_pickup), 0)
  * _is_dmg_up_fx(_state_dmg_fx(after_pickup))
  * _eq_u32(_maybe_run_index(_state_run(after_pickup_clear)), 0)
  * _eq_u32(_maybe_run_weapon_dmg(_state_run(after_pickup_clear)), 5)
  * _eq_u32(_state_dmg_fx(after_pickup_clear), 0)
  * _eq_u32(_maybe_run_index(_state_run(after_hit)), 4)
  * _eq_u32(_maybe_run_weapon_dmg(_state_run(after_hit)), 2)
  * _eq_u32(_state_hp_fx(after_hit), 0)
  * _is_dmg_down_fx(_state_dmg_fx(after_hit))
  * _eq_u32(_maybe_run_index(_state_run(after_hit_clear)), 4)
  * _eq_u32(_maybe_run_weapon_dmg(_state_run(after_hit_clear)), 2)
  * _eq_u32(_state_dmg_fx(after_hit_clear), 0)

def test_dmg_fx() -> U32:
  pickup_board = Dungeon.board_set(Dungeon.board_set(Dungeon.empty_board(), 1, sword{0, 5}), 0, gold{2});
  hit_board = Dungeon.board_set(Dungeon.empty_board(), 1, monster{0, 3});
  pickup_state = Dungeon.on_event(turn_up{}, _state_with_run(meta{0, 0}, _dmg_fx_run_with(pickup_board, 10, 10, no_weapon{}), 9, 0, 0));
  pickup_clear_state = Dungeon.on_event(turn_left{}, pickup_state);
  hit_state = Dungeon.on_event(turn_up{}, _state_with_run(meta{0, 0}, _dmg_fx_run_with(hit_board, 10, 10, weapon{0, 5}), 9, 0, 0));
  hit_clear_state = Dungeon.on_event(turn_left{}, hit_state);
  _assert_dmg_fx(pickup_state, pickup_clear_state, hit_state, hit_clear_state)

def main() -> U32:
  test_start_run()
  * test_upgrade_hero()
  * test_items()
  * test_combat_unarmed()
  * test_combat_weapon()
  * test_app_start_from_idle()
  * test_app_upgrade_idle()
  * test_app_upgrade_blocked_during_run()
  * test_app_upgrade_after_game_over()
  * test_app_restart_preserves_meta()
  * test_idle_move_is_noop()
  * test_hp_fx()
  * test_dmg_fx()
