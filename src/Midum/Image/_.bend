# Public image API for Midum.
#
# Images stay renderer-neutral. The current renderer lives under
# /Midum/Internal/DOM/.

import /HTML/
import /List/length
import /Midum/Internal/DOM/Image/render as dom_render
import Nat/add as nat_add
import Nat/compare as compare_nat
import Nat/div as div_nat
import Nat/max as max_nat
import Nat/mod as mod_nat
import Nat/mul as mul_nat
import Nat/pred as pred_nat

def with_width(cfg: Midum/Image/Config, next_width: Midum/Image/Size) -> Midum/Image/Config:
  match cfg:
    case image{width, height, fit, sampling}:
      image{width: next_width, height, fit, sampling}

def with_height(cfg: Midum/Image/Config, next_height: Midum/Image/Size) -> Midum/Image/Config:
  match cfg:
    case image{width, height, fit, sampling}:
      image{width, height: next_height, fit, sampling}

def with_fit(cfg: Midum/Image/Config, next_fit: Midum/Image/Fit) -> Midum/Image/Config:
  match cfg:
    case image{width, height, fit, sampling}:
      image{width, height, fit: next_fit, sampling}

def with_sampling(cfg: Midum/Image/Config, next_sampling: Midum/Image/Sampling) -> Midum/Image/Config:
  match cfg:
    case image{width, height, fit, sampling}:
      image{width, height, fit, sampling: next_sampling}

def apply_override(cfg: Midum/Image/Config, override: Midum/Image/Override) -> Midum/Image/Config:
  match override:
    case width_px{value}:
      with_width(cfg, px{value})
    case height_px{value}:
      with_height(cfg, px{value})
    case fit_contain{}:
      with_fit(cfg, contain{})
    case fit_cover{}:
      with_fit(cfg, cover{})
    case fit_stretch{}:
      with_fit(cfg, stretch{})
    case sampling_smooth{}:
      with_sampling(cfg, smooth{})
    case sampling_pixelated{}:
      with_sampling(cfg, pixelated{})

def apply_overrides(cfg: Midum/Image/Config, overrides: List(Midum/Image/Override)) -> Midum/Image/Config:
  match overrides:
    case []:
      cfg
    case override<>rest:
      apply_overrides(apply_override(cfg, override), rest)

def config(overrides: List(Midum/Image/Override)) -> Midum/Image/Config:
  apply_overrides(image{width: auto{}, height: auto{}, fit: contain{}, sampling: smooth{}}, overrides)

def nth_or_empty(xs: List(String), idx: Nat) -> String:
  match xs idx:
    case [] 0n:
      ""
    case head<>tail 0n:
      head
    case [] 1n+rest:
      ""
    case _<>tail 1n+rest:
      nth_or_empty(tail, rest)

def frame_count(animation: Midum/Image/Animation) -> Nat:
  match animation:
    case animation{frames, fps, playback}:
      List/length(String, frames)

def frame_ms(animation: Midum/Image/Animation) -> Nat:
  match animation:
    case animation{frames, fps, playback}:
      match fps:
        case 0n:
          0n
        case 1n+rest:
          max_nat(1n, div_nat(1000n, 1n + rest))

def clamp_to_last_with_order(idx: Nat, last: Nat, order: Ord) -> Nat:
  match order:
    case lt{}:
      idx
    case eq{}:
      idx
    case gt{}:
      last

def clamp_to_last(idx: Nat, last: Nat) -> Nat:
  clamp_to_last_with_order(idx, last, compare_nat(idx, last))

def current_frame_index(count: Nat, ms: Nat, playback: Midum/Image/Playback, state: Midum/Image/State) -> Nat:
  match count ms playback state:
    case 0n ms playback state{elapsed_ms, finished}:
      0n
    case count 0n playback state{elapsed_ms, finished}:
      0n
    case count ms loop{} state{elapsed_ms, finished}:
      mod_nat(div_nat(elapsed_ms, ms), count)
    case count ms once_hold_last{} state{elapsed_ms, finished}:
      clamp_to_last(div_nat(elapsed_ms, ms), pred_nat(count))

