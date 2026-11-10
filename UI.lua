-- Wayfarer's Tales - window (/wt), journal, report box, minimap button.
-- Pages are mostly plain text in a scroll area: simple and hard to break.

local _, KT = ...
local L, D = KT.L, KT.Data
local api -- KT.api, set by Core.lua; read at runtime

local frame, mm
local tabs, pages = {}, {}
local currentTab = "companion"
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

function KT.RelabelPanel()
  for _, w in ipairs(labelled) do w:SetText(L[w.labelKey] or w.labelKey) end
  if KT.Homework then KT.Homework.Refresh() end
  local p = pages.options
  if p then
    for n, b in pairs(p.chattyButtons) do b:SetText(L.UI_CHATTY[n]) end
    for n, b in pairs(p.rhythmButtons) do b:SetText(L.UI_RHYTHM[n]) end
    for st, b in pairs(p.styleButtons) do b:SetText(L.UI_STYLE[st]) end
    for bs, b in pairs(p.bodyStyleButtons) do b:SetText(L.UI_BODYSTYLE[bs]) end
  end
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

local function BuildJournal(parent)
  local p = CreateFrame("Frame", nil, parent)
  p:SetAllPoints()
  p.page = 1

  p.header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  p.header:SetPoint("TOPLEFT", 10, -9)

  local prev = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  prev:SetSize(28, 20)
  prev:SetPoint("TOPRIGHT", -152, -4)
  prev:SetText("<")
  prev:SetScript("OnClick", function() p.page = math.max(1, p.page - 1); KT.RefreshPanel() end)
  local nxt = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  nxt:SetSize(28, 20)
  nxt:SetPoint("TOPRIGHT", -120, -4)
  nxt:SetText(">")
  nxt:SetScript("OnClick", function() p.page = p.page + 1; KT.RefreshPanel() end)
  local copy = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  copy:SetSize(110, 20)
  copy:SetPoint("TOPRIGHT", -6, -4)
  Label(copy, "UI_JOURNAL_COPY")
  copy:SetScript("OnClick", function() KT.ShowReport() end)

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
      if row.entry then
        row.entry.flagged = not row.entry.flagged or nil
        KT.RefreshPanel()
      end
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

---------------------------------------------------------------------------
-- Body page (Elements module): your character, five gauges, where you are
---------------------------------------------------------------------------

local function BuildBody(parent)
  local p = CreateFrame("Frame", nil, parent)
  p:SetAllPoints()
  p.modelBox = ModelBox(p, 160, 236)
  p.modelBox:SetPoint("TOPLEFT", 6, -6)

  local x = 182
  p.intro = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  p.intro:SetPoint("TOPLEFT", x, -10)
  p.intro:SetWidth(CONTENT_WIDTH - 140)
  p.intro:SetJustifyH("LEFT")
  p.bars = {}
  for i = 1, 5 do
    local bar = StyledBar(p, CONTENT_WIDTH - 150, 18)
    bar:SetPoint("TOPLEFT", x + 4, -52 - (i - 1) * 38)
    p.bars[i] = bar
  end
  p.here = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  p.here:SetPoint("TOPLEFT", 10, -260)
  p.here:SetWidth(CONTENT_WIDTH + 40)
  p.here:SetJustifyH("LEFT")
  p.tips = p:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  p.tips:SetPoint("TOPLEFT", 10, -290)
  p.tips:SetWidth(CONTENT_WIDTH + 40)
  p.tips:SetJustifyH("LEFT")
  p.tips:SetSpacing(3)
  return p
end

local function RefreshBody(p)
  local E = KT.Elements
  local st = E and E.GetState()
  local on = KT.ModuleOn("elements") and st ~= nil
  p.modelBox:ShowUnit("player")
  local rows = on and E.Rows() or {}
  for i, bar in ipairs(p.bars) do
    local r = rows[i]
    bar:SetShown(r ~= nil)
    if r then
      bar.text:SetText(r[1])
      E.ApplyBar(bar, r)
    end
  end
  p.here:SetShown(on)
  p.tips:SetShown(on)
  if not on then
    p.intro:SetText(L.EL_OFF)
    return
  end
  p.intro:SetText(L.EL_PAGE_INTRO)
  p.here:SetText(E.HereText())
  p.tips:SetText(L.EL_PAGE_TIPS)
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

