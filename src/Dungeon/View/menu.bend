import /HTML/
import /Dungeon/HeroDef as HeroDef
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/HeroPresentation as HeroPresentation
import /Dungeon/Meta as Meta
import /Dungeon/PresentationAlign as PresentationAlign
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/config as config
import /Dungeon/hero_helpers/hero_at as hero_at
import /Dungeon/hero_helpers/hero_count as hero_count
import /Dungeon/hero_helpers/hero_name as hero_name
import /Dungeon/hero_helpers/hero_sprite as hero_sprite
import /Dungeon/hero_presentation/hero_presentation_at as hero_presentation_at
import /Dungeon/hero_presentation/hero_presentation_name_align as hero_presentation_name_align
import /Dungeon/hero_presentation/hero_presentation_ultimate_description as hero_presentation_ultimate_description
import /Dungeon/hero_presentation/hero_presentation_ultimate_icon as hero_presentation_ultimate_icon
import /Dungeon/hero_presentation/hero_presentation_ultimate_title as hero_presentation_ultimate_title
import /Dungeon/profile_helpers/selected_hero as selected_hero
import /Dungeon/profile_helpers/selection_confirmed as selection_confirmed
import /Dungeon/profile_helpers/active_profile as active_profile
import /Dungeon/profile_helpers/profile_for_hero as profile_for_hero
import /Dungeon/profile_helpers/profile_unlocked as profile_unlocked
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
import /Dungeon/View/selectors/character_upgrade_enabled as character_upgrade_enabled
import /Dungeon/View/selectors/character_primary_label as character_primary_label
import /Dungeon/View/selectors/character_primary_enabled as character_primary_enabled
import /Dungeon/Content/ as Content
import /Midum/Button/ as Button
import /Midum/Button/Size
import /Midum/Card/ as Card
import /Midum/Layout/ as Layout
import /Midum/Text/ as Text
import /Midum/Text/Align

def _dashboard_header(meta_state: Meta, header_action: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  <header class="topbar topbar--menu">
    <p class="resource-bar">
      <span class="resource-bar__label">{text{Content.ui_topbar_gold()}}</span>
      <strong class="resource-bar__value">{text{meta_gold(meta_state)}}</strong>
    </p>
    <div class="topbar__actions">
      <div class="topbar__stats">
        {_menu_stat(Content.ui_topbar_boosters(), meta_pack_total(meta_state))}
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
  _menu_shell(
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
    )
  )

