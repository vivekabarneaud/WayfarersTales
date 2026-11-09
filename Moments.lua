-- Wayfarer's Tales - Moments: little lines when something happens to you
-- (a hard fight, a meal, gathering, a hearthstone, dawn, the bank...).
-- Part of the Senses module (same on/off switch, same rhythm option).
-- Lines and timers live in MomentsData.lua.

local _, KT = ...
local D, W = KT.Data, KT.World
local S = KT.Senses
local Mo = {}
KT.Moments = Mo

local RHYTHM_MULT = { [1] = 0.5, [2] = 1, [3] = 1.4 }

local function SpellName(id)
  if not (C_Spell and C_Spell.GetSpellName) then return nil end
  local ok, n = pcall(C_Spell.GetSpellName, id)
  return ok and n or nil
end

-- run a function, and save its error (if any) to the error log
local function Safe(fn, name)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then KT.LogError("Moments " .. name, err) end
  end
end

local function After(sec, fn, name) C_Timer.After(sec, Safe(fn, name or "timer")) end

---------------------------------------------------------------------------
-- Playing a moment
---------------------------------------------------------------------------

-- Can moment `key` play now? (its own timer, the gap since the last line, its chance)
local function Ready(key)
  local state = S.State()
  if not state or not S.CanSpeak() then return nil end
  local rule = D.MOMENT_RULES[key]
  if not rule then return nil end
  state.moments = state.moments or {}
  local now = time()
  if now - (state.moments[rule.shares or key] or 0) < (rule.cd or 0) then return nil end
  if now - (state.lastLine or 0) < (rule.gap or 60) then return nil end
  local chance = math.min(1, (rule.chance or 1) * (RHYTHM_MULT[S.Rhythm()] or 1))
  if math.random() >= chance then return nil end
  return rule, state
end

local function Commit(key, rule, state)
  state.moments[rule.shares or key] = time()
end

