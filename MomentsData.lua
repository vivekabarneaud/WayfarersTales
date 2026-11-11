-- Wayfarer's Tales - Moments lines: little lines when something happens to you
-- (a hard fight, a meal, gathering, dawn, the bank...). Part of the Senses module.
--
-- Same RULE as SensesData.lua: a line must be true every time it can play.
-- Lines use the same conditions ("when") as the Senses lines.
-- {item} = the food or drink, when we know it.

local _, KT = ...
local D = KT.Data

-- Each moment has its own timer:
--   cd     = seconds before this moment can play again
--   chance = for very frequent actions only: how often it plays when it can (1 = always)
--   (the Rare rhythm makes every cd x1.5, Often x0.6)
--   gap    = it never plays less than this many seconds after another Senses line
--   shares = uses the timer of another moment (e.g. stepping in and stepping out)
D.MOMENT_RULES = {
  eat             = { cd = 900,  chance = 1, gap = 20 },
  eatItem         = { cd = 900,  chance = 1, gap = 20, shares = "eat" },
  drink           = { cd = 900,  chance = 1, gap = 20 },
  drinkItem       = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  drinkWater      = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  drinkConjured   = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  drinkMilk       = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  drinkJuice      = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  drinkDew        = { cd = 900,  chance = 1, gap = 20, shares = "drink" },
  -- your own food diary (see D.MEAL_FAMILIAR, D.MEAL_MILESTONES)
  firstTaste      = { cd = 0,    chance = 1,   gap = 10, shares = "eat" },
  firstSip        = { cd = 0,    chance = 1,   gap = 10, shares = "drink" },
  familiarFood    = { cd = 900,  chance = 1,   gap = 20, shares = "eat" },
  familiarDrink   = { cd = 900,  chance = 1,   gap = 20, shares = "drink" },
  foodMilestone   = { cd = 0,    chance = 1,   gap = 10, shares = "eat" },
  drinkMilestone  = { cd = 0,    chance = 1,   gap = 10, shares = "drink" },
  lootRare        = { cd = 300,  chance = 1,   gap = 0 },
  lootEpic        = { cd = 0,    chance = 1,   gap = 0 },
  lootLegendary   = { cd = 0,    chance = 1,   gap = 0 },
  craftRare       = { cd = 300,  chance = 1,   gap = 0 },
  craftEpic       = { cd = 0,    chance = 1,   gap = 0 },
  craftFirst      = { cd = 600,  chance = 1, gap = 20 },
  discoveryMilestone = { cd = 0, chance = 1,   gap = 30 },
  fall            = { cd = 300,  chance = 1,   gap = 10 },
  fallHard        = { cd = 300,  chance = 1,   gap = 0, shares = "fall" },
  campSit         = { cd = 900,  chance = 1,   gap = 10 },
  campRested      = { cd = 900,  chance = 1,   gap = 10 },
  petRain         = { cd = 900,  chance = 0.1, gap = 30 }, -- checked every 5 s while it rains
  fishCast        = { cd = 600,  chance = 1,   gap = 10 },
  fishWait        = { cd = 900,  chance = 1,   gap = 30 },
  fishCatch       = { cd = 300,  chance = 1,   gap = 0 },
  fishFirst       = { cd = 0,    chance = 1,   gap = 0 },
  fishJunk        = { cd = 600,  chance = 1,   gap = 0 },
  npc             = { cd = 120,  chance = 1,   gap = 20 },
  questAccept_2159 = { cd = 0,   chance = 1,   gap = 0 },
  afterFight      = { cd = 900,  chance = 1,   gap = 0 },
  afterFightClose = { cd = 900,  chance = 1,   gap = 0, shares = "afterFight" },
  quiet           = { cd = 1200, chance = 1,   gap = 120 },
  herb            = { cd = 1200, chance = 0.5, gap = 60 },
  -- each herb's own lines (D.HERBS) share the herb timer, a little shorter
  herb_peacebloom = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_silverleaf = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_earthroot  = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_mageroyal  = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_briarthorn = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_bruiseweed = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  herb_stranglekelp = { cd = 600, chance = 0.5, gap = 30, shares = "herb" },
  mine            = { cd = 1200, chance = 0.5, gap = 60 },
  skin            = { cd = 1200, chance = 0.5, gap = 60 },
  hearth          = { cd = 600,  chance = 1,   gap = 30 },
  landing         = { cd = 600,  chance = 1, gap = 30 },
  dawn            = { cd = 3600, chance = 1,   gap = 30 },
  dusk            = { cd = 3600, chance = 1,   gap = 30 },
  goIn            = { cd = 900,  chance = 1, gap = 60, shares = "door" },
  goOut           = { cd = 900,  chance = 1, gap = 60, shares = "door" },
  bank            = { cd = 1800, chance = 1, gap = 20 },
  mail            = { cd = 1800, chance = 1, gap = 20 },
  auction         = { cd = 1800, chance = 1, gap = 20 },
  trainer         = { cd = 1800, chance = 1, gap = 20 },
  learnProfession = { cd = 0,    chance = 1,   gap = 0 },
  craftRankUp     = { cd = 600,  chance = 1,   gap = 0 },
  learnRecipe     = { cd = 1800, chance = 0.35, gap = 30 },
  learnRecipe_boom = { cd = 1800, chance = 1,  gap = 30, shares = "learnRecipe" }, -- bombs, dynamite, powder...
  craftFirst_boom = { cd = 600,  chance = 1,   gap = 20, shares = "craftFirst" },
  revive          = { cd = 0,    chance = 1,   gap = 0 },
  reviveSick      = { cd = 0,    chance = 1,   gap = 0, shares = "revive" },
}

-- Each profession's own lines use the timer of the general ones
for _, k in ipairs({ "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism", "leatherworking",
  "mining", "skinning", "tailoring", "cooking", "firstaid", "fishing" }) do
  D.MOMENT_RULES["learn_" .. k] = { cd = 0,   chance = 1, gap = 0, shares = "learnProfession" }
  D.MOMENT_RULES["rank_" .. k]  = { cd = 600, chance = 1, gap = 0, shares = "craftRankUp" }
end

-- First taste of each kind of food / drink uses the same timer as the general one
for _, k in ipairs({ "meat", "fish", "cheese", "bread", "fungus", "fruit" }) do
  D.MOMENT_RULES["firstTaste_" .. k] = D.MOMENT_RULES.firstTaste
end
for _, k in ipairs({ "Water", "Conjured", "Milk", "Juice", "Dew" }) do
  D.MOMENT_RULES["firstSip_" .. k] = D.MOMENT_RULES.firstSip
end

-- Your food diary: after this many times, a food or drink is an old favourite
-- (and now and then gets its own line); these counts get a little celebration.
D.MEAL_FAMILIAR = 10
D.MEAL_FAMILIAR_CHANCE = 0.4
D.MEAL_MILESTONES = { [25] = true, [50] = true, [100] = true }

-- A brand new character's very first moments: where you open your eyes (by race,
-- always the race's starting area), then what you feel inside (by class).
-- Keys are the game's race / class file names (UnitRace / UnitClass).
D.BIRTH_RACE = {
  Human = { en = "You open your eyes on the green hills of Northshire. The abbey stands tall nearby, and beyond the valley, all of Elwynn is waiting for you.",
            fr = "Vous ouvrez les yeux sur les collines verdoyantes de Comté-du-Nord. L'abbaye se dresse non loin, et au-delà de la vallée, toute la forêt d'Elwynn vous attend." },
  Dwarf = { en = "Cold air bites your cheeks. Snow crunches under your feet in this icy valley, and the mountains of Dun Morogh rise all around you.",
            fr = "L'air froid vous mord les joues. La neige crisse sous vos pieds dans cette vallée glacée, et les montagnes de Dun Morogh se dressent tout autour de vous." },
  Gnome = { en = "Snow, cold, and mountains as far as the eye can see. Somewhere beyond them lies Gnomeregan, and the hope of taking it back one day.",
            fr = "De la neige, du froid, et des montagnes à perte de vue. Quelque part au-delà se trouve Gnomeregan, et l'espoir de la reprendre un jour." },
  NightElf = { en = "You awaken beneath the great boughs of Teldrassil. Soft light filters through the leaves, and the forest seems to whisper your name.",
               fr = "Vous vous éveillez sous les immenses branches de Teldrassil. Une douce lumière filtre à travers les feuilles, et la forêt semble murmurer votre nom." },
  Tauren = { en = "The wind runs free over the plains of Mulgore, carrying the scent of tall grass. The Earth Mother watches over your first steps.",
             fr = "Le vent court librement sur les plaines de Mulgore, chargé de l'odeur des hautes herbes. La Terre-Mère veille sur vos premiers pas." },
  Orc = { en = "The dry heat of Durotar hits you at once. Red dust, rocks, and a land that respects only strength.",
          fr = "La chaleur sèche de Durotar vous saisit aussitôt. Poussière rouge, rochers, et une terre qui ne respecte que la force." },
  Troll = { en = "Durotar's hot wind smells of dust and dry earth. Far from the islands, your people have found a new home, and you a new path.",
            fr = "Le vent chaud de Durotar sent la poussière et la terre sèche. Loin des îles, votre peuple a trouvé un nouveau foyer, et vous un nouveau chemin." },
  Scourge = { en = "You open your eyes in the grey mist of Tirisfal. No heartbeat, no warmth, only a strange, cold freedom.",
              fr = "Vous ouvrez les yeux dans la brume grise de Tirisfal. Pas de battement de cœur, pas de chaleur, seulement une étrange et froide liberté." },
  default = { en = "A new life begins here. The world is vast, and everything is still ahead of you.",
              fr = "Une nouvelle vie commence ici. Le monde est vaste, et tout reste encore devant vous." },
}
D.BIRTH_CLASS = {
  DRUID = { en = "Deep inside, you feel the slow heartbeat of nature, as if every living thing were whispering to you.",
            fr = "Au fond de vous, vous sentez battre le cœur lent de la nature, comme si chaque être vivant vous murmurait quelque chose." },
  WARRIOR = { en = "Your hand closes on your weapon's grip. It feels right, as if it had always belonged there.",
              fr = "Votre main se referme sur la poignée de votre arme. Elle semble à sa place, comme si elle l'avait toujours été." },
  PALADIN = { en = "A quiet warmth glows in your chest: the Light is with you, and you will carry it far.",
              fr = "Une chaleur paisible rayonne dans votre poitrine : la Lumière est avec vous, et vous la porterez loin." },
  HUNTER = { en = "Your eyes scan the horizon on their own. Somewhere out there, a faithful companion is waiting for you.",
             fr = "Vos yeux balaient l'horizon d'eux-mêmes. Quelque part, un fidèle compagnon vous attend." },
  ROGUE = { en = "You notice every shadow, every way out, every purse within reach. Old habits, already.",
            fr = "Vous remarquez chaque ombre, chaque issue, chaque bourse à portée de main. Déjà de vieilles habitudes." },
  PRIEST = { en = "A gentle calm settles over you. Others will need you one day, and you feel up to it.",
             fr = "Un calme doux vous envahit. D'autres auront besoin de vous un jour, et vous vous sentez à la hauteur." },
  SHAMAN = { en = "The elements stir around you: wind, earth, fire and water. They're listening.",
             fr = "Les éléments s'éveillent autour de vous : le vent, la terre, le feu et l'eau. Ils vous écoutent." },
  MAGE = { en = "Magic tingles at your fingertips, eager and a little dangerous. The world is full of things to learn.",
           fr = "La magie picote au bout de vos doigts, impatiente et un peu dangereuse. Le monde regorge de choses à apprendre." },
  WARLOCK = { en = "Something dark whispers at the edge of your mind. Power has a price, and you fully intend to pay it.",
              fr = "Quelque chose de sombre murmure aux confins de votre esprit. Le pouvoir a un prix, et vous comptez bien le payer." },
}

