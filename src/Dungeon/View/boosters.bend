import /HTML/
import /U32/ as U32
import /Dungeon/CardRef as CardRef
import /Dungeon/Meta as Meta
import /Dungeon/PackReward as PackReward
import /Dungeon/DungeonEvent as DungeonEvent
import /Dungeon/View/selectors/meta_gold as meta_gold
import /Dungeon/View/selectors/meta_pack_total as meta_pack_total
import /Dungeon/View/selectors/active_pack_price as active_pack_price
import /Dungeon/View/selectors/booster_buy_enabled as booster_buy_enabled
import /Dungeon/View/selectors/booster_open_enabled as booster_open_enabled
import /Dungeon/View/selectors/booster_is_last_card as booster_is_last_card
import /Dungeon/View/selectors/card_copies as card_copies
import /Dungeon/View/menu/_full_button_overrides as _full_button_overrides
import /Dungeon/View/menu/_fit_button_overrides as _fit_button_overrides
import /Dungeon/View/assets_and_labels/_card_name as _card_name
import /Dungeon/View/assets_and_labels/_card_sprite as _card_sprite
import /Dungeon/View/assets_and_labels/_card_stat_range as _card_stat_range
import /Midum/Card/ as Card
import /Midum/Button/ as Button
import /Midum/Button/Size

def _render_boosters(meta_state: Meta, reward: PackReward, reveal_index: U32) -> HTML(DungeonEvent):
  match reward:
    case no_pack_reward{}:
      _render_boosters_idle(meta_state)
    case pack_reward{cards}:
      _render_boosters_reveal(meta_state, pack_reward{cards}, reveal_index)

def _render_boosters_idle(meta_state: Meta) -> HTML(DungeonEvent):
  <section class="shell shell--boosters">
    {_boosters_header(meta_state)}
    <section class="boosters-stage">
      <div class="boosters-stage__content">
        <div class="booster-visual booster-visual--pack">
          <img class="booster-visual__pack-img" src="assets/booster-pack.png" alt="Booster Pack" />
        </div>
      </div>
    </section>
    <section class="boosters-actions">
      {_booster_actions(meta_state)}
    </section>
  </section>

def _render_boosters_reveal(meta_state: Meta, reward: PackReward, reveal_index: U32) -> HTML(DungeonEvent):
  card = _reward_card_at(reward, reveal_index);
  <section class="shell shell--boosters-reveal">
    <div class="boosters-reveal__top-spacer"></div>
    <section class="boosters-stage boosters-stage--reveal">
      <div class="boosters-stage__content boosters-stage__content--reveal">
        <div class="booster-reveal-panel">
          <div class="booster-reveal-panel__visual">
            {_reveal_card(card)}
          </div>
          <div class="booster-reveal-panel__meta">
            {_reveal_meta(meta_state, card)}
          </div>
          <div class="booster-reveal-panel__footer">
            <div class="booster-reveal-panel__action">
              {_reveal_action_button(reward, reveal_index)}
            </div>
          </div>
        </div>
      </div>
    </section>
  </section>

def _reveal_meta(meta_state: Meta, card: CardRef) -> HTML(DungeonEvent):
  <div class="reveal-meta">
    <div class="reveal-meta__top">
      <p class="reveal-name">{text{_card_name(card)}}</p>
      <p class="reveal-copies">{text{"COPIES: " ++ card_copies(meta_state, card)}}</p>
    </div>
    {_reveal_stat_left(card)}
  </div>

def _reveal_stat_left(card: CardRef) -> HTML(DungeonEvent):
  match card:
    case hero_card{}:
      <span class="reveal-stat--empty"></span>
    case _:
      <p class="reveal-stat reveal-stat--detail">{text{_card_stat_range(card)}}</p>

def _reveal_card(card: CardRef) -> HTML(DungeonEvent):
  <div class="booster-visual booster-visual--revealed booster-visual--midum">
    {Card.neutral(
      DungeonEvent,
      <div class="booster-visual__detail booster-visual__detail--midum">
        <div class="booster-visual__image-wrap">
          <img class="booster-visual__image booster-visual__image--midum" src={_card_sprite(card)} alt={_card_name(card)} />
        </div>
      </div>,
      _reveal_card_surface_overrides()
    )}
  </div>

def _reveal_card_surface_overrides() -> List(Midum/Card/Override):
  [
    padding_none{},
    background_none{},
    border_none{},
    radius_square{},
    surface_image_sized{
      src: "assets/background-card.png",
      source_left: U32.to_nat(34),
      source_right: U32.to_nat(34),
      source_top: U32.to_nat(34),
      source_bottom: U32.to_nat(34),
      target_left: U32.to_nat(22),
      target_right: U32.to_nat(22),
      target_top: U32.to_nat(22),
      target_bottom: U32.to_nat(22),
    }
  ]

def _reveal_action_button(reward: PackReward, reveal_index: U32) -> HTML(DungeonEvent):
  match booster_is_last_card(reward, reveal_index):
    case 1:
      Button.neutral(DungeonEvent, done_reward{}, medium{}, "Done", [])
    case _:
      Button.neutral(DungeonEvent, next_reward{}, medium{}, "Next", [])

def _reward_card_at(reward: PackReward, idx: U32) -> CardRef:
  match reward:
    case no_pack_reward{}:
      hero_card{}
    case pack_reward{cards}:
      _card_at(cards, idx)

def _card_at(cards: List(CardRef), idx: U32) -> CardRef:
  match cards:
    case []:
      hero_card{}
    case card<>rest:
      match idx:
        case 0:
          card
        case _:
          _card_at(rest, idx - 1)

def _boosters_header(meta_state: Meta) -> HTML(DungeonEvent):
  <header class="topbar topbar--boosters">
    <div class="topbar__back">
      {_back_button()}
    </div>
    <div class="topbar__stats">
      {_topbar_stat("Gold", meta_gold(meta_state))}
      {_topbar_stat("Boosters", meta_pack_total(meta_state))}
    </div>
  </header>

def _topbar_stat(label: String, value: String) -> HTML(DungeonEvent):
  <p class="topbar-stat">
    <span class="topbar-stat__label">{text{label}}</span>
    <strong class="topbar-stat__value">{text{value}}</strong>
  </p>

def _back_button() -> HTML(DungeonEvent):
  Button.secondary(DungeonEvent, close_boosters{}, medium{}, "Back", [])

def _booster_actions(meta_state: Meta) -> HTML(DungeonEvent):
  match booster_open_enabled(meta_state):
    case 1:
      <div class="menu-actions">
        <div class="menu-secondary-action">
          {Button.secondary(DungeonEvent, buy_pack{0}, medium{}, "Buy More - " ++ U32.show(active_pack_price()) ++ "g", _fit_button_overrides(booster_buy_enabled(meta_state)))}
        </div>
        <div class="menu-start-action">
          {Button.primary(DungeonEvent, open_pack{0}, large{}, "Open", _full_button_overrides(1))}
        </div>
      </div>
    case _:
      <div class="menu-actions">
        <div class="menu-start-action">
          {Button.primary(DungeonEvent, buy_pack{0}, large{}, "Buy - " ++ U32.show(active_pack_price()) ++ "g", _full_button_overrides(booster_buy_enabled(meta_state)))}
        </div>
      </div>