def current_src(animation: Midum/Image/Animation, state: Midum/Image/State) -> String:
  match animation:
    case animation{frames, fps, playback}:
      count = List/length(String, frames)
      ms = frame_ms(animation)
      nth_or_empty(frames, current_frame_index(count, ms, playback, state))

def reset_state() -> Midum/Image/State:
  state{elapsed_ms: 0n, finished: false{}}

def step_empty_or_frozen(elapsed_ms: Nat, finished: Bool) -> Midum/Image/Step:
  step{state: state{elapsed_ms, finished}, cycled: false{}, finished_now: false{}}

def step_loop_with_order(cycle_ms: Nat, next_elapsed: Nat, order: Ord) -> Midum/Image/Step:
  match order:
    case lt{}:
      step{state: state{elapsed_ms: next_elapsed, finished: false{}}, cycled: false{}, finished_now: false{}}
    case eq{}:
      step{state: state{elapsed_ms: 0n, finished: false{}}, cycled: true{}, finished_now: false{}}
    case gt{}:
      step{state: state{elapsed_ms: mod_nat(next_elapsed, cycle_ms), finished: false{}}, cycled: true{}, finished_now: false{}}

def step_loop(count: Nat, ms: Nat, delta_ms: Nat, elapsed_ms: Nat) -> Midum/Image/Step:
  cycle_ms = mul_nat(count, ms)
  next_elapsed = nat_add(elapsed_ms, delta_ms)
  step_loop_with_order(cycle_ms, next_elapsed, compare_nat(next_elapsed, cycle_ms))

def step_once_with_order(total_ms: Nat, next_elapsed: Nat, order: Ord) -> Midum/Image/Step:
  match order:
    case lt{}:
      step{state: state{elapsed_ms: next_elapsed, finished: false{}}, cycled: false{}, finished_now: false{}}
    case eq{}:
      step{state: state{elapsed_ms: total_ms, finished: true{}}, cycled: true{}, finished_now: true{}}
    case gt{}:
      step{state: state{elapsed_ms: total_ms, finished: true{}}, cycled: true{}, finished_now: true{}}

def step_once(count: Nat, ms: Nat, delta_ms: Nat, elapsed_ms: Nat, finished: Bool) -> Midum/Image/Step:
  match finished:
    case true{}:
      step{state: state{elapsed_ms, finished: true{}}, cycled: false{}, finished_now: false{}}
    case false{}:
      total_ms = mul_nat(count, ms)
      next_elapsed = nat_add(elapsed_ms, delta_ms)
      step_once_with_order(total_ms, next_elapsed, compare_nat(next_elapsed, total_ms))

def step_checked(count: Nat, ms: Nat, playback: Midum/Image/Playback, delta_ms: Nat, state: Midum/Image/State) -> Midum/Image/Step:
  match count ms playback state:
    case 0n ms playback state{elapsed_ms, finished}:
      step_empty_or_frozen(elapsed_ms, finished)
    case count 0n playback state{elapsed_ms, finished}:
      step_empty_or_frozen(elapsed_ms, finished)
    case count ms loop{} state{elapsed_ms, finished}:
      step_loop(count, ms, delta_ms, elapsed_ms)
    case count ms once_hold_last{} state{elapsed_ms, finished}:
      step_once(count, ms, delta_ms, elapsed_ms, finished)

def step(animation: Midum/Image/Animation, delta_ms: Nat, state: Midum/Image/State) -> Midum/Image/Step:
  match animation:
    case animation{frames, fps, playback}:
      count = List/length(String, frames)
      ms = frame_ms(animation)
      step_checked(count, ms, playback, delta_ms, state)

def view(Event: Type, src: String, alt: String, overrides: List(Midum/Image/Override)) -> HTML(Event):
  dom_render(Event, src, alt, config(overrides))

def animated(Event: Type, state: Midum/Image/State, animation: Midum/Image/Animation, alt: String, overrides: List(Midum/Image/Override)) -> HTML(Event):
  dom_render(Event, current_src(animation, state), alt, config(overrides))
