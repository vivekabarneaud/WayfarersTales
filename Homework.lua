-- Wayfarer's Tales - "Homework": a small tracker-like window for testers, with
-- what to note while playing (NPCs, quests, moonwells, places with no open sky...).
-- Each button records the note with its context (zone, position, target...).
-- Notes are saved in db.fieldNotes and listed in the report. Open with /wt devoirs.

local _, KT = ...
local L, D = KT.L, KT.Data
local H = {}
KT.Homework = H

local frame

local function Say(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffff8fb1Wayfarer's Tales|r " .. tostring(msg))
end

-- Where you are, for the note
local function Here()
  local ok, ctx = pcall(KT.Senses.Context)
  if not ok or not ctx then ctx = {} end
  local function r(v) return v and math.floor(v * 10 + 0.5) / 10 or nil end
  return { zone = ctx.zone, sub = ctx.sub, map = ctx.rawMapID, mapID = ctx.mapID, x = r(ctx.x), y = r(ctx.y),
    indoors = ctx.indoors, t = time() }
end

local function AddNote(kind, extra)
  local db = KT.GetDB()
  db.fieldNotes = db.fieldNotes or {}
  local n = Here()
  n.kind = kind
  for k, v in pairs(extra or {}) do n[k] = v end
  local text = frame and frame.input:GetText() or ""
  if text ~= "" then n.text = text end
  if frame then frame.input:SetText(""); frame.input:ClearFocus() end
  table.insert(db.fieldNotes, n)
  Say(L.HW_SAVED)
  H.Refresh()
end

---------------------------------------------------------------------------
-- What each button does
---------------------------------------------------------------------------

local function NoteNPC()
  local ok, guid = pcall(UnitGUID, "target")
  if not ok or type(guid) ~= "string" then Say(L.HW_NEED_TARGET) return end
  local unitType, _, _, _, _, npcID = strsplit("-", guid)
  if unitType ~= "Creature" then Say(L.HW_NEED_TARGET) return end
  local _, sex = pcall(UnitSex, "target")
  AddNote("npc", { npcID = npcID, npcName = UnitName("target"), npcSex = sex })
end

local function NoteQuest()
  local done = KT.GetDB().questsDone or {}
  local q = done[#done]
  if not q then Say(L.HW_NO_QUEST) return end
  AddNote("quest", { questID = q.id, questTitle = q.title })
end

local function NoteMoonwell() AddNote("moonwell") end

local function NoteNoSky()
  local res = KT.Senses.ToggleRoof()
  Say(L.CMD_ROOF[res] or res)
  if res == "added" then AddNote("nosky") end
end

local function NoteFree()
  if frame.input:GetText() == "" then Say(L.HW_NEED_TEXT) frame.input:SetFocus() return end
  AddNote("note")
end

---------------------------------------------------------------------------
-- The window
---------------------------------------------------------------------------

local ROWS = {
  { "HW_NPC",   "HW_BTN_NOTE",  NoteNPC },
  { "HW_QUEST", "HW_BTN_LAST",  NoteQuest },
  { "HW_MOON",  "HW_BTN_HERE",  NoteMoonwell },
  { "HW_SKY",   "HW_BTN_HERE",  NoteNoSky },
  { "HW_FREE",  "HW_BTN_NOTE",  NoteFree },
}

local function Build()
  local f = CreateFrame("Frame", "WayfarersTalesHomework", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetSize(290, 64 + #ROWS * 30 + 70)
  f:SetFrameStrata("MEDIUM")
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, rel, x, y = self:GetPoint()
    KT.GetDB().settings.homeworkPos = { point, rel, x, y }
  end)
  if f.SetBackdrop then
    f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    f:SetBackdropColor(0.05, 0.05, 0.08, 0.85)
    f:SetBackdropBorderColor(0.8, 0.65, 0.3, 1)
  end
  local pos = KT.GetDB().settings.homeworkPos
  if pos then f:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else f:SetPoint("RIGHT", UIParent, "RIGHT", -260, 60) end

  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.title:SetPoint("TOPLEFT", 12, -10)
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function() H.Toggle(false) end)

  f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.sub:SetPoint("TOPLEFT", 12, -28)
  f.sub:SetWidth(266)
  f.sub:SetJustifyH("LEFT")

  f.rows = {}
  for i, row in ipairs(ROWS) do
    local y = -52 - (i - 1) * 30
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", 14, y - 6)
    label:SetWidth(180)
    label:SetJustifyH("LEFT")
    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    b:SetSize(78, 22)
    b:SetPoint("TOPRIGHT", -12, y)
    b:SetScript("OnClick", function() local ok, err = pcall(row[3]); if not ok then KT.LogError("Homework", err) end end)
    f.rows[i] = { label = label, button = b, row = row }
  end

  local y = -52 - #ROWS * 30
  f.inputLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  f.inputLabel:SetPoint("TOPLEFT", 14, y - 4)
  f.input = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  f.input:SetSize(258, 20)
  f.input:SetPoint("TOPLEFT", 18, y - 18)
  f.input:SetAutoFocus(false)
  f.input:SetMaxLetters(200)
  f.input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  f.input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

  f.footer = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  f.footer:SetPoint("BOTTOMLEFT", 12, 12)
  f.footer:SetWidth(180)
  f.footer:SetJustifyH("LEFT")
  f.report = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.report:SetSize(78, 22)
  f.report:SetPoint("BOTTOMRIGHT", -12, 8)
  f.report:SetScript("OnClick", function() if KT.ShowReport then KT.ShowReport() end end)

  frame = f
end

function H.Refresh()
  if not frame then return end
  frame.title:SetText(L.HW_TITLE)
  frame.sub:SetText(L.HW_SUB)
  for _, r in ipairs(frame.rows) do
    r.label:SetText(L[r.row[1]])
    r.button:SetText(L[r.row[2]])
  end
  frame.inputLabel:SetText(L.HW_INPUT)
  frame.report:SetText(L.HW_REPORT)
  local n = #(KT.GetDB().fieldNotes or {})
  frame.footer:SetText(string.format(L.HW_COUNT, n))
end

function H.Toggle(show)
  if not frame then Build() end
  if show == nil then show = not frame:IsShown() end
  frame:SetShown(show)
  KT.GetDB().settings.homework = show
  if show then H.Refresh() end
end

---------------------------------------------------------------------------
-- Quests you turn in (kept for the "last quest" button and the report)
---------------------------------------------------------------------------

local function QuestTitle(id)
  if C_QuestLog and C_QuestLog.GetTitleForQuestID then
    local ok, t = pcall(C_QuestLog.GetTitleForQuestID, id)
    if ok and t then return t end
  end
  if C_QuestLog and C_QuestLog.GetQuestInfo then
    local ok, t = pcall(C_QuestLog.GetQuestInfo, id)
    if ok and type(t) == "string" then return t end
  end
  return nil
end

local rewardTitle -- the title shown in the quest reward window (the quest may leave the log before it's turned in)

local ev = CreateFrame("Frame")
pcall(ev.RegisterEvent, ev, "PLAYER_LOGIN")
pcall(ev.RegisterEvent, ev, "QUEST_COMPLETE")
pcall(ev.RegisterEvent, ev, "QUEST_TURNED_IN")
ev:SetScript("OnEvent", function(_, event, questID)
  local ok, err = pcall(function()
    if event == "PLAYER_LOGIN" then
      if KT.GetDB().settings.homework then H.Toggle(true) end
    elseif event == "QUEST_COMPLETE" then
      rewardTitle = GetTitleText and GetTitleText() or nil
    elseif event == "QUEST_TURNED_IN" and questID then
      local db = KT.GetDB()
      db.questsDone = db.questsDone or {}
      table.insert(db.questsDone, { id = questID, title = QuestTitle(questID) or rewardTitle, zone = GetRealZoneText(), t = time() })
      rewardTitle = nil
      while #db.questsDone > 50 do table.remove(db.questsDone, 1) end
    end
  end)
  if not ok then KT.LogError("Homework " .. tostring(event), err) end
end)
