# Public image animation data.

type Animation {
  animation{
    frames: List(String),
    fps: Nat,
    playback: Midum/Image/Playback,
  }
}
