-- Wayfarer's Tales - Senses lines.
--
-- RULE: a line must be true EVERYWHERE it can play. If in doubt, add a condition
-- or leave the line out. One wrong line breaks the spell.
--
-- Each line: { en = "...", fr = "...", when = { ...conditions... } }
-- Conditions (all optional):
--   night = true / false        day or night (game clock)
--   indoors = true / false
--   resting = true              in a city or an inn
--   swimming = true
--   moving = true               only while you walk / ride (e.g. "under your feet")
--   weather = "clear" / "rain" / "snow" / "sand"
--   crowd = "quiet" or { "lively", "crowded" }
--   airBelow = 5 / airAbove = 25    air temperature in °C
--   notBiomes = { volcanic = true, ... }
--   subMatch = { "inn", "auberge" }  part of the sub-zone name (lowercase)
-- French may use {masculine|feminine|neutral} forms for your character.
--
-- Layers, from general to precise: generic -> biome -> zone (map ID) -> sub-zone.
-- "arrive" lines play the first time you enter a place; "ambient" ones now and then,
-- and also when you walk into a sub-zone you already know (on a separate timer).

local _, KT = ...
local D = KT.Data

-- Weather types from C_Weather.GetCurrentWeather().type.
-- Only "clear" (0) has been seen so far. The others are guesses and stay asleep
-- until confirmed in the weather log.
-- Once a line has played, it rests for a while before it can play again (in
-- seconds). Precise lines rest longer, so a place's own lines feel special.
D.SENSES_COOLDOWN = {
  spot = 24 * 3600, subzone = 24 * 3600, zone = 24 * 3600,
  weather = 4 * 3600, biome = 4 * 3600,
  generic = 3600,
}

-- Recommended levels per zone (classic ranges). Only used if the game itself
-- doesn't give the range (C_Map.GetMapLevels), since Forever may have changed some.
D.ZONE_LEVELS = {
  -- Eastern Kingdoms
  [1429] = { 1, 10 },  [1426] = { 1, 10 },  [1420] = { 1, 10 },  [1436] = { 10, 20 }, [1432] = { 10, 20 },
  [1421] = { 10, 20 }, [1433] = { 15, 25 }, [1431] = { 18, 30 }, [1437] = { 20, 30 }, [1424] = { 20, 30 },
  [1416] = { 30, 40 }, [1417] = { 30, 40 }, [1434] = { 30, 45 }, [1418] = { 35, 45 }, [1435] = { 35, 45 },
  [1425] = { 40, 50 }, [1427] = { 43, 50 }, [1419] = { 45, 55 }, [1428] = { 50, 58 }, [1422] = { 51, 58 },
  [1423] = { 53, 60 }, [1430] = { 55, 60 },
  -- Kalimdor
  [1411] = { 1, 10 },  [1412] = { 1, 10 },  [1438] = { 1, 10 },  [1413] = { 10, 25 }, [1439] = { 10, 20 },
  [1442] = { 15, 27 }, [1440] = { 18, 30 }, [1441] = { 25, 35 }, [1443] = { 30, 40 }, [1445] = { 35, 45 },
  [1444] = { 40, 50 }, [1446] = { 40, 50 }, [1447] = { 45, 55 }, [1448] = { 48, 55 }, [1449] = { 48, 55 },
  [1450] = { 55, 60 }, [1451] = { 55, 60 }, [1452] = { 55, 60 },
}

-- Sub-zones much more dangerous than their zone (lowercase names, EN and FR).
-- Spots can also have levels = { min, max }. More precise always wins.
D.SUBZONE_LEVELS = {
  -- ["the name of the place"] = { 55, 60 },
}

-- Landscape flavour added before a danger feeling (see M.dangerFlavor_* in Locale)
D.DANGER_FLAVOR = {
  gloom = "gloom", swamp = "swamp", marsh = "swamp",
  desert = "hostile", savanna = "hostile", badlands = "hostile", canyon = "hostile", wasteland = "hostile",
  snow = "cold", mountain = "cold", volcanic = "volcanic", plague = "sick", corrupted = "sick",
  jungle = "wild", forest = "wild", hills = "wild", plains = "wild", farmland = "wild", coast = "wild",
}

D.WEATHER_TYPES = { [0] = "clear", [1] = "rain", [2] = "snow", [3] = "sand" }
D.WEATHER_CONFIRMED = { clear = true }

