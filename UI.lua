-- Wayfarer's Tales - window (/wt), journal, report box, minimap button.
-- Pages are mostly plain text in a scroll area: simple and hard to break.

local _, KT = ...
local L, D = KT.L, KT.Data
local api -- KT.api, set by Core.lua; read at runtime

local frame, mm
local tabs, pages = {}, {}
local currentTab = "body"
local CONTENT_WIDTH = 470

-- The addon's icon (header, minimap button): D.CUSTOM_ICON in Data.lua
local function Icon() return D.CUSTOM_ICON or "Interface\\Icons\\INV_Misc_Note_01" end
local function Head(text) return "|cffffd100" .. text .. "|r" end
local function Pink(text) return "|cffff8fb1" .. text .. "|r" end
local function Grey(text) return "|cffaaaaaa" .. text .. "|r" end
local function IsWarlock() return select(2, UnitClass("player")) == "WARLOCK" end

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

local JOURNAL_ROWS = 24 -- at most this many lines on a page (pages are cut by height)
local JOURNAL_DATE_W = 78 -- width of the date column

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

  -- Paper, like a letter in the mail: the game's stationery if the client has it,
  -- over a parchment color (so the dark text always reads well)
  local paper = CreateFrame("Frame", nil, p, BackdropTemplateMixin and "BackdropTemplate" or nil)
  paper:SetPoint("TOPLEFT", 2, -4)
  paper:SetPoint("BOTTOMRIGHT", -4, 36) -- (the page buttons sit below the paper)
  if paper.SetBackdrop then
    paper:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    paper:SetBackdropBorderColor(0.45, 0.33, 0.18)
  end
  local base = paper:CreateTexture(nil, "BACKGROUND", nil, 0)
  base:SetPoint("TOPLEFT", 3, -3)
  base:SetPoint("BOTTOMRIGHT", -3, 3)
  base:SetColorTexture(0.87, 0.79, 0.62, 1)
  local tex = paper:CreateTexture(nil, "BACKGROUND", nil, 1)
  tex:SetPoint("TOPLEFT", 3, -3)
  tex:SetPoint("BOTTOMRIGHT", -3, 3)
  -- (the spellbook page first: bigger, so less blurry once stretched; kept faint, the
  -- parchment color underneath does most of the work)
  -- the spellbook page has an empty strip at the bottom of its file (cropped here) and
  -- its spine on the left (the text starts after it: p.leftPad)
  p.leftPad = 16
  local PAGES = {
    { "Interface\\Spellbook\\Spellbook-Page-1", { 0, 1, 0, 0.94 }, 116 },
    { "Interface\\Stationery\\StationeryTest1", { 0, 1, 0, 1 }, 16 },
  }
  for _, pg in ipairs(PAGES) do
    local ok = tex:SetTexture(pg[1])
    if ok ~= false and tex:GetTexture() ~= nil then
      tex:SetTexCoord(unpack(pg[2]))
      p.leftPad = pg[3]
      break
    end
    tex:SetTexture(nil)
  end
  tex:SetAlpha(0.45)
  p.paper = paper

  -- Everything / big moments only
  p.showAll = CreateFrame("Button", nil, paper, "UIPanelButtonTemplate")
  p.showAll:SetSize(110, 20)
  p.showAll:SetPoint("TOPLEFT", p.leftPad, -40)
  Label(p.showAll, "UI_JOURNAL_ALL")
  p.showAll:SetScript("OnClick", function() api.GetDB().settings.journalBig = nil; p.page = 1; KT.RefreshPanel() end)
  p.showBig = CreateFrame("Button", nil, paper, "UIPanelButtonTemplate")
  p.showBig:SetSize(140, 20)
  p.showBig:SetPoint("LEFT", p.showAll, "RIGHT", 4, 0)
  Label(p.showBig, "UI_JOURNAL_BIG")
  p.showBig:SetScript("OnClick", function() api.GetDB().settings.journalBig = true; p.page = 1; KT.RefreshPanel() end)

  p.header = paper:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  -- (placed under the report button, see below)
  p.header:SetShadowOffset(0, 0)

  local copy = CreateFrame("Button", nil, paper, "UIPanelButtonTemplate")
  copy:SetSize(150, 20)
  copy:SetPoint("TOPRIGHT", -56, -40) -- (same line as the Tout / Grands moments buttons, right edge with the ! buttons)
  Label(copy, "UI_JOURNAL_COPY")
  copy:SetScript("OnClick", function() KT.ShowReport() end)
  p.copy = copy -- testers only (see RefreshJournal)
  -- reported lines count (testers), right under the report button
  p.header:SetPoint("TOPRIGHT", copy, "BOTTOMRIGHT", 0, -3)

  -- page buttons, centered below the paper
  p.pageText = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  p.pageText:SetPoint("BOTTOM", 0, 12)
  local prev = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  prev:SetSize(28, 20)
  prev:SetPoint("RIGHT", p.pageText, "LEFT", -12, 0)
  prev:SetText("<")
  prev:SetScript("OnClick", function() p.page = math.max(1, p.page - 1); KT.RefreshPanel() end)
  local nxt = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  nxt:SetSize(28, 20)
  nxt:SetPoint("LEFT", p.pageText, "RIGHT", 12, 0)
  nxt:SetText(">")
  nxt:SetScript("OnClick", function() p.page = p.page + 1; KT.RefreshPanel() end)
  p.prev, p.nxt = prev, nxt

  p.rows = {}
  for i = 1, JOURNAL_ROWS do
    local row = CreateFrame("Frame", nil, paper)
    row:SetHeight(20)
    local flag = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    flag:SetSize(22, 18)
    flag:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 2)
    flag:SetText("!")
    -- the date in its own column, so a long line wraps under the start of the sentence
    local when = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    when:SetPoint("TOPLEFT", 0, 0)
    when:SetWidth(JOURNAL_DATE_W)
    when:SetJustifyH("LEFT")
    when:SetShadowOffset(0, 0)
    when:SetTextColor(0.33, 0.22, 0.1)
    row.when = when
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", JOURNAL_DATE_W, 0)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetSpacing(2)
    fs:SetShadowOffset(0, 0)
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