-- Discovery score ("Carnet" tab): points for each new thing discovered.
D.DISCOVERY_POINTS = {
  zones = 10, subzones = 2, spots = 5, dungeons = 15,   -- places
  tastes = 3,                                            -- foods and drinks
  professions = 10, crafts = 2,                          -- know-how
  flights = 3, inns = 3,                                 -- travels
}
-- crossing one of these totals brings a line in the chat (once each)
D.DISCOVERY_MILESTONES = { 50, 100, 250, 500, 1000, 2000, 4000 }

-- How long you stand still (not AFK, not fighting) before a quiet moment
D.QUIET_AFTER = 150
-- A fight counts as hard if it lasted this long, or left you below this much health
D.HARD_FIGHT_TIME = 60
D.HARD_FIGHT_HEALTH = 0.5
D.CLOSE_FIGHT_HEALTH = 0.2
-- Flights shorter than this don't get a landing line
D.LONG_FLIGHT = 60

-- Kinds of drinks, from words in the item's name (English and French, lowercase).
-- First match wins: "Conjured Water" is conjured, not plain water.
D.DRINK_WORDS = {
  { "Conjured", { "conjured", "invoqu" } },
  { "Milk",     { "milk", "lait" } },
  { "Dew",      { "dew", "rosée" } },
  { "Juice",    { "juice", "jus ", "nectar" } },
  { "Water",    { "water", "eau " } },
}

local NO_DARK ={ gloom = true, undercity = true } -- places where day and night barely show

