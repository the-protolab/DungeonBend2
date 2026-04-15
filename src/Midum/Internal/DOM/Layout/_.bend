# Internal DOM layout renderer for Midum.
#
# Layout owns placement and simple grouping. The public API remains one
# primitive, while the DOM renderer maps each closed choice to a CSS class.

import /HTML/
import /Midum/Internal/DOM/Layout/Arrangement
import Nat/show as show_nat

def position_class(position: Midum/Layout/Position) -> String:
  match position:
    case top_left{}:
      "bc-layout-pos-top-left"
    case top{}:
      "bc-layout-pos-top"
    case top_right{}:
      "bc-layout-pos-top-right"
    case left{}:
      "bc-layout-pos-left"
    case center{}:
      "bc-layout-pos-center"
    case right{}:
      "bc-layout-pos-right"
    case bottom_left{}:
      "bc-layout-pos-bottom-left"
    case bottom{}:
      "bc-layout-pos-bottom"
    case bottom_right{}:
      "bc-layout-pos-bottom-right"

def flow_class(flow: Midum/Layout/Flow) -> String:
  match flow:
    case row{}:
      "bc-layout-flow-row"
    case column{}:
      "bc-layout-flow-column"

def gap_class(gap: Midum/Layout/Gap) -> String:
  match gap:
    case none{}:
      "bc-layout-gap-none"
    case sm{}:
      "bc-layout-gap-sm"
    case md{}:
      "bc-layout-gap-md"
    case lg{}:
      "bc-layout-gap-lg"

def align_class(align: Midum/Layout/Align) -> String:
  match align:
    case align_start_value{}:
      "bc-layout-align-start"
    case align_center_value{}:
      "bc-layout-align-center"
    case align_end_value{}:
      "bc-layout-align-end"
    case align_stretch_value{}:
      "bc-layout-align-stretch"

def arrangement_class(Event: Type, arrangement: Midum/Internal/DOM/Layout/Arrangement, kids: List(HTML(Event))) -> String:
  match arrangement kids:
    case between{} []:
      "bc-layout-arrangement-packed"
    case between{} _<>[]:
      "bc-layout-arrangement-packed"
    case between{} _:
      "bc-layout-arrangement-between"
    case packed{} _:
      "bc-layout-arrangement-packed"

def box_class(position: Midum/Layout/Position) -> String:
  "bc-layout-box " ++ position_class(position)

def box_body_class(flow: Midum/Layout/Flow, gap: Midum/Layout/Gap) -> String:
  "bc-layout-box-body " ++ flow_class(flow) ++ " " ++ gap_class(gap)

def box(Event: Type, cfg: Midum/Layout/Config, body: HTML(Event)) -> HTML(Event):
  match cfg:
    case layout{position, flow, gap}:
      <div class={box_class(position)}>
        <div class={box_body_class(flow, gap)}>
          {body}
        </div>
      </div>

def css_nat(value: Nat) -> String:
  show_nat(value)

def frame_width_style(width: Midum/Layout/Width) -> String:
  match width:
    case fit{}:
      "fit-content"
    case full{}:
      "100%"
    case px{value}:
      css_nat(value) ++ "px"

def frame_height_style(height: Midum/Layout/Height) -> String:
  match height:
    case fit{}:
      "fit-content"
    case full{}:
      "100%"
    case px{value}:
      css_nat(value) ++ "px"

def frame_inset_style(inset: Midum/Layout/Inset) -> String:
  match inset:
    case none{}:
      "0px"
    case sm{}:
      "8px"
    case md{}:
      "16px"
    case lg{}:
      "24px"

def max_width_style(max_width: Midum/Layout/MaxWidth) -> String:
  match max_width:
    case max_width_none{}:
      "none"
    case max_width_px_value{value}:
      css_nat(value) ++ "px"

def edge_px(value: Nat) -> String:
  css_nat(value) ++ "px"

