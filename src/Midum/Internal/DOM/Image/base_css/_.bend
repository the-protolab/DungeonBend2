def base_css() -> String:
  "
  .bc-image {
    display: block;
    max-width: 100%;
    object-position: center;
    background: transparent;
  }

  .bc-image--empty {
    visibility: hidden;
    pointer-events: none;
  }

  .bc-image-fit-contain {
    object-fit: contain;
  }

  .bc-image-fit-cover {
    object-fit: cover;
  }

  .bc-image-fit-stretch {
    object-fit: fill;
  }

  .bc-image-sampling-smooth {
    image-rendering: auto;
  }

  .bc-image-sampling-pixelated {
    image-rendering: crisp-edges;
    image-rendering: pixelated;
  }
  "
