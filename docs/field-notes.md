# Field notes

Notes sent from the game (Homework window, `/wt nope`, review page) and what we did with them.
Once a note is handled, its time goes into `Processed.lua`, and the addon removes it from the
in-game report at the next login.

**Status:** `done` = in the addon (live or as a draft to review) · `todo` = planned ·
`wontfix` = decided against (with the reason) · `info` = reference, nothing to do.

## 2026-11-10 — Teldrassil (Tissy, night elf druid)

| When | Kind | Note | Status | What we did |
|---|---|---|---|---|
| 20:09 | NPC | Keina (3589), Aldrassil: female night elf, sells bows and arrows | done | `D.NPCS` bowyer + 2 lines (draft) |
| 20:10 | NPC | Dellylah (6091), Aldrassil: female night elf, food and drink | done | `D.NPCS` food + 1 line (draft) |
| 20:12 | NPC | Mardant Strongoak (3597), Aldrassil: male night elf, druid trainer | done | `D.NPCS` trainer_druid + 1 line (draft) |
| 20:12 | NPC | Ayanna Everstride (3596), Aldrassil: female night elf, hunter trainer | done | `D.NPCS` trainer_hunter + 1 line (draft) |
| — | NPC | Keldamyr (6736), Dolanaar innkeeper (from the NPC log) | done | `D.NPCS` innkeeper + 1 line (draft) |
| — | NPC | Lyreena Lamebrune (265811): female night elf, campfire teacher | done | `D.NPCS` campfire_teacher + line (draft) |
| 20:13 | Idea | Fall damage could have a line | done | Falls: health lost on landing, small / hard / fur versions (draft) |
| 20:17 | Quest | Livraison à Dolanaar (2159): a line when taking it, leaving Shadowglen for Teldrassil | done | First quest line, on accept (draft) |
| 20:15 | Flag | "Vous mangeriez bien quelque chose" while below 25% hunger: should be more pressing | done | Pressing hunger / thirst / fatigue lines below 25% (draft) |
| 20:21 | Idea | No campfire lines for non-hunters (sitting, and the buff) | done | Campfire lines for everyone: sitting, then rested (draft) |
| 20:25 | Place | Dolanaar, first arrival: humble village, an inn to rest and set the hearthstone | done | Dolanaar sub-zone arrival line (draft) |
| 20:27 | Lore | Night elves in Teldrassil: a strange, corrupt-smelling breeze, the urge to protect home | done | Night elf line, reworded to be more immediate (draft) |
| 20:29 | Place | Dolanaar inn sells "Pain sorti du four": it could smell of it | done | Dolanaar inn spot, merged with the beds line (draft) |
| 20:29 | Place | The beds look very comfy at Dolanaar's inn | done | Merged with the bread line (draft) |

## From the review page

| Line | Review | Status | What we did |
|---|---|---|---|
| Inn first visit (genericArrive 1) | keep | done | Kept as the model for other lines |
| Inn hearthstone rewrite (genericHearth 1) | approve | done | Rewrite applied |
| Squirrel (forest) | tweak: only near healthy trees | done | Forest landscape = healthy forests only; Silverpine moved to gloomy |
| Teldrassil: walking on the World Tree | tweak: not for night elves | done | `notRace = "NightElf"` |
| Teldrassil: violet light, "crépuscule" | tweak: twilight means evening | done | Now "pénombre" |
| Teldrassil ambient 2–5 | approve | done | Made permanent |
| Silverleaf: crushed leaf, wild mint | approve | done | Made permanent |
| Teldrassil lore "On murmure…" | tweak: a night elf knows | done | Night elf version + visitor version |
| Twig "personne en vue" with boars around | flag | done | New "alone" condition counts creatures too |
| Moonwell "Vous n'osez pas y toucher" | tweak: quests make other races fill vials | done | Reworded for visitors |

## 2026-11-11 — Stormwind (Kitty, hunter)

