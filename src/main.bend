import /App/
import /HTML/
import /Attr/
import /U32/ as U32

# Dungeon data

type Upgrade {
  upgrade{cost: U32, max_hp: U32}
}

type MonsterDef {
  monster_def{gold_drop: U32, hp_levels: List(U32)}
}

type SwordDef {
  sword_def{dmg: U32}
}

type PotionDef {
  potion_def{heal: U32}
}

type DeckEntry {
  deck_entry{kind: U32, ref: U32, count: U32}
}

type Weapon {
  no_weapon{}
  weapon{ref: U32, dmg: U32}
}

type Tile {
  none{}
  monster{ref: U32, hp: U32}
  sword{ref: U32, dmg: U32}
  potion{ref: U32, heal: U32}
  gold{amount: U32}
}

type Board {
  board{
    c0: Tile,
    c1: Tile,
    c2: Tile,
    c3: Tile,
    c4: Tile,
    c5: Tile,
    c6: Tile,
    c7: Tile,
    c8: Tile
  }
}

type BoardDraw {
  board_draw{
    board: Board,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type DrawResult {
  draw_result{
    tile: Tile,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type CombatResult {
  combat_result{
    hero_hp: U32,
    weapon: Weapon,
    board: Board,
    status: U32
  }
}

type Meta {
  meta{hero_level: U32, gold: U32}
}

type Config {
  config{
    hero_base_max_hp: U32,
    upgrades: List(Upgrade),
    monsters: List(MonsterDef),
    swords: List(SwordDef),
    potions: List(PotionDef),
    deck: List(DeckEntry),
    base_deck_size: U32,
    starting_dungeon_level: U32
  }
}

type Run {
  run{
    dungeon_level: U32,
    hero_hp: U32,
    hero_max_hp: U32,
    hero_index: U32,
    weapon: Weapon,
    board: Board,
    deck_blueprint: List(DeckEntry),
    draw_counts: List(DeckEntry),
    remaining: U32,
    capacity: U32,
    seed: U32,
    status: U32
  }
}

type SwipeResult {
  swipe_result{meta: Meta, run: Run}
}

type RunSlot {
  idle_run{}
  run_slot{run: Run}
}

type DungeonEvent {
  start{}
  upgrade{}
  turn_up{}
  turn_down{}
  turn_left{}
  turn_right{}
  ok{}
  ignore{}
}

type DungeonState {
  dungeon{meta: Meta, current_run: RunSlot, next_seed: U32, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32}
}

type ImpactState {
  impact_state{idx: U32, fx: U32}
}

type _PickResult {
  pick_result{kind: U32, ref: U32, counts: List(DeckEntry)}
}

def default_meta() -> Meta:
  meta{0, 0}

def initial_seed() -> U32:
  1

def config() -> Config:
  config{
    11,
    [
      upgrade{20, 14},
      upgrade{35, 17},
      upgrade{55, 20},
      upgrade{80, 24}
    ],
    [
      monster_def{3, [3, 5, 7, 9, 11]},
      monster_def{4, [5, 7, 9, 11, 13]},
      monster_def{5, [7, 9, 11, 13, 15]},
      monster_def{6, [9, 11, 14, 17, 20]}
    ],
    [
      sword_def{5},
      sword_def{7},
      sword_def{9}
    ],
    [
      potion_def{4}
    ],
    [
      deck_entry{0, 0, 4},
      deck_entry{0, 1, 3},
      deck_entry{0, 2, 3},
      deck_entry{0, 3, 3},
      deck_entry{1, 0, 1},
      deck_entry{1, 1, 1},
      deck_entry{1, 2, 1},
      deck_entry{2, 0, 3},
      deck_entry{3, 0, 1}
    ],
    20,
    1
  }

# Deck helpers

def _next_seed_value(value: U32) -> U32:
  match value === 0:
    case 0:
      value
    case _:
      1

def next_seed(seed: U32) -> U32:
  _next_seed_value((seed * 1664525) + 1013904223)

def sum_counts(entries: List(DeckEntry)) -> U32:
  match entries:
    case []:
      0
    case deck_entry{kind, ref, count}<>rest:
      count + sum_counts(rest)

def nth_upgrade(upgrades: List(Upgrade), idx: U32) -> Upgrade:
  match upgrades:
    case []:
      upgrade{0, 0}
    case upgrade{cost, max_hp}<>rest:
      match idx === 0:
        case 0:
          nth_upgrade(rest, idx - 1)
        case _:
          upgrade{cost, max_hp}

def _from_upgrade(step: Upgrade, fallback: U32) -> U32:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp === 0:
        case 0:
          max_hp
        case _:
          fallback

def hero_max_hp(base_hp: U32, upgrades: List(Upgrade), hero_level: U32) -> U32:
  match hero_level === 0:
    case 0:
      _from_upgrade(nth_upgrade(upgrades, hero_level - 1), base_hp)
    case _:
      base_hp

def monster_gold(monsters: List(MonsterDef), idx: U32) -> U32:
  match monsters:
    case []:
      0
    case monster_def{gold_drop, hp_levels}<>rest:
      match idx === 0:
        case 0:
          monster_gold(rest, idx - 1)
        case _:
          gold_drop

def _remove_entry(kind: U32, ref: U32, count: U32, rest: List(DeckEntry)) -> List(DeckEntry):
  match kind === 3:
    case 0:
      (deck_entry{kind, ref, count}<>remove_hero_card(rest) :: List(DeckEntry))
    case _:
      _remove_keep(ref, count, rest)

def _remove_keep(ref: U32, count: U32, rest: List(DeckEntry)) -> List(DeckEntry):
  match count === 1:
    case 0:
      (deck_entry{3, ref, count - 1}<>rest :: List(DeckEntry))
    case _:
      (rest :: List(DeckEntry))

def remove_hero_card(entries: List(DeckEntry)) -> List(DeckEntry):
  match entries:
    case []:
      []
    case deck_entry{kind, ref, count}<>rest:
      _remove_entry(kind, ref, count, rest)

def _pick_entry(entries: List(DeckEntry), idx: U32) -> _PickResult:
  match entries:
    case []:
      pick_result{0, 0, []}
    case deck_entry{kind, ref, count}<>rest:
      match idx < count:
        case 0:
          _pick_rest(kind, ref, count, rest, idx - count)
        case _:
          _pick_hit(kind, ref, count, rest)

def _prepend_pick(kind: U32, ref: U32, count: U32, result: _PickResult) -> _PickResult:
  match result:
    case pick_result{picked_kind, picked_ref, next_counts}:
      pick_result{picked_kind, picked_ref, deck_entry{kind, ref, count}<>next_counts}

def _pick_rest(kind: U32, ref: U32, count: U32, rest: List(DeckEntry), idx: U32) -> _PickResult:
  _prepend_pick(kind, ref, count, _pick_entry(rest, idx))

def _pick_hit(kind: U32, ref: U32, count: U32, rest: List(DeckEntry)) -> _PickResult:
  match count === 1:
    case 0:
      (pick_result{kind, ref, deck_entry{kind, ref, count - 1}<>rest} :: _PickResult)
    case _:
      (pick_result{kind, ref, rest} :: _PickResult)

def _nth_u32(xs: List(U32), idx: U32, fallback: U32) -> U32:
  match xs:
    case []:
      fallback
    case head<>rest:
      match idx === 0:
        case 0:
          _nth_u32(rest, idx - 1, head)
        case _:
          head

def _monster_hp(monsters: List(MonsterDef), idx: U32, level: U32) -> U32:
  match monsters:
    case []:
      1
    case monster_def{gold_drop, hp_levels}<>rest:
      match idx === 0:
        case 0:
          _monster_hp(rest, idx - 1, level)
        case _:
          _nth_u32(hp_levels, level - 1, 1)

def _sword_damage(swords: List(SwordDef), idx: U32) -> U32:
  match swords:
    case []:
      1
    case sword_def{dmg}<>rest:
      match idx === 0:
        case 0:
          _sword_damage(rest, idx - 1)
        case _:
          dmg

def _potion_heal(potions: List(PotionDef), idx: U32) -> U32:
  match potions:
    case []:
      1
    case potion_def{heal}<>rest:
      match idx === 0:
        case 0:
          _potion_heal(rest, idx - 1)
        case _:
          heal

def _spawn_tile(config_value: Config, kind: U32, ref: U32, level: U32) -> Tile:
  match config_value:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      match kind:
        case 0:
          monster{ref, _monster_hp(monsters, ref, level)}
        case 1:
          sword{ref, _sword_damage(swords, ref)}
        case 2:
          potion{ref, _potion_heal(potions, ref)}
        case _:
          none{}

def _pick_result_to_draw(
  config_value: Config,
  remaining: U32,
  next_seed_value: U32,
  level: U32,
  result: _PickResult,
) -> DrawResult:
  match result:
    case pick_result{kind, ref, counts}:
      draw_result{
        _spawn_tile(config_value, kind, ref, level),
        counts,
        remaining - 1,
        next_seed_value,
        level
      }

def _draw_from_counts(
  config_value: Config,
  draw_counts: List(DeckEntry),
  remaining: U32,
  seed: U32,
  level: U32,
) -> DrawResult:
  match remaining === 0:
    case 0:
      idx = seed % remaining;
      next = next_seed(seed);
      _pick_result_to_draw(config_value, remaining, next, level, _pick_entry(draw_counts, idx))
    case _:
      draw_result{none{}, draw_counts, 0, next_seed(seed), level}

def draw_tile(
  config_value: Config,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  seed: U32,
  level: U32,
) -> DrawResult:
  match remaining === 0:
    case 0:
      _draw_from_counts(config_value, draw_counts, remaining, seed, level)
    case _:
      refill = sum_counts(deck_blueprint);
      _draw_from_counts(config_value, deck_blueprint, refill, seed, level + 1)

# Board helpers

def board_get(board_value: Board, idx: U32) -> Tile:
  match board_value:
    case board{c0, c1, c2, c3, c4, c5, c6, c7, c8}:
      pick = λ{
        0: c0;
        1: c1;
        2: c2;
        3: c3;
        4: c4;
        5: c5;
        6: c6;
        7: c7;
        8: c8;
        _ => none{}
      };
      pick(idx)

def board_set(board_value: Board, idx: U32, tile: Tile) -> Board:
  match board_value:
    case board{c0, c1, c2, c3, c4, c5, c6, c7, c8}:
      pick = λ{
        0: (board{tile, c1, c2, c3, c4, c5, c6, c7, c8} :: Board);
        1: (board{c0, tile, c2, c3, c4, c5, c6, c7, c8} :: Board);
        2: (board{c0, c1, tile, c3, c4, c5, c6, c7, c8} :: Board);
        3: (board{c0, c1, c2, tile, c4, c5, c6, c7, c8} :: Board);
        4: (board{c0, c1, c2, c3, tile, c5, c6, c7, c8} :: Board);
        5: (board{c0, c1, c2, c3, c4, tile, c6, c7, c8} :: Board);
        6: (board{c0, c1, c2, c3, c4, c5, tile, c7, c8} :: Board);
        7: (board{c0, c1, c2, c3, c4, c5, c6, tile, c8} :: Board);
        8: (board{c0, c1, c2, c3, c4, c5, c6, c7, tile} :: Board);
        _ => (board{c0, c1, c2, c3, c4, c5, c6, c7, c8} :: Board)
      };
      pick(idx)

def empty_board() -> Board:
  board{
    none{},
    none{},
    none{},
    none{},
    none{},
    none{},
    none{},
    none{},
    none{}
  }

def _up(hero_index: U32) -> U32:
  match hero_index < 3:
    case 0:
      hero_index - 3
    case _:
      9

def _down(hero_index: U32) -> U32:
  match hero_index < 6:
    case 0:
      9
    case _:
      hero_index + 3

def _left(hero_index: U32) -> U32:
  match hero_index:
    case 0:
      9
    case 1:
      0
    case 2:
      1
    case 3:
      9
    case 4:
      3
    case 5:
      4
    case 6:
      9
    case 7:
      6
    case 8:
      7
    case _:
      9

def _right(hero_index: U32) -> U32:
  match hero_index:
    case 0:
      1
    case 1:
      2
    case 2:
      9
    case 3:
      4
    case 4:
      5
    case 5:
      9
    case 6:
      7
    case 7:
      8
    case 8:
      9
    case _:
      9

def adjacent_index(hero_index: U32, dir: U32) -> U32:
  match dir:
    case 0:
      _up(hero_index)
    case 1:
      _down(hero_index)
    case 2:
      _left(hero_index)
    case 3:
      _right(hero_index)
    case _:
      9

def _back_up(hero_index: U32) -> U32:
  match hero_index < 6:
    case 0:
      9
    case _:
      hero_index + 3

def _back_down(hero_index: U32) -> U32:
  match hero_index < 3:
    case 0:
      hero_index - 3
    case _:
      9

def _back_left(hero_index: U32) -> U32:
  match hero_index:
    case 0:
      1
    case 1:
      2
    case 2:
      9
    case 3:
      4
    case 4:
      5
    case 5:
      9
    case 6:
      7
    case 7:
      8
    case 8:
      9
    case _:
      9

def _back_right(hero_index: U32) -> U32:
  match hero_index:
    case 0:
      9
    case 1:
      0
    case 2:
      1
    case 3:
      9
    case 4:
      3
    case 5:
      4
    case 6:
      9
    case 7:
      6
    case 8:
      7
    case _:
      9

def _back_index(hero_index: U32, dir: U32) -> U32:
  match dir:
    case 0:
      _back_up(hero_index)
    case 1:
      _back_down(hero_index)
    case 2:
      _back_left(hero_index)
    case 3:
      _back_right(hero_index)
    case _:
      9

def _shift_after_move_back(board_value: Board, board1: Board, hero_index: U32, back: U32, spawn: Tile) -> Board:
  match back === 9:
    case 0:
      back_tile = board_get(board_value, back);
      board2 = board_set(board1, hero_index, back_tile);
      board_set(board2, back, spawn)
    case _:
      board_set(board1, hero_index, spawn)

def shift_after_move(
  board_value: Board,
  hero_index: U32,
  target_index: U32,
  dir: U32,
  spawn: Tile,
) -> Board:
  _shift_after_move_back(
    board_value,
    board_set(board_value, target_index, none{}),
    hero_index,
    _back_index(hero_index, dir),
    spawn
  )

# Combat and run logic

def _resolve_unarmed(
  monsters: List(MonsterDef),
  board_value: Board,
  hero_hp: U32,
  target_idx: U32,
  monster_ref: U32,
  monster_hp: U32,
) -> CombatResult:
  match hero_hp > monster_hp:
    case 0:
      (combat_result{0, no_weapon{}, board_value, 1} :: CombatResult)
    case _:
      gold = monster_gold(monsters, monster_ref);
      next_board = board_set(board_value, target_idx, gold{gold});
      (combat_result{hero_hp - monster_hp, no_weapon{}, next_board, 0} :: CombatResult)

def _resolve_armed_equal_or_less(
  monsters: List(MonsterDef),
  board_value: Board,
  hero_hp: U32,
  target_idx: U32,
  monster_ref: U32,
  monster_hp: U32,
  weapon_ref: U32,
  dmg: U32,
) -> CombatResult:
  match dmg === monster_hp:
    case 0:
      next_board = board_set(board_value, target_idx, monster{monster_ref, monster_hp - dmg});
      (combat_result{hero_hp, no_weapon{}, next_board, 0} :: CombatResult)
    case _:
      gold = monster_gold(monsters, monster_ref);
      next_board = board_set(board_value, target_idx, gold{gold});
      (combat_result{hero_hp, no_weapon{}, next_board, 0} :: CombatResult)

def _resolve_armed(
  monsters: List(MonsterDef),
  board_value: Board,
  hero_hp: U32,
  target_idx: U32,
  monster_ref: U32,
  monster_hp: U32,
  weapon_ref: U32,
  dmg: U32,
) -> CombatResult:
  match dmg > monster_hp:
    case 0:
      _resolve_armed_equal_or_less(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, weapon_ref, dmg)
    case _:
      gold = monster_gold(monsters, monster_ref);
      next_board = board_set(board_value, target_idx, gold{gold});
      combat_result{hero_hp, weapon{weapon_ref, dmg - monster_hp}, next_board, 0}

def resolve_monster(
  config_value: Config,
  board_value: Board,
  hero_hp: U32,
  weapon_value: Weapon,
  target_idx: U32,
  monster_ref: U32,
  monster_hp: U32,
) -> CombatResult:
  match config_value:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      match weapon_value:
        case no_weapon{}:
          _resolve_unarmed(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp)
        case weapon{ref, dmg}:
          _resolve_armed(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, ref, dmg)

def _draw_into_slot(board_value: Board, slot: U32, result: DrawResult) -> BoardDraw:
  match result:
    case draw_result{tile, next_counts, next_remaining, next_seed, next_level}:
      board_draw{board_set(board_value, slot, tile), next_counts, next_remaining, next_seed, next_level}

def _draw_step(
  config_value: Config,
  board_value: Board,
  slot: U32,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  seed: U32,
  level: U32,
) -> BoardDraw:
  _draw_into_slot(board_value, slot, draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, level))

def _seed_after_1(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board1, counts1, remaining1, seed1, level1}:
      _seed_after_2(config_value, blueprint, _draw_step(config_value, board1, 2, blueprint, counts1, remaining1, seed1, level1))

def _seed_after_2(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board2, counts2, remaining2, seed2, level2}:
      _seed_after_3(config_value, blueprint, _draw_step(config_value, board2, 3, blueprint, counts2, remaining2, seed2, level2))

def _seed_after_3(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board3, counts3, remaining3, seed3, level3}:
      _seed_after_4(config_value, blueprint, _draw_step(config_value, board3, 5, blueprint, counts3, remaining3, seed3, level3))

def _seed_after_4(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board4, counts4, remaining4, seed4, level4}:
      _seed_after_5(config_value, blueprint, _draw_step(config_value, board4, 6, blueprint, counts4, remaining4, seed4, level4))

def _seed_after_5(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board5, counts5, remaining5, seed5, level5}:
      _seed_after_6(config_value, blueprint, _draw_step(config_value, board5, 7, blueprint, counts5, remaining5, seed5, level5))

def _seed_after_6(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board6, counts6, remaining6, seed6, level6}:
      _draw_step(config_value, board6, 8, blueprint, counts6, remaining6, seed6, level6)

def _seed_after_0(config_value: Config, blueprint: List(DeckEntry), stage: BoardDraw) -> BoardDraw:
  match stage:
    case board_draw{board0, counts0, remaining0, seed0, level0}:
      _seed_after_1(config_value, blueprint, _draw_step(config_value, board0, 1, blueprint, counts0, remaining0, seed0, level0))

def _seed_initial_board(
  config_value: Config,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  seed: U32,
  level: U32,
) -> BoardDraw:
  _seed_after_0(config_value, deck_blueprint, _draw_step(config_value, empty_board(), 0, deck_blueprint, draw_counts, remaining, seed, level))

def _start_from_board(hero_max: U32, blueprint: List(DeckEntry), capacity: U32, stage: BoardDraw) -> Run:
  match stage:
    case board_draw{board_value, next_counts, next_remaining, next_seed_value, next_level}:
      run{
        next_level,
        hero_max,
        hero_max,
        4,
        no_weapon{},
        board_value,
        blueprint,
        next_counts,
        next_remaining,
        capacity,
        next_seed_value,
        0
      }

def start_run(config_value: Config, meta_state: Meta, seed: U32) -> Run:
  match config_value meta_state:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} meta{hero_level, gold}:
      current = (config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} :: Config);
      hero_max = hero_max_hp(hero_base_max_hp, upgrades, hero_level);
      blueprint = remove_hero_card(deck);
      remaining = sum_counts(blueprint);
      _start_from_board(hero_max, blueprint, base_deck_size, _seed_initial_board(current, blueprint, blueprint, remaining, seed, starting_dungeon_level))

def upgrade_hero(config_value: Config, meta_state: Meta) -> Meta:
  match config_value meta_state:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} meta{hero_level, gold_value}:
      _upgrade_from_step(hero_level, gold_value, meta{hero_level, gold_value}, nth_upgrade(upgrades, hero_level))

