-- Wayfarer's Tales - more lines for situations that only had one (audit of 2026-11-11).
-- All drafts: they play only while "Try new lines" is on, and go through the review page.
-- They are added at load time to the lines they extend (places, moments, body), or,
-- for message pools (pet, body, danger), merged in while testing (D.POOL_DRAFTS).

local _, KT = ...
local D = KT.Data

local OUT = { indoors = false }

---------------------------------------------------------------------------
-- Places
---------------------------------------------------------------------------
D.SENSES_MORE = {
  weatherChange = {
    rainStart = {
      { draft = true,
        en = "One drop, then two, then ten: the rain starts to fall, and at once the air fills with the smell of rain.",
        fr = "Une goutte, puis deux, puis dix : la pluie se met à tomber, et l'air se charge aussitôt d'une odeur de pluie." },
      { draft = true,
        en = "The first drops fall, pattering all around you.",
        fr = "Les premières gouttes tombent en crépitant tout autour de vous." },
      -- (review 2026-11-11: the "smell of rain" half of the old rain line, for when it starts)
      { draft = true,
        en = "The air suddenly smells fresh with rain, and the first drops start tapping on your shoulders.",
        fr = "L'air prend soudain une odeur fraîche de pluie, et les premières gouttes viennent tapoter sur vos épaules.",
        when = { indoors = false, sky = true } },
    },
    rainStop = {
      { draft = true,
        en = "The rain finally stops. Everything is dripping, and a fresh smell rises from everywhere.",
        fr = "La pluie s'arrête enfin. Tout ruisselle, et une odeur fraîche monte de partout." },
      { draft = true,
        en = "The last drops fall, then nothing. The world seems to breathe again.",
        fr = "Les dernières gouttes tombent, puis plus rien. Le monde semble respirer à nouveau." },
    },
  },
  biomes = {
    badlands = { arrive = {
      { draft = true,
        en = "The earth here is red, cracked, burned by the sun. Nothing really grows, and the dry wind sticks the dust to your lips.",
        fr = "La terre ici est rouge, craquelée, brûlée par le soleil. Rien ne pousse vraiment, et le vent sec vous colle la poussière aux lèvres.",
        when = OUT },
    } },
    canyon = {
      arrive = {
        { draft = true,
          en = "Immense rock walls surround you, and the slightest sound echoes for a long time. You feel tiny.",
          fr = "D'immenses parois de roche vous entourent, et le moindre bruit y résonne longtemps. Vous vous sentez minuscule.",
          when = OUT },
      },
      ambient = {
        { draft = true,
          en = "A pebble tumbles down the rock face and bounces for a long time before it stops. The silence that follows feels heavier.",
          fr = "Un caillou dévale la paroi et rebondit longtemps avant de s'arrêter. Le silence qui suit semble plus lourd encore.",
          when = { indoors = false, calm = true } },
      },
    },
    coast = {
      arrive = {
        { draft = true,
          en = "The sea wind tousles you, heavy with salt and spray. Somewhere, the waves roll on and on.",
          fr = "Le vent du large vous ébouriffe, chargé de sel et d'embruns. Quelque part, les vagues roulent sans fin.",
          when = OUT },
      },
      ambient = {
        { draft = true,
          en = "The sea wind whips your face and leaves a taste of salt on your lips.",
          fr = "Le vent marin vous fouette le visage et laisse un goût de sel sur vos lèvres.",
          when = OUT },
      },
    },
    corrupted = {
      arrive = {
        { draft = true, long = true,
          en = "The trees here are twisted, their blackened bark oozing a thick sap. The air smells of sweet rot, and part of you wants to turn back.",
          fr = "Les arbres ici sont tordus, leur écorce noircie suinte une sève épaisse. L'air sent la pourriture sucrée, et une part de vous a envie de faire demi-tour.",
          when = OUT },
      },
      ambient = {
        { draft = true,
          en = "A sweetish, unhealthy smell drifts between the trunks. You barely breathe, just in case.",
          fr = "Une odeur douceâtre et malsaine flotte entre les troncs. Vous respirez à peine, par prudence.",
          when = OUT },
      },
    },
    hills = { arrive = {
      { draft = true,
        en = "The hills roll away as far as the eye can see, green and gentle. The wind runs free here, and your step grows lighter.",
        fr = "Les collines roulent à perte de vue, vertes et douces. Le vent y court librement, et votre pas se fait plus léger.",
        when = OUT },
    } },
    marsh = {
      arrive = {
        { draft = true,
          en = "The smell of silt grabs you, and the damp clings to everything. Here, every step is a negotiation with the mud.",
          fr = "L'odeur de vase vous saisit, et l'humidité colle à tout. Ici, chaque pas est une négociation avec la boue.",
          when = OUT },
      },
      ambient = {
        { draft = true,
          en = "The air smells of silt and wet reeds, and the damp sticks to your skin.",
          fr = "L'air sent la vase et les roseaux mouillés, et l'humidité vous colle à la peau.",
          when = OUT },
      },
    },
    mountain = { arrive = {
      { draft = true,
        en = "The peaks tower over you on every side. The wind is colder up here, purer too, and every breath wakes you up.",
        fr = "Les sommets vous dominent de toutes parts. Le vent est plus froid ici, plus pur aussi, et chaque inspiration vous réveille.",
        when = OUT },
    } },
    plague = { arrive = {
      { draft = true,
        en = "A smell of sickness hangs over these lands. The grass is grey, the trees bare, and a dull unease tightens your throat.",
        fr = "Une odeur de maladie flotte sur ces terres. L'herbe est grise, les arbres nus, et un malaise sourd vous serre la gorge.",
        when = OUT },
    } },
    plains = { arrive = {
      { draft = true,
        en = "The plains open up before you, immense. The wind sings in the grass, and the horizon seems to go on forever.",
        fr = "Les plaines s'ouvrent devant vous, immenses. Le vent y chante dans l'herbe, et l'horizon semble ne jamais finir.",
        when = OUT },
    } },
    swamp = { arrive = {
      { draft = true,
        en = "The air is heavy, hot and humid, and the stagnant water gives off a smell of rot. You press on, grimacing.",
        fr = "L'air est lourd, chaud et humide, et l'eau stagnante dégage une odeur de pourriture. Vous avancez en grimaçant.",
        when = OUT },
    } },
    undercity = {
      arrive = {
        { draft = true,
          en = "You go underground, and the air turns cold and stale. It smells of damp stone, dust... and something far less pleasant.",
          fr = "Vous descendez sous terre, et l'air devient froid et confiné. Ça sent la pierre humide, la poussière… et quelque chose de bien moins agréable." },
      },
      ambient = {
        { draft = true,
          en = "The cold, damp air of the underground city clings to your skin.",
          fr = "L'air froid et humide de la cité souterraine vous colle à la peau." },
      },
    },
    volcanic = { arrive = {
      { draft = true,
        en = "Heat rises from the ground, and the air smells of sulfur and ash. Here, the earth still rumbles with anger.",
        fr = "La chaleur monte du sol, l'air sent le soufre et la cendre. Ici, la terre gronde encore de colère.",
        when = OUT },
    } },
    wasteland = {
      arrive = {
        { draft = true,
          en = "A dry, empty land stretches before you. The wind carries nothing but dust and silence, and suddenly you feel very far from everything.",
          fr = "Une terre sèche et vide s'étend devant vous. Le vent ne porte que poussière et silence, et vous vous sentez soudain très loin de tout.",
          when = OUT },
      },
      ambient = {
        { draft = true,
          en = "Nothing moves, except the dust the wind lifts here and there. A landscape that tugs at your heart.",
          fr = "Rien ne bouge, à part la poussière que le vent soulève par endroits. Un paysage qui vous serre le cœur.",
          when = OUT },
      },
    },
  },
  zones = {
    [1453] = { ambient = { -- Stormwind
      { draft = true,
        en = "Stormwind hums around you: voices, footsteps, endless comings and goings.",
        fr = "Hurlevent bourdonne autour de vous : des voix, des pas, des allées et venues sans fin.",
        when = { indoors = false, crowd = { "lively", "crowded" } } },
      { draft = true,
        en = "The white stone of Stormwind surrounds you, solid and reassuring. Here, you feel sheltered from the world.",
        fr = "La pierre blanche de Hurlevent vous entoure, solide et rassurante. Ici, vous vous sentez à l'abri du monde.",
        when = OUT },
    } },
  },
  subzones = {
    sw_cathedral = { ambient = {
      { draft = true,
        en = "White steps lead up to the great doors of the cathedral. Just looking at them, a strange calm comes over you.",
        fr = "Des marches blanches mènent aux grandes portes de la cathédrale. Rien qu'à les regarder, un calme étrange vous gagne.",
        when = OUT },
    } },
    goldshire = { ambient = {
      { draft = true,
        en = "Goldshire has something reassuring about it: the roofs, the smell of the inn, the familiar paths. Here, you feel safe.",
        fr = "Comté-de-l'Or a quelque chose de rassurant : les toits, l'odeur de l'auberge, les chemins familiers. Ici, on se sent à l'abri.",
        when = OUT },
    } },
    sw_mage = { ambient = {
      { draft = true,
        en = "The towers of the Mage Quarter rise all around, and the air seems to hum softly, as if charged with an invisible spark.",
        fr = "Les tours du Quartier des Mages se dressent tout autour, et l'air semble vibrer doucement, comme chargé d'une électricité invisible.",
        when = OUT },
    } },
    sw_canals = { ambient = {
      { draft = true,
        en = "The reflections of the houses tremble on the surface of the canals. The water smells of wet stone, and a little of silt.",
        fr = "Le reflet des maisons tremble à la surface des canaux. L'eau sent la pierre mouillée, et un peu la vase.",
        when = OUT },
    } },
    sw_trade = { ambient = {
      { draft = true,
        en = "The Trade District buzzes with activity: voices, footsteps, the smell of new leather and polished wood.",
        fr = "Le Quartier commerçant bourdonne d'activité : des voix, des pas, l'odeur du cuir neuf et du bois ciré.",
        when = { indoors = false, crowd = { "lively", "crowded" } } },
    } },
  },
  spots = {
    mw_shadowglen_water = { ambient = {
      { draft = true,
        en = "Standing in the water of the well, you feel a faint tingle climbing up your legs. The water seems alive.",
        fr = "Debout dans l'eau du puits, vous sentez un léger picotement vous remonter le long des jambes. L'eau semble vivante." },
    } },
    td_dolanaar_inn = { ambient = {
      { draft = true,
        en = "The pale wood of the inn creaks softly under your feet. Everything here invites you to set down your pack for a while.",
        fr = "Le bois clair de l'auberge craque doucement sous vos pas. Ici, tout invite à poser son sac pour un moment.",
        when = { moving = true } },
    } },
  },
}