local function BuildOptions(parent)
  -- The options page scrolls: page > scroll frame > content (p)
  local page = CreateFrame("Frame", nil, parent)
  page:SetAllPoints()
  local scroll = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 0, -2)
  scroll:SetPoint("BOTTOMRIGHT", -26, 2)
  local p = CreateFrame("Frame", nil, scroll)
  p:SetSize(CONTENT_WIDTH + 70, 900)
  scroll:SetScrollChild(p)
  local y = -12
  p.checks = {}

  -- Modules
  local modLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  modLabel:SetPoint("TOPLEFT", 12, y)
  Label(modLabel, "UI_MODULES")
  y = y - 20
  local MODULES = {
    { "kindred", "UI_MOD_KINDRED", function(on) api.UpdateHeart(); if on then api.Rescan() end end },
    { "elements", "UI_MOD_ELEMENTS", function() if KT.Elements then KT.Elements.UpdateIcons(); KT.Elements.UpdateThermo() end end },
    { "senses", "UI_MOD_SENSES" },
  }
  for _, m in ipairs(MODULES) do
    local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 8, y)
    if cb.Text then cb.Text:SetText("") end
    if cb.text then cb.text:SetText("") end
    local t = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    t:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    Label(t, m[2])
    cb.module = m[1]
    cb:SetScript("OnClick", function(self)
      local on = self:GetChecked() and true or false
      api.GetDB().modules[m[1]] = on
      if m[3] then m[3](on) end
      KT.RefreshPanel()
    end)
    p.checks[#p.checks + 1] = cb
    y = y - 26
  end
  y = y - 6

  -- Ambiance rhythm
  local rLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  rLabel:SetPoint("TOPLEFT", 12, y)
  Label(rLabel, "UI_OPT_RHYTHM")
  y = y - 24
  p.rhythmButtons = {}
  for n = 0, 3 do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + n * 118, y)
    b:SetText(L.UI_RHYTHM[n])
    b:SetScript("OnClick", function()
      api.GetDB().settings.sensesRhythm = n
      KT.RefreshPanel()
    end)
    p.rhythmButtons[n] = b
  end
  y = y - 32

  -- Ambiance line length
  local sLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sLabel:SetPoint("TOPLEFT", 12, y)
  Label(sLabel, "UI_OPT_STYLE")
  y = y - 24
  p.styleButtons = {}
  for i, st in ipairs({ "short", "mixed", "rich" }) do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + (i - 1) * 118, y)
    b:SetText(L.UI_STYLE[st])
    b:SetScript("OnClick", function()
      api.GetDB().settings.sensesStyle = st
      KT.RefreshPanel()
    end)
    p.styleButtons[st] = b
  end
  y = y - 32

  -- How body comfort shows next to your character frame
  local bLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  bLabel:SetPoint("TOPLEFT", 12, y)
  Label(bLabel, "UI_OPT_BODYSTYLE")
  y = y - 24
  p.bodyStyleButtons = {}
  for i, bs in ipairs({ "none", "icons", "bars" }) do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + (i - 1) * 118, y)
    b:SetText(L.UI_BODYSTYLE[bs])
    b:SetScript("OnClick", function()
      api.GetDB().settings.bodyStyle = bs
      if KT.Elements then KT.Elements.UpdateIcons() end
      KT.RefreshPanel()
    end)
    p.bodyStyleButtons[bs] = b
  end
  y = y - 36

  local label = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("TOPLEFT", 12, y)
  Label(label, "UI_OPT_CHATTY")
  y = y - 24

  p.chattyButtons = {}
  for n = 0, 3 do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + n * 118, y)
    b:SetText(L.UI_CHATTY[n])
    b:SetScript("OnClick", function()
      api.GetDB().settings.chatty = n
      KT.RefreshPanel()
    end)
    p.chattyButtons[n] = b
  end
  y = y - 28

  p.chattyDesc = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  p.chattyDesc:SetPoint("TOPLEFT", 14, y)
  p.chattyDesc:SetWidth(CONTENT_WIDTH)
  p.chattyDesc:SetJustifyH("LEFT")
  y = y - 44

  local function Check(key, textKey, onChange)
    local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 8, y)
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
    p.checks[#p.checks + 1] = cb
    y = y - 30
  end
  Check("minimap", "UI_OPT_MINIMAP", function() KT.UpdateMinimapButton() end)
  Check("showHeart", "UI_OPT_HEART", function() api.UpdateHeart() end)
  Check("showThermo", "UI_OPT_THERMO", function() if KT.Elements then KT.Elements.UpdateThermo() end end)
  Check("label", "UI_OPT_LABEL")
  Check("sound", "UI_OPT_SOUND")
  Check("testDrafts", "UI_OPT_TESTDRAFTS")
  Check("debug", "UI_OPT_DEBUG")

  -- Language
  y = y - 8
  local langLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  langLabel:SetPoint("TOPLEFT", 12, y)
  Label(langLabel, "UI_OPT_LANGUAGE")
  y = y - 24
  p.langButtons = {}
  for i, lang in ipairs(LANGUAGES) do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + (i - 1) * 118, y)
    b:SetText(lang[2])
    b:SetScript("OnClick", function()
      api.GetDB().settings.language = lang[1]
      KT.ApplyLanguage()
      KT.RelabelPanel()
      api.UpdateHeart() -- also refreshes this window
    end)
    p.langButtons[lang[1]] = b
  end
  y = y - 32

  -- Your character's gender, for grammar (French)
  local gLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  gLabel:SetPoint("TOPLEFT", 12, y)
  Label(gLabel, "UI_OPT_GENDER")
  y = y - 24
  p.genderButtons = {}
  for i, g in ipairs({ { "auto", "UI_GENDER_AUTO" }, { "m", "UI_GENDER_M" }, { "f", "UI_GENDER_F" },
    { "n", "UI_GENDER_N" } }) do
    local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    b:SetSize(114, 24)
    b:SetPoint("TOPLEFT", 10 + (i - 1) * 118, y)
    Label(b, g[2])
    b:SetScript("OnClick", function()
      api.GetDB().settings.gender = g[1]
      KT.RefreshPanel()
    end)
    p.genderButtons[g[1]] = b
  end
  y = y - 32

  local note = p:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  note:SetPoint("TOPLEFT", 14, y)
  note:SetWidth(CONTENT_WIDTH)
  note:SetJustifyH("LEFT")
  Label(note, "UI_OPT_NOTE")
  p:SetHeight(-y + 80)

  -- the refresh code reads these from the page
  page.checks, page.chattyButtons, page.chattyDesc = p.checks, p.chattyButtons, p.chattyDesc
  page.langButtons, page.genderButtons, page.rhythmButtons = p.langButtons, p.genderButtons, p.rhythmButtons
  page.styleButtons, page.bodyStyleButtons = p.styleButtons, p.bodyStyleButtons
  return page