def _upgrade_from_step(hero_level: U32, gold_value: U32, meta_state: Meta, step: Upgrade) -> Meta:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp === 0:
        case 0:
          _upgrade_if_affordable(hero_level, gold_value, meta_state, cost)
        case _:
          meta_state

def _upgrade_if_affordable(hero_level: U32, gold_value: U32, meta_state: Meta, cost: U32) -> Meta:
  match gold_value < cost:
    case 0:
      (meta{hero_level + 1, gold_value - cost} :: Meta)
    case _:
      (meta_state :: Meta)

def _min_u32(a: U32, b: U32) -> U32:
  match a < b:
    case 0:
      b
    case _:
      a

def _add_gold(meta_state: Meta, amount: U32) -> Meta:
  match meta_state:
    case meta{hero_level, gold}:
      meta{hero_level, gold + amount}

def _keep_run(
  meta_state: Meta,
  dungeon_level: U32,
  hero_hp: U32,
  hero_max_hp: U32,
  hero_index: U32,
  weapon_value: Weapon,
  board_value: Board,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  capacity: U32,
  seed: U32,
  status: U32,
) -> SwipeResult:
  swipe_result{
    meta_state,
    run{
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
      status
    }
  }

def _move_after_collect_from_draw(
  meta_state: Meta,
  hero_hp: U32,
  hero_max_hp: U32,
  hero_index: U32,
  target_index: U32,
  weapon_value: Weapon,
  board_value: Board,
  deck_blueprint: List(DeckEntry),
  capacity: U32,
  result: DrawResult,
  dir: U32,
) -> SwipeResult:
  match result:
    case draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      swipe_result{
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
          0
        }
      }

