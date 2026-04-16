import /Dungeon/Meta as Meta
import /Dungeon/config as config
import /Dungeon/profile_helpers/default_hero_profiles as default_hero_profiles
import /Dungeon/rules/starting_gold as starting_gold
import /Dungeon/rules/starting_selected_hero as starting_selected_hero
import /Dungeon/rules/starting_selection_confirmed as starting_selection_confirmed

def default_meta() -> Meta:
  meta{starting_selected_hero(), starting_selection_confirmed(), starting_gold(), [], [], default_hero_profiles(config())}
