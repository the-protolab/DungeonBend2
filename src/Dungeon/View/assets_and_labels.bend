import /U32/ as U32
import /Dungeon/Config as Config
import /Dungeon/HeroDef as HeroDef
import /Dungeon/MonsterDef as MonsterDef
import /Dungeon/SwordDef as SwordDef
import /Dungeon/PotionDef as PotionDef
import /Dungeon/CardRef as CardRef
import /Dungeon/Tile as Tile
import /Dungeon/config as config
import /Dungeon/hero_helpers/hero_at as hero_at
import /Dungeon/hero_helpers/hero_name as hero_name
import /Dungeon/hero_helpers/hero_sprite as hero_sprite
import /Dungeon/Content/ as Content

def _hero_name() -> String:
  hero_name(hero_at(config(), 0))

def _hero_sprite() -> String:
  hero_sprite(hero_at(config(), 0))

def _gold_name() -> String:
  Content.item_gold_name()

def _gold_icon() -> String:
  "assets/icon_gold.png"

def _gold_sprite() -> String:
  "assets/item-gold.png"

def _dungeon_level_badge_backdrop() -> String:
  "assets/ui/dungeon/dungeon-level.png"

def _dungeon_level_value_backdrop() -> String:
  "assets/ui/dungeon/paper-back.png"

def _monster_name(ref: U32) -> String:
  _monster_name_from_defs(config(), ref)

def _monster_name_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_name_from_list(monsters, ref)

def _monster_name_from_list(monsters: List(MonsterDef), ref: U32) -> String:
  match monsters:
    case []:
      Content.fallback_monster_name()
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      match ref:
        case 0:
          name
        case _:
          _monster_name_from_list(rest, ref - 1)

def _monster_sprite(ref: U32) -> String:
  _monster_sprite_from_defs(config(), ref)

def _monster_sprite_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_sprite_from_list(monsters, ref)

def _monster_sprite_from_list(monsters: List(MonsterDef), ref: U32) -> String:
  match monsters:
    case []:
      ""
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      match ref:
        case 0:
          sprite
        case _:
          _monster_sprite_from_list(rest, ref - 1)

def _sword_name(ref: U32) -> String:
  _sword_name_from_defs(config(), ref)

def _sword_name_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _sword_name_from_list(swords, ref)

def _sword_name_from_list(swords: List(SwordDef), ref: U32) -> String:
  match swords:
    case []:
      Content.fallback_weapon_name()
    case sword_def{name, sprite, dmg}<>rest:
      match ref:
        case 0:
          name
        case _:
          _sword_name_from_list(rest, ref - 1)

def _sword_sprite(ref: U32) -> String:
  _sword_sprite_from_defs(config(), ref)

def _sword_sprite_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _sword_sprite_from_list(swords, ref)

def _sword_sprite_from_list(swords: List(SwordDef), ref: U32) -> String:
  match swords:
    case []:
      ""
    case sword_def{name, sprite, dmg}<>rest:
      match ref:
        case 0:
          sprite
        case _:
          _sword_sprite_from_list(rest, ref - 1)

def _potion_name(ref: U32) -> String:
  _potion_name_from_defs(config(), ref)

def _potion_name_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _potion_name_from_list(potions, ref)

def _potion_name_from_list(potions: List(PotionDef), ref: U32) -> String:
  match potions:
    case []:
      Content.fallback_potion_name()
    case potion_def{name, sprite, heal}<>rest:
      match ref:
        case 0:
          name
        case _:
          _potion_name_from_list(rest, ref - 1)

def _potion_sprite(ref: U32) -> String:
  _potion_sprite_from_defs(config(), ref)

def _potion_sprite_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _potion_sprite_from_list(potions, ref)

def _potion_sprite_from_list(potions: List(PotionDef), ref: U32) -> String:
  match potions:
    case []:
      ""
    case potion_def{name, sprite, heal}<>rest:
      match ref:
        case 0:
          sprite
        case _:
          _potion_sprite_from_list(rest, ref - 1)

