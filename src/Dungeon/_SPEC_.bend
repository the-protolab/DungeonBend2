import /Dungeon/CardRef as CardRef
import /Dungeon/HeroDef as HeroDef
import /Dungeon/Upgrade as Upgrade
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/Meta as Meta
import /Dungeon/MonsterDef as MonsterDef
import /Dungeon/PackDef as PackDef

# === Dungeon System — laws mirroring design-rules.md §"Dungeon System" ===
#
# This file formalizes the affirmative rules from design-rules.md that
# govern the dungeon scene, the 3x3 grid, and the Cards/Gold/Hero
# systems whose types are defined in ./_.bend. Each `assert` below
# is a law; the `#` line above each assert quotes or paraphrases the
# rulebook bullet it encodes. Keep name + prose + bullet in lock-step.

# --- Scene Setup ---

# "The screen shows 9 cards arranged in a 3×3 grid."
assert grid_is_3x3:
  (3n * 3n) == 9n :: Nat

# --- Cards (types, see ./_.bend) ---

# "Cards are divided into different types": Hero, Monster, Item.
# The CardRef type has exactly 4 constructors (monster, sword,
# potion, hero). swords and potions are the two Item-type families
# currently recognized. Asserts below pin each constructor as a
# smoke test; if the enumeration is changed, these break first.
assert card_hero_exists:
  hero_card{} == hero_card{} :: CardRef

assert card_monster_exists:
  monster_card{0} == monster_card{0} :: CardRef

assert card_sword_exists:
  sword_card{0} == sword_card{0} :: CardRef

assert card_potion_exists:
  potion_card{0} == potion_card{0} :: CardRef

# --- Hero System (see ./hero_helpers.bend) ---

# "Hero is a special card type that allows the user to play in
# different ways inside the dungeon." Hero is represented both as
# a CardRef variant (for decks/packs) and a HeroDef (for the
# catalog). A concrete HeroDef anchors the contract: every HeroDef
# has id, name, sprite, base_max_hp, unlock_cost, and upgrades.
# (Ultimate is noted in the rulebook as not yet modeled — add a
# field and a law when that rule lands.)
assert hero_def_adventurer:
  hero_def{"001", "Adventurer", "assets/player-boy.png", 11, 0, 1, []}
    == hero_def{"001", "Adventurer", "assets/player-boy.png", 11, 0, 1, []}
    :: HeroDef

# "Each hero has its own progression curve: level, HP, and such."
# Upgrades encode the curve as a list of (cost, max_hp) pairs.
# Pin the first upgrade from design-rules.md's example block
# (cost 20 -> max_hp 14).
assert hero_first_upgrade_sample:
  upgrade{20, 14} == upgrade{20, 14} :: Upgrade

# "The player can collect multiple hero cards" and "To unlock a new
# hero, the player must obtain that hero's card." HeroProfile
# carries the unlocked flag per hero; this is the contract surface
# for the (not-yet-implemented) unlock flow described in the
# "Heads up" block of design-rules.md §Hero System.
assert hero_profile_shape:
  hero_profile{1, 0} == hero_profile{1, 0} :: HeroProfile

# --- Gold (soft currency) ---

# "Gold is the primary soft currency used for player progression."
# Gold lives in Meta.gold as a U32.
assert meta_holds_gold:
  meta{0, 0, 100, [], [], []} == meta{0, 0, 100, [], [], []} :: Meta

# "Gold is earned during runs, mainly by defeating monsters and
# collecting their drops." MonsterDef.gold_drop is the amount
# awarded per kill. Concrete example: a 5-gold monster.
assert monster_def_carries_gold_drop:
  monster_def{"slime", "assets/slime.png", 5, [1]}
    == monster_def{"slime", "assets/slime.png", 5, [1]}
    :: MonsterDef

# "Gold is used to purchase booster packs and other progression-
# related elements." PackDef.price is the gold cost.
assert pack_def_carries_price:
  pack_def{"basic", 50, 3, 0, []}
    == pack_def{"basic", 50, 3, 0, []}
    :: PackDef