D.MOMENTS = {
  -- You sit down to eat (and we don't know what)
  eat = {
    { en = "You sit down and take a first, slow bite.", fr = "Vous vous asseyez et prenez une première bouchée, sans vous presser." },
    { en = "You settle down to eat. It feels good to stop for a moment.", fr = "Vous vous installez pour manger. Ça fait du bien de s'arrêter un moment." },
    { en = "You eat slowly, savoring the pause as much as the food.", fr = "Vous mangez lentement, en savourant la pause autant que le repas." },
  },
  -- You sit down to eat, and we know the food
  eatItem = {
    { en = "You sit down with your {item}. The first bite is always the best.", fr = "Vous vous asseyez avec votre {item}. La première bouchée est toujours la meilleure." },
    { en = "You dig into your {item}. Simple, and so satisfying.", fr = "Vous attaquez votre {item}. Simple, et tellement bon." },
    { en = "You take your time with your {item}. No hurry, just for a moment.", fr = "Vous prenez le temps de savourer votre {item}. Rien ne presse, juste un instant." },
  },
  -- The first time you eat a food: taste, texture and how it makes you feel
  firstTaste = {
    { en = "You taste your {item} for the first time. A careful bite, then another, with curiosity: every flavor is a small discovery.",
      fr = "Vous goûtez votre {item} pour la première fois. Une bouchée prudente, puis une autre, avec curiosité : chaque saveur est une petite découverte." },
    { en = "Something new: your {item}. You close your eyes for a moment to really savor it. Funny how a new flavor can make a day feel different.",
      fr = "Du nouveau : votre {item}. Vous fermez les yeux un instant pour mieux savourer. C'est fou comme une saveur inconnue peut changer une journée." },
  },
  firstTaste_meat = {
    { en = "You taste your {item} for the first time. The meat is rich and savory, and each bite warms you from the inside. The kind of meal that keeps you going for miles.",
      fr = "Vous goûtez votre {item} pour la première fois. La viande est riche et savoureuse, et chaque bouchée vous réchauffe de l'intérieur. De quoi tenir des lieues." },
  },
  firstTaste_fish = {
    { en = "You taste your {item} for the first time. Delicate, with a clean, light taste of clear water. You eat slowly, savoring something new.",
      fr = "Vous goûtez votre {item} pour la première fois. C'est délicat, avec un goût franc et léger d'eau claire. Vous mangez lentement, en savourant cette nouveauté." },
  },
  firstTaste_cheese = {
    { en = "You taste your {item} for the first time: a rich flavor, a melting texture, and a little sharp bite at the end. You catch yourself smiling.",
      fr = "Vous goûtez votre {item} pour la première fois : une saveur riche, une texture fondante, et une petite pointe piquante à la fin. Vous vous surprenez à sourire." },
  },
  firstTaste_bread = {
    { en = "You taste your {item} for the first time. A golden crust, a soft inside, and that comforting smell of the oven. It feels a little like home.",
      fr = "Vous goûtez votre {item} pour la première fois. Une croûte dorée, un cœur moelleux, et cette odeur réconfortante de four. Un peu comme à la maison." },
  },
  firstTaste_fungus = {
    { en = "You taste your {item} for the first time. Earthy, almost woody, with a texture you're not quite sure about. Strange... but not bad.",
      fr = "Vous goûtez votre {item} pour la première fois. Un goût de terre, presque de sous-bois, et une texture déroutante. Étrange... mais pas mauvais." },
  },
  firstTaste_fruit = {
    { en = "You taste your {item} for the first time. Fresh and sweet, it melts in your mouth. A little burst of sunshine on the road.",
      fr = "Vous goûtez votre {item} pour la première fois. Une fraîcheur sucrée qui fond dans la bouche. Un petit rayon de soleil sur la route." },
  },
  -- Something you've eaten many times (D.MEAL_FAMILIAR)
  familiarFood = {
    { en = "Your {item}, again. An old friend by now, and honestly? Nothing beats a good old classic.",
      fr = "Encore votre {item}. Une vieille connaissance, et franchement ? Rien ne vaut un bon vieux classique." },
    { en = "Your {item}, like so many times before. A familiar, comforting taste, just the way you like it.",
      fr = "Votre {item}, comme tant de fois déjà. Un goût familier, réconfortant, exactement comme vous l'aimez." },
    { en = "You don't even need to look anymore: your hands know your {item} by heart.",
      fr = "Vous n'avez même plus besoin de regarder : vos mains connaissent votre {item} par cœur." },
  },
  -- The 25th, 50th, 100th time ({count})
  foodMilestone = {
    { en = "Your {item}, for the {count}th time. At this point, it's practically a tradition.",
      fr = "Votre {item}, pour la {count}e fois. À ce stade, c'est presque une tradition." },
  },

  -- The first time you drink something
  firstSip = {
    { en = "A first sip of your {item}. You let it roll on your tongue, curious, before swallowing. One more taste to remember.",
      fr = "Une première gorgée de votre {item}. Vous la laissez rouler sur la langue, avec curiosité, avant d'avaler. Une saveur de plus à retenir." },
  },
  firstSip_Water = {
    { en = "You drink your {item} for the first time. Clear, cool water that washes the dust of the road from your throat. Simple, and perfect.",
      fr = "Vous buvez votre {item} pour la première fois. Une eau claire et fraîche, qui chasse de votre gorge la poussière de la route. Simple, et parfait." },
  },
  firstSip_Conjured = {
    { en = "Your first taste of conjured water. It tingles faintly, perfectly clear, perfectly cold... and tastes of absolutely nothing. Magic is strange.",
      fr = "Pour la première fois, vous goûtez à l'eau invoquée. Elle picote légèrement, parfaitement claire, parfaitement froide... et n'a absolument aucun goût. Étrange chose que la magie." },
  },
  firstSip_Milk = {
    { en = "You drink your {item} for the first time. Rich and creamy, it brings back the memory of a farm kitchen at dawn.",
      fr = "Vous buvez votre {item} pour la première fois. Un lait riche et onctueux, qui vous rappelle une cuisine de ferme au petit matin." },
  },
  firstSip_Juice = {
    { en = "You drink your {item} for the first time. Sweet, fruity, a little tangy. A small joy, sip after sip.",
      fr = "Vous buvez votre {item} pour la première fois. Une saveur sucrée, fruitée, un peu acidulée. Un petit bonheur, gorgée après gorgée." },
  },
  firstSip_Dew = {
    { en = "You drink your {item} for the first time. Light, with a scent of flowers and morning. It feels almost too delicate to drink.",
      fr = "Vous buvez votre {item} pour la première fois. Une saveur légère, au parfum de fleurs et de matin. Presque trop délicate pour être bue." },
  },
  familiarDrink = {
    { en = "Your {item}, again. Some things never change, and that's just fine.",
      fr = "Encore votre {item}. Certaines choses ne changent jamais, et c'est très bien comme ça." },
    { en = "Your {item}, as always. A familiar taste, like an old friend on the road.",
      fr = "Votre {item}, comme toujours. Un goût familier, comme un vieil ami sur la route." },
  },
  drinkMilestone = {
    { en = "Your {item}, for the {count}th time. At this point, it's practically a tradition.",
      fr = "Votre {item}, pour la {count}e fois. À ce stade, c'est presque une tradition." },
  },

  drink = {
    { en = "You drink in long, slow sips.", fr = "Vous buvez à longues gorgées, sans vous presser." },
    { en = "You sit down and drink slowly, taking your time.", fr = "Vous vous asseyez et buvez lentement, en prenant votre temps." },
  },
  drinkItem = {
    { en = "You sip your {item} slowly. It does you good.", fr = "Vous sirotez votre {item} lentement. Ça fait du bien." },
    { en = "You sit down and drink slowly, taking your time.", fr = "Vous vous asseyez et buvez lentement, en prenant votre temps." },
  },
  -- by kind of drink (see D.DRINK_WORDS)
  drinkWater = {
    { en = "You drink your {item} in long gulps. Nothing fancy, just good, clear water.", fr = "Vous buvez votre {item} à longues gorgées. Rien d'extraordinaire, juste une bonne eau claire." },
    { en = "Your {item} tastes of nothing at all, and that's exactly its charm.", fr = "Votre {item} n'a le goût de rien, et c'est justement ce qui fait tout son charme." },
    { en = "Water, simply. You drink slowly, and your whole body seems to thank you.", fr = "De l'eau, tout simplement. Vous buvez lentement, et tout votre corps semble vous dire merci." },
  },
  drinkConjured = {
    { en = "The conjured water tingles faintly on your tongue, as if to remind you it was made of magic.", fr = "L'eau invoquée picote légèrement sur la langue, comme pour vous rappeler qu'elle est faite de magie." },
    { en = "Conjured water: perfectly clear, perfectly cold, and maybe a little too perfect.", fr = "De l'eau invoquée : parfaitement claire, parfaitement froide, et peut-être un peu trop parfaite." },
  },
  drinkMilk = {
    { en = "The milk is rich and creamy. You end up with a little white mustache.", fr = "Le lait est riche et onctueux. Vous voilà avec une petite moustache blanche." },
    { en = "You drink your {item} slowly. It tastes like a farmhouse breakfast.", fr = "Vous buvez votre {item} lentement. Ça a le goût d'un petit-déjeuner à la ferme." },
  },
  drinkJuice = {
    { en = "Your {item} is sweet and fruity. A small treat.", fr = "Votre {item} a un goût sucré et fruité. Une petite douceur." },
  },
  drinkDew = {
    { en = "Your {item} tastes faintly of flowers and early morning.", fr = "Votre {item} a un léger goût de fleurs et de petit matin." },
  },

  -- A long fight, or one that left you below half health
  afterFight = {
    { en = "Your heart is still pounding. You take a long breath.", fr = "Votre cœur bat encore à tout rompre. Vous prenez une longue inspiration." },
    { en = "That one wasn't easy. You take a moment to catch your breath.", fr = "Ce combat n'avait rien de facile. Vous prenez un moment pour reprendre votre souffle." },
    { en = "Your hands are still shaking a little as the fury of the fight fades.", fr = "Vos mains tremblent encore un peu tandis que la fureur du combat retombe." },
    { en = "Your breathing slowly calms down. That was a tough one.", fr = "Votre respiration se calme peu à peu. C'était un rude combat." },
  },
  -- A fight that left you nearly dead
  afterFightClose = {
    { en = "That was close. Far too close.", fr = "C'était juste. Beaucoup trop juste." },
    { en = "For a moment there, you really thought it was over.", fr = "Pendant un instant, vous avez bien cru que c'était la fin." },
    { en = "You're still standing. Barely.", fr = "Vous tenez encore debout. De justesse." },
  },

  -- Said before an ambient line, when you've been standing still for a while
  quiet = {
    { en = "You stop for a moment and take it all in.", fr = "Vous vous arrêtez un instant pour tout observer." },
    { en = "You stand still for a while, and listen.", fr = "Vous restez immobile un moment, à l'écoute." },
    { en = "For a moment, you simply stay where you are.", fr = "Un instant, vous restez simplement là." },
  },

  -- Gathering
  herb = {
    { en = "Your fingers smell green and bitter, like crushed leaves.", fr = "Vos doigts sentent le vert et l'amer, comme des feuilles froissées." },
    { en = "A bit of sap clings to your fingertips.", fr = "Un peu de sève colle au bout de vos doigts." },
    { en = "You tuck your harvest away carefully.", fr = "Vous rangez soigneusement votre récolte." },
  },
  mine = {
    { en = "Stone dust clings to your hands.", fr = "De la poussière de pierre vous colle aux mains." },
    { en = "Your arms ache a little from swinging the pick.", fr = "Vos bras sont un peu endoloris d'avoir manié la pioche." },
    { en = "Little chips of rock lie scattered at your feet.", fr = "De petits éclats de roche jonchent le sol à vos pieds." },
  },
  skin = {
    { en = "You wipe your knife clean before putting it away.", fr = "Vous essuyez votre couteau avant de le ranger." },
    { en = "The smell of fresh hide clings to your hands.", fr = "L'odeur de la peau fraîche vous reste sur les mains." },
  },

  -- Travel
  -- First half of the hearthstone line: the magic. The second half describes the
  -- place you land in (SensesData.lua: "hearth" lines of spots, sub-zones, zones,
  -- and S.genericHearth).
  hearth = {
    { en = "Your head still spins a little from the hearthstone's magic.", fr = "La magie de la pierre de foyer vous fait encore un peu tourner la tête." },
    { en = "The pull of the hearthstone fades, and the world settles around you again.", fr = "L'attraction de la pierre de foyer s'estompe, et le monde se remet en place autour de vous." },
    { en = "The hearthstone's magic lets go of you, leaving a slight dizziness behind.", fr = "La magie de la pierre de foyer vous relâche, en laissant derrière elle un léger vertige." },
  },
  landing = {
    { en = "Solid ground again. It takes your legs a moment to remember it.", fr = "Enfin la terre ferme. Vos jambes mettent un moment à s'en souvenir." },
    { en = "Your legs are stiff after the long flight.", fr = "Vos jambes sont raides après ce long vol." },
    { en = "The rush of the wind still rings in your ears.", fr = "Le souffle du vent résonne encore dans vos oreilles." },
  },

  -- Time of day (outdoors only)
  dawn = {
    { en = "The first light of morning spreads over the land.", fr = "La première lumière du matin se répand sur le pays.", when = { notBiomes = NO_DARK } },
    { en = "Dawn breaks. Slowly, the world takes on its colors again.", fr = "L'aube se lève. Peu à peu, le monde retrouve ses couleurs.", when = { notBiomes = NO_DARK } },
    { en = "The sky grows paler. A new day is beginning.", fr = "Le ciel pâlit. Un nouveau jour commence.", when = { sky = true, notBiomes = NO_DARK } },
  },
  dusk = {
    { en = "The light turns golden, then slowly fades. Evening is falling.", fr = "La lumière se fait dorée, puis décline doucement. Le soir tombe.", when = { notBiomes = NO_DARK } },
    { en = "The shadows grow longer. Night is coming.", fr = "Les ombres s'allongent. La nuit approche.", when = { notBiomes = NO_DARK } },
    { en = "Darkness slowly settles over the land.", fr = "L'obscurité s'installe lentement sur le pays.", when = { notBiomes = NO_DARK } },
  },

  -- Stepping indoors and out (one shared timer)
  goIn = {
    -- calm = only when no crowd is seen around you
    { en = "The sounds of the outside fade as you step inside.", fr = "Les bruits du dehors s'estompent quand vous entrez.", when = { calm = true } },
    { en = "Inside, everything is calm and quiet.", fr = "À l'intérieur, tout est calme et paisible.", when = { calm = true } },
    { en = "You step into the bustle: voices everywhere, people coming and going.", fr = "Vous entrez dans l'agitation : des voix de partout, des allées et venues.",
      when = { crowd = { "lively", "crowded" } } },
    { en = "It's packed in here. You have to squeeze your way through.", fr = "C'est bondé ici. Il faut jouer des coudes pour avancer.", when = { crowd = "crowded" } },
    { en = "Your eyes take a moment to adjust to the dimmer light.", fr = "Vos yeux mettent un instant à s'habituer à la pénombre.",
      when = { night = false, notBiomes = NO_DARK } },
  },
  goOut = {
    { en = "You step back out into the open air.", fr = "Vous ressortez à l'air libre." },
    { en = "The open sky above you again.", fr = "Le ciel à nouveau au-dessus de vous.", when = { sky = true } },
    { en = "You squint a little in the daylight.", fr = "Vous plissez un peu les yeux à la lumière du jour.",
      when = { sky = true, night = false, notBiomes = NO_DARK } },
    { en = "The night air greets you as you step outside.", fr = "L'air de la nuit vous accueille dehors.", when = { night = true } },
  },

  -- City errands
  bank = {
    { en = "The banker greets you with a polite nod.", fr = "On vous accueille au guichet d'un signe de tête poli." },
    { en = "Behind the counter, coins clink softly as they are counted.", fr = "Derrière le comptoir, des pièces tintent doucement tandis qu'on les compte." },
  },
  mail = { -- only when you have new mail (you already know before opening: the minimap shows it)
    { draft = true,
      en = "Letters are waiting for you. You take them out one by one, curious about what they hold.",
      fr = "Du courrier vous attend. Vous sortez les lettres une à une, {curieux|curieuse|curieux·se} de ce qu'elles contiennent." },
    { draft = true,
      en = "A few letters in the box. You break the first seal with a little thrill of anticipation.",
      fr = "Quelques lettres dans la boîte. Vous brisez le premier sceau avec un petit frisson d'impatience." },
  },
  auction = {
    { en = "The auctioneer barely looks up from a long list of prices.", fr = "Au comptoir des enchères, on lève à peine les yeux d'une longue liste de prix." },
    { en = "A quill scratches busily across the auction ledger.", fr = "Une plume gratte sans relâche sur le registre des enchères." },
  },
  trainer = {
    { en = "Your trainer looks you over, as if measuring how far you've come.", fr = "Un regard attentif vous détaille, comme pour mesurer le chemin parcouru." },
    { en = "Your trainer greets you with a knowing nod.", fr = "Un signe de tête entendu vous accueille." },
  },

  -- Professions. {skill} = the profession's name, {item} = the recipe
  learnProfession = {
    { en = "{skill}: a whole new craft to learn. Your fingers are already itching to try.",
      fr = "{skill} : tout un nouveau métier à apprendre. Les doigts vous démangent déjà d'essayer." },
    { en = "A new path opens before you: {skill}. Every master started exactly here.",
      fr = "Une nouvelle voie s'ouvre à vous : {skill}. Tous les maîtres ont commencé exactement ici." },
    { en = "You leave with your head full of new words, new tools and new gestures. {skill} will take patience.",
      fr = "Vous repartez la tête pleine de nouveaux mots, de nouveaux outils et de nouveaux gestes. {skill} demandera de la patience." },
  },
  -- a higher rank of a profession you already know (journeyman, expert...)
  craftRankUp = {
    { en = "You feel your hands grow surer. {skill} is becoming second nature.",
      fr = "Vos mains se font plus sûres. {skill} devient peu à peu une seconde nature." },
    { en = "A few more secrets of {skill}, entrusted to you. There's always more to learn.",
      fr = "Quelques secrets de plus en {skill}, rien que pour vous. Il y a toujours plus à apprendre." },
  },
  -- Each profession's own lines: learn_<key> (learning it) and rank_<key> (a new
  -- rank). Keys come from the profession spells (see PROFESSION_KEYS in Moments.lua).
  -- About how YOU feel (curiosity, pride, calm...), not about the work itself.
  learn_alchemy = {
    { en = "A thrill of curiosity runs through you: so many vials, so many secrets just waiting for you.", fr = "Un frisson de curiosité vous parcourt : tant de fioles, tant de secrets qui n'attendent que vous." },
    { en = "A mix of nerves and excitement. Alchemy feels like holding a secret in your hands.", fr = "Un mélange de nervosité et d'excitation. L'alchimie, c'est comme tenir un secret entre vos mains." },
  },
  rank_alchemy = {
    { en = "A quiet pride settles in: the mixtures that once puzzled you are finally starting to make sense.", fr = "Une fierté tranquille vous gagne : les mélanges qui vous déroutaient autrefois prennent enfin tout leur sens." },
  },
  learn_blacksmithing = {
    { en = "A spark of pride lights up in you. One day, you'll wear armor forged with your own hands.", fr = "Une étincelle de fierté s'allume en vous. Un jour, vous porterez une armure forgée de vos propres mains." },
    { en = "You can almost feel the weight of the hammer in your hand already, and you can't wait.", fr = "Vous sentez déjà presque le poids du marteau dans votre main, et vous avez hâte." },
  },
  rank_blacksmithing = {
    { en = "You feel your confidence growing. The forge doesn't intimidate you anymore.", fr = "Vous sentez votre assurance grandir. La forge ne vous intimide plus." },
  },
  learn_enchanting = {
    { en = "Something stirs in you, somewhere between wonder and respect. Magic, at your fingertips.", fr = "Quelque chose s'éveille en vous, entre émerveillement et respect. La magie, au bout de vos doigts." },
    { en = "The excitement almost makes you dizzy. Suddenly, the world seems full of hidden magic.", fr = "L'excitation vous donne presque le vertige. Le monde vous semble soudain plein de magie cachée." },
  },
  rank_enchanting = {
    { en = "A deep satisfaction settles in you: the magic answers you a little more readily now.", fr = "Une profonde satisfaction vous gagne : la magie vous répond un peu plus volontiers." },
  },
  learn_engineering = {
    { en = "Your head is buzzing with ideas, and you're grinning like a child. What could possibly go wrong?", fr = "Votre tête bourdonne d'idées, et vous souriez comme un enfant. Qu'est-ce qui pourrait mal tourner ?" },
    { en = "A giddy excitement takes hold of you. Somewhere, something is about to go boom, and it will be your fault.", fr = "Une excitation fébrile s'empare de vous. Quelque part, quelque chose va bientôt faire boum, et ce sera votre faute." },
  },
  rank_engineering = {
    { en = "A small surge of pride: fewer explosions by accident, more on purpose.", fr = "Une petite bouffée de fierté : moins d'explosions par accident, plus d'explosions voulues." },
  },
  learn_herbalism = {
    { en = "A quiet joy fills you. From now on, every flower along the road feels like a small gift.", fr = "Une joie tranquille vous envahit. Désormais, chaque fleur au bord du chemin ressemble à un petit cadeau." },
    { en = "You feel a little closer to the land, as if it had just let you in on a secret.", fr = "Vous vous sentez un peu plus proche de la terre, comme si elle venait de vous confier un secret." },
  },
  rank_herbalism = {
    { en = "You feel at ease among the plants now, almost at home.", fr = "Vous vous sentez à l'aise parmi les plantes désormais, presque chez vous." },
  },
  learn_leatherworking = {
    { en = "You feel the satisfaction of a craft you can hold in your hands. Patient work, honest work.", fr = "Vous ressentez la satisfaction d'un métier qu'on tient entre ses mains. Un travail patient, un travail honnête." },
    { en = "A calm pleasure comes over you at the thought of the first piece you'll make.", fr = "Un plaisir paisible vous gagne à l'idée de la première pièce que vous fabriquerez." },
  },
  rank_leatherworking = {
    { en = "A quiet pride: your hands have learned patience.", fr = "Une fierté discrète : vos mains ont appris la patience." },
  },
  learn_mining = {
    { en = "A treasure hunter's thrill runs through you. Every mountain might be hiding something.", fr = "Un frisson de chercheur de trésors vous parcourt. Chaque montagne cache peut-être quelque chose." },
    { en = "Impatience takes hold of you. The rock is calling, and you want to answer.", fr = "L'impatience vous gagne. La roche vous appelle, et vous avez envie de répondre." },
  },
  rank_mining = {
    { en = "You feel more sure of yourself with every vein you find.", fr = "Vous gagnez en assurance à chaque filon trouvé." },
  },
  learn_skinning = {
    { en = "Not the most glamorous craft, but you feel a quiet respect: nothing will go to waste.", fr = "Pas le métier le plus glamour, mais vous ressentez un respect tranquille : rien ne sera gaspillé." },
    { en = "Your stomach turns a little at first, then settles. You'll get used to it, and you know it.", fr = "Votre estomac se serre un peu au début, puis se calme. Vous vous y ferez, et vous le savez." },
  },
  rank_skinning = {
    { en = "The knife doesn't trouble you anymore: what once felt strange now feels natural.", fr = "Le couteau ne vous trouble plus : ce qui vous semblait étrange vous paraît désormais naturel." },
  },
  learn_tailoring = {
    { en = "A little creative thrill runs through you. You're already imagining what you'll make.", fr = "Un petit frisson créatif vous parcourt. Vous imaginez déjà ce que vous allez confectionner." },
    { en = "A gentle excitement comes over you: every scrap of cloth could become something beautiful.", fr = "Une douce excitation vous gagne : chaque bout d'étoffe pourrait devenir quelque chose de beau." },
  },
  rank_tailoring = {
    { en = "You look at your own stitches with a quiet pride. They're getting really good.", fr = "Vous regardez vos propres points avec une fierté discrète. Ils deviennent vraiment beaux." },
  },
  learn_cooking = {
    { en = "A warm glow fills you at the thought of sharing a good meal by the fire.", fr = "Une douce chaleur vous gagne à l'idée de partager un bon repas au coin du feu." },
    { en = "Your mouth is already watering, and a funny kind of happiness settles in. Cooking is a kind of comfort.", fr = "Vous en salivez déjà, et un drôle de bonheur vous gagne. Cuisiner, c'est une forme de réconfort." },
  },
  rank_cooking = {
    { en = "You feel a little pride in your dishes, and a little hunger too.", fr = "Vous éprouvez une petite fierté devant vos plats, et aussi un petit creux." },
  },
  learn_firstaid = {
    { en = "A feeling of safety comes over you: knowing how to tend a wound makes the road ahead a little less frightening.", fr = "Un sentiment de sécurité vous gagne : savoir soigner une plaie rend la route un peu moins effrayante." },
    { en = "A sense of responsibility settles on your shoulders. One day, this might save someone.", fr = "Un sentiment de responsabilité se pose sur vos épaules. Un jour, ça sauvera peut-être quelqu'un." },
  },
  rank_firstaid = {
    { en = "Wounds don't shake you as much anymore. Your hands have stopped trembling.", fr = "Les blessures vous troublent moins désormais. Vos mains ne tremblent plus." },
  },
  learn_fishing = {
    { en = "A deep calm comes over you at the thought of long, quiet hours by the water.", fr = "Un grand calme vous envahit à l'idée de longues heures tranquilles au bord de l'eau." },
    { en = "You feel like a child again, eager to see what bites first.", fr = "Vous retrouvez une âme d'enfant, impatiente de voir ce qui mordra en premier." },
  },
  rank_fishing = {
    { en = "You feel more patient, more at peace. The water has taught you something.", fr = "Vous gagnez en patience et en sérénité. L'eau vous a appris quelque chose." },
  },

  learnRecipe = {
    { en = "A new recipe: {item}. You can't wait to try it.", fr = "Nouvelle recette : {item}. Vous avez hâte d'essayer." },
    { en = "You go over the steps of the recipe in your head, again and again: {item}.", fr = "Vous repassez les étapes de la recette dans votre tête, encore et encore : {item}." },
    { en = "You carefully commit it to memory: {item}.", fr = "Vous la gravez soigneusement dans votre mémoire : {item}." },
  },

  -- Looting (or receiving as a quest reward) a rare, epic or legendary item. {item} = its link
  lootRare = {
    { en = "Your heart skips a beat: {item}. Something this fine doesn't come along every day.",
      fr = "Votre cœur fait un bond : {item}. Une pièce de cette qualité, ça ne se trouve pas tous les jours." },
    { en = "You turn {item} over in your hands, almost unable to believe your luck.",
      fr = "Vous retournez {item} entre vos mains, n'en croyant presque pas votre chance." },
    { en = "{item}! A little thrill runs through you. Today is a good day.",
      fr = "{item} ! Un petit frisson vous parcourt. Aujourd'hui est un bon jour." },
  },
  lootEpic = {
    { en = "You stare at {item}, breathless. Your hands are trembling a little. This is the kind of find people tell stories about.",
      fr = "Vous fixez {item}, le souffle coupé. Vos mains tremblent un peu. C'est le genre de trouvaille dont on parle encore des années après." },
    { en = "{item}... For a long moment, you can't take your eyes off it. Nobody is going to believe you.",
      fr = "{item}... Pendant un long moment, vous ne pouvez pas en détacher les yeux. Personne ne va vous croire." },
  },
  lootLegendary = {
    { en = "{item}. Your heart pounds so hard you can hear it. Some things are bigger than you, and this is one of them.",
      fr = "{item}. Votre cœur bat si fort que vous l'entendez. Certaines choses vous dépassent, et celle-ci en fait partie." },
  },

  -- Crafting
  craftRare = {
    { en = "You step back to look at what you've made: {item}. Fine work, and you know it.",
      fr = "Vous prenez un peu de recul pour admirer votre ouvrage : {item}. Du beau travail, et vous le savez." },
    { en = "{item}, made with your own hands. A warm wave of pride washes over you.",
      fr = "{item}, de vos propres mains. Une vague de fierté vous envahit." },
  },
  craftEpic = {
    { en = "{item}. You can hardly believe it came from your own hands. All those hours were worth it.",
      fr = "{item}. Vous avez du mal à croire que c'est sorti de vos mains. Toutes ces heures en valaient la peine." },
  },
  -- the first time you ever make an item (any quality)
  craftFirst = {
    { en = "{item}, for the very first time! Maybe not perfect, but it's yours.",
      fr = "{item}, pour la toute première fois ! Ce n'est peut-être pas parfait, mais c'est de vous." },
    { en = "You look over your creation with quiet pride: {item}, a first.",
      fr = "Vous examinez votre création avec une fierté discrète : {item}, une première." },
  },

  -- Your discovery score crossed a milestone (see D.DISCOVERY_MILESTONES)
  discoveryMilestone = {
    { en = "Looking back, you realize how much ground you've covered since you set out. The world feels a little bigger, and a little more yours.",
      fr = "En y repensant, vous réalisez tout le chemin parcouru depuis vos débuts. Le monde vous semble un peu plus grand, et un peu plus à vous." },
    { en = "So many places, so many flavors, so many firsts. You smile at the thought of everything still waiting out there.",
      fr = "Tant de lieux, tant de saveurs, tant de premières fois. Vous souriez en pensant à tout ce qui vous attend encore." },
  },

  -- Back to life
  revive = {
    { en = "You gasp, alive again. Everything feels a little too bright.", fr = "Vous inspirez brusquement, de nouveau en vie. Tout paraît un peu trop lumineux." },
    { en = "Life rushes back into your limbs, cold and tingling.", fr = "La vie revient dans vos membres, froide et fourmillante." },
    { en = "You take a deep breath. You're still here.", fr = "Vous prenez une grande inspiration. Vous êtes toujours là." },
  },
  -- Back to life at the spirit healer (with resurrection sickness)
  reviveSick = {
    { en = "Everything feels heavy and slow. Coming back this way has a price.", fr = "Tout vous paraît lourd et lent. Revenir de cette façon a un prix." },
    { en = "Your limbs feel like lead, and every movement is an effort.", fr = "Vos membres pèsent comme du plomb, et chaque geste vous coûte." },
  },
}

