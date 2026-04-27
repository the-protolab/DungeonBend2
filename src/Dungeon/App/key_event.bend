import /Dungeon/DungeonEvent as DungeonEvent

def key_event(key: U32) -> DungeonEvent:
  match key:
    case 27:
      pause_dungeon{}
    case 37:
      move{left{}}
    case 63234:
      move{left{}}
    case 65:
      move{left{}}
    case 97:
      move{left{}}
    case 38:
      move{up{}}
    case 63232:
      move{up{}}
    case 87:
      move{up{}}
    case 119:
      move{up{}}
    case 39:
      move{right{}}
    case 63235:
      move{right{}}
    case 68:
      move{right{}}
    case 100:
      move{right{}}
    case 40:
      move{down{}}
    case 63233:
      move{down{}}
    case 83:
      move{down{}}
    case 115:
      move{down{}}
    case 32:
      ignore{}
    case 82:
      ignore{}
    case _:
      ignore{}