-- ink colors on the paper: big moments darker, everyday lines softer
local INK, INK_SOFT, INK_FLAG = "|cff24140a", "|cff6a5538", "|cffa01818"
local STAR = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:11:11:0:-1|t "

-- Big moments: firsts, milestones, things learned, titles, your pet's big steps.
-- (journal keys: the pet's message pool, or a line id "moment:<key>:<n>",
-- "senses:...:arrive:<n>" for a first visit)
local BIG_PET = { tierUp = true, loyaltyUp = true, petLevel = true, newPet = true, newPetHistory = true,
  favoriteRevealed = true, reunion = true, stableReunion = true, daysTogether = true, rename = true,
  newZone = true, mealShared = true, celebrated = true, petSolo = true, petSoloAfk = true, death = true }
local BIG_MOMENTS = { "firstTaste", "firstSip", "foodMilestone", "drinkMilestone", "learn", "rank_",
  "craftFirst", "craftEpic", "craftRare", "craftRankUp", "loot", "fishFirst", "discoveryMilestone",
  "quest", "flightNew" }
local function IsBigMoment(e)
  local k = tostring(e.key or "")
  if e.module == "kindred" then return BIG_PET[k] == true end
  if k == "newTitle" or k:find(":arrive:", 1, true) then return true end
  local m = k:match("^moment:([^:]+):")
  if not m then return false end
  if m:match("^%u") then return true end -- a new character's first lines (class, race)
  for _, prefix in ipairs(BIG_MOMENTS) do
    if m:sub(1, #prefix) == prefix then return true end
  end
  return false
end

local JOURNAL_TOP, JOURNAL_BOTTOM, JOURNAL_GAP = 76, 64, 9

-- Pages by height: each line is measured, and a page takes lines (newest first) until
-- the sheet is full. Returns the index (from the newest) where each page starts.
local function JournalPages(p, j, textWidth, mode)
  local avail = p.paper:GetHeight() - JOURNAL_TOP - JOURNAL_BOTTOM
  if avail < 120 then avail = 380 end
  local key = (mode or "") .. ":" .. #j .. ":" .. textWidth .. ":" .. math.floor(avail)
  if p.pagesKey == key then return p.pages end
  if not p.measure then
    p.measure = p.paper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    p.measure:SetSpacing(2)
    p.measure:SetAlpha(0)
  end
  p.measure:SetWidth(textWidth)
  local pages, y, onPage = { 1 }, 0, 0
  for i = 1, #j do
    local e = j[#j - i + 1]
    p.measure:SetText((IsBigMoment(e) and STAR or "") .. StripCodes(e.text or ""))
    local h = math.max(p.measure:GetStringHeight(), 14) + JOURNAL_GAP
    if onPage > 0 and (y + h > avail or onPage >= JOURNAL_ROWS) then
      pages[#pages + 1] = i
      y, onPage = 0, 0
    end
    y, onPage = y + h, onPage + 1
  end
  p.pages, p.pagesKey = pages, key
  return pages
end

local function RefreshJournal(p, db)
  local j = db.journal
  local all = j
  -- big moments only: the same journal, filtered
  local bigOnly = db.settings.journalBig == true
  if bigOnly then
    local list = {}
    for _, e in ipairs(all) do if IsBigMoment(e) then list[#list + 1] = e end end
    j = list
  end
  if bigOnly then p.showBig:LockHighlight(); p.showAll:UnlockHighlight()
  else p.showAll:LockHighlight(); p.showBig:UnlockHighlight() end
  local total = #j
  local tester = KT.IsTester()
  local width = p.paper:GetWidth() - p.leftPad - 56 -- (margin on the right too)
  if width < 200 then width = 470 end
  local textWidth = width - JOURNAL_DATE_W - (tester and 30 or 0)
  local pages = JournalPages(p, j, textWidth, bigOnly and "big" or "all")
  local pageCount = math.max(1, #pages)
  if p.page > pageCount then p.page = pageCount end
  local first = pages[p.page] or 1
  local last = (pages[p.page + 1] or (total + 1)) - 1
  p.copy:SetShown(tester)
  local flagged = 0
  for _, e in ipairs(all) do if e.flagged then flagged = flagged + 1 end end
  if total == 0 then
    p.header:SetText(INK .. L.UI_JOURNAL_EMPTY .. "|r")
  else
    p.header:SetText(flagged > 0 and (INK_FLAG .. string.format(L.UI_JOURNAL_FLAGGED, flagged) .. "|r") or "")
  end
  p.pageText:SetText(string.format(L.UI_JOURNAL_PAGE, p.page, pageCount))
  p.pageText:SetShown(total > 0)
  p.prev:SetShown(total > 0)
  p.nxt:SetShown(total > 0)

  -- lines stacked from the top, each as tall as its text
  local y = JOURNAL_TOP -- (a generous top margin, under the page's decoration)
  for i, row in ipairs(p.rows) do
    local n = first + i - 1
    local e = n <= last and j[total - n + 1] or nil
    row.entry = e
    if e then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", p.paper, "TOPLEFT", p.leftPad, -y)
      row:SetWidth(width)
      row.fs:SetWidth(textWidth)
      local big = IsBigMoment(e)
      local color = (e.flagged and INK_FLAG) or (big and INK) or INK_SOFT
      row.when:SetText(date("%d/%m %H:%M", e.t))
      row.fs:SetText((big and STAR or "") .. color .. StripCodes(e.text or "") .. "|r")
      local h = math.max(row.fs:GetStringHeight(), 14)
      row:SetHeight(h)
      row.flag:SetText(e.flagged and "x" or "!")
      row.flag:SetShown(tester)
      row:Show()
      y = y + h + JOURNAL_GAP
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
  -- show a creature by its display (a mascot: it isn't a unit you can point to)
  function box:ShowDisplay(id)
    if not self.model or not id then return end
    if id ~= self.disp then
      self.disp = id
      pcall(self.model.SetDisplayInfo, self.model, id)
    end
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
    -- (the NPCs and quests met along the way: for us only, testers share what they choose)
    .. (KT.IsDev() and #npcs > 0 and ("\n\n" .. L.UI_REPORT_NPCS .. "\n" .. table.concat(npcs, "\n")) or "")
    .. (KT.IsDev() and #quests > 0 and ("\n\n" .. L.UI_REPORT_QUESTS .. "\n" .. table.concat(quests, "\n")) or "")
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
    f:SetSize(500, 380)
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
    -- one button per part (Discord takes at most 2000 characters per message)
    f.partLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.partLabel:SetPoint("TOPLEFT", 14, -68)
    f.partButtons = {}
    for i = 1, 10 do
      local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
      b:SetSize(28, 20)
      b:SetText(i)
      b:SetScript("OnClick", function() f:ShowPart(i) end)
      f.partButtons[i] = b
    end
    function f:ShowPart(i)
      self.part = i
      self.edit:SetText(self.parts[i] or "")
      for n, b in ipairs(self.partButtons) do
        if n == i then b:LockHighlight() else b:UnlockHighlight() end
      end
      self.edit:SetFocus()
      self.edit:HighlightText()
    end
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -94)
    scroll:SetPoint("BOTTOMRIGHT", -34, 14)
    f.scroll = scroll
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
  -- Cut the report into parts that fit in one Discord message, between lines
  local parts, cur, size = {}, {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if size + #line + 1 > D.REPORT_PART and #cur > 0 then
      parts[#parts + 1] = table.concat(cur, "\n")
      cur, size = {}, 0
    end
    cur[#cur + 1] = line
    size = size + #line + 1
  end
  if #cur > 0 then parts[#parts + 1] = table.concat(cur, "\n") end
  if #parts > #reportFrame.partButtons then -- (very long: the last part takes the rest)
    local rest = {}
    for i = #reportFrame.partButtons, #parts do rest[#rest + 1] = parts[i] end
    for i = #parts, #reportFrame.partButtons, -1 do parts[i] = nil end
    parts[#reportFrame.partButtons] = table.concat(rest, "\n")
  end
  if #parts > 1 then
    for i, p in ipairs(parts) do parts[i] = string.format("(%d/%d)\n", i, #parts) .. p end
  end
  reportFrame.parts = parts

  local f = reportFrame
  f.help:SetText(string.format(L.UI_JOURNAL_COPY_HELP, D.DISCORD))
  f.partLabel:SetText(#parts > 1 and string.format(L.UI_REPORT_PARTS, #parts) or "")
  local prev
  for i, b in ipairs(f.partButtons) do
    b:SetShown(#parts > 1 and i <= #parts)
    b:ClearAllPoints()
    if prev then b:SetPoint("LEFT", prev, "RIGHT", 4, 0) else b:SetPoint("LEFT", f.partLabel, "RIGHT", 8, 0) end
    prev = b
  end
  f:Show()
  f:ShowPart(1)
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
      add(Grey(string.format(L.TT_NEXT, api.TierName(idx + 1, pet), D.TIERS[idx + 1])))
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
    if pet.demon then -- (no meals or cuddles with a demon)
      add(string.format(L.UI_STATS_DEMON, api.FormatDuration(s.minutes or 0), s.kills or 0))
    else
      add(string.format(L.UI_STATS, api.FormatDuration(s.minutes or 0), s.kills or 0, s.feeds or 0,
        s.meals or 0, s.campfires or 0, s.emotes or 0))
    end
    -- (memories have their own scrolling box below)
  else
    add(IsWarlock() and L.CMD_NO_DEMON or L.CMD_NO_PET)
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
      add(r.name .. Grey(" (" .. (r.family or "?") .. ")") .. " - " .. Pink(api.TierName(i, r)) .. " " .. math.floor(r.affection))
    end
  end
  return table.concat(lines, "\n")
end

local function BuildCompanion(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, IsWarlock() and "UI_DEMON_TITLE" or "UI_COMPANION_TITLE", "kindred", function(on)
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
      page.tier:SetText(api.TierName(idx, pet))
      page.desc:SetText(api.TierDesc(idx, pet))
      page.bar:SetValue(pet.affection)
      page.bar.text:SetText(string.format(L.TT_SCORE, math.floor(pet.affection)))
    end
    page.text:SetText(CompanionText(pet))
    local chatty = db.settings.chatty or 2
    page.chatty:Select(chatty)
    page.chattyDesc:SetText(L.UI_CHATTY_DESC[chatty] or "")
    page.sound:Refresh()
    page.guide.text:SetText((pet and pet.demon or (not pet and IsWarlock())) and L.UI_DEMON_GUIDE or L.UI_KINDRED_GUIDE)
  end
  page:Layout()
end

---------------------------------------------------------------------------
-- Mascot (every class): the mascot that's out, your bond, what you shared
---------------------------------------------------------------------------

local function BuildMascot(parent)
  local page = ScrollPage(parent)
  page.header = ModuleHeader(page, "UI_MASCOT_TITLE", "mascot")
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
  page.bar:SetStatusBarColor(0.55, 0.8, 0.45)
  page.top = page:Add(top, 10)
  page.text = Para(page, "GameFontHighlight", 12)

  -- memories, in their own scrolling box (like the pet's)
  local mem = Box(page.p, 180)
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
  function mem:SetMemories(rec)
    local lines = {}
    if #rec.memories == 0 then lines[1] = Grey(L.CMD_NO_MEMORY) end
    for i = #rec.memories, 1, -1 do
      local m = rec.memories[i]
      lines[#lines + 1] = Grey(date("%Y-%m-%d", m.t)) .. "  " .. KT.Mascot.MemoryText(m, rec)
    end
    mfs:SetText(table.concat(lines, "\n"))
    child:SetHeight(mfs:GetStringHeight() + 6)
  end
  page.memories = page:Add(mem, 12)
  page.others = Para(page, "GameFontHighlight", 12)
  page.guide = GuideBox(page)
  return page
end

local function RefreshMascot(page)
  local Ma = KT.Mascot
  page.header:Refresh()
  local on = api.GetDB().modules.mascot ~= false
  local rec = on and Ma and Ma.Current() or nil
  page.top:SetShown(rec ~= nil)
  page.memories:SetShown(rec ~= nil)
  page.guide:SetShown(on)
  if not on then
    page.text:SetText(L.UI_MASCOT_OFF)
  elseif rec then
    local idx = Ma.TierIndex(math.floor(rec.affection))
    page.modelBox:ShowDisplay(rec.displayID)
    page.name:SetText(Ma.Name(rec))
    local sub = rec.name or "?"
    if rec.level then sub = sub .. ", " .. L.UI_LEVEL .. " " .. rec.level end
    page.sub:SetText(sub)
    page.tier:SetText(Ma.TierName(idx))
    page.desc:SetText(KT.G(Ma.TierDesc(idx)))
    page.bar:SetValue(rec.affection)
    page.bar.text:SetText(string.format(L.UI_MASCOT_SCORE, math.floor(rec.affection)))
    local s = rec.stats
    local lines = {}
    if D.TIERS[idx + 1] then lines[#lines + 1] = Grey(string.format(L.TT_NEXT, Ma.TierName(idx + 1), D.TIERS[idx + 1])) .. "\n" end
    lines[#lines + 1] = Head(L.UI_TOGETHER)
    lines[#lines + 1] = string.format(L.UI_MASCOT_STATS, api.FormatDuration(s.minutes or 0), s.outings or 0,
      s.places or 0, s.cuddles or 0, s.campfires or 0, s.naps or 0)
    page.text:SetText(table.concat(lines, "\n"))
    page.memories:SetMemories(rec)
  else
    page.text:SetText(L.UI_MASCOT_NONE)
  end
  -- this character's other mascots
  local others = {}
  for _, r in ipairs(Ma and Ma.Records() or {}) do
    if r ~= rec then
      others[#others + 1] = Ma.Name(r) .. Grey(" (" .. (r.name or "?") .. ")") .. " - "
        .. Pink(Ma.TierName(Ma.TierIndex(math.floor(r.affection)))) .. " " .. math.floor(r.affection)
    end
  end
  page.others:SetShown(on and #others > 0)
  if #others > 0 then page.others:SetText(Head(L.UI_MASCOT_OTHERS) .. "\n" .. table.concat(others, "\n")) end
  page.guide.text:SetText(L.UI_MASCOT_GUIDE)
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
  -- header: "Carnet de voyage de X" and the total on the right
  local h = CreateFrame("Frame", nil, page.p)
  h:SetSize(PAGE_W, 28)
  page.heading = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  page.heading:SetPoint("LEFT", 2, 0)
  page.total = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  page.total:SetPoint("RIGHT", -4, 0)
  local hl = h:CreateTexture(nil, "ARTWORK")
  hl:SetColorTexture(0.5, 0.4, 0.22, 0.8)
  hl:SetHeight(1)
  hl:SetPoint("BOTTOMLEFT", 0, -3)
  hl:SetPoint("BOTTOMRIGHT", 0, -3)
  page:Add(h, 12)

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

  -- one column per category (Lieux, Saveurs, Savoir-faire, Voyages), one row per kind
  local GAP, ROWS = 8, 4
  local colW = math.floor((PAGE_W - 3 * GAP) / 4)
  local grid = CreateFrame("Frame", nil, page.p)
  grid:SetSize(PAGE_W, 30 + ROWS * 17 + 10)
  page.cols = {}
  for i = 1, 4 do
    local col = Box(grid, grid:GetHeight())
    col:SetWidth(colW)
    col:SetPoint("TOPLEFT", (i - 1) * (colW + GAP), 0)
    col.head = col:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    col.head:SetPoint("TOPLEFT", 10, -9)
    col.head:SetTextColor(1, 0.56, 0.69)
    col.rows = {}
    for r = 1, ROWS do
      local label = col:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetPoint("TOPLEFT", 10, -30 - (r - 1) * 17)
      label:SetJustifyH("LEFT")
      local count = col:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      count:SetPoint("TOPRIGHT", -10, -30 - (r - 1) * 17)
      col.rows[r] = { label = label, count = count }
    end
    page.cols[i] = col
  end
  page:Add(grid, 14)

  page.text = Para(page, "GameFontHighlight", 12)
  page.guide = GuideBox(page)
  return page
end

local function RefreshTravels(page)
  local Di = KT.Discovery
  if Di then
    local c = Di.Counts()
    local score = Di.Score(c)
    page.heading:SetText(string.format(L.DISC.title, UnitName("player") or ""))
    page.total:SetText(string.format(L.DISC.total, score))
    local name, at, nextName, nextAt = Di.Title(score)
    page.title:SetText(name)
    page.bar:SetMinMaxValues(at or 0, nextAt or ((at or 0) + 1))
    page.bar:SetValue(nextAt and score or ((at or 0) + 1))
    page.bar.text:SetText(nextAt and (score .. " / " .. nextAt) or tostring(score))
    page.next:SetText(nextName and string.format(L.DISC_NEXT, nextName, nextAt) or L.DISC_TOP)
    for i, cat in ipairs(Di.Categories(c)) do
      local col = page.cols[i]
      if col then
        col.head:SetText(cat.name .. Grey("  · " .. cat.total))
        for r, row in ipairs(col.rows) do
          local data = cat.rows[r]
          row.label:SetText(data and data[1] or "")
          row.count:SetText(data and tostring(data[2]) or "")
        end
      end
    end
  end
  page.text:SetText(Di and Di.PageText() or "")
  page.guide.text:SetText(L.DISC.guide)
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

  -- Discord: the game can't open links, so the address sits in a box you can copy from
  local dc = Box(page.p, 58)
  BoxLabel(dc, 10, -10, "UI_DISCORD")
  local eb = CreateFrame("EditBox", nil, dc, "InputBoxTemplate")
  eb:SetSize(260, 20)
  eb:SetPoint("TOPLEFT", 16, -30)
  eb:SetAutoFocus(false)
  eb:SetText(D.DISCORD)
  eb:SetCursorPosition(0)
  -- read-only: whatever is typed, the address comes back; clicking selects it all
  eb:SetScript("OnTextChanged", function(self) if self:GetText() ~= D.DISCORD then self:SetText(D.DISCORD) end end)
  eb:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
  eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  eb:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  page:Add(dc, 10)

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
  local class = select(2, UnitClass("player"))
  if class == "HUNTER" then list[#list + 1] = { "companion", "UI_TAB_COMPANION" } end
  if class == "WARLOCK" then list[#list + 1] = { "companion", "UI_TAB_DEMON" } end
  list[#list + 1] = { "mascot", "UI_TAB_MASCOT" } -- (every class)
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
  pages.mascot = BuildMascot(content)
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
  elseif currentTab == "mascot" and pages.mascot then RefreshMascot(pages.mascot)
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
    if p.modelBox then p.modelBox.guid, p.modelBox.disp = nil, nil end
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
  bg:SetSize(26, 26) -- fills the ring's hole (the ring is drawn on top)
  bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  bg:SetPoint("CENTER", mm, "TOPLEFT", 17, -15) -- the ring's center
  local icon = mm:CreateTexture(nil, "ARTWORK")
  icon:SetSize(23, 23)
  icon:SetTexture(Icon())
  icon:SetPoint("CENTER", mm, "TOPLEFT", 17, -15)
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

