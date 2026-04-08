import /Dungeon/Upgrade as Upgrade
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/Deck/counts_pick/nth_upgrade as nth_upgrade

def upgrade_hero(config_value: Config, meta_state: Meta) -> Meta:
  match config_value meta_state:
    case config{hero_base_max_hp, upgrades, monsters, swords, potions, deck, base_deck_size, starting_dungeon_level} meta{hero_level, gold_value}:
      _upgrade_from_step(hero_level, gold_value, meta{hero_level, gold_value}, nth_upgrade(upgrades, hero_level))

def _upgrade_from_step(hero_level: U32, gold_value: U32, meta_state: Meta, step: Upgrade) -> Meta:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp:
        case 0:
          meta_state
        case _:
          _upgrade_if_affordable(hero_level, gold_value, meta_state, cost)

def _upgrade_if_affordable(hero_level: U32, gold_value: U32, meta_state: Meta, cost: U32) -> Meta:
  _upgrade_if_affordable_flag(gold_value < cost, hero_level, gold_value, meta_state, cost)

def _upgrade_if_affordable_flag(gold_lt_cost: U32, hero_level: U32, gold_value: U32, meta_state: Meta, cost: U32) -> Meta:
  match gold_lt_cost:
    case 0:
      meta{hero_level + 1, gold_value - cost}
    case _:
      meta_state
