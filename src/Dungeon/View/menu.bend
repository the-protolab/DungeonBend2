import /HTML/
import /Dungeon/Meta as Meta
import /Dungeon/Scene as Scene
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/View/selectors/meta_gold as meta_gold
import /Dungeon/View/selectors/hero_menu_stats as hero_menu_stats
import /Dungeon/View/selectors/start_enabled as start_enabled
import /Dungeon/View/selectors/upgrade_enabled as upgrade_enabled
import /Dungeon/View/selectors/menu_upgrade_label as menu_upgrade_label
import /Dungeon/View/selectors/menu_upgrade_cost_text as menu_upgrade_cost_text
import /Dungeon/View/selectors/next_upgrade_cost as next_upgrade_cost
import /Midum/Button/ as Button
import /Midum/Button/Size
import /Dungeon/View/assets_and_labels/_hero_name as _hero_name
import /Dungeon/View/assets_and_labels/_hero_sprite as _hero_sprite

def _dashboard_header(meta_state: Meta) -> HTML(DungeonEvent):
  <header class="topbar">
    <p class="resource-bar">
      <span class="resource-bar__label">Gold</span>
      <strong class="resource-bar__value">{text{meta_gold(meta_state)}}</strong>
    </p>
  </header>

def _render_menu(meta_state: Meta) -> HTML(DungeonEvent):
  <section class="shell shell--menu">
    {_dashboard_header(meta_state)}
    <section class="menu-stage">
      <div class="menu-stage__content">
        {_menu_hero_panel(meta_state)}
      </div>
    </section>
    <section class="menu-actions">
      <div class="menu-start-action">
        {_menu_start_button()}
      </div>
    </section>
  </section>

def _menu_hero_panel(meta_state: Meta) -> HTML(DungeonEvent):
  <section class="menu-hero-panel">
    <p class="menu-hero-panel__name">{text{_hero_name()}}</p>
    <div class="menu-hero-panel__portrait">
      <img class="menu-hero-panel__image" src={_hero_sprite()} alt={_hero_name()} />
    </div>
    <p class="menu-hero-panel__stats">{text{hero_menu_stats(meta_state)}}</p>
    <div class="menu-upgrade-row">
      <div class="menu-upgrade-row__action">
        {_menu_upgrade_button(meta_state)}
      </div>
      <p class="menu-upgrade-row__meta">{text{menu_upgrade_cost_text(meta_state)}}</p>
    </div>
  </section>

def _menu_start_button() -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    start{},
    large{},
    "Start",
    _full_button_overrides(start_enabled(setup{}))
  )

def _menu_upgrade_button(meta_state: Meta) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    upgrade{},
    medium{},
    menu_upgrade_label(meta_state),
    _fit_button_overrides(upgrade_enabled(meta_state, setup{}, next_upgrade_cost(meta_state)))
  )

def _full_button_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [width_full{} state_disabled{}]
    case _:
      [width_full{}]

def _fit_button_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [state_disabled{}]
    case _:
      []