---------------------------------------------------------------------------
-- Body (Elements) lines that depend on your gear or your shape.
-- when: cloak / boots / gloves = true (wearing one) or false (not), armor = "plate"...
--       (chest piece), form = "furry" (bear, cat, travel form, ghost wolf), still = true.
-- {cloak}, {boots}, {gloves} = links to the items you're wearing.
-- Used instead of the usual lines (Locale.lua) when they fit: some of the time in
-- your normal shape (D.BODY_GEAR_CHANCE), always in an animal form.
---------------------------------------------------------------------------
D.BODY_GEAR_CHANCE = 0.6

-- Usual Body pools whose lines describe a human body (hands, clothes...): skipped in an
-- animal form when no fur line fits.
D.BODY_PERSON_POOLS = {
  coldEnter = true, freezingEnter = true, coldRemind = true, freezingRemind = true, warmBack = true,
  hotEnter = true, hotRemind = true, soaked = true, dry = true, fireWarm = true,
}

local CLOAK_COLD = { draft = true,
  en = "You pull your {cloak} tighter around your neck. The icy wind still finds a way in.",
  fr = "Vous resserrez votre {cloak} autour de votre cou. Le vent glacé parvient quand même à s'y faufiler.",
  when = { cloak = true, indoors = false } }
local NOCLOAK_COLD = { draft = true,
  en = "You fold your arms across your chest to keep in a little warmth. A cloak would be welcome.",
  fr = "Vous croisez les bras sur votre poitrine pour garder un peu de chaleur. Une cape ne serait pas de refus.",
  when = { cloak = false, indoors = false } }
