import /Dungeon/Config as Config
import /Dungeon/Upgrade as Upgrade
import /Dungeon/MonsterDef as MonsterDef
import /Dungeon/SwordDef as SwordDef
import /Dungeon/PotionDef as PotionDef
import /Dungeon/DeckEntry as DeckEntry

def config() -> Config:
  config{
    11,
    [
      upgrade{20, 14},
      upgrade{35, 17},
      upgrade{55, 20},
      upgrade{80, 24}
    ],
    [
      monster_def{3, [3, 5, 7, 9, 11]},
      monster_def{4, [5, 7, 9, 11, 13]},
      monster_def{5, [7, 9, 11, 13, 15]},
      monster_def{6, [9, 11, 14, 17, 20]}
    ],
    [
      sword_def{5},
      sword_def{7},
      sword_def{9}
    ],
    [
      potion_def{4}
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
    20,
    1
  }
