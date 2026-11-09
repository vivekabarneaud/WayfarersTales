# Wayfarer's Tales

Little touches of life on your journey, for **World of Warcraft: Forever**.
Purely cosmetic: nothing changes your stats, and everything stays on your computer.
English and French.

> **Beta.** Things still change often. Feedback is very welcome: use the in-game
> *Report & ideas* button (Journal tab) and paste it into an issue here.

## Modules (each can be turned on or off)

- **Kindred**: build a bond with your hunter pet. Affection grows with cuddles, meals,
  campfires and adventures. Emote reactions, a secret favorite food, moods, memories,
  sounds, and a pet that reacts to its surroundings.
- **Elements**: how your character feels. Cold and heat (with a thermometer by the
  minimap), wetness, thirst, hunger and tiredness. Your body tells you in the chat;
  the details are in the window.
- **Senses**: short immersion lines about the world around you: smells, sounds, the
  wind, the weather, first visits to new places, and the feeling of danger.

## Install

Copy the `WayfarersTales` folder into
`World of Warcraft\_forever_\Interface\AddOns\`, then restart the game.

## Commands

| Command | |
|---|---|
| `/wt` | open the window |
| `/wt nope` | flag the last line as wrong or odd |
| `/wt status` | your pet's story, in chat |
| `/wt sound` | hear your pet's sounds |
| `/wt debug` | technical messages |

## Writing lines

Immersion lines live in `SensesData.lua`: English and French side by side, with
conditions (day or night, indoors, weather, temperature, place...) so a line only plays
where it is true. The *Ambiance* tab in game shows every line for the place you're
standing in, and why each one can or can't play right now.