def _move_after_collect(
  config_value: Config,
  meta_state: Meta,
  dungeon_level: U32,
  hero_hp: U32,
  hero_max_hp: U32,
  hero_index: U32,
  target_index: U32,
  weapon_value: Weapon,
  board_value: Board,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  capacity: U32,
  seed: U32,
  dir: U32,
) -> SwipeResult:
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
    draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, dungeon_level),
    dir
  )

def _from_combat(
  meta_state: Meta,
  dungeon_level: U32,
  hero_max_hp: U32,
  hero_index: U32,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  capacity: U32,
  seed: U32,
  result: CombatResult,
) -> SwipeResult:
  match result:
    case combat_result{next_hp, next_weapon, next_board, next_status}:
      swipe_result{
        meta_state,
        run{
          dungeon_level,
          next_hp,
          hero_max_hp,
          hero_index,
          next_weapon,
          next_board,
          deck_blueprint,
          draw_counts,
          remaining,
          capacity,
          seed,
          next_status
        }
      }

def _apply_to_tile(
  config_value: Config,
  meta_state: Meta,
  dungeon_level: U32,
  hero_hp: U32,
  hero_max_hp: U32,
  hero_index: U32,
  weapon_value: Weapon,
  board_value: Board,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  capacity: U32,
  seed: U32,
  status: U32,
  dir: U32,
  target_index: U32,
  tile_value: Tile,
) -> SwipeResult:
  match tile_value:
    case none{}:
      _keep_run(meta_state, dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status)
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
        resolve_monster(config_value, board_value, hero_hp, weapon_value, target_index, ref, hp)
      )
    case sword{ref, dmg}:
      _move_after_collect(config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_index, target_index, weapon{ref, dmg}, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, dir)
    case potion{ref, heal}:
      next_hp = _min_u32(hero_max_hp, hero_hp + heal);
      _move_after_collect(config_value, meta_state, dungeon_level, next_hp, hero_max_hp, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, dir)
    case gold{amount}:
      next_meta = _add_gold(meta_state, amount);
      _move_after_collect(config_value, next_meta, dungeon_level, hero_hp, hero_max_hp, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, dir)

