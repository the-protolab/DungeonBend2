import /Dungeon/deck_counter_frames/frames as deck_counter_frames

def clip() -> Midum/Image/Animation:
  animation{
    frames: deck_counter_frames(),
    fps: 8n,
    playback: once_hold_last{},
  }
