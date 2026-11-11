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
  },
  flagsAt = {
    ["2026-11-11 08:45"] = true, ["2026-11-11 09:15"] = true, ["2026-11-11 09:21"] = true, -- mail, bomb, canals
    ["2026-11-11 09:25"] = true, ["2026-11-11 09:42"] = true, ["2026-11-11 09:54"] = true, -- auction, drink, meal
  },
  -- errors logged by versions older than this were fixed (secret values, v0.31)
  errorsBefore = "0.31.0",
}
