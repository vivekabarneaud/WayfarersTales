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
| — | NPC | Lyreena Lamebrune (265811), seen in the NPC log | todo | Who is she? Race and role needed |
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
