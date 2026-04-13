// in order to start using the SPEC system(?) it helps to break down the game design rules as simple and straight affirmatives.


# Booster Pack

- Booster packs are the primary way to add new cards to the player's deck, serving as the core system for progression and in-game customization.

- Opening a booster pack grants a set of X cards to the player.

- Booster packs can contain any existing card type in the game.

- The contents of a booster pack are always manually defined by a game designer, including drop rates and possible outcomes.

- We plan to have multiple booster packs in the future, inclusing seasonal ones.


# Hero System

- Hero is a special card type that allow the user to play in different ways inside the dungeon.
- The player can collect multiple hero cards and equip them to play a run with it.

- Each hero has its own progression curve: level, HP, and such.
- In addition to the individual progression curve, each hero also have a id, name, a sprite, ultimate.

"heroes": [
      {
        "id": "001",
        "name": "Adventurer",
        "sprite": "assets/player-boy.png",
        "base_max_hp": 11,
        "unlock_cost": 0,
        "upgrades": [
          { "cost": 20, "max_hp": 14 },
          { "cost": 35, "max_hp": 17 },
          { "cost": 55, "max_hp": 20 },
          { "cost": 80, "max_hp": 24 }
        ]
      }, 

- ^ esse snippet é como ta hoje mas não ta contemplando a ultimate como deveria já que não pensei nisso ainda

- To unlock a new hero, the player must obtain that hero's card. Like another card-types, hero cards can be unlocked through booster packs.
> Heads up: This system is not currently implemented. At the moment, heroes are directly available for purchase using gold.
> In the intended system, gold should be used to purchase booster packs, which grant new cards to the player, and one possible outcome from these packs is a hero card.


# Dungeon System 

- The dungeon is a deck of cards. The cards contained in the deck represents the units populated on the grid each run.

- Core rule: every unity that appears on the grid is the result of a card being drawn from the deck.
- Core rule: when a card is drawn, it is placed on the grid as a new unit.

- Card consumption: when a unit is removed from the grid (eg collected, consumed, killed) its corresponding card is considered consumed.
- Once consumed, that card is removed from the remaining deck count.
- A new card must enter the dungeon to replace it on the grid so we follow the rule to always have 9 cards on the dungeon grid.

- The gameplay behavior listed above is communicated to the user using a simple UI indicator: the UI displays the number remaining cards in the deck relative to the total deck size (("REMAINING CARDS / TOTAL CARDS")(eg "3/20")).

- The dungeon level up every time the deck is exhausted. This occurs when the remaining card counter reaches 0, and is trigged on the next player movement that consumes a card.
- When the dungeon level inscreases, all monster-type cards in the deck also level up, increasing their HP.
- Dungeon and monster level increases can repeat indefinitely, but remain temporary and apply only during the active run.

> Example flow:

1. The player is standing still. The UI shows "CARDS: 3/20", meaning there are 3 cards remaining in the deck before it is exhausted.

2. The player moves left to pick up a potion:
    - The item potion card is consumed
    - The remaining deck count decreases
    - The UI updates to "CARDS: 2/20"
    - A new card enters the grid to replace the consumed one

3. When the counter reaches 0/Total Cards, on the NEXT player movement (if that movement consumes a card):
    - The deck is reset
    - The dungoeon level increases and so does the monsters cards.

- Quando a dungeon sobe de nível, afeta as cartas do tipo monstro deixando eles mais forte, já que eles sobem de nível também.

## Dungeon Scene Setup

The main scene of the game is a 3×3 grid that represents a dungeon room.

The screen shows 9 cards arranged in a 3×3 grid and the hero card always starts in the center of the grid, no exceptions.

The player moves the hero by swiping in one of the four directions: up, down, left, or right.

Diagonal movement is not allowed.

A swipe always targets the adjacent card in that direction. eg: if the player swipes up, the hero targets the card directly above it.

# Deck

- The deck represents the player’s full card inventory, which can grow without a fixed limit. It has an initial size of X cards and can be increased through progression systems such as booster packs.

- Altough the deck inventory can grow without a fixed limit, inside dungeon runs, the deck has a maximum size cap of Y to preserve gameplay pacing.

> Example: The player has a total of 300 cards. During a dungeon run, the deck size is limited to 40. The player can select which cards to use for each run. (Both the threshold and the selection feature are not yet implemented.)

- The deck can contain duplicated cards, both inside and outside of a run.

# Cards

Cards represent all units and interactive elements that can appear in the dungeon, defining their behavior and interactions.

Cards are divided into different types, each with distinct roles and behaviors within the dungeon.

- Hero-type Cards: Represent playable characters. Hero cards define unique abilities and behaviors, such as ultimates that interact with the grid in different ways.

- Monster-type cards: Represent enemies encountered in the dungeon. When defeated, monsters generate rewards (e.g., gold) before being fully consumed. A monster card is only consumed after its drop is collected.

- Item-type cards: Represent consumable or interactive elements in the dungeon, such as potions and swords.


# Gold (Soft currency)

- Gold is the primary soft currency used for player progression.

- Gold is earned during runs, mainly by defeating monsters and collecting their drops.

- Gold is used to purchase booster packs and other progression-related elements.



# Combat System
