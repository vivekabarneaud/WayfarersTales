-- Wayfarer's Tales - game data, tuning numbers and default settings.
-- (Climate per zone is in World.lua, immersion lines in SensesData.lua.)
-- IDs below were confirmed in WoW Forever 1.60.1 with the Companion Scout addon
-- unless marked otherwise.

local _, KT = ...
local D = {}
KT.Data = D

-- Bond stages (minimum affection for each). Names live in Locale.lua.
D.TIERS = { 0, 20, 40, 60, 80, 100 }

-- Spells (confirmed)
D.SPELL_FEED_PET   = 6991
D.SPELL_REVIVE_PET = 982
D.SPELL_FOOD_AURA  = 433   -- "Food" buff while eating
D.SPELL_DRINK_AURA = 430   -- "Drink" buff
D.SPELL_FISHING    = { [7620] = true, [7731] = true, [7732] = true, [18248] = true }

-- Campfire auras (confirmed; both you and your pet get them)
D.AURA_CAMP_NEAR     = 1283391 -- "Campfire nearby"
D.AURA_CAMP_WELCOME  = 1229739 -- 60s "stay seated" buff
D.AURA_CAMP_BENEFITS = 1229741 -- the 1-hour camp buff

-- Affection rules: amount, cooldown in seconds, daily cap.
D.GAIN = {
  emote    = { amount = 1,   cooldown = 900,  cap = 4 },
  feed     = { amount = 1,   cooldown = 600,  cap = 3 },
  meal     = { amount = 4 },                 -- shared the exact food it asked for
  mealAlt  = { amount = 2 },                 -- shared another food
  campfire = { amount = 2,   cooldown = 3000, cap = 4 },
  kill     = { amount = 0.1,                  cap = 2 },
  time     = { amount = 0.2,                  cap = 2 }, -- every 10 minutes together
  comfort  = { amount = 1,                    cap = 2 }, -- cuddle/feed soon after a revive
  loyalty  = { amount = 2 },
  reunion  = { amount = 1,   cooldown = 72000 },
  play     = { amount = 0.5, cooldown = 900,  cap = 2 }, -- playful emotes, once the pet trusts you
  sad      = { amount = 0.5, cooldown = 1800, cap = 1 }, -- the pet comforts you
  attention = { amount = 2 },                -- answered a petting request in time
  sorry    = { amount = 0.5 },               -- apologized soon after being rude
  level    = { amount = 1 },                 -- you gained a level together
}
D.SORRY_WINDOW = 600 -- seconds after a rude emote during which /sorry works
D.GAIN.favorite    = { amount = 2 } -- fed its favorite food (same cooldown as normal feeding)
D.GAIN.treat       = { amount = 2 } -- fed the food it noticed in your loot, in time
D.GAIN.celebrate   = { amount = 1 } -- cheered for its level-up, in time
D.TREAT_WINDOW     = 120
D.CELEBRATE_WINDOW = 120
-- Emotes that count as cheering for a level-up
D.CELEBRATE = { CHEER = true, CLAP = true, APPLAUD = true, BRAVO = true, WOOT = true,
  CONGRATULATE = true, CONGRATS = true }
D.GAIN.anniversary = { amount = 3 }

-- Food types a pet can have as secret favorite / dislike.
D.FOOD_KINDS = { "meat", "fish", "cheese", "bread", "fungus", "fruit" }

-- Mood of the day and how it changes chances (1 = normal).
D.MOODS = { "playful", "sleepy", "cuddly", "curious", "hungry" }
D.MOOD_MULT = {
  playful = { idle = 1.5, playful = 1.5 },
  sleepy  = { idle = 1.2, attention = 0.5, playful = 0.5 },
  cuddly  = { attention = 2 },
  curious = { loot = 1.6, idle = 1.3 },
  hungry  = { meal = 1.6, loot = 1.3 },
}

-- Days together worth celebrating (counted from when the addon first met the pet).
D.DAY_MILESTONES = { 7, 30, 100 }

-- Pet stance tokens (same in every language)
D.PET_MODES = { PET_MODE_PASSIVE = "Passive", PET_MODE_DEFENSIVE = "Defensive",
  PET_MODE_AGGRESSIVE = "Aggressive", PET_MODE_ASSIST = "Aggressive" }

-- Relationship "bands" used to pick reactions: shy / friendly / devoted.
-- A band starts at this affection.
D.BANDS = { 0, 40, 80 }

