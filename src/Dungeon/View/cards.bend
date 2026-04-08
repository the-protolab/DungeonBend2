import /HTML/
import /U32/ as U32
import /Dungeon/Weapon as Weapon
import /Dungeon/Tile as Tile
import /Dungeon/HpFx as HpFx
import /Dungeon/DmgFx as DmgFx
import /Dungeon/DungeonEvent as DungeonEvent
import /Midum/Card/ as Card
import /Dungeon/View/assets_and_labels/_hero_name as _hero_name
import /Dungeon/View/assets_and_labels/_hero_sprite as _hero_sprite
import /Dungeon/View/assets_and_labels/_tile_name as _tile_name
import /Dungeon/View/assets_and_labels/_tile_sprite as _tile_sprite
import /Dungeon/View/assets_and_labels/_tile_badge as _tile_badge

def _hero_card_values(hero_hp: U32, hero_max_hp: U32, weapon_value: Weapon, hp_fx: HpFx, dmg_fx: DmgFx) -> HTML(DungeonEvent):
  Card.neutral(
    DungeonEvent,
    <div class={_hero_card_class(dmg_fx)} data-dmg={_hero_damage_attr(weapon_value)}>
      <div class={_hero_hp_badge_class(hp_fx)}>{text{"HP " ++ U32.show(hero_hp) ++ "/" ++ U32.show(hero_max_hp)}}</div>
      <div class="card__art-wrap">
        <img class="card__art" src={_hero_sprite()} alt={_hero_name()} />
      </div>
    </div>,
    [padding_none{}]
  )

def _hero_card_class(dmg_fx: DmgFx) -> String:
  match dmg_fx:
    case dmg_fx_up_a{}:
      "card card--hero card--hero-dmg-up-a"
    case dmg_fx_up_b{}:
      "card card--hero card--hero-dmg-up-b"
    case dmg_fx_down_a{}:
      "card card--hero card--hero-dmg-down-a"
    case dmg_fx_down_b{}:
      "card card--hero card--hero-dmg-down-b"
    case _:
      "card card--hero"

def _hero_hp_badge_class(hp_fx: HpFx) -> String:
  match hp_fx:
    case hp_fx_heal_a{}:
      "card__badge card__badge--hp card__badge--hp-heal-a"
    case hp_fx_heal_b{}:
      "card__badge card__badge--hp card__badge--hp-heal-b"
    case hp_fx_hurt_a{}:
      "card__badge card__badge--hp card__badge--hp-hurt-a"
    case hp_fx_hurt_b{}:
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
      Card.neutral(
        DungeonEvent,
        <div class="card card--empty">
          <div class="card__empty">{text{"Empty"}}</div>
        </div>,
        [padding_none{}]
      )
    case monster{ref, hp}:
      _standard_tile_card(monster{ref, hp}, "card card--tile card--monster")
    case sword{ref, dmg}:
      _standard_tile_card(sword{ref, dmg}, "card card--tile card--sword")
    case potion{ref, heal}:
      _standard_tile_card(potion{ref, heal}, "card card--tile card--potion")
    case gold{amount}:
      _standard_tile_card(gold{amount}, "card card--tile card--gold")

def _standard_card_shell(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  Card.neutral(DungeonEvent, body, [padding_none{}])

def _tile_card_body(tile: Tile, class_name: String) -> HTML(DungeonEvent):
  <div class={class_name}>
    {_tile_badge_node(tile)}
    <div class="card__art-wrap">
      <img class="card__art" src={_tile_sprite(tile)} alt={_tile_name(tile)} />
    </div>
  </div>

def _standard_tile_card(tile: Tile, class_name: String) -> HTML(DungeonEvent):
  _standard_card_shell(_tile_card_body(tile, class_name))

def _tile_badge_node(tile: Tile) -> HTML(DungeonEvent):
  <div class="card__badge card__badge--value">{text{_tile_badge(tile)}}</div>
