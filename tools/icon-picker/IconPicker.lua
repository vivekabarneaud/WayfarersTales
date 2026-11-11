-- Wayfarer's Tales - icon picker (dev tool, NOT loaded by the game).
-- Used on 2026-11-11 to choose the addon icon (INV_Misc_Note_01). To use it again:
-- paste it at the end of UI.lua, add back the /wt icons command in Core.lua, and
-- let Icon() read settings.iconTry. It relies on UI.lua locals (api, Icon,
-- iconTextures, BACKDROP_TEMPLATE).

---------------------------------------------------------------------------
-- Icon picker (/wt icons, dev): game icons that could become the addon's icon.
-- Two lists: a short selection (notes, scrolls, books, quills...) and every icon
-- the client has (the list the game's macro window uses), page by page.
-- Click one to try it on the minimap button and the window header. In the
-- selection, an icon the client doesn't have gets a red cross.
---------------------------------------------------------------------------

local ICON_CANDIDATES = {
  -- notes, letters and scrolls
  "INV_Misc_Note_01", "INV_Misc_Note_02", "INV_Misc_Note_03", "INV_Misc_Note_04", "INV_Misc_Note_05", "INV_Misc_Note_06",
  "INV_Letter_01", "INV_Letter_02", "INV_Letter_03", "INV_Letter_04", "INV_Letter_05", "INV_Letter_06",
  "INV_Letter_07", "INV_Letter_08", "INV_Letter_09", "INV_Letter_15", "INV_Letter_16", "INV_Letter_17",
  "INV_Scroll_01", "INV_Scroll_02", "INV_Scroll_03", "INV_Scroll_04", "INV_Scroll_05", "INV_Scroll_06",
  "INV_Scroll_07", "INV_Scroll_08", "INV_Scroll_09", "INV_Scroll_10", "INV_Scroll_11", "INV_Scroll_15",
  -- books
  "INV_Misc_Book_01", "INV_Misc_Book_02", "INV_Misc_Book_03", "INV_Misc_Book_04", "INV_Misc_Book_05",
  "INV_Misc_Book_06", "INV_Misc_Book_07", "INV_Misc_Book_08", "INV_Misc_Book_09", "INV_Misc_Book_10",
  "INV_Misc_Book_11", "INV_Misc_Book_12", "INV_Misc_Book_13", "INV_Misc_Book_14", "INV_Misc_Book_15",
  -- quills, ink, maps, travel
  "INV_Feather_01", "INV_Feather_02", "INV_Feather_03", "INV_Feather_04", "INV_Feather_05", "INV_Feather_12",
  "INV_Inscription_Tradeskill01", "INV_Inscription_Papyrus", "INV_Inscription_Scroll", "INV_Inscription_InkBlack01",
  "INV_Misc_Map_01", "INV_Misc_Map02", "INV_Misc_Map03", "INV_Misc_Spyglass_02", "INV_Misc_Spyglass_03",
  "INV_ValentinesCandy",
}

-- An icon value: a file number, a full path, or a short name from Interface\Icons
local function IconPath(v)
  if type(v) == "number" then return v end
  if type(v) == "string" and not v:find("\\", 1, true) then return "Interface\\Icons\\" .. v end
  return v
end

-- Every icon of the client, as the macro window lists them (file numbers, or
-- names in older clients). Spell icons first, then item icons.
local allIcons
local function AllGameIcons()
  if allIcons then return allIcons end
  local list = {}
  for _, fn in ipairs({ GetMacroIcons, GetMacroItemIcons }) do
    if fn then
      local before = #list
      pcall(fn, list) -- newer clients fill the table we give them
      if #list == before then -- older ones return a table
        local ok, r = pcall(fn)
        if ok and type(r) == "table" then for _, v in ipairs(r) do list[#list + 1] = v end end
      end
    end
  end
  if #list == 0 and GetNumMacroIcons and GetMacroIconInfo then -- oldest clients
    for i = 1, GetNumMacroIcons() do list[#list + 1] = GetMacroIconInfo(i) end
  end
  allIcons = list
  return list
end

local iconPicker
local function ApplyIcon()
  local tex = Icon()
  for _, t in ipairs(iconTextures) do t:SetTexture(tex) end
end

local COLS, ROWS, SIZE, GAP = 10, 7, 40, 6

function KT.ToggleIconPicker()
  if not KT.IsDev() then return end
  api = KT.api
  if not iconPicker then
    local ok, f = pcall(CreateFrame, "Frame", "WayfarersTalesIcons", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not f then
      f = CreateFrame("Frame", "WayfarersTalesIcons", UIParent, BACKDROP_TEMPLATE)
      if f.SetBackdrop then
        f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
          edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
          insets = { left = 11, right = 12, top = 12, bottom = 11 } })
      end
      local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
      close:SetPoint("TOPRIGHT", -4, -4)
    end
    if f.TitleText then f.TitleText:SetText("Wayfarer's Tales - icons (dev)") end
    f:SetSize(COLS * (SIZE + GAP) + 30, ROWS * (SIZE + GAP) + 120)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "WayfarersTalesIcons")
    f.mode, f.page = "selection", 1

    -- which list
    local modeSel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    modeSel:SetSize(150, 22)
    modeSel:SetPoint("TOPLEFT", 14, -30)
    modeSel:SetText("Sélection")
    local modeAll = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    modeAll:SetSize(200, 22)
    modeAll:SetPoint("LEFT", modeSel, "RIGHT", 6, 0)
    modeAll:SetText("Toutes les icônes du jeu")
    modeSel:SetScript("OnClick", function() f.mode, f.page = "selection", 1; f:Refresh() end)
    modeAll:SetScript("OnClick", function() f.mode, f.page = "all", 1; f:Refresh() end)
    f.modeSel, f.modeAll = modeSel, modeAll

    -- the grid (drawn like the minimap button's icon: a sized texture on a button)
    f.buttons = {}
    for i = 1, COLS * ROWS do
      local b = CreateFrame("Button", nil, f)
      b:SetSize(SIZE, SIZE)
      b:SetPoint("TOPLEFT", 15 + ((i - 1) % COLS) * (SIZE + GAP), -60 - math.floor((i - 1) / COLS) * (SIZE + GAP))
      local sel = b:CreateTexture(nil, "BACKGROUND")
      sel:SetPoint("TOPLEFT", -3, 3)
      sel:SetPoint("BOTTOMRIGHT", 3, -3)
      sel:SetColorTexture(1, 0.82, 0, 1)
      b.sel = sel
      local slot = b:CreateTexture(nil, "BACKGROUND", nil, 1)
      slot:SetAllPoints()
      slot:SetColorTexture(0.08, 0.08, 0.1, 1)
      local icon = b:CreateTexture(nil, "ARTWORK")
      icon:SetSize(SIZE - 2, SIZE - 2)
      icon:SetPoint("CENTER")
      b.icon = icon
      b.cross = b:CreateFontString(nil, "OVERLAY", "GameFontRedLarge")
      b.cross:SetPoint("CENTER")
      b.cross:SetText("x")
      b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
      b:SetScript("OnEnter", function(self)
        if self.value == nil then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(tostring(self.value), 1, 1, 1)
        if self.missing then GameTooltip:AddLine("(absente du jeu)", 1, 0.3, 0.3) end
        GameTooltip:Show()
      end)
      b:SetScript("OnLeave", function() GameTooltip:Hide() end)
      b:SetScript("OnClick", function(self)
        if self.value == nil or self.missing then return end
        api.GetDB().settings.iconTry = self.value
        ApplyIcon()
        f:Refresh()
      end)
      f.buttons[i] = b
    end

    -- pages (all icons)
    local prev = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    prev:SetSize(30, 22)
    prev:SetPoint("BOTTOMLEFT", 14, 40)
    prev:SetText("<")
    prev:SetScript("OnClick", function() f.page = math.max(1, f.page - 1); f:Refresh() end)
    local nxt = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    nxt:SetSize(30, 22)
    nxt:SetPoint("LEFT", prev, "RIGHT", 4, 0)
    nxt:SetText(">")
    nxt:SetScript("OnClick", function() f.page = f.page + 1; f:Refresh() end)
    f.pageText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.pageText:SetPoint("LEFT", nxt, "RIGHT", 10, 0)
    f.prev, f.nxt = prev, nxt

    f.current = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.current:SetPoint("BOTTOMLEFT", 16, 16)
    local reset = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    reset:SetSize(120, 22)
    reset:SetPoint("BOTTOMRIGHT", -14, 12)
    reset:SetText(DEFAULT or "Default")
    reset:SetScript("OnClick", function()
      api.GetDB().settings.iconTry = nil
      ApplyIcon()
      f:Refresh()
    end)

    function f:Refresh()
      local tried = api.GetDB().settings.iconTry
      local list = self.mode == "all" and AllGameIcons() or ICON_CANDIDATES
      local per = COLS * ROWS
      local pages = math.max(1, math.ceil(#list / per))
      if self.page > pages then self.page = pages end
      local found, missing = 0, 0
      for i, b in ipairs(self.buttons) do
        local v = list[(self.page - 1) * per + i]
        b.value, b.missing = v, nil
        if v == nil then
          b:Hide()
        else
          b:Show()
          b.icon:SetTexture(nil)
          local r = b.icon:SetTexture(IconPath(v))
          b.missing = (r == false) or (b.icon:GetTexture() == nil)
          b.cross:SetShown(b.missing)
          if b.missing then missing = missing + 1 else found = found + 1 end
          b.sel:SetShown(v == tried)
        end
      end
      local paged = self.mode == "all"
      self.prev:SetShown(paged)
      self.nxt:SetShown(paged)
      self.pageText:SetText(paged and string.format("Page %d / %d  (%d icônes)", self.page, pages, #list)
        or string.format("%d trouvées, %d absentes", found, missing))
      self.current:SetText(tried and ("|cffffd100" .. tostring(tried) .. "|r") or "(default)")
      if self.mode == "all" then self.modeAll:LockHighlight(); self.modeSel:UnlockHighlight()
      else self.modeSel:LockHighlight(); self.modeAll:UnlockHighlight() end
    end
    f:Hide()
    iconPicker = f
  end
  iconPicker:SetShown(not iconPicker:IsShown())
  if iconPicker:IsShown() then iconPicker:Refresh() end
end