local OUT = { indoors = false }
local OUT_WALK = { indoors = false, moving = true } -- lines about your steps: only while you walk
-- landscapes where "fresh air" would be wrong (foul, dusty or dry air)
local NOT_FOUL_AIR = { volcanic = true, plague = true, swamp = true, undercity = true, corrupted = true,
  farmland = true, desert = true, savanna = true, badlands = true, canyon = true, wasteland = true, forge = true }

D.SENSES = {}
local S = D.SENSES

---------------------------------------------------------------------------
-- Generic: anywhere (low priority)
---------------------------------------------------------------------------
S.generic = {
  { en = "A breeze brushes past you.", fr = "Une brise vous effleure.",
    when = { indoors = false, notBiomes = { undercity = true } } },
  { en = "You take a deep breath of fresh air.", fr = "Vous prenez une grande inspiration d'air frais.",
    when = { indoors = false, notBiomes = NOT_FOUL_AIR } },
  { en = "You roll your shoulders, loosening up.", fr = "Vous faites rouler vos épaules pour vous détendre." },
  { en = "Stars glitter overhead.", fr = "Les étoiles scintillent au-dessus de vous.",
    when = { indoors = false, night = true, weather = "clear", notBiomes = { undercity = true, gloom = true } } },
  { en = "Light warms your face for a moment.", fr = "La lumière vous réchauffe un instant le visage.",
    when = { indoors = false, night = false, weather = "clear", notBiomes = { undercity = true, gloom = true } } },
  { en = "The night air is cool on your face.", fr = "L'air de la nuit est frais sur votre visage.",
    when = { indoors = false, night = true, airBelow = 20 } },
  { en = "The warm smell of stew fills the room.", fr = "Une bonne odeur de ragoût emplit la salle.",
    when = { indoors = true, resting = true, subMatch = { "inn", "auberge", "tavern", "taverne" } } },
  { en = "The fire in the hearth crackles.", fr = "Le feu crépite dans l'âtre.",
    when = { indoors = true, resting = true, subMatch = { "inn", "auberge", "tavern", "taverne" } } },
}

-- Generic arrivals: first time you walk into a kind of place (any zone)
S.genericArrive = {
  { long = true,
    en = "The warmth of the hearth wraps around you as you step in. It smells of stew, spilled ale and burning wood.",
    fr = "La chaleur de l'âtre vous enveloppe dès que vous entrez. Ça sent le ragoût, la bière renversée et le bois qui brûle.",
    when = { indoors = true, subMatch = { "inn", "auberge", "tavern", "taverne" } } },
}

-- Arriving with your hearthstone: the second half of the hearthstone line
-- (the first half, about the magic, is in MomentsData.lua). The hearthstone
-- always brings you next to your innkeeper, so the place you land in tells us
-- which inn it is: zones, sub-zones and spots can have their own "hearth" lines,
-- and these generic ones are used when there's nothing more precise.
S.genericHearth = {
  { en = "The familiar smell of the inn wraps around you: stew, spilled ale and woodsmoke. It feels good to be back.",
    fr = "L'odeur familière de l'auberge vous enveloppe : ragoût, bière renversée et feu de bois. Ça fait du bien d'être de retour.",
    when = { indoors = true, subMatch = { "inn", "auberge", "tavern", "taverne" } } },
  { en = "Familiar walls around you again. It feels a little like coming home.",
    fr = "Des murs familiers vous entourent à nouveau. Un peu comme rentrer chez soi.",
    when = { indoors = true, resting = true } },
  { en = "Familiar surroundings take shape around you. You're back, safe for a while.",
    fr = "Des lieux familiers se dessinent autour de vous. Vous voilà de retour, à l'abri pour un moment.",
    when = { indoors = false, resting = true } },
  { en = "A familiar place, at last. You can finally catch your breath.",
    fr = "Un lieu familier, enfin. Vous pouvez souffler un peu." },
}

---------------------------------------------------------------------------
-- Weather (asleep until each type is confirmed)
---------------------------------------------------------------------------
S.weather = {
  { en = "Raindrops patter on your shoulders.", fr = "Des gouttes de pluie tapotent sur vos épaules.",
    when = { indoors = false, weather = "rain" } },
  { en = "The smell of wet earth rises around you.", fr = "Une odeur de terre mouillée monte autour de vous.",
    when = { indoors = false, weather = "rain", notBiomes = { city = true, forge = true } } },
  { en = "Rain trickles down the back of your neck.", fr = "La pluie vous coule dans le cou.",
    when = { indoors = false, weather = "rain" } },
  { en = "Snowflakes settle on your sleeves.", fr = "Des flocons se posent sur vos manches.",
    when = { indoors = false, weather = "snow" } },
  { en = "Your breath fogs in the cold air.", fr = "Votre souffle forme de la buée dans l'air froid.",
    when = { indoors = false, airBelow = 3 } },
  { en = "Sand stings your eyes.", fr = "Le sable vous pique les yeux.",
    when = { indoors = false, weather = "sand" } },
  { en = "You squint against the blowing sand.", fr = "Vous plissez les yeux face au sable qui vole.",
    when = { indoors = false, weather = "sand" } },
}