-- Emote token -> kind of reaction. Tokens are the same in every language.
D.EMOTES = {
  PET = "affection", HUG = "affection", LOVE = "affection", CUDDLE = "affection", KISS = "affection",
  SOOTHE = "affection", PAT = "affection", TICKLE = "affection", SNUGGLE = "affection",
  DANCE = "playful", CHEER = "playful", FLEX = "playful", SILLY = "playful", BOUNCE = "playful",
  CLAP = "playful", LAUGH = "playful", GIGGLE = "playful", JOKE = "playful", WHISTLE = "playful",
  APPLAUD = "playful", BRAVO = "playful", WOOT = "playful", CONGRATULATE = "playful", CONGRATS = "playful",
  CHICKEN = "chicken", FLAP = "chicken", STRUT = "chicken",
  ROAR = "roar", GROWL = "roar",
  SLEEP = "rest", SIT = "rest", KNEEL = "rest", YAWN = "rest", TIRED = "rest", LAYDOWN = "rest", LIE = "rest", BORED = "rest",
  CRY = "sad", SIGH = "sad", MOURN = "sad", SAD = "sad", SULK = "sad", WEEP = "sad",
  HELLO = "greet", WAVE = "greet", BOW = "greet", SALUTE = "greet", WELCOME = "greet", GREET = "greet", HI = "greet",
  HUNGRY = "hungry", EAT = "hungry", DRINK = "hungry",
  SLAP = "rude", RUDE = "rude", SPIT = "rude", INSULT = "rude", ANGRY = "rude", PUNCH = "rude",
  KICK = "rude", SHOO = "rude", THREATEN = "rude", GLARE = "rude",
  SORRY = "sorry", APOLOGIZE = "sorry",
}
-- Kinds the pet also notices when the emote isn't aimed at it.
D.EMOTE_UNTARGETED = { playful = true, chicken = true, roar = true, rest = true, sad = true, hungry = true, sorry = true }
-- Backup when the emote command can't be seen: words that mean "affection" (EN/FR).
D.AFFECTION_WORDS = { "cajol", "câlin", "calin", "caress", "embrass", "aime", "pet ", "hug", "cuddle", "love", "kiss" }
D.LOSS = {
  death       = { amount = 1, cooldown = 600 },
  rude        = { amount = 1, cooldown = 300 },
  stableWeek  = { amount = 1, max = 5 },  -- per full week spent in the stable
}

D.MEAL_WINDOW        = 120   -- seconds to answer a meal request
D.ATTENTION_WINDOW   = 120   -- seconds to answer a petting request
D.ATTENTION_COOLDOWN = 2400
D.IDLE_COOLDOWN      = 600
D.MEAL_COOLDOWN      = 1200
D.COMFORT_WINDOW     = 300
D.FISHING_WINDOW     = 40
D.FLAVOR_COOLDOWN    = 25    -- minimum gap between two random flavor messages
D.CHATTY_MULT        = { [0] = 0, [1] = 0.5, [2] = 1, [3] = 1.6 }

-- Pet family (as the game names it) -> body type, so reactions fit the animal.
-- Anything not listed counts as "furry". English and French names.
D.FAMILY_TYPE = {
  Owl = "bird", Chouette = "bird", Hibou = "bird",
  ["Carrion Bird"] = "bird", Charognard = "bird",
  Tallstrider = "bird", ["Haut-trotteur"] = "bird", Trotteur = "bird",
  Crocolisk = "scaly", Crocilisque = "scaly",
  Raptor = "scaly",
  Turtle = "scaly", Tortue = "scaly",
  ["Wind Serpent"] = "scaly", ["Serpent des vents"] = "scaly",
  Spider = "chitin", ["Araignée"] = "chitin",
  Scorpid = "chitin", Scorpide = "chitin",
  Crab = "chitin", Crabe = "chitin",
}

-- Food type names as the game shows them in the pet's diet, per language.
D.FOOD_TYPE_NAMES = {
  Meat = "meat", Fish = "fish", Cheese = "cheese", Bread = "bread", Fungus = "fungus", Fruit = "fruit",
  Viande = "meat", Poisson = "fish", Fromage = "cheese", Pain = "bread", Champignon = "fungus",
}