def apply_swipe(config_value: Config, meta_state: Meta, run_value: Run, dir: U32) -> SwipeResult:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      match status === 0:
        case 0:
          _keep_run(meta_state, dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status)
        case _:
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
            status,
            dir,
            adjacent_index(hero_index, dir)
          )

def _apply_swipe_target(
  config_value: Config,
  meta_state: Meta,
  dungeon_level: U32,
  hero_hp: U32,
  hero_max_hp: U32,
  hero_index: U32,
  weapon_value: Weapon,
  board_value: Board,
  deck_blueprint: List(DeckEntry),
  draw_counts: List(DeckEntry),
  remaining: U32,
  capacity: U32,
  seed: U32,
  status: U32,
  dir: U32,
  target_index: U32,
) -> SwipeResult:
  match target_index === 9:
    case 0:
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
        status,
        dir,
        target_index,
        board_get(board_value, target_index)
      )
    case _:
      _keep_run(meta_state, dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status)

# App state

init : DungeonState =
  dungeon{default_meta(), idle_run{}, initial_seed(), 0, 0, 9, 0}

def key_event(key: U32) -> DungeonEvent:
  match key:
    case 37:
      turn_left{}
    case 65:
      turn_left{}
    case 38:
      turn_up{}
    case 87:
      turn_up{}
    case 39:
      turn_right{}
    case 68:
      turn_right{}
    case 40:
      turn_down{}
    case 83:
      turn_down{}
    case 32:
      ignore{}
    case 82:
      ignore{}
    case _:
      ignore{}