---------------------------------------------------------------------------
-- Moments
---------------------------------------------------------------------------
D.MOMENTS_MORE = {
  fallHard = {
    { draft = true,
      en = "You hit the ground hard. The shock rattles up to your teeth, and for a moment you stay there, dazed.",
      fr = "Vous heurtez le sol de plein fouet. Le choc vous remonte jusque dans les dents, et vous restez un instant {étourdi|étourdie|étourdi·e}." },
  },
  fishJunk = {
    { draft = true,
      en = "You reel in something heavy... but it's not a fish: {item}. The water has a sense of humor.",
      fr = "Vous remontez quelque chose de lourd… mais ce n'est pas un poisson : {item}. L'eau a le sens de l'humour." },
  },
  herb_bruiseweed = {
    { draft = true,
      en = "The leaves are thick and a little rough under your fingers. A bitter, prickly smell tickles your nose.",
      fr = "Les feuilles sont épaisses et un peu rugueuses sous vos doigts. Une odeur amère et piquante vous chatouille le nez." },
  },
  herb_stranglekelp = {
    { draft = true,
      en = "You tear the kelp from the bottom. It's slippery, cold, and smells strongly of deep water.",
      fr = "Vous arrachez l'algue au fond de l'eau. Elle est glissante, froide, et sent fort l'eau profonde." },
  },
  craftEpic = {
    { draft = true,
      en = "{item}. Every detail is perfect. You stay a long moment admiring your work, breathless.",
      fr = "{item}. Chaque détail est parfait. Vous restez un long moment à contempler votre œuvre, le souffle court." },
  },
  craftFirst_boom = {
    { draft = true,
      en = "Your very first creation: {item}. You hold it at arm's length, very far from your face. Just in case.",
      fr = "Votre toute première création : {item}. Vous la tenez à bout de bras, très loin de votre visage. Par précaution." },
  },
  drinkDew = {
    { draft = true,
      en = "Your {item} is so light it seems to vanish on your tongue. A taste of dew and barely opened flowers.",
      fr = "Votre {item} est si légère qu'elle semble s'évaporer sur la langue. Un goût de rosée et de fleurs à peine écloses." },
  },
  drinkJuice = {
    { draft = true,
      en = "Your {item} is bursting with flavor, sweet and a little tangy. You almost lick the bottle.",
      fr = "Votre {item} déborde de saveur, sucrée et un peu acidulée. Vous en léchez presque le goulot." },
  },
  foodMilestone = {
    { draft = true,
      en = "Your {item} again, for the {count}th time! You certainly know what you like.",
      fr = "Encore votre {item}, pour la {count}e fois ! On peut dire que vous savez ce que vous aimez." },
  },
  drinkMilestone = {
    { draft = true,
      en = "Your {item} again, for the {count}th time! You certainly know what you like.",
      fr = "Encore votre {item}, pour la {count}e fois ! On peut dire que vous savez ce que vous aimez." },
  },
  firstSip = {
    { draft = true,
      en = "You taste your {item} for the first time, in small sips, so as not to miss a thing.",
      fr = "Vous goûtez votre {item} pour la première fois, à petites gorgées, pour ne rien manquer de sa saveur." },
  },
  firstSip_Water = {
    { draft = true,
      en = "You taste your {item} for the first time. It has that little taste of stone and spring that refreshes you down to your fingertips.",
      fr = "Vous goûtez votre {item} pour la première fois. Elle a ce petit goût de pierre et de source qui vous rafraîchit jusqu'au bout des doigts." },
  },
  firstSip_Milk = {
    { draft = true,
      en = "First sip of your {item}: soft, creamy, a little sweet. All at once, you're a child again.",
      fr = "Première gorgée de votre {item} : doux, crémeux, un peu sucré. D'un coup, vous voilà en enfance." },
  },
  firstSip_Juice = {
    { draft = true,
      en = "First sip of your {item}: a burst of fruit that wakes up your taste buds. You take another sip right away.",
      fr = "Première gorgée de votre {item} : un éclat de fruit qui vous réveille les papilles. Vous en reprenez une gorgée aussitôt." },
  },
  firstSip_Dew = {
    { draft = true,
      en = "First sip of your {item}. Fresh, delicate, like drinking a little bit of morning.",
      fr = "Première gorgée de votre {item}. C'est frais, délicat, comme boire un peu de matin." },
  },
  firstSip_Conjured = {
    { draft = true,
      en = "Your first sip of conjured water: cold, clear, without the slightest taste. Handy, but a little sad.",
      fr = "Votre première gorgée d'eau invoquée : froide, limpide, sans le moindre goût. Pratique, mais un peu triste." },
  },
  firstTaste_meat = {
    { draft = true,
      en = "First bite of your {item}: a frank taste of meat, salted just right. Your stomach approves at once.",
      fr = "Première bouchée de votre {item} : une saveur franche de viande, salée juste comme il faut. Votre estomac approuve aussitôt." },
  },
  firstTaste_fish = {
    { draft = true,
      en = "First bite of your {item}: delicate flesh that falls apart in your mouth, with a taste of clear water.",
      fr = "Première bouchée de votre {item} : une chair délicate qui se défait sous la dent, avec un goût d'eau claire." },
  },
  firstTaste_bread = {
    { draft = true,
      en = "First bite of your {item}: it crunches, then melts. A smell of warm oven rises to your nose.",
      fr = "Première bouchée de votre {item} : ça craque, puis ça fond. Une odeur de four chaud vous remonte au nez." },
  },
  firstTaste_fruit = {
    { draft = true,
      en = "First bite of your {item}: the juice runs down your chin, sweet and fresh. A real little joy.",
      fr = "Première bouchée de votre {item} : le jus vous coule sur le menton, sucré et frais. Un vrai petit bonheur." },
  },
  firstTaste_cheese = {
    { draft = true,
      en = "First bite of your {item}: a melting texture, a strong taste that stings your tongue a little. You want more.",
      fr = "Première bouchée de votre {item} : une texture fondante, un goût puissant qui pique un peu la langue. Vous en redemandez." },
  },
  firstTaste_fungus = {
    { draft = true,
      en = "First bite of your {item}: a spongy texture, a taste of damp undergrowth. You hesitate... then take another bite.",
      fr = "Première bouchée de votre {item} : une texture spongieuse, un goût de sous-bois humide. Vous hésitez… puis vous en reprenez." },
  },
}