def edge_top_style(inset: Midum/Layout/EdgeInsets) -> String:
  match inset:
    case edge_insets{top, right, bottom, left}:
      edge_px(top)

def edge_right_style(inset: Midum/Layout/EdgeInsets) -> String:
  match inset:
    case edge_insets{top, right, bottom, left}:
      edge_px(right)

def edge_bottom_style(inset: Midum/Layout/EdgeInsets) -> String:
  match inset:
    case edge_insets{top, right, bottom, left}:
      edge_px(bottom)

def edge_left_style(inset: Midum/Layout/EdgeInsets) -> String:
  match inset:
    case edge_insets{top, right, bottom, left}:
      edge_px(left)

def compact_top_style(inset: Midum/Layout/EdgeInsets, compact_inset: Midum/Layout/ShellCompactInset) -> String:
  match compact_inset:
    case compact_inset_none{}:
      edge_top_style(inset)
    case compact_inset_value{inset: compact_value}:
      edge_top_style(compact_value)

def compact_right_style(inset: Midum/Layout/EdgeInsets, compact_inset: Midum/Layout/ShellCompactInset) -> String:
  match compact_inset:
    case compact_inset_none{}:
      edge_right_style(inset)
    case compact_inset_value{inset: compact_value}:
      edge_right_style(compact_value)

def compact_bottom_style(inset: Midum/Layout/EdgeInsets, compact_inset: Midum/Layout/ShellCompactInset) -> String:
  match compact_inset:
    case compact_inset_none{}:
      edge_bottom_style(inset)
    case compact_inset_value{inset: compact_value}:
      edge_bottom_style(compact_value)

def compact_left_style(inset: Midum/Layout/EdgeInsets, compact_inset: Midum/Layout/ShellCompactInset) -> String:
  match compact_inset:
    case compact_inset_none{}:
      edge_left_style(inset)
    case compact_inset_value{inset: compact_value}:
      edge_left_style(compact_value)

def shell_height_class(height: Midum/Layout/ShellHeight) -> String:
  match height:
    case shell_height_auto{}:
      "bc-layout-shell-height-auto"
    case shell_height_viewport{}:
      "bc-layout-shell-height-viewport"

def shell_overflow_class(overflow: Midum/Layout/ShellOverflow) -> String:
  match overflow:
    case shell_overflow_visible{}:
      "bc-layout-shell-overflow-visible"
    case shell_overflow_hidden{}:
      "bc-layout-shell-overflow-hidden"

def shell_safe_area_class(safe_area: Midum/Layout/ShellSafeArea) -> String:
  match safe_area:
    case shell_safe_area_off{}:
      "bc-layout-shell-safe-area-off"
    case shell_safe_area_on{}:
      "bc-layout-shell-safe-area"

def shell_class(height: Midum/Layout/ShellHeight, overflow: Midum/Layout/ShellOverflow, safe_area: Midum/Layout/ShellSafeArea) -> String:
  "bc-layout-shell " ++ shell_height_class(height) ++ " " ++ shell_overflow_class(overflow) ++ " " ++ shell_safe_area_class(safe_area)

def shell_attrs(Event: Type, cfg: Midum/Layout/ShellConfig) -> List(HTML/Attr(Event)):
  match cfg:
    case shell_layout{width, max_width, height, overflow, safe_area, inset, compact_inset}:
      [
        attr{"class", shell_class(height, overflow, safe_area)}
        style{"width", frame_width_style(width)}
        style{"max-width", max_width_style(max_width)}
        style{"--bc-layout-shell-inset-top", edge_top_style(inset)}
        style{"--bc-layout-shell-inset-right", edge_right_style(inset)}
        style{"--bc-layout-shell-inset-bottom", edge_bottom_style(inset)}
        style{"--bc-layout-shell-inset-left", edge_left_style(inset)}
        style{"--bc-layout-shell-compact-inset-top", compact_top_style(inset, compact_inset)}
        style{"--bc-layout-shell-compact-inset-right", compact_right_style(inset, compact_inset)}
        style{"--bc-layout-shell-compact-inset-bottom", compact_bottom_style(inset, compact_inset)}
        style{"--bc-layout-shell-compact-inset-left", compact_left_style(inset, compact_inset)}
      ]

