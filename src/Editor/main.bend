import /App/
import /HTML/
import /Editor/EditorData as EditorData
import /Editor/EditorEvent as EditorEvent
import /Editor/EditorState as EditorState
import /Editor/EditorTab as EditorTab
import /Editor/HeroRow as HeroRow
import /Editor/HeroUpgradeRow as HeroUpgradeRow
import /Editor/MonsterRow as MonsterRow
import /Editor/WeaponRow as WeaponRow
import /Editor/PotionRow as PotionRow
import /Editor/DeckRow as DeckRow
import /Editor/PackRow as PackRow
import /Editor/PoolRow as PoolRow
import /Editor/RulesRow as RulesRow
import /Editor/PresentationRow as PresentationRow
import /Editor/generated_data/generated_editor_data as generated_editor_data

init : App/Update(EditorState, EditorEvent) =
  update{editor_state{generated_editor_data(), overview_tab{}, "Editor loaded from data/game and data/presentation.", 0, 0}, none{}}

main : App =
  app{EditorState, EditorEvent, init, view, on_event, none{}}

def on_event(evt: EditorEvent, state: EditorState) -> App/Update(EditorState, EditorEvent):
  match state:
    case editor_state{data, tab, status, saving, building}:
      match evt:
        case select_tab{next_tab}:
          update{editor_state{data, next_tab, status, saving, building}, none{}}
        case reset_data{}:
          update{editor_state{generated_editor_data(), tab, "Reset to the generated data embedded in this editor build.", 0, building}, none{}}
        case save{}:
          update{
            editor_state{data, tab, "Saving JSON and regenerating Bend files...", 1, building},
            http{"PUT", "/api/game-data", "Content-Type: application/json", editor_data_json(data), body => save_ok{body}, body => save_err{body}}
          }
        case save_ok{body}:
          update{editor_state{data, tab, "Save response: " ++ body, 0, building}, none{}}
        case save_err{body}:
          update{editor_state{data, tab, "Save failed: " ++ body, 0, building}, none{}}
        case build_docs{}:
          update{
            editor_state{data, tab, "Building docs/index.html...", saving, 1},
            http{"POST", "/api/build-docs", "", "", body => build_ok{body}, body => build_err{body}}
          }
        case build_ok{body}:
          update{editor_state{data, tab, "Build docs response: " ++ body, saving, 0}, none{}}
        case build_err{body}:
          update{editor_state{data, tab, "Build docs failed: " ++ body, saving, 0}, none{}}
        case update_rule{field, value}:
          update{editor_state{set_rules(data, update_rules(editor_rules(data), field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case update_hero{row, field, value}:
          update{editor_state{set_heroes(data, update_heroes(editor_heroes(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_hero{}:
          update{editor_state{set_heroes(data, add_hero_row(editor_heroes(data))), tab, "New hero row added. Save will validate references before writing.", saving, building}, none{}}
        case update_upgrade{row, field, value}:
          update{editor_state{set_upgrades(data, update_upgrades(editor_upgrades(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_upgrade{}:
          update{editor_state{set_upgrades(data, add_upgrade_row(editor_upgrades(data), first_hero_id(editor_heroes(data)))), tab, "New upgrade row added.", saving, building}, none{}}
        case update_monster{row, field, value}:
          update{editor_state{set_monsters(data, update_monsters(editor_monsters(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case update_monster_hp{row, level, value}:
          update{editor_state{set_monsters(data, update_monster_hps(editor_monsters(data), row, level, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_monster{}:
          update{editor_state{set_monsters(data, add_monster_row(editor_monsters(data))), tab, "New monster row added.", saving, building}, none{}}
        case add_hp_level{}:
          update{editor_state{set_monsters(data, add_hp_level_to_monsters(editor_monsters(data))), tab, "HP level column added to all monsters.", saving, building}, none{}}
        case update_weapon{row, field, value}:
          update{editor_state{set_weapons(data, update_weapons(editor_weapons(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_weapon{}:
          update{editor_state{set_weapons(data, add_weapon_row(editor_weapons(data))), tab, "New weapon row added.", saving, building}, none{}}
        case update_potion{row, field, value}:
          update{editor_state{set_potions(data, update_potions(editor_potions(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_potion{}:
          update{editor_state{set_potions(data, add_potion_row(editor_potions(data))), tab, "New potion row added.", saving, building}, none{}}
        case update_deck{row, field, value}:
          update{editor_state{set_deck(data, update_deck_rows(editor_deck(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_deck{}:
          update{editor_state{set_deck(data, add_deck_row(editor_deck(data), first_card_id(data))), tab, "New base deck row added.", saving, building}, none{}}
        case update_pack{row, field, value}:
          update{editor_state{set_packs(data, update_packs(editor_packs(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_pack{}:
          update{editor_state{set_packs(data, add_pack_row(editor_packs(data))), tab, "New booster pack row added.", saving, building}, none{}}
        case update_pool{row, field, value}:
          update{editor_state{set_pool(data, update_pool_rows(editor_pool(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_pool{}:
          update{editor_state{set_pool(data, add_pool_row(editor_pool(data), first_pack_id(editor_packs(data)), first_card_id(data))), tab, "New booster pool row added.", saving, building}, none{}}
        case update_presentation{row, field, value}:
          update{editor_state{set_presentation(data, update_presentations(editor_presentation(data), row, field, value)), tab, "Unsaved changes.", saving, building}, none{}}
        case add_presentation{}:
          update{editor_state{set_presentation(data, add_presentation_row(editor_presentation(data), first_hero_id(editor_heroes(data)))), tab, "New presentation row added.", saving, building}, none{}}
        case ignore{}:
          update{state, none{}}

def view(state: EditorState) -> HTML(EditorEvent):
  match state:
    case editor_state{data, tab, status, saving, building}:
      <div class="app-shell">
        <link rel="stylesheet" href="/styles.css" />
        <header class="app-header">
          <div>
            <h1>Economy Lever Editor</h1>
            <p>Edit split JSON data as spreadsheet tables.</p>
          </div>
          <div class="actions">
            <button type="button" on_click={reset_data{}}>Reset</button>
            <button type="button" on_click={build_docs{}}>Build docs</button>
            <button type="button" class="primary" on_click={save{}}>Save</button>
          </div>
        </header>
        <div class="status">{text{status}}</div>
        {tabs(tab)}
        {panel(tab, data)}
      </div>

def tabs(current: EditorTab) -> HTML(EditorEvent):
  <nav class="tabs">
    {tab_button(current, overview_tab{}, "Overview")}
    {tab_button(current, rules_tab{}, "Rules")}
    {tab_button(current, heroes_tab{}, "Heroes")}
    {tab_button(current, upgrades_tab{}, "Hero Upgrades")}
    {tab_button(current, monsters_tab{}, "Monsters")}
    {tab_button(current, weapons_tab{}, "Weapons")}
    {tab_button(current, potions_tab{}, "Potions")}
    {tab_button(current, deck_tab{}, "Base Deck")}
    {tab_button(current, packs_tab{}, "Booster Packs")}
    {tab_button(current, pool_tab{}, "Booster Pool")}
    {tab_button(current, presentation_tab{}, "Presentation")}
  </nav>

def tab_button(current: EditorTab, next_tab: EditorTab, label: String) -> HTML(EditorEvent):
  tab_button_active(tab_is_active(current, next_tab), next_tab, label)

def tab_button_active(active: U32, next_tab: EditorTab, label: String) -> HTML(EditorEvent):
  match active:
    case 0:
      <button type="button" class="tab" on_click={select_tab{next_tab}}>{text{label}}</button>
    case _:
      <button type="button" class="tab active" on_click={select_tab{next_tab}}>{text{label}}</button>

def tab_is_active(current: EditorTab, next_tab: EditorTab) -> U32:
  match current:
    case overview_tab{}:
      match next_tab:
        case overview_tab{}:
          1
        case _:
          0
    case rules_tab{}:
      match next_tab:
        case rules_tab{}:
          1
        case _:
          0
    case heroes_tab{}:
      match next_tab:
        case heroes_tab{}:
          1
        case _:
          0
    case upgrades_tab{}:
      match next_tab:
        case upgrades_tab{}:
          1
        case _:
          0
    case monsters_tab{}:
      match next_tab:
        case monsters_tab{}:
          1
        case _:
          0
    case weapons_tab{}:
      match next_tab:
        case weapons_tab{}:
          1
        case _:
          0
    case potions_tab{}:
      match next_tab:
        case potions_tab{}:
          1
        case _:
          0
    case deck_tab{}:
      match next_tab:
        case deck_tab{}:
          1
        case _:
          0
    case packs_tab{}:
      match next_tab:
        case packs_tab{}:
          1
        case _:
          0
    case pool_tab{}:
      match next_tab:
        case pool_tab{}:
          1
        case _:
          0
    case presentation_tab{}:
      match next_tab:
        case presentation_tab{}:
          1
        case _:
          0

def tab_key(tab: EditorTab) -> String:
  match tab:
    case overview_tab{}:
      "overview"
    case rules_tab{}:
      "rules"
    case heroes_tab{}:
      "heroes"
    case upgrades_tab{}:
      "upgrades"
    case monsters_tab{}:
      "monsters"
    case weapons_tab{}:
      "weapons"
    case potions_tab{}:
      "potions"
    case deck_tab{}:
      "deck"
    case packs_tab{}:
      "packs"
    case pool_tab{}:
      "pool"
    case presentation_tab{}:
      "presentation"

def panel(tab: EditorTab, data: EditorData) -> HTML(EditorEvent):
  match tab:
    case overview_tab{}:
      overview_panel(data)
    case rules_tab{}:
      rules_panel(editor_rules(data))
    case heroes_tab{}:
      heroes_panel(editor_heroes(data))
    case upgrades_tab{}:
      upgrades_panel(editor_upgrades(data))
    case monsters_tab{}:
      monsters_panel(editor_monsters(data))
    case weapons_tab{}:
      weapons_panel(editor_weapons(data))
    case potions_tab{}:
      potions_panel(editor_potions(data))
    case deck_tab{}:
      deck_panel(editor_deck(data))
    case packs_tab{}:
      packs_panel(editor_packs(data))
    case pool_tab{}:
      pool_panel(editor_pool(data))
    case presentation_tab{}:
      presentation_panel(editor_presentation(data))

def overview_panel(data: EditorData) -> HTML(EditorEvent):
  <main class="panel">
    <div class="panel-header">
      <div>
        <h2>Overview</h2>
        <p>Current editable economy levers grouped by JSON domain.</p>
      </div>
    </div>
    <div class="grid">
      {metric("Heroes", U32.show(hero_count(editor_heroes(data))))}
      {metric("Hero upgrades", U32.show(upgrade_count(editor_upgrades(data))))}
      {metric("Monsters", U32.show(monster_count(editor_monsters(data))))}
      {metric("Weapons", U32.show(weapon_count(editor_weapons(data))))}
      {metric("Potions", U32.show(potion_count(editor_potions(data))))}
      {metric("Deck rows", U32.show(deck_count(editor_deck(data))))}
      {metric("Booster packs", U32.show(pack_count(editor_packs(data))))}
      {metric("Booster pool rows", U32.show(pool_count(editor_pool(data))))}
    </div>
    <p class="note">Existing row IDs are locked. Additions go to the end, preserving save compatibility.</p>
  </main>

def metric(label: String, value: String) -> HTML(EditorEvent):
  <div class="metric">
    <strong>{text{value}}</strong>
    <span>{text{label}}</span>
  </div>

def rules_panel(rules: RulesRow) -> HTML(EditorEvent):
  match rules:
    case rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}:
      <main class="panel">
        {panel_header("Rules", "Global run and economy rules promoted from Bend code.", none{})}
        {table(
          ["initial_seed", "starting_gold", "starting_selected_hero_id", "starting_selection_confirmed", "starting_dungeon_level", "dungeon_level_increment_per_refill", "ultimate_charge_required", "ultimate_charge_per_move"],
          [
            <tr>
              {td_number(initial_seed, value => update_rule{0, value})}
              {td_number(starting_gold, value => update_rule{1, value})}
              {td_text(starting_selected_hero_id, 0, value => update_rule{2, value})}
              {td_number(starting_selection_confirmed, value => update_rule{3, value})}
              {td_number(starting_dungeon_level, value => update_rule{4, value})}
              {td_number(dungeon_level_increment_per_refill, value => update_rule{5, value})}
              {td_number(ultimate_charge_required, value => update_rule{6, value})}
              {td_number(ultimate_charge_per_move, value => update_rule{7, value})}
            </tr>
          ]
        )}
      </main>

def heroes_panel(rows: List(HeroRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Heroes", "Playable characters, unlock cost, initial unlock status, and base HP.", some{add_hero{}})}
    {table(["id", "name", "sprite", "base_max_hp", "unlock_cost", "starts_unlocked"], hero_rows(rows, 0))}
  </main>

def hero_rows(rows: List(HeroRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case hero_row{locked, id, name, sprite, base_max_hp, unlock_cost, starts_unlocked}<>tail:
      <tr>
        {td_text(id, locked, value => update_hero{idx, 0, value})}
        {td_text(name, 0, value => update_hero{idx, 1, value})}
        {td_sprite(sprite, value => update_hero{idx, 2, value})}
        {td_number(base_max_hp, value => update_hero{idx, 3, value})}
        {td_number(unlock_cost, value => update_hero{idx, 4, value})}
        {td_number(starts_unlocked, value => update_hero{idx, 5, value})}
      </tr> <> hero_rows(tail, idx + 1)

def upgrades_panel(rows: List(HeroUpgradeRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Hero Upgrades", "Upgrade rows by hero and level. Levels should stay contiguous for each hero.", some{add_upgrade{}})}
    {table(["hero_id", "level", "cost", "max_hp"], upgrade_rows(rows, 0))}
  </main>

def upgrade_rows(rows: List(HeroUpgradeRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case hero_upgrade_row{locked, hero_id, level, cost, max_hp}<>tail:
      <tr>
        {td_text(hero_id, locked, value => update_upgrade{idx, 0, value})}
        {td_number(level, value => update_upgrade{idx, 1, value})}
        {td_number(cost, value => update_upgrade{idx, 2, value})}
        {td_number(max_hp, value => update_upgrade{idx, 3, value})}
      </tr> <> upgrade_rows(tail, idx + 1)

def monsters_panel(rows: List(MonsterRow)) -> HTML(EditorEvent):
  <main class="panel">
    <div class="panel-header">
      <div>
        <h2>Monsters</h2>
        <p>Gold drop and HP by dungeon level.</p>
      </div>
      <div class="toolbar">
        <button type="button" on_click={add_hp_level{}}>Add HP level</button>
        <button type="button" on_click={add_monster{}}>Add row</button>
      </div>
    </div>
    {table(monster_headers(rows), monster_rows(rows, 0))}
  </main>

def monster_headers(rows: List(MonsterRow)) -> List(String):
  List/append(String, ["id", "name", "sprite", "gold_drop"], hp_headers(first_hp_levels(rows), 1))

def hp_headers(values: List(U32), level: U32) -> List(String):
  match values:
    case []:
      []
    case _<>tail:
      ("hp_level_" ++ U32.show(level)) <> hp_headers(tail, level + 1)

def monster_rows(rows: List(MonsterRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case monster_row{locked, id, name, sprite, gold_drop, hp_by_level}<>tail:
      <tr>{...List/append(HTML(EditorEvent), [
        td_text(id, locked, value => update_monster{idx, 0, value}),
        td_text(name, 0, value => update_monster{idx, 1, value}),
        td_sprite(sprite, value => update_monster{idx, 2, value}),
        td_number(gold_drop, value => update_monster{idx, 3, value})
      ], hp_cells(idx, hp_by_level, 0))}</tr> <> monster_rows(tail, idx + 1)

def hp_cells(row: U32, values: List(U32), level: U32) -> List(HTML(EditorEvent)):
  match values:
    case []:
      []
    case hp<>tail:
      <td>{number_input(hp, value => update_monster_hp{row, level, value})}</td> <> hp_cells(row, tail, level + 1)

def weapons_panel(rows: List(WeaponRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Weapons", "Sword cards and damage values.", some{add_weapon{}})}
    {table(["id", "name", "sprite", "dmg"], weapon_rows(rows, 0))}
  </main>

def weapon_rows(rows: List(WeaponRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case weapon_row{locked, id, name, sprite, dmg}<>tail:
      <tr>
        {td_text(id, locked, value => update_weapon{idx, 0, value})}
        {td_text(name, 0, value => update_weapon{idx, 1, value})}
        {td_sprite(sprite, value => update_weapon{idx, 2, value})}
        {td_number(dmg, value => update_weapon{idx, 3, value})}
      </tr> <> weapon_rows(tail, idx + 1)

def potions_panel(rows: List(PotionRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Potions", "Potion cards and heal values.", some{add_potion{}})}
    {table(["id", "name", "sprite", "heal"], potion_rows(rows, 0))}
  </main>

def potion_rows(rows: List(PotionRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case potion_row{locked, id, name, sprite, heal}<>tail:
      <tr>
        {td_text(id, locked, value => update_potion{idx, 0, value})}
        {td_text(name, 0, value => update_potion{idx, 1, value})}
        {td_sprite(sprite, value => update_potion{idx, 2, value})}
        {td_number(heal, value => update_potion{idx, 3, value})}
      </tr> <> potion_rows(tail, idx + 1)

def deck_panel(rows: List(DeckRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Base Deck", "Base deck composition. The hero row remains structural and protected.", some{add_deck{}})}
    {table(["card_id", "count"], deck_rows(rows, 0))}
    <p class="note">Keep exactly one hero row with a positive count.</p>
  </main>

def deck_rows(rows: List(DeckRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case deck_row{locked, card_id, count}<>tail:
      <tr>
        {td_text(card_id, locked, value => update_deck{idx, 0, value})}
        {td_number(count, value => update_deck{idx, 1, value})}
      </tr> <> deck_rows(tail, idx + 1)

def packs_panel(rows: List(PackRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Booster Packs", "Pack price, reveal count, and duplicate rule.", some{add_pack{}})}
    {table(["id", "name", "price", "reveal_count", "allow_duplicates"], pack_rows(rows, 0))}
  </main>

def pack_rows(rows: List(PackRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case pack_row{locked, id, name, price, reveal_count, allow_duplicates}<>tail:
      <tr>
        {td_text(id, locked, value => update_pack{idx, 0, value})}
        {td_text(name, 0, value => update_pack{idx, 1, value})}
        {td_number(price, value => update_pack{idx, 2, value})}
        {td_number(reveal_count, value => update_pack{idx, 3, value})}
        {td_number(allow_duplicates, value => update_pack{idx, 4, value})}
      </tr> <> pack_rows(tail, idx + 1)

def pool_panel(rows: List(PoolRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Booster Pool", "Weighted card pool entries by pack ID.", some{add_pool{}})}
    {table(["pack_id", "card_id", "weight"], pool_rows(rows, 0))}
  </main>

def pool_rows(rows: List(PoolRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case pool_row{locked, pack_id, card_id, weight}<>tail:
      <tr>
        {td_text(pack_id, locked, value => update_pool{idx, 0, value})}
        {td_text(card_id, locked, value => update_pool{idx, 1, value})}
        {td_number(weight, value => update_pool{idx, 2, value})}
      </tr> <> pool_rows(tail, idx + 1)

def presentation_panel(rows: List(PresentationRow)) -> HTML(EditorEvent):
  <main class="panel">
    {panel_header("Presentation", "Hero presentation fields kept separate from balance data.", some{add_presentation{}})}
    {table(["hero_id", "name_align", "ultimate_title", "ultimate_icon", "ultimate_description"], presentation_rows(rows, 0))}
  </main>

def presentation_rows(rows: List(PresentationRow), idx: U32) -> List(HTML(EditorEvent)):
  match rows:
    case []:
      []
    case presentation_row{locked, hero_id, name_align, ultimate_title, ultimate_icon, ultimate_description}<>tail:
      <tr>
        {td_text(hero_id, locked, value => update_presentation{idx, 0, value})}
        {td_text(name_align, 0, value => update_presentation{idx, 1, value})}
        {td_text(ultimate_title, 0, value => update_presentation{idx, 2, value})}
        {td_sprite(ultimate_icon, value => update_presentation{idx, 3, value})}
        {td_area(ultimate_description, value => update_presentation{idx, 4, value})}
      </tr> <> presentation_rows(tail, idx + 1)

def panel_header(title: String, description: String, add_event: Maybe(EditorEvent)) -> HTML(EditorEvent):
  <div class="panel-header">
    <div>
      <h2>{text{title}}</h2>
      <p>{text{description}}</p>
    </div>
    {add_button(add_event)}
  </div>

def add_button(add_event: Maybe(EditorEvent)) -> HTML(EditorEvent):
  match add_event:
    case none{}:
      <div></div>
    case some{event}:
      <div class="toolbar"><button type="button" on_click={event}>Add row</button></div>

def table(headers: List(String), rows: List(HTML(EditorEvent))) -> HTML(EditorEvent):
  <div class="table-wrap">
    <table>
      <thead><tr>{...header_cells(headers)}</tr></thead>
      <tbody>{...rows}</tbody>
    </table>
  </div>

def header_cells(headers: List(String)) -> List(HTML(EditorEvent)):
  match headers:
    case []:
      []
    case header<>tail:
      <th>{text{header}}</th> <> header_cells(tail)

def td_text(value: String, locked: U32, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  <td>{text_input(value, locked, on_change)}</td>

def td_area(value: String, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  <td><textarea on_input={on_change}>{text{value}}</textarea></td>

def td_number(value: U32, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  <td>{number_input(value, on_change)}</td>

def td_sprite(value: String, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  <td>
    <div class="sprite-cell">
      {text_input(value, 0, on_change)}
      <img class="sprite-preview" src={value} alt="" />
    </div>
  </td>

def text_input(value: String, locked: U32, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  match locked:
    case 1:
      <input type="text" value={value} disabled="disabled" />
    case _:
      <input type="text" value={value} on_input={on_change} />

def number_input(value: U32, on_change: String -> EditorEvent) -> HTML(EditorEvent):
  <input type="number" min="0" value={U32.show(value)} on_input={on_change} />

def parse_u32_or(current: U32, value: String) -> U32:
  match String/to_u32(value):
    case some{next}:
      next
    case none{}:
      current

def parse_boolish(current: U32, value: String) -> U32:
  match String/to_u32(value):
    case some{parsed}:
      boolish_from_u32(parsed)
    case none{}:
      current

def boolish_from_u32(value: U32) -> U32:
  match value:
    case 0:
      0
    case _:
      1

def editor_heroes(data: EditorData) -> List(HeroRow):
  match data:
    case editor_data{heroes, _, _, _, _, _, _, _, _, _}:
      heroes

def editor_upgrades(data: EditorData) -> List(HeroUpgradeRow):
  match data:
    case editor_data{_, upgrades, _, _, _, _, _, _, _, _}:
      upgrades

def editor_monsters(data: EditorData) -> List(MonsterRow):
  match data:
    case editor_data{_, _, monsters, _, _, _, _, _, _, _}:
      monsters

def editor_weapons(data: EditorData) -> List(WeaponRow):
  match data:
    case editor_data{_, _, _, weapons, _, _, _, _, _, _}:
      weapons

def editor_potions(data: EditorData) -> List(PotionRow):
  match data:
    case editor_data{_, _, _, _, potions, _, _, _, _, _}:
      potions

def editor_deck(data: EditorData) -> List(DeckRow):
  match data:
    case editor_data{_, _, _, _, _, deck, _, _, _, _}:
      deck

def editor_packs(data: EditorData) -> List(PackRow):
  match data:
    case editor_data{_, _, _, _, _, _, packs, _, _, _}:
      packs

def editor_pool(data: EditorData) -> List(PoolRow):
  match data:
    case editor_data{_, _, _, _, _, _, _, pool, _, _}:
      pool

def editor_rules(data: EditorData) -> RulesRow:
  match data:
    case editor_data{_, _, _, _, _, _, _, _, rules, _}:
      rules

def editor_presentation(data: EditorData) -> List(PresentationRow):
  match data:
    case editor_data{_, _, _, _, _, _, _, _, _, presentation}:
      presentation

def set_heroes(data: EditorData, next: List(HeroRow)) -> EditorData:
  match data:
    case editor_data{_, upgrades, monsters, weapons, potions, deck, packs, pool, rules, presentation}:
      editor_data{next, upgrades, monsters, weapons, potions, deck, packs, pool, rules, presentation}

def set_upgrades(data: EditorData, next: List(HeroUpgradeRow)) -> EditorData:
  match data:
    case editor_data{heroes, _, monsters, weapons, potions, deck, packs, pool, rules, presentation}:
      editor_data{heroes, next, monsters, weapons, potions, deck, packs, pool, rules, presentation}

def set_monsters(data: EditorData, next: List(MonsterRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, _, weapons, potions, deck, packs, pool, rules, presentation}:
      editor_data{heroes, upgrades, next, weapons, potions, deck, packs, pool, rules, presentation}

def set_weapons(data: EditorData, next: List(WeaponRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, _, potions, deck, packs, pool, rules, presentation}:
      editor_data{heroes, upgrades, monsters, next, potions, deck, packs, pool, rules, presentation}

def set_potions(data: EditorData, next: List(PotionRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, _, deck, packs, pool, rules, presentation}:
      editor_data{heroes, upgrades, monsters, weapons, next, deck, packs, pool, rules, presentation}

def set_deck(data: EditorData, next: List(DeckRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, _, packs, pool, rules, presentation}:
      editor_data{heroes, upgrades, monsters, weapons, potions, next, packs, pool, rules, presentation}

def set_packs(data: EditorData, next: List(PackRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, deck, _, pool, rules, presentation}:
      editor_data{heroes, upgrades, monsters, weapons, potions, deck, next, pool, rules, presentation}

def set_pool(data: EditorData, next: List(PoolRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, _, rules, presentation}:
      editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, next, rules, presentation}

def set_rules(data: EditorData, next: RulesRow) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, pool, _, presentation}:
      editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, pool, next, presentation}

def set_presentation(data: EditorData, next: List(PresentationRow)) -> EditorData:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, pool, rules, _}:
      editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, pool, rules, next}

def update_rules(rules: RulesRow, field: U32, value: String) -> RulesRow:
  match rules:
    case rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}:
      match field:
        case 0:
          rules_row{parse_u32_or(initial_seed, value), starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}
        case 1:
          rules_row{initial_seed, parse_u32_or(starting_gold, value), starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}
        case 2:
          rules_row{initial_seed, starting_gold, value, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}
        case 3:
          rules_row{initial_seed, starting_gold, starting_selected_hero_id, parse_boolish(starting_selection_confirmed, value), starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}
        case 4:
          rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, parse_u32_or(starting_dungeon_level, value), dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}
        case 5:
          rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, parse_u32_or(dungeon_level_increment_per_refill, value), ultimate_charge_required, ultimate_charge_per_move}
        case 6:
          rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, parse_u32_or(ultimate_charge_required, value), ultimate_charge_per_move}
        case _:
          rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, parse_u32_or(ultimate_charge_per_move, value)}

def update_heroes(rows: List(HeroRow), row: U32, field: U32, value: String) -> List(HeroRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_hero_row(current, field, value) <> tail
        case _:
          current <> update_heroes(tail, row - 1, field, value)

def update_hero_row(row: HeroRow, field: U32, value: String) -> HeroRow:
  match row:
    case hero_row{locked, id, name, sprite, base_max_hp, unlock_cost, starts_unlocked}:
      match field:
        case 0:
          hero_row{locked, value, name, sprite, base_max_hp, unlock_cost, starts_unlocked}
        case 1:
          hero_row{locked, id, value, sprite, base_max_hp, unlock_cost, starts_unlocked}
        case 2:
          hero_row{locked, id, name, value, base_max_hp, unlock_cost, starts_unlocked}
        case 3:
          hero_row{locked, id, name, sprite, parse_u32_or(base_max_hp, value), unlock_cost, starts_unlocked}
        case 4:
          hero_row{locked, id, name, sprite, base_max_hp, parse_u32_or(unlock_cost, value), starts_unlocked}
        case _:
          hero_row{locked, id, name, sprite, base_max_hp, unlock_cost, parse_boolish(starts_unlocked, value)}

def add_hero_row(rows: List(HeroRow)) -> List(HeroRow):
  n = hero_count(rows) + 1;
  List/append(HeroRow, rows, [hero_row{0, "new_hero_" ++ U32.show(n), "New Hero", "assets/player-boy.png", 10, 0, 0}])

def update_upgrades(rows: List(HeroUpgradeRow), row: U32, field: U32, value: String) -> List(HeroUpgradeRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_upgrade_row(current, field, value) <> tail
        case _:
          current <> update_upgrades(tail, row - 1, field, value)

def update_upgrade_row(row: HeroUpgradeRow, field: U32, value: String) -> HeroUpgradeRow:
  match row:
    case hero_upgrade_row{locked, hero_id, level, cost, max_hp}:
      match field:
        case 0:
          hero_upgrade_row{locked, value, level, cost, max_hp}
        case 1:
          hero_upgrade_row{locked, hero_id, parse_u32_or(level, value), cost, max_hp}
        case 2:
          hero_upgrade_row{locked, hero_id, level, parse_u32_or(cost, value), max_hp}
        case _:
          hero_upgrade_row{locked, hero_id, level, cost, parse_u32_or(max_hp, value)}

def add_upgrade_row(rows: List(HeroUpgradeRow), hero_id: String) -> List(HeroUpgradeRow):
  List/append(HeroUpgradeRow, rows, [hero_upgrade_row{0, hero_id, 1, 10, 10}])

def update_monsters(rows: List(MonsterRow), row: U32, field: U32, value: String) -> List(MonsterRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_monster_row(current, field, value) <> tail
        case _:
          current <> update_monsters(tail, row - 1, field, value)

def update_monster_row(row: MonsterRow, field: U32, value: String) -> MonsterRow:
  match row:
    case monster_row{locked, id, name, sprite, gold_drop, hp_by_level}:
      match field:
        case 0:
          monster_row{locked, value, name, sprite, gold_drop, hp_by_level}
        case 1:
          monster_row{locked, id, value, sprite, gold_drop, hp_by_level}
        case 2:
          monster_row{locked, id, name, value, gold_drop, hp_by_level}
        case _:
          monster_row{locked, id, name, sprite, parse_u32_or(gold_drop, value), hp_by_level}

def update_monster_hps(rows: List(MonsterRow), row: U32, level: U32, value: String) -> List(MonsterRow):
  match rows:
    case []:
      []
    case monster_row{locked, id, name, sprite, gold_drop, hp_by_level}<>tail:
      match row:
        case 0:
          monster_row{locked, id, name, sprite, gold_drop, update_u32_list(hp_by_level, level, value)} <> tail
        case _:
          monster_row{locked, id, name, sprite, gold_drop, hp_by_level} <> update_monster_hps(tail, row - 1, level, value)

def add_monster_row(rows: List(MonsterRow)) -> List(MonsterRow):
  n = monster_count(rows) + 1;
  List/append(MonsterRow, rows, [monster_row{0, "new_monster_" ++ U32.show(n), "New Monster", "assets/enemy-rat.png", 1, first_hp_levels(rows)}])

def add_hp_level_to_monsters(rows: List(MonsterRow)) -> List(MonsterRow):
  match rows:
    case []:
      []
    case monster_row{locked, id, name, sprite, gold_drop, hp_by_level}<>tail:
      monster_row{locked, id, name, sprite, gold_drop, List/append(U32, hp_by_level, [1])} <> add_hp_level_to_monsters(tail)

def update_weapons(rows: List(WeaponRow), row: U32, field: U32, value: String) -> List(WeaponRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_weapon_row(current, field, value) <> tail
        case _:
          current <> update_weapons(tail, row - 1, field, value)

def update_weapon_row(row: WeaponRow, field: U32, value: String) -> WeaponRow:
  match row:
    case weapon_row{locked, id, name, sprite, dmg}:
      match field:
        case 0:
          weapon_row{locked, value, name, sprite, dmg}
        case 1:
          weapon_row{locked, id, value, sprite, dmg}
        case 2:
          weapon_row{locked, id, name, value, dmg}
        case _:
          weapon_row{locked, id, name, sprite, parse_u32_or(dmg, value)}

def add_weapon_row(rows: List(WeaponRow)) -> List(WeaponRow):
  n = weapon_count(rows) + 1;
  List/append(WeaponRow, rows, [weapon_row{0, "new_weapon_" ++ U32.show(n), "New Weapon", "assets/item-sword.png", 1}])

def update_potions(rows: List(PotionRow), row: U32, field: U32, value: String) -> List(PotionRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_potion_row(current, field, value) <> tail
        case _:
          current <> update_potions(tail, row - 1, field, value)

def update_potion_row(row: PotionRow, field: U32, value: String) -> PotionRow:
  match row:
    case potion_row{locked, id, name, sprite, heal}:
      match field:
        case 0:
          potion_row{locked, value, name, sprite, heal}
        case 1:
          potion_row{locked, id, value, sprite, heal}
        case 2:
          potion_row{locked, id, name, value, heal}
        case _:
          potion_row{locked, id, name, sprite, parse_u32_or(heal, value)}

def add_potion_row(rows: List(PotionRow)) -> List(PotionRow):
  n = potion_count(rows) + 1;
  List/append(PotionRow, rows, [potion_row{0, "new_potion_" ++ U32.show(n), "New Potion", "assets/item-potion.png", 1}])

def update_deck_rows(rows: List(DeckRow), row: U32, field: U32, value: String) -> List(DeckRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_deck_row(current, field, value) <> tail
        case _:
          current <> update_deck_rows(tail, row - 1, field, value)

def update_deck_row(row: DeckRow, field: U32, value: String) -> DeckRow:
  match row:
    case deck_row{locked, card_id, count}:
      match field:
        case 0:
          deck_row{locked, value, count}
        case _:
          deck_row{locked, card_id, parse_u32_or(count, value)}

def add_deck_row(rows: List(DeckRow), card_id: String) -> List(DeckRow):
  List/append(DeckRow, rows, [deck_row{0, card_id, 1}])

def update_packs(rows: List(PackRow), row: U32, field: U32, value: String) -> List(PackRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_pack_row(current, field, value) <> tail
        case _:
          current <> update_packs(tail, row - 1, field, value)

def update_pack_row(row: PackRow, field: U32, value: String) -> PackRow:
  match row:
    case pack_row{locked, id, name, price, reveal_count, allow_duplicates}:
      match field:
        case 0:
          pack_row{locked, value, name, price, reveal_count, allow_duplicates}
        case 1:
          pack_row{locked, id, value, price, reveal_count, allow_duplicates}
        case 2:
          pack_row{locked, id, name, parse_u32_or(price, value), reveal_count, allow_duplicates}
        case 3:
          pack_row{locked, id, name, price, parse_u32_or(reveal_count, value), allow_duplicates}
        case _:
          pack_row{locked, id, name, price, reveal_count, parse_boolish(allow_duplicates, value)}

def add_pack_row(rows: List(PackRow)) -> List(PackRow):
  n = pack_count(rows) + 1;
  List/append(PackRow, rows, [pack_row{0, "new_pack_" ++ U32.show(n), "New Pack", 10, 1, 0}])

def update_pool_rows(rows: List(PoolRow), row: U32, field: U32, value: String) -> List(PoolRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_pool_row(current, field, value) <> tail
        case _:
          current <> update_pool_rows(tail, row - 1, field, value)

def update_pool_row(row: PoolRow, field: U32, value: String) -> PoolRow:
  match row:
    case pool_row{locked, pack_id, card_id, weight}:
      match field:
        case 0:
          pool_row{locked, value, card_id, weight}
        case 1:
          pool_row{locked, pack_id, value, weight}
        case _:
          pool_row{locked, pack_id, card_id, parse_u32_or(weight, value)}

def add_pool_row(rows: List(PoolRow), pack_id: String, card_id: String) -> List(PoolRow):
  List/append(PoolRow, rows, [pool_row{0, pack_id, card_id, 1}])

def update_presentations(rows: List(PresentationRow), row: U32, field: U32, value: String) -> List(PresentationRow):
  match rows:
    case []:
      []
    case current<>tail:
      match row:
        case 0:
          update_presentation_row(current, field, value) <> tail
        case _:
          current <> update_presentations(tail, row - 1, field, value)

def update_presentation_row(row: PresentationRow, field: U32, value: String) -> PresentationRow:
  match row:
    case presentation_row{locked, hero_id, name_align, ultimate_title, ultimate_icon, ultimate_description}:
      match field:
        case 0:
          presentation_row{locked, value, name_align, ultimate_title, ultimate_icon, ultimate_description}
        case 1:
          presentation_row{locked, hero_id, value, ultimate_title, ultimate_icon, ultimate_description}
        case 2:
          presentation_row{locked, hero_id, name_align, value, ultimate_icon, ultimate_description}
        case 3:
          presentation_row{locked, hero_id, name_align, ultimate_title, value, ultimate_description}
        case _:
          presentation_row{locked, hero_id, name_align, ultimate_title, ultimate_icon, value}

def add_presentation_row(rows: List(PresentationRow), hero_id: String) -> List(PresentationRow):
  List/append(PresentationRow, rows, [presentation_row{0, hero_id, "center", "Ultimate", "assets/item-sword.png", "Describe the ultimate."}])

def update_u32_list(values: List(U32), index: U32, value: String) -> List(U32):
  match values:
    case []:
      []
    case current<>tail:
      match index:
        case 0:
          parse_u32_or(current, value) <> tail
        case _:
          current <> update_u32_list(tail, index - 1, value)

def first_hero_id(rows: List(HeroRow)) -> String:
  match rows:
    case []:
      "new_hero_1"
    case hero_row{_, id, _, _, _, _, _}<>_:
      id

def first_pack_id(rows: List(PackRow)) -> String:
  match rows:
    case []:
      "new_pack_1"
    case pack_row{_, id, _, _, _, _}<>_:
      id

def first_card_id(data: EditorData) -> String:
  first_card_id_from_monsters(editor_monsters(data), editor_weapons(data), editor_potions(data))

def first_card_id_from_monsters(monsters: List(MonsterRow), weapons: List(WeaponRow), potions: List(PotionRow)) -> String:
  match monsters:
    case monster_row{_, id, _, _, _, _}<>_:
      id
    case []:
      first_card_id_from_weapons(weapons, potions)

def first_card_id_from_weapons(weapons: List(WeaponRow), potions: List(PotionRow)) -> String:
  match weapons:
    case weapon_row{_, id, _, _, _}<>_:
      id
    case []:
      first_card_id_from_potions(potions)

def first_card_id_from_potions(potions: List(PotionRow)) -> String:
  match potions:
    case potion_row{_, id, _, _, _}<>_:
      id
    case []:
      "hero"

def first_hp_levels(rows: List(MonsterRow)) -> List(U32):
  match rows:
    case []:
      [1]
    case monster_row{_, _, _, _, _, hp_by_level}<>_:
      hp_by_level

def hero_count(rows: List(HeroRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + hero_count(tail)

def upgrade_count(rows: List(HeroUpgradeRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + upgrade_count(tail)

def monster_count(rows: List(MonsterRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + monster_count(tail)

def weapon_count(rows: List(WeaponRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + weapon_count(tail)

def potion_count(rows: List(PotionRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + potion_count(tail)

def deck_count(rows: List(DeckRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + deck_count(tail)

def pack_count(rows: List(PackRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + pack_count(tail)

def pool_count(rows: List(PoolRow)) -> U32:
  match rows:
    case []:
      0
    case _<>tail:
      1 + pool_count(tail)

def jstr(value: String) -> String:
  JSON/show/str(value)

def jbool(value: U32) -> String:
  match value:
    case 0:
      "false"
    case _:
      "true"

def jarr(items: List(String)) -> String:
  "[" ++ String/join(items, ",") ++ "]"

def jobj(fields: List(String)) -> String:
  "{" ++ String/join(fields, ",") ++ "}"

def jp_s(key: String, value: String) -> String:
  jstr(key) ++ ":" ++ jstr(value)

def jp_u(key: String, value: U32) -> String:
  jstr(key) ++ ":" ++ U32.show(value)

def jp_b(key: String, value: U32) -> String:
  jstr(key) ++ ":" ++ jbool(value)

def editor_data_json(data: EditorData) -> String:
  match data:
    case editor_data{heroes, upgrades, monsters, weapons, potions, deck, packs, pool, rules, presentation}:
      jobj([
        jstr("heroes") ++ ":" ++ jarr(hero_jsons(heroes)),
        jstr("hero_upgrades") ++ ":" ++ jarr(upgrade_jsons(upgrades)),
        jstr("monsters") ++ ":" ++ jarr(monster_jsons(monsters)),
        jstr("weapons") ++ ":" ++ jarr(weapon_jsons(weapons)),
        jstr("potions") ++ ":" ++ jarr(potion_jsons(potions)),
        jstr("decks") ++ ":" ++ jobj([jstr("base_deck") ++ ":" ++ jarr(deck_jsons(deck))]),
        jstr("boosters") ++ ":" ++ jobj([jstr("packs") ++ ":" ++ jarr(pack_jsons(packs)), jstr("pool") ++ ":" ++ jarr(pool_jsons(pool))]),
        jstr("rules") ++ ":" ++ rules_json(rules),
        jstr("presentation") ++ ":" ++ jobj([jstr("heroes") ++ ":" ++ jarr(presentation_jsons(presentation))])
      ])

def hero_jsons(rows: List(HeroRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      hero_json(row) <> hero_jsons(tail)

def hero_json(row: HeroRow) -> String:
  match row:
    case hero_row{_, id, name, sprite, base_max_hp, unlock_cost, starts_unlocked}:
      jobj([jp_s("id", id), jp_s("name", name), jp_s("sprite", sprite), jp_u("base_max_hp", base_max_hp), jp_u("unlock_cost", unlock_cost), jp_b("starts_unlocked", starts_unlocked)])

def upgrade_jsons(rows: List(HeroUpgradeRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      upgrade_json(row) <> upgrade_jsons(tail)

def upgrade_json(row: HeroUpgradeRow) -> String:
  match row:
    case hero_upgrade_row{_, hero_id, level, cost, max_hp}:
      jobj([jp_s("hero_id", hero_id), jp_u("level", level), jp_u("cost", cost), jp_u("max_hp", max_hp)])

def monster_jsons(rows: List(MonsterRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      monster_json(row) <> monster_jsons(tail)

def monster_json(row: MonsterRow) -> String:
  match row:
    case monster_row{_, id, name, sprite, gold_drop, hp_by_level}:
      jobj([jp_s("id", id), jp_s("name", name), jp_s("sprite", sprite), jp_u("gold_drop", gold_drop), jstr("hp_by_level") ++ ":" ++ jarr(u32_jsons(hp_by_level))])

def weapon_jsons(rows: List(WeaponRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      weapon_json(row) <> weapon_jsons(tail)

def weapon_json(row: WeaponRow) -> String:
  match row:
    case weapon_row{_, id, name, sprite, dmg}:
      jobj([jp_s("id", id), jp_s("name", name), jp_s("sprite", sprite), jp_u("dmg", dmg)])

def potion_jsons(rows: List(PotionRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      potion_json(row) <> potion_jsons(tail)

def potion_json(row: PotionRow) -> String:
  match row:
    case potion_row{_, id, name, sprite, heal}:
      jobj([jp_s("id", id), jp_s("name", name), jp_s("sprite", sprite), jp_u("heal", heal)])

def deck_jsons(rows: List(DeckRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      deck_json(row) <> deck_jsons(tail)

def deck_json(row: DeckRow) -> String:
  match row:
    case deck_row{_, card_id, count}:
      jobj([jp_s("card_id", card_id), jp_u("count", count)])

def pack_jsons(rows: List(PackRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      pack_json(row) <> pack_jsons(tail)

def pack_json(row: PackRow) -> String:
  match row:
    case pack_row{_, id, name, price, reveal_count, allow_duplicates}:
      jobj([jp_s("id", id), jp_s("name", name), jp_u("price", price), jp_u("reveal_count", reveal_count), jp_b("allow_duplicates", allow_duplicates)])

def pool_jsons(rows: List(PoolRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      pool_json(row) <> pool_jsons(tail)

def pool_json(row: PoolRow) -> String:
  match row:
    case pool_row{_, pack_id, card_id, weight}:
      jobj([jp_s("pack_id", pack_id), jp_s("card_id", card_id), jp_u("weight", weight)])

def rules_json(rules: RulesRow) -> String:
  match rules:
    case rules_row{initial_seed, starting_gold, starting_selected_hero_id, starting_selection_confirmed, starting_dungeon_level, dungeon_level_increment_per_refill, ultimate_charge_required, ultimate_charge_per_move}:
      jobj([
        jp_u("initial_seed", initial_seed),
        jp_u("starting_gold", starting_gold),
        jp_s("starting_selected_hero_id", starting_selected_hero_id),
        jp_b("starting_selection_confirmed", starting_selection_confirmed),
        jp_u("starting_dungeon_level", starting_dungeon_level),
        jp_u("dungeon_level_increment_per_refill", dungeon_level_increment_per_refill),
        jp_u("ultimate_charge_required", ultimate_charge_required),
        jp_u("ultimate_charge_per_move", ultimate_charge_per_move)
      ])

def presentation_jsons(rows: List(PresentationRow)) -> List(String):
  match rows:
    case []:
      []
    case row<>tail:
      presentation_json(row) <> presentation_jsons(tail)

def presentation_json(row: PresentationRow) -> String:
  match row:
    case presentation_row{_, hero_id, name_align, ultimate_title, ultimate_icon, ultimate_description}:
      jobj([jp_s("hero_id", hero_id), jp_s("name_align", name_align), jp_s("ultimate_title", ultimate_title), jp_s("ultimate_icon", ultimate_icon), jp_s("ultimate_description", ultimate_description)])

def u32_jsons(values: List(U32)) -> List(String):
  match values:
    case []:
      []
    case value<>tail:
      U32.show(value) <> u32_jsons(tail)