local HANDS_STILL = { draft = true,
  en = "You blow into your hands and rub them together, trying to warm them. Your fingers tingle.",
  fr = "Vous soufflez dans vos mains et les frottez l'une contre l'autre pour tenter de les réchauffer. Vos doigts picotent.",
  when = { still = true, gloves = false } }
local GLOVES_STILL = { draft = true,
  en = "You clap your hands together, muffled by your {gloves}, and stamp your feet to get the blood flowing.",
  fr = "Vous frappez vos mains l'une contre l'autre, étouffées par vos {gloves}, et tapez des pieds pour faire circuler le sang.",
  when = { still = true, gloves = true } }
local PLATE_COLD = { draft = true,
  en = "The cold seeps through your plate armor, and the icy metal bites your skin.",
  fr = "Le froid traverse votre armure de plaques, et le métal glacé vous mord la peau.",
  when = { armor = "plate" } }
local MAIL_COLD = { draft = true,
  en = "The rings of your mail are icy and bite your skin with every move.",
  fr = "Les mailles de votre armure sont glacées et vous mordent la peau à chaque mouvement.",
  when = { armor = "mail" } }
local FUR_COLD = { draft = true,
  en = "Your thick fur keeps out the worst of it, but the cold still nips at your ears.",
  fr = "Votre épaisse fourrure vous protège du pire, mais le froid finit quand même par vous mordre les oreilles.",
  when = { form = "furry" } }
local FUR_FREEZING = { draft = true,
  en = "Even through your fur, the cold pierces you. You hunch up to keep in a little warmth.",
  fr = "Même sous votre fourrure, le froid vous transperce. Vous vous ramassez sur vous-même pour garder un peu de chaleur.",
  when = { form = "furry" } }
local PLATE_HOT = { draft = true,
  en = "Under your plate, you're suffocating, and sweat runs down your back.",
  fr = "Sous vos plaques, vous étouffez, et la sueur vous coule dans le dos.",
  when = { armor = "plate" } }
local FUR_HOT = { draft = true,
  en = "Your fur is far too warm for this weather. You pant, tongue hanging out.",
  fr = "Votre fourrure est bien trop chaude pour ce temps. Vous haletez, la langue pendante.",
  when = { form = "furry" } }
local CLOAK_HOT = { draft = true,
  en = "Your {cloak} is far too warm. You dream of taking it off.",
  fr = "Votre {cloak} vous tient bien trop chaud. Vous rêvez de l'enlever.",
  when = { cloak = true } }
local FAN_STILL = { draft = true,
  en = "You fan yourself with your hand, to little effect. The scorching air doesn't stir.",
  fr = "Vous vous éventez de la main, sans grand effet. L'air brûlant ne bouge pas d'un souffle.",
  when = { still = true, shifted = false } }
local BOOTS_WET = { draft = true,
  en = "Your {boots} are soaked through, and every step makes a little squelch.",
  fr = "Vos {boots} ont pris l'eau, et chaque pas fait un petit bruit mouillé.",
  when = { boots = true } }
local NOBOOTS_WET = { draft = true,
  en = "With nothing on your feet, you feel cold water and mud at every step.",
  fr = "Sans rien aux pieds, vous sentez l'eau froide et la boue à chaque pas.",
  when = { boots = false } }
local CLOAK_WET = { draft = true,
  en = "Water has soaked into your {cloak}, which weighs on your shoulders and drips down your back.",
  fr = "L'eau a imbibé votre {cloak}, qui vous pèse sur les épaules et goutte dans votre dos.",
  when = { cloak = true } }
