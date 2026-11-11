-- Wayfarer's Tales - window (/wt), journal, report box, minimap button.
-- Pages are mostly plain text in a scroll area: simple and hard to break.

local _, KT = ...
local L, D = KT.L, KT.Data
local api -- KT.api, set by Core.lua; read at runtime

local frame, mm
local tabs, pages = {}, {}
local currentTab = "body"
local CONTENT_WIDTH = 470

local function Icon() return D.CUSTOM_ICON or "Interface\\Icons\\INV_ValentinesCandy" end
local function Head(text) return "|cffffd100" .. text .. "|r" end
local function Pink(text) return "|cffff8fb1" .. text .. "|r" end
local function Grey(text) return "|cffaaaaaa" .. text .. "|r" end

---------------------------------------------------------------------------
-- Building blocks
---------------------------------------------------------------------------

local function CreateTextPage(parent)
  local page = CreateFrame("Frame", nil, parent)
  page:SetAllPoints()
  local scroll = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 6, -6)
  scroll:SetPoint("BOTTOMRIGHT", -28, 6)
  local child = CreateFrame("Frame", nil, scroll)
  child:SetSize(CONTENT_WIDTH, 10)
  scroll:SetScrollChild(child)
  local fs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", 0, 0)
  fs:SetWidth(CONTENT_WIDTH)
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  fs:SetSpacing(2)
  function page:SetContent(text)
    fs:SetText(text)
    child:SetHeight(fs:GetStringHeight() + 20)
  end
  return page
end

