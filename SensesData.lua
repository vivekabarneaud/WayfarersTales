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

-- Places the game counts as "outdoors" but with a roof over your head: lines that
-- need the open sky (sky = true) skip them. map = map ID (raw, as for spots), x/y in %.
-- Players can add their own with /wt toit; send them in the report to add them here.
-- Whole zones where you never see the sky (canopy everywhere), by zone map ID
D.NO_SKY_ZONES = {
  [1438] = true, -- Teldrassil: the canopy covers everything
}

D.ROOFED = {
  { map = 1438, x = 59.8, y = 41.7, r = 3, name = "Aldrassil (Teldrassil)" },
}

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
    when = { indoors = false, notBiomes = { undercity = true } },
    rewrite = { en = "A light breeze brushes your face and, for a moment, carries away the weariness of the road.",
                fr = "Une brise légère vous effleure le visage et emporte un instant la fatigue de la route." } },
  { en = "You take a deep breath of fresh air.", fr = "Vous prenez une grande inspiration d'air frais.",
    when = { indoors = false, notBiomes = NOT_FOUL_AIR } },
  { en = "You roll your shoulders, loosening up.", fr = "Vous faites rouler vos épaules pour vous détendre." },
  { en = "Stars glitter overhead.", fr = "Les étoiles scintillent au-dessus de vous.",
    when = { indoors = false, sky = true, night = true, weather = "clear", notBiomes = { undercity = true, gloom = true } } },
  { en = "Light warms your face for a moment.", fr = "La lumière vous réchauffe un instant le visage.",
    when = { indoors = false, sky = true, night = false, weather = "clear", notBiomes = { undercity = true, gloom = true } } },
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
    when = { indoors = true, subMatch = { "inn", "auberge", "tavern", "taverne" } },
    rewrite = { en = "The inn welcomes you with its familiar smells: warm bread, candle wax and polished wood. Your shoulders relax on their own.",
                fr = "L'auberge vous accueille avec ses odeurs familières : pain chaud, cire de bougie et bois ciré. Vos épaules se détendent toutes seules." } },
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
    when = { indoors = false, sky = true, weather = "rain" } },
  { en = "The smell of wet earth rises around you.", fr = "Une odeur de terre mouillée monte autour de vous.",
    when = { indoors = false, weather = "rain", notBiomes = { city = true, forge = true } } },
  { en = "Rain trickles down the back of your neck.", fr = "La pluie vous coule dans le cou.",
    when = { indoors = false, sky = true, weather = "rain" } },
  { en = "Snowflakes settle on your sleeves.", fr = "Des flocons se posent sur vos manches.",
    when = { indoors = false, sky = true, weather = "snow" } },
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
      { en = "A twig snaps somewhere nearby.", fr = "Une brindille craque quelque part non loin.", when = OUT,
        rewrite = { en = "A twig snaps nearby. And yet, there's no one in sight.",
                    fr = "Une brindille craque non loin. Il n'y a personne en vue, pourtant.",
                    when = { indoors = false, alone = true } } },
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
    ambient = {
      { draft = true, -- for tauren: home
        en = "Mulgore's wind carries the smell of tall grass and kodos. Here, the Earth Mother is everywhere, and you feel at peace.",
        fr = "Le vent de Mulgore porte l'odeur des hautes herbes et des kodos. Ici, la Terre-Mère est partout, et vous vous sentez en paix.",
        when = { indoors = false, race = "Tauren" } },
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
      { en = "The forest feels peaceful here.", fr = "La forêt semble paisible ici.", when = OUT,
        rewrite = { en = "Elwynn Forest breathes calm: the smell of warm grass and leaves, light playing between the oaks. You'd almost forget about the wolves.",
                    fr = "La forêt d'Elwynn respire le calme : une odeur d'herbe tiède et de feuilles, la lumière qui joue entre les chênes. On en oublierait presque les loups.",
                    when = { indoors = false, night = false } } },
      { draft = true,
        en = "They say bandits in red masks roam right up to Stormwind's gates. Without thinking, you tighten your grip on your purse.",
        fr = "On raconte que des bandits au foulard rouge rôdent jusqu'aux portes de Hurlevent. Sans y penser, vous resserrez la main sur votre bourse.",
        when = OUT },
      { draft = true,
        en = "At night, Elwynn changes face. The shadows stretch between the oaks, and you walk a little faster than usual.",
        fr = "La nuit, la forêt d'Elwynn change de visage. Les ombres s'allongent entre les chênes, et vous marchez un peu plus vite que d'habitude.",
        when = { indoors = false, night = true, moving = true } },
      { draft = true, -- for humans: home
        en = "Elwynn feels a little like home: its oaks, its gentle hills, its quiet farms. Here, you feel you belong.",
        fr = "Elwynn, c'est un peu chez vous : ses chênes, ses collines douces, ses fermes tranquilles. Ici, vous vous sentez à votre place.",
        when = { indoors = false, race = "Human" } },
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
      { en = "Behind Stormwind's high walls, you feel safe, for a while.", fr = "Derrière les hautes murailles de Hurlevent, vous vous sentez en sécurité, pour un temps.", when = OUT },
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

  -- Batch 1 of zone lines: drafts waiting for approval (draft = true never plays).
  -- check = a French name to confirm.
  [1438] = { -- Teldrassil
    arrive = {
      { draft = true, long = true,
        en = "You are walking on the World Tree itself. Beneath your feet lie not hills but colossal roots and branches, and the thought makes you a little dizzy.",
        fr = "Vous marchez sur l'Arbre-Monde lui-même. Sous vos pieds, ce ne sont pas des collines mais des racines et des branches géantes, et cette idée vous donne un léger vertige.",
        when = OUT },
    },
    ambient = {
      { draft = true,
        en = "Violet light filters through the immense canopy. Everything is bathed in a soft, slightly unreal twilight, and time seems to slow down.",
        fr = "Une lumière violette filtre à travers l'immense feuillage. Tout baigne dans un crépuscule doux et un peu irréel, et le temps semble ralentir.",
        when = OUT },
      { draft = true,
        en = "The air smells of moss, damp bark and a hint of wildflowers. Here, even the silence feels alive.",
        fr = "L'air sent la mousse, l'écorce humide et une pointe de fleurs sauvages. Ici, même le silence semble vivant.",
        when = { indoors = false, calm = true } },
      { draft = true,
        en = "It is whispered that the Tree never received the blessing of the great dragons. Listening to the wind in its branches, you understand why the elves speak of it with such worry.",
        fr = "On murmure que l'Arbre n'a jamais reçu la bénédiction des grands dragons. En écoutant le vent dans ses branches, vous comprenez pourquoi les elfes en parlent avec tant d'inquiétude.",
        when = { indoors = false, notRace = "NightElf" } },
      { draft = true,
        en = "Night falls over Teldrassil without really changing its violet light. The leaves murmur softly, and you feel tiny, but safe.",
        fr = "La nuit tombe sur Teldrassil sans vraiment changer sa lumière violette. Le feuillage murmure doucement, et vous vous sentez minuscule, mais en sécurité.",
        when = { indoors = false, night = true } },
      { draft = true, -- for night elves: this is home
        en = "You know the Tree never received the blessing of the great dragons. Listening to the wind in its branches, your heart tightens: this is your home, and the thought that it could one day be corrupted is unbearable.",
        fr = "Vous savez que l'Arbre n'a jamais reçu la bénédiction des grands dragons. En écoutant le vent dans ses branches, votre cœur se serre : c'est votre foyer, et l'idée qu'il puisse un jour se corrompre vous est insupportable.",
        when = { indoors = false, race = "NightElf" } },
    },
  },
  [1457] = { -- Darnassus
    arrive = {
      { draft = true, long = true,
        en = "Darnassus opens before you, peaceful and hushed. The pools mirror the trees and the pale stone temples, and the air smells of flowers and clear water. Without realizing it, you lower your voice.",
        fr = "Darnassus s'ouvre devant vous, paisible et feutrée. Les bassins reflètent les arbres et les temples de pierre pâle, et l'air sent les fleurs et l'eau claire. Sans vous en rendre compte, vous baissez la voix.",
        when = OUT },
    },
    ambient = {
      { draft = true,
        en = "The lapping of water follows each of your steps. Everything here invites you to slow down.",
        fr = "Le clapotis de l'eau accompagne chacun de vos pas. Tout ici invite à ralentir.",
        when = { indoors = false, moving = true } },
      { draft = true, check = "Temple de la Lune",
        en = "They say the priestesses of Elune pray day and night in the Temple of the Moon. Here, the goddess never seems very far away.",
        fr = "On dit que les prêtresses d'Élune prient jour et nuit au Temple de la Lune. Ici, la déesse ne semble jamais très loin.",
        when = { indoors = false, notRace = "NightElf" } },
      { draft = true,
        en = "A mild breeze ripples the water of the pools. The calm is so deep you can hear your own breathing.",
        fr = "Une brise tiède fait onduler l'eau des bassins. Le calme est si profond que vous entendez votre propre souffle.",
        when = { indoors = false, calm = true } },
      { draft = true, check = "Temple de la Lune", -- for night elves
        en = "Passing near the Temple of the Moon, you whisper a short prayer to Elune, out of habit, and out of love. Here, the goddess watches over your people.",
        fr = "En passant près du Temple de la Lune, vous murmurez une courte prière à Élune, par habitude, et par amour. Ici, la déesse veille sur les vôtres.",
        when = { indoors = false, race = "NightElf" } },
    },
  },
  [1439] = { -- Darkshore
    arrive = {
      { draft = true, long = true,
        en = "A grey mist clings to the dark coast. The sea wind carries a smell of salt and seaweed, and something melancholy hangs over the whole shore.",
        fr = "Une brume grise s'accroche à la côte sombre. Le vent du large apporte une odeur de sel et d'algues, et quelque chose de mélancolique flotte sur tout le rivage.",
        when = OUT },
    },
    ambient = {
      { draft = true,
        en = "Even away from the shore, you can sense the sea: a salty smell on the wind, damp air that clings to your skin.",
        fr = "Même loin du rivage, on devine la mer : une odeur de sel portée par le vent, un air humide qui colle à la peau.",
        when = OUT },
      { draft = true,
        en = "They say elven ruins haunt these woods, and that some souls never left Ameth'Aran. Despite yourself, you glance over your shoulder.",
        fr = "On raconte que des ruines elfiques hantent ces bois, et que certaines âmes n'ont jamais quitté Ameth'Aran. Malgré vous, vous jetez un œil par-dessus votre épaule.",
        when = { indoors = false, notRace = "NightElf" } },
      { draft = true,
        en = "The dark trees of the coast bend in the wind, their branches creaking softly. The place seems to carry an old sorrow.",
        fr = "Les arbres sombres de la côte ploient sous le vent, et leurs branches grincent doucement. L'endroit semble porter un vieux chagrin.",
        when = OUT },
      { draft = true, -- for night elves
        en = "You know the stories of Ameth'Aran, the city that fell to ruin not far from here. They say some souls never left it, and that old sorrow is a little bit yours.",
        fr = "Vous connaissez les histoires d'Ameth'Aran, la cité tombée en ruine non loin d'ici. On dit que certaines âmes ne l'ont jamais quittée, et ce chagrin ancien est un peu le vôtre.",
        when = { indoors = false, race = "NightElf" } },
    },
  },
  [1440] = { -- Ashenvale
    arrive = {
      { draft = true, long = true, check = "Orneval",
        en = "Ashenvale wraps around you: immense trees, a bluish light, and a smell of sap and moss. It feels like stepping into a sanctuary.",
        fr = "La forêt d'Orneval vous enveloppe : des arbres immenses, une lumière bleutée, et une odeur de sève et de mousse. Vous avez l'impression d'entrer dans un sanctuaire.",
        when = OUT },
    },
    ambient = {
      { draft = true, check = "Grommash Hurlenfer",
        en = "They say this is where Cenarius fell to Grommash Hellscream's axe. The forest has not forgotten.",
        fr = "On dit que c'est ici que Cenarius est tombé sous la hache de Grommash Hurlenfer. La forêt, elle, n'a pas oublié.",
        when = { indoors = false, notRace = { "NightElf", "Orc" } } },
      { draft = true,
        en = "The leaves rustle overhead like a thousand whispers. You can't help but listen.",
        fr = "Les feuilles bruissent au-dessus de vous comme mille voix chuchotées. Vous ne pouvez pas vous empêcher de tendre l'oreille.",
        when = OUT },
      { draft = true,
        en = "The air is cool and damp beneath the great trees, and each step sinks a little into the moss. This forest is older than anything you know.",
        fr = "L'air est frais et humide sous les grands arbres, et chaque pas s'enfonce un peu dans la mousse. Cette forêt est plus vieille que tout ce que vous connaissez.",
        when = { indoors = false, moving = true } },
      { draft = true, check = "Grommash Hurlenfer", -- for night elves
        en = "This is where Cenarius, demigod of the forest, fell to Grommash Hellscream's axe. Every time you think of it, a dull anger rises in your heart.",
        fr = "C'est ici que Cenarius, le demi-dieu de la forêt, est tombé sous la hache de Grommash Hurlenfer. Chaque fois que vous y pensez, une colère sourde vous monte au cœur.",
        when = { indoors = false, race = "NightElf" } },
      { draft = true, check = "Grommash Hurlenfer, Mannoroth", -- for orcs
        en = "It was in these woods that Grommash Hellscream slew Mannoroth and broke your people's chains. The price was heavy, but you walk with your head held high.",
        fr = "C'est dans ces bois que Grommash Hurlenfer a abattu Mannoroth et brisé les chaînes de votre peuple. Le prix fut lourd, mais vous marchez la tête haute.",
        when = { indoors = false, race = "Orc" } },
    },
  },
  [1436] = { -- Westfall (the farmland landscape already has its own lines)
    ambient = {
      { draft = true, check = "Confrérie Défias",
        en = "They say the stonemasons who rebuilt Stormwind were never paid. Since then, the Defias Brotherhood has roamed these hills, red masks over their faces.",
        fr = "On raconte que les tailleurs de pierre qui ont rebâti Hurlevent n'ont jamais été payés. Depuis, la Confrérie Défias rôde dans ces collines, un foulard rouge sur le visage.",
        when = { indoors = false, notRace = "Human" } },
      { draft = true,
        en = "The farms here were abandoned one by one. You can't help wondering what became of the people who lived in them.",
        fr = "Les fermes d'ici ont été abandonnées une à une. Vous ne pouvez pas vous empêcher de vous demander ce que sont devenus ceux qui y vivaient.",
        when = OUT },
      { draft = true, check = "Confrérie Défias", -- for humans
        en = "Stormwind was rebuilt by these stonemasons, and the city never paid them. Thinking of the Defias Brotherhood, you feel a mix of anger and shame.",
        fr = "Hurlevent a été rebâtie par ces tailleurs de pierre, et la ville ne les a jamais payés. En pensant à la Confrérie Défias, vous ressentez un mélange de colère et de honte.",
        when = { indoors = false, race = "Human" } },
    },
  },
  [1426] = { -- Dun Morogh
    arrive = {
      { draft = true, long = true,
        en = "The mountains of Dun Morogh surround you, white and silent. The icy air smells of pine and woodsmoke, and somewhere, a forge must already be burning.",
        fr = "Les montagnes de Dun Morogh vous entourent, blanches et silencieuses. L'air glacé sent le pin et la fumée de bois, et quelque part, une forge doit déjà être allumée.",
        when = OUT },
    },
    ambient = {
      { draft = true,
        en = "They say the gnomes had to flee Gnomeregan when their city was overrun. Thinking of them, the cold feels a little sharper.",
        fr = "On dit que les gnomes ont dû fuir Gnomeregan quand leur cité a été envahie. En pensant à eux, le froid vous semble un peu plus mordant.",
        when = { indoors = false, notRace = "Gnome" } },
      { draft = true,
        en = "The wind comes down from the peaks and stings your cheeks. You dream of a crackling fireplace and a warm mug.",
        fr = "Le vent descend des sommets et vous pique les joues. Vous rêvez d'un feu de cheminée et d'une chope bien chaude.",
        when = OUT },
      { draft = true, -- for gnomes
        en = "Somewhere beneath these mountains, Gnomeregan is lost. Every time you think of it, your throat tightens: one day, your people will take it back.",
        fr = "Quelque part sous ces montagnes, Gnomeregan est perdue. Chaque fois que vous y pensez, votre gorge se serre : un jour, votre peuple la reprendra.",
        when = { indoors = false, race = "Gnome" } },
      { draft = true, -- for dwarves: home
        en = "Icy air, the smell of pine and forge smoke: you're home, and every gust of cold wind reminds you of it.",
        fr = "L'air glacé, l'odeur du pin et de la fumée des forges : vous êtes chez vous, et chaque bouffée de vent froid vous le rappelle.",
        when = { indoors = false, race = "Dwarf" } },
    },
  },
  [1432] = { -- Loch Modan
    arrive = {
      { draft = true, long = true,
        en = "Loch Modan stretches before you, ringed by green hills. The air is crisp and smells of grass and lake water, and they say that to the north, a great dwarven dam holds back the whole loch.",
        fr = "Le Loch Modan s'étend devant vous, bordé de collines vertes. L'air est vif et sent l'herbe et l'eau du lac, et l'on dit qu'au nord, un immense barrage nain retient tout le loch.",
        when = OUT },
    },
    ambient = {
      { draft = true,
        en = "The wind ripples the grass on the hills. Everything here breathes a simple, quiet life.",
        fr = "Le vent fait onduler l'herbe des collines. Ici, tout respire une vie simple et tranquille.",
        when = OUT },
      { draft = true,
        en = "They say troggs crawled up from the depths when the dwarves dug too deep. You eye the rocks around you with suspicion.",
        fr = "On raconte que des troggs sont sortis des profondeurs quand les nains ont creusé trop loin. Vous jetez un œil méfiant aux rochers alentour.",
        when = OUT },
      { draft = true, -- for dwarves
        en = "Dwarves like to say the great dam of the Loch was built to last a thousand years. You don't doubt it for a second: that's dwarven work.",
        fr = "Entre nains, on aime dire que le grand barrage du Loch a été bâti pour durer mille ans. Vous n'en doutez pas une seconde : c'est du travail de nain.",
        when = { indoors = false, race = "Dwarf" } },
    },
  },
  [1433] = { -- Redridge Mountains
    arrive = {
      { draft = true, long = true, check = "Les Carmines",
        en = "The Redridge Mountains raise their red rocks all around. The air is mild, yet there's a tension in these valleys, as if everyone were watching for something.",
        fr = "Les Carmines dressent leurs rochers rouges tout autour de vous. L'air est doux, et pourtant on sent une tension dans ces vallées, comme si chacun guettait quelque chose.",
        when = OUT },
    },
    ambient = {
      { draft = true, check = "Rochenoire, Comté-du-Lac",
        en = "They say Blackrock orcs come down from the mountains to raid the farms. In Lakeshire, people sleep with one eye open.",
        fr = "On dit que les orcs Rochenoire descendent des montagnes pour piller les fermes. À Comté-du-Lac, on dort d'un œil.",
        when = OUT },
      { draft = true,
        en = "The sun warms the red rock, and the air smells of hot dust and dry grass.",
        fr = "Le soleil chauffe la roche rouge, et l'air sent la poussière chaude et les herbes sèches.",
        when = { indoors = false, sky = true, night = false, weather = "clear" } },
      { draft = true,
        en = "This land is beautiful, and yet you can't quite relax. Here, people live with war at their door.",
        fr = "Ce pays est beau, et pourtant vous ne parvenez pas tout à fait à vous détendre. Ici, on vit avec la guerre à sa porte.",
        when = OUT },
    },
  },
  [1431] = { -- Duskwood
    arrive = {
      { draft = true, long = true, check = "Bois de la Pénombre",
        en = "The light fades the moment you enter Duskwood. Dead trees stretch out their black branches, the air smells of damp earth and rot, and a shiver runs down your spine.",
        fr = "La lumière s'éteint dès que vous entrez dans le Bois de la Pénombre. Les arbres morts tendent leurs branches noires, l'air sent la terre humide et la pourriture, et un frisson vous remonte le long du dos.",
        when = OUT },
    },
    ambient = {
      { draft = true, check = "Garde de nuit",
        en = "The people of Darkshire speak in hushed voices about what prowls these woods. They say the Night Watch never really sleeps.",
        fr = "Les habitants de Sombre-Comté parlent à voix basse de ce qui rôde dans ces bois. On dit que la Garde de nuit ne dort jamais vraiment.",
        when = OUT },
      { draft = true,
        en = "Somewhere, a wolf howls. Or maybe something else. You freeze for a moment, your heart pounding.",
        fr = "Quelque part, un loup hurle. Ou peut-être autre chose. Vous vous figez un instant, le cœur battant.",
        when = { indoors = false, calm = true } },
      { draft = true,
        en = "Here, it is always night. You've lost track of the hours, and it makes you uneasy.",
        fr = "Ici, il fait toujours nuit. Vous avez perdu la notion des heures, et cela vous met mal à l'aise.",
        when = OUT },
    },
  },
  [1437] = { -- Wetlands
    arrive = {
      { draft = true, long = true, check = "Les Paluns",
        en = "The Wetlands greet you with their smell of silt and stagnant water. The spongy ground clings to your feet, and the damp air sticks to your skin.",
        fr = "Les Paluns vous accueillent avec leur odeur de vase et d'eau stagnante. Le sol spongieux colle à vos pieds, et l'air humide colle à votre peau.",
        when = OUT },
    },
    ambient = {
      { draft = true, check = "Gueule-de-dragon",
        en = "They say the Dragonmaw clan keeps red dragons in chains somewhere in these mountains. Instinctively, you look up toward the peaks.",
        fr = "On raconte que le clan Gueule-de-dragon garde des dragons rouges enchaînés quelque part dans ces montagnes. Instinctivement, vous levez les yeux vers les sommets.",
        when = OUT },
      { draft = true,
        en = "Insects buzz around you, and the damp seeps right into your bones. You dream of a fire and dry clothes.",
        fr = "Les insectes bourdonnent autour de vous, et l'humidité vous pénètre jusqu'aux os. Vous rêvez d'un feu et de vêtements secs.",
        when = OUT },
    },
  },
  [1455] = { -- Ironforge
    arrive = {
      { draft = true, long = true, check = "Forgefer",
        en = "Ironforge's gates open onto a welcome warmth. The rumble of the forges echoes through the stone, and the air smells of hot metal and beer. You are in the heart of the mountain.",
        fr = "Les portes de Forgefer s'ouvrent sur une chaleur bienvenue. Le grondement des forges résonne dans la pierre, et l'air sent le métal chaud et la bière. Vous êtes au cœur de la montagne.",
        when = { indoors = true } },
    },
    ambient = {
      { draft = true,
        en = "They say the city was carved out of the mountain itself, centuries ago, and has never fallen. Within these walls, you feel safe from everything.",
        fr = "On dit que la cité a été taillée dans la montagne elle-même, il y a des siècles, et qu'elle n'est jamais tombée. Entre ces murs, vous vous sentez à l'abri de tout.",
        when = { indoors = true, notRace = { "Dwarf", "Gnome" } } },
      { draft = true,
        en = "The orange glow of the forges dances on the stone. Here, even the mountain feels warm.",
        fr = "La lumière orangée des forges danse sur la pierre. Ici, même la montagne semble chaleureuse.",
        when = { indoors = true } },
      { draft = true, -- for dwarves
        en = "Ironforge, the city of your ancestors, carved into the heart of the mountain. You walk its halls with quiet pride.",
        fr = "Forgefer, la cité de vos ancêtres, taillée au cœur de la montagne. Vous la parcourez avec une fierté tranquille.",
        when = { indoors = true, race = "Dwarf" } },
      { draft = true, -- for gnomes
        en = "The dwarves opened their gates to you when Gnomeregan fell. Within these walls, you feel safe, and a little in their debt.",
        fr = "Les nains vous ont ouvert leurs portes quand Gnomeregan est tombée. Entre ces murs, vous vous sentez à l'abri, et un peu redevable.",
        when = { indoors = true, race = "Gnome" } },
    },
  },

  -- Horde homelands: a line for the people who live there
  [1411] = { -- Durotar
    ambient = {
      { draft = true, check = "Durotar, Thrall", -- for orcs
        en = "Durotar's red earth is dry and hard, like your people. Thrall named it after his father, and you tread it with pride.",
        fr = "La terre rouge de Durotar est sèche et dure, comme votre peuple. Thrall lui a donné le nom de son père, et vous la foulez avec fierté.",
        when = { indoors = false, race = "Orc" } },
      { draft = true, check = "îles de l'Écho, Sombrelances", -- for trolls
        en = "The Echo Isles aren't far, and the smell of the sea reminds you that the Darkspear have finally found a home.",
        fr = "Les îles de l'Écho ne sont pas loin, et l'odeur de la mer vous rappelle que les Sombrelances ont enfin trouvé un foyer.",
        when = { indoors = false, race = "Troll" } },
    },
  },
  [1420] = { -- Tirisfal Glades
    ambient = {
      { draft = true, -- for the Forsaken
        en = "These glades were once your kingdom, alive and full of light. All that's left is the grey mist, and a memory that gives you no peace.",
        fr = "Ces clairières étaient autrefois votre royaume, vivantes et lumineuses. Il n'en reste que la brume grise, et un souvenir qui ne vous laisse pas en paix.",
        when = { indoors = false, race = "Scourge" } },
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
  { id = "sw_dwarven_forge", map = 1453, x = 63.7, y = 36.7, r = 2.5, when = { indoors = false },
    names = { en = "the Dwarven District forge", fr = "la forge du Quartier des Nains" },
    arrive = {
      { long = true,
        en = "You step close to the forge. The heat hits you like a wall, the air shimmers above the coals, and the smell of hot iron fills your lungs.",
        fr = "Vous vous approchez de la forge. La chaleur vous frappe comme un mur, l'air tremble au-dessus des braises, et l'odeur du fer chaud vous emplit les poumons." },
    },
    ambient = {
      { en = "The heat of the forge stings your cheeks.", fr = "La chaleur de la forge vous pique les joues." },
      { en = "The coals glow red, and the air above them shimmers.", fr = "Les braises rougeoient, et l'air tremble au-dessus d'elles." },
    } },
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
  { id = "sw_trade", zone = 1453, names = { "trade district", "quartier commerçant", "the gilded rose", "la rose dorée" },
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
  { id = "sw_canals", zone = 1453, names = { "the canals", "les canaux" },
    arrive = {
      { long = true,
        en = "The canal water laps gently against the stone. A smell of damp and wet stone rises to meet you.",
        fr = "L'eau des canaux clapote doucement contre la pierre. Une odeur d'humidité et de pierre mouillée monte jusqu'à vous.",
        when = OUT },
    },
    ambient = {
      { en = "Water laps against the stone of the canals.", fr = "L'eau clapote contre la pierre des canaux.", when = OUT },
    } },
  { id = "sw_mage", zone = 1453, names = { "mage quarter", "quartier des mages" },
    arrive = {
      { long = true,
        en = "The air of the Mage Quarter tingles on your skin, heavy with magic, and violet light glows in the tower windows.",
        fr = "L'air du Quartier des Mages picote sur votre peau, chargé de magie, et une lueur violette brille aux fenêtres des tours.",
        when = OUT },
    },
    ambient = {
      { en = "The air tingles faintly with magic.", fr = "L'air picote légèrement de magie." },
    } },
  { id = "sw_dwarven", zone = 1453, names = { "dwarven district", "quartier des nains" }, -- Stormwind's forges
    arrive = {
      { long = true,
        en = "The air grows thick and warm as you enter the Dwarven District. Smoke drifts from the forges, carrying a smell of hot iron, coal and gunpowder.",
        fr = "L'air devient lourd et chaud quand vous entrez dans le Quartier des Nains. La fumée des forges flotte dans les rues, chargée d'une odeur de fer chaud, de charbon et de poudre.",
        when = OUT },
    },
    ambient = {
      { long = true,
        en = "Even before you see the forges, you can smell them: coal smoke, hot iron, a hint of gunpowder. In the Dwarven District, a fire is never far.",
        fr = "Avant même de voir les forges, vous les sentez : fumée de charbon, fer chaud, une pointe de poudre. Dans le Quartier des Nains, le feu n'est jamais loin.",
        when = OUT },
      { en = "A smell of coal smoke and hot iron hangs over the district.", fr = "Une odeur de fumée de charbon et de fer chaud flotte sur le quartier.", when = OUT },
      { en = "Thick smoke curls up from the forges.", fr = "Une épaisse fumée s'élève des forges.", when = OUT },
      { en = "A whiff of gunpowder mixes with the forge smoke.", fr = "Une pointe de poudre se mêle à la fumée des forges.", when = OUT },
      { en = "Soot drifts in the air and settles on your sleeves.", fr = "De la suie flotte dans l'air et se dépose sur vos manches.", when = OUT },
    } },
  { id = "sw_cathedral", zone = 1453, names = { "cathedral square", "place de la cathédrale" },
    ambient = {
      { en = "The great cathedral towers over the square.", fr = "La grande cathédrale domine la place.", when = OUT },
    } },
  { id = "wf_pumpkins", zone = 1436, names = { "furlbrow's pumpkin farm", "ferme de potirons de froncebouille" }, -- Westfall
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
  { id = "goldshire", zone = 1429, names = { "goldshire", "comté-de-l'or", "lion's pride inn", "auberge de la fierté du lion" },
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
  { id = "darkshire", zone = 1431, names = { "darkshire", "sombre-comté", "scarlet raven tavern" }, -- Duskwood
    hearth = {
      { en = "Darkshire's inn is dim and hushed, and outside, the night never ends. You're in no real hurry to step back out there.",
        fr = "L'auberge de Sombre-Comté est sombre et feutrée, et dehors, la nuit ne finit jamais. Vous n'avez pas vraiment hâte de ressortir.",
        when = { indoors = true } },
      { en = "The dim inn of Darkshire, at last. Out there, the endless night is waiting... You'd gladly linger here a little longer.",
        fr = "La pénombre de l'auberge de Sombre-Comté, enfin. Dehors, la nuit sans fin vous attend... Vous aimeriez bien pouvoir vous éterniser un peu.",
        when = { indoors = true } },
    } },
  { id = "td_shadowglen", zone = 1438, names = { "shadowglen", "sombrevallon" }, -- Teldrassil, night elf start
    arrive = {
      { draft = true, long = true, check = "Sombrevallon",
        en = "Shadowglen wakes around you: mossy paths, soft lanterns, and the immense silhouette of Aldrassil above the trees. This is where everything begins.",
        fr = "Sombrevallon s'éveille autour de vous : des sentiers moussus, des lanternes douces et l'immense silhouette d'Aldrassil au-dessus des arbres. C'est ici que tout commence.",
        when = OUT },
    } },
  { id = "if_forge", zone = 1455, names = { "the great forge", "la grande forge" },
    arrive = {
      { en = "The heat of the Great Forge washes over you.", fr = "La chaleur de la Grande Forge vous enveloppe." },
    },
    ambient = {
      { en = "Molten metal glows in the great channels.", fr = "Le métal en fusion rougeoie dans les grandes rigoles." },
      { en = "The heat of the Great Forge washes over you.", fr = "La chaleur de la Grande Forge vous enveloppe." },
    } },
}
