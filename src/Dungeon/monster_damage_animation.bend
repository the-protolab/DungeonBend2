import /Dungeon/monster_damage_frames/frames as damage_frames

def clip() -> Midum/Image/Animation:
  animation{
    frames: damage_frames(),
    fps: 8n,
    playback: once_hold_last{},
  }
