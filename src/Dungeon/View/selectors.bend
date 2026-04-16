import /U32/ as U32
import /Dungeon/Upgrade as Upgrade
import /Dungeon/HeroDef as HeroDef
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/PackDef as PackDef
import /Dungeon/PackReward as PackReward
import /Dungeon/Weapon as Weapon
import /Dungeon/Meta as Meta
import /Dungeon/Run as Run
import /Dungeon/Scene as Scene
import /Dungeon/config as config
import /Dungeon/CardRef as CardRef
import /Dungeon/Config as Config
import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/Deck/counts_pick/hero_max_hp as hero_max_hp
import /Dungeon/Deck/counts_pick/nth_upgrade as nth_upgrade
import /Dungeon/Deck/counts_pick/deck_count_for_card as deck_count_for_card
import /Dungeon/Deck/counts_pick/merge_deck_entries as merge_deck_entries
import /Dungeon/profile_helpers/meta_bonus_deck as meta_bonus_deck
import /Dungeon/Boosters/inventory/pack_inventory_count as pack_inventory_count
import /Dungeon/Boosters/inventory/pack_inventory_total as pack_inventory_total
import /Dungeon/Boosters/packs/active_pack as active_pack
import /Dungeon/Boosters/reward_nav/reward_count as reward_count
import /Dungeon/hero_helpers/hero_base_max_hp as hero_base_max_hp
import /Dungeon/hero_helpers/hero_unlock_cost as hero_unlock_cost
import /Dungeon/hero_helpers/hero_upgrades as hero_upgrades
import /Dungeon/profile_helpers/meta_gold as meta_gold_value
import /Dungeon/profile_helpers/meta_pack_inventory as meta_pack_inventory_value
import /Dungeon/profile_helpers/selected_hero as selected_hero
import /Dungeon/profile_helpers/selection_confirmed as selection_confirmed
import /Dungeon/profile_helpers/profile_unlocked as profile_unlocked
import /Dungeon/profile_helpers/profile_hero_level as profile_hero_level
import /Dungeon/rules/ultimate_charge_required as ultimate_charge_required

def meta_gold(meta_state: Meta) -> String:
  U32.show(meta_gold_value(meta_state))

def meta_pack_total(meta_state: Meta) -> String:
  U32.show(pack_inventory_total(meta_pack_inventory_value(meta_state)))

def hero_level_text(profile: HeroProfile) -> String:
  "Hero Lv " ++ U32.show(profile_hero_level(profile))

def hero_display_level(profile: HeroProfile) -> String:
  U32.show(profile_hero_level(profile) + 1)

def hero_menu_level_text(profile: HeroProfile) -> String:
  "LV: " ++ hero_display_level(profile)

def hero_menu_current_hp_text(hero_value: HeroDef, profile: HeroProfile) -> String:
  hero_menu_max_hp_text(hero_value, profile)

def hero_menu_max_hp_text(hero_value: HeroDef, profile: HeroProfile) -> String:
  U32.show(hero_max_hp_value(hero_value, profile))

