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
}
