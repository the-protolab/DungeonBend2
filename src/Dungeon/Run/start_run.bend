import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Weapon as Weapon
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/Run as Run
import /Dungeon/BoardDraw as BoardDraw
import /Dungeon/Deck/counts_pick/hero_max_hp as hero_max_hp
import /Dungeon/Deck/counts_pick/remove_hero_card as remove_hero_card
import /Dungeon/Deck/counts_pick/sum_counts as sum_counts
import /Dungeon/Board/indexing/empty_board as empty_board
import /Dungeon/Run/refill/_refill_non_hero_slots as _refill_non_hero_slots

def _start_from_board(hero_max: U32, blueprint: List(DeckEntry), capacity: U32, stage: BoardDraw) -> Run:
  match stage:
    case board_draw{board_value, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_max, hero_max, 4, no_weapon{}, board_value, blueprint, next_counts, next_remaining, capacity, next_seed_value, 0}

def start_run(config_value: Config, meta_state: Meta, seed: U32) -> Run:
  match config_value meta_state:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} meta{hero_level, gold}:
      current = (config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} :: Config);
      hero_max = hero_max_hp(hero_base_max_hp, upgrades, hero_level);
      blueprint = remove_hero_card(deck);
      remaining = sum_counts(blueprint);
      _start_from_board(hero_max, blueprint, base_deck_size, _refill_non_hero_slots(current, empty_board(), 4, blueprint, blueprint, remaining, seed, starting_dungeon_level))