-- Text that must change when the language changes: remember which L key it shows.
local labelled = {}
local function Label(widget, key)
  widget.labelKey = key
  labelled[#labelled + 1] = widget
  widget:SetText(L[key] or key)
end


---------------------------------------------------------------------------
-- Ambiance page (Senses): what the addon sees here, and every line for this place
---------------------------------------------------------------------------

local SENSE_ROWS = 6

local function BuildSenses(parent)
  local p = CreateFrame("Frame", nil, parent)
  p:SetAllPoints()
  p.page = 1
  p.context = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  p.context:SetPoint("TOPLEFT", 10, -8)
  p.context:SetWidth(CONTENT_WIDTH + 60)
  p.context:SetJustifyH("LEFT")
  p.context:SetSpacing(2)

  p.header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  p.header:SetPoint("TOPLEFT", 10, -128)
  local prev = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  prev:SetSize(28, 20)
  prev:SetPoint("TOPRIGHT", -40, -123)
  prev:SetText("<")
  prev:SetScript("OnClick", function() p.page = math.max(1, p.page - 1); KT.RefreshPanel() end)
  local nxt = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  nxt:SetSize(28, 20)
  nxt:SetPoint("TOPRIGHT", -8, -123)
  nxt:SetText(">")
  nxt:SetScript("OnClick", function() p.page = p.page + 1; KT.RefreshPanel() end)

  p.rows = {}
  for i = 1, SENSE_ROWS do
    local row = CreateFrame("Frame", nil, p)
    row:SetSize(CONTENT_WIDTH + 70, 52)
    row:SetPoint("TOPLEFT", 6, -150 - (i - 1) * 54)
    local play = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    play:SetSize(26, 20)
    play:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    play:SetText(">")
    play:SetScript("OnClick", function() if row.c and KT.Senses then KT.Senses.Show(row.c, true) end end)
    play:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_LEFT")
      GameTooltip:AddLine(L.SN_PLAY_TT, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    play:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", 0, 0)
    fs:SetPoint("BOTTOMRIGHT", play, "BOTTOMLEFT", -6, -16)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetSpacing(2)
    row.fs = fs
    p.rows[i] = row
  end

  -- Propose a line for this place
  local plabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  plabel:SetPoint("BOTTOMLEFT", 12, 34)
  Label(plabel, "SN_PROPOSE_LABEL")
  local box = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
  box:SetSize(CONTENT_WIDTH - 60, 22)
  box:SetPoint("BOTTOMLEFT", 18, 8)
  box:SetAutoFocus(false)
  box:SetMaxLetters(300)
  local send = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  send:SetSize(110, 24)
  send:SetPoint("LEFT", box, "RIGHT", 10, 0)
  Label(send, "SN_PROPOSE")
  local function Submit()
    local text = (box:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text ~= "" and KT.Senses then
      KT.Senses.Propose(text)
      box:SetText("")
      box:ClearFocus()
      api.Print(L.SN_PROPOSED)
    end
  end
  box:SetScript("OnEnterPressed", Submit)
  box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  send:SetScript("OnClick", Submit)
  return p
end

local function RefreshSenses(p)
  local S = KT.Senses
  if not S or not KT.ModuleOn("senses") then
    p.context:SetText(L.SN_OFF)
    p.header:SetText("")
    for _, row in ipairs(p.rows) do row:Hide() end
    return
  end
  local lines, ctx = S.LinesHere()

  -- what the addon sees here
  local yes, no = L.SN_YES, L.SN_NO
  local w = ctx.weather
  local weather
  if not w then weather = L.SN_WEATHER_NONE
  elseif w.confirmed then weather = (L.SN_WEATHERS[w.name] or w.name) .. string.format(" (%s %s)", tostring(w.type), tostring(w.intensity))
  else weather = string.format(L.SN_WEATHER_UNKNOWN, tostring(w.type), tostring(w.intensity)) end
  local place = tostring(ctx.zone or "?") .. ((ctx.sub and ctx.sub ~= "") and (" / " .. ctx.sub) or "")
  local crowd = ctx.crowd and (L.SN_CROWDS[ctx.crowd] or ctx.crowd) or L.SN_CROWD_UNKNOWN
  p.context:SetText(table.concat({
    string.format(L.SN_PLACE, place, tostring(ctx.mapID)),
    string.format(L.SN_LANDSCAPE, L.SN_BIOMES[ctx.biome] or tostring(ctx.biome), (function()
      local minL, maxL, src = S.ZoneLevels(ctx.mapID)
      if not minL then return "?" end
      return minL .. "-" .. maxL .. (src == "classic" and " (classic)" or "")
    end)()),
    string.format(L.SN_WEATHER, weather),
    string.format(L.SN_TIME, ctx.night and L.SN_NIGHT or L.SN_DAY, KT.Elements and KT.Elements.FormatAir(ctx.air or 15) or ""),
    string.format(L.SN_INOUT, ctx.indoors and yes or no, ctx.resting and yes or no),
    string.format(L.SN_CROWD, crowd, ctx.players or 0, ctx.chatter or 0),
    string.format(L.SN_POS, ctx.x and string.format("%.1f, %.1f (map %s)", ctx.x, ctx.y, tostring(ctx.rawMapID)) or "?", (function()
      local names = {}
      for _, sp in ipairs(S.SpotsHere(ctx)) do names[#names + 1] = S.SpotName(sp) end
      return #names > 0 and table.concat(names, ", ") or "-"
    end)()),
  }, "\n"))

  -- the lines
  local okCount = 0
  for _, c in ipairs(lines) do if c.ok then okCount = okCount + 1 end end
  local pageCount = math.max(1, math.ceil(#lines / SENSE_ROWS))
  if p.page > pageCount then p.page = pageCount end
  p.header:SetText(string.format(L.SN_LINES, okCount, #lines - okCount) .. "   " ..
    string.format(L.UI_JOURNAL_PAGE, p.page, pageCount))
  for i, row in ipairs(p.rows) do
    local c = lines[(p.page - 1) * SENSE_ROWS + i]
    row.c = c
    if c then
      local text = KT.G(S.LineText(c.line))
      local tags = S.Tags(c, ctx)
      if c.ok then
        row.fs:SetText("|cffffd0a0" .. text .. "|r\n" .. tags)
      else
        local reason = L.SN_REASONS[c.reason] or c.reason or "?"
        if c.reason == "cooldown" and c.remaining then
          local r = c.remaining
          local left = r >= 3600 and string.format("%d h", math.floor(r / 3600)) or string.format("%d min", math.ceil(r / 60))
          reason = string.format(L.SN_REASONS.cooldown, left)
        end
        row.fs:SetText("|cff808080" .. text .. "|r\n" .. tags .. "  |cffc06060(" .. reason .. ")|r")
      end
      row:Show()
    else
      row:Hide()
    end
  end
end

local LANGUAGES = { { "auto", "Auto" }, { "en", "English" }, { "fr", "Français" } }

-- Plain text for the journal and reports: no colors, links shown as [Name].
local function StripCodes(s)
  s = s:gsub("|H.-|h(.-)|h", "%1")
  s = s:gsub("|cn[^:]*:", "")
  s = s:gsub("|c%x%x%x%x%x%x%x%x", "")
  s = s:gsub("|r", "")
  return s
end

---------------------------------------------------------------------------
-- Journal page: newest lines first, a flag button on each
---------------------------------------------------------------------------

local JOURNAL_ROWS = 10

-- Reporting a line: a small window with the line and a "why?" box
local function FlagWithNote(dialog, entry)
  if not entry then return end
  local eb = dialog.editBox or dialog.EditBox or (dialog.GetName and _G[(dialog:GetName() or "") .. "EditBox"])
  local note = eb and eb:GetText() or ""
  note = note:gsub("^%s+", ""):gsub("%s+$", "")
  entry.flagged = true
  entry.flagNote = note ~= "" and note or nil
  KT.RefreshPanel()
  if KT.Homework then KT.Homework.Refresh() end
end
StaticPopupDialogs.WAYFARERSTALES_FLAG_LINE = {
  text = "%s", button1 = OKAY, button2 = CANCEL,
  hasEditBox = true, maxLetters = 250,
  OnShow = function(self)
    local eb = self.editBox or self.EditBox or (self.GetName and _G[(self:GetName() or "") .. "EditBox"])
    if eb then eb:SetText(""); eb:SetFocus() end
  end,
  OnAccept = function(self, entry) FlagWithNote(self, entry) end,
  EditBoxOnEnterPressed = function(self)
    local dialog = self:GetParent()
    FlagWithNote(dialog, dialog.data)
    dialog:Hide()
  end,
  EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

local function BuildJournal(parent)
  local p = CreateFrame("Frame", nil, parent)
  p:SetAllPoints()
  p.page = 1

  p.header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  p.header:SetPoint("TOPLEFT", 10, -9)

  local prev = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  prev:SetSize(28, 20)
  prev:SetPoint("TOPRIGHT", -192, -4)
  prev:SetText("<")
  prev:SetScript("OnClick", function() p.page = math.max(1, p.page - 1); KT.RefreshPanel() end)
  local nxt = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  nxt:SetSize(28, 20)
  nxt:SetPoint("TOPRIGHT", -160, -4)
  nxt:SetText(">")
  nxt:SetScript("OnClick", function() p.page = p.page + 1; KT.RefreshPanel() end)
  local copy = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  copy:SetSize(150, 20)
  copy:SetPoint("TOPRIGHT", -6, -4)
  Label(copy, "UI_JOURNAL_COPY")
  copy:SetScript("OnClick", function() KT.ShowReport() end)
  p.copy = copy -- testers only (see RefreshJournal)

  p.rows = {}
  for i = 1, JOURNAL_ROWS do
    local row = CreateFrame("Frame", nil, p)
    row:SetSize(CONTENT_WIDTH + 24, 38)
    row:SetPoint("TOPLEFT", 6, -30 - (i - 1) * 40)
    local flag = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    flag:SetSize(22, 20)
    flag:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    flag:SetText("!")
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", 0, 0)
    fs:SetPoint("BOTTOMRIGHT", flag, "BOTTOMLEFT", -4, -9)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    flag:SetScript("OnClick", function()
      local e = row.entry
      if not e then return end
      if e.flagged then -- already reported: click again to take it back
        e.flagged, e.flagNote = nil, nil
        KT.RefreshPanel()
        if KT.Homework then KT.Homework.Refresh() end
        return
      end
      local dlg = StaticPopupDialogs.WAYFARERSTALES_FLAG_LINE
      dlg.text, dlg.button1 = L.UI_FLAG_POPUP, L.UI_FLAG_OK
      StaticPopup_Show("WAYFARERSTALES_FLAG_LINE", StripCodes(e.text or ""), nil, e)
    end)
    flag:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_LEFT")
      GameTooltip:AddLine(L.UI_JOURNAL_FLAG_TT, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    flag:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.fs, row.flag = fs, flag
    p.rows[i] = row
  end
  return p
end

local function RefreshJournal(p, db)
  local j = db.journal
  local total = #j
  local pageCount = math.max(1, math.ceil(total / JOURNAL_ROWS))
  if p.page > pageCount then p.page = pageCount end
  local tester = KT.IsTester()
  p.copy:SetShown(tester)
  local flagged = 0
  for _, e in ipairs(j) do if e.flagged then flagged = flagged + 1 end end
  if total == 0 then
    p.header:SetText(L.UI_JOURNAL_EMPTY)
  else
    p.header:SetText(string.format(L.UI_JOURNAL_PAGE, p.page, pageCount)
      .. (flagged > 0 and ("   |cffff6060" .. string.format(L.UI_JOURNAL_FLAGGED, flagged) .. "|r") or ""))
  end
  for i, row in ipairs(p.rows) do
    local e = j[total - (p.page - 1) * JOURNAL_ROWS - (i - 1)]
    row.entry = e
    if e then
      local color = e.flagged and "|cffff6060" or "|cffffd0a0"
      row.fs:SetText(Grey(date("%d/%m %H:%M", e.t)) .. "  " .. color .. StripCodes(e.text or "") .. "|r")
      row.flag:SetText(e.flagged and "x" or "!")
      row.flag:SetShown(tester)
      row:Show()
    else
      row:Hide()
    end
  end
end

---------------------------------------------------------------------------
-- Game-style building blocks: framed bars with their text inside (like the
-- skill bars), and a framed 3D model box (like the character sheet).
---------------------------------------------------------------------------

local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

local function StyledBar(parent, w, h)
  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetSize(w, h)
  bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  bar:SetMinMaxValues(0, 100)
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.55)
  local border = CreateFrame("Frame", nil, bar, BACKDROP_TEMPLATE)
  border:SetPoint("TOPLEFT", -3, 3)
  border:SetPoint("BOTTOMRIGHT", 3, -3)
  border:SetFrameLevel(bar:GetFrameLevel() + 2)
  if border.SetBackdrop then
    border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
    border:SetBackdropBorderColor(0.7, 0.7, 0.7)
  end
  bar.text = border:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
  bar.text:SetShadowOffset(1, -1)
  return bar
end

-- A framed 3D model of a unit ("player", "pet"). Drag it to turn it around.
local function ModelBox(parent, w, h)
  local box = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
  box:SetSize(w, h)
  if box.SetBackdrop then
    box:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 14,
      insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    box:SetBackdropColor(0.04, 0.04, 0.07, 0.95)
    box:SetBackdropBorderColor(0.7, 0.7, 0.7)
  end
  local ok, model = pcall(CreateFrame, "PlayerModel", nil, box)
  if ok and model then
    model:SetPoint("TOPLEFT", 4, -4)
    model:SetPoint("BOTTOMRIGHT", -4, 4)
    model:EnableMouse(true)
    model:SetScript("OnMouseDown", function(self) self.dragX = GetCursorPosition() end)
    model:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    model:SetScript("OnUpdate", function(self)
      if self.dragX then
        local x = GetCursorPosition()
        self:SetFacing((self:GetFacing() or 0) + (x - self.dragX) / 60)
        self.dragX = x
      end
    end)
    box.model = model
  end
  -- show a unit (only reloads the model when it's a different creature)
  function box:ShowUnit(unit)
    if not self.model then return end
    if not UnitExists(unit) then self.model:ClearModel(); self.guid = nil; return end
    local guid = UnitGUID(unit)
    if guid ~= self.guid then
      self.guid = guid
      self.model:SetUnit(unit)
    end
  end
  return box
end


-- Report box: flagged lines with their context, selected and ready to copy.
local reportFrame
function KT.ShowReport()
  api = KT.api
  local lines = {}
  for _, e in ipairs(api.GetDB().journal) do
    if e.flagged then
      lines[#lines + 1] = string.format("[%s] %s / %s (map %s, %s, game time %s, %s) %s.%s: %s",
        date("%Y-%m-%d %H:%M", e.t), tostring(e.zone), tostring(e.sub), tostring(e.mapID),
        e.indoors and "indoors" or "outdoors", tostring(e.gametime), tostring(e.lang),
        tostring(e.module), tostring(e.key), StripCodes(e.text or "")) .. (e.flagNote and ("  >> " .. e.flagNote) or "")
    end
  end
  local proposals = {}
  for _, pr in ipairs(api.GetDB().proposals or {}) do
    proposals[#proposals + 1] = string.format("[%s] %s / %s (map %s at %s,%s%s, %s, %s, %s, %s, %s°C): %s",
      date("%Y-%m-%d %H:%M", pr.t), tostring(pr.zone), tostring(pr.sub), tostring(pr.mapID),
      tostring(pr.x), tostring(pr.y), pr.resting and ", resting" or "", tostring(pr.biome),
      pr.indoors and "indoors" or "outdoors", pr.night and "night" or "day", tostring(pr.weather or "?"),
      tostring(pr.air), pr.text)
  end
  local roofs = {}
  for _, r in ipairs(api.GetDB().roofs or {}) do
    roofs[#roofs + 1] = string.format("%s / %s (map %s at %s,%s)", tostring(r.zone), tostring(r.sub),
      tostring(r.map), tostring(r.x), tostring(r.y))
  end
  local npcs = {}
  for id, e in pairs(api.GetDB().npcs or {}) do
    if not D.NPCS[tonumber(id)] then -- NPCs already identified (D.NPCS) are not listed again
    local kinds = {}
    for k in pairs(e.kinds or {}) do kinds[#kinds + 1] = k end
    table.sort(kinds)
    npcs[#npcs + 1] = string.format("[%s] %s (%s / %s) %s, %s, race: %s, x%d: %s", tostring(id), tostring(e.name),
      tostring(e.zone), tostring(e.sub), e.sex == 3 and "female" or (e.sex == 2 and "male" or "?"),
      tostring(e.ctype or "?"), tostring(e.race or "?"), e.n or 1, table.concat(kinds, ", "))
    end
  end
  table.sort(npcs)
  local notes = {}
  for _, n in ipairs(api.GetDB().fieldNotes or {}) do
    local what = n.kind
    if n.kind == "npc" then what = string.format("npc [%s] %s (%s)", tostring(n.npcID), tostring(n.npcName),
      n.npcSex == 3 and "female" or (n.npcSex == 2 and "male" or "?")) end
    if n.kind == "quest" then what = string.format("quest [%s] %s", tostring(n.questID), tostring(n.questTitle)) end
    notes[#notes + 1] = string.format("[%s] %s: %s | %s / %s (map %s at %s,%s, %s)", date("%Y-%m-%d %H:%M", n.t),
      what, n.text or "-", tostring(n.zone), tostring(n.sub), tostring(n.map), tostring(n.x), tostring(n.y),
      n.indoors and "indoors" or "outdoors")
  end
  local quests = {}
  for _, q in ipairs(api.GetDB().questsDone or {}) do
    quests[#quests + 1] = string.format("[%s] [%s] %s (%s)", date("%Y-%m-%d %H:%M", q.t), tostring(q.id), tostring(q.title), tostring(q.zone))
  end
  local text = "Wayfarer's Tales report (" .. date("%Y-%m-%d") .. ", " .. tostring(GetLocale()) .. ")\n"
    .. (#lines > 0 and table.concat(lines, "\n") or L.UI_JOURNAL_NOFLAGS)
    .. (#proposals > 0 and ("\n\n" .. L.UI_REPORT_PROPOSALS .. "\n" .. table.concat(proposals, "\n")) or "")
    .. (#roofs > 0 and ("\n\n" .. L.UI_REPORT_ROOFS .. "\n" .. table.concat(roofs, "\n")) or "")
    .. (#notes > 0 and ("\n\n" .. L.UI_REPORT_NOTES .. "\n" .. table.concat(notes, "\n")) or "")
    .. (#npcs > 0 and ("\n\n" .. L.UI_REPORT_NPCS .. "\n" .. table.concat(npcs, "\n")) or "")
    .. (#quests > 0 and ("\n\n" .. L.UI_REPORT_QUESTS .. "\n" .. table.concat(quests, "\n")) or "")
    .. (function()
      local errs = {}
      for _, e in ipairs(api.GetDB().errors or {}) do
        errs[#errs + 1] = string.format("[%s, v%s, x%d] %s", date("%Y-%m-%d %H:%M", e.last), tostring(e.version),
          e.count or 1, e.msg)
      end
      return #errs > 0 and ("\n\n--- Errors ---\n" .. table.concat(errs, "\n")) or ""
    end)()
    .. "\n\n" .. L.UI_REPORT_IDEAS .. "\n"

  if not reportFrame then
    local ok, f = pcall(CreateFrame, "Frame", "WayfarersTalesReport", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not f then
      f = CreateFrame("Frame", "WayfarersTalesReport", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
      if f.SetBackdrop then
        f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
          edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
          insets = { left = 11, right = 12, top = 12, bottom = 11 } })
      end
      local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
      close:SetPoint("TOPRIGHT", -4, -4)
    end
    if f.TitleText then f.TitleText:SetText("Wayfarer's Tales") end
    f:SetSize(480, 320)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "WayfarersTalesReport")
    f.help = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.help:SetPoint("TOPLEFT", 14, -30)
    f.help:SetPoint("TOPRIGHT", -14, -30)
    f.help:SetJustifyH("LEFT")
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -52)
    scroll:SetPoint("BOTTOMRIGHT", -34, 14)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(420)
    edit:SetAutoFocus(false)
    edit:SetScript("OnEscapePressed", function() f:Hide() end)
    scroll:SetScrollChild(edit)
    f.edit = edit
    reportFrame = f
  end
  reportFrame.help:SetText(L.UI_JOURNAL_COPY_HELP)
  reportFrame.edit:SetText(text)
  reportFrame:Show()
  reportFrame.edit:SetFocus()
  reportFrame.edit:HighlightText()
end

---------------------------------------------------------------------------
-- The window's pages (0.55). Each module has its tab with, from top to bottom:
-- a header with its on/off box, what it shows, its settings, a short guide.
-- Blocks are stacked by page:Layout(), which skips hidden ones.
---------------------------------------------------------------------------

local PAGE_W = 566
local segmented = {} -- button rows, relabelled when the language changes

local BOX_BACKDROP = { bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 } }

local function Box(parent, h)
  local f = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
  f:SetSize(PAGE_W, h or 40)
  if f.SetBackdrop then
    f:SetBackdrop(BOX_BACKDROP)
    f:SetBackdropColor(0.13, 0.1, 0.07, 0.85)
    f:SetBackdropBorderColor(0.5, 0.4, 0.22)
  end
  return f
end

local function ScrollPage(parent)
  local page = CreateFrame("Frame", nil, parent)
  page:SetAllPoints()
  local scroll = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 0, -4)
  scroll:SetPoint("BOTTOMRIGHT", -26, 4)
  local p = CreateFrame("Frame", nil, scroll)
  p:SetSize(PAGE_W + 8, 10)
  scroll:SetScrollChild(p)
  page.p, page.blocks = p, {}
  function page:Add(block, gap)
    self.blocks[#self.blocks + 1] = { block, gap or 10 }
    return block
  end
  function page:Layout()
    local y = 6
    for _, b in ipairs(self.blocks) do
      local w = b[1]
      if w:IsShown() then
        w:ClearAllPoints()
        w:SetPoint("TOPLEFT", p, "TOPLEFT", 4, -y)
        local h
        if w.Fit then h = w:Fit()
        elseif w.GetStringHeight then h = w:GetStringHeight()
        else h = w:GetHeight() end
        y = y + (h or 0) + b[2]
      end
    end
    p:SetHeight(y + 10)
  end
  return page
end

-- A paragraph of text in a page
local function Para(page, font, gap)
  local fs = page.p:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
  fs:SetWidth(PAGE_W - 8)
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  fs:SetSpacing(2)
  return page:Add(fs, gap)
end

-- Title of the tab, with the module's on/off box on the right
local function ModuleHeader(page, titleKey, module, onToggle)
  local h = CreateFrame("Frame", nil, page.p)
  h:SetSize(PAGE_W, 28)
  local t = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  t:SetPoint("LEFT", 2, 0)
  Label(t, titleKey)
  if module then
    local lt = h:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lt:SetPoint("RIGHT", -4, 0)
    Label(lt, "UI_MODULE_ON")
    local cb = CreateFrame("CheckButton", nil, h, "UICheckButtonTemplate")
    cb:SetPoint("RIGHT", lt, "LEFT", 0, 0)
    if cb.Text then cb.Text:SetText("") end
    if cb.text then cb.text:SetText("") end
    cb:SetScript("OnClick", function(self)
      local on = self:GetChecked() and true or false
      api.GetDB().modules[module] = on
      if onToggle then onToggle(on) end
      KT.RefreshPanel()
    end)
    h.check, h.module = cb, module
  end
  local line = h:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(0.5, 0.4, 0.22, 0.8)
  line:SetHeight(1)
  line:SetPoint("BOTTOMLEFT", 0, -3)
  line:SetPoint("BOTTOMRIGHT", 0, -3)
  function h:Refresh()
    if self.check then self.check:SetChecked(api.GetDB().modules[self.module] ~= false) end
  end
  return page:Add(h, 12)
end

-- A row of buttons, one lit (like the old options)
local function Segmented(parent, x, y, items, onPick, width)
  local row = { buttons = {} }
  width = width or 130
  for i, it in ipairs(items) do
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 24)
    b:SetPoint("TOPLEFT", x + (i - 1) * (width + 4), y)
    b.value, b.textOf = it[1], it[2]
    b:SetText(it[2]())
    b:SetScript("OnClick", function()
      onPick(it[1])
      KT.RefreshPanel()
    end)
    row.buttons[i] = b
  end
  function row:Select(v)
    for _, b in ipairs(self.buttons) do
      if b.value == v then b:LockHighlight() else b:UnlockHighlight() end
    end
  end
  function row:Relabel()
    for _, b in ipairs(self.buttons) do b:SetText(b.textOf()) end
  end
  segmented[#segmented + 1] = row
  return row
end

local function CheckBox(parent, x, y, key, textKey, onChange)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", x, y)
  if cb.Text then cb.Text:SetText("") end
  if cb.text then cb.text:SetText("") end
  local t = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  t:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  Label(t, textKey)
  cb.key = key
  cb:SetScript("OnClick", function(self)
    api.GetDB().settings[key] = self:GetChecked() and true or false
    if onChange then onChange() end
  end)
  function cb:Refresh() self:SetChecked(api.GetDB().settings[key] and true or false) end
  return cb
end

local function BoxLabel(box, x, y, key)
  local fs = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  fs:SetPoint("TOPLEFT", x, y)
  Label(fs, key)
  return fs
end

-- "How it works", at the bottom of a tab
local function GuideBox(page)
  local box = Box(page.p, 40)
  if box.SetBackdropColor then box:SetBackdropColor(0.1, 0.08, 0.06, 0.9) end
  local head = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  head:SetPoint("TOPLEFT", 10, -9)
  Label(head, "UI_GUIDE_HEAD")
  local t = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  t:SetPoint("TOPLEFT", 10, -28)
  t:SetWidth(PAGE_W - 22)
  t:SetJustifyH("LEFT")
  t:SetSpacing(3)
  box.text = t
  function box:Fit()
    local h = 38 + t:GetStringHeight()
    self:SetHeight(h)
    return h
  end
  return page:Add(box, 10)
end

local function Ago(t)
  local d = time() - (t or time())
  if d < 60 then return L.UI_AGO_NOW end
  if d < 3600 then return string.format(L.UI_AGO_MIN, math.floor(d / 60)) end
  if d < 86400 then return string.format(L.UI_AGO_HOURS, math.floor(d / 3600)) end
  return string.format(L.UI_AGO_DAYS, math.floor(d / 86400))
end

local function Hex(c)
  return string.format("|cff%02x%02x%02x", math.floor(c[1] * 255), math.floor(c[2] * 255), math.floor(c[3] * 255))
end

---------------------------------------------------------------------------
-- Body (Elements): your character, five gauges, where you are
---------------------------------------------------------------------------

-- The tips, each label in the color of its gauge
local function TipsText()
  local E = KT.Elements
  local C = {}
  if E then
    C = { E.TEMP_COLORS.hot, E.TEMP_COLORS.cold, E.BAR_COLORS.wet, E.BAR_COLORS.thirst,
      E.BAR_COLORS.hunger, E.BAR_COLORS.energy, E.BAR_COLORS.wet }
  end
  local out, i = {}, 0
  for line in (KT.G(L.EL_PAGE_TIPS) .. "\n"):gmatch("(.-)\n") do
    i = i + 1
    local label, rest = line:match("^(.-)( ?: .*)$")
    if label and C[i] then line = Hex(C[i]) .. label .. "|r" .. rest end
    out[#out + 1] = line
  end
  return table.concat(out, "\n")
end

local function BuildBody(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, "EL_TITLE", "elements", function()
    if KT.Elements then KT.Elements.UpdateIcons(); KT.Elements.UpdateThermo() end
  end)
  local top = CreateFrame("Frame", nil, page.p)
  top:SetSize(PAGE_W, 232)
  page.modelBox = ModelBox(top, 150, 228)
  page.modelBox:SetPoint("TOPLEFT", 0, 0)
  local x = 166
  page.intro = top:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  page.intro:SetPoint("TOPLEFT", x, -4)
  page.intro:SetWidth(PAGE_W - x - 6)
  page.intro:SetJustifyH("LEFT")
  page.bars = {}
  for i = 1, 5 do
    local bar = StyledBar(top, PAGE_W - x - 16, 18)
    bar:SetPoint("TOPLEFT", x + 4, -50 - (i - 1) * 36)
    page.bars[i] = bar
  end
  page:Add(top, 8)
  page.here = Para(page, "GameFontHighlight", 10)

  local set = Box(page.p, 92)
  BoxLabel(set, 10, -10, "UI_OPT_BODYSTYLE")
  page.bodyStyle = Segmented(set, 10, -30, {
    { "none", function() return L.UI_BODYSTYLE.none end },
    { "icons", function() return L.UI_BODYSTYLE.icons end },
    { "bars", function() return L.UI_BODYSTYLE.bars end },
  }, function(v)
    api.GetDB().settings.bodyStyle = v
    if KT.Elements then KT.Elements.UpdateIcons() end
  end)
  page.thermo = CheckBox(set, 6, -58, "showThermo", "UI_OPT_THERMO", function()
    if KT.Elements then KT.Elements.UpdateThermo() end
  end)
  page.settings = page:Add(set, 10)
  page.guide = GuideBox(page)
  return page
end

local function RefreshBody(page)
  local db = api.GetDB()
  local E = KT.Elements
  local st = E and E.GetState()
  local on = KT.ModuleOn("elements") and st ~= nil
  page.header:Refresh()
  page.modelBox:ShowUnit("player")
  local rows = on and E.Rows() or {}
  for i, bar in ipairs(page.bars) do
    local r = rows[i]
    bar:SetShown(r ~= nil)
    if r then
      bar.text:SetText(r[1])
      E.ApplyBar(bar, r)
    end
  end
  page.intro:SetText(on and L.EL_PAGE_INTRO or L.EL_OFF)
  page.here:SetShown(on)
  page.settings:SetShown(on)
  page.guide:SetShown(on)
  if on then
    page.here:SetText(E.HereText())
    page.guide.text:SetText(TipsText())
    page.bodyStyle:Select(db.settings.bodyStyle or "none")
    page.thermo:Refresh()
  end
  page:Layout()
end

---------------------------------------------------------------------------
-- Companion (Kindred, hunters): your pet, its story, how often it speaks up
---------------------------------------------------------------------------

local function CompanionText(pet)
  local db = api.GetDB()
  local lines = {}
  local function add(s) lines[#lines + 1] = s or "" end

  if pet then
    local idx = api.TierIndex(math.floor(pet.affection))
    if D.TIERS[idx + 1] then
      add(Grey(string.format(L.TT_NEXT, L.TIERS[idx + 1], D.TIERS[idx + 1])))
      add("")
    end
    if pet.mood and pet.mood.date == api.Today() then
      add(string.format(L.TT_MOOD, L.MOODS[pet.mood.key] or "?"))
    end
    local t = pet.tastes
    if t then
      add(string.format(L.TT_FAVORITE, t.favoriteKnown and L.FOOD_KINDS[t.favorite] or L.TT_SECRET))
      add(string.format(L.TT_DISLIKE, t.dislikeKnown and L.FOOD_KINDS[t.dislike] or "???"))
    end
    if pet.loyaltyName then add(string.format(L.TT_LOYALTY, api.CleanLoyaltyName(pet.loyaltyName))) end
    if pet.happiness then add(string.format(L.TT_HAPPINESS, L.HAPPINESS[pet.happiness] or "?")) end

    local s = pet.stats
    add("")
    add(Head(L.UI_TOGETHER))
    add(string.format(L.UI_STATS, api.FormatDuration(s.minutes or 0), s.kills or 0, s.feeds or 0,
      s.meals or 0, s.campfires or 0, s.emotes or 0))
    -- (memories have their own scrolling box below)
  else
    add(L.CMD_NO_PET)
  end

  -- Other pets of this character
  local prefix = api.CharKey() .. ":"
  local others = {}
  for key, rec in pairs(db.pets) do
    if rec ~= pet and key:sub(1, #prefix) == prefix then others[#others + 1] = rec end
  end
  if #others > 0 then
    table.sort(others, function(a, b) return a.affection > b.affection end)
    add("")
    add(Head(L.UI_OTHERS))
    for _, r in ipairs(others) do
      local i = api.TierIndex(math.floor(r.affection))
      add(r.name .. Grey(" (" .. (r.family or "?") .. ")") .. " - " .. Pink(L.TIERS[i]) .. " " .. math.floor(r.affection))
    end
  end
  return table.concat(lines, "\n")
end

local function BuildCompanion(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, "UI_COMPANION_TITLE", "kindred", function(on)
    api.UpdateHeart()
    if on then api.Rescan() end
  end)
  local top = CreateFrame("Frame", nil, page.p)
  top:SetSize(PAGE_W, 172)
  page.modelBox = ModelBox(top, 160, 170)
  page.modelBox:SetPoint("TOPLEFT", 0, 0)
  local hx = 178
  page.name = top:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  page.name:SetPoint("TOPLEFT", hx, -8)
  page.sub = top:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  page.sub:SetPoint("TOPLEFT", page.name, "BOTTOMLEFT", 0, -4)
  page.tier = top:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  page.tier:SetPoint("TOPLEFT", page.sub, "BOTTOMLEFT", 0, -12)
  page.tier:SetTextColor(1, 0.56, 0.69)
  page.desc = top:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  page.desc:SetPoint("TOPLEFT", page.tier, "BOTTOMLEFT", 0, -6)
  page.desc:SetWidth(PAGE_W - hx - 10)
  page.desc:SetJustifyH("LEFT")
  page.bar = StyledBar(top, PAGE_W - hx - 16, 18)
  page.bar:SetPoint("TOPLEFT", hx + 3, -136)
  page.bar:SetStatusBarColor(1, 0.45, 0.62)
  page.top = page:Add(top, 10)
  page.text = Para(page, "GameFontHighlight", 12)

  -- Memories: a box of its own that scrolls, newest first
  local mem = Box(page.p, 200)
  local mh = mem:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  mh:SetPoint("TOPLEFT", 10, -9)
  Label(mh, "UI_MEMORIES")
  local sc = CreateFrame("ScrollFrame", nil, mem, "UIPanelScrollFrameTemplate")
  sc:SetPoint("TOPLEFT", 8, -28)
  sc:SetPoint("BOTTOMRIGHT", -28, 8)
  local child = CreateFrame("Frame", nil, sc)
  child:SetSize(PAGE_W - 44, 10)
  sc:SetScrollChild(child)
  local mfs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  mfs:SetPoint("TOPLEFT", 2, 0)
  mfs:SetWidth(PAGE_W - 48)
  mfs:SetJustifyH("LEFT")
  mfs:SetSpacing(2)
  function mem:SetMemories(pet)
    local lines = {}
    if #pet.memories == 0 then lines[1] = Grey(L.CMD_NO_MEMORY) end
    for i = #pet.memories, 1, -1 do -- newest first
      local m = pet.memories[i]
      lines[#lines + 1] = Grey(date("%Y-%m-%d", m.t)) .. "  " .. api.MemoryText(m, pet)
    end
    mfs:SetText(table.concat(lines, "\n"))
    child:SetHeight(mfs:GetStringHeight() + 6)
  end
  page.memories = page:Add(mem, 12)

  local set = Box(page.p, 120)
  BoxLabel(set, 10, -10, "UI_OPT_CHATTY")
  page.chatty = Segmented(set, 10, -30, {
    { 0, function() return L.UI_CHATTY[0] end }, { 1, function() return L.UI_CHATTY[1] end },
    { 2, function() return L.UI_CHATTY[2] end }, { 3, function() return L.UI_CHATTY[3] end },
  }, function(v) api.GetDB().settings.chatty = v end)
  page.chattyDesc = set:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  page.chattyDesc:SetPoint("TOPLEFT", 12, -60)
  page.chattyDesc:SetWidth(PAGE_W - 24)
  page.chattyDesc:SetJustifyH("LEFT")
  page.sound = CheckBox(set, 6, -86, "sound", "UI_OPT_SOUND")
  page.settings = page:Add(set, 10)
  page.guide = GuideBox(page)
  return page
end

local function RefreshCompanion(page)
  local db = api.GetDB()
  page.header:Refresh()
  local on = db.modules.kindred ~= false
  local pet = on and api.GetPet() or nil
  page.top:SetShown(pet ~= nil)
  page.memories:SetShown(pet ~= nil)
  if pet then page.memories:SetMemories(pet) end
  page.settings:SetShown(on)
  page.guide:SetShown(on)
  if not on then
    page.text:SetText(L.UI_KINDRED_OFF)
  else
    if pet then
      local idx = api.TierIndex(math.floor(pet.affection))
      page.modelBox:ShowUnit("pet")
      page.name:SetText(pet.name)
      local sub = pet.family or "?"
      if pet.level then sub = sub .. ", " .. L.UI_LEVEL .. " " .. pet.level end
      page.sub:SetText(sub)
      page.tier:SetText(L.TIERS[idx])
      page.desc:SetText(L.TIER_DESC[idx])
      page.bar:SetValue(pet.affection)
      page.bar.text:SetText(string.format(L.TT_SCORE, math.floor(pet.affection)))
    end
    page.text:SetText(CompanionText(pet))
    local chatty = db.settings.chatty or 2
    page.chatty:Select(chatty)
    page.chattyDesc:SetText(L.UI_CHATTY_DESC[chatty] or "")
    page.sound:Refresh()
    page.guide.text:SetText(L.UI_KINDRED_GUIDE)
  end
  page:Layout()
end

---------------------------------------------------------------------------
-- Ambiance (Senses): the last line, how often lines come
---------------------------------------------------------------------------

local devSenses -- the dev window with the situation and every possible line

function KT.ToggleSensesDev()
  if not KT.IsDev() then return end
  if not devSenses then
    local ok, f = pcall(CreateFrame, "Frame", "WayfarersTalesSensesDev", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not f then
      f = CreateFrame("Frame", "WayfarersTalesSensesDev", UIParent, BACKDROP_TEMPLATE)
      if f.SetBackdrop then
        f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
          edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
          insets = { left = 11, right = 12, top = 12, bottom = 11 } })
      end
      local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
      close:SetPoint("TOPRIGHT", -4, -4)
    end
    if f.TitleText then f.TitleText:SetText(L.SN_DEV_BUTTON .. " (dev)") end
    f:SetSize(580, 640)
    f:SetPoint("CENTER", 120, 0)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "WayfarersTalesSensesDev")
    local holder = CreateFrame("Frame", nil, f)
    holder:SetPoint("TOPLEFT", 10, -30)
    holder:SetPoint("BOTTOMRIGHT", -10, 10)
    f.page = BuildSenses(holder)
    -- what's around you changes: refresh every few seconds while it's open
    local acc = 0
    f:SetScript("OnUpdate", function(_, dt)
      acc = acc + dt
      if acc >= 3 then
        acc = 0
        pcall(RefreshSenses, f.page)
      end
    end)
    devSenses = f
    f:Hide()
  end
  devSenses:SetShown(not devSenses:IsShown())
  if devSenses:IsShown() then pcall(RefreshSenses, devSenses.page) end
end

local function BuildAmbiance(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, "UI_TAB_SENSES", "senses")
  page.intro = Para(page, "GameFontHighlight", 10)

  local last = Box(page.p, 60)
  if last.SetBackdropColor then last:SetBackdropColor(0.06, 0.05, 0.04, 0.9) end
  last.meta = last:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  last.meta:SetPoint("TOPLEFT", 10, -9)
  last.text = last:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  last.text:SetPoint("TOPLEFT", 10, -26)
  last.text:SetWidth(PAGE_W - 22)
  last.text:SetJustifyH("LEFT")
  last.text:SetSpacing(2)
  last.text:SetTextColor(1, 0.82, 0.63)
  function last:Fit()
    local h = 36 + self.text:GetStringHeight()
    self:SetHeight(h)
    return h
  end
  page.last = page:Add(last, 10)

  local set = Box(page.p, 62)
  BoxLabel(set, 10, -10, "UI_OPT_RHYTHM")
  page.rhythm = Segmented(set, 10, -30, {
    { 0, function() return L.UI_RHYTHM[0] end }, { 1, function() return L.UI_RHYTHM[1] end },
    { 2, function() return L.UI_RHYTHM[2] end }, { 3, function() return L.UI_RHYTHM[3] end },
  }, function(v) api.GetDB().settings.sensesRhythm = v end)
  page.settings = page:Add(set, 12)

  if KT.IsDev() then
    local dev = CreateFrame("Button", nil, page.p, "UIPanelButtonTemplate")
    dev:SetSize(180, 24)
    Label(dev, "SN_DEV_BUTTON")
    dev:SetScript("OnClick", function() KT.ToggleSensesDev() end)
    page:Add(dev, 10)
  end
  return page
end

local function RefreshAmbiance(page)
  local db = api.GetDB()
  page.header:Refresh()
  local on = KT.ModuleOn("senses")
  page.intro:SetText(on and L.SN_PAGE_INTRO or L.SN_OFF)
  page.last:SetShown(on)
  page.settings:SetShown(on)
  if on then
    local e
    for i = #db.journal, 1, -1 do
      local j = db.journal[i]
      if j.module == "senses" and j.key ~= "newTitle" then e = j break end
    end
    if e then
      local where = tostring(e.zone or "?")
      if e.sub and e.sub ~= "" then where = e.sub end
      page.last.meta:SetText(string.format(L.SN_LAST, where, Ago(e.t)))
      page.last.text:SetText(StripCodes(e.text or ""))
    else
      page.last.meta:SetText("")
      page.last.text:SetText(L.SN_LAST_NONE)
    end
    page.rhythm:Select(db.settings.sensesRhythm or 2)
  end
  page:Layout()
end

---------------------------------------------------------------------------
-- Carnet (discoveries): your title, then the travel log
---------------------------------------------------------------------------

local function BuildTravels(parent)
  local page = ScrollPage(parent)
  local box = Box(page.p, 72)
  local small = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  small:SetPoint("TOPLEFT", 12, -10)
  Label(small, "DISC_YOUR_TITLE")
  page.title = box:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  page.title:SetPoint("TOPLEFT", 12, -28)
  page.title:SetTextColor(1, 0.56, 0.69)
  page.bar = StyledBar(box, 300, 14)
  page.bar:SetPoint("TOPRIGHT", -16, -16)
  page.bar:SetStatusBarColor(0.95, 0.75, 0.2)
  page.next = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  page.next:SetPoint("TOPLEFT", page.bar, "BOTTOMLEFT", 0, -8)
  page:Add(box, 12)
  page.text = Para(page, "GameFontHighlight", 10)
  return page
end

local function RefreshTravels(page)
  local Di = KT.Discovery
  if Di then
    local score = Di.Score()
    local name, at, nextName, nextAt = Di.Title(score)
    page.title:SetText(name)
    page.bar:SetMinMaxValues(at or 0, nextAt or ((at or 0) + 1))
    page.bar:SetValue(nextAt and score or ((at or 0) + 1))
    page.bar.text:SetText(nextAt and (score .. " / " .. nextAt) or tostring(score))
    page.next:SetText(nextName and string.format(L.DISC_NEXT, nextName, nextAt) or L.DISC_TOP)
  end
  page.text:SetText(Di and Di.PageText() or "")
  page:Layout()
end

---------------------------------------------------------------------------
-- Options: what's left once each module has its own settings
---------------------------------------------------------------------------

local function BuildOptions(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, "UI_TAB_OPTIONS")
  local box = CreateFrame("Frame", nil, page.p)
  box:SetSize(PAGE_W, 190)
  page.minimap = CheckBox(box, 0, 0, "minimap", "UI_OPT_MINIMAP", function() KT.UpdateMinimapButton() end)
  BoxLabel(box, 4, -40, "UI_OPT_LANGUAGE")
  page.lang = Segmented(box, 2, -60, {
    { "auto", function() return "Auto" end }, { "en", function() return "English" end },
    { "fr", function() return "Français" end },
  }, function(v)
    api.GetDB().settings.language = v
    KT.ApplyLanguage()
    KT.RelabelPanel()
    api.UpdateHeart() -- also refreshes this window
  end)
  BoxLabel(box, 4, -100, "UI_OPT_GENDER")
  page.gender = Segmented(box, 2, -120, {
    { "auto", function() return L.UI_GENDER_AUTO end }, { "m", function() return L.UI_GENDER_M end },
    { "f", function() return L.UI_GENDER_F end }, { "n", function() return L.UI_GENDER_N end },
  }, function(v) api.GetDB().settings.gender = v end)
  if KT.IsDev() then
    page.debug = CheckBox(box, 0, -156, "debug", "UI_OPT_DEBUG")
  end
  page:Add(box, 10)
  page.note = Para(page, "GameFontDisableSmall", 10)
  return page
end

local function RefreshOptions(page)
  local s = api.GetDB().settings
  page.minimap:Refresh()
  if page.debug then page.debug:Refresh() end
  page.lang:Select(s.language or "auto")
  page.gender:Select(s.gender or "auto")
  page.note:SetText(L.UI_OPT_NOTE)
  page:Layout()
end

---------------------------------------------------------------------------
-- The window: a header with your title, tabs on top, the pages
---------------------------------------------------------------------------

local header, tabTemplate

local function SelectTabButton(b, on)
  if tabTemplate ~= "plain" then
    local fn = on and PanelTemplates_SelectTab or PanelTemplates_DeselectTab
    if fn and pcall(fn, b) then return end
  end
  if on then b:LockHighlight() else b:UnlockHighlight() end
end

local function MakeTab(f, i, prev, key)
  local name = "WayfarersTalesFrameTab" .. i
  local ok, b = pcall(CreateFrame, "Button", name, f, "PanelTopTabButtonTemplate")
  if ok and b then
    tabTemplate = tabTemplate or "top"
  else
    ok, b = pcall(CreateFrame, "Button", name .. "Old", f, "TabButtonTemplate")
    if ok and b then
      tabTemplate = tabTemplate or "old"
    else
      b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
      b:SetSize(92, 24)
      tabTemplate = "plain"
    end
  end
  Label(b, key)
  if tabTemplate ~= "plain" then pcall(PanelTemplates_TabResize, b, 0) end
  if prev then
    b:SetPoint("LEFT", prev, "RIGHT", tabTemplate == "old" and -12 or 4, 0)
  else
    b:SetPoint("TOPLEFT", 14, -84)
  end
  return b
end

local function RefreshHeader()
  if not header or not KT.Discovery then return end
  local score = KT.Discovery.Score()
  local name, at, _, nextAt = KT.Discovery.Title(score)
  header.line:SetText(string.format(L.DISC_TITLE_LINE, Pink(name), score))
end

local function Build()
  local ok, f = pcall(CreateFrame, "Frame", "WayfarersTalesFrame", UIParent, "BasicFrameTemplateWithInset")
  if not ok or not f then
    f = CreateFrame("Frame", "WayfarersTalesFrame", UIParent, BACKDROP_TEMPLATE)
    if f.SetBackdrop then
      f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
      })
    end
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
  end
  f:SetSize(630, 680)
  f:SetPoint("CENTER")
  f:SetFrameStrata("DIALOG")
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()
  tinsert(UISpecialFrames, "WayfarersTalesFrame") -- Escape closes it
  if f.TitleText then f.TitleText:SetText("") end -- the big title is in the header

  -- Header: icon, name, your title and discoveries (click: the Carnet)
  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetSize(40, 40)
  icon:SetPoint("TOPLEFT", 16, -30)
  icon:SetTexture(Icon())
  local name = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
  name:SetText("Wayfarer's Tales")
  local tb = CreateFrame("Button", nil, f)
  tb:SetSize(320, 24)
  tb:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
  tb.line = tb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  tb.line:SetPoint("TOPLEFT", 0, 0)
  tb.line:SetTextColor(0.72, 0.68, 0.6)
  tb:SetScript("OnClick", function() KT.ShowTab("travels") end)
  tb:SetScript("OnEnter", function(self)
    if not KT.Discovery then return end
    local score = KT.Discovery.Score()
    local _, _, nextName, nextAt = KT.Discovery.Title(score)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:AddLine(nextName and string.format(L.DISC_NEXT, nextName, nextAt) or L.DISC_TOP, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  tb:SetScript("OnLeave", function() GameTooltip:Hide() end)
  header = tb

  -- Tabs (Companion only for hunters)
  local list = { { "body", "UI_TAB_BODY" } }
  if select(2, UnitClass("player")) == "HUNTER" then list[#list + 1] = { "companion", "UI_TAB_COMPANION" } end
  for _, t in ipairs({ { "senses", "UI_TAB_SENSES" }, { "travels", "UI_TAB_TRAVELS" },
    { "journal", "UI_TAB_JOURNAL" }, { "options", "UI_TAB_OPTIONS" } }) do list[#list + 1] = t end
  local prev
  for i, t in ipairs(list) do
    local b = MakeTab(f, i, prev, t[2])
    b:SetScript("OnClick", function() KT.ShowTab(t[1]) end)
    tabs[t[1]] = b
    prev = b
  end

  local content = CreateFrame("Frame", nil, f)
  content:SetPoint("TOPLEFT", 12, -116)
  content:SetPoint("BOTTOMRIGHT", -10, 10)
  local line = content:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(0.5, 0.4, 0.22, 0.6)
  line:SetHeight(1)
  line:SetPoint("TOPLEFT", 0, 2)
  line:SetPoint("TOPRIGHT", 0, 2)

  pages.body = BuildBody(content)
  if tabs.companion then pages.companion = BuildCompanion(content) end
  pages.senses = BuildAmbiance(content)
  pages.travels = BuildTravels(content)
  pages.journal = BuildJournal(content)
  pages.options = BuildOptions(content)

  frame = f
end

function KT.RelabelPanel()
  for _, w in ipairs(labelled) do w:SetText(L[w.labelKey] or w.labelKey) end
  for _, row in ipairs(segmented) do row:Relabel() end
  if tabTemplate and tabTemplate ~= "plain" then
    for _, b in pairs(tabs) do pcall(PanelTemplates_TabResize, b, 0) end
  end
  if KT.Homework then KT.Homework.Refresh() end
end

function KT.RefreshPanel()
  if devSenses and devSenses:IsShown() then pcall(RefreshSenses, devSenses.page) end
  if not frame or not frame:IsShown() then return end
  local db = api.GetDB()
  RefreshHeader()
  if currentTab == "journal" then RefreshJournal(pages.journal, db)
  elseif currentTab == "body" then RefreshBody(pages.body)
  elseif currentTab == "companion" and pages.companion then RefreshCompanion(pages.companion)
  elseif currentTab == "senses" then RefreshAmbiance(pages.senses)
  elseif currentTab == "travels" then RefreshTravels(pages.travels)
  elseif currentTab == "options" then RefreshOptions(pages.options)
  end
end

function KT.ShowTab(name)
  if not pages[name] then name = "body" end
  currentTab = name
  for k, p in pairs(pages) do p:SetShown(k == name) end
  -- 3D models must be reloaded after being hidden; bars start at their current value
  for _, p in pairs(pages) do
    if p.modelBox then p.modelBox.guid = nil end
    for _, bar in ipairs(p.bars or {}) do bar.shown = nil end
  end
  for k, b in pairs(tabs) do SelectTabButton(b, k == name) end
  KT.RefreshPanel()
end

function KT.TogglePanel(tab)
  api = KT.api
  if not frame then Build() end
  if tab and not pages[tab] then tab = nil end -- (old tabs like the guide)
  if frame:IsShown() and (not tab or tab == currentTab) then
    frame:Hide()
    return
  end
  frame:Show()
  KT.ShowTab(tab or currentTab)
end


---------------------------------------------------------------------------
-- Minimap button (drag it around the minimap)
---------------------------------------------------------------------------

local function PositionMinimap()
  local angle = math.rad(api.GetDB().settings.minimapAngle or 200)
  local r = Minimap:GetWidth() / 2 + 5
  mm:ClearAllPoints()
  mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

function KT.UpdateMinimapButton()
  if not mm then return end
  mm:SetShown(api.GetDB().settings.minimap ~= false)
end

function KT.CreateMinimapButton()
  api = KT.api
  if mm or not Minimap then return end
  mm = CreateFrame("Button", "WayfarersTalesMinimapButton", Minimap)
  mm:SetSize(31, 31)
  mm:SetFrameStrata("MEDIUM")
  mm:SetFrameLevel(8)
  mm:RegisterForClicks("AnyUp")
  mm:RegisterForDrag("LeftButton")
  mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local bg = mm:CreateTexture(nil, "BACKGROUND")
  bg:SetSize(20, 20)
  bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  bg:SetPoint("TOPLEFT", 7, -5)
  local icon = mm:CreateTexture(nil, "ARTWORK")
  icon:SetSize(17, 17)
  icon:SetTexture(Icon())
  icon:SetPoint("TOPLEFT", 7, -6)
  pcall(icon.SetMask, icon, "Interface\\CharacterFrame\\TempPortraitAlphaMask")
  local border = mm:CreateTexture(nil, "OVERLAY")
  border:SetSize(53, 53)
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT")

  mm:SetScript("OnClick", function() KT.TogglePanel() end)
  mm:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Wayfarer's Tales", 1, 0.56, 0.69)
    GameTooltip:AddLine(L.UI_MINIMAP_CLICK, 1, 1, 1)
    GameTooltip:AddLine(L.UI_MINIMAP_DRAG, 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end)
  mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
  mm:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      px, py = px / scale, py / scale
      api.GetDB().settings.minimapAngle = math.deg(math.atan2(py - my, px - mx))
      PositionMinimap()
    end)
  end)
  mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

  PositionMinimap()
  KT.UpdateMinimapButton()
end
