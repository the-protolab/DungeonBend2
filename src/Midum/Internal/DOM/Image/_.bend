# Internal DOM image renderer for Midum.

import /HTML/
import /String/is_empty as string_is_empty
import Nat/show as show_nat

def css_nat(value: Nat) -> String:
  show_nat(value)

def size_style(size: Midum/Image/Size) -> String:
  match size:
    case auto{}:
      "auto"
    case px{value}:
      css_nat(value) ++ "px"

def fit_class(fit: Midum/Image/Fit) -> String:
  match fit:
    case contain{}:
      "bc-image-fit-contain"
    case cover{}:
      "bc-image-fit-cover"
    case stretch{}:
      "bc-image-fit-stretch"

def sampling_class(sampling: Midum/Image/Sampling) -> String:
  match sampling:
    case smooth{}:
      "bc-image-sampling-smooth"
    case pixelated{}:
      "bc-image-sampling-pixelated"

def image_class(fit: Midum/Image/Fit, sampling: Midum/Image/Sampling) -> String:
  "bc-image " ++ fit_class(fit) ++ " " ++ sampling_class(sampling)

def empty_class(fit: Midum/Image/Fit, sampling: Midum/Image/Sampling) -> String:
  image_class(fit, sampling) ++ " bc-image--empty"

def render(Event: Type, src: String, alt: String, cfg: Midum/Image/Config) -> HTML(Event):
  match cfg:
    case image{width, height, fit, sampling}:
      match string_is_empty(src):
        case true{}:
          <div
            class={empty_class(fit, sampling)}
            style:width={size_style(width)}
            style:height={size_style(height)}
          ></div>
        case false{}:
          <img
            class={image_class(fit, sampling)}
            src={src}
            alt={alt}
            style:width={size_style(width)}
            style:height={size_style(height)}
          />
