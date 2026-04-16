import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Tile as Tile
import /Dungeon/DrawResult as DrawResult
import /Dungeon/Config as Config
import /Dungeon/_PickResult as _PickResult
import /Dungeon/Deck/counts_pick/sum_counts as sum_counts
import /Dungeon/Deck/counts_pick/_pick_entry as _pick_entry
import /Dungeon/Deck/counts_pick/next_seed as next_seed
import /Dungeon/Deck/counts_pick/_monster_hp as _monster_hp
import /Dungeon/Deck/counts_pick/_sword_damage as _sword_damage
import /Dungeon/Deck/counts_pick/_potion_heal as _potion_heal
import /Dungeon/rules/dungeon_level_increment_per_refill as dungeon_level_increment_per_refill

def _spawn_tile(config_value: Config, entry: DeckEntry, level: U32) -> Tile:
  match config_value entry:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} monster_entry{ref, count}:
      monster{ref, _monster_hp(monsters, ref, level)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} sword_entry{ref, count}:
      sword{ref, _sword_damage(swords, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} potion_entry{ref, count}:
      potion{ref, _potion_heal(potions, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} hero_entry{count}:
      none{}

def _draw_from_pick(config_value: Config, remaining: U32, next_seed_value: U32, level: U32, entry: DeckEntry, counts: List(DeckEntry)) -> DrawResult:
  draw_result{_spawn_tile(config_value, entry, level), counts, remaining - 1, next_seed_value, level}

def _pick_result_to_draw(config_value: Config, remaining: U32, next_seed_value: U32, level: U32, result: _PickResult) -> DrawResult:
  match result:
    case no_pick{counts}:
      draw_result{none{}, counts, remaining, next_seed_value, level}
    case picked_entry{entry, counts}:
      _draw_from_pick(config_value, remaining, next_seed_value, level, entry, counts)

def _draw_from_counts(config_value: Config, draw_counts: List(DeckEntry), remaining: U32, seed: U32, level: U32) -> DrawResult:
  match remaining:
    case 0:
      draw_result{none{}, draw_counts, 0, next_seed(seed), level}
    case _:
      idx = seed % remaining;
      next = next_seed(seed);
      _pick_result_to_draw(config_value, remaining, next, level, _pick_entry(draw_counts, idx))

def draw_tile(config_value: Config, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, seed: U32, level: U32) -> DrawResult:
  match remaining:
    case 0:
      refill = sum_counts(deck_blueprint);
      _draw_from_counts(config_value, deck_blueprint, refill, seed, level + dungeon_level_increment_per_refill())
    case _:
      _draw_from_counts(config_value, draw_counts, remaining, seed, level)