local FUR_WET = { draft = true,
  en = "Your soaked fur clings to your skin. You shake yourself hard, sending water flying everywhere.",
  fr = "Votre fourrure trempée vous colle à la peau. Vous vous ébrouez vigoureusement, en projetant de l'eau partout.",
  when = { form = "furry" } }
local FUR_DRY = { draft = true,
  en = "Your fur has finally dried, soft and fluffy again.",
  fr = "Votre fourrure a enfin séché, douce et gonflée à nouveau.",
  when = { form = "furry" } }
local CLOAK_FIRE = { draft = true,
  en = "You open the folds of your {cloak} to let the fire's warmth in.",
  fr = "Vous écartez les pans de votre {cloak} pour laisser entrer la chaleur du feu.",
  when = { cloak = true } }
local FUR_FIRE = { draft = true,
  en = "You draw close to the fire, and its warmth slowly seeps into your fur.",
  fr = "Vous vous approchez du feu, et sa chaleur pénètre doucement votre fourrure.",
  when = { form = "furry" } }

-- Extra versions for the middle level (25-50%: hungry, thirsty, tired).
local HUNGRY_MORE = { draft = true,
  en = "Your stomach growls loudly. It's really time to eat something.",
  fr = "Votre estomac gargouille bruyamment. Il serait vraiment temps de manger quelque chose.",
  when = { hungerBelow = 50 } }
local THIRSTY_MORE = { draft = true,
  en = "Your throat is dry and your lips are starting to crack. You need a drink, and soon.",
  fr = "Votre gorge est sèche et vos lèvres commencent à craqueler. Il vous faut boire, et vite.",
  when = { thirstBelow = 50 } }
local TIRED_MORE = { draft = true,
  en = "Your eyelids keep closing on their own, and your steps grow heavy. A real rest would do you a world of good.",
  fr = "Vos paupières se ferment toutes seules et vos pas se font lourds. Un vrai repos vous ferait le plus grand bien.",
  when = { energyBelow = 50 } }

-- The first level (50-75%): just starting to feel it ("always": these pools have no usual lines)
local PECKISH_1 = { draft = true, always = true,
  en = "A little hunger is creeping in. Nothing serious, but you could do with a snack.",
  fr = "Un petit creux se fait sentir. Rien de grave, mais vous grignoteriez bien quelque chose." }
local PECKISH_2 = { draft = true, always = true,
  en = "Your stomach gives a small, discreet gurgle. Snack time might be near.",
  fr = "Votre estomac émet un petit gargouillis discret. L'heure du goûter approche, peut-être." }
local THIRSTY_LIGHT_1 = { draft = true, always = true,
  en = "You could do with a little sip of cool water.",
  fr = "Vous boiriez bien une petite gorgée d'eau fraîche." }
local THIRSTY_LIGHT_2 = { draft = true, always = true,
  en = "Your mouth is getting a little dry.",
  fr = "Votre bouche commence à être un peu sèche." }
local TIRED_LIGHT_1 = { draft = true, always = true,
  en = "A slight tiredness settles in your legs. Nothing a break wouldn't fix.",
  fr = "Une légère fatigue se fait sentir dans vos jambes. Rien qu'une pause ne puisse arranger." }
local TIRED_LIGHT_2 = { draft = true, always = true,
  en = "You stifle a small yawn.",
  fr = "Vous étouffez un petit bâillement." }

-- Napping (/sleep): lying down, then waking up when you move (full or not quite)
D.NAP_RATE = 10        -- energy points per second while napping
D.NAP_FULL = 95        -- waking up at this much energy or more: "fully rested"
D.SIT_RATE = 0.05      -- sitting down elsewhere than an inn or a campfire...
D.SIT_ENERGY_CAP = 60  -- ...helps a little, up to this
local NAP_START = { draft = true, always = true,
  en = "You lie down and close your eyes. Just a few minutes...",
  fr = "Vous vous allongez et fermez les yeux. Juste quelques minutes…",
  when = { shifted = false } }
local NAP_START_FUR = { draft = true, always = true,
  en = "You curl up in a ball, nose tucked under your tail, and close your eyes.",
  fr = "Vous vous roulez en boule, le museau sous la queue, et fermez les yeux.",
  when = { form = "furry" } }
local NAP_FULL_1 = { draft = true, always = true,
  en = "You stretch for a long time. You wake up feeling great: that little nap did you a world of good.",
  fr = "Vous vous étirez longuement. Vous vous réveillez en pleine forme : ce petit somme vous a fait un bien fou." }
local NAP_SHORT_1 = { draft = true, always = true,
  en = "You get up with a yawn. You'd gladly have slept a little longer.",
  fr = "Vous vous relevez en bâillant. Vous auriez bien dormi encore un peu." }
local NAP_SHORT_2 = { draft = true, always = true,
  en = "You open one eye, then the other. Already? You'd have liked to stay a little longer.",
  fr = "Vous ouvrez un œil, puis l'autre. Déjà ? Vous seriez bien resté{|e|·e} encore un peu." }

D.BODY_LINES = {
  coldEnter      = { CLOAK_COLD, NOCLOAK_COLD, PLATE_COLD, MAIL_COLD, FUR_COLD },
  coldRemind     = { CLOAK_COLD, NOCLOAK_COLD, HANDS_STILL, GLOVES_STILL, PLATE_COLD, MAIL_COLD, FUR_COLD },
  freezingEnter  = { PLATE_COLD, FUR_FREEZING },
  freezingRemind = { CLOAK_COLD, HANDS_STILL, GLOVES_STILL, PLATE_COLD, FUR_FREEZING },
  hotEnter       = { PLATE_HOT, FUR_HOT },
  hotRemind      = { PLATE_HOT, FUR_HOT, CLOAK_HOT, FAN_STILL },
  overheatEnter  = { PLATE_HOT, FUR_HOT },
  overheatRemind = { PLATE_HOT, FUR_HOT, CLOAK_HOT, FAN_STILL },
  soaked         = { BOOTS_WET, NOBOOTS_WET, CLOAK_WET, FUR_WET },
  dry            = { FUR_DRY },
  fireWarm       = { CLOAK_FIRE, FUR_FIRE },
  body_hungry    = { HUNGRY_MORE },
  body_thirsty   = { THIRSTY_MORE },
  body_tired     = { TIRED_MORE },
  body_peckish   = { PECKISH_1, PECKISH_2 },
  body_thirstyLight = { THIRSTY_LIGHT_1, THIRSTY_LIGHT_2 },
  body_tiredLight = { TIRED_LIGHT_1, TIRED_LIGHT_2 },
  napStart       = { NAP_START, NAP_START_FUR },
  napWakeFull    = { NAP_FULL_1 },
  napWakeShort   = { NAP_SHORT_1, NAP_SHORT_2 },
}

---------------------------------------------------------------------------
-- Herbs: after gathering, the loot message tells us which herb it was, so the
-- line can be about that very plant. {item} = the herb (link), {gloves} = your gloves.
-- Item ID -> key of its lines (D.MOMENTS.herb_<key>); other herbs get the general line.
---------------------------------------------------------------------------
D.HERB_LOOT_WAIT = 6 -- seconds to wait for the loot message after gathering
D.HERBS = {
  [2447] = "peacebloom", [765] = "silverleaf", [2449] = "earthroot", [785] = "mageroyal",
  [2450] = "briarthorn", [2453] = "bruiseweed", [3820] = "stranglekelp",
}

D.MOMENTS.herb_peacebloom = {
  { draft = true,
    en = "You gently pick the flower. Its scent is soft, almost sweet, and a little pollen clings to your fingers.",
    fr = "Vous cueillez délicatement la fleur. Son parfum est doux, presque sucré, et un peu de pollen reste sur vos doigts." },
  { draft = true,
    en = "A simple, slender flower that grows almost everywhere. Just breathing it in makes you feel calmer. You can see why they call it that: {item}.",
    fr = "Une fleur simple et fine, qui pousse un peu partout. Rien qu'à la respirer, vous vous sentez plus calme. Vous comprenez pourquoi on l'appelle ainsi : {item}." },
  { draft = true,
    en = "A thin stem, light petals, that soft and discreet scent: no doubt about it, {item}.",
    fr = "Une tige fine, des pétales légers, ce parfum doux et discret : pas de doute, c'est bien {item}." },
}
D.MOMENTS.herb_silverleaf = {
  { draft = true,
    en = "The top of the leaf is downy, the underside smooth and silvery. No doubt about it: {item}.",
    fr = "Le dessus de la feuille est duveteux, le dessous lisse et argenté. Pas de doute : {item}." },
  {
    en = "You crush a leaf between your fingers: a fresh, slightly bitter smell escapes, like wild mint.",
    fr = "Vous froissez une feuille entre vos doigts : une odeur fraîche et un peu amère s'en échappe, comme de la menthe sauvage." },
  { draft = true,
    en = "The silvery leaves catch the light for a moment as you pick them. They smell of sage and fresh earth.",
    fr = "Les feuilles argentées accrochent un instant la lumière quand vous les cueillez. Elles sentent la sauge et la terre fraîche." },
}
D.MOMENTS.herb_earthroot = {
  { draft = true,
    en = "You pull gently on the root until it gives. It smells of damp earth and wood, and leaves a brown trace on your hands.",
    fr = "Vous tirez doucement sur la racine jusqu'à ce qu'elle cède. Elle sent la terre humide et le bois, et laisse une trace brune sur vos mains." },
  { draft = true,
    en = "The root is hard and knotted, covered in tiny filaments. You shake off the soil clinging to it before putting it away.",
    fr = "La racine est dure, noueuse, couverte de petits filaments. Vous secouez la terre qui s'y accroche avant de la ranger." },
}
D.MOMENTS.herb_mageroyal = {
  { draft = true,
    en = "A peppery smell rises from the leaves as you pick them. A faint tingle stays at your fingertips, like a trace of magic.",
    fr = "Une odeur poivrée monte des feuilles quand vous les cueillez. Un léger picotement vous reste au bout des doigts, comme une trace de magie." },
  { draft = true,
    en = "You can see why mages love it: even picked, the plant seems to quiver softly between your fingers.",
    fr = "Vous comprenez pourquoi les mages en raffolent : même cueillie, la plante semble frémir doucement entre vos doigts." },
}
D.MOMENTS.herb_briarthorn = {
  { draft = true,
    en = "Ouch! A thorn pricks your thumb. You pull it out with a wince: this one fights back.",
    fr = "Aïe ! Une épine vous pique le pouce. Vous la retirez en grimaçant : cette plante-là se défend.",
    when = { gloves = false } },
  { draft = true,
    en = "Good thing you're wearing your {gloves}: the thorns catch on them without reaching your skin.",
    fr = "Heureusement que vous portez vos {gloves} : les épines s'y accrochent sans atteindre votre peau.",
    when = { gloves = true } },
  { draft = true,
    en = "You carefully part the thorny stems. Despite the thorns, the flowers smell lovely, a sweet scent of wild rose.",
    fr = "Vous écartez les tiges épineuses avec précaution. Malgré les épines, les fleurs sentent bon, un parfum sucré de rose sauvage." },
}
D.MOMENTS.herb_bruiseweed = {
  { draft = true,
    en = "Its sap has a sharp smell that stings your nose. They say it soothes bruises, hence the name.",
    fr = "Sa sève a une odeur âcre qui vous pique le nez. On dit qu'elle soulage les douleurs, d'où son nom." },
}
D.MOMENTS.herb_stranglekelp = {
  { draft = true,
    en = "The kelp slides between your fingers, slimy and cold, and coils around your wrist as if it didn't want to let go.",
    fr = "L'algue glisse entre vos doigts, visqueuse et froide, et s'enroule autour de votre poignet comme si elle ne voulait pas vous lâcher." },
}

