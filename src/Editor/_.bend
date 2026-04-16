type EditorTab {
  overview_tab{}
  rules_tab{}
  heroes_tab{}
  upgrades_tab{}
  monsters_tab{}
  weapons_tab{}
  potions_tab{}
  deck_tab{}
  packs_tab{}
  pool_tab{}
  presentation_tab{}
}

type HeroRow {
  hero_row{
    locked: U32,
    id: String,
    name: String,
    sprite: String,
    base_max_hp: U32,
    unlock_cost: U32,
    starts_unlocked: U32
  }
}

type HeroUpgradeRow {
  hero_upgrade_row{
    locked: U32,
    hero_id: String,
    level: U32,
    cost: U32,
    max_hp: U32
  }
}

type MonsterRow {
  monster_row{
    locked: U32,
    id: String,
    name: String,
    sprite: String,
    gold_drop: U32,
    hp_by_level: List(U32)
  }
}

type WeaponRow {
  weapon_row{
    locked: U32,
    id: String,
    name: String,
    sprite: String,
    dmg: U32
  }
}

type PotionRow {
  potion_row{
    locked: U32,
    id: String,
    name: String,
    sprite: String,
    heal: U32
  }
}

type DeckRow {
  deck_row{locked: U32, card_id: String, count: U32}
}

type PackRow {
  pack_row{
    locked: U32,
    id: String,
    name: String,
    price: U32,
    reveal_count: U32,
    allow_duplicates: U32
  }
}

type PoolRow {
  pool_row{locked: U32, pack_id: String, card_id: String, weight: U32}
}

type RulesRow {
  rules_row{
    initial_seed: U32,
    starting_gold: U32,
    starting_selected_hero_id: String,
    starting_selection_confirmed: U32,
    starting_dungeon_level: U32,
    dungeon_level_increment_per_refill: U32,
    ultimate_charge_required: U32,
    ultimate_charge_per_move: U32
  }
}

type PresentationRow {
  presentation_row{
    locked: U32,
    hero_id: String,
    name_align: String,
    ultimate_title: String,
    ultimate_icon: String,
    ultimate_description: String
  }
}

type EditorData {
  editor_data{
    heroes: List(HeroRow),
    hero_upgrades: List(HeroUpgradeRow),
    monsters: List(MonsterRow),
    weapons: List(WeaponRow),
    potions: List(PotionRow),
    deck: List(DeckRow),
    packs: List(PackRow),
    pool: List(PoolRow),
    rules: RulesRow,
    presentation: List(PresentationRow)
  }
}

type EditorState {
  editor_state{
    data: EditorData,
    tab: EditorTab,
    status: String,
    saving: U32,
    building: U32
  }
}

type EditorEvent {
  select_tab{tab: EditorTab}
  reset_data{}
  save{}
  save_ok{body: String}
  save_err{body: String}
  build_docs{}
  build_ok{body: String}
  build_err{body: String}
  update_rule{field: U32, value: String}
  update_hero{row: U32, field: U32, value: String}
  add_hero{}
  update_upgrade{row: U32, field: U32, value: String}
  add_upgrade{}
  update_monster{row: U32, field: U32, value: String}
  update_monster_hp{row: U32, level: U32, value: String}
  add_monster{}
  add_hp_level{}
  update_weapon{row: U32, field: U32, value: String}
  add_weapon{}
  update_potion{row: U32, field: U32, value: String}
  add_potion{}
  update_deck{row: U32, field: U32, value: String}
  add_deck{}
  update_pack{row: U32, field: U32, value: String}
  add_pack{}
  update_pool{row: U32, field: U32, value: String}
  add_pool{}
  update_presentation{row: U32, field: U32, value: String}
  add_presentation{}
  ignore{}
}
