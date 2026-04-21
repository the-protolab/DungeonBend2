import /HTML/
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/Content/ as Content
import /Dungeon/View/assets_and_labels/_gold_icon as _gold_icon

def gold_stat(value: String) -> HTML(DungeonEvent):
  <p class="topbar-resource topbar-resource--gold">
    <img class="topbar-resource__icon" src={_gold_icon()} alt={Content.ui_topbar_gold()} />
    <strong class="topbar-resource__value">{text{value}}</strong>
  </p>

def stat(label: String, value: String) -> HTML(DungeonEvent):
  <p class="topbar-stat">
    <span class="topbar-stat__label">{text{label}}</span>
    <strong class="topbar-stat__value">{text{value}}</strong>
  </p>