def render_shell(Event: Type, cfg: Midum/Layout/ShellConfig, body: HTML(Event)) -> HTML(Event):
  node{"div", shell_attrs(Event, cfg), [body]}

def render_page(Event: Type, cfg: Midum/Layout/PageConfig, body: HTML(Event)) -> HTML(Event):
  match cfg:
    case page_layout{inset}:
      <div class="bc-layout-page" style:padding={frame_inset_style(inset)}>
        {body}
      </div>

def render_container(Event: Type, cfg: Midum/Layout/ContainerConfig, body: HTML(Event)) -> HTML(Event):
  match cfg:
    case container_layout{max_width}:
      <div class="bc-layout-container" style:max-width={max_width_style(max_width)}>
        {body}
      </div>

def frame(Event: Type, cfg: Midum/Layout/FrameConfig, body: HTML(Event)) -> HTML(Event):
  match cfg:
    case frame{width, height, inset}:
      <div
        class="bc-layout-frame"
        style:width={frame_width_style(width)}
        style:max-width="100%"
        style:height={frame_height_style(height)}
        style:padding={frame_inset_style(inset)}
      >
        {body}
      </div>

def overlay(Event: Type, layers: List(HTML(Event))) -> HTML(Event):
  <div class="bc-layout-overlay">
    {...layers}
  </div>

def group_stack_class(Event: Type, flow: Midum/Layout/Flow, arrangement: Midum/Internal/DOM/Layout/Arrangement, gap: Midum/Layout/Gap, align: Midum/Layout/Align, kids: List(HTML(Event))) -> String:
  "bc-layout-stack " ++ flow_class(flow) ++ " " ++ arrangement_class(Event, arrangement, kids) ++ " " ++ gap_class(gap) ++ " " ++ align_class(align)

def group_stack(Event: Type, flow: Midum/Layout/Flow, arrangement: Midum/Internal/DOM/Layout/Arrangement, gap: Midum/Layout/Gap, align: Midum/Layout/Align, kids: List(HTML(Event))) -> HTML(Event):
  <div class={group_stack_class(Event, flow, arrangement, gap, align, kids)}>
    {...kids}
  </div>

def document_stack_class(cfg: Midum/Layout/StackConfig) -> String:
  match cfg:
    case document_stack_layout{flow, gap, align}:
      "bc-layout-document-stack " ++ flow_class(flow) ++ " " ++ gap_class(gap) ++ " " ++ align_class(align)

def render_document_stack(Event: Type, cfg: Midum/Layout/StackConfig, kids: List(HTML(Event))) -> HTML(Event):
  <div class={document_stack_class(cfg)}>
    {...kids}
  </div>

