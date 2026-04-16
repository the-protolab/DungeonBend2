import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/PackInventoryEntry as PackInventoryEntry
import /Dungeon/HeroDef as HeroDef
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/Meta as Meta
import /Dungeon/Config as Config
import /Dungeon/hero_helpers/hero_starts_unlocked as hero_starts_unlocked

def default_hero_profile() -> HeroProfile:
  hero_profile{0, 0}

def default_profile_for_hero(hero_ref: U32) -> HeroProfile:
  match hero_ref:
    case 0:
      hero_profile{1, 0}
    case _:
      default_hero_profile()

def default_profile_from_hero(hero_value: HeroDef) -> HeroProfile:
  hero_profile{hero_starts_unlocked(hero_value), 0}

def default_hero_profiles(config_value: Config) -> List(HeroProfile):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _default_hero_profiles_from_list(heroes, 0)

def _default_hero_profiles_from_list(heroes: List(HeroDef), hero_ref: U32) -> List(HeroProfile):
  match heroes:
    case []:
      []
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades}<>rest:
      default_profile_from_hero(hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades})<>_default_hero_profiles_from_list(rest, hero_ref + 1)

def selected_hero(meta_state: Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, selection_confirmed, gold, bonus_deck, pack_inventory, hero_profiles}:
      selected_hero_ref

def selection_confirmed(meta_state: Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, hero_profiles}:
      confirmed

def hero_profiles(meta_state: Meta) -> List(HeroProfile):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      profiles

def meta_gold(meta_state: Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      gold

def meta_bonus_deck(meta_state: Meta) -> List(DeckEntry):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      bonus_deck

def meta_pack_inventory(meta_state: Meta) -> List(PackInventoryEntry):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      pack_inventory

def profile_for_hero(meta_state: Meta, hero_ref: U32) -> HeroProfile:
  _profile_at(hero_profiles(meta_state), hero_ref)

def _profile_at(profiles: List(HeroProfile), hero_ref: U32) -> HeroProfile:
  match profiles:
    case []:
      default_profile_for_hero(hero_ref)
    case hero_profile{unlocked, hero_level}<>rest:
      match hero_ref:
        case 0:
          hero_profile{unlocked, hero_level}
        case _:
          _profile_at(rest, hero_ref - 1)

def active_profile(meta_state: Meta) -> HeroProfile:
  profile_for_hero(meta_state, selected_hero(meta_state))

def update_profile(meta_state: Meta, hero_ref: U32, next_profile: HeroProfile) -> Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, _update_profile_list(profiles, hero_ref, next_profile)}

def _update_profile_list(profiles: List(HeroProfile), hero_ref: U32, next_profile: HeroProfile) -> List(HeroProfile):
  match profiles:
    case []:
      _update_profile_missing(hero_ref, next_profile, 0)
    case current<>rest:
      _update_profile_list_match(hero_ref === 0, current, rest, hero_ref, next_profile)

def _update_profile_list_match(matched: U32, current: HeroProfile, rest: List(HeroProfile), hero_ref: U32, next_profile: HeroProfile) -> List(HeroProfile):
  match matched:
    case 0:
      current<>_update_profile_list(rest, hero_ref - 1, next_profile)
    case _:
      next_profile<>rest

def _update_profile_missing(hero_ref: U32, next_profile: HeroProfile, current_ref: U32) -> List(HeroProfile):
  match hero_ref:
    case 0:
      [next_profile]
    case _:
      default_profile_for_hero(current_ref)<>_update_profile_missing(hero_ref - 1, next_profile, current_ref + 1)

def set_selected_hero(meta_state: Meta, hero_ref: U32) -> Meta:
  match meta_state:
    case meta{current_selected, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}

def set_selection_confirmed(meta_state: Meta, confirmed: U32) -> Meta:
  match meta_state:
    case meta{selected_hero_ref, current_confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}

def set_meta_gold(meta_state: Meta, next_gold: U32) -> Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{selected_hero_ref, confirmed, next_gold, bonus_deck, pack_inventory, profiles}

def set_meta_bonus_deck(meta_state: Meta, next_bonus_deck: List(DeckEntry)) -> Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{selected_hero_ref, confirmed, gold, next_bonus_deck, pack_inventory, profiles}

def set_meta_pack_inventory(meta_state: Meta, next_pack_inventory: List(PackInventoryEntry)) -> Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, next_pack_inventory, profiles}

def profile_unlocked(profile: HeroProfile) -> U32:
  match profile:
    case hero_profile{unlocked, hero_level}:
      unlocked

def profile_hero_level(profile: HeroProfile) -> U32:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_level

def profile_with_unlocked(profile: HeroProfile, next_unlocked: U32) -> HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{next_unlocked, hero_level}

def profile_with_level(profile: HeroProfile, next_level: U32) -> HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{unlocked, next_level}

def profile_with_unlocked_and_level(profile: HeroProfile, next_unlocked: U32, next_level: U32) -> HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{next_unlocked, next_level}
