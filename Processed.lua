-- Wayfarer's Tales - notes and flagged lines already handled (see docs/field-notes.md).
-- At login, the addon removes these from your Homework notes and unflags these lines,
-- so the report only shows what's still waiting. Keyed by the note's / line's time.

local _, KT = ...
local D = KT.Data

D.PROCESSED = {
  notes = {
    [1794337789] = true, [1794337806] = true, [1794337831] = true, [1794337934] = true, -- NPCs, Aldrassil
    [1794337952] = true, [1794338033] = true, [1794338234] = true, [1794338493] = true, -- NPC, fall, quest, campfire
    [1794338705] = true, [1794338843] = true, [1794338945] = true, [1794338962] = true, -- Dolanaar, corruption, inn
  },
  flags = {
    [1794338113] = true, -- "Vous mangeriez bien quelque chose" below 25% hunger
  },
  -- by the minute shown in the report (when the exact time isn't known)
  notesAt = {
    ["2026-11-11 09:12"] = true, ["2026-11-11 09:14"] = true, ["2026-11-11 09:16"] = true, -- AFK, Fée Dérailleur, Therum
    ["2026-11-11 09:17"] = true, ["2026-11-11 09:19"] = true, ["2026-11-11 09:24"] = true, -- Dane, Kaita, pet +0.9
    ["2026-11-11 09:27"] = true, ["2026-11-11 09:31"] = true, ["2026-11-11 09:36"] = true, -- Jaxon, rain/sun, Lilliam
    ["2026-11-11 09:55"] = true, ["2026-11-11 09:57"] = true, ["2026-11-11 09:58"] = true, -- rain on roof, bankers
    ["2026-11-11 10:19"] = true, ["2026-11-11 12:09"] = true, ["2026-11-11 12:16"] = true, -- Erika, Dungar, eating
    ["2026-11-11 12:17"] = true, ["2026-11-11 12:29"] = true, ["2026-11-11 12:33"] = true, -- eating, flies, Saldean
    ["2026-11-11 12:34"] = true, ["2026-11-11 12:40"] = true, ["2026-11-11 12:45"] = true, -- quest 22, two lines, pet solo
    ["2026-11-11 13:36"] = true, ["2026-11-11 14:04"] = true, ["2026-11-11 14:07"] = true, -- faire, Ariena, flight paths
    ["2026-11-11 14:08"] = true, ["2026-11-11 14:15"] = true, ["2026-11-11 14:19"] = true, -- wanted, Solomon, inns
    ["2026-11-11 14:20"] = true, ["2026-11-11 14:21"] = true, ["2026-11-11 14:24"] = true, -- foods, titles, Wental
    ["2026-11-11 14:25"] = true, ["2026-11-11 14:39"] = true, ["2026-11-11 14:46"] = true, -- question, birds, sounds
    ["2026-11-11 15:04"] = true, ["2026-11-11 15:05"] = true, -- Argus, his quest
    ["2026-11-11 20:17"] = true, ["2026-11-12 16:33"] = true, ["2026-11-12 16:46"] = true, -- test, quests 144, 145
    ["2026-11-12 16:49"] = true, ["2026-11-12 16:50"] = true, -- Darkshire inn + Trelayne, cheese
    ["2026-11-12 17:23"] = true, ["2026-11-12 17:33"] = true, ["2026-11-12 17:34"] = true, -- murloc loot, soup, goulash
    ["2026-11-13 11:14"] = true, -- mining arms
  },
  flagsAt = {
    ["2026-11-11 08:45"] = true, ["2026-11-11 09:15"] = true, ["2026-11-11 09:21"] = true, -- mail, bomb, canals
    ["2026-11-11 09:25"] = true, ["2026-11-11 09:42"] = true, ["2026-11-11 09:54"] = true, -- auction, drink, meal
    ["2026-11-11 10:04"] = true, -- pet licks crumbs of a fish
    ["2026-11-11 15:07"] = true, ["2026-11-11 15:16"] = true, -- pet solo wording, Aubergiste Allison
    ["2026-11-11 19:27"] = true, ["2026-11-11 20:05"] = true, ["2026-11-11 20:29"] = true, -- still line, bustle, Dolanaar
    ["2026-11-12 16:45"] = true, ["2026-11-12 17:35"] = true, -- bustle, "food"
    ["2026-11-13 10:38"] = true, ["2026-11-13 11:19"] = true, -- Westfall Defias, Erika
  },
  -- errors logged by versions older than this were fixed (secret values, v0.31)
  errorsBefore = "0.31.0",
}