def _state_from_run(meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> DungeonState:
  dungeon{meta_state, run_slot{run_value}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}

def _start(meta_state: Meta, seed: U32) -> DungeonState:
  next = next_seed(seed);
  _state_from_run(meta_state, start_run(config(), meta_state, seed), next, 0, 0, 9, 0)

def _hero_hp(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_hp

def _weapon_dmg(weapon_value: Weapon) -> U32:
  match weapon_value:
    case no_weapon{}:
      0
    case weapon{ref, dmg}:
      dmg

def _hero_dmg(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      _weapon_dmg(weapon)

def _run_status(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      status

def _phase_from_run(run_value: Run) -> U32:
  match _run_status(run_value) === 0:
    case 0:
      2
    case _:
      1

def _phase(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _phase_from_run(run_value)

def _has_run(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      1

def _is_idle(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      1
    case run_slot{run_value}:
      0

def _is_active_run(current_run: RunSlot) -> U32:
  match _phase(current_run) === 1:
    case 0:
      0
    case _:
      1

def _is_game_over(current_run: RunSlot) -> U32:
  match current_run:
    case idle_run{}:
      0
    case run_slot{run_value}:
      _is_game_over_run(run_value)

def _is_game_over_run(run_value: Run) -> U32:
  _is_game_over_status(_run_status(run_value))

def _is_game_over_status(status: U32) -> U32:
  match status === 0:
    case 0:
      1
    case _:
      0

def _can_upgrade(current_run: RunSlot) -> U32:
  _is_idle(current_run)

def _toggle_heal_fx(hp_fx: U32) -> U32:
  match hp_fx === 1:
    case 0:
      1
    case _:
      2

def _toggle_hurt_fx(hp_fx: U32) -> U32:
  match hp_fx === 3:
    case 0:
      3
    case _:
      4

def _toggle_dmg_up_fx(dmg_fx: U32) -> U32:
  match dmg_fx === 1:
    case 0:
      1
    case _:
      2

def _toggle_dmg_down_fx(dmg_fx: U32) -> U32:
  match dmg_fx === 3:
    case 0:
      3
    case _:
      4

def _next_hp_fx_values(current_hp: U32, next_hp: U32, current_hp_fx: U32) -> U32:
  match current_hp < next_hp:
    case 0:
      match next_hp < current_hp:
        case 0:
          0
        case _:
          _toggle_hurt_fx(current_hp_fx)
    case _:
      _toggle_heal_fx(current_hp_fx)

def _next_hp_fx(current_run: Run, next_run: Run, current_hp_fx: U32) -> U32:
  _next_hp_fx_values(_hero_hp(current_run), _hero_hp(next_run), current_hp_fx)

def _next_dmg_fx_values(current_dmg: U32, next_dmg: U32, current_dmg_fx: U32) -> U32:
  match current_dmg < next_dmg:
    case 0:
      match next_dmg < current_dmg:
        case 0:
          0
        case _:
          _toggle_dmg_down_fx(current_dmg_fx)
    case _:
      _toggle_dmg_up_fx(current_dmg_fx)

def _next_dmg_fx(current_run: Run, next_run: Run, current_dmg_fx: U32) -> U32:
  _next_dmg_fx_values(_hero_dmg(current_run), _hero_dmg(next_run), current_dmg_fx)

def _toggle_impact_hit_fx(current_impact_fx: U32) -> U32:
  match current_impact_fx === 1:
    case 0:
      1
    case _:
      2

def _toggle_impact_kill_fx(current_impact_fx: U32) -> U32:
  match current_impact_fx === 3:
    case 0:
      3
    case _:
      4

def _run_hero_index(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      hero_index

def _run_board(run_value: Run) -> Board:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      board_value

def _impact_none() -> ImpactState:
  impact_state{9, 0}

def _impact_hit(target_idx: U32, current_impact_fx: U32) -> ImpactState:
  impact_state{target_idx, _toggle_impact_hit_fx(current_impact_fx)}

def _impact_kill(target_idx: U32, current_impact_fx: U32) -> ImpactState:
  impact_state{target_idx, _toggle_impact_kill_fx(current_impact_fx)}

def _impact_from_monster_hp(target_idx: U32, prev_hp: U32, next_hp: U32, current_impact_fx: U32) -> ImpactState:
  match next_hp < prev_hp:
    case 0:
      _impact_none()
    case _:
      _impact_hit(target_idx, current_impact_fx)

def _impact_from_monster_next(target_idx: U32, prev_hp: U32, next_tile: Tile, current_impact_fx: U32) -> ImpactState:
  match next_tile:
    case monster{next_ref, next_hp}:
      _impact_from_monster_hp(target_idx, prev_hp, next_hp, current_impact_fx)
    case gold{amount}:
      _impact_kill(target_idx, current_impact_fx)
    case _:
      _impact_none()

def _impact_from_target_tile(target_idx: U32, prev_tile: Tile, next_tile: Tile, current_impact_fx: U32) -> ImpactState:
  match prev_tile:
    case monster{ref, prev_hp}:
      _impact_from_monster_next(target_idx, prev_hp, next_tile, current_impact_fx)
    case _:
      _impact_none()

def _impact_from_turn(current_run: Run, next_run: Run, dir: U32, current_impact_fx: U32) -> ImpactState:
  target_idx = adjacent_index(_run_hero_index(current_run), dir);
  prev_tile = board_get(_run_board(current_run), target_idx);
  next_tile = board_get(_run_board(next_run), target_idx);
  _impact_from_target_tile(target_idx, prev_tile, next_tile, current_impact_fx)

def _state_from_swipe_impact(next_meta: Meta, current_run: Run, next_run: Run, next_seed_value: U32, current_hp_fx: U32, current_dmg_fx: U32, impact: ImpactState) -> DungeonState:
  match impact:
    case impact_state{next_impact_idx, next_impact_fx}:
      _state_from_run(
        next_meta,
        next_run,
        next_seed_value,
        _next_hp_fx(current_run, next_run, current_hp_fx),
        _next_dmg_fx(current_run, next_run, current_dmg_fx),
        next_impact_idx,
        next_impact_fx
      )

def _state_from_swipe(result: SwipeResult, current_run: Run, next_seed_value: U32, current_hp_fx: U32, current_dmg_fx: U32, current_impact_fx: U32, dir: U32) -> DungeonState:
  match result:
    case swipe_result{next_meta, next_run}:
      impact = _impact_from_turn(current_run, next_run, dir, current_impact_fx);
      _state_from_swipe_impact(next_meta, current_run, next_run, next_seed_value, current_hp_fx, current_dmg_fx, impact)

def _apply_turn(meta_state: Meta, run_value: Run, next_seed_value: U32, dir: U32, current_hp_fx: U32, current_dmg_fx: U32, current_impact_fx: U32) -> DungeonState:
  result = apply_swipe(config(), meta_state, run_value, dir);
  _state_from_swipe(result, run_value, next_seed_value, current_hp_fx, current_dmg_fx, current_impact_fx, dir)

def _can_afford_upgrade(meta_state: Meta, cost: U32) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      _can_afford_upgrade_gold(gold, cost)

def _can_afford_upgrade_gold(gold: U32, cost: U32) -> U32:
  match cost === 0:
    case 0:
      match gold < cost:
        case 0:
          1
        case _:
          0
    case _:
      0

def _idle_event(evt: DungeonEvent, meta_state: Meta, next_seed_value: U32, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> DungeonState:
  match evt:
    case start{}:
      _start(meta_state, next_seed_value)
    case upgrade{}:
      dungeon{upgrade_hero(config(), meta_state), idle_run{}, next_seed_value, 0, 0, 9, 0}
    case _:
      dungeon{meta_state, idle_run{}, next_seed_value, hp_fx, dmg_fx, 9, 0}

def _active_run_event(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> DungeonState:
  match evt:
    case turn_up{}:
      _apply_turn(meta_state, run_value, next_seed_value, 0, hp_fx, dmg_fx, impact_fx)
    case turn_down{}:
      _apply_turn(meta_state, run_value, next_seed_value, 1, hp_fx, dmg_fx, impact_fx)
    case turn_left{}:
      _apply_turn(meta_state, run_value, next_seed_value, 2, hp_fx, dmg_fx, impact_fx)
    case turn_right{}:
      _apply_turn(meta_state, run_value, next_seed_value, 3, hp_fx, dmg_fx, impact_fx)
    case _:
      _state_from_run(meta_state, run_value, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx)

def _ended_run_event(evt: DungeonEvent, meta_state: Meta, run_value: Run, next_seed_value: U32, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> DungeonState:
  match evt:
    case ok{}:
      dungeon{meta_state, idle_run{}, next_seed_value, 0, 0, 9, 0}
    case _:
      _state_from_run(meta_state, run_value, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx)

def on_event(evt: DungeonEvent, state: DungeonState) -> DungeonState:
  match state:
    case dungeon{meta_state, idle_run{}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      _idle_event(evt, meta_state, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx)
    case dungeon{meta_state, run_slot{run_value}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      match _run_status(run_value) === 0:
        case 0:
          _ended_run_event(evt, meta_state, run_value, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx)
        case _:
          _active_run_event(evt, meta_state, run_value, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx)

# Rendering

def render(state: DungeonState) -> HTML(DungeonEvent):
  match state:
    case dungeon{meta_state, idle_run{}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      _frame(_shell_children(meta_state, idle_run{}, 0, 0, 9, 0))
    case dungeon{meta_state, run_slot{run_value}, next_seed_value, hp_fx, dmg_fx, impact_idx, impact_fx}:
      _frame(_shell_children(meta_state, run_slot{run_value}, hp_fx, dmg_fx, impact_idx, impact_fx))

def _frame(kids: List(HTML(DungeonEvent))) -> HTML(DungeonEvent):
  <div class="page">
    <style>{text{css()}}</style>
    <main class="shell shell--dungeon" tabindex="0" style="outline:none" on_key_down={key_event}>
      {...kids}
    </main>
  </div>

def _shell_children(meta_state: Meta, current_run: RunSlot, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> List(HTML(DungeonEvent)):
  [
    _dashboard_header(meta_state),
    _status_panel(current_run),
    _controls_panel(meta_state, current_run),
    _board_node(current_run, meta_state, hp_fx, dmg_fx, impact_idx, impact_fx)
  ]

def _dashboard_header(meta_state: Meta) -> HTML(DungeonEvent):
  <header class="topbar">
    <p class="resource-bar">
      <span class="resource-bar__label">Gold</span>
      <strong class="resource-bar__value">{text{_meta_gold(meta_state)}}</strong>
    </p>
  </header>

def _status_panel(current_run: RunSlot) -> HTML(DungeonEvent):
  <section class="status-panel">
    <div class="status-panel__head">
      <p class={_phase_chip_class(current_run)}>{text{_phase_badge(current_run)}}</p>
    </div>
    <div class="status-grid">
      <div class="stat-panel">
        <span class="stat-panel__label">Dungeon Lv</span>
        <strong class="stat-panel__value">{text{_dungeon_level_value(current_run)}}</strong>
      </div>
      <div class="stat-panel">
        <span class="stat-panel__label">Cards Remaining</span>
        <strong class="stat-panel__value">{text{_remaining_value(current_run)}}</strong>
      </div>
      <div class="stat-panel">
        <span class="stat-panel__label">Weapon</span>
        <strong class="stat-panel__value">{text{_weapon_value(current_run)}}</strong>
      </div>
    </div>
  </section>

def _controls_panel(meta_state: Meta, current_run: RunSlot) -> HTML(DungeonEvent):
  <section class="controls">
    <button {..._start_attrs(current_run)}>
      {text{"Start"}}
    </button>
    <div class="upgrade-slot">
      <button {..._upgrade_attrs(meta_state, current_run)}>
        {text{_upgrade_label(meta_state)}}
      </button>
      <p class="upgrade-slot__meta">{text{_hero_level_text(meta_state)}}</p>
    </div>
  </section>

def _board_node(current_run: RunSlot, meta_state: Meta, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32) -> HTML(DungeonEvent):
  match current_run:
    case idle_run{}:
      cells = U32.grid(HTML(DungeonEvent), 3, 3, _idle_board_slot(meta_state));
      <section class={_board_shell_class_idle()}>
        <div class="board">{...cells}</div>
        {_board_overlay_idle()}
      </section>
    case run_slot{run_value}:
      cells = U32.grid(HTML(DungeonEvent), 3, 3, _board_slot(run_value, hp_fx, dmg_fx, impact_idx, impact_fx));
      <section class={_board_shell_class_run(run_value)}>
        <div class="board">{...cells}</div>
        {_board_overlay_run(run_value)}
      </section>

def _board_shell_class_idle() -> String:
  "board-shell"

def _board_shell_class_run(run_value: Run) -> String:
  over = _is_game_over_run(run_value);
  _board_shell_class_flag(over)

def _board_shell_class_flag(over: U32) -> String:
  match over:
    case 0:
      "board-shell"
    case _:
      "board-shell board-shell--over"

def _board_overlay_idle() -> HTML(DungeonEvent):
  <div class="game-over-modal"></div>

def _board_overlay_run(run_value: Run) -> HTML(DungeonEvent):
  <div class={_game_over_modal_class(run_value)}>
    <div class="game-over-card">
      <p class="game-over-card__eyebrow">{text{"Run encerrada"}}</p>
      <h2 class="game-over-card__title">{text{"Game Over"}}</h2>
      <button {..._button_attrs("button", ok{}, 1)}>
        {text{"OK"}}
      </button>
    </div>
  </div>

def _game_over_modal_class(run_value: Run) -> String:
  over = _is_game_over_run(run_value);
  _game_over_modal_class_flag(over)

def _game_over_modal_class_flag(over: U32) -> String:
  match over:
    case 0:
      "game-over-modal"
    case _:
      "game-over-modal game-over-modal--visible"

def _idle_board_card(meta_state: Meta, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  match idx === 4:
    case 0:
      _idle_placeholder_card()
    case _:
      _hero_card_idle(meta_state)

def _idle_placeholder_card() -> HTML(DungeonEvent):
  <article class="card card--empty card--idle">
    <div class="card__empty">Ready</div>
  </article>

def _hero_card_idle(meta_state: Meta) -> HTML(DungeonEvent):
  max_hp = _hero_max_hp(meta_state);
  _hero_card_values(max_hp, max_hp, no_weapon{}, 0, 0)

def _idle_board_slot(meta_state: Meta, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  <div class={_board_slot_class(idx, 9, 0)}>
    {_idle_board_card(meta_state, x, y)}
  </div>

def _board_card_at(run_value: Run, hp_fx: U32, dmg_fx: U32, idx: U32) -> HTML(DungeonEvent):
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      match hero_index === idx:
        case 0:
          _tile_card(board_get(board_value, idx))
        case _:
          _hero_card_values(hero_hp, hero_max_hp, weapon, hp_fx, dmg_fx)

def _board_card(run_value: Run, hp_fx: U32, dmg_fx: U32, x: U32, y: U32) -> HTML(DungeonEvent):
  _board_card_at(run_value, hp_fx, dmg_fx, x + (y * 3))

def _board_slot(run_value: Run, hp_fx: U32, dmg_fx: U32, impact_idx: U32, impact_fx: U32, x: U32, y: U32) -> HTML(DungeonEvent):
  idx = x + (y * 3);
  <div class={_board_slot_class(idx, impact_idx, impact_fx)}>
    {_board_card_at(run_value, hp_fx, dmg_fx, idx)}
  </div>

def _board_slot_class(idx: U32, impact_idx: U32, impact_fx: U32) -> String:
  matched = idx === impact_idx;
  _board_slot_class_matched(matched, impact_fx)

def _board_slot_class_matched(matched: U32, impact_fx: U32) -> String:
  match matched:
    case 0:
      "board-slot"
    case _:
      _board_slot_impact_class(impact_fx)

def _board_slot_impact_class(impact_fx: U32) -> String:
  match impact_fx:
    case 1:
      "board-slot board-slot--impact-a"
    case 2:
      "board-slot board-slot--impact-b"
    case 3:
      "board-slot board-slot--kill-a"
    case 4:
      "board-slot board-slot--kill-b"
    case _:
      "board-slot"

def _hero_card_values(hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, hp_fx: U32, dmg_fx: U32) -> HTML(DungeonEvent):
  <article class={_hero_card_class(dmg_fx)} data-dmg={_hero_damage_attr(weapon_value)}>
    <div class={_hero_hp_badge_class(hp_fx)}>{text{"HP " ++ U32.show(hero_hp) ++ "/" ++ U32.show(hero_max_hp)}}</div>
    <div class="card__art-wrap">
      <img class="card__art" src={_hero_sprite()} alt={_hero_name()} />
    </div>
    <div class="card__label">{text{_hero_name()}}</div>
  </article>

def _hero_card_class(dmg_fx: U32) -> String:
  match dmg_fx:
    case 1:
      "card card--hero card--hero-dmg-up-a"
    case 2:
      "card card--hero card--hero-dmg-up-b"
    case 3:
      "card card--hero card--hero-dmg-down-a"
    case 4:
      "card card--hero card--hero-dmg-down-b"
    case _:
      "card card--hero"

def _hero_hp_badge_class(hp_fx: U32) -> String:
  match hp_fx:
    case 1:
      "card__badge card__badge--hp card__badge--hp-heal-a"
    case 2:
      "card__badge card__badge--hp card__badge--hp-heal-b"
    case 3:
      "card__badge card__badge--hp card__badge--hp-hurt-a"
    case 4:
      "card__badge card__badge--hp card__badge--hp-hurt-b"
    case _:
      "card__badge card__badge--hp"

def _hero_damage_attr(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      ""
    case weapon{ref, dmg}:
      "DMG " ++ U32.show(dmg)

def _tile_card(tile: Tile) -> HTML(DungeonEvent):
  match tile:
    case none{}:
      <article class="card card--empty">
        <div class="card__empty">Empty</div>
      </article>
    case monster{ref, hp}:
      _filled_tile_card(monster{ref, hp}, "card card--tile card--monster")
    case sword{ref, dmg}:
      _filled_tile_card(sword{ref, dmg}, "card card--tile card--sword")
    case potion{ref, heal}:
      _filled_tile_card(potion{ref, heal}, "card card--tile card--potion")
    case gold{amount}:
      _filled_tile_card(gold{amount}, "card card--tile card--gold")

def _filled_tile_card(tile: Tile, class_name: String) -> HTML(DungeonEvent):
  <article class={class_name}>
    {_tile_badge_node(tile)}
    <div class="card__art-wrap">
      <img class="card__art" src={_tile_sprite(tile)} alt={_tile_name(tile)} />
    </div>
    <div class="card__label">{text{_tile_name(tile)}}</div>
  </article>

def _tile_badge_node(tile: Tile) -> HTML(DungeonEvent):
  <div class="card__badge card__badge--value">{text{_tile_badge(tile)}}</div>

def _meta_gold(meta_state: Meta) -> String:
  match meta_state:
    case meta{hero_level, gold}:
      U32.show(gold)

def _hero_level(meta_state: Meta) -> U32:
  match meta_state:
    case meta{hero_level, gold}:
      hero_level

def _hero_level_text(meta_state: Meta) -> String:
  "Hero Lv " ++ U32.show(_hero_level(meta_state))

def _dungeon_level_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--"
    case run_slot{run_value}:
      _dungeon_level_value_from_run(run_value)

def _dungeon_level_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      U32.show(dungeon_level)

def _remaining_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--/--"
    case run_slot{run_value}:
      _remaining_value_from_run(run_value)

def _remaining_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      U32.show(remaining) ++ "/" ++ U32.show(capacity)

def _weapon_value(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "--"
    case run_slot{run_value}:
      _weapon_value_from_run(run_value)

def _weapon_value_from_run(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, status}:
      _weapon_value_from_weapon(weapon)

def _weapon_value_from_weapon(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      "Unarmed"
    case weapon{ref, dmg}:
      "DMG " ++ U32.show(dmg)

def _phase_badge(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "Idle"
    case run_slot{run_value}:
      _phase_badge_run(run_value)

def _phase_badge_run(run_value: Run) -> String:
  _phase_badge_status(_run_status(run_value))

def _phase_badge_status(status: U32) -> String:
  _phase_badge_hit(status === 0)

def _phase_badge_hit(hit: U32) -> String:
  match hit:
    case 0:
      "Game Over"
    case _:
      "Run Active"

def _phase_chip_class(current_run: RunSlot) -> String:
  match current_run:
    case idle_run{}:
      "status-chip status-chip--idle"
    case run_slot{run_value}:
      _phase_chip_class_run(run_value)

def _phase_chip_class_run(run_value: Run) -> String:
  _phase_chip_class_status(_run_status(run_value))

def _phase_chip_class_status(status: U32) -> String:
  _phase_chip_class_hit(status === 0)

def _phase_chip_class_hit(hit: U32) -> String:
  match hit:
    case 0:
      "status-chip status-chip--over"
    case _:
      "status-chip status-chip--active"

def _button_attrs_enabled(class_name: String, evt: DungeonEvent) -> List(Attr(DungeonEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, on_click{evt}]

def _button_attrs_disabled(class_name: String) -> List(Attr(DungeonEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, attr{"disabled", "disabled"}]

def _button_attrs(class_name: String, evt: DungeonEvent, enabled: U32) -> List(Attr(DungeonEvent)):
  match enabled:
    case 0:
      _button_attrs_disabled(class_name)
    case _:
      _button_attrs_enabled(class_name, evt)

def _start_attrs(current_run: RunSlot) -> List(Attr(DungeonEvent)):
  _button_attrs("button", start{}, _is_idle(current_run))

def _upgrade_enabled(meta_state: Meta, current_run: RunSlot, cost: U32) -> U32:
  match _can_upgrade(current_run):
    case 0:
      0
    case _:
      _can_afford_upgrade(meta_state, cost)

def _upgrade_label_cost(cost: U32) -> String:
  match cost === 0:
    case 0:
      "Upgrade - " ++ U32.show(cost)
    case _:
      "Max Level"

def _upgrade_label(meta_state: Meta) -> String:
  _upgrade_label_cost(_next_upgrade_cost(meta_state))

def _upgrade_attrs(meta_state: Meta, current_run: RunSlot) -> List(Attr(DungeonEvent)):
  cost = _next_upgrade_cost(meta_state);
  _button_attrs("button button--secondary", upgrade{}, _upgrade_enabled(meta_state, current_run, cost))

def _hero_name() -> String:
  "Knight"

def _hero_sprite() -> String:
  "assets/hero.png"

def _gold_name() -> String:
  "Gold"

def _gold_sprite() -> String:
  "assets/drop-gold-chest.png"

def _monster_name(ref: U32) -> String:
  match ref:
    case 0:
      "Slime"
    case 1:
      "Ghoul"
    case 2:
      "Shade"
    case 3:
      "Brute"
    case _:
      "Monster"

def _monster_sprite(ref: U32) -> String:
  match ref:
    case 0:
      "assets/mob1.png"
    case 1:
      "assets/mob2.png"
    case 2:
      "assets/mob3.png"
    case 3:
      "assets/mob4.png"
    case _:
      ""

def _sword_name(ref: U32) -> String:
  match ref:
    case 0:
      "Bronze Sword"
    case 1:
      "Iron Sword"
    case 2:
      "Relic Sword"
    case _:
      "Sword"

def _sword_sprite(ref: U32) -> String:
  match ref:
    case 0:
      "assets/sword1.png"
    case 1:
      "assets/sword2.png"
    case 2:
      "assets/sword3.png"
    case _:
      ""

def _potion_name(ref: U32) -> String:
  "Potion"

def _potion_sprite(ref: U32) -> String:
  "assets/potion.png"

def _tile_name(tile: Tile) -> String:
  match tile:
    case none{}:
      "Empty"
    case monster{ref, hp}:
      _monster_name(ref)
    case sword{ref, dmg}:
      _sword_name(ref)
    case potion{ref, heal}:
      _potion_name(ref)
    case gold{amount}:
      _gold_name()

def _tile_sprite(tile: Tile) -> String:
  match tile:
    case none{}:
      ""
    case monster{ref, hp}:
      _monster_sprite(ref)
    case sword{ref, dmg}:
      _sword_sprite(ref)
    case potion{ref, heal}:
      _potion_sprite(ref)
    case gold{amount}:
      _gold_sprite()

def _tile_badge(tile: Tile) -> String:
  match tile:
    case none{}:
      ""
    case monster{ref, hp}:
      "HP " ++ U32.show(hp)
    case sword{ref, dmg}:
      "DMG " ++ U32.show(dmg)
    case potion{ref, heal}:
      "HEAL " ++ U32.show(heal)
    case gold{amount}:
      "GOLD " ++ U32.show(amount)

def _upgrade_cost_or_zero(step: Upgrade) -> U32:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp === 0:
        case 0:
          cost
        case _:
          0

def _hero_max_hp_from_config(cfg: Config, hero_level: U32) -> U32:
  match cfg:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      hero_max_hp(hero_base_max_hp, upgrades, hero_level)

def _next_upgrade_cost_from_config(cfg: Config, hero_level: U32) -> U32:
  match cfg:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level}:
      _upgrade_cost_or_zero(nth_upgrade(upgrades, hero_level))

def _hero_max_hp(meta_state: Meta) -> U32:
  _hero_max_hp_from_config(config(), _hero_level(meta_state))

def _next_upgrade_cost(meta_state: Meta) -> U32:
  _next_upgrade_cost_from_config(config(), _hero_level(meta_state))

# Styling

def base_css() -> String:
  ""
  ++ ":root{--bg:#ffffff;--surface:#f2f2f2;--surface-strong:#e3e3e3;--surface-border:#d2d2d2;--text:#111111;--text-muted:#555555;--accent:#202020;--danger:#c21c1c;--shadow:0 16px 40px rgba(17,17,17,0.08);--radius-lg:28px;--radius-md:20px;--radius-sm:14px;}"
  ++ "*{box-sizing:border-box;}html,body{margin:0;height:100%;min-height:100%;background:var(--bg);color:var(--text);font-family:'Avenir Next','Trebuchet MS',sans-serif;overflow-x:hidden;}body{overflow:hidden;overscroll-behavior:none;}button,input,select{font:inherit;}button{cursor:pointer;}img{display:block;max-width:100%;}#app,.page{min-height:100svh;}"

def layout_css() -> String:
  ""
  ++ ".shell{width:min(100%,560px);min-height:100svh;height:100svh;max-height:100svh;margin:0 auto;padding:calc(14px + env(safe-area-inset-top)) 14px calc(14px + env(safe-area-inset-bottom));display:grid;grid-template-rows:auto auto auto minmax(0,1fr);gap:12px;overflow:hidden;}"
  ++ ".topbar{display:flex;align-items:center;justify-content:flex-start;min-height:0;}.resource-bar{margin:0;display:inline-flex;align-items:baseline;gap:8px;color:var(--text-muted);font-size:0.78rem;font-weight:700;letter-spacing:0.06em;text-transform:uppercase;}.resource-bar__value{color:var(--text);font-size:1rem;letter-spacing:0;}"
  ++ ".button{display:inline-flex;align-items:center;justify-content:center;border:0;border-radius:999px;padding:14px 18px;font-weight:700;background:var(--accent);color:#fff;}.button--secondary{background:var(--surface);color:var(--text);}.button:disabled{opacity:0.45;cursor:not-allowed;}"
  ++ ".status-panel{display:grid;gap:10px;}.status-panel__head{display:flex;align-items:center;justify-content:flex-start;gap:10px;}.status-chip{margin:0;display:inline-flex;align-items:center;justify-content:center;padding:7px 10px;border-radius:999px;border:1px solid var(--surface-border);font-size:0.74rem;font-weight:700;letter-spacing:0.06em;text-transform:uppercase;background:#fff;}.status-chip--idle{color:#1f5db2;background:#edf4ff;}.status-chip--active{color:#0f6c4c;background:#ebfff5;}.status-chip--over{color:#8f1d1d;background:#fff1f1;}.status-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;}"
  ++ ".controls{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;align-items:start;}.upgrade-slot{display:grid;gap:6px;}.upgrade-slot__meta{margin:0;color:var(--text-muted);font-size:0.78rem;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;text-align:center;}.stat-panel{padding:10px 12px;background:#fff;border:1px solid var(--surface-border);border-radius:var(--radius-sm);}.stat-panel__label{display:block;margin-bottom:6px;color:var(--text-muted);font-size:0.78rem;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;}.stat-panel__value{font-size:0.98rem;line-height:1.2;}"
  ++ ".board-shell{position:relative;display:grid;min-height:0;place-items:center;}.board-shell--over .board{transform:scale(0.985);filter:blur(1px);}.board{position:relative;display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;width:min(100%,420px);touch-action:none;transition:transform 140ms ease,filter 140ms ease;}.game-over-modal{position:absolute;inset:0;display:grid;place-items:center;padding:16px;opacity:0;pointer-events:none;background:rgba(17,17,17,0);transition:opacity 140ms ease,background-color 140ms ease;}.game-over-modal--visible{opacity:1;pointer-events:auto;background:rgba(17,17,17,0.32);}.game-over-card{width:min(100%,280px);display:grid;gap:12px;justify-items:center;padding:20px 18px;background:#fff;border:1px solid var(--surface-border);border-radius:var(--radius-md);box-shadow:var(--shadow);text-align:center;}.game-over-card__eyebrow{margin:0;color:var(--danger);font-size:0.74rem;font-weight:700;letter-spacing:0.06em;text-transform:uppercase;}.game-over-card__title{margin:0;font-size:1.4rem;line-height:1;}"
  ++ "@media (max-width:800px){.shell{padding-inline:12px;gap:10px;}.status-grid,.controls{grid-template-columns:1fr;}.upgrade-slot__meta{text-align:left;}.board{gap:8px;width:min(100%,380px);}.game-over-card{width:min(100%,240px);padding:18px 16px;}}"

def cards_css() -> String:
  ""
  ++ ".board-slot{position:relative;}.board-slot>*{position:relative;z-index:1;}.board-slot::before{content:'';position:absolute;inset:-3px;border-radius:var(--radius-md);opacity:0;pointer-events:none;z-index:2;}.card{position:relative;display:flex;min-height:170px;flex-direction:column;justify-content:space-between;padding:12px;background:var(--surface);border:1px solid var(--surface-border);border-radius:var(--radius-md);box-shadow:var(--shadow);overflow:hidden;}.board .card{min-height:0;aspect-ratio:1 / 1;padding:10px;}.card__art-wrap{display:flex;flex:1;align-items:center;justify-content:center;padding:16px 10px;}.card__art{width:100%;max-width:116px;max-height:116px;object-fit:contain;}.card__label{font-size:0.95rem;font-weight:700;text-align:center;}.card__badge{position:absolute;display:inline-flex;align-items:center;justify-content:center;min-height:34px;padding:6px 10px;border-radius:999px;background:#fff;border:1px solid var(--surface-border);font-size:0.78rem;font-weight:700;}.card__badge--hp{top:10px;right:10px;color:var(--danger);}.card__badge--value{left:10px;bottom:10px;}.board .card__art-wrap{padding:18px 4px 10px;}.board .card__art{max-width:clamp(44px,16vw,80px);max-height:clamp(44px,16vw,80px);}.board .card__label{font-size:clamp(0.64rem,2vw,0.82rem);line-height:1.05;}.board .card__badge{min-height:28px;padding:4px 8px;font-size:0.68rem;}.board .card__badge--hp{top:8px;right:8px;}.board .card__badge--value{left:8px;bottom:8px;}.board .card--hero[data-dmg]::after{content:attr(data-dmg);position:absolute;left:8px;bottom:8px;display:inline-flex;align-items:center;justify-content:center;min-height:28px;padding:4px 8px;border-radius:999px;background:#fff;border:1px solid var(--surface-border);font-size:0.68rem;font-weight:700;color:#0f63c9;}.board .card--hero[data-dmg='']::after{content:none;}.card__empty{display:grid;flex:1;place-items:center;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;text-transform:uppercase;}.card--idle{background:linear-gradient(180deg,#f8f8f8,#ededed);}"

def fx_css() -> String:
  ""
  ++ ".button{transition:transform 120ms ease,background-color 120ms ease,opacity 120ms ease,color 120ms ease;}.button:not(:disabled):hover{transform:translateY(-1px);}"
  ++ ".board-slot--impact-a::before{animation:slot-impact-a 280ms ease-out;border:2px solid rgba(194,28,28,0.62);}.board-slot--impact-b::before{animation:slot-impact-b 280ms ease-out;border:2px solid rgba(194,28,28,0.62);}.board-slot--kill-a::before{animation:slot-kill-a 360ms ease-out;border:2px solid rgba(194,28,28,0.8);}.board-slot--kill-b::before{animation:slot-kill-b 360ms ease-out;border:2px solid rgba(194,28,28,0.8);}.card__badge--hp-heal-a{animation:badge-heal-pulse-a 320ms ease-out;}.card__badge--hp-heal-b{animation:badge-heal-pulse-b 320ms ease-out;}.card__badge--hp-hurt-a{animation:badge-hurt-pulse-a 300ms ease-out;}.card__badge--hp-hurt-b{animation:badge-hurt-pulse-b 300ms ease-out;}.card--hero-dmg-up-a,.card--hero-dmg-up-b,.card--hero-dmg-down-a,.card--hero-dmg-down-b{will-change:transform;}.card--hero-dmg-up-a::after{animation:dmg-badge-up-a 280ms ease-out;}.card--hero-dmg-up-b::after{animation:dmg-badge-up-b 280ms ease-out;}.card--hero-dmg-down-a::after{animation:dmg-badge-down-a 260ms ease-out;}.card--hero-dmg-down-b::after{animation:dmg-badge-down-b 260ms ease-out;}"
  ++ "@keyframes slot-impact-a{0%{opacity:0;transform:scale(0.98);box-shadow:0 0 0 0 rgba(194,28,28,0);}30%{opacity:1;transform:scale(1.01);box-shadow:0 0 0 7px rgba(194,28,28,0.14);}100%{opacity:0;transform:scale(1.02);box-shadow:0 0 0 12px rgba(194,28,28,0);}}"
  ++ "@keyframes slot-impact-b{0%{opacity:0;transform:scale(0.98);box-shadow:0 0 0 0 rgba(194,28,28,0);}30%{opacity:1;transform:scale(1.01);box-shadow:0 0 0 7px rgba(194,28,28,0.14);}100%{opacity:0;transform:scale(1.02);box-shadow:0 0 0 12px rgba(194,28,28,0);}}"
  ++ "@keyframes slot-kill-a{0%{opacity:0;transform:scale(0.96);box-shadow:0 0 0 0 rgba(194,28,28,0);}24%{opacity:1;transform:scale(1.02);box-shadow:0 0 0 10px rgba(194,28,28,0.18);}100%{opacity:0;transform:scale(1.05);box-shadow:0 0 0 16px rgba(194,28,28,0);}}"
  ++ "@keyframes slot-kill-b{0%{opacity:0;transform:scale(0.96);box-shadow:0 0 0 0 rgba(194,28,28,0);}24%{opacity:1;transform:scale(1.02);box-shadow:0 0 0 10px rgba(194,28,28,0.18);}100%{opacity:0;transform:scale(1.05);box-shadow:0 0 0 16px rgba(194,28,28,0);}}"
  ++ "@keyframes badge-heal-pulse-a{0%{transform:scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}35%{transform:scale(1.08);box-shadow:0 0 0 8px rgba(15,99,201,0.14);}100%{transform:scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}}"
  ++ "@keyframes badge-heal-pulse-b{0%{transform:scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}35%{transform:scale(1.08);box-shadow:0 0 0 8px rgba(15,99,201,0.14);}100%{transform:scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}}"
  ++ "@keyframes badge-hurt-pulse-a{0%{transform:scale(1);box-shadow:0 0 0 rgba(194,28,28,0);}35%{transform:scale(0.96);box-shadow:0 0 0 9px rgba(194,28,28,0.16);}100%{transform:scale(1);box-shadow:0 0 0 rgba(194,28,28,0);}}"
  ++ "@keyframes badge-hurt-pulse-b{0%{transform:scale(1);box-shadow:0 0 0 rgba(194,28,28,0);}35%{transform:scale(0.96);box-shadow:0 0 0 9px rgba(194,28,28,0.16);}100%{transform:scale(1);box-shadow:0 0 0 rgba(194,28,28,0);}}"
  ++ "@keyframes dmg-badge-up-a{0%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}35%{transform:translateY(-2px) scale(1.08);box-shadow:0 0 0 7px rgba(15,99,201,0.14);}100%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}}"
  ++ "@keyframes dmg-badge-up-b{0%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}35%{transform:translateY(-2px) scale(1.08);box-shadow:0 0 0 7px rgba(15,99,201,0.14);}100%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(15,99,201,0);}}"
  ++ "@keyframes dmg-badge-down-a{0%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(12,18,28,0);}35%{transform:translateY(1px) scale(0.94);box-shadow:0 0 0 7px rgba(12,18,28,0.12);}100%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(12,18,28,0);}}"
  ++ "@keyframes dmg-badge-down-b{0%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(12,18,28,0);}35%{transform:translateY(1px) scale(0.94);box-shadow:0 0 0 7px rgba(12,18,28,0.12);}100%{transform:translateY(0) scale(1);box-shadow:0 0 0 rgba(12,18,28,0);}}"

def css() -> String:
  base_css()
  ++ layout_css()
  ++ cards_css()
  ++ fx_css()

main : App =
  app{DungeonState, DungeonEvent, init, render, on_event}
