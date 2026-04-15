# Public per-instance overrides for layout primitives.

type Override {
  width_fit{}
  width_full{}
  width_px{value: Nat}
  height_fit{}
  height_full{}
  height_px{value: Nat}
  inset_none{}
  inset_sm{}
  inset_md{}
  inset_lg{}
  inset_px{top: Nat, right: Nat, bottom: Nat, left: Nat}
  compact_inset_px{top: Nat, right: Nat, bottom: Nat, left: Nat}
  max_width_px{value: Nat}
  height_viewport{}
  overflow_hidden{}
  safe_area{}
  direction_column{}
  direction_row{}
  gap_none{}
  gap_sm{}
  gap_md{}
  gap_lg{}
  align_start{}
  align_center{}
  align_end{}
  align_stretch{}
}