-- When the weather changes (outdoors only)
S.weatherChange = {
  rainStart = { { en = "It starts to rain.", fr = "Il commence à pleuvoir." } },
  rainStop  = { { en = "The rain stops.", fr = "La pluie cesse." } },
  snowStart = { { en = "Snow begins to fall.", fr = "La neige se met à tomber." } },
  snowStop  = { { en = "The snow stops falling.", fr = "La neige cesse de tomber." } },
  sandStart = { { en = "The wind picks up and the sand begins to fly.", fr = "Le vent se lève et le sable se met à voler." } },
  sandStop  = { { en = "The sandstorm dies down.", fr = "La tempête de sable retombe." } },
}

---------------------------------------------------------------------------
-- Landscapes (biomes come from World.lua's zone table)
---------------------------------------------------------------------------
S.biomes = {
  forest = {
    arrive = {
      { en = "The air smells of leaves and damp earth.", fr = "L'air sent les feuilles et la terre humide.", when = OUT },
      { en = "Birdsong drifts down from the branches.", fr = "Des chants d'oiseaux descendent des branches.", when = { indoors = false, night = false } },
    },
    ambient = {
      { en = "Leaves rustle overhead.", fr = "Les feuilles bruissent au-dessus de vous.", when = OUT },
      { en = "A twig snaps somewhere nearby.", fr = "Une brindille craque quelque part non loin.", when = OUT },
      { en = "An owl hoots in the dark.", fr = "Une chouette hulule dans l'obscurité.", when = { indoors = false, night = true } },
      { en = "Light filters through the leaves.", fr = "La lumière filtre à travers les feuilles.", when = { indoors = false, night = false, weather = "clear" } },
      { en = "A squirrel darts up a tree trunk.", fr = "Un écureuil file le long d'un tronc.", when = { indoors = false, night = false } },
      { long = true,
        en = "Night has fallen over the forest. The air cools on your skin, and every snapping twig sounds closer than it is.",
        fr = "La nuit est tombée sur la forêt. L'air fraîchit sur votre peau, et chaque craquement de branche semble plus proche qu'il ne l'est.",
        when = { indoors = false, night = true } },
    },
  },
  plains = {
    arrive = {
      { en = "The wind sweeps freely across the open land.", fr = "Le vent balaie librement les grands espaces.", when = OUT },
    },
    ambient = {
      { en = "The grass whispers in the wind.", fr = "L'herbe murmure dans le vent.", when = OUT },
      { en = "A bird circles high above.", fr = "Un oiseau tournoie tout là-haut.", when = { indoors = false, night = false } },
      { en = "Crickets chirp in the grass.", fr = "Des grillons chantent dans l'herbe.", when = { indoors = false, night = true } },
    },
  },
  farmland = { -- Westfall: dry fields, dust, abandoned farms
    arrive = {
      { long = true,
        en = "The wind lifts a fine dust that clings to your lips. It tastes of dry earth and forgotten harvests.",
        fr = "Le vent soulève une fine poussière qui vous colle aux lèvres. Elle a un goût de terre sèche et de moisson oubliée.",
        when = { indoors = false, weather = "clear" } },
      { en = "Dust rises from the dry fields.", fr = "La poussière s'élève des champs secs.", when = { indoors = false, weather = "clear" } },
      { en = "The wind smells of dry earth and old harvests.", fr = "Le vent sent la terre sèche et les vieilles moissons.", when = OUT },
    },
    ambient = {
      { en = "Dry stalks rattle in the wind, a brittle whisper running across the fields.", fr = "Des tiges sèches craquent dans le vent, et ce murmure fragile court à travers les champs.", when = OUT },
      { en = "Dust gets in your eyes.", fr = "La poussière vous pique les yeux.", when = { indoors = false, weather = "clear" } },
      { en = "The dry fields stretch as far as the eye can see.", fr = "Les champs secs s'étendent à perte de vue.", when = OUT },
      { en = "Crickets chirp in the dry grass.", fr = "Des grillons chantent dans l'herbe sèche.", when = { indoors = false, night = true } },
      -- ideas from Kitty's walk around Westfall
      { en = "The air smells of dry fields and dusty soil.", fr = "L'air sent les champs secs et la terre poussiéreuse.", when = { indoors = false, weather = "clear" } },
      { en = "It smells of dry grass, warmed by the day.", fr = "Ça sent l'herbe sèche, chauffée par la journée.", when = { indoors = false, night = false, weather = "clear" } },
      { en = "The parched, cracked ground crunches under your feet.", fr = "Le sol sec et craquelé croustille sous vos pas.", when = { indoors = false, weather = "clear", moving = true } },
      { en = "The smell of hay drifts over from the farm.", fr = "Une odeur de foin vous arrive de la ferme.",
        when = { indoors = false, subMatch = { "farm", "ferme" } } },
      { en = "A whiff of manure reminds you this is a working farm.", fr = "Une bouffée de fumier vous rappelle qu'ici, on travaille la terre.",
        when = { indoors = false, subMatch = { "farm", "ferme" } } },
      { long = true,
        en = "The sun bakes the fields, and the air shimmers above the dry furrows. It smells of warm straw and dusty earth.",
        fr = "Le soleil chauffe les champs, et l'air tremble au-dessus des sillons secs. Ça sent la paille chaude et la terre poussiéreuse.",
        when = { indoors = false, night = false, weather = "clear" } },
    },
  },
  hills = {
    arrive = {
      { en = "The path climbs and dips over the rolling hills.", fr = "Le chemin monte et descend au gré des collines.", when = OUT },
    },
    ambient = {
      { en = "A cool wind comes down from the heights.", fr = "Un vent frais descend des hauteurs.", when = { indoors = false, airBelow = 22 } },
      { en = "The grass whispers in the wind.", fr = "L'herbe murmure dans le vent.", when = OUT },
    },
  },
  mountain = {
    arrive = {
      { en = "The air is sharper up here.", fr = "L'air est plus vif ici, en altitude.", when = OUT },
    },
    ambient = {
      { en = "Pebbles skitter down the slope.", fr = "Des cailloux dévalent la pente.", when = OUT },
      { en = "The wind howls between the peaks.", fr = "Le vent hurle entre les sommets.", when = OUT },
    },
  },
  snow = {
    arrive = {
      { long = true,
        en = "The cold grabs you from the very first steps. Snow crunches under your feet, and your breath drifts away in little white clouds.",
        fr = "Le froid vous saisit dès les premiers pas. La neige crisse sous vos pieds, et votre souffle s'envole en petits nuages blancs.",
        when = OUT },
      { en = "The cold bites the moment you arrive.", fr = "Le froid vous saisit dès votre arrivée.", when = OUT },
      { en = "Everything is hushed under the snow.", fr = "Tout est feutré sous la neige.", when = OUT },
    },
    ambient = {
      { en = "Snow crunches under your feet.", fr = "La neige crisse sous vos pas.", when = OUT_WALK },
      { en = "A gust lifts a veil of powdery snow.", fr = "Une rafale soulève un voile de neige poudreuse.", when = OUT },
      { en = "Your fingers ache with the cold.", fr = "Vos doigts vous font mal à cause du froid.", when = { indoors = false, airBelow = 0 } },
    },
  },
  desert = {
    arrive = {
      { long = true,
        en = "The heat crushes you the moment you arrive. The burning sand slides under your feet, and the dry air catches in your throat.",
        fr = "La chaleur vous écrase dès votre arrivée. Le sable brûlant glisse sous vos pas, et l'air sec vous accroche la gorge.",
        when = { indoors = false, night = false } },
      { en = "Heat rises off the sand in waves.", fr = "La chaleur monte du sable en vagues.", when = { indoors = false, night = false } },
      { en = "The dry air catches in your throat.", fr = "L'air sec vous accroche la gorge.", when = OUT },
    },
    ambient = {
      { en = "Sand gets everywhere. Absolutely everywhere.", fr = "Le sable s'infiltre partout. Vraiment partout.", when = OUT },
      { en = "The sand shifts beneath your feet.", fr = "Le sable glisse sous vos pas.", when = OUT_WALK },
    },
  },
  savanna = {
    arrive = {
      { en = "Dry grass crackles underfoot.", fr = "L'herbe sèche craque sous vos pas.", when = OUT_WALK },
      { en = "The plains stretch out, golden and endless.", fr = "Les plaines s'étendent, dorées et sans fin.", when = { indoors = false, night = false } },
    },
    ambient = {
      { en = "A dusty wind blows across the plains.", fr = "Un vent poussiéreux balaie les plaines.", when = OUT },
      { en = "Somewhere far away, an animal calls.", fr = "Quelque part, très loin, un animal pousse un cri.", when = OUT },
    },
  },
  badlands = {
    arrive = {
      { en = "Red dust clings to everything.", fr = "Une poussière rouge colle à tout.", when = OUT },
    },
    ambient = {
      { en = "The rocks give off the heat of the day.", fr = "Les rochers renvoient la chaleur du jour.", when = { indoors = false, night = false } },
      { en = "Dust devils spin in the distance.", fr = "Des tourbillons de poussière dansent au loin.", when = OUT },
    },
  },
  canyon = {
    arrive = {
      { en = "Red dust clings to everything.", fr = "Une poussière rouge colle à tout.", when = OUT },
    },
    ambient = {
      { en = "The rocks give off the heat of the day.", fr = "Les rochers renvoient la chaleur du jour.", when = { indoors = false, night = false } },
    },
  },
  jungle = {
    arrive = {
      { en = "The air is thick and humid.", fr = "L'air est épais et humide.", when = OUT },
      { en = "A riot of green surrounds you.", fr = "Une explosion de verdure vous entoure.", when = OUT },
    },
    ambient = {
      { en = "Insects buzz relentlessly.", fr = "Les insectes bourdonnent sans relâche.", when = OUT },
      { en = "Something rustles in the undergrowth.", fr = "Quelque chose remue dans les sous-bois.", when = OUT },
      { en = "Sweat sticks your clothes to your skin.", fr = "La sueur colle vos vêtements à votre peau.", when = { indoors = false, airAbove = 24 } },
    },
  },
  swamp = {
    arrive = {
      { en = "The smell of rot and stagnant water hits you.", fr = "Une odeur de pourriture et d'eau stagnante vous saisit.", when = OUT },
    },
    ambient = {
      { en = "Frogs croak somewhere in the reeds.", fr = "Des grenouilles coassent quelque part dans les roseaux.", when = OUT },
      { en = "Mosquitoes whine around your ears.", fr = "Des moustiques vous tournent autour des oreilles.", when = { indoors = false, airAbove = 15 } },
    },
  },
  marsh = {
    arrive = {
      { en = "The ground squelches beneath your feet.", fr = "Le sol spongieux gargouille sous vos pas.", when = OUT_WALK },
    },
    ambient = {
      { en = "Frogs croak somewhere in the reeds.", fr = "Des grenouilles coassent quelque part dans les roseaux.", when = OUT },
    },
  },
  coast = {
    arrive = {
      { en = "The sea air tastes of salt.", fr = "L'air marin a un goût de sel.", when = OUT },
    },
    ambient = {
      { en = "The cry of a gull drifts in from the sea.", fr = "Le cri d'une mouette arrive de la mer.", when = { indoors = false, night = false } },
    },
  },
  gloom = {
    arrive = {
      { long = true,
        en = "The trees seem to close in over the road, and the light fades little by little. A shiver runs through you that has nothing to do with the cold.",
        fr = "Les arbres semblent se refermer au-dessus du chemin, et la lumière s'éteint peu à peu. Un frisson vous parcourt, qui n'a rien à voir avec le froid.",
        when = OUT },
      { en = "A chill that has nothing to do with the weather creeps over you.", fr = "Un frisson qui n'a rien à voir avec le temps vous parcourt.", when = OUT },
      { en = "The light feels dimmer here.", fr = "La lumière semble plus faible ici.", when = OUT },
    },
    ambient = {
      { en = "A crow caws somewhere in the dark branches.", fr = "Un corbeau croasse quelque part dans les branches sombres.", when = OUT },
      { en = "You could swear something is watching you.", fr = "Vous jureriez que quelque chose vous observe.", when = OUT },
      { en = "The silence here is heavy.", fr = "Le silence est pesant ici.", when = { indoors = false, crowd = "quiet" } },
    },
  },
  plague = {
    arrive = {
      { en = "The air carries a faint, sickly smell.", fr = "L'air porte une légère odeur maladive.", when = OUT },
    },
    ambient = {
      { en = "The grass here grows grey and brittle.", fr = "L'herbe pousse grise et cassante ici.", when = OUT },
      { en = "You catch yourself breathing through your mouth.", fr = "Vous vous surprenez à respirer par la bouche.", when = OUT },
    },
  },
  wasteland = {
    arrive = {
      { en = "Not much grows here.", fr = "Pas grand-chose ne pousse ici.", when = OUT },
    },
    ambient = {
      { en = "A dry wind scatters grit across the ground.", fr = "Un vent sec éparpille du gravier sur le sol.", when = OUT },
    },
  },
  volcanic = {
    arrive = {
      { en = "The air smells of sulphur and ash.", fr = "L'air sent le soufre et la cendre.", when = OUT },
    },
    ambient = {
      { en = "Ash drifts down like grey snow.", fr = "La cendre retombe comme une neige grise.", when = OUT },
      { en = "The ground is warm beneath your feet.", fr = "Le sol est chaud sous vos pieds.", when = OUT },
    },
  },
  corrupted = {
    arrive = {
      { en = "Something is deeply wrong with this forest.", fr = "Quelque chose ne tourne vraiment pas rond dans cette forêt.", when = OUT },
    },
    ambient = {
      { en = "The trees here look sick and twisted.", fr = "Les arbres ici semblent malades et tordus.", when = OUT },
    },
  },
  city = {
    ambient = {
      { en = "The city never really sleeps.", fr = "La ville ne dort jamais vraiment.", when = { indoors = false, night = true } },
      { en = "Voices and footsteps fill the air.", fr = "Des voix et des bruits de pas emplissent l'air.", when = { crowd = { "lively", "crowded" } } },
      { en = "The streets are strangely calm.", fr = "Les rues sont étrangement calmes.", when = { indoors = false, crowd = "quiet" } },
    },
  },
  forge = {
    arrive = {
      { en = "Warm air and the smell of hot metal greet you.", fr = "Un air chaud et une odeur de métal chaud vous accueillent." },
    },
    ambient = {
      { en = "The air tastes of soot.", fr = "L'air a un goût de suie." },
      { en = "Somewhere, a hammer rings on an anvil.", fr = "Quelque part, un marteau résonne sur une enclume." },
    },
  },
  undercity = {
    arrive = {
      { en = "The air down here is damp and stale.", fr = "L'air ici est humide et confiné." },
    },
    ambient = {
      { en = "Water drips somewhere in the dark.", fr = "De l'eau goutte quelque part dans l'obscurité." },
    },
  },
}

---------------------------------------------------------------------------
-- Zones (map ID)
---------------------------------------------------------------------------
S.zones = {
  [1412] = { -- Mulgore: rolling grassland
    arrive = {
      { en = "Tall grass ripples around you.", fr = "Les hautes herbes ondulent autour de vous.", when = OUT },
    },
  },
  [1417] = { -- Arathi Highlands: open grassy highlands
    arrive = {
      { en = "Tall grass ripples around you.", fr = "Les hautes herbes ondulent autour de vous.", when = OUT },
    },
  },
  [1429] = { -- Elwynn Forest
    arrive = {
      { en = "Elwynn's gentle hills roll away under the trees.", fr = "Les douces collines d'Elwynn s'étendent sous les arbres.", when = OUT },
      { long = true,
        en = "Light filters through the oaks, scattering warm patches across the path. It smells of moss and damp bark.",
        fr = "La lumière filtre entre les chênes et dessine des taches tièdes sur le chemin. Ça sent la mousse et l'écorce humide.",
        when = { indoors = false, night = false, weather = "clear" } },
      { long = true,
        en = "Night wraps Elwynn Forest. The air cools on your skin, and crickets sing between the trees.",
        fr = "La nuit enveloppe la forêt d'Elwynn. L'air fraîchit sur votre peau, et le chant des grillons monte entre les arbres.",
        when = { indoors = false, night = true } },
    },
    ambient = {
      { en = "The forest feels peaceful here.", fr = "La forêt semble paisible ici.", when = OUT },
    },
  },
  [1453] = { -- Stormwind
    arrive = {
      { en = "The white stone of Stormwind gleams around you.", fr = "La pierre blanche de Hurlevent luit autour de vous.", when = { indoors = false, night = false, weather = "clear" } },
      { long = true,
        en = "The white stone of Stormwind gleams in the light, and your footsteps echo between the walls. The paving stones are warm underfoot.",
        fr = "La pierre blanche de Hurlevent luit dans la lumière, et vos pas résonnent entre les murs. Les pavés sont tièdes sous vos pieds.",
        when = { indoors = false, night = false, weather = "clear" } },
    },
    ambient = {
      { en = "A guard's armor clinks as a patrol passes.", fr = "Une armure cliquette au passage d'une patrouille.", when = OUT },
    },
    hearth = { -- any Stormwind inn, depending on how busy it is
      { en = "Back in the heart of Stormwind. The inn is packed, as always: voices everywhere, people coming and going, and barely room to squeeze through.",
        fr = "De retour au cœur de Hurlevent. L'auberge est bondée, comme toujours : des voix de partout, des allées et venues, et à peine de quoi se faufiler.",
        when = { indoors = true, crowd = "crowded" } },
      { en = "So much for peace and quiet: the inn is full of voices and comings and goings. Stormwind never really sleeps.",
        fr = "Pour le calme, c'est raté : l'auberge déborde de voix et d'allées et venues. Hurlevent ne dort jamais vraiment.",
        when = { indoors = true, crowd = { "lively", "crowded" } } },
      { en = "For once, Stormwind's inn is almost quiet. You savor the calm while it lasts.",
        fr = "Pour une fois, l'auberge de Hurlevent est presque calme. Vous savourez la tranquillité tant qu'elle dure.",
        when = { indoors = true, crowd = "quiet" } },
    },
  },
}

---------------------------------------------------------------------------
-- Spots: a precise place INSIDE a zone, found by map coordinates (the numbers
-- under the minimap, in %). map = zone map ID, x/y = centre, r = radius.
-- "when" adds conditions for the whole spot (e.g. resting = only in the inn's rest area).
-- The most precise level of all.
---------------------------------------------------------------------------
S.spots = {
  { id = "wf_sentinel_inn", map = 1436, x = 52.5, y = 53.1, r = 1.5, when = { resting = true },
    names = { en = "Sentinel Hill inn", fr = "l'auberge de la Colline des sentinelles" },
    arrive = {
      { long = true,
        en = "The inn is little more than a battered barn. Through the gaping roof you can see the sky, and the wind carries in a smell of dust and old straw.",
        fr = "L'auberge n'est guère plus qu'une grange malmenée. Par le toit éventré, on aperçoit le ciel, et le vent apporte une odeur de poussière et de vieille paille." },
    },
    hearth = {
      { en = "Back in the old barn. The wind whistles through the broken roof, and it smells of dust and old straw. Not the coziest of inns, but it will do.",
        fr = "De retour dans la vieille grange. Le vent siffle à travers le toit éventré, et ça sent la poussière et la vieille paille. Pas l'auberge la plus douillette, mais elle fera l'affaire." },
    },
    ambient = {
      { en = "The wind whistles through the holes in the roof.", fr = "Le vent siffle à travers les trous du toit." },
      { en = "Loose planks creak overhead.", fr = "Des planches mal fixées grincent au-dessus de vous." },
      { en = "The candles flicker in the draught.", fr = "Les bougies vacillent dans les courants d'air." },
      { en = "Through the broken roof, a few stars are showing.", fr = "Par le toit éventré, on aperçoit quelques étoiles.",
        when = { night = true, weather = "clear" } },
      { en = "Here, people make do with what little they have.", fr = "Ici, on fait avec le peu qu'on a." },
    } },
}

---------------------------------------------------------------------------
-- Sub-zones (matched by name, English and French)
---------------------------------------------------------------------------
S.subzones = {
  { id = "sw_trade", names = { "trade district", "quartier commerçant", "the gilded rose", "la rose dorée" },
    ambient = {
      { en = "Merchants' signs creak in the breeze.", fr = "Les enseignes des marchands grincent dans la brise.", when = OUT },
    },
    hearth = { -- the Gilded Rose, next to the bank and the auction house: always busy
      { en = "Back at the Gilded Rose, packed as always: voices everywhere, people coming and going, and barely room to squeeze through.",
        fr = "De retour à la Rose dorée, bondée comme toujours : des voix de partout, des allées et venues, et à peine de quoi se faufiler.",
        when = { indoors = true, crowd = "crowded" } },
      { en = "The Gilded Rose is buzzing, as usual. With the bank and the auction house right next door, half of Stormwind seems to pass through here.",
        fr = "La Rose dorée bourdonne d'activité, comme d'habitude. Avec la banque et l'hôtel des ventes juste à côté, la moitié de Hurlevent semble passer par ici.",
        when = { indoors = true, crowd = { "lively", "crowded" } } },
      { en = "For once, the Gilded Rose is almost quiet. Enjoy the calm: it never lasts long here.",
        fr = "Pour une fois, la Rose dorée est presque calme. Profitez-en : ici, ça ne dure jamais longtemps.",
        when = { indoors = true, crowd = "quiet" } },
      { en = "Back at the Gilded Rose, right in the bustle of the Trade District.",
        fr = "De retour à la Rose dorée, en plein cœur de l'animation du Quartier commerçant.",
        when = { indoors = true } },
    } },
  { id = "sw_canals", names = { "the canals", "les canaux" },
    arrive = {
      { long = true,
        en = "The canal water laps gently against the stone. A smell of damp and wet stone rises to meet you.",
        fr = "L'eau des canaux clapote doucement contre la pierre. Une odeur d'humidité et de pierre mouillée monte jusqu'à vous.",
        when = OUT },
    },
    ambient = {
      { en = "Water laps against the stone of the canals.", fr = "L'eau clapote contre la pierre des canaux.", when = OUT },
    } },
  { id = "sw_mage", names = { "mage quarter", "quartier des mages" },
    arrive = {
      { long = true,
        en = "The air of the Mage Quarter tingles on your skin, heavy with magic, and violet light glows in the tower windows.",
        fr = "L'air du Quartier des Mages picote sur votre peau, chargé de magie, et une lueur violette brille aux fenêtres des tours.",
        when = OUT },
    },
    ambient = {
      { en = "The air tingles faintly with magic.", fr = "L'air picote légèrement de magie." },
    } },
  { id = "sw_cathedral", names = { "cathedral square", "place de la cathédrale" },
    ambient = {
      { en = "The great cathedral towers over the square.", fr = "La grande cathédrale domine la place.", when = OUT },
    } },
  { id = "wf_pumpkins", names = { "furlbrow's pumpkin farm", "ferme de potirons de froncebouille" }, -- Westfall
    arrive = {
      { long = true,
        en = "Rows of pumpkins stretch out across the dry soil, fat and orange. A smell of machine oil drifts between them: the mechanical harvesters are never far.",
        fr = "Des rangées de potirons s'étendent dans la terre sèche, gros et orange. Une odeur d'huile de machine flotte entre eux : les moissonneurs mécaniques ne sont jamais loin.",
        when = OUT },
    },
    ambient = {
      { en = "Fat orange pumpkins lie scattered between the rows.", fr = "De gros potirons orange sont éparpillés entre les rangs.", when = OUT },
      { en = "A sweetish smell of overripe pumpkin hangs over the field.", fr = "Une odeur douceâtre de potiron trop mûr flotte sur le champ.", when = OUT },
      { en = "A smell of machine oil and hot metal hangs in the air.", fr = "Une odeur d'huile de machine et de métal chaud flotte dans l'air.", when = OUT },
      { en = "Somewhere in the field, gears creak and grind.", fr = "Quelque part dans le champ, des engrenages grincent.", when = OUT },
    } },
  { id = "goldshire", names = { "goldshire", "comté-de-l'or", "lion's pride inn", "auberge de la fierté du lion" },
    hearth = {
      { en = "The warmth of the Lion's Pride Inn closes around you again, with its smell of stew and woodsmoke. Your stomach is already growling.",
        fr = "La chaleur de l'auberge de Comté-de-l'Or se referme à nouveau sur vous, avec son odeur de ragoût et de feu de bois. Votre estomac gargouille déjà.",
        when = { indoors = true } },
    },
    arrive = {
      { long = true,
        en = "The roofs of Goldshire appear between the trees. The smell of the inn's kitchen drifts across the road, and your stomach answers.",
        fr = "Les toits de Comté-de-l'Or apparaissent entre les arbres. L'odeur des cuisines de l'auberge flotte jusqu'au chemin, et votre estomac répond.",
        when = OUT },
    },
    ambient = {
      { en = "The smell of the inn's kitchen drifts across the road.", fr = "L'odeur des cuisines de l'auberge flotte jusqu'au chemin.", when = OUT },
    } },
  { id = "darkshire", names = { "darkshire", "sombre-comté", "scarlet raven tavern" }, -- Duskwood
    hearth = {
      { en = "Darkshire's inn is dim and hushed, and outside, the night never ends. You're in no real hurry to step back out there.",
        fr = "L'auberge de Sombre-Comté est sombre et feutrée, et dehors, la nuit ne finit jamais. Vous n'avez pas vraiment hâte de ressortir.",
        when = { indoors = true } },
      { en = "The dim inn of Darkshire, at last. Out there, the endless night is waiting... You'd gladly linger here a little longer.",
        fr = "La pénombre de l'auberge de Sombre-Comté, enfin. Dehors, la nuit sans fin vous attend... Vous aimeriez bien pouvoir vous éterniser un peu.",
        when = { indoors = true } },
    } },
  { id = "if_forge", names = { "the great forge", "la grande forge" },
    arrive = {
      { en = "The heat of the Great Forge washes over you.", fr = "La chaleur de la Grande Forge vous enveloppe." },
    },
    ambient = {
      { en = "Molten metal glows in the great channels.", fr = "Le métal en fusion rougeoie dans les grandes rigoles." },
      { en = "The heat of the Great Forge washes over you.", fr = "La chaleur de la Grande Forge vous enveloppe." },
    } },
}