def _run_dungeon_level(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      dungeon_level

def _two_digit_value(value: U32) -> String:
  match value < 10:
    case 1:
      "0" ++ U32.show(value)
    case _:
      U32.show(value)

def _run_dungeon_level_text(run_value: Run) -> String:
  _two_digit_value(_run_dungeon_level(run_value))

def _run_remaining_text(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      U32.show(remaining) ++ "/" ++ U32.show(capacity)

def _weapon_value_from_weapon(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      "Unarmed"
    case weapon{ref, dmg}:
      "DMG " ++ U32.show(dmg)

def _run_weapon_text(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      _weapon_value_from_weapon(weapon)

def _run_ult_label(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      "ULTIMATE " ++ U32.show(ult_charge) ++ "/" ++ U32.show(ultimate_charge_required())

def _run_ult_ready(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge}:
      _run_ult_ready_flag(ult_charge < ultimate_charge_required())

def _run_ult_ready_flag(charge_lt_required: U32) -> U32:
  match charge_lt_required:
    case 0:
      1
    case _:
      0

def dungeon_level_value(scene_value: Scene) -> String:
  match scene_value:
    case setup{}:
      "--"
    case character_select{preview_hero}:
      "--"
    case boosters{reward, reveal_index}:
      "--"
    case running{run_value}:
      _run_dungeon_level_text(run_value)
    case resume_prompt{run_value}:
      _run_dungeon_level_text(run_value)
    case game_over{run_value}:
      _run_dungeon_level_text(run_value)

def remaining_value(scene_value: Scene) -> String:
  match scene_value:
    case setup{}:
      "--/--"
    case character_select{preview_hero}:
      "--/--"
    case boosters{reward, reveal_index}:
      "--/--"
    case running{run_value}:
      _run_remaining_text(run_value)
    case resume_prompt{run_value}:
      _run_remaining_text(run_value)
    case game_over{run_value}:
      _run_remaining_text(run_value)

def weapon_value(scene_value: Scene) -> String:
  match scene_value:
    case setup{}:
      "--"
    case character_select{preview_hero}:
      "--"
    case boosters{reward, reveal_index}:
      "--"
    case running{run_value}:
      _run_weapon_text(run_value)
    case resume_prompt{run_value}:
      _run_weapon_text(run_value)
    case game_over{run_value}:
      _run_weapon_text(run_value)

def ultimate_label(scene_value: Scene) -> String:
  match scene_value:
    case setup{}:
      "ULTIMATE 0/" ++ U32.show(ultimate_charge_required())
    case character_select{preview_hero}:
      "ULTIMATE 0/" ++ U32.show(ultimate_charge_required())
    case boosters{reward, reveal_index}:
      "ULTIMATE 0/" ++ U32.show(ultimate_charge_required())
    case running{run_value}:
      _run_ult_label(run_value)
    case resume_prompt{run_value}:
      _run_ult_label(run_value)
    case game_over{run_value}:
      _run_ult_label(run_value)

def ultimate_enabled(scene_value: Scene) -> U32:
  match scene_value:
    case running{run_value}:
      _run_ult_ready(run_value)
    case _:
      0

def start_enabled(scene_value: Scene) -> U32:
  match scene_value:
    case setup{}:
      1
    case _:
      0

def can_upgrade(scene_value: Scene) -> U32:
  start_enabled(scene_value)

def _can_afford_upgrade_gold(gold: U32, cost: U32) -> U32:
  match cost:
    case 0:
      0
    case _:
      _can_afford_upgrade_flag(gold < cost)

def _can_afford_upgrade_flag(gold_lt_cost: U32) -> U32:
  match gold_lt_cost:
    case 0:
      1
    case _:
      0

def can_afford_upgrade(meta_state: Meta, cost: U32) -> U32:
  _can_afford_upgrade_gold(meta_gold_value(meta_state), cost)

def upgrade_enabled(meta_state: Meta, scene_value: Scene, cost: U32) -> U32:
  _upgrade_enabled_flag(can_upgrade(scene_value), can_afford_upgrade(meta_state, cost))

def _upgrade_enabled_flag(can_upgrade_value: U32, can_afford_value: U32) -> U32:
  match can_upgrade_value:
    case 0:
      0
    case _:
      can_afford_value

def _upgrade_cost_or_zero(step: Upgrade) -> U32:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp:
        case 0:
          0
        case _:
          cost

def hero_max_hp_value(hero_value: HeroDef, profile: HeroProfile) -> U32:
  hero_max_hp(hero_base_max_hp(hero_value), hero_upgrades(hero_value), profile_hero_level(profile))

def next_upgrade_cost(hero_value: HeroDef, profile: HeroProfile) -> U32:
  _upgrade_cost_or_zero(nth_upgrade(hero_upgrades(hero_value), profile_hero_level(profile)))

def menu_upgrade_visible(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> U32:
  upgrade_enabled(meta_state, setup{}, next_upgrade_cost(hero_value, profile))

def upgrade_label(hero_value: HeroDef, profile: HeroProfile) -> String:
  _upgrade_label_cost(next_upgrade_cost(hero_value, profile))

def _upgrade_label_cost(cost: U32) -> String:
  match cost:
    case 0:
      "Max Level"
    case _:
      "Upgrade - " ++ U32.show(cost)

def menu_upgrade_label(hero_value: HeroDef, profile: HeroProfile) -> String:
  _menu_upgrade_label_cost(next_upgrade_cost(hero_value, profile))

def _menu_upgrade_label_cost(cost: U32) -> String:
  match cost:
    case 0:
      "MAX LEVEL"
    case _:
      "UPGRADE"

def menu_upgrade_cost_text(hero_value: HeroDef, profile: HeroProfile) -> String:
  _menu_upgrade_cost_text(next_upgrade_cost(hero_value, profile))

def _menu_upgrade_cost_text(cost: U32) -> String:
  match cost:
    case 0:
      "MAX"
    case _:
      U32.show(cost)

def _unlock_cost_text(cost: U32) -> String:
  U32.show(cost)

def character_upgrade_label(hero_value: HeroDef, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      "LOCKED"
    case _:
      menu_upgrade_label(hero_value, profile)

def character_upgrade_cost_text(hero_value: HeroDef, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      _unlock_cost_text(hero_unlock_cost(hero_value))
    case _:
      menu_upgrade_cost_text(hero_value, profile)

def character_upgrade_enabled(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> U32:
  match profile_unlocked(profile):
    case 0:
      0
    case _:
      menu_upgrade_visible(meta_state, hero_value, profile)

def _character_selected(meta_state: Meta, hero_ref: U32) -> U32:
  _character_selected_confirmed(selection_confirmed(meta_state), selected_hero(meta_state) === hero_ref)

def _character_selected_confirmed(confirmed: U32, same_ref: U32) -> U32:
  match confirmed:
    case 0:
      0
    case _:
      same_ref

def character_primary_label(meta_state: Meta, hero_ref: U32, hero_value: HeroDef, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      "BUY"
    case _:
      _character_select_label(_character_selected(meta_state, hero_ref))

def _character_select_label(is_selected: U32) -> String:
  match is_selected:
    case 0:
      "SELECT"
    case _:
      "SELECTED"

def character_primary_enabled(meta_state: Meta, hero_ref: U32, hero_value: HeroDef, profile: HeroProfile) -> U32:
  match profile_unlocked(profile):
    case 0:
      _can_afford_upgrade_gold(meta_gold_value(meta_state), hero_unlock_cost(hero_value))
    case _:
      _character_select_enabled(_character_selected(meta_state, hero_ref))

def _character_select_enabled(is_selected: U32) -> U32:
  match is_selected:
    case 0:
      1
    case _:
      0

def game_over_modal_class(scene_value: Scene) -> String:
  match scene_value:
    case resume_prompt{run_value}:
      "game-over-modal game-over-modal--visible"
    case game_over{run_value}:
      "game-over-modal game-over-modal--visible"
    case _:
      "game-over-modal"

def active_pack_name() -> String:
  _pack_name(active_pack(config()))

def _pack_name(pack: PackDef) -> String:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      name

def active_pack_price() -> U32:
  _pack_price(active_pack(config()))

def _pack_price(pack: PackDef) -> U32:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      price

def active_pack_reveal_count() -> String:
  _pack_reveal_count(active_pack(config()))

def _pack_reveal_count(pack: PackDef) -> String:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      U32.show(reveal_count)

def active_pack_owned(meta_state: Meta) -> U32:
  pack_inventory_count(meta_pack_inventory_value(meta_state), 0)

def active_pack_owned_text(meta_state: Meta) -> String:
  U32.show(active_pack_owned(meta_state))

def booster_buy_enabled(meta_state: Meta) -> U32:
  _can_afford_upgrade_gold(meta_gold_value(meta_state), active_pack_price())

def booster_open_enabled(meta_state: Meta) -> U32:
  _booster_open_enabled(active_pack_owned(meta_state))

def _booster_open_enabled(owned: U32) -> U32:
  match owned:
    case 0:
      0
    case _:
      1

def booster_prev_enabled(reveal_index: U32) -> U32:
  match reveal_index:
    case 0:
      0
    case _:
      1

def booster_next_enabled(reward: PackReward, reveal_index: U32) -> U32:
  _booster_next_enabled(reward_count(reward), reveal_index)

def _booster_next_enabled(count: U32, reveal_index: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _booster_next_enabled_match(reveal_index + 1 < count)

def _booster_next_enabled_match(enabled: U32) -> U32:
  match enabled:
    case 0:
      0
    case _:
      1

def booster_reward_position_text(reward: PackReward, reveal_index: U32) -> String:
  _booster_reward_position_text(reward_count(reward), reveal_index)

def _booster_reward_position_text(count: U32, reveal_index: U32) -> String:
  match count:
    case 0:
      ""
    case _:
      U32.show(reveal_index + 1) ++ "/" ++ U32.show(count)

def booster_is_last_card(reward: PackReward, reveal_index: U32) -> U32:
  _booster_is_last_card(reward_count(reward), reveal_index)

def _booster_is_last_card(count: U32, reveal_index: U32) -> U32:
  match count:
    case 0:
      1
    case _:
      (reveal_index + 1) === count

def _full_deck(meta_state: Meta) -> List(DeckEntry):
  _full_deck_from_config(config(), meta_bonus_deck(meta_state))

def _full_deck_from_config(config_value: Config, bonus: List(DeckEntry)) -> List(DeckEntry):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      merge_deck_entries(deck, bonus)

def card_copies(meta_state: Meta, card: CardRef) -> String:
  U32.show(deck_count_for_card(_full_deck(meta_state), card))
