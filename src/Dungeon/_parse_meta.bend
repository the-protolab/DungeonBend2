import /Dungeon/DungeonEvent as DungeonEvent

def _parse_meta(s: String) -> DungeonEvent:
  _parse_meta_parts(String/split(s, ','))

def _parse_meta_parts(parts: List(String)) -> DungeonEvent:
  match parts:
    case [hl_str, gold_str]:
      _parse_meta_values(String/to_u32(hl_str), String/to_u32(gold_str))
    case _:
      no_save{}

def _parse_meta_values(hl: Maybe(U32), g: Maybe(U32)) -> DungeonEvent:
  match hl g:
    case some{hl_val} some{g_val}:
      loaded{hl_val, g_val}
    case _ _:
      no_save{}
