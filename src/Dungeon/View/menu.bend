import /HTML/
import /Dungeon/HeroDef as HeroDef
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/Meta as Meta
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/config as config
import /Dungeon/hero_helpers/hero_at as hero_at
import /Dungeon/hero_helpers/hero_count as hero_count
import /Dungeon/hero_helpers/hero_name as hero_name
import /Dungeon/hero_helpers/hero_sprite as hero_sprite
import /Dungeon/profile_helpers/selected_hero as selected_hero
import /Dungeon/profile_helpers/selection_confirmed as selection_confirmed
import /Dungeon/profile_helpers/active_profile as active_profile
import /Dungeon/profile_helpers/profile_for_hero as profile_for_hero
import /Dungeon/View/selectors/meta_gold as meta_gold
import /Dungeon/View/selectors/meta_pack_total as meta_pack_total
import /Dungeon/View/selectors/hero_menu_level_text as hero_menu_level_text
import /Dungeon/View/selectors/hero_menu_current_hp_text as hero_menu_current_hp_text
import /Dungeon/View/selectors/hero_menu_max_hp_text as hero_menu_max_hp_text
import /Dungeon/View/selectors/start_enabled as start_enabled
import /Dungeon/View/selectors/menu_upgrade_label as menu_upgrade_label
import /Dungeon/View/selectors/menu_upgrade_cost_text as menu_upgrade_cost_text
import /Dungeon/View/selectors/menu_upgrade_visible as menu_upgrade_visible
import /Dungeon/View/selectors/character_upgrade_label as character_upgrade_label
import /Dungeon/View/selectors/character_upgrade_cost_text as character_upgrade_cost_text
import /Dungeon/View/selectors/character_primary_label as character_primary_label
import /Dungeon/View/selectors/character_primary_enabled as character_primary_enabled
import /Midum/Button/ as Button
import /Midum/Button/Size
import /Midum/Layout/ as Layout
import /Midum/Text/ as Text
import /Midum/Text/Align

