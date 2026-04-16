import /Editor/EditorData as EditorData
import /Editor/HeroRow as HeroRow
import /Editor/HeroUpgradeRow as HeroUpgradeRow
import /Editor/MonsterRow as MonsterRow
import /Editor/WeaponRow as WeaponRow
import /Editor/PotionRow as PotionRow
import /Editor/DeckRow as DeckRow
import /Editor/PackRow as PackRow
import /Editor/PoolRow as PoolRow
import /Editor/RulesRow as RulesRow
import /Editor/PresentationRow as PresentationRow

def generated_editor_data() -> EditorData:
  editor_data{
    [
      hero_row{1, "adventurer", "Adventurer", "assets/player-boy.png", 11, 0, 1},
      hero_row{1, "gato_de_botas", "Gato de Botas", "assets/player-gato-de-botas.png", 9, 45, 0}
    ],
    [
      hero_upgrade_row{1, "adventurer", 1, 20, 14},
      hero_upgrade_row{1, "adventurer", 2, 35, 17},
      hero_upgrade_row{1, "adventurer", 3, 55, 20},
      hero_upgrade_row{1, "adventurer", 4, 80, 24},
      hero_upgrade_row{1, "gato_de_botas", 1, 18, 12},
      hero_upgrade_row{1, "gato_de_botas", 2, 30, 15},
      hero_upgrade_row{1, "gato_de_botas", 3, 48, 18},
      hero_upgrade_row{1, "gato_de_botas", 4, 72, 22}
    ],
    [
      monster_row{1, "rat", "Rat", "assets/enemy-rat.png", 3, [
      3,
      5,
      7,
      9,
      11
    ]},
      monster_row{1, "spider", "Spider", "assets/enemy-spider.png", 4, [
      5,
      7,
      9,
      11,
      13
    ]},
      monster_row{1, "venom_spider", "Venom Spider", "assets/enemy-spider2.png", 5, [
      7,
      9,
      11,
      13,
      15
    ]},
      monster_row{1, "orc", "Orc", "assets/enemy-orc.png", 6, [
      9,
      11,
      14,
      17,
      20
    ]}
    ],
    [
      weapon_row{1, "sword_1", "Sword", "assets/item-sword.png", 5},
      weapon_row{1, "sword_2", "Sword", "assets/item-sword.png", 7},
      weapon_row{1, "sword_3", "Sword", "assets/item-sword.png", 9}
    ],
    [
      potion_row{1, "potion_1", "Potion", "assets/item-potion.png", 4}
    ],
    [
      deck_row{1, "rat", 4},
      deck_row{1, "spider", 3},
      deck_row{1, "venom_spider", 3},
      deck_row{1, "orc", 3},
      deck_row{1, "sword_1", 1},
      deck_row{1, "sword_2", 1},
      deck_row{1, "sword_3", 1},
      deck_row{1, "potion_1", 3},
      deck_row{1, "hero", 1}
    ],
    [
      pack_row{1, "starter_booster", "Starter Booster", 80, 3, 0}
    ],
    [
      pool_row{1, "starter_booster", "rat", 1},
      pool_row{1, "starter_booster", "spider", 1},
      pool_row{1, "starter_booster", "venom_spider", 1},
      pool_row{1, "starter_booster", "orc", 1},
      pool_row{1, "starter_booster", "sword_1", 1},
      pool_row{1, "starter_booster", "sword_2", 1},
      pool_row{1, "starter_booster", "sword_3", 1},
      pool_row{1, "starter_booster", "potion_1", 1}
    ],
    rules_row{1, 0, "adventurer", 1, 1, 1, 6, 1},
    [
      presentation_row{1, "adventurer", "center", "Ultimate", "assets/item-sword.png", "Refills the dungeon with new cards while keeping the hero in place."},
      presentation_row{1, "gato_de_botas", "center", "Ultimate", "assets/item-sword.png", "Refills the dungeon with new cards while keeping the hero in place."}
    ]
  }