-- Pick one of the moment's lines that fits here and now (not the same as last time)
local function PickLine(key, state, ctx)
  local lines = D.MOMENTS[key]
  if not lines then return nil end
  local fits = {}
  for i, line in ipairs(lines) do
    if S.Check(line.when, ctx) then fits[#fits + 1] = i end
  end
  state.momentLine = state.momentLine or {}
  local last = state.momentLine[key]
  if #fits > 1 and last then
    for j = #fits, 1, -1 do if fits[j] == last then table.remove(fits, j) end end
  end
  if #fits == 0 then return nil end
  local i = fits[math.random(#fits)]
  state.momentLine[key] = i
  return lines[i], i
end

function Mo.Play(key, vars)
  local rule, state = Ready(key)
  if not rule then return false end
  local line, i = PickLine(key, state, S.Context())
  if not line then return false end
  Commit(key, rule, state)
  S.Show({ line = line, id = "moment:" .. key .. ":" .. i, src = "moment", kind = "moment" }, false, nil, vars)
  return true
end
local Play = Mo.Play

-- Standing still for a while: "You stop for a moment..." + a line about this place
-- (long lines favoured, like on a first visit).
local function Quiet()
  local ctx = S.Context()
  if ctx.eating or ctx.drinking or ctx.afk then return end
  local rule, state = Ready("quiet")
  if not rule then return end
  local list = {}
  for _, c in ipairs(S.Candidates(ctx, "ambient")) do
    c.kind = "quiet"
    list[#list + 1] = c
  end
  local c = S.PickFrom(list, ctx)
  if not c then return end
  local lead = PickLine("quiet", state, ctx)
  if not lead then return end
  Commit("quiet", rule, state)
  S.Show(c, false, nil, nil, S.LineText(lead))
end

---------------------------------------------------------------------------
-- What happens to you
---------------------------------------------------------------------------

local function HasDebuff(spellID)
  local name = SpellName(spellID)
  for i = 1, 40 do
    local ok, data = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HARMFUL")
    if not ok or not data then break end
    if data.spellId == spellID or (name and data.name == name) then return true end
  end
  return false
end

local function Revive()
  Play(HasDebuff(D.AURA_RES_SICKNESS) and "reviveSick" or "revive")
end

-- Fights: how long, and how low your health went
local fightStart, minHealth
local function HealthPct()
  local max = UnitHealthMax("player") or 0
  if max <= 0 then return 1 end
  return (UnitHealth("player") or max) / max
end

local function FightEnded()
  if not fightStart then return end
  local duration, low = GetTime() - fightStart, minHealth or 1
  fightStart, minHealth = nil, nil
  After(2.5, function()
    if UnitIsDeadOrGhost("player") or UnitAffectingCombat("player") then return end
    if low < D.CLOSE_FIGHT_HEALTH then
      Play("afterFightClose")
    elseif low < D.HARD_FIGHT_HEALTH or duration >= D.HARD_FIGHT_TIME then
      Play("afterFight")
    end
  end, "fight")
end

-- Eating and drinking
local wasEating, wasDrinking
local function CheckMeal()
  local eating = W.HasAura(D.SPELL_FOOD_AURA, true)
  local drinking = W.HasAura(D.SPELL_DRINK_AURA, true)
  if eating and not wasEating then
    -- the item leaves the bags around the same moment: look a little later
    After(1, function()
      local _, link = KT.LastFood and KT.LastFood()
      if link then Play("eatItem", { item = link }) else Play("eat") end
    end, "eat")
  elseif drinking and not wasDrinking and not eating then
    After(1, function()
      local _, link = KT.LastFood and KT.LastFood()
      if link then Play("drinkItem", { item = link }) else Play("drink") end
    end, "drink")
  end
  wasEating, wasDrinking = eating, drinking
end

-- Spells you cast: gathering and the hearthstone (found by name, for all ranks)
local SPELL_MOMENTS = { [2366] = "herb", [2575] = "mine", [8613] = "skin", [8690] = "hearth" }
local spellByName = {}
local hearthAt
local function OnSpell(spellID)
  local key = SPELL_MOMENTS[spellID]
  if not key then
    local name = SpellName(spellID)
    if not name then return end
    if not next(spellByName) or not spellByName._complete then
      local n = 0
      for id, k in pairs(SPELL_MOMENTS) do
        local sn = SpellName(id)
        if sn then spellByName[sn] = k; n = n + 1 end
      end
      spellByName._complete = (n == 4) or nil
    end
    key = spellByName[name]
  end
  if not key then return end
  if key == "hearth" then
    hearthAt = GetTime() -- the line comes once you've arrived
  else
    After(1, function() Play(key) end, "gather")
  end
end

---------------------------------------------------------------------------
-- Every few seconds: flights, dawn and dusk, stepping in and out, standing still
---------------------------------------------------------------------------

local stillSince, quietDone, taxiSince, lastNight, lastIndoors, wasDead

local function Tick()
  if not S.State() then return end
  local now = GetTime()

  -- back to life?
  local dead = UnitIsDeadOrGhost("player") and true or false
  if wasDead and not dead then
    lastIndoors, stillSince, quietDone = nil, nil, nil
    wasDead = false
    After(2, Revive, "revive")
    return
  end
  wasDead = dead
  if dead then stillSince = nil return end

  if fightStart then minHealth = math.min(minHealth or 1, HealthPct()) end

  -- landing after a long flight
  local onTaxi = UnitOnTaxi and UnitOnTaxi("player") or false
  if onTaxi then
    taxiSince = taxiSince or now
  elseif taxiSince then
    local duration = now - taxiSince
    taxiSince = nil
    if duration >= D.LONG_FLIGHT then After(2, function() Play("landing") end, "landing") end
  end

  -- arrived with the hearthstone
  if hearthAt and now - hearthAt > 3 then
    if now - hearthAt < 120 then Play("hearth") end
    hearthAt = nil
  end

  -- dawn and dusk (outdoors, not in a dungeon)
  local night = W.IsNight()
  local indoors = IsIndoors and IsIndoors() or false
  if lastNight ~= nil and night ~= lastNight and not indoors and not IsInInstance() then
    Play(night and "dusk" or "dawn")
  end
  lastNight = night

  -- stepping in or out
  if lastIndoors ~= nil and indoors ~= lastIndoors and not onTaxi then
    Play(indoors and "goIn" or "goOut")
  end
  lastIndoors = indoors

  -- standing still for a while (not AFK, not fighting, not swimming)
  local moving = GetUnitSpeed and (GetUnitSpeed("player") or 0) > 0
  local busy = onTaxi or UnitAffectingCombat("player") or UnitIsAFK("player") or IsSwimming()
  if moving or busy then
    stillSince, quietDone = nil, nil
  else
    stillSince = stillSince or now
    if not quietDone and now - stillSince >= D.QUIET_AFTER then
      quietDone = true -- once per stop: move again to get another one
      Quiet()
    end
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local ERRANDS = { BANKFRAME_OPENED = "bank", MAIL_SHOW = "mail", AUCTION_HOUSE_SHOW = "auction", TRAINER_SHOW = "trainer" }

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
  "BANKFRAME_OPENED", "MAIL_SHOW", "AUCTION_HOUSE_SHOW", "TRAINER_SHOW" }) do
  pcall(f.RegisterEvent, f, ev)
end
-- only about you (not every unit around)
for _, ev in ipairs({ "UNIT_AURA", "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_SPELLCAST_SUCCEEDED" }) do
  if not (f.RegisterUnitEvent and pcall(f.RegisterUnitEvent, f, ev, "player")) then
    pcall(f.RegisterEvent, f, ev)
  end
end

f:SetScript("OnEvent", function(_, event, ...)
  local ok, err = pcall(function(...)
    if event == "PLAYER_LOGIN" then
      C_Timer.NewTicker(5, Safe(Tick, "tick"))
      wasEating = W.HasAura(D.SPELL_FOOD_AURA, true)
      wasDrinking = W.HasAura(D.SPELL_DRINK_AURA, true)
    elseif event == "PLAYER_REGEN_DISABLED" then
      fightStart, minHealth = GetTime(), HealthPct()
    elseif event == "PLAYER_REGEN_ENABLED" then
      FightEnded()
    elseif ERRANDS[event] then
      local key = ERRANDS[event]
      After(0.3, function() Play(key) end, "errand")
    else
      local unit = ...
      if unit ~= "player" then return end
      if event == "UNIT_AURA" then
        CheckMeal()
      elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpell(select(3, ...))
      elseif fightStart then -- UNIT_HEALTH
        minHealth = math.min(minHealth or 1, HealthPct())
      end
    end
  end, ...)
  if not ok then KT.LogError("Moments " .. tostring(event), err) end
end)