| When | Kind | Note | Status | What we did |
|---|---|---|---|---|
| 09:31 | Weather | It rains, the Ambiance tab shows "type 1, intensity 0.88" | done | Rain confirmed as weather type 1: rain lines switched on |
| 09:31 | Question | The minimap still shows a sun while it rains | info | That's the game's own day/night clock icon, not the addon's; it never shows weather |
| — | Idea | Rain: get wet, light vs heavy rain, gear in the rain, the pet in the rain | done | Rain soaks you outdoors (2 to 6 min) and cools the air up to 4°C; drizzle / downpour lines; helmet, cloak and fur lines; pet rain lines (drafts) |
| — | Idea | More need levels: a little (75), yes (50), a lot (25) for hunger, thirst and energy | done | Four levels with new labels (Petit creux / Faim / Grande faim...), first-level lines (draft) |
| — | Idea | Energy: standing still stops the drop; sitting helps up to 60; /sleep nap fast (10%/s), wake-up line full or not | done | Sitting (X key, /sit) and napping (/sleep) followed until you move; lines (draft) |
| — | Flag | Fishing: got "stop and look around" lines while fishing | done | Fishing lines: casting, waiting (replaces the quiet moment), catch, first of a kind, junk (draft) |

### Playtest report, Stormwind (Kitty, hunter)

| When | Kind | Note | Status | What we did |
|---|---|---|---|---|
| 08:45 | Flag | Mailbox "au cas où": you already know whether there's mail before opening | done | Mailbox lines only when there's new mail, rewritten (draft) |
| 09:12 | Idea | Ambient lines should stop when AFK | done | No Senses lines at all while AFK |
| 09:14 | NPC | Fée Dérailleur (11026), female gnome, master engineer | done | `D.NPCS` + gnome engineering trainer lines (draft) |
| 09:15 | Flag | Learning "Bombe grossière en cuivre": a fun line for bombs | done | Explosive recipes and first crafts get their own lines (draft) |
| 09:16 | NPC | Therum Deepforge (5511), male dwarf, master blacksmith | done | `D.NPCS` + dwarf blacksmith line (draft) |
| 09:17 | NPC | Dane Lindgren (957), male human, master blacksmith, busy and blunt | done | `D.NPCS` + his own line (draft) |
| 09:19 | NPC | Kaita Deepforge (5512), female dwarf, smith supplies, kind | done | `D.NPCS` + her line (draft) |
| 09:21 | Flag | Canals "malgré vous" | done | Rewrite proposal reworded ("vous apaise doucement") |
| 09:24 | Question | Got (+0,9) feeding the pet: will it show (+0) at 100? | info | It filled the last 0.9 to 100; at 100 gains are 0 and no number is shown |
| 09:25 | Flag | Auction house: the auctioneer stands on a crate, lots of players | done | Jaxon's own lines, one for a crowd (draft) |
| 09:27 | NPC | Commissaire-priseur Jaxon (15659), female human, on a crate | done | `D.NPCS` + lines (draft) |
| 09:31 | Question | Raining but the minimap shows a sun | info | The game's own day/night clock |
| 09:36 | NPC | Lilliam Sparkspindle (5518), male gnome, expert engineer | done | `D.NPCS` + gnome engineering trainer lines (draft) |
| 09:42 | Flag | "…le temps de reprendre votre souffle" while standing still for a while | done | Now "en prenant votre temps" |
| 09:54 | Flag | Poppo "se couche avec un petit soupir" while walking | done | Walking version: he follows you, head a little low |
| 09:55 | Idea | At the inn, the rain on the roof could have lines | done | Rain heard from indoors (inn, city building) (draft) |
| 09:57 | NPC | Newton Burnside (2456), human banker, proud of the security | done | `D.NPCS` + banker lines, proud line (draft) |
| 09:58 | NPC | Olivia Burnside (2455), human banker, red hair and bangs | done | `D.NPCS` + her own line (draft) |
| 09:58 | NPC | John Burnside (2457), balding human banker, proud of the security | done | `D.NPCS` + banker lines, proud line (draft) |
| — | NPC | Aubergiste Allison (6740), Gilded Rose (from the NPC log) | done | `D.NPCS` human innkeeper + line (draft) |
| — | NPC | Meri Ironweave (3613), Dolanaar: female night elf, mail armor and repairs | done | `D.NPCS` armorer + line (draft) |
| — | Error | Old secret value errors (v0.30) | done | Fixed in v0.31; old errors are cleared at login |
| — | Idea | Audit: add diversity where a situation has only one line | done | `More.lua`: 78 new drafts (weather changes, landscapes, Stormwind places, spots, danger feelings, first tastes and sips, falls, fishing junk, herbs, crafts, naps, pet moods and reactions). Repeating single-line situations: from about 80 down to 6 (snow and sand still asleep, Mulgore and Tirisfal native lines) |