---------------------------------------------------------------------------
-- Falls: health lost on landing (only read out of combat).
---------------------------------------------------------------------------
D.FALL_MIN = 0.05  -- lose at least 5% of your health: a small line
D.FALL_HARD = 0.30 -- 30% or more: a hard fall

D.MOMENTS.fall = {
  { draft = true,
    en = "Ouch. Your knees will remember that jump for a long time.",
    fr = "Aïe. Vos genoux se souviendront longtemps de ce saut.",
    when = { shifted = false } },
  { draft = true,
    en = "You land heavily, and a dull pain climbs up your legs.",
    fr = "Vous atterrissez lourdement, et une douleur sourde vous remonte le long des jambes.",
    when = { shifted = false } },
  { draft = true,
    en = "You land heavily on your paws. Your pads sting for a moment.",
    fr = "Vous retombez lourdement sur vos pattes. Vos coussinets vous lancent un moment.",
    when = { form = "furry" } },
}
D.MOMENTS.fallHard = {
  { draft = true,
    en = "The fall knocks the wind out of you. For a moment the world spins, and you stay there, gathering your wits.",
    fr = "La chute vous coupe le souffle. Pendant un instant, le monde tourne autour de vous, et vous restez là, à reprendre vos esprits." },
}

---------------------------------------------------------------------------
-- Campfires, for everyone (hunters' pets have their own lines in Kindred)
---------------------------------------------------------------------------
D.MOMENTS.campSit = {
  { draft = true,
    en = "You sit down by the fire. The flames crackle, and a gentle warmth spreads through your hands.",
    fr = "Vous vous asseyez près du feu. Les flammes crépitent, et une douce chaleur vous gagne les mains.",
    when = { shifted = false } },
  { draft = true,
    en = "You hold your hands out to the flames. The smell of burning wood and the warmth on your face: a real comfort.",
    fr = "Vous tendez les mains vers les flammes. L'odeur du bois qui brûle et la chaleur sur votre visage : un vrai réconfort.",
    when = { shifted = false } },
  { draft = true,
    en = "You lie down by the fire, and its warmth slowly seeps into your fur.",
    fr = "Vous vous couchez près du feu, et sa chaleur pénètre doucement votre fourrure.",
    when = { form = "furry" } },
}
D.MOMENTS.campRested = {
  { draft = true,
    en = "You get up, limbs warmed and mind lighter. You're ready to set off again.",
    fr = "Vous vous relevez, les membres réchauffés et l'esprit plus léger. Vous voilà d'attaque pour repartir." },
  { draft = true,
    en = "The fire did you good: your muscles have loosened, and the road ahead seems shorter.",
    fr = "Le feu vous a fait du bien : vos muscles se sont dénoués, et la route vous semble moins longue." },
}

---------------------------------------------------------------------------
-- Quests: lines for specific quests, by quest ID (questAccept_<id>, questDone_<id>).
-- Each one also needs a rule in D.MOMENT_RULES.
---------------------------------------------------------------------------
D.MOMENTS.questAccept_2159 = { -- Livraison à Dolanaar (Teldrassil): leaving Shadowglen for the first time
  { draft = true,
    en = "For the first time, you're about to leave Shadowglen. The path to Dolanaar winds down through the forest, and your heart beats a little faster.",
    fr = "Pour la première fois, vous allez quitter Sombrevallon. Le chemin vers Dolanaar descend à travers la forêt, et votre cœur bat un peu plus vite." },
}

---------------------------------------------------------------------------
-- NPCs. The game doesn't tell addons an NPC's race, so we note them by hand
-- (NPC id -> race and role), from what players report. The sex comes from the game.
-- {npc} = the NPC's name.
---------------------------------------------------------------------------
D.NPC_LINE_CD = 1200 -- the same NPC gets a line at most every 20 minutes
D.NPCS = {
  [3589] = { race = "NightElf", role = "bowyer" },          -- Keina, Aldrassil: bows and arrows
  [6091] = { race = "NightElf", role = "food" },            -- Dellylah, Aldrassil: food and drink
  [3597] = { race = "NightElf", role = "trainer_druid" },   -- Mardant Strongoak, Aldrassil
  [3596] = { race = "NightElf", role = "trainer_hunter" },  -- Ayanna Everstride, Aldrassil
  [6736] = { race = "NightElf", role = "innkeeper" },       -- Keldamyr, Dolanaar
}

D.MOMENTS.npc = {
  { draft = true,
    en = "{npc} hands you your arrows with a calm smile. A smell of wax and freshly cut wood hangs around the stall.",
    fr = "{npc} vous tend vos flèches avec un sourire tranquille. Une odeur de cire et de bois fraîchement taillé flotte autour de l'étal.",
    when = { npcRace = "NightElf", npcRole = "bowyer" } },
  { draft = true,
    en = "Bows of pale wood are lined up behind {npc}, carefully polished. You can't help admiring one.",
    fr = "Des arcs de bois clair sont alignés derrière {npc}, polis avec soin. Vous ne pouvez pas vous empêcher d'en admirer un.",
    when = { npcRace = "NightElf", npcRole = "bowyer" } },
  { draft = true,
    en = "{npc} serves you with a gentle smile. A smell of bread and ripe fruit floats all around.",
    fr = "{npc} vous sert avec un sourire doux. Une odeur de pain et de fruits mûrs flotte tout autour.",
    when = { npcRace = "NightElf", npcRole = "food" } },
  { draft = true,
    en = "{npc} watches you with silvery eyes, calm as a forest without wind. You feel that nothing escapes that gaze.",
    fr = "{npc} vous observe de ses yeux argentés, calme comme une forêt sans vent. Vous avez l'impression que rien ne lui échappe.",
    when = { npcRace = "NightElf", npcRole = "trainer_druid" } },
  { draft = true,
    en = "{npc} sizes you up with a piercing look, the way one judges prey. Then, a faint smile.",
    fr = "{npc} vous jauge d'un regard perçant, comme on estime une proie. Puis, un léger sourire.",
    when = { npcRace = "NightElf", npcRole = "trainer_hunter" } },
  { draft = true,
    en = "{npc} greets you with a warm nod. Behind the counter, it smells of warm bread and polished wood.",
    fr = "{npc} vous accueille d'un signe de tête chaleureux. Derrière le comptoir, ça sent le pain chaud et le bois ciré.",
    when = { npcRace = "NightElf", npcRole = "innkeeper" } },
  { draft = true, -- any night elf NPC
    en = "{npc}'s eyes glow softly with a silvery light, like those of every night elf.",
    fr = "Les yeux de {npc} luisent doucement d'un éclat argenté, comme ceux de tous les elfes de la nuit.",
    when = { npcRace = "NightElf" } },
}

---------------------------------------------------------------------------
-- Your hunter pet in the rain (needs the Kindred module). {pet} = its name.
---------------------------------------------------------------------------
D.MOMENTS.petRain = {
  { draft = true,
    en = "{pet} shakes off vigorously and splashes you in passing. Thanks a lot.",
    fr = "{pet} s'ébroue vigoureusement et vous asperge au passage. Merci bien.",
    when = { indoors = false, sky = true, weather = "rain" } },
  { draft = true,
    en = "{pet} presses against your legs, clearly finding this rain has lasted long enough.",
    fr = "{pet} se serre contre vos jambes, l'air de trouver que cette pluie a assez duré.",
    when = { indoors = false, sky = true, weather = "rain" } },
  { draft = true,
    en = "{pet} looks up at the sky, blinking at the raindrops.",
    fr = "{pet} lève les yeux vers le ciel et cligne des paupières sous les gouttes.",
    when = { indoors = false, sky = true, weather = "rain" } },
}

---------------------------------------------------------------------------
-- Fishing: casting, waiting (instead of "you stop to look around"), the catch.
-- {item} = what you pulled out. fishFirst = the first catch of a kind of fish.
---------------------------------------------------------------------------
D.MOMENTS.fishCast = {
  { draft = true,
    en = "You cast your line. The float lands on the water with a little plop, and you wonder what's going to bite this time.",
    fr = "Vous lancez votre ligne. Le bouchon se pose sur l'eau avec un petit « plop », et vous vous demandez ce qui va bien pouvoir mordre cette fois-ci." },
  { draft = true,
    en = "You settle at the water's edge, rod firmly in hand. No hurry: here, patience is king.",
    fr = "Vous vous installez au bord de l'eau, la canne bien en main. Rien ne presse : ici, la patience est reine." },
}
D.MOMENTS.fishWait = {
  { draft = true,
    en = "The float bobs gently on the ripples. You hold your breath at every twitch.",
    fr = "Le bouchon danse doucement au gré des vaguelettes. Vous retenez votre souffle à chaque frémissement." },
  { draft = true,
    en = "The water laps softly. You watch the float, your mind finally at peace.",
    fr = "L'eau clapote doucement. Vous fixez le bouchon, l'esprit enfin tranquille." },
}
D.MOMENTS.fishCatch = {
  { draft = true,
    en = "A tug! You strike sharply, and out of the water comes {item}, thrashing.",
    fr = "Une secousse ! Vous ferrez d'un coup sec, et votre prise jaillit de l'eau en se débattant : {item}." },
  { draft = true,
    en = "The float dips all at once. You reel in your catch, still wriggling and dripping: {item}.",
    fr = "Le bouchon plonge d'un coup. Vous remontez votre prise, encore frétillante et ruisselante : {item}." },
}
D.MOMENTS.fishFirst = {
  { draft = true,
    en = "A first! You look your {item} over from every angle, its scales still dripping. You won't forget this one soon.",
    fr = "Une première ! Vous observez votre {item} sous toutes les coutures, ses écailles encore ruisselantes. Vous ne l'oublierez pas de sitôt." },
}
D.MOMENTS.fishJunk = {
  { draft = true,
    en = "You reel in your line... and there's {item}. Not quite a fish, but it's something.",
    fr = "Vous remontez votre ligne… et voilà {item}. Pas tout à fait un poisson, mais c'est toujours ça." },
}

---------------------------------------------------------------------------
-- Things that go boom (engineering): recipes and first crafts whose name has one
-- of these words get their own lines.
---------------------------------------------------------------------------
D.BOOM_WORDS = { "bomb", "bombe", "dynamite", "explos", "grenade", "poudre", "powder" }

D.MOMENTS.learnRecipe_boom = {
  { draft = true,
    en = "You go over the recipe again and again, hoping with all your heart it won't blow up before it's finished: {item}.",
    fr = "Vous repassez la recette encore et encore, en espérant de tout cœur que ça n'explosera pas avant la fin : {item}." },
  { draft = true,
    en = "A new recipe that smells of powder and singed eyebrows: {item}. What could possibly go wrong?",
    fr = "Une nouvelle recette qui sent la poudre et les sourcils roussis : {item}. Qu'est-ce qui pourrait mal tourner ?" },
}
D.MOMENTS.craftFirst_boom = {
  { draft = true,
    en = "Your very first {item}! You set it down gently. Very, very gently.",
    fr = "Votre toute première création : {item} ! Vous la posez délicatement. Très, très délicatement." },
}

---------------------------------------------------------------------------
-- More NPCs, noted in Stormwind (2026-11-11). npcID lines are for one NPC only.
---------------------------------------------------------------------------
D.NPCS[11026] = { race = "Gnome", role = "trainer_engineering" }  -- Fée Dérailleur, Dwarven District
D.NPCS[5518]  = { race = "Gnome", role = "trainer_engineering" }  -- Lilliam Sparkspindle, Dwarven District
D.NPCS[5511]  = { race = "Dwarf", role = "trainer_blacksmith" }   -- Therum Deepforge, Dwarven District
D.NPCS[5512]  = { race = "Dwarf", role = "vendor_smith" }         -- Kaita Deepforge, kind, Dwarven District
D.NPCS[957]   = { race = "Human", role = "trainer_blacksmith" }   -- Dane Lindgren, busy, straight to the point
D.NPCS[15659] = { race = "Human", role = "auctioneer" }           -- Jaxon, on a crate in the middle of the hall
D.NPCS[2455]  = { race = "Human", role = "banker" }               -- Olivia Burnside, red hair and bangs
D.NPCS[2456]  = { race = "Human", role = "banker" }               -- Newton Burnside, proud of the security
D.NPCS[2457]  = { race = "Human", role = "banker" }               -- John Burnside, balding, proud of the security
D.NPCS[6740]  = { race = "Human", role = "innkeeper" }            -- Allison, the Gilded Rose

local NPC_MORE = {
  { draft = true,
    en = "{npc} greets you with overflowing enthusiasm, fingers stained with grease. Around you, it smells of oil and powder.",
    fr = "{npc} vous accueille avec un enthousiasme débordant, les doigts tachés de cambouis. Autour de vous, ça sent l'huile et la poudre.",
    when = { npcRace = "Gnome", npcRole = "trainer_engineering" } },
  { draft = true,
    en = "{npc} talks so fast you only catch every other word, but the enthusiasm is contagious.",
    fr = "{npc} parle si vite que vous ne saisissez qu'un mot sur deux, mais l'enthousiasme est contagieux.",
    when = { npcRace = "Gnome", npcRole = "trainer_engineering" } },
  { draft = true,
    en = "{npc} greets you in a deep voice that carries over the roar of the forges. His forearms, thick as tree trunks, bear the marks of a thousand sparks.",
    fr = "{npc} vous salue d'une voix grave qui porte par-dessus le grondement des forges. Ses avant-bras, épais comme des troncs, portent les traces de mille étincelles.",
    when = { npcRace = "Dwarf", npcRole = "trainer_blacksmith", npcSex = 2 } },
  { draft = true,
    en = "{npc} welcomes you with a broad smile. She has a way of putting you at ease, as if you were already family.",
    fr = "{npc} vous accueille d'un large sourire. Elle a une façon bien à elle de vous mettre à l'aise, comme si vous faisiez déjà partie de la famille.",
    when = { npcRace = "Dwarf", npcRole = "vendor_smith", npcSex = 3 } },
  { draft = true,
    en = "{npc} barely looks up from the work. Here, you get straight to the point: no time for pleasantries.",
    fr = "{npc} lève à peine les yeux de son ouvrage. Ici, on va droit au but : pas de temps pour les politesses.",
    when = { npcID = 957 } },
  { draft = true,
    en = "Standing on a crate in the middle of the hall, {npc} calls out the bids in a ringing voice, one hand raised above the crowd.",
    fr = "Debout sur une caisse au milieu de la salle, {npc} lance les enchères d'une voix forte, une main levée au-dessus de la foule.",
    when = { npcID = 15659 } },
  { draft = true,
    en = "All around, people jostle and haggle out loud. Standing on a crate, {npc} tries to make herself heard over the din.",
    fr = "Autour de vous, ça se bouscule et ça marchande à voix haute. Debout sur une caisse, {npc} tente de couvrir le vacarme.",
    when = { npcID = 15659, crowd = { "lively", "crowded" } } },
  { draft = true,
    en = "Behind the counter, {npc} greets you with impeccable politeness. Here, everything breathes order and carefully counted coins.",
    fr = "Derrière le comptoir, {npc} vous accueille avec une politesse impeccable. Ici, tout respire l'ordre et les pièces bien comptées.",
    when = { npcRace = "Human", npcRole = "banker" } },
  { draft = true,
    en = "{npc} assures you, not without pride, that nobody has ever stolen anything from here. You'd almost believe him.",
    fr = "{npc} vous assure, non sans fierté, que personne n'a jamais rien volé ici. Vous le croiriez presque.",
    when = { npcID = { 2456, 2457 } } },
  { draft = true,
    en = "{npc} gives you a model employee's smile, a red lock falling across her forehead. She seems ready to open an account for you on the spot.",
    fr = "{npc} vous adresse un sourire d'employée modèle, une mèche rousse tombant sur son front. Elle semble prête à vous ouvrir un compte sur-le-champ.",
    when = { npcID = 2455 } },
  { draft = true,
    en = "{npc} greets you with a sincere smile, between two customers. Here, she never gets a moment's rest.",
    fr = "{npc} vous accueille d'un sourire sincère, entre deux clients. Ici, elle ne chôme jamais.",
    when = { npcRace = "Human", npcRole = "innkeeper", npcSex = 3 } },
}
for _, line in ipairs(NPC_MORE) do table.insert(D.MOMENTS.npc, line) end

D.NPCS[3613]   = { race = "NightElf", role = "armorer" }          -- Meri Ironweave, Dolanaar: mail armor, repairs
D.NPCS[265811] = { race = "NightElf", role = "campfire_teacher" } -- Lyreena Lamebrune, Teldrassil: teaches campfires

local NPC_TELDRASSIL = {
  { draft = true,
    en = "{npc} runs a hand over a coat of mail, checking each ring with care. It smells of oil and cold metal.",
    fr = "{npc} passe la main sur une cotte de mailles, en vérifiant chaque anneau avec soin. Ça sent l'huile et le métal froid.",
    when = { npcRace = "NightElf", npcRole = "armorer" } },
  { draft = true,
    en = "{npc} talks about fire like an old friend: how to feed it, how to respect it. Just listening, you can almost feel its warmth.",
    fr = "{npc} vous parle du feu comme d'un vieil ami : comment le nourrir, comment le respecter. Rien qu'à l'écouter, vous sentez déjà sa chaleur.",
    when = { npcRace = "NightElf", npcRole = "campfire_teacher" } },
}
for _, line in ipairs(NPC_TELDRASSIL) do table.insert(D.MOMENTS.npc, line) end