-- Food item -> type. Classic item IDs from memory (not all checked in Forever),
-- plus Forever items seen in testing. Pets also learn: anything a pet has eaten
-- once is remembered as something it likes.
D.FOOD = {}
local function add(kind, ids) for _, id in ipairs(ids) do D.FOOD[id] = kind end end
add("meat", { 117, 2287, 3770, 3771, 4599, 8952, 2679, 2680, 2681, 2684, 2687, 724, 1017, 2888,
  3220, 3662, 3726, 3727, 3728, 4457, 12209, 12210, 12213,
  -- raw meat
  769, 1015, 2672, 2673, 2677, 3173, 3667, 3730, 3731, 12037, 12184, 12203, 12205, 5051, 723,
  729, 1081, 2924, 3404, 4739, 5467, 5469, 5470, 5471 })
add("fish", { 787, 4592, 4593, 4594, 5095, 6290, 6316, 6887, 8364, 8957, 13930, 13933, 13935, 21552,
  -- raw fish
  6291, 6303, 6289, 6308, 6317, 6361, 6362, 8365, 4603, 13754, 13756, 13758, 13759, 13760,
  13888, 13889, 13893, 21071, 21153 })
add("cheese", { 414, 422, 1707, 2070, 3927, 8932, 252030 })
add("bread",  { 4540, 4541, 4542, 4544, 4601, 8950 })
add("fruit",  { 4536, 4537, 4538, 4539, 4602, 8953 })
add("fungus", { 4604, 4605, 4606, 4607, 4608, 8948 })

---------------------------------------------------------------------------
-- Sounds
---------------------------------------------------------------------------

-- Pet family (EN/FR names) -> sound set below.
D.FAMILY_SOUND = {
  Bear = "bear", Ours = "bear",
  Wolf = "wolf", Loup = "wolf",
  Cat = "cat", ["Félin"] = "cat",
  Boar = "boar", Sanglier = "boar",
  Owl = "owl", Chouette = "owl", Hibou = "owl",
  ["Carrion Bird"] = "carrion", Charognard = "carrion",
  Raptor = "raptor",
  Hyena = "hyena", ["Hyène"] = "hyena",
  Gorilla = "gorilla", Gorille = "gorilla",
  Crab = "crab", Crabe = "crab", Scorpid = "crab", Scorpide = "crab",
  Tallstrider = "tallstrider", ["Haut-trotteur"] = "tallstrider", Trotteur = "tallstrider",
  Spider = "spider", ["Araignée"] = "spider",
  Bat = "bat", ["Chauve-souris"] = "bat",
  Turtle = "turtle", Tortue = "turtle",
  ["Wind Serpent"] = "serpent", ["Serpent des vents"] = "serpent",
}

-- The game's original creature sounds (FileDataIDs from the community listfile).
-- happy = cuddles, food, cosy moments / excited = play, roars, big news / hurt = rude emotes
D.SOUND_SETS = {
  bear        = { happy = { 544953, 544951 }, excited = { 544959 }, hurt = { 544957 } },   -- Bear/mBearAttackA,B / AggroA / WoundA
  wolf        = { happy = { 564223, 564226, 564228 }, excited = { 564215, 564229 }, hurt = { 564225 } }, -- Wolf/Fidget2a,b,c / Aggro1,2 / Wound1
  cat         = { happy = { 562388 }, excited = { 562387, 545949 }, hurt = { 562390 } },  -- Tiger/Stand2A / Tiger AggroA, CatAggro / WoundA
  boar        = { happy = { 545136, 545135 }, excited = { 545134 }, hurt = { 545137 } },
  owl         = { happy = { 557971 }, excited = { 557977 }, hurt = { 557970 } },
  carrion     = { happy = { 545939 }, excited = { 545937 }, hurt = { 545940 } },
  raptor      = { happy = { 558870 }, excited = { 558877 }, hurt = { 558873 } },
  hyena       = { happy = { 552343 }, excited = { 552339 }, hurt = { 552337 } },
  gorilla     = { happy = { 550961 }, excited = { 550967 }, hurt = { 550970 } },
  crab        = { happy = { 546432 }, excited = { 546423 }, hurt = { 546426 } },
  tallstrider = { happy = { 561393 }, excited = { 561396, 561390 }, hurt = { 561388 } },
  spider      = { happy = { 549870 }, excited = { 549868 }, hurt = { 549873 } },
  bat         = { happy = { 555483 }, excited = { 555491 }, hurt = { 555484 } },
  turtle      = { happy = { 559872 }, excited = { 559878 }, hurt = { 559879 } },
  serpent     = { happy = { 559973 }, excited = { 559967 }, hurt = { 559970 } },
}

