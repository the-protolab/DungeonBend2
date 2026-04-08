type Upgrade {
  upgrade{cost: U32, max_hp: U32}
}

type MonsterDef {
  monster_def{gold_drop: U32, hp_levels: List(U32)}
}

type SwordDef {
  sword_def{dmg: U32}
}

type PotionDef {
  potion_def{heal: U32}
}

type DeckEntry {
  monster_entry{ref: U32, count: U32}
  sword_entry{ref: U32, count: U32}
  potion_entry{ref: U32, count: U32}
  hero_entry{count: U32}
}

type Direction {
  up{}
  down{}
  left{}
  right{}
}

type Weapon {
  no_weapon{}
  weapon{ref: U32, dmg: U32}
}

type Tile {
  none{}
  monster{ref: U32, hp: U32}
  sword{ref: U32, dmg: U32}
  potion{ref: U32, heal: U32}
  gold{amount: U32}
}

type Board {
  board{cells: Nat/V2/Map(Tile)}
}

type BoardDraw {
  board_draw{
    board: Board,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type DrawResult {
  draw_result{
    tile: Tile,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type CombatOutcome {
  combat_continue{}
  combat_game_over{}
}

type CombatResult {
  combat_result{
    hero_hp: U32,
    weapon: Weapon,
    board: Board,
    outcome: CombatOutcome
  }
}

type Meta {
  meta{hero_level: U32, gold: U32}
}

type Config {
  config{
    hero_base_max_hp: U32,
    upgrades: List(Upgrade),
    monsters: List(MonsterDef),
    swords: List(SwordDef),
    potions: List(PotionDef),
    deck: List(DeckEntry),
    base_deck_size: U32,
    starting_dungeon_level: U32
  }
}

type Run {
  run{
    dungeon_level: U32,
    hero_hp: U32,
    hero_max_hp: U32,
    hero_index: U32,
    weapon: Weapon,
    board: Board,
    deck_blueprint: List(DeckEntry),
    draw_counts: List(DeckEntry),
    remaining: U32,
    capacity: U32,
    seed: U32,
    ult_charge: U32
  }
}

type RunAdvance {
  keep_running{run: Run}
  end_run{run: Run}
}

type SwipeResult {
  swipe_result{meta: Meta, next: RunAdvance}
}

type Scene {
  setup{}
  running{run: Run}
  game_over{run: Run}
}

type GameState {
  game_state{meta: Meta, scene: Scene, next_seed: U32}
}

type HpFx {
  hp_fx_none{}
  hp_fx_heal_a{}
  hp_fx_heal_b{}
  hp_fx_hurt_a{}
  hp_fx_hurt_b{}
}

type DmgFx {
  dmg_fx_none{}
  dmg_fx_up_a{}
  dmg_fx_up_b{}
  dmg_fx_down_a{}
  dmg_fx_down_b{}
}

type ImpactFx {
  impact_hit_a{}
  impact_hit_b{}
  impact_kill_a{}
  impact_kill_b{}
}

type Impact {
  no_impact{}
  impact{pos: Nat/V2, fx: ImpactFx}
}

type UiState {
  ui_state{hp_fx: HpFx, dmg_fx: DmgFx, impact: Impact}
}

type DungeonState {
  dungeon{game: GameState, ui: UiState}
}

type DungeonEvent {
  start{}
  upgrade{}
  ultimate{}
  move{dir: Direction}
  ok{}
  ignore{}
  loaded{hero_level: U32, gold: U32}
  no_save{}
}

type _PickResult {
  no_pick{counts: List(DeckEntry)}
  picked_entry{entry: DeckEntry, counts: List(DeckEntry)}
}