def css_canvas() -> String:
  "
  .bc-layout-shell {
    display: block;
    box-sizing: border-box;
    min-width: 0;
    margin-left: auto;
    margin-right: auto;
    padding-top: var(--bc-layout-shell-inset-top);
    padding-right: var(--bc-layout-shell-inset-right);
    padding-bottom: var(--bc-layout-shell-inset-bottom);
    padding-left: var(--bc-layout-shell-inset-left);
  }

  .bc-layout-shell-safe-area {
    padding-top: calc(var(--bc-layout-shell-inset-top) + env(safe-area-inset-top));
    padding-right: calc(var(--bc-layout-shell-inset-right) + env(safe-area-inset-right));
    padding-bottom: calc(var(--bc-layout-shell-inset-bottom) + env(safe-area-inset-bottom));
    padding-left: calc(var(--bc-layout-shell-inset-left) + env(safe-area-inset-left));
  }

  .bc-layout-shell-height-viewport {
    min-height: 100svh;
    height: 100svh;
    max-height: 100svh;
  }

  .bc-layout-shell-overflow-hidden {
    overflow: hidden;
  }

  @media (max-width: 800px) {
    .bc-layout-shell {
      padding-top: var(--bc-layout-shell-compact-inset-top);
      padding-right: var(--bc-layout-shell-compact-inset-right);
      padding-bottom: var(--bc-layout-shell-compact-inset-bottom);
      padding-left: var(--bc-layout-shell-compact-inset-left);
    }

    .bc-layout-shell-safe-area {
      padding-top: calc(var(--bc-layout-shell-compact-inset-top) + env(safe-area-inset-top));
      padding-right: calc(var(--bc-layout-shell-compact-inset-right) + env(safe-area-inset-right));
      padding-bottom: calc(var(--bc-layout-shell-compact-inset-bottom) + env(safe-area-inset-bottom));
      padding-left: calc(var(--bc-layout-shell-compact-inset-left) + env(safe-area-inset-left));
    }
  }

  .bc-layout-page {
    display: block;
    box-sizing: border-box;
    width: 100%;
    min-height: 100vh;
  }

  .bc-layout-container {
    display: block;
    box-sizing: border-box;
    width: 100%;
    min-width: 0;
    margin-left: auto;
    margin-right: auto;
  }

  .bc-layout-box {
    box-sizing: border-box;
    display: flex;
    flex: 1 1 auto;
    width: 100%;
    max-width: 100%;
    height: 100%;
    min-height: 0;
  }

  .bc-screen > .bc-layout-box {
    min-height: 100vh;
    padding: 24px;
  }

  .bc-layout-box > .bc-layout-box-body {
    display: flex;
    box-sizing: border-box;
    max-width: 100%;
    max-height: 100%;
    min-width: 0;
    min-height: 0;
  }

  .bc-layout-overlay {
    position: relative;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
    min-height: 100%;
  }

  .bc-screen > .bc-layout-overlay {
    min-height: 100vh;
  }

  .bc-layout-overlay > .bc-layout-box {
    position: absolute;
    inset: 0;
    padding: 24px;
    pointer-events: none;
  }

  .bc-layout-overlay > .bc-layout-box > .bc-layout-box-body {
    pointer-events: none;
  }

  .bc-layout-overlay > .bc-layout-box > .bc-layout-box-body > * {
    pointer-events: auto;
  }

  .bc-layout-frame {
    display: block;
    box-sizing: border-box;
    min-width: 0;
    min-height: 0;
  }

  .bc-layout-frame > .bc-layout-overlay {
    width: 100%;
    height: 100%;
    min-height: 0;
  }

  .bc-layout-frame > .bc-layout-overlay > .bc-layout-box {
    padding: 0;
  }

  .bc-layout-stack {
    display: flex;
    box-sizing: border-box;
    max-width: 100%;
    min-width: 0;
    min-height: 0;
  }

  .bc-layout-document-stack {
    display: flex;
    box-sizing: border-box;
    width: 100%;
    max-width: 100%;
    min-width: 0;
    min-height: 0;
    gap: var(--bc-layout-gap);
  }
  "

