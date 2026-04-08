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
import /Dungeon/View/selectors/booster_prev_enabled as booster_prev_enabled
import /Dungeon/View/selectors/booster_next_enabled as booster_next_enabled
import /Dungeon/View/selectors/booster_reward_position_text as booster_reward_position_text
import /Dungeon/View/menu/_full_button_overrides as _full_button_overrides
import /Dungeon/View/menu/_fit_button_overrides as _fit_button_overrides
import /Dungeon/View/assets_and_labels/_card_name as _card_name
import /Dungeon/View/assets_and_labels/_card_sprite as _card_sprite
import /Dungeon/View/assets_and_labels/_card_stat as _card_stat
import /Midum/Button/ as Button
import /Midum/Button/Size

def _render_boosters(meta_state: Meta, reward: PackReward, reveal_index: U32) -> HTML(DungeonEvent):
  <section class="shell shell--boosters">
    {_boosters_header(meta_state)}
    <section class="boosters-stage">
      <div class="boosters-stage__content">
        {_booster_visual(reward, reveal_index)}
        <div class="boosters-stage__open">
          {_open_button(meta_state)}
        </div>
        <p class="boosters-stage__price">{text{"GOLD: " ++ U32.show(active_pack_price())}}</p>
        <div class="boosters-stage__buy">
          {_buy_button(meta_state)}
        </div>
      </div>
    </section>
  </section>

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

def _booster_visual(reward: PackReward, reveal_index: U32) -> HTML(DungeonEvent):
  match reward:
    case no_pack_reward{}:
      <div class="booster-visual booster-visual--pack">
        <img class="booster-visual__pack-img" src="assets/booster-pack.png" alt="Booster Pack" />
      </div>
    case pack_reward{cards}:
      <div class="booster-visual booster-visual--revealed">
        {_reward_detail(_reward_card_at(cards, reveal_index))}
        <div class="booster-visual__nav">
          {_reward_nav_button("Prev", prev_reward{}, booster_prev_enabled(reveal_index))}
          <p class="booster-visual__index">{text{booster_reward_position_text(reward, reveal_index)}}</p>
          {_reward_nav_button("Next", next_reward{}, booster_next_enabled(reward, reveal_index))}
        </div>
      </div>

def _reward_card_at(cards: List(CardRef), idx: U32) -> CardRef:
  match cards:
    case []:
      hero_card{}
    case card<>rest:
      match idx:
        case 0:
          card
        case _:
          _reward_card_at(rest, idx - 1)

def _reward_detail(card: CardRef) -> HTML(DungeonEvent):
  <div class="booster-visual__detail">
    <div class="booster-visual__image-wrap">
      <img class="booster-visual__image" src={_card_sprite(card)} alt={_card_name(card)} />
    </div>
    <p class="booster-visual__stat">{text{_card_stat(card)}}</p>
  </div>

def _reward_nav_button(label: String, evt: DungeonEvent, enabled: U32) -> HTML(DungeonEvent):
  Button.secondary(DungeonEvent, evt, medium{}, label, _fit_button_overrides(enabled))

def _back_button() -> HTML(DungeonEvent):
  Button.secondary(DungeonEvent, close_boosters{}, medium{}, "Back", [])

def _buy_button(meta_state: Meta) -> HTML(DungeonEvent):
  Button.primary(
    DungeonEvent,
    buy_pack{0},
    large{},
    "Buy",
    _full_button_overrides(booster_buy_enabled(meta_state))
  )

def _open_button(meta_state: Meta) -> HTML(DungeonEvent):
  Button.secondary(
    DungeonEvent,
    open_pack{0},
    medium{},
    "Open",
    _fit_button_overrides(booster_open_enabled(meta_state))
  )