def _menu_shell(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  Layout.shell(
    DungeonEvent,
    body,
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
  presentation = hero_presentation_at(preview_hero);
  _menu_shell(
    Layout.frame(
      DungeonEvent,
      Layout.overlay(DungeonEvent, [
        Layout.top(DungeonEvent,
          Layout.frame(
            DungeonEvent,
            _dashboard_header(meta_state, _header_placeholder_action()),
            [width_full{} height_fit{} inset_none{}]
          )
        )
        Layout.center(DungeonEvent,
          Layout.frame(
            DungeonEvent,
            _character_select_content(meta_state, preview_hero, hero_value, profile, presentation),
            [width_full{} height_fit{} inset_none{}]
          )
        )
        Layout.bottom(DungeonEvent, _character_bottom_actions(meta_state, preview_hero, hero_value, profile))
      ]),
      [width_full{} height_full{} inset_none{}]
    )
  )

def _character_select_content(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  Layout.group(
    DungeonEvent,
    [
      _character_detail_panel(meta_state, preview_hero, hero_value, profile, presentation)
      _character_context_actions(meta_state, hero_value, profile)
      _character_roster(meta_state, preview_hero)
    ],
    [direction_column{} gap_md{} align_center{}]
  )

def _character_bottom_actions(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Layout.frame(
    DungeonEvent,
    Layout.row_between(DungeonEvent, [
      _character_back_button()
      Layout.frame(
        DungeonEvent,
        _character_select_button(meta_state, preview_hero, hero_value, profile),
        [width_px{value: 280n} height_fit{} inset_none{}]
      )
    ]),
    [width_px{value: 460n} height_fit{} inset_none{}]
  )

def _character_detail_panel(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <section class="character-detail">
    {Layout.row(DungeonEvent, [
      _character_detail_portrait(hero_value)
      _character_info_column(meta_state, preview_hero, hero_value, profile, presentation)
    ])}
  </section>

def _character_detail_portrait(hero_value: HeroDef) -> HTML(DungeonEvent):
  <div class="character-detail__portrait">
    <img class="character-detail__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
  </div>

def _character_info_column(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <div class="character-detail__info">
    {Layout.group(
      DungeonEvent,
      [
        _character_detail_name(hero_value, presentation)
        _hero_hud(hero_value, profile)
        _character_detail_status(meta_state, preview_hero, profile)
        _character_ultimate_block(presentation)
      ],
      [direction_column{} gap_sm{} align_stretch{}]
    )}
  </div>

def _character_detail_name(hero_value: HeroDef, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <div class="character-detail__name-outline">
    {Text.h2(
      DungeonEvent,
      _presentation_text_align(hero_presentation_name_align(presentation)),
      hero_name(hero_value),
      []
    )}
  </div>

def _character_detail_status(meta_state: Meta, preview_hero: U32, profile: HeroProfile) -> HTML(DungeonEvent):
  <p class={_character_detail_status_class(meta_state, preview_hero, profile)}>
    {text{_character_detail_status_label(meta_state, preview_hero, profile)}}
  </p>

def _character_ultimate_block(presentation: HeroPresentation) -> HTML(DungeonEvent):
  <section class="character-ultimate">
    {Text.label(DungeonEvent, left{}, hero_presentation_ultimate_title(presentation), [])}
    <div class="character-ultimate__body">
      <img class="character-ultimate__icon" src={hero_presentation_ultimate_icon(presentation)} alt={hero_presentation_ultimate_title(presentation)} />
      <div class="character-ultimate__description">
        {Text.body(DungeonEvent, left{}, hero_presentation_ultimate_description(presentation), [])}
      </div>
    </div>
  </section>

def _presentation_text_align(align: PresentationAlign) -> Midum/Text/Align:
  match align:
    case presentation_left{}:
      left{}
    case presentation_center{}:
      center{}
    case presentation_right{}:
      right{}

def _character_context_actions(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="character-actions">
    {_character_upgrade_button(meta_state, hero_value, profile)}
  </section>

def _character_roster(meta_state: Meta, preview_hero: U32) -> HTML(DungeonEvent):
  <section class="character-roster">
    {Layout.row(DungeonEvent, _character_roster_items(meta_state, preview_hero, 0, hero_count(config())))}
  </section>

def _character_roster_items(meta_state: Meta, preview_hero: U32, hero_ref: U32, count: U32) -> List(HTML(DungeonEvent)):
  match hero_ref < count:
    case 0:
      []
    case _:
      hero_value = hero_at(config(), hero_ref);
      profile = profile_for_hero(meta_state, hero_ref);
      _character_roster_card(meta_state, preview_hero, hero_ref, hero_value, profile)<>_character_roster_items(meta_state, preview_hero, hero_ref + 1, count)

def _character_roster_card(meta_state: Meta, preview_hero: U32, hero_ref: U32, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <button class={_character_roster_card_class(meta_state, preview_hero, hero_ref, profile)} type="button" on_click={preview_character{hero_ref}}>
    {Card.neutral(
      DungeonEvent,
      <span class="character-roster-card__content">
        <span class="character-roster-card__image-wrap">
          <img class="character-roster-card__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
        </span>
      </span>,
      [padding_sm{}]
    )}
  </button>

def _character_equipped(meta_state: Meta, hero_ref: U32) -> U32:
  match selection_confirmed(meta_state):
    case 0:
      0
    case _:
      selected_hero(meta_state) === hero_ref

def _character_detail_status_label(meta_state: Meta, preview_hero: U32, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      Content.ui_character_locked()
    case _:
      _character_detail_unlocked_status(_character_equipped(meta_state, preview_hero))

def _character_detail_unlocked_status(equipped: U32) -> String:
  match equipped:
    case 0:
      Content.ui_character_preview()
    case _:
      Content.ui_character_equipped()

def _character_detail_status_class(meta_state: Meta, preview_hero: U32, profile: HeroProfile) -> String:
  "character-detail__status " ++ _character_detail_status_state_class(meta_state, preview_hero, profile)

def _character_detail_status_state_class(meta_state: Meta, preview_hero: U32, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      "character-detail__status--locked"
    case _:
      _character_detail_status_unlocked_class(_character_equipped(meta_state, preview_hero))

def _character_detail_status_unlocked_class(equipped: U32) -> String:
  match equipped:
    case 0:
      "character-detail__status--preview"
    case _:
      "character-detail__status--equipped"

def _character_roster_card_class(meta_state: Meta, preview_hero: U32, hero_ref: U32, profile: HeroProfile) -> String:
  "character-roster-card " ++ _character_roster_card_state_class(meta_state, preview_hero, hero_ref, profile)

def _character_roster_card_state_class(meta_state: Meta, preview_hero: U32, hero_ref: U32, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      _character_roster_card_locked_class(preview_hero === hero_ref)
    case _:
      _character_roster_card_unlocked_class(_character_equipped(meta_state, hero_ref), preview_hero === hero_ref)

def _character_roster_card_locked_class(previewed: U32) -> String:
  match previewed:
    case 0:
      "character-roster-card--locked"
    case _:
      "character-roster-card--locked character-roster-card--preview"

def _character_roster_card_unlocked_class(equipped: U32, previewed: U32) -> String:
  match equipped:
    case 0:
      _character_roster_card_preview_class(previewed)
    case _:
      _character_roster_card_equipped_class(previewed)

def _character_roster_card_preview_class(previewed: U32) -> String:
  match previewed:
    case 0:
      "character-roster-card--idle"
    case _:
      "character-roster-card--preview"

def _character_roster_card_equipped_class(previewed: U32) -> String:
  match previewed:
    case 0:
      "character-roster-card--equipped"
    case _:
      "character-roster-card--equipped character-roster-card--preview"

def _menu_hero_panel(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="menu-hero-panel">
    <p class="menu-hero-panel__name">{text{hero_name(hero_value)}}</p>
    <div class="menu-hero-panel__portrait">
      <img class="menu-hero-panel__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
    </div>
    {_hero_hud(hero_value, profile)}
    {_menu_upgrade_row(meta_state, hero_value, profile)}
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

def _menu_start_button() -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    start{},
    large{},
    Content.ui_menu_start(),
    _full_button_overrides(start_enabled(setup{}))
  )

def _menu_boosters_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_boosters{},
    medium{},
    Content.ui_menu_boosters(),
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

def _character_upgrade_button(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    upgrade{},
    medium{},
    character_upgrade_label(hero_value, profile) ++ " " ++ character_upgrade_cost_text(hero_value, profile),
    _action_button_overrides(character_upgrade_enabled(meta_state, hero_value, profile))
  )

def _character_back_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    close_character_select{},
    medium{},
    Content.ui_menu_back(),
    _fit_button_overrides(1)
  )

def _character_select_button(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    select_character{},
    large{},
    character_primary_label(meta_state, preview_hero, hero_value, profile),
    _full_button_overrides(character_primary_enabled(meta_state, preview_hero, hero_value, profile))
  )

def _header_characters_action() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_character_select{},
    small{},
    Content.ui_menu_characters(),
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

def _action_button_overrides(enabled: U32) -> List(Midum/Button/Override):
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