## 2026-11-11 (afternoon) - Stormwind, Westfall

| When | Kind | Note | Status | What we did |
|---|---|---|---|---|
| 10:04 | Flag | Poppo "lèche les dernières miettes" of a raw fish | done | Line now fits any food: "jusqu'à la toute dernière bouchée" |
| 10:19 | NPC | Erika Tate (5483), female human, cooking supplies, "go find a goblin" to haggle | done | `D.NPCS` + a line quoting her (draft) |
| 12:09 | NPC | Dungar Longdrink (352), male human, flight master, big pilot goggles, proud of his gryphons | done | `D.NPCS` + his line (draft); an ambient line near him waits for details (gryphons around?) |
| 12:16 | Idea | Eating and drinking fill up over time while you eat (like napping) | todo | In TODO.md: fill rate from how much the food heals |
| 12:17 | Idea | ...and depend on the food (apple +3%/s, cooked fish +5%/s) | todo | Same, in TODO.md |
| 12:29 | Idea | Flies buzzing around your face in Westfall | done | Two Westfall lines, outdoors by day (draft) |
| 12:33 | Place | Saldean farm (56.2, 31.0), kitchen (56.3, 30.7): fire in the chimney, Salma making boar liver pie | done | Kitchen spot: arrival + ambient lines (draft) |
| 12:34 | Quest | Quest 22 "La tourte au foie de Broche-tripes": hot fresh pie, smells comforting, gives the recipe | done | First quest turn-in line (draft); quest turn-ins can now have lines |
| 12:40 | Bug | Two lines can show up at the very same moment | done | Lines on a timer wait 30 s after any line (any module) |
| 12:45 | Idea | Pet fought alone while you were AFK: a line for it | done | Pet wins a fight you didn't take part in (no attack, shot or spell from you): line, +1 affection, first-time memory (draft); AFK version |
| — | Flag | "Poppo vous frôle affectueusement la jambe en marchant" while standing still | done | Walking pet lines only while you walk; still versions in their place |

## 2026-11-11 — Review page, second round

| Line | Review | Status | What we did |
|---|---|---|---|
| Rain ambient rewrite (weather 1) | tweak: "l'air prend soudain" fits the start, "ruisselle" only after a while | done | Split: rain-start line (smell + first drops) and an ongoing-rain rewrite (drums, trickles) |
| Elwynn: red-masked bandits "on raconte" | tweak: known lore, no "on raconte" | done | Stated plainly, tied to the woods and a snapping twig |
| Westfall: Defias "on raconte" | tweak: mix lore with what you sense | done | Dust of the abandoned fields → the Defias' story and anger |
| Redridge: Blackrock "on dit" | tweak: fits arriving, not after a while | done | Moved into the arrival line; new ambient line: red ridges on the sky, the orcs watching |
| Dwarven forge "vous reculez d'un pas" | tweak: plays any time | done | Rewrite without it; the step back moved to a new "stepping outside in the Dwarven District" line (draft) |
| Dwarven forge embers | note: only right by the fire (63.9, 37.0) | done | New small spot by the fire |
| Dwarven District "Avant même de voir les forges" | tweak: sounds like arriving | done | Rewrite that fits any time |
| Writing rule | "on raconte" only for what's not fully known | info | Saved as a rule for all lines |

## 2026-11-11 — New window, first look

| Note | Status | What we did |
|---|---|---|
| Memories: make that part scroll on its own | done | Memories in their own scrolling box |
| The bar under the title in the header isn't needed | done | Removed (the Carnet keeps its bar) |
| "Poppo vous rapporte un bâton…" should be outdoors only, and more like it | done | Its own pool: outdoors, out of towns and inns, while you stand still; 6 new lines (draft) |
| (seen in the screenshot) "Début de votre histoire : [zone]" and "après 1 jours" | done | Old memory without its place gets "Début de votre histoire."; one day has its own text |
