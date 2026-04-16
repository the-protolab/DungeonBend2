import /Dungeon/Config as Config
import /Dungeon/HeroDef as HeroDef
import /Dungeon/Upgrade as Upgrade
import /Dungeon/MonsterDef as MonsterDef
import /Dungeon/SwordDef as SwordDef
import /Dungeon/PotionDef as PotionDef
import /Dungeon/DeckEntry as DeckEntry
import /Dungeon/CardRef as CardRef
import /Dungeon/PackPoolEntry as PackPoolEntry
import /Dungeon/PackDef as PackDef

def generated_config() -> Config:
  config{
    [
      hero_def{"adventurer", "Adventurer", "assets/player-boy.png", 11, 0, 1, [
        upgrade{20, 14},
        upgrade{35, 17},
        upgrade{55, 20},
        upgrade{80, 24}
      ]},
      hero_def{"gato_de_botas", "Gato de Botas", "assets/player-gato-de-botas.png", 9, 45, 0, [
        upgrade{18, 12},
        upgrade{30, 15},
        upgrade{48, 18},
        upgrade{72, 22}
      ]}
    ],
    [
      monster_def{"Rat", "assets/enemy-rat.png", 3, [
        3,
        5,
        7,
        9,
        11
      ]},
      monster_def{"Spider", "assets/enemy-spider.png", 4, [
        5,
        7,
        9,
        11,
        13
      ]},
      monster_def{"Venom Spider", "assets/enemy-spider2.png", 5, [
        7,
        9,
        11,
        13,
        15
      ]},
      monster_def{"Orc", "assets/enemy-orc.png", 6, [
        9,
        11,
        14,
        17,
        20
      ]}
    ],
    [
      sword_def{"Sword", "assets/item-sword.png", 5},
      sword_def{"Sword", "assets/item-sword.png", 7},
      sword_def{"Sword", "assets/item-sword.png", 9}
    ],
    [
      potion_def{"Potion", "assets/item-potion.png", 4}
    ],
    [
      monster_entry{0, 4},
      monster_entry{1, 3},
      monster_entry{2, 3},
      monster_entry{3, 3},
      sword_entry{0, 1},
      sword_entry{1, 1},
      sword_entry{2, 1},
      potion_entry{0, 3},
      hero_entry{1}
    ],
    [
      pack_def{"Starter Booster", 1, 3, 0, [
        pack_pool_entry{monster_card{2}, 1},
        pack_pool_entry{monster_card{3}, 1},
        pack_pool_entry{sword_card{0}, 1},
        pack_pool_entry{sword_card{1}, 1},
        pack_pool_entry{potion_card{0}, 1}
      ]}
    ],
    1
  }
