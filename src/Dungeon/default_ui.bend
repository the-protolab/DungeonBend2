import /Dungeon/UiState as UiState
import /Dungeon/HpFx as HpFx
import /Dungeon/DmgFx as DmgFx
import /Dungeon/Impact as Impact
import /Dungeon/DamageOverlay as DamageOverlay

def default_ui() -> UiState:
  ui_state{hp_fx_none{}, dmg_fx_none{}, no_impact{}, no_damage_overlay{}}
