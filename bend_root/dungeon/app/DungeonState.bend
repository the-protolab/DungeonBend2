import /dungeon/logic/Meta
import /dungeon/logic/Run

type DungeonState {
  hub{meta: Meta, next_seed: U32}
  run_screen{meta: Meta, run: Run, next_seed: U32, hp_fx: U32, dmg_fx: U32}
  game_over{meta: Meta, run: Run, next_seed: U32, hp_fx: U32, dmg_fx: U32}
}
