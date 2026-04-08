import /Dungeon/Meta as Meta

def meta_to_string(m: Meta) -> String:
  match m:
    case meta{hero_level, gold}:
      String/join([U32/show(hero_level), U32/show(gold)], ",")