def css_regions() -> String:
  "
  .bc-layout-pos-top-left {
    justify-content: flex-start;
    align-items: flex-start;
  }

  .bc-layout-pos-top {
    justify-content: flex-start;
    align-items: stretch;
  }

  .bc-layout-pos-top-right {
    justify-content: flex-end;
    align-items: flex-start;
  }

  .bc-layout-pos-left {
    justify-content: flex-start;
    align-items: stretch;
  }

  .bc-layout-pos-center {
    justify-content: center;
    align-items: stretch;
  }

  .bc-layout-pos-right {
    justify-content: flex-end;
    align-items: stretch;
  }

  .bc-layout-pos-bottom-left {
    justify-content: flex-start;
    align-items: flex-end;
  }

  .bc-layout-pos-bottom {
    justify-content: flex-end;
    align-items: stretch;
  }

  .bc-layout-pos-bottom-right {
    justify-content: flex-end;
    align-items: flex-end;
  }

  .bc-layout-pos-top > .bc-layout-box-body,
  .bc-layout-pos-bottom > .bc-layout-box-body,
  .bc-layout-pos-center > .bc-layout-box-body {
    width: 100%;
  }

  .bc-layout-pos-left > .bc-layout-box-body,
  .bc-layout-pos-right > .bc-layout-box-body,
  .bc-layout-pos-top > .bc-layout-box-body,
  .bc-layout-pos-bottom > .bc-layout-box-body,
  .bc-layout-pos-center > .bc-layout-box-body {
    height: 100%;
  }

  .bc-layout-pos-top > .bc-layout-box-body {
    justify-content: flex-start;
  }

  .bc-layout-pos-bottom > .bc-layout-box-body {
    justify-content: flex-end;
  }

  .bc-layout-pos-left > .bc-layout-box-body,
  .bc-layout-pos-right > .bc-layout-box-body,
  .bc-layout-pos-center > .bc-layout-box-body {
    justify-content: center;
  }
  "

def css_flow() -> String:
  "
  .bc-layout-box-body.bc-layout-flow-row {
    flex-direction: row;
    align-items: center;
    gap: var(--bc-layout-gap);
  }

  .bc-layout-box-body.bc-layout-flow-column {
    flex-direction: column;
    align-items: center;
    gap: var(--bc-layout-gap);
  }

  .bc-layout-stack.bc-layout-flow-row {
    flex-direction: row;
    align-items: center;
    gap: var(--bc-layout-gap);
  }

  .bc-layout-stack.bc-layout-flow-column {
    flex-direction: column;
    align-items: center;
    gap: var(--bc-layout-gap);
  }

  .bc-layout-document-stack.bc-layout-flow-row {
    flex-direction: row;
  }

  .bc-layout-document-stack.bc-layout-flow-column {
    flex-direction: column;
  }

  .bc-layout-document-stack.bc-layout-align-start,
  .bc-layout-stack.bc-layout-align-start {
    align-items: flex-start;
  }

  .bc-layout-document-stack.bc-layout-align-center,
  .bc-layout-stack.bc-layout-align-center {
    align-items: center;
  }

  .bc-layout-document-stack.bc-layout-align-end,
  .bc-layout-stack.bc-layout-align-end {
    align-items: flex-end;
  }

  .bc-layout-document-stack.bc-layout-align-stretch,
  .bc-layout-stack.bc-layout-align-stretch {
    align-items: stretch;
  }

  .bc-layout-stack.bc-layout-flow-column.bc-layout-align-stretch {
    width: 100%;
  }

  .bc-layout-stack.bc-layout-flow-row.bc-layout-align-stretch {
    height: 100%;
  }

  .bc-layout-stack.bc-layout-arrangement-packed {
    justify-content: center;
  }

  .bc-layout-stack.bc-layout-arrangement-between.bc-layout-flow-row {
    width: 100%;
    justify-content: space-between;
  }

  .bc-layout-stack.bc-layout-arrangement-between.bc-layout-flow-column {
    height: 100%;
    justify-content: space-between;
  }

  .bc-layout-gap-none {
    --bc-layout-gap: 0px;
  }

  .bc-layout-gap-sm {
    --bc-layout-gap: 8px;
  }

  .bc-layout-gap-md {
    --bc-layout-gap: 16px;
  }

  .bc-layout-gap-lg {
    --bc-layout-gap: 24px;
  }
  "

def css() -> String:
  css_canvas() ++ css_regions() ++ css_flow()