---------------------------------------------------------------------------
-- Body lines with conditions (gear, forms, naps)
---------------------------------------------------------------------------
D.BODY_MORE = {
  napWakeFull = {
    { draft = true, always = true,
      en = "You open your eyes, fully rested. The world suddenly feels lighter.",
      fr = "Vous ouvrez les yeux, {parfaitement reposé|parfaitement reposée|parfaitement reposé·e}. Le monde vous semble soudain plus léger." },
  },
  dry = {
    { draft = true,
      en = "You shake yourself one last time: your fur is finally dry and all fluffy.",
      fr = "Vous vous ébrouez une dernière fois : votre fourrure est enfin sèche et toute gonflée.",
      when = { form = "furry" } },
  },
}

---------------------------------------------------------------------------
-- Message pools (pet, body, danger feelings): extra lines while testing
---------------------------------------------------------------------------
D.POOL_DRAFTS = {
  -- your pet won a fight you didn't take part in (no attack, spell or shot from you)
  petSolo = {
    { en = "{pet} handled that fight without your help, and holds their head high.",
      fr = "{pet} a réglé ce combat sans votre aide, et garde la tête haute." },
    { en = "While you were busy elsewhere, {pet} took the fight in hand. Nice work.",
      fr = "Pendant que vous aviez à faire ailleurs, {pet} a pris le combat en main. Du beau travail." },
  },
  petSoloAfk = { -- same, while you're away (/afk)
    { en = "While you were away, {pet} had to fight, and did it without you. The fight is over, and {pet} holds their head high.",
      fr = "Pendant votre absence, {pet} a dû se battre, et l'a fait sans vous. Le combat est fini, et {pet} garde la tête haute." },
  },
  dry = {
    { en = "You finally feel dry, and what a relief.", fr = "Vous vous sentez enfin au sec, et quel soulagement." },
    { en = "Your clothes have finished drying. You feel comfortable again.", fr = "Vos vêtements ont fini de sécher. Vous vous sentez de nouveau à l'aise." },
  },
  attentionExpired = {
    { en = "{pet} gets tired of waiting and wanders off to explore around.", fr = "{pet} se lasse d'attendre et s'en va explorer les environs." },
  },
  mealExpired = {
    { en = "{pet} lets out a little sigh and rests its head on its paws.", fr = "{pet} pousse un petit soupir et pose la tête sur ses pattes." },
  },
  mealExpiredMoving = {
    { en = "{pet} gives your meal one last look, then trots after you.", fr = "{pet} jette un dernier regard à votre repas, puis trottine derrière vous." },
  },
  mealOther = {
    { en = "{pet} hadn't asked for that, but doesn't complain for a second.", fr = "{pet} n'avait pas demandé ça, mais ne se plaint pas une seconde." },
  },
  mood_playful = { { en = "{pet} looks like it wants to play today.", fr = "{pet} a l'air d'avoir envie de jouer aujourd'hui." } },
  mood_cuddly  = { { en = "{pet} seeks your touch more than usual today.", fr = "{pet} cherche votre contact plus que d'habitude aujourd'hui." } },
  mood_curious = { { en = "{pet} sniffs everything within reach today.", fr = "{pet} renifle tout ce qui passe à sa portée aujourd'hui." } },
  mood_hungry  = { { en = "{pet} eyes your bags more often than usual today.", fr = "{pet} lorgne vos sacs plus souvent que d'habitude aujourd'hui." } },
  mood_sleepy  = { { en = "{pet} drags its paws a little today, eyelids heavy.", fr = "{pet} traîne un peu la patte aujourd'hui, les paupières lourdes." } },
  revive = {
    { en = "{pet} opens its eyes and gets up with difficulty. It will need a little gentleness.", fr = "{pet} rouvre les yeux et se relève péniblement. Un peu de douceur ne serait pas de trop." },
  },
  sorryNothing = {
    { en = "{pet} tilts its head, puzzled. Sorry? For what?", fr = "{pet} penche la tête, perplexe. Des excuses ? Pour quoi donc ?" },
  },
  stableMissed = {
    { en = "{pet} won't leave your side. You were clearly missed.", fr = "{pet} ne vous lâche plus d'une semelle. Vous lui avez manqué, c'est évident." },
  },
  petDangerNone = {
    { en = "{pet} strolls along without the slightest worry. Here, you're on conquered ground.", fr = "{pet} se promène tranquillement, sans la moindre inquiétude. Ici, vous êtes en terrain conquis." },
  },
  dangerFlavor_cold     = { { en = "A biting cold grips your chest, and it's not only the wind.", fr = "Un froid mordant vous serre la poitrine, et ce n'est pas seulement à cause du vent." } },
  dangerFlavor_gloom    = { { en = "The shadows seem thicker here, as if they were waiting for something.", fr = "Les ombres semblent plus épaisses ici, comme si elles attendaient quelque chose." } },
  dangerFlavor_hostile  = { { en = "The sun beats down, the earth cracks, and nothing here seems to want you.", fr = "Le soleil cogne, la terre craque, et rien ici ne semble vouloir de vous." } },
  dangerFlavor_sick     = { { en = "The air tastes of sickness, and every breath feels like one too many.", fr = "L'air a un goût de maladie, et chaque inspiration vous semble de trop." } },
  dangerFlavor_swamp    = { { en = "Something stirs under the murky surface. Or maybe not.", fr = "Quelque chose remue sous la surface de l'eau trouble. Ou peut-être pas." } },
  dangerFlavor_volcanic = { { en = "The ground rumbles under your feet, as if it were growling at you.", fr = "La terre gronde sous vos pieds, comme si elle grondait contre vous." } },
  dangerFlavor_wild     = { { en = "The silence around you is anything but peaceful. It feels more like waiting.", fr = "Le silence qui vous entoure n'a rien de paisible. Il ressemble plutôt à une attente." } },
}