end

local function Build()
  local ok, f = pcall(CreateFrame, "Frame", "WayfarersTalesFrame", UIParent, "BasicFrameTemplateWithInset")
  if not ok or not f then
    f = CreateFrame("Frame", "WayfarersTalesFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
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
  f:SetSize(620, 640)
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

  if f.TitleText then
    f.TitleText:SetText("Wayfarer's Tales")
  else
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -8)
    title:SetText("Wayfarer's Tales")
  end

  local list = { { "companion", "UI_TAB_COMPANION" }, { "body", "UI_TAB_BODY" }, { "senses", "UI_TAB_SENSES" },
    { "travels", "UI_TAB_TRAVELS" }, { "journal", "UI_TAB_JOURNAL" }, { "guide", "UI_TAB_GUIDE" },
    { "options", "UI_TAB_OPTIONS" } }
  for i, t in ipairs(list) do
    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    b:SetSize(82, 26)
    b:SetPoint("TOPLEFT", 12 + (i - 1) * 85, -30)
    Label(b, t[2])
    b:SetScript("OnClick", function() KT.ShowTab(t[1]) end)
    tabs[t[1]] = b
  end

  local content = CreateFrame("Frame", nil, f)
  content:SetPoint("TOPLEFT", 10, -62)
  content:SetPoint("BOTTOMRIGHT", -10, 10)

  -- Companion page: the pet's model and header, then details and memories
  local comp = CreateFrame("Frame", nil, content)
  comp:SetAllPoints()
  comp.modelBox = ModelBox(comp, 160, 170)
  comp.modelBox:SetPoint("TOPLEFT", 6, -6)
  local hx = 184
  comp.name = comp:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  comp.name:SetPoint("TOPLEFT", hx, -14)
  comp.sub = comp:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  comp.sub:SetPoint("TOPLEFT", comp.name, "BOTTOMLEFT", 0, -4)
  comp.tier = comp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  comp.tier:SetPoint("TOPLEFT", comp.sub, "BOTTOMLEFT", 0, -12)
  comp.tier:SetTextColor(1, 0.56, 0.69)
  comp.desc = comp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  comp.desc:SetPoint("TOPLEFT", comp.tier, "BOTTOMLEFT", 0, -6)
  comp.desc:SetWidth(CONTENT_WIDTH - 150)
  comp.desc:SetJustifyH("LEFT")
  comp.bar = StyledBar(comp, CONTENT_WIDTH - 150, 18)
  comp.bar:SetPoint("TOPLEFT", hx + 3, -140)
  comp.bar:SetStatusBarColor(1, 0.45, 0.62)
  comp.text = CreateTextPage(comp)
  comp.text:ClearAllPoints()
  comp.text:SetPoint("TOPLEFT", 0, -184)
  comp.text:SetPoint("BOTTOMRIGHT")
  pages.companion = comp

  pages.guide = CreateTextPage(content)
  pages.travels = CreateTextPage(content)
  pages.journal = BuildJournal(content)
  pages.body = BuildBody(content)
  pages.senses = BuildSenses(content)
  pages.options = BuildOptions(content)

  frame = f
