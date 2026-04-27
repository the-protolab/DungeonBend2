import /HTML/
import /U32/ as U32
import /Dungeon/HeroDef as HeroDef
import /Dungeon/HeroProfile as HeroProfile
import /Dungeon/HeroPresentation as HeroPresentation
import /Dungeon/Meta as Meta
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/config as config
import /Dungeon/hero_helpers/hero_at as hero_at
import /Dungeon/hero_helpers/hero_base_max_hp as hero_base_max_hp
import /Dungeon/hero_helpers/hero_count as hero_count
import /Dungeon/hero_helpers/hero_name as hero_name
import /Dungeon/hero_helpers/hero_sprite as hero_sprite
import /Dungeon/hero_presentation/hero_presentation_at as hero_presentation_at
import /Dungeon/hero_presentation/hero_presentation_lore as hero_presentation_lore
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
import /Dungeon/View/selectors/hero_base_hp_text as hero_base_hp_text
import /Dungeon/View/selectors/hero_level_progress_text as hero_level_progress_text
import /Dungeon/View/selectors/hero_level_ratio_text as hero_level_ratio_text
import /Dungeon/View/selectors/hero_menu_level_text as hero_menu_level_text
import /Dungeon/View/selectors/start_enabled as start_enabled
import /Dungeon/View/selectors/menu_upgrade_label as menu_upgrade_label
import /Dungeon/View/selectors/menu_upgrade_visible as menu_upgrade_visible
import /Dungeon/View/selectors/character_upgrade_maxed as character_upgrade_maxed
import /Dungeon/View/selectors/character_upgrade_enabled as character_upgrade_enabled
import /Dungeon/View/selectors/character_upgrade_price_text as character_upgrade_price_text
import /Dungeon/View/assets_and_labels/_gold_icon as _gold_icon
import /Dungeon/View/menu_screen/_menu_screen_frame as _menu_screen_frame
import /Dungeon/Content/ as Content
import /Dungeon/View/topbar_stats/gold_stat as gold_stat
import /Midum/Button/ as Button
import /Midum/Button/Size
import /Midum/Card/ as Card
import /Midum/Layout/ as Layout
import /Midum/Text/ as Text
import /Midum/Text/Align

def _menu_header(meta_state: Meta) -> HTML(DungeonEvent):
  <div class="menu-home-headers">
    <header class="topbar topbar--menu-home topbar--menu-home-desktop">
      <div class="topbar__stats">
        {gold_stat(meta_gold(meta_state))}
      </div>
    </header>
    <header class="topbar topbar--menu-home topbar--menu-home-mobile">
      <div class="topbar__slot topbar__slot--leading">
        {_header_characters_action()}
      </div>
      <div class="topbar__stats">
        {gold_stat(meta_gold(meta_state))}
      </div>
    </header>
  </div>