def _dashboard_header(meta_state: Meta, header_action: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  <header class="topbar topbar--menu">
    <p class="resource-bar">
      <span class="resource-bar__label">Gold</span>
      <strong class="resource-bar__value">{text{meta_gold(meta_state)}}</strong>
    </p>
    <div class="topbar__actions">
      <div class="topbar__stats">
        {_menu_stat("Boosters", meta_pack_total(meta_state))}
      </div>
      <div class="topbar__slot">
        {header_action}
      </div>
    </div>
  </header>

def _render_menu(meta_state: Meta) -> HTML(DungeonEvent):
  hero_ref = selected_hero(meta_state);
  hero_value = hero_at(config(), hero_ref);
  profile = active_profile(meta_state);
  Layout.shell(
    DungeonEvent,
    Layout.frame(
      DungeonEvent,
      Layout.overlay(DungeonEvent, [
        Layout.top(DungeonEvent,
          Layout.frame(
            DungeonEvent,
            _dashboard_header(meta_state, _header_characters_action()),
            [width_full{} height_fit{} inset_none{}]
          )
        )
        Layout.center(DungeonEvent,
          Layout.frame(
            DungeonEvent,
            <section class="menu-stage">
              <div class="menu-stage__content">
                {_menu_hero_panel(meta_state, hero_value, profile)}
              </div>
            </section>,
            [width_full{} height_fit{} inset_none{}]
          )
        )
        Layout.bottom(DungeonEvent, _menu_actions_layout())
      ]),
      [width_full{} height_full{} inset_none{}]
    ),
    [
      max_width_px{value: 560n}
      height_viewport{}
      overflow_hidden{}
      safe_area{}
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n}
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _menu_actions_layout() -> HTML(DungeonEvent):
  Layout.frame(
    DungeonEvent,
    Layout.group(
      DungeonEvent,
      [
        _menu_boosters_button()
        _menu_start_button()
      ],
      [direction_column{} gap_sm{} align_stretch{}]
    ),
    [width_px{value: 280n} height_fit{} inset_none{}]
  )

def _render_character_select(meta_state: Meta, preview_hero: U32) -> HTML(DungeonEvent):
  hero_value = hero_at(config(), preview_hero);
  profile = profile_for_hero(meta_state, preview_hero);
  <section class="shell shell--menu">
    {_dashboard_header(meta_state, _header_placeholder_action())}
    <section class="menu-stage">
      <div class="menu-stage__content">
        {_menu_character_panel(hero_value, profile)}
      </div>
    </section>
    <section class="menu-actions">
      <div class="menu-secondary-action">
        {_character_back_button(meta_state)}
      </div>
      <div class="menu-start-action">
        {_character_select_button(meta_state, preview_hero, hero_value, profile)}
      </div>
    </section>
  </section>

def _menu_hero_panel(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="menu-hero-panel">
    <p class="menu-hero-panel__name">{text{hero_name(hero_value)}}</p>
    <div class="menu-hero-panel__portrait">
      <img class="menu-hero-panel__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
    </div>
    {_hero_hud(hero_value, profile)}
    {_menu_upgrade_row(meta_state, hero_value, profile)}
  </section>

def _menu_character_panel(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="menu-hero-panel">
    <p class="menu-hero-panel__name">{text{hero_name(hero_value)}}</p>
    <div class="menu-hero-panel__portrait menu-hero-panel__portrait--select">
      <div class="menu-hero-panel__nav">
        <div class="menu-hero-panel__nav-action">
          {_character_nav_button("←", move{left{}}, _character_nav_enabled())}
        </div>
        <div class="menu-hero-panel__nav-figure">
          <img class="menu-hero-panel__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
        </div>
        <div class="menu-hero-panel__nav-action">
          {_character_nav_button("→", move{right{}}, _character_nav_enabled())}
        </div>
      </div>
    </div>
    {_hero_hud(hero_value, profile)}
    <div class="menu-upgrade-row">
      <div class="menu-upgrade-row__action">
        {_menu_preview_upgrade_button(hero_value, profile)}
      </div>
      <p class="menu-upgrade-row__meta">{text{character_upgrade_cost_text(hero_value, profile)}}</p>
    </div>
  </section>

def _hero_hud(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <div class="hero-hud">
    <div class="hero-hud__level">
      {Text.label(DungeonEvent, left{}, hero_menu_level_text(profile), [])}
    </div>
    <div class="hero-hud__hp">
      <div class="hero-hud__heart">
        <img class="hero-hud__heart-image" src="assets/icon_heart.png" alt="" />
        <span class="hero-hud__heart-value">{text{hero_menu_current_hp_text(hero_value, profile)}}</span>
      </div>
      <div class="hero-hud__max">
        {Text.body(DungeonEvent, left{}, "/" ++ hero_menu_max_hp_text(hero_value, profile), [])}
      </div>
    </div>
  </div>

def _menu_upgrade_row(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  match menu_upgrade_visible(meta_state, hero_value, profile):
    case 1:
      <div class="menu-upgrade-row">
        <div class="menu-upgrade-row__action">
          {_menu_upgrade_button(hero_value, profile)}
        </div>
        <p class="menu-upgrade-row__meta">{text{menu_upgrade_cost_text(hero_value, profile)}}</p>
      </div>
    case _:
      <div class="menu-upgrade-row menu-upgrade-row--placeholder"></div>

def _character_nav_enabled() -> U32:
  _character_nav_enabled_count(hero_count(config()))

def _character_nav_enabled_count(count: U32) -> U32:
  match count:
    case 0:
      0
    case 1:
      0
    case _:
      1

def _menu_start_button() -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    start{},
    large{},
    "Start",
    _full_button_overrides(start_enabled(setup{}))
  )

def _menu_boosters_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_boosters{},
    medium{},
    "BOOSTERS",
    _full_button_overrides(1)
  )

def _menu_upgrade_button(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    upgrade{},
    medium{},
    menu_upgrade_label(hero_value, profile),
    _fit_button_overrides(1)
  )

def _menu_preview_upgrade_button(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    ignore{},
    medium{},
    character_upgrade_label(hero_value, profile),
    _fit_button_overrides(0)
  )

def _character_back_button(meta_state: Meta) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    close_character_select{},
    medium{},
    "BACK",
    _fit_button_overrides(selection_confirmed(meta_state))
  )

def _character_select_button(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    select_character{},
    large{},
    character_primary_label(meta_state, preview_hero, hero_value, profile),
    _full_button_overrides(character_primary_enabled(meta_state, preview_hero, hero_value, profile))
  )

def _character_nav_button(label: String, evt: DungeonEvent, enabled: U32) -> HTML(DungeonEvent):
  Button.secondary(DungeonEvent, evt, medium{}, label, _fit_button_overrides(enabled))

def _header_characters_action() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_character_select{},
    small{},
    "Characters",
    _fit_button_overrides(1)
  )

def _header_placeholder_action() -> HTML(DungeonEvent):
  <div class="topbar__slot--placeholder">
    {_header_characters_action()}
  </div>

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

def _menu_stat(label: String, value: String) -> HTML(DungeonEvent):
  <p class="topbar-stat">
    <span class="topbar-stat__label">{text{label}}</span>
    <strong class="topbar-stat__value">{text{value}}</strong>
  </p>