end

---------------------------------------------------------------------------
-- Page contents
---------------------------------------------------------------------------

local function CompanionText(pet)
  local db = api.GetDB()
  local lines = {}
  local function add(s) lines[#lines + 1] = s or "" end

  if pet then
    -- (name, bond stage and its description are in the header above the text)
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

    add("")
    add(Head(L.UI_MEMORIES))
    if #pet.memories == 0 then add(Grey(L.CMD_NO_MEMORY)) end
    for i = #pet.memories, 1, -1 do -- newest first
      local m = pet.memories[i]
      add(Grey(date("%Y-%m-%d", m.t)) .. "  " .. api.MemoryText(m, pet))
    end
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

function KT.RefreshPanel()
  if not frame or not frame:IsShown() then return end
  local db = api.GetDB()
  if currentTab == "journal" then
    RefreshJournal(pages.journal, db)
  elseif currentTab == "body" then
    RefreshBody(pages.body)
  elseif currentTab == "senses" then
    RefreshSenses(pages.senses)
  elseif currentTab == "companion" then
    local c = pages.companion
    local pet = db.modules.kindred ~= false and api.GetPet() or nil
    local header = { c.modelBox, c.name, c.sub, c.tier, c.desc, c.bar }
    for _, w in ipairs(header) do w:SetShown(pet ~= nil) end
    c.text:ClearAllPoints()
    c.text:SetPoint("TOPLEFT", 0, pet and -184 or 0)
    c.text:SetPoint("BOTTOMRIGHT")
    if db.modules.kindred == false then
      c.text:SetContent(L.UI_KINDRED_OFF)
    else
      if pet then
        local idx = api.TierIndex(math.floor(pet.affection))
        c.modelBox:ShowUnit("pet")
        c.name:SetText(pet.name)
        local sub = pet.family or "?"
        if pet.level then sub = sub .. ", " .. L.UI_LEVEL .. " " .. pet.level end
        c.sub:SetText(sub)
        c.tier:SetText(L.TIERS[idx])
        c.desc:SetText(L.TIER_DESC[idx])
        c.bar:SetValue(pet.affection)
        c.bar.text:SetText(string.format(L.TT_SCORE, math.floor(pet.affection)))
      end
      c.text:SetContent(CompanionText(pet))
    end
  elseif currentTab == "travels" then
    pages.travels:SetContent(KT.Discovery and KT.Discovery.PageText() or "")
  elseif currentTab == "guide" then
    pages.guide:SetContent(L.GUIDE .. "\n\n" .. (L.EL_GUIDE or "") .. "\n\n" .. (L.SN_GUIDE or ""))
  elseif currentTab == "options" then
    local p = pages.options
    local chatty = db.settings.chatty or 2
    for n, b in pairs(p.chattyButtons) do
      if n == chatty then b:LockHighlight() else b:UnlockHighlight() end
    end
    p.chattyDesc:SetText(L.UI_CHATTY_DESC[chatty] or "")
    for _, cb in ipairs(p.checks) do
      if cb.module then
        cb:SetChecked(db.modules[cb.module] ~= false)
      else
        cb:SetChecked(db.settings[cb.key] and true or false)
      end
    end
    local lang = db.settings.language or "auto"
    for code, b in pairs(p.langButtons) do
      if code == lang then b:LockHighlight() else b:UnlockHighlight() end
    end
    local gender = db.settings.gender or "auto"
    for code, b in pairs(p.genderButtons) do
      if code == gender then b:LockHighlight() else b:UnlockHighlight() end
    end
    local rhythm = db.settings.sensesRhythm or 2
    for n, b in pairs(p.rhythmButtons) do
      if n == rhythm then b:LockHighlight() else b:UnlockHighlight() end
    end
    local style = db.settings.sensesStyle or "mixed"
    for st, b in pairs(p.styleButtons) do
      if st == style then b:LockHighlight() else b:UnlockHighlight() end
    end
    local bstyle = db.settings.bodyStyle or "none"
    for bs, b in pairs(p.bodyStyleButtons) do
      if bs == bstyle then b:LockHighlight() else b:UnlockHighlight() end
    end
  end
end

function KT.ShowTab(name)
  currentTab = name
  for k, p in pairs(pages) do p:SetShown(k == name) end
  -- 3D models must be reloaded after being hidden; bars start at their current value
  for _, p in pairs(pages) do
    if p.modelBox then p.modelBox.guid = nil end
    for _, bar in ipairs(p.bars or {}) do bar.shown = nil end
  end
  for k, b in pairs(tabs) do
    if k == name then b:LockHighlight() else b:UnlockHighlight() end
  end
  KT.RefreshPanel()
end

function KT.TogglePanel(tab)
  api = KT.api
  if not frame then Build() end
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