def _tile_name(tile: Tile) -> String:
  match tile:
    case none{}:
      Content.card_empty()
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
      Content.stat_hp() ++ " " ++ U32.show(hp)
    case sword{ref, dmg}:
      Content.stat_dmg() ++ " " ++ U32.show(dmg)
    case potion{ref, heal}:
      Content.stat_heal() ++ " " ++ U32.show(heal)
    case gold{amount}:
      Content.stat_gold() ++ " " ++ U32.show(amount)

def _card_name(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      _monster_name(ref)
    case sword_card{ref}:
      _sword_name(ref)
    case potion_card{ref}:
      _potion_name(ref)
    case hero_card{}:
      _hero_name()

def _card_sprite(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      _monster_sprite(ref)
    case sword_card{ref}:
      _sword_sprite(ref)
    case potion_card{ref}:
      _potion_sprite(ref)
    case hero_card{}:
      _hero_sprite()

def _card_stat(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      _tile_badge(monster{ref, _monster_hp_value(ref)})
    case sword_card{ref}:
      _tile_badge(sword{ref, _sword_damage_value(ref)})
    case potion_card{ref}:
      _tile_badge(potion{ref, _potion_heal_value(ref)})
    case hero_card{}:
      ""

def _monster_hp_value(ref: U32) -> U32:
  _monster_hp_from_defs(config(), ref)

def _monster_hp_from_defs(config_value: Config, ref: U32) -> U32:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_hp_from_list(monsters, ref)

def _monster_hp_from_list(monsters: List(MonsterDef), ref: U32) -> U32:
  match monsters:
    case []:
      1
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      match ref:
        case 0:
          _first_hp(hp_levels)
        case _:
          _monster_hp_from_list(rest, ref - 1)

def _first_hp(hp_levels: List(U32)) -> U32:
  match hp_levels:
    case []:
      1
    case hp<>rest:
      hp

def _last_hp(hp_levels: List(U32), last: U32) -> U32:
  match hp_levels:
    case []:
      last
    case hp<>rest:
      _last_hp(rest, hp)

def _monster_hp_range(ref: U32) -> String:
  _monster_hp_range_from_defs(config(), ref)

def _monster_hp_range_from_defs(config_value: Config, ref: U32) -> String:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_hp_range_from_list(monsters, ref)

def _monster_hp_range_from_list(monsters: List(MonsterDef), ref: U32) -> String:
  match monsters:
    case []:
      "1 - 1"
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      match ref:
        case 0:
          U32.show(_first_hp(hp_levels)) ++ " - " ++ U32.show(_last_hp(hp_levels, 1))
        case _:
          _monster_hp_range_from_list(rest, ref - 1)

def _card_stat_range(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      Content.stat_hp() ++ ": " ++ _monster_hp_range(ref)
    case sword_card{ref}:
      Content.stat_dmg() ++ ": " ++ U32.show(_sword_damage_value(ref))
    case potion_card{ref}:
      Content.stat_heal() ++ ": " ++ U32.show(_potion_heal_value(ref))
    case hero_card{}:
      ""

def _sword_damage_value(ref: U32) -> U32:
  _sword_damage_from_defs(config(), ref)

def _sword_damage_from_defs(config_value: Config, ref: U32) -> U32:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _sword_damage_from_list(swords, ref)

def _sword_damage_from_list(swords: List(SwordDef), ref: U32) -> U32:
  match swords:
    case []:
      1
    case sword_def{name, sprite, dmg}<>rest:
      match ref:
        case 0:
          dmg
        case _:
          _sword_damage_from_list(rest, ref - 1)

def _potion_heal_value(ref: U32) -> U32:
  _potion_heal_from_defs(config(), ref)

def _potion_heal_from_defs(config_value: Config, ref: U32) -> U32:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _potion_heal_from_list(potions, ref)

def _potion_heal_from_list(potions: List(PotionDef), ref: U32) -> U32:
  match potions:
    case []:
      1
    case potion_def{name, sprite, heal}<>rest:
      match ref:
        case 0:
          heal
        case _:
          _potion_heal_from_list(rest, ref - 1)