def _render_menu(meta_state: Meta) -> HTML(DungeonEvent):
  hero_ref = selected_hero(meta_state);
  hero_value = hero_at(config(), hero_ref);
  profile = active_profile(meta_state);
  _menu_shell(
    Layout.frame(
      DungeonEvent,
      _menu_screen_frame(
        _menu_header(meta_state),
        <section class="menu-stage menu-stage--home">
          <div class="menu-stage__content menu-stage__content--home">
            {_menu_home(meta_state, hero_value, profile)}
          </div>
        </section>,
        _menu_actions_layout(meta_state)
      ),
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

def _menu_actions_layout(meta_state: Meta) -> HTML(DungeonEvent):
  Layout.frame(
    DungeonEvent,
    <section class="menu-actions">
      <div class="menu-actions__booster">
        {_menu_boosters_button(meta_state)}
      </div>
      <div class="menu-actions__primary">
        <div class="menu-actions__slot">
          {_menu_deck_button()}
        </div>
        <div class="menu-actions__slot">
          {_menu_start_button()}
        </div>
      </div>
    </section>,
    [width_full{} height_fit{} inset_none{}]
  )

def _render_character_select(meta_state: Meta, preview_hero: U32) -> HTML(DungeonEvent):
  hero_value = hero_at(config(), preview_hero);
  profile = profile_for_hero(meta_state, preview_hero);
  presentation = hero_presentation_at(preview_hero);
  _character_select_shell(
    Layout.frame(
      DungeonEvent,
      _menu_screen_frame(
        _character_select_header(meta_state),
        <section class="character-select-stage">
          <div class="character-select-stage__content">
            {_character_select_content(meta_state, preview_hero, hero_value, profile, presentation)}
          </div>
        </section>,
        _character_mobile_footer()
      ),
      [width_full{} height_full{} inset_none{}]
    )
  )

def _character_select_shell(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  Layout.shell(
    DungeonEvent,
    body,
    [
      max_width_px{value: 1080n}
      height_viewport{}
      overflow_hidden{}
      safe_area{}
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n}
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _character_select_header(meta_state: Meta) -> HTML(DungeonEvent):
  <div class="character-select-headers">
    <header class="topbar topbar--character-select topbar--character-select-desktop">
      <div class="topbar__slot topbar__slot--leading">
        {_character_back_button()}
      </div>
      <div class="topbar__stats">
        {gold_stat(meta_gold(meta_state))}
      </div>
    </header>
    <header class="topbar topbar--character-select topbar--character-select-mobile">
      <div class="topbar__slot topbar__slot--leading topbar__slot--placeholder" aria-hidden="true"></div>
      <div class="topbar__stats">
        {gold_stat(meta_gold(meta_state))}
      </div>
    </header>
  </div>

def _character_select_content(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <section class="character-select">
    <div class="character-select__main">
      {_character_detail_panel(meta_state, preview_hero, hero_value, profile, presentation)}
    </div>
    <aside class="character-select__side">
      {_character_roster(meta_state, preview_hero)}
      {_character_booster_cta()}
    </aside>
  </section>

def _character_mobile_footer() -> HTML(DungeonEvent):
  <div class="character-select-footer">
    {_character_back_button()}
  </div>

def _character_detail_panel(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <section class="character-detail">
    <div class="character-detail__layout">
      {_character_detail_portrait(hero_value)}
      {_character_info_column(meta_state, preview_hero, hero_value, profile, presentation)}
    </div>
  </section>

def _character_detail_portrait(hero_value: HeroDef) -> HTML(DungeonEvent):
  <div class="character-detail__portrait">
    <img class="character-detail__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
  </div>

def _character_info_column(meta_state: Meta, preview_hero: U32, hero_value: HeroDef, profile: HeroProfile, presentation: HeroPresentation) -> HTML(DungeonEvent):
  <div class="character-detail__info">
    <div class="character-detail__stack">
      {_character_detail_name(hero_value)}
      {_character_detail_lore(presentation)}
      {_character_stats_row(hero_value, profile)}
      {_character_locked_slot(profile)}
      {_character_ultimate_slot(presentation)}
      {_character_upgrade_slot(meta_state, hero_value, profile)}
    </div>
  </div>

def _character_detail_name(hero_value: HeroDef) -> HTML(DungeonEvent):
  <div class="character-detail__name-outline">
    {Text.h2(DungeonEvent, left{}, hero_name(hero_value), [])}
  </div>

def _character_detail_lore(presentation: HeroPresentation) -> HTML(DungeonEvent):
  <div class="character-detail__lore">
    {Text.body(DungeonEvent, left{}, hero_presentation_lore(presentation), [])}
  </div>

def _character_stats_row(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <div class="character-detail__stats">
    <p class="character-detail__stat">{text{hero_level_progress_text(hero_value, profile)}}</p>
    <p class="character-detail__stat">{text{Content.stat_hp() ++ " " ++ hero_base_hp_text(hero_value)}}</p>
  </div>

def _character_locked_badge(profile: HeroProfile) -> HTML(DungeonEvent):
  match profile_unlocked(profile):
    case 0:
      <p class="character-detail__locked">{text{Content.ui_character_locked()}}</p>
    case _:
      text{""}

def _character_locked_slot(profile: HeroProfile) -> HTML(DungeonEvent):
  match profile_unlocked(profile):
    case 0:
      <div class="character-detail__lock-slot">
        {_character_locked_badge(profile)}
      </div>
    case _:
      text{""}

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

def _character_ultimate_slot(presentation: HeroPresentation) -> HTML(DungeonEvent):
  <div class="character-detail__ultimate-slot">
    {_character_ultimate_block(presentation)}
  </div>

def _character_upgrade_block(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  match profile_unlocked(profile):
    case 0:
      text{""}
    case _:
      _character_upgrade_content(meta_state, hero_value, profile, character_upgrade_maxed(hero_value, profile))

def _character_upgrade_slot(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  match profile_unlocked(profile):
    case 0:
      text{""}
    case _:
      <div class="character-detail__upgrade-slot">
        {_character_upgrade_content(meta_state, hero_value, profile, character_upgrade_maxed(hero_value, profile))}
      </div>

def _character_upgrade_content(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile, maxed: U32) -> HTML(DungeonEvent):
  match maxed:
    case 0:
      <section class="character-upgrade">
        <div class="character-upgrade__row">
          <div class="character-upgrade__action">
            {_character_upgrade_button(meta_state, hero_value, profile)}
          </div>
          <p class="character-upgrade__price">
            <img class="character-upgrade__price-icon" src={_gold_icon()} alt={Content.ui_topbar_gold()} />
            <span class="character-upgrade__price-value">{text{character_upgrade_price_text(hero_value, profile)}}</span>
          </p>
        </div>
      </section>
    case _:
      <section class="character-upgrade character-upgrade--max">
        <p class="character-upgrade__max">{text{Content.ui_upgrade_max_level_short()}}</p>
      </section>

def _character_roster(meta_state: Meta, preview_hero: U32) -> HTML(DungeonEvent):
  <section class="character-roster">
    <div class="character-roster__grid">
      {..._character_roster_items(meta_state, preview_hero, 0, hero_count(config()))}
    </div>
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
        <span class="character-roster-card__footer">{text{hero_level_ratio_text(hero_value, profile)}}</span>
      </span>,
      [padding_none{}]
    )}
  </button>

def _character_equipped(meta_state: Meta, hero_ref: U32) -> U32:
  match selection_confirmed(meta_state):
    case 0:
      0
    case _:
      selected_hero(meta_state) === hero_ref

def _character_roster_card_class(meta_state: Meta, preview_hero: U32, hero_ref: U32, profile: HeroProfile) -> String:
  "character-roster-card"
  ++ _character_roster_card_locked_modifier(profile)
  ++ _character_roster_card_selected_modifier(meta_state, hero_ref, profile)
  ++ _character_roster_card_active_modifier(preview_hero === hero_ref)

def _character_roster_card_locked_modifier(profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      " character-roster-card--locked"
    case _:
      ""

def _character_roster_card_selected_modifier(meta_state: Meta, hero_ref: U32, profile: HeroProfile) -> String:
  match profile_unlocked(profile):
    case 0:
      ""
    case _:
      _character_roster_card_selected_state(_character_equipped(meta_state, hero_ref))

def _character_roster_card_selected_state(selected: U32) -> String:
  match selected:
    case 0:
      ""
    case _:
      " character-roster-card--selected"

def _character_roster_card_active_modifier(active: U32) -> String:
  match active:
    case 0:
      ""
    case _:
      " character-roster-card--active"

def _character_booster_cta() -> HTML(DungeonEvent):
  <section class="character-boosters">
    <p class="character-boosters__hint">{text{Content.ui_character_booster_hint()}}</p>
    <div class="character-boosters__action">
      {_character_booster_button()}
    </div>
  </section>

def _menu_home(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="menu-home">
    <div class="menu-home__hero">
      {_menu_hero_panel_desktop(hero_value, profile)}
      {_menu_hero_panel_mobile(hero_value, profile)}
      {_menu_upgrade_overlay(meta_state, hero_value, profile)}
    </div>
  </section>

def _menu_hero_panel_desktop(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <button class="menu-hero-panel menu-hero-panel--desktop" type="button" on_click={open_character_select{}}>
    {_menu_home_info(hero_value, profile)}
    {_menu_home_portrait(hero_value)}
  </button>

def _menu_hero_panel_mobile(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <section class="menu-hero-panel menu-hero-panel--mobile">
    {_menu_home_info(hero_value, profile)}
    {_menu_home_portrait(hero_value)}
  </section>

def _menu_home_info(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <div class="menu-home-info">
    <div class="menu-home-info__default menu-home-info__default--hud">
      {_menu_home_hud(hero_value, profile)}
    </div>
    <div class="menu-home-info__change">
      <span class="menu-home-info__change-label">{text{"CHANGE HERO"}}</span>
    </div>
  </div>

def _menu_home_hud(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  <div class="hero-hud hero-hud--menu-home">
    <div class="hero-hud__level">
      {Text.label(DungeonEvent, left{}, hero_menu_level_text(profile), [])}
    </div>
    <div class="hero-hud__hp">
      <div class="hero-hud__heart">
        <img class="hero-hud__heart-image" src="assets/icon_heart.png" alt="" />
        <span class="hero-hud__heart-value">{text{U32.show(hero_base_max_hp(hero_value))}}</span>
      </div>
    </div>
  </div>

def _menu_home_portrait(hero_value: HeroDef) -> HTML(DungeonEvent):
  <div class="menu-hero-panel__portrait">
    <img class="menu-hero-panel__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
  </div>

def _menu_upgrade_overlay(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  match menu_upgrade_visible(meta_state, hero_value, profile):
    case 1:
      <div class="menu-home__upgrade">
        {_menu_upgrade_button(hero_value, profile)}
      </div>
    case _:
      text{""}

def _menu_start_button() -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    start{},
    large{},
    Content.ui_menu_start(),
    _full_button_overrides(start_enabled(setup{}))
  )

def _menu_boosters_button(meta_state: Meta) -> HTML(DungeonEvent):
  <button class="bc-btn bc-btn-secondary bc-btn-rounded bc-btn-medium bc-btn-full menu-booster-cta" type="button" on_click={open_boosters{}}>
    <span class="bc-btn-content">
      <span class="bc-btn-label">{text{Content.ui_menu_boosters()}}</span>
    </span>
    <span class="menu-booster-cta__count">{text{meta_pack_total(meta_state)}}</span>
  </button>

def _menu_deck_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    ignore{},
    medium{},
    "DECK",
    _full_button_overrides(0)
  )

def _menu_upgrade_button(hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_character_select{},
    medium{},
    menu_upgrade_label(hero_value, profile),
    _fit_button_overrides(1)
  )

def _character_upgrade_button(meta_state: Meta, hero_value: HeroDef, profile: HeroProfile) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    upgrade{},
    medium{},
    Content.ui_upgrade_upgrade(),
    _action_button_overrides(character_upgrade_enabled(meta_state, hero_value, profile))
  )

def _character_booster_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_boosters{},
    medium{},
    Content.ui_menu_boosters(),
    _full_button_overrides(1)
  )

def _character_back_button() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    close_character_select{},
    medium{},
    Content.ui_menu_back(),
    _fit_button_overrides(1)
  )

def _header_characters_action() -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_character_select{},
    small{},
    Content.ui_menu_characters(),
    _fit_button_overrides(1)
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

def _action_button_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [state_disabled{}]
    case _:
      []