---------------------------------------------------------------------------
-- Add the place, moment and body lines to the lines they extend
---------------------------------------------------------------------------
local function Append(dst, src)
  for _, line in ipairs(src or {}) do dst[#dst + 1] = line end
end

local S = D.SENSES
local M = D.SENSES_MORE
for key, lines in pairs(M.weatherChange or {}) do
  S.weatherChange[key] = S.weatherChange[key] or {}
  Append(S.weatherChange[key], lines)
end
for biome, kinds in pairs(M.biomes or {}) do
  S.biomes[biome] = S.biomes[biome] or {}
  for kind, lines in pairs(kinds) do
    S.biomes[biome][kind] = S.biomes[biome][kind] or {}
    Append(S.biomes[biome][kind], lines)
  end
end
for zone, kinds in pairs(M.zones or {}) do
  S.zones[zone] = S.zones[zone] or {}
  for kind, lines in pairs(kinds) do
    S.zones[zone][kind] = S.zones[zone][kind] or {}
    Append(S.zones[zone][kind], lines)
  end
end
for _, list in ipairs({ { S.subzones, M.subzones }, { S.spots, M.spots } }) do
  for _, entry in ipairs(list[1] or {}) do
    local more = list[2] and list[2][entry.id]
    for kind, lines in pairs(more or {}) do
      entry[kind] = entry[kind] or {}
      Append(entry[kind], lines)
    end
  end
end
for key, lines in pairs(D.MOMENTS_MORE) do
  D.MOMENTS[key] = D.MOMENTS[key] or {}
  Append(D.MOMENTS[key], lines)
end
for key, lines in pairs(D.BODY_MORE) do
  D.BODY_LINES[key] = D.BODY_LINES[key] or {}
  Append(D.BODY_LINES[key], lines)
end
