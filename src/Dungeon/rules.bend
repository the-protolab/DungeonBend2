import /Dungeon/generated_rules/generated_initial_seed as generated_initial_seed
import /Dungeon/generated_rules/generated_starting_gold as generated_starting_gold
import /Dungeon/generated_rules/generated_starting_selected_hero as generated_starting_selected_hero
import /Dungeon/generated_rules/generated_starting_selection_confirmed as generated_starting_selection_confirmed
import /Dungeon/generated_rules/generated_starting_dungeon_level as generated_starting_dungeon_level
import /Dungeon/generated_rules/generated_dungeon_level_increment_per_refill as generated_dungeon_level_increment_per_refill
import /Dungeon/generated_rules/generated_ultimate_charge_required as generated_ultimate_charge_required
import /Dungeon/generated_rules/generated_ultimate_charge_per_move as generated_ultimate_charge_per_move

def initial_seed_value() -> U32:
  generated_initial_seed()

def starting_gold() -> U32:
  generated_starting_gold()

def starting_selected_hero() -> U32:
  generated_starting_selected_hero()

def starting_selection_confirmed() -> U32:
  generated_starting_selection_confirmed()

def starting_dungeon_level() -> U32:
  generated_starting_dungeon_level()

def dungeon_level_increment_per_refill() -> U32:
  generated_dungeon_level_increment_per_refill()

def ultimate_charge_required() -> U32:
  generated_ultimate_charge_required()

def ultimate_charge_per_move() -> U32:
  generated_ultimate_charge_per_move()
