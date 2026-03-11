import /dungeon/app/base_css as base_css
import /dungeon/app/layout_css as layout_css
import /dungeon/app/cards_css as cards_css
import /dungeon/app/fx_css as fx_css

def css() -> String:
  base_css()
  ++ layout_css()
  ++ cards_css()
  ++ fx_css()