-- Interface chimes for big moments (classic quest sounds)
D.UI_SOUNDS = {
  big      = 567439, -- iQuestComplete
  discover = 567516, -- iQuestUpdate
}

-- Your own sound files can replace any kind, e.g.
-- D.CUSTOM_SOUNDS["ui:big"] = "Interface\\AddOns\\WayfarersTales\\Media\\chime.ogg"
D.CUSTOM_SOUNDS = {}

-- Which message plays which sound. Random/idle lines stay silent on purpose.
D.POOL_SOUND = {
  affection = "happy", feed = "happy", feedFavorite = "happy", mealShared = "happy", mealOther = "happy",
  mealRequest = "happy", attentionRequest = "happy", attentionAnswered = "happy", comfort = "happy",
  sorryForgive = "happy", campfireRest = "happy", reunion = "excited", stableReunion = "excited",
  playful = "excited", roar = "excited", chicken = "excited", followAfterStay = "excited",
  campfireEnergized = "excited", playerLevel = "excited",
  rude = "hurt",
  tierUp = "ui:big", loyaltyUp = "ui:big", anniversary = "ui:big", daysTogether = "ui:big",
  feedFavoriteFirst = "ui:discover", favoriteRevealed = "ui:discover",
  treatGiven = "happy", celebrated = "excited",
  petDangerHigh = "excited", petDangerNear = "excited",
}

-- Default settings (applied once, for any setting not saved yet).
-- tempUnit isn't here on purpose: without a choice it follows the game's language.
D.DEFAULTS = {
  chatty = 2,              -- how often the pet speaks up (0-3)
  sound = true,
  label = false,           -- "Wayfarer's Tales" before the pet's lines
  language = "auto",
  gender = "auto",         -- your character's grammatical gender (French)
  debug = false,
  minimap = true,
  minimapAngle = 200,
  showHeart = true,
  showThermo = true,
  thermoAngle = 15,
  bodyStyle = "none",      -- body comfort by your portrait: none / icons / bars
  sensesRhythm = 2,        -- how often immersion lines appear (0-3)
  sensesStyle = "mixed",   -- line length: short / mixed / rich
}
D.SOUND_GAP = 3 -- minimum seconds between two animal sounds (chimes ignore it)

-- Your own icon art: set to a path like "Interface\\AddOns\\WayfarersTales\\Media\\heart"
-- once the file exists (a missing file shows as a green square).
D.CUSTOM_ICON = nil

-- Foods not in the list above (many Forever foods): guess the type from words in
-- the item name, French and English. Checked in this order, first match wins
-- (fish before meat so "chair de pinces"/"crab cake" count as fish, like in classic).
D.FOOD_WORDS = {
  { "fish", { "poisson", "fish", "goujon", "saumon", "salmon", "truite", "trout", "morue", "cod",
    "maquereau", "mackerel", "vivaneau", "snapper", "crabe", "crab", "pince", "claw", "homard", "lobster",
    "anguille", "eel", "calmar", "squid", "palourde", "clam", "flétan", "halibut", "thon", "tuna",
    "sardine", "bass", "sagefish", "albacore", "mightfish", "redgill", "yellowtail" } },
  { "cheese", { "fromage", "cheese", "cheddar", "brie", "gruyère", "emmental", "swiss" } },
  { "fungus", { "champignon", "mushroom", "morille", "morel", "truffe", "truffle", "bolet", "bolete", "moisissure", "mold" } },
  { "fruit", { "pomme", "apple", "banane", "banana", "melon", "pastèque", "citrouille", "pumpkin", "fruit",
    "baie", "berry", "raisin", "grape", "poire", "pear", "peach", "cerise", "cherry", "plantain" } },
  { "bread", { "pain", "bread", "muffin", "biscuit", "galette", "brioche", "gâteau", "cake", "tarte", "pie",
    "croissant", "beignet", "cornbread" } },
  { "meat", { "viande", "meat", "steak", "jerky", "jambon", "ham", "saucisse", "sausage", "jarret", "shank",
    "côtelette", "chop", "rôti", "roast", "caille", "quail", "bacon", "lard", "côte", "rib", "cuisse",
    "haunch", "boulette", "kabob", "brochette", "pâté", "chair", "aile", "wing", "flank", "flanc" } },
}

-- Drinks, so a looted water bottle doesn't make your pet drool.
D.DRINKS = { [159] = true, [1179] = true, [1205] = true, [1708] = true, [1645] = true, [8766] = true, [252031] = true }
