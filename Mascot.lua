-- Wayfarer's Tales - Mascots (companion pets from the mascot codex): a bond with the
-- little creature that follows you, for every class. One bond per character and per
-- mascot. It grows with what you share: time, places discovered together, cuddles,
-- campfires, naps, the first rain. No requests, no food: just company.
-- Lines have a personality per kind of mascot (rabbit, cat), and a mage's mascot
-- reacts to magic, with a little magic of its own as the bond grows.

local _, KT = ...
local L, D = KT.L, KT.Data
local Ma = {}
KT.Mascot = Ma

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

-- kind of mascot, from words in its name (EN / FR)
-- (whole = true: whole words only, so "Achat" or "Caterpillar" don't count as cats).
-- The French words come from the auction house's cages and baskets ("Panier à chat
-- (Siamois)", "Cage de perroquet (Sénégal)"): the summoned pet's own name may differ.
D.MASCOT_KINDS = {
  { "rabbit", { "lapin", "rabbit", "lièvre", "hare" } },
  { "cat", { "cat", "kitten", "chat", "chaton", "siamese", "siamois", "bombay", "tabby", "tigré",
    "cornish", "cornouailles" }, whole = true },
  { "parrot", { "parrot", "perroquet", "macaw", "ara", "cockatiel", "calopsitte", "senegal", "sénégal" }, whole = true },
}
-- A mage's mascot reacts to magic: spells found by name (any rank, any language)
D.MASCOT_MAGIC_SPELLS = {
  blink = { 1953 }, polymorph = { 118 }, conjure = { 587, 5504 }, frostNova = { 122 },
  intellect = { 1459 }, evocation = { 12051 }, frostArmor = { 168, 7302 },
}
D.MASCOT_MAGIC_CD = 600    -- a reaction to your magic at most every 10 minutes
D.MASCOT_MEAL_CD  = 600
D.MASCOT_GAIN = {
  time     = { amount = 0.2, cap = 2 },   -- every 10 minutes together
  place    = { amount = 0.5, cap = 3 },   -- a new place discovered together
  cuddle   = { amount = 1,   cap = 3 },   -- /pet, /love... (every 15 minutes at most)
  campfire = { amount = 2,   cap = 2 },   -- sitting by a campfire together
  nap      = { amount = 1,   cap = 2 },   -- a nap together (/sleep)
  rain     = { amount = 1 },              -- the first rain together
}
D.MASCOT_IDLE_CD   = 600   -- an idle line at most every 10 minutes
D.MASCOT_CUDDLE_CD = 900
D.MASCOT_PLACE_CD  = 600   -- a line about a new place at most every 10 minutes
D.MASCOT_PLACE_MILESTONES = { [10] = true, [50] = true, [100] = true, [250] = true }

-- Lines: per kind, per moment. band: 1 low bond, 2 middle, 3 high (minBand/maxBand
-- limit a line); when: the usual Senses conditions.
local GRASS = { indoors = false, notBiomes = { city = true, desert = true, snow = true, undercity = true,
  forge = true, badlands = true, canyon = true, volcanic = true, wasteland = true, plague = true } }
local LINES = {
  rabbit = {
    idle = {
      { en = "{pet}'s nose twitches at full speed, investigating a smell you can't detect.",
        fr = "{pet} remue le nez à toute vitesse, en pleine enquête sur une odeur que vous ne sentez pas." },
      { en = "{pet} hops three times, stops dead, then looks at you as if nothing happened.",
        fr = "{pet} fait trois petits bonds, s'arrête net, puis vous regarde comme si de rien n'était." },
      { en = "{pet} stands up on its hind legs, ears straight up, alert to the slightest sound.",
        fr = "{pet} se dresse sur ses pattes arrière, les oreilles bien droites, à l'affût du moindre bruit." },
      { minBand = 3,
        en = "{pet} snuggles against your foot, as if it were the safest place in the world.",
        fr = "{pet} vient se blottir contre votre pied, comme si c'était l'endroit le plus sûr du monde." },
    },
    idleGrass = {
      { when = GRASS,
        en = "{pet} nibbles a blade of grass, looking very focused.",
        fr = "{pet} grignote un brin d'herbe, l'air très concentré." },
    },
    rain = {
      { en = "{pet} shakes its soaked ears and gives you a reproachful look.",
        fr = "{pet} secoue ses oreilles trempées et vous lance un regard plein de reproches." },
    },
    campfire = {
      { en = "{pet} curls up by the fire, and its eyelids slowly close.",
        fr = "{pet} s'installe près du feu, en boule, et ses paupières se ferment doucement." },
    },
    cuddle = {
      { maxBand = 2,
        en = "{pet} freezes under your hand... then relaxes, just a tiny bit.",
        fr = "{pet} se fige sous votre main... puis se détend, un tout petit peu." },
      { minBand = 3,
        en = "{pet} closes its eyes under your hand and lets out a tiny sigh of happiness.",
        fr = "{pet} ferme les yeux sous votre main et pousse un minuscule soupir de bonheur." },
    },
    newPlace = {
      { en = "{pet} discovers this new place by going round in circles, nose in the air.",
        fr = "{pet} découvre ce nouvel endroit en tournant en rond, le nez en l'air." },
    },
    nap = {
      { en = "{pet} curls up against you and falls asleep before you do.",
        fr = "{pet} se roule en boule tout contre vous et s'endort avant vous." },
    },
    danger = {
      { en = "At the slightest sound, {pet} thumps a foot and dashes to hide behind you.",
        fr = "Au moindre bruit, {pet} tape du pied par terre et file se cacher derrière vous." },
    },
  },

  -- Cats (drafts, 2026-11-12)
  cat = {
    idle = {
      { draft = true, when = { indoors = false },
        en = "{pet} sits down in the middle of the path and washes a paw, in no hurry at all.",
        fr = "{pet} s'assoit au milieu du chemin et se lave une patte, sans se presser le moins du monde." },
      { draft = true,
        en = "A small purr rises at your feet: {pet} is rubbing against your legs.",
        fr = "Un petit ronronnement monte à vos pieds : {pet} se frotte contre vos jambes." },
      { draft = true,
        en = "{pet} stares at a spot in thin air, the tip of its tail twitching, then loses interest.",
        fr = "{pet} fixe un point dans le vide, le bout de la queue qui frémit, puis s'en désintéresse." },
      { draft = true,
        en = "{pet} lets out a little meow, and waits, as if you were supposed to answer.",
        fr = "{pet} pousse un petit miaulement, et attend, comme si vous deviez répondre." },
      { draft = true, maxBand = 1,
        en = "{pet} follows you, but always a few steps away, as if by chance.",
        fr = "{pet} vous suit, mais toujours à quelques pas, comme par hasard." },
      { draft = true, minBand = 3,
        en = "{pet} blinks slowly at you. You blink back.",
        fr = "{pet} cligne lentement des yeux en vous regardant. Vous lui rendez son clin d'œil." },
      { draft = true,
        en = "{pet}'s whiskers point forward: a smell, somewhere, has caught its interest.",
        fr = "Les moustaches de {pet} se tendent vers l'avant : une odeur, quelque part, l'intrigue." },
      { draft = true,
        en = "{pet} brushes your hand with the tips of its whiskers, as if to check it's really you.",
        fr = "{pet} vous frôle la main du bout des moustaches, comme pour vérifier que c'est bien vous." },
      { draft = true, minBand = 2,
        en = "{pet} comes to sniff your hand, and you feel the cool of its little wet nose.",
        fr = "{pet} vient vous renifler la main, et vous sentez la fraîcheur de son petit nez humide." },
      { draft = true,
        en = "{pet} licks its side very thoroughly, then stops dead, the tip of its tongue still out.",
        fr = "{pet} se lèche consciencieusement le flanc, puis s'arrête net, le bout de la langue encore sorti." },
      { draft = true,
        en = "{pet} rubs a damp paw behind its ear, again and again, with absolute seriousness.",
        fr = "{pet} se passe une patte mouillée derrière l'oreille, encore et encore, avec un sérieux absolu." },
      { draft = true,
        en = "Without warning, {pet} shoots off like an arrow, races around you twice, then stops dead and licks a paw as if nothing happened.",
        fr = "Sans prévenir, {pet} part comme une flèche, fait deux fois le tour de vous à toute allure, puis s'arrête net et se lèche une patte comme si de rien n'était." },
    },
    idleGrass = {
      { draft = true, when = GRASS,
        en = "{pet} crouches in the grass, wiggles, and pounces... on nothing at all. Then it walks back to you with great dignity.",
        fr = "{pet} se tapit dans l'herbe, se trémousse, et bondit... sur rien du tout. Puis revient vers vous avec une grande dignité." },
    },
    rain = {
      { draft = true,
        en = "{pet} shakes one paw, then the other, with obvious indignation, and presses against your legs.",
        fr = "{pet} secoue une patte, puis l'autre, avec une indignation évidente, et se colle contre vos jambes." },
      { draft = true,
        en = "{pet} flattens its ears in the rain and gives you a look: this is clearly your fault.",
        fr = "{pet} couche les oreilles sous la pluie et vous lance un regard : c'est clairement de votre faute." },
    },
    -- a few minutes of rain, and it has just stopped
    afterRain = {
      { draft = true,
        en = "The rain has left puddles. {pet} stops at the edge of one and laps at the water with the tip of its little pink tongue.",
        fr = "La pluie a laissé des flaques. {pet} s'arrête au bord de l'une d'elles et lape l'eau du bout de sa petite langue rose." },
    },
    campfire = {
      { draft = true,
        en = "{pet} settles as close to the fire as it can and starts to purr. The crackle of the wood and the purring blend together.",
        fr = "{pet} s'installe aussi près du feu que possible et se met à ronronner. Le crépitement du bois et le ronronnement se mêlent." },
      { draft = true,
        en = "As soon as you sit down, {pet} settles on your lap, turns around once and starts to purr.",
        fr = "Dès que vous vous asseyez, {pet} vient s'installer sur vos genoux, tourne une fois sur place et se met à ronronner." },
    },
    -- you sit down (X key, /sit), away from a campfire
    sit = {
      { draft = true,
        en = "As soon as you sit down, {pet} settles on your lap, turns around once and starts to purr.",
        fr = "Dès que vous vous asseyez, {pet} vient s'installer sur vos genoux, tourne une fois sur place et se met à ronronner." },
    },
    -- back from AFK, after sitting down
    afkLap = {
      { draft = true,
        en = "When you come back, {pet} is asleep on your lap. You get up as gently as you can, but {pet} wakes, stretches, and follows you, yawning.",
        fr = "À votre retour, {pet} dort sur vos genoux. Vous vous levez le plus doucement possible, mais {pet} se réveille, s'étire, et vous suit en bâillant." },
    },
    cuddle = {
      { draft = true, maxBand = 1,
        en = "{pet} tolerates your hand for a moment... then steps away to wash, right at that spot.",
        fr = "{pet} tolère votre main un instant... puis s'écarte pour faire sa toilette, juste à cet endroit." },
      { draft = true, minBand = 2, maxBand = 2,
        en = "{pet} pushes its head against your palm, asking for more.",
        fr = "{pet} pousse sa tête contre votre paume pour en réclamer davantage." },
      { draft = true, minBand = 3,
        en = "{pet} rolls onto its back, purring loudly. You know better than to touch the belly.",
        fr = "{pet} se roule sur le dos en ronronnant fort. Vous savez qu'il ne faut pas toucher au ventre." },
    },
    newPlace = {
      { draft = true,
        en = "{pet} sniffs every corner of this new place, tail held high.",
        fr = "{pet} renifle chaque recoin de ce nouvel endroit, la queue bien droite." },
    },
    nap = {
      { draft = true,
        en = "{pet} kneads the spot beside you for a long while, turns around three times, and falls asleep against you.",
        fr = "{pet} fait longuement ses petits pains à côté de vous, tourne trois fois sur place, et s'endort contre vous." },
    },
    danger = {
      { draft = true,
        en = "{pet} puffs up, fur on end, and hisses from behind your legs.",
        fr = "{pet} se hérisse, le poil dressé, et crache derrière vos jambes." },
    },
    -- cold or freezing, outdoors: under your cloak if you wear one
    cold = {
      { draft = true, when = { cloak = true },
        en = "{pet} climbs up your leg, claws out, and curls up under your {cloak}. A small ball of warmth against you.",
        fr = "{pet} grimpe le long de votre jambe, toutes griffes dehors, et vient se blottir sous votre {cloak}. Une petite boule de chaleur contre vous." },
      { draft = true, when = { cloak = false },
        en = "{pet} climbs into your arms and curls up against you. You share a little warmth.",
        fr = "{pet} grimpe dans vos bras et se blottit contre vous. Vous partagez un peu de chaleur." },
    },
    -- you start eating meat, fish or cheese
    meal_meat = {
      { draft = true,
        en = "You toss a little piece of your {item} to {pet}, who catches it in midair.",
        fr = "Vous lancez un petit bout de votre {item} à {pet}, qui l'attrape au vol." },
    },
    meal_fish = {
      { draft = true,
        en = "At the smell of fish, {pet} is already at your feet, eyes wide. You give up a little piece of your {item}.",
        fr = "À l'odeur du poisson, {pet} est déjà à vos pieds, les yeux ronds. Vous lui cédez un petit morceau de votre {item}." },
    },
    meal_cheese = {
      { draft = true,
        en = "{pet} sniffs your {item} with very serious interest. You leave it a crumb, which vanishes at once.",
        fr = "{pet} renifle votre {item} avec un intérêt très sérieux. Vous lui en laissez une miette, qui disparaît aussitôt." },
    },
  },

  -- Parrots (drafts, 2026-11-12)
  parrot = {
    idle = {
      { draft = true,
        en = "{pet} preens its feathers one by one, with meticulous care.",
        fr = "{pet} se lisse les plumes une à une, avec une application méticuleuse." },
      { draft = true,
        en = "{pet} tilts its head one way, then the other, staring at you with one round eye.",
        fr = "{pet} penche la tête d'un côté, puis de l'autre, en vous fixant d'un œil rond." },
      { draft = true,
        en = "{pet} lets out a piercing shriek that makes you jump. Then falls silent, looking perfectly innocent.",
        fr = "{pet} pousse un cri perçant qui vous fait sursauter. Puis se tait, l'air parfaitement innocent." },
      { draft = true,
        en = "{pet} imitates the clink of the coins in your purse. Very convincing. A little too convincing.",
        fr = "{pet} imite le tintement des pièces dans votre bourse. Très ressemblant. Un peu trop." },
      { draft = true,
        en = "{pet} whistles three notes, stops, and waits for an answer.",
        fr = "{pet} siffle trois notes, s'arrête, et attend qu'on lui réponde." },
      { draft = true,
        en = "{pet} puffs up all its feathers at once, shakes, and is back to its normal size in an instant.",
        fr = "{pet} gonfle toutes ses plumes d'un coup, se secoue, et retrouve aussitôt sa taille normale." },
      { draft = true,
        en = "{pet} lets out a little laugh that sounds strangely like yours.",
        fr = "{pet} lâche un petit rire qui ressemble étrangement au vôtre." },
      { draft = true,
        en = "{pet} scratches its head with one foot, eye half closed, balanced on the other.",
        fr = "{pet} se gratte la tête avec une patte, l'œil mi-clos, en équilibre sur l'autre." },
      { draft = true,
        en = "{pet} clicks its beak, twice, as if to get your attention. Then pretends to look elsewhere.",
        fr = "{pet} fait claquer son bec, deux fois, comme pour attirer votre attention. Puis fait semblant de regarder ailleurs." },
      { draft = true, when = { indoors = false },
        en = "{pet} perfectly imitates the creak of a door. There's no door here.",
        fr = "{pet} imite à la perfection le grincement d'une porte. Il n'y a pas de porte ici." },
      { draft = true, when = { night = true },
        en = "{pet} draws closer to you and mutters softly, in a language you don't understand.",
        fr = "{pet} se rapproche de vous et marmonne tout bas, dans une langue que vous ne comprenez pas." },
      { draft = true, when = { crowd = { "lively", "crowded" } },
        en = "{pet} imitates the hubbub of the crowd, a little quieter.",
        fr = "{pet} imite le brouhaha de la foule, un ton plus bas." },
      { draft = true, maxBand = 1,
        en = "{pet} studies you with one eye, then the other, as if deciding whether you can be trusted.",
        fr = "{pet} vous observe d'un œil, puis de l'autre, comme pour décider si vous êtes digne de confiance." },
      { draft = true, maxBand = 1,
        en = "{pet} keeps its distance and comments on your every move with a short, sharp cry.",
        fr = "{pet} garde ses distances et commente chacun de vos gestes d'un petit cri sec." },
      { draft = true, minBand = 3,
        en = "{pet} lands on your shoulder and nibbles your ear, very gently.",
        fr = "{pet} se pose sur votre épaule et vous mordille l'oreille, très doucement." },
      { draft = true, minBand = 3,
        en = "{pet} repeats your name in a croaky voice. Well, something close to it.",
        fr = "{pet} répète votre nom d'une voix éraillée. Enfin, quelque chose qui y ressemble." },
      { draft = true, minBand = 3, when = { indoors = false },
        en = "{pet} brings you a twig and proudly drops it in your hand.",
        fr = "{pet} vous apporte une brindille et la dépose fièrement dans votre main." },
    },
    idleGrass = {
      { draft = true, when = { indoors = false, moving = true, notBiomes = GRASS.notBiomes },
        en = "{pet} lands in the grass and waddles along beside you, with very dignified steps.",
        fr = "{pet} se pose dans l'herbe et marche à côté de vous en se dandinant, d'un pas très digne." },
    },
    rain = {
      { draft = true,
        en = "In the rain, {pet} spreads its wings wide and lets itself get soaked, with obvious pleasure.",
        fr = "Sous la pluie, {pet} ouvre grand les ailes et se laisse tremper avec un plaisir évident." },
    },
    afterRain = {
      { draft = true,
        en = "The rain stops. {pet} shakes out every feather and gives you a thorough spraying.",
        fr = "La pluie s'arrête. {pet} se secoue de toutes ses plumes et vous asperge copieusement." },
    },
    cold = {
      { draft = true,
        en = "{pet} fluffs up its feathers until it looks like a ball, and huddles against your neck.",
        fr = "{pet} gonfle ses plumes jusqu'à ressembler à une boule, et se serre contre votre cou." },
    },
    sit = {
      { draft = true,
        en = "As soon as you sit down, {pet} lands on your knee and sets about smoothing your sleeve with the tip of its beak.",
        fr = "Dès que vous vous asseyez, {pet} se pose sur votre genou et entreprend de vous lisser la manche du bout du bec." },
    },
    afkLap = {
      { draft = true,
        en = "When you come back, you find {pet} on your shoulder, greeting you with a resounding \"Ha!\"",
        fr = "À votre retour, vous trouvez {pet} sur votre épaule, qui vous accueille d'un « Ah ! » retentissant." },
    },
    campfire = {
      { draft = true,
        en = "{pet} perches near the fire, fluffs up its feathers and half closes its eyes.",
        fr = "{pet} se perche près du feu, gonfle ses plumes et ferme les yeux à demi." },
      { draft = true,
        en = "{pet} imitates the crackle of the fire so well that you no longer know which of the two you're hearing.",
        fr = "{pet} imite le crépitement du feu, si bien que vous ne savez plus lequel des deux vous entendez." },
    },
    cuddle = {
      { draft = true, maxBand = 1,
        en = "{pet} lets you scratch its head for a second... then nips your finger, just for form.",
        fr = "{pet} se laisse gratter la tête une seconde... puis vous pince le doigt, pour la forme." },
      { draft = true, minBand = 2, maxBand = 2,
        en = "{pet} lowers its head under your hand so you'll scratch its neck.",
        fr = "{pet} baisse la tête sous votre main pour que vous lui grattiez la nuque." },
      { draft = true, minBand = 3,
        en = "{pet} closes its eyes while you scratch its head, with a small, satisfied click of its beak.",
        fr = "{pet} ferme les yeux pendant que vous lui grattez la tête, avec un petit claquement de bec satisfait." },
      { draft = true, minBand = 3,
        en = "{pet} gives you a little bow, wings half open, head low, asking for a scratch on the neck.",
        fr = "{pet} vous fait une petite révérence, ailes entrouvertes, la tête basse, pour réclamer une caresse sur la nuque." },
    },
    -- {place}: the place you're in (subzone, else zone)
    newPlace = {
      { draft = true,
        en = "{pet} circles over this new place, squawking, as if to announce your arrival.",
        fr = "{pet} fait un tour au-dessus de ce nouvel endroit en criant, comme pour annoncer votre arrivée." },
      { draft = true,
        en = "{pet} repeats \"{place}\" in a croaky voice, several times, as if to remember it.",
        fr = "{pet} répète « {place} » d'une voix éraillée, plusieurs fois, comme pour s'en souvenir." },
    },
    nap = {
      { draft = true,
        en = "{pet} perches close by, tucks its head under its wing and falls asleep before you.",
        fr = "{pet} se perche tout près, glisse la tête sous son aile et s'endort avant vous." },
    },
    danger = {
      { draft = true,
        en = "{pet} lets out a shrill alarm call and flies off to take cover.",
        fr = "{pet} pousse un cri d'alarme strident et s'envole se mettre à l'abri." },
      { draft = true,
        en = "{pet} perches on your shoulder and screams at the enemy with all its might.",
        fr = "{pet} se perche sur votre épaule et crie sur l'ennemi de toutes ses forces." },
    },
    meal_fruit = {
      { draft = true,
        en = "You hold out a piece of your {item} to {pet}, who takes it apart with the seriousness of a connoisseur.",
        fr = "Vous tendez un morceau de votre {item} à {pet}, qui le décortique avec un sérieux de connaisseur." },
    },
    meal_bread = {
      { draft = true,
        en = "{pet} accepts the crumb of your {item} that you hold out, and holds it delicately in one foot to nibble it.",
        fr = "{pet} accepte la miette de votre {item} que vous lui tendez, et la tient délicatement dans sa patte pour la grignoter." },
    },
  },
}

-- A mage's mascot: magic rubs off on it as the bond grows. These lines are added to
-- the usual ones (any = every mascot, family = by pet type, kind = cat...).
-- spell_<name>: right after you cast that spell (D.MASCOT_MAGIC_SPELLS).
-- notPetType: not for that family (3 = the flying ones already float).
local MAGE = {
  any = {
    spell_blink = {
      { draft = true,
        en = "You reappear a few yards away. {pet} takes a moment to find you, then hurries over.",
        fr = "Vous réapparaissez quelques mètres plus loin. {pet} met un instant à vous retrouver, puis vous rejoint en hâte." } },
    spell_polymorph = {
      { draft = true,
        en = "{pet} watches the sheep you just made with the deepest suspicion.",
        fr = "{pet} observe le mouton que vous venez de créer avec la plus grande méfiance." } },
    spell_conjure = {
      { draft = true,
        en = "{pet} comes up to what you just conjured, examines it for a long time, then decides it's of no interest.",
        fr = "{pet} s'approche de ce que vous venez d'invoquer, l'examine longuement, puis décide que ça ne l'intéresse pas." } },
    spell_frostNova = {
      { draft = true,
        en = "Frost bursts out around you. {pet} backs away in a hurry, then comes back, carefully.",
        fr = "Le givre jaillit autour de vous. {pet} recule précipitamment, puis revient, avec précaution." } },
    spell_intellect = {
      { draft = true,
        en = "A bluish glow wraps around you for a moment. {pet} draws closer to see that light up close.",
        fr = "Une lueur bleutée vous enveloppe un instant. {pet} se rapproche pour voir cette lumière de plus près." } },
    spell_evocation = {
      { draft = true,
        en = "During your evocation, {pet} stays perfectly still, watching you, without a sound.",
        fr = "Pendant votre évocation, {pet} reste immobile à vous regarder, sans un bruit." } },
    spell_frostArmor = {
      { draft = true,
        en = "A thin film of frost covers your armor. {pet} keeps its distance until it passes.",
        fr = "Une fine pellicule de givre couvre votre armure. {pet} garde ses distances, le temps que ça passe." } },
    idle = {
      { draft = true, minBand = 2,
        en = "For a moment, a fine arcane dust sparkles around {pet}, then fades.",
        fr = "Un instant, une fine poussière arcanique scintille autour de {pet}, puis se dissipe." },
      { draft = true, minBand = 2, notPetType = 3,
        en = "Did you imagine it, or did you just see {pet} levitate for a second?",
        fr = "Avez-vous halluciné, ou venez-vous de voir {pet} léviter pendant une seconde ?" },
      { draft = true, minBand = 3,
        en = "Now and then, a small blue spark floats around {pet} for a moment. You're no longer quite sure who put it there.",
        fr = "Parfois, une petite étincelle bleue flotte un instant autour de {pet}. Vous ne savez plus très bien qui l'a mise là." },
    },
    cuddle = {
      { draft = true, minBand = 3,
        en = "A small blue spark jumps between your hand and {pet}. Nobody flinches anymore.",
        fr = "Une petite étincelle bleue saute entre votre main et {pet}. Plus personne ne sursaute." } },
    campfire = {
      { draft = true, minBand = 3,
        en = "When {pet} comes near the fire, the flames take on a bluish tint. Or maybe you're imagining it.",
        fr = "Quand {pet} s'approche du feu, les flammes prennent une teinte bleutée. Ou peut-être que vous l'imaginez." } },
  },
  family = {
    [10] = { spell_frostNova = {
      { draft = true,
        en = "Frost crackles over {pet}. Let's hope nothing freezes inside.",
        fr = "Le givre craque sur {pet}. Pourvu que rien ne gèle à l'intérieur." } } },
    [3] = { spell_blink = {
      { draft = true,
        en = "You've barely vanished when {pet} joins you with a flap of its wings, as if you were playing hide-and-seek.",
        fr = "À peine avez-vous disparu que {pet} vous rejoint d'un coup d'aile, comme si vous jouiez à cache-cache." } } },
  },
  kind = {
    parrot = {
      spell_polymorph = {
        { draft = true,
          en = "{pet} imitates the sheep's bleat to perfection. The sheep looks puzzled.",
          fr = "{pet} imite le bêlement du mouton à la perfection. Le mouton semble perplexe." } },
      spell_intellect = {
        { draft = true,
          en = "{pet} repeats the last syllables of your incantation. Fortunately, nothing happens.",
          fr = "{pet} répète les dernières syllabes de votre incantation. Heureusement, rien ne se passe." } },
      spell_conjure = {
        { draft = true,
          en = "{pet} repeats the last syllables of your incantation. Fortunately, nothing happens.",
          fr = "{pet} répète les dernières syllabes de votre incantation. Heureusement, rien ne se passe." } },
      spell_frostNova = {
        { draft = true,
          en = "{pet} imitates the crackle of the frost. The effect is striking.",
          fr = "{pet} imite le craquement du givre. Le résultat est saisissant." } },
      spell_blink = {
        { draft = true,
          en = "Just as you vanish, {pet} lets out a very convincing \"Poof!\"",
          fr = "Au moment où vous disparaissez, {pet} lance un « Pouf ! » très convaincant." } },
    },
    cat = {
      spell_blink = {
        { draft = true,
          en = "You reappear a few yards away. {pet} blinks, looks at the spot where you were, then trots over to you, tail curled like a question mark.",
          fr = "Vous réapparaissez quelques mètres plus loin. {pet} cligne des yeux, regarde l'endroit où vous étiez, puis vous rejoint en trottinant, la queue en point d'interrogation." } },
      spell_polymorph = {
        { draft = true,
          en = "{pet} stares at the sheep you just made with a deeply worrying interest.",
          fr = "{pet} fixe le mouton que vous venez de créer avec un intérêt tout à fait inquiétant." } },
      spell_conjure = {
        { draft = true,
          en = "{pet} sniffs what you just conjured, sneezes, and walks away.",
          fr = "{pet} renifle ce que vous venez d'invoquer, éternue, et s'en va." } },
      spell_frostNova = {
        { draft = true,
          en = "{pet} shakes its paws one by one on the frosted ground, as if holding you personally responsible.",
          fr = "{pet} secoue les pattes une à une sur le sol givré, l'air de vous en tenir pour personnellement responsable." } },
      spell_intellect = {
        { draft = true,
          en = "The bluish light of your spell shines in {pet}'s eyes, and it follows it like prey.",
          fr = "La lumière bleutée de votre sort se reflète dans les yeux de {pet}, qui la suit du regard comme une proie." } },
      spell_evocation = {
        { draft = true,
          en = "During your evocation, {pet} sits facing you, eyes half closed, tail wrapped around its paws.",
          fr = "Pendant votre évocation, {pet} s'assoit en face de vous, les yeux mi-clos, la queue enroulée autour des pattes." } },
      spell_frostArmor = {
        { draft = true,
          en = "{pet} comes to rub against your legs, meets the frost on your armor, and backs off, shaking its whiskers.",
          fr = "{pet} vient se frotter contre vos jambes, rencontre le givre de votre armure, et recule en secouant les moustaches." } },
      idle = {
        { draft = true, minBand = 2,
          en = "When {pet} licks a paw, tiny sparks fall from it.",
          fr = "Quand {pet} se lèche une patte, de minuscules étincelles en tombent." },
        { draft = true, minBand = 3,
          en = "{pet}'s eyes glow with an arcane gleam for a moment, then go back to perfectly ordinary.",
          fr = "Les yeux de {pet} brillent un instant d'une lueur arcanique, puis redeviennent tout à fait ordinaires." },
      },
      cuddle = {
        { draft = true, minBand = 3,
          en = "Under your hand, {pet}'s fur crackles with tiny bluish sparks. You no longer notice, and neither does {pet}.",
          fr = "Sous votre main, le pelage de {pet} crépite de petites étincelles bleutées. Vous n'y faites plus attention, et {pet} non plus." } },
    },
  },
}
-- For any mascot, whatever it is (bird, cat, frog, clockwork, ghost...): nothing that
-- needs a body part it might not have. Nothing agrees with the mascot in French.
local GENERIC = {
  tierUp = {
    { en = "Your bond with {pet} has grown: {tier}.", fr = "Votre lien avec {pet} a grandi : {tier}." },
  },
  idle = {
    { en = "{pet} stays right by your side, as if that were its place.",
      fr = "{pet} reste tout près de vous, comme si c'était sa place." },
    { en = "{pet} stops for a moment to watch something you can't see, then comes back to you.",
      fr = "{pet} s'arrête un instant pour observer quelque chose que vous ne voyez pas, puis revient vers vous." },
    { en = "{pet} glances at you, as if to check you're still there.",
      fr = "{pet} vous lance un regard, comme pour vérifier que vous êtes toujours là." },
    { minBand = 3,
      en = "Without {pet} by your side, the road would feel much longer.",
      fr = "Sans {pet} à vos côtés, la route vous semblerait bien plus longue." },
  },
  newPlace = {
    { en = "{pet} discovers this new place with you, with boundless curiosity.",
      fr = "{pet} découvre ce nouvel endroit avec vous, avec une curiosité sans bornes." },
  },
  campfire = {
    { en = "{pet} settles by the fire, right next to you. The evening promises to be peaceful.",
      fr = "{pet} s'installe près du feu, tout près de vous. La soirée s'annonce paisible." },
  },
  nap = {
    { en = "{pet} stays close while you close your eyes, as if watching over your sleep.",
      fr = "{pet} reste près de vous pendant que vous fermez les yeux, comme pour veiller sur votre sommeil." },
  },
  cuddle = {
    { maxBand = 2,
      en = "{pet} takes your gesture with a little surprise, then seems to enjoy it.",
      fr = "{pet} accueille votre geste avec un peu de surprise, puis semble l'apprécier." },
    { minBand = 3,
      en = "{pet} answers your gesture with obvious joy.",
      fr = "{pet} répond à votre geste avec une joie évidente." },
  },
  rain = {
    { en = "The rain starts to fall, and {pet} draws closer to you.",
      fr = "La pluie se met à tomber, et {pet} se rapproche de vous." },
  },
  danger = {
    { en = "{pet} takes cover behind you until the danger passes.",
      fr = "{pet} se met à l'abri derrière vous en attendant que le danger passe." },
  },
}

-- By mascot family (the game's pet type): a few lines that only fit that family,
-- added to the lines for any mascot. 2 dragonkin, 3 flying, 4 undead, 5 critter,
-- 6 magic, 8 beast, 9 aquatic, 10 mechanical.
local FAMILY = {
  [2] = { idle = {
    { en = "{pet} spreads its little wings for a moment, then folds them back with care.",
      fr = "{pet} déploie un instant ses petites ailes, puis les replie avec soin." } } },
  [3] = { idle = {
    { en = "{pet} flutters around you, then comes back to settle close by.",
      fr = "{pet} volette autour de vous, puis revient se poser tout près." } } },
  [4] = { idle = {
    { en = "A strange chill comes off {pet}. You've stopped noticing it, almost.",
      fr = "Une fraîcheur étrange émane de {pet}. Vous n'y faites presque plus attention." } } },
  [5] = { idle = {
    { en = "{pet} investigates the ground at your feet with the utmost seriousness.",
      fr = "{pet} inspecte le sol à vos pieds avec le plus grand sérieux." } } },
  [6] = { idle = {
    { en = "A faint glow dances around {pet}, then fades.",
      fr = "Une faible lueur danse autour de {pet}, puis s'éteint." } } },
  [8] = { idle = {
    { en = "{pet} has a long stretch, then settles back down beside you.",
      fr = "{pet} s'étire longuement, puis revient s'installer près de vous." } } },
  [9] = { rain = {
    { en = "The rain seems to delight {pet}. At least someone is happy.",
      fr = "La pluie a l'air de ravir {pet}. Au moins, quelqu'un est content." } } },
  [10] = {
    idle = {
      { en = "A small clicking comes from {pet}, steady as clockwork.",
        fr = "Un petit cliquetis s'échappe de {pet}, régulier comme une horloge." } },
    rain = {
      { en = "{pet} creaks a little in the rain. Let's hope nothing rusts.",
        fr = "{pet} grince un peu sous la pluie. Pourvu que rien ne rouille." } },
  },
}

---------------------------------------------------------------------------
-- Records: one per character and per mascot (db.mascots)
---------------------------------------------------------------------------

local cur, curGUID -- the mascot that's out (its record) and its ID
local function CharKey() return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?") end
local function Today() return date("%Y-%m-%d") end
local function DB()
  local db = KT.GetDB()
  db.mascots = db.mascots or {}
  return db.mascots
end

local function Kind(name)
  local n = (name or ""):lower()
  -- a whole word: no letter right before or after it (accented letters count as letters)
  local function HasWord(word)
    local init = 1
    while true do
      local s, e = n:find(word, init, true)
      if not s then return false end
      local before, after = n:sub(s - 1, s - 1), n:sub(e + 1, e + 1)
      if s == 1 then before = "" end
      if not before:find("^[%w\128-\255]") and not after:find("^[%w\128-\255]") then return true end
      init = s + 1
    end
  end
  for _, k in ipairs(D.MASCOT_KINDS) do
    for _, w in ipairs(k[2]) do
      if k.whole then
        if HasWord(w) then return k[1] end
      elseif n:find(w, 1, true) then
        return k[1]
      end
    end
  end
  return nil
end

local function IsMage()
  local _, class = UnitClass("player")
  return class == "MAGE"
end

local function SpellName(id)
  if not id then return nil end
  if C_Spell and C_Spell.GetSpellName then
    local ok, n = pcall(C_Spell.GetSpellName, id)
    if ok and n then return n end
  end
  if GetSpellInfo then
    local ok, n = pcall(GetSpellInfo, id)
    if ok and n then return n end
  end
  return nil
end

-- the spell you just cast, as a magic event (blink, polymorph...), or nil
local magicNames
local function MagicEvent(spellID)
  if not magicNames or not next(magicNames) then
    magicNames = {}
    for ev, ids in pairs(D.MASCOT_MAGIC_SPELLS) do
      for _, id in ipairs(ids) do
        local n = SpellName(id)
        if n then magicNames[n] = ev end
      end
    end
  end
  local n = SpellName(spellID)
  return n and magicNames[n]
end

function Ma.TierIndex(aff)
  local idx = 1
  for i, min in ipairs(D.TIERS) do if (aff or 0) >= min then idx = i end end
  return idx
end
function Ma.Band(rec)
  local b = 1
  for i, min in ipairs(D.BANDS) do if (rec.affection or 0) >= min then b = i end end
  return b
end
function Ma.TierName(idx) return L.MASCOT_TIERS[idx] or "?" end
function Ma.TierDesc(idx) return L.MASCOT_TIER_DESC[idx] or "" end
function Ma.Name(rec) return rec and (rec.customName or rec.name) or "?" end
function Ma.Current() return cur end
-- this character's mascots (for the tab: the others)
function Ma.Records()
  local out, prefix = {}, CharKey() .. ":"
  for key, rec in pairs(DB()) do
    if key:sub(1, #prefix) == prefix then out[#out + 1] = rec end
  end
  table.sort(out, function(a, b) return (a.affection or 0) > (b.affection or 0) end)
  return out
end

local function Info(guid)
  if not (C_PetJournal and C_PetJournal.GetPetInfoByPetID) then return nil end
  local ok, speciesID, customName, level, _, _, displayID, _, name, icon, petType, creatureID =
    pcall(C_PetJournal.GetPetInfoByPetID, guid)
  if not ok or not name then return nil end
  return { speciesID = speciesID, customName = (customName ~= "" and customName) or nil, level = level,
    displayID = displayID, name = name, icon = icon, petType = petType, creatureID = creatureID }
end

local function Record(guid, info)
  local key = CharKey() .. ":" .. guid
  local db = DB()
  local rec = db[key]
  if not rec then
    rec = { key = key, guid = guid, created = time(), affection = 0, bestTier = 1, cd = {},
      daily = { date = Today(), gains = {} }, memories = {}, firsts = {},
      stats = { minutes = 0, outings = 0, places = 0, cuddles = 0, campfires = 0, naps = 0 } }
    db[key] = rec
  end
  rec.name, rec.customName, rec.speciesID = info.name, info.customName, info.speciesID
  rec.displayID, rec.creatureID, rec.level = info.displayID, info.creatureID, info.level
  rec.kind = Kind(info.name)
  rec.petType = info.petType
  return rec
end

local function Ready(rec, key, seconds) return time() - (rec.cd[key] or 0) >= (seconds or 0) end
local function Mark(rec, key) rec.cd[key] = time() end

local function AddMemory(rec, key, vars)
  rec.memories[#rec.memories + 1] = { t = time(), key = key, vars = vars or {} }
end
local function FirstMemory(rec, key, vars)
  if rec.firsts[key] then return end
  rec.firsts[key] = true
  AddMemory(rec, key, vars)
end

function Ma.MemoryText(m, rec)
  local text = L.MASCOT_MEMORY[m.key] or m.key
  local vars = {}
  for k, v in pairs(m.vars or {}) do vars[k] = v end
  vars.pet = vars.pet or Ma.Name(rec)
  if vars.tierIndex then vars.tier = Ma.TierName(vars.tierIndex) end
  return (KT.G(text):gsub("{(%w+)}", function(k) return vars[k] and tostring(vars[k]) or ("{" .. k .. "}") end))
end

---------------------------------------------------------------------------
-- Lines and the bond
---------------------------------------------------------------------------

local function Say(event, vars, important)
  if not cur or not KT.ModuleOn("mascot") then return false end
  local db = KT.GetDB()
  if not important and (db.settings.chatty or 2) == 0 then return false end
  -- a mascot with its own personality (rabbit, cat) speaks its own lines; any other one
  -- gets the lines of its family and the lines for any mascot
  local list = {}
  local function Add(src) for _, l in ipairs(src or {}) do list[#list + 1] = l end end
  local own = cur.kind and LINES[cur.kind] and LINES[cur.kind][event]
  if own then
    Add(own)
  else
    local fam = FAMILY[cur.petType or 0]
    Add(fam and fam[event])
    Add(GENERIC[event])
  end
  -- a mage's mascot: magic lines on top
  if IsMage() then
    Add(MAGE.any[event])
    local mf = MAGE.family[cur.petType or 0]
    Add(mf and mf[event])
    local mk = cur.kind and MAGE.kind[cur.kind]
    Add(mk and mk[event])
  end
  if #list == 0 then return false end
  local band = Ma.Band(cur)
  local testing = KT.Senses and KT.Senses.Testing and KT.Senses.Testing()
  local ctx
  local fits = {}
  for _, line in ipairs(list) do
    if band >= (line.minBand or 1) and band <= (line.maxBand or 3)
      and (not line.draft or testing) and line.notPetType ~= cur.petType
      and (not (line.en or ""):find("{place}", 1, true) or (vars and vars.place)) then
      local ok = true
      if line.when and KT.Senses and KT.Senses.Check then
        if not ctx then
          local okC, c = pcall(KT.Senses.Context)
          ctx = okC and c or {}
        end
        ok = KT.Senses.Check(line.when, ctx)
      end
      if ok then fits[#fits + 1] = line end
    end
  end
  if #fits == 0 then return false end
  local line = fits[math.random(#fits)]
  local fr = KT.CurrentLanguage and KT.CurrentLanguage() == "fr"
  vars = vars or {}
  vars.pet = Ma.Name(cur)
  if ctx and ctx.cloak then vars.cloak = vars.cloak or ctx.cloak end
  KT.NarrateText("mascot", "mascot:" .. event, fr and line.fr or line.en, vars, important)
  return true
end

local function Gain(rec, src)
  local rule = D.MASCOT_GAIN[src] or {}
  local today = Today()
  if rec.daily.date ~= today then rec.daily = { date = today, gains = {} } end
  local room = rule.cap and (rule.cap - (rec.daily.gains[src] or 0)) or math.huge
  local amount = math.min(rule.amount or 0, room, 100 - rec.affection)
  if amount <= 0 then return 0 end
  rec.affection = rec.affection + amount
  rec.daily.gains[src] = (rec.daily.gains[src] or 0) + amount
  local idx = Ma.TierIndex(math.floor(rec.affection))
  if idx > (rec.bestTier or 1) then
    rec.bestTier = idx
    AddMemory(rec, "tier", { tierIndex = idx })
    Say("tierUp", { tier = Ma.TierName(idx) }, true)
  end
  if KT.RefreshPanel then KT.RefreshPanel() end
  return amount
end

---------------------------------------------------------------------------
-- What happens while your mascot is out
---------------------------------------------------------------------------

local lastPlaces, wasSeated, wasNapping, wasRain, minuteAcc, lastTick
local wasSit, wasCold, wasEating, wasAFK, afkOnLap, rainSince, rainEnded

local function PlaceCount()
  if not (KT.Discovery and KT.Discovery.Counts) then return nil end
  local ok, c = pcall(KT.Discovery.Counts)
  if not ok or not c then return nil end
  return (c.zones or 0) + (c.subzones or 0) + (c.spots or 0)
end

local function OnSummon(guid)
  local info = Info(guid)
  if not info then cur, curGUID = nil, nil return end
  cur, curGUID = Record(guid, info), guid
  cur.stats.outings = cur.stats.outings + 1
  cur.lastSeen = time()
  local zone = GetRealZoneText()
  FirstMemory(cur, "met", { zone = (zone and zone ~= "") and zone or "Azeroth" })
  lastPlaces = PlaceCount()
  wasSeated, wasNapping, wasRain = nil, nil, nil
  wasSit, wasCold, wasEating, wasAFK, afkOnLap, rainSince, rainEnded = nil, nil, nil, nil, nil, nil, nil
  if KT.RefreshPanel then KT.RefreshPanel() end
end

local function Check()
  if not (C_PetJournal and C_PetJournal.GetSummonedPetGUID) then return end
  local ok, guid = pcall(C_PetJournal.GetSummonedPetGUID)
  guid = ok and guid or nil
  if guid ~= curGUID then
    if guid then OnSummon(guid) else cur, curGUID = nil, nil end
    if KT.RefreshPanel then KT.RefreshPanel() end
  end
end

local function Tick()
  Check()
  if not cur or not KT.ModuleOn("mascot") then return end
  local now = time()
  local dt = lastTick and math.min(now - lastTick, 30) or 0
  lastTick = now
  local El = KT.Elements

  -- away (AFK) while sitting: your mascot may have curled up on your lap
  local afk = UnitIsAFK and UnitIsAFK("player") and true or false
  if afk then
    if El and El.Sitting and El.Sitting() then afkOnLap = true end
  elseif wasAFK then
    if afkOnLap and Ready(cur, "afkLap", 1800) then
      if Say("afkLap", nil, true) then Mark(cur, "afkLap") end
    end
    afkOnLap = nil
  end
  wasAFK = afk

  if UnitIsDeadOrGhost("player") or afk then return end

  -- time together: a minute at a time, a little bond every 10 minutes
  minuteAcc = (minuteAcc or 0) + dt
  while minuteAcc >= 60 do
    minuteAcc = minuteAcc - 60
    cur.stats.minutes = cur.stats.minutes + 1
    if cur.stats.minutes % 10 == 0 then Gain(cur, "time") end
  end
  cur.lastSeen = now

  local okE, env = pcall(KT.World.Snapshot)
  env = okE and env or {}

  -- a new place discovered together
  local places = PlaceCount()
  if places and lastPlaces and places > lastPlaces then
    cur.stats.places = cur.stats.places + (places - lastPlaces)
    Gain(cur, "place")
    if D.MASCOT_PLACE_MILESTONES[cur.stats.places] then AddMemory(cur, "places", { count = cur.stats.places }) end
    if Ready(cur, "place", D.MASCOT_PLACE_CD) and KT.LineGapOK() then
      local sub, zone = GetSubZoneText(), GetRealZoneText()
      local place = (sub and sub ~= "") and sub or zone
      if Say("newPlace", { place = (place and place ~= "") and place or nil }) then Mark(cur, "place") end
    end
  end
  lastPlaces = places or lastPlaces

  -- sitting by a campfire together
  if env.seatedAtFire and not wasSeated then
    cur.stats.campfires = cur.stats.campfires + 1
    FirstMemory(cur, "firstCampfire")
    if Ready(cur, "campfire", 3000) then
      Mark(cur, "campfire")
      Gain(cur, "campfire")
      Say("campfire")
    end
  end
  wasSeated = env.seatedAtFire

  -- a nap together
  local napping = KT.Elements and KT.Elements.Napping and KT.Elements.Napping()
  if napping and not wasNapping then
    cur.stats.naps = cur.stats.naps + 1
    FirstMemory(cur, "firstNap")
    if Ready(cur, "nap", 3000) then
      Mark(cur, "nap")
      Gain(cur, "nap")
      Say("nap", nil, true)
    end
  end
  wasNapping = napping

  -- rain, outdoors
  local rain = env.rain and not env.indoors
  if rain and not wasRain then
    if not cur.firsts.firstRain then
      FirstMemory(cur, "firstRain")
      Gain(cur, "rain")
    end
    if Ready(cur, "rain", 1800) and KT.LineGapOK() then
      if Say("rain") then Mark(cur, "rain") end
    end
  end
  wasRain = rain

  -- after the rain (puddles...): a few minutes of rain outdoors, then it stops (once the rain-stop line is past)
  if env.rain then
    rainSince = rainSince or now
    rainEnded = nil
  elseif rainSince then
    rainEnded = (now - rainSince >= 180) and now or nil
    rainSince = nil
  end
  if rainEnded and now - rainEnded >= 35 then
    if now - rainEnded > 240 then
      rainEnded = nil
    elseif not env.indoors and not env.combat and KT.LineGapOK() and Ready(cur, "afterRain", 1800) then
      if Say("afterRain") then Mark(cur, "afterRain") end
      rainEnded = nil
    end
  end

  -- sitting down (X key, /sit), away from a campfire
  local sitNow = El and El.Sitting and El.Sitting() and not napping or false
  if sitNow and not wasSit and not env.seatedAtFire and not env.combat
    and Ready(cur, "sit", 1800) and KT.LineGapOK() then
    if Say("sit") then Mark(cur, "sit") end
  end
  wasSit = sitNow

  -- cold or freezing, outdoors
  local es = El and El.GetState and El.GetState()
  local cold = es and (es.tempState == "cold" or es.tempState == "freezing") and not env.indoors or false
  if cold and not wasCold and not env.combat and Ready(cur, "cold", 1800) and KT.LineGapOK() then
    if Say("cold") then Mark(cur, "cold") end
  end
  wasCold = cold

  -- you start eating something your mascot likes (cat: meat, fish, cheese; parrot: fruit,
  -- bread): a little bit for it (not every meal), a few seconds after the meal's own line
  if env.eating and not wasEating and Ready(cur, "meal", D.MASCOT_MEAL_CD) and math.random() < 0.5 then
    local id, link
    if KT.LastFood then id, link = KT.LastFood(12) end -- (not "a and f()": it keeps only the id)
    local kind = id and KT.FoodKind and KT.FoodKind(id, link)
    local own = cur.kind and LINES[cur.kind]
    if link and kind and own and own["meal_" .. kind] then
      C_Timer.After(12, function()
        local ok, err = pcall(function()
          if not cur then return end
          local okE2, env2 = pcall(KT.World.Snapshot)
          if not (okE2 and env2 and env2.eating) or env2.combat then return end
          if Say("meal_" .. kind, { item = link }) then Mark(cur, "meal") end
        end)
        if not ok and KT.LogError then KT.LogError("Mascot meal", err) end
      end)
    end
  end
  wasEating = env.eating

  -- now and then, a little something
  if not env.combat and Ready(cur, "idle", D.MASCOT_IDLE_CD) and KT.LineGapOK() and math.random() < 0.12 then
    local event = (not env.indoors and math.random() < 0.35) and "idleGrass" or "idle"
    if Say(event) or (event ~= "idle" and Say("idle")) then Mark(cur, "idle") end
  end
end

-- Cuddles: /pet, /love... aimed at your mascot (its name in the emote)
local function OnEmote(text, sender, guid)
  if not cur or not text or not (KT.IsMe and KT.IsMe(sender, guid)) then return end
  if not text:find(Ma.Name(cur), 1, true) then return end
  local lower = text:lower()
  local affection = false
  for _, w in ipairs(D.AFFECTION_WORDS) do
    if lower:find(w, 1, true) then affection = true break end
  end
  if not affection then return end
  cur.stats.cuddles = cur.stats.cuddles + 1
  FirstMemory(cur, "firstCuddle")
  if Ready(cur, "cuddle", D.MASCOT_CUDDLE_CD) then
    Mark(cur, "cuddle")
    Gain(cur, "cuddle")
    Say("cuddle", nil, true)
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "COMPANION_UPDATE", "PET_JOURNAL_LIST_UPDATE", "PLAYER_REGEN_DISABLED",
  "CHAT_MSG_TEXT_EMOTE", "UNIT_SPELLCAST_SUCCEEDED" }) do
  pcall(f.RegisterEvent, f, ev)
end
f:SetScript("OnEvent", function(_, event, ...)
  local ok, err = pcall(function(...)
    if event == "PLAYER_LOGIN" then
      KT.GetDB().mascotProbe = nil -- (the first check's data, no longer needed)
      C_Timer.After(3, Check)
      C_Timer.NewTicker(5, function()
        local okT, errT = pcall(Tick)
        if not okT and KT.LogError then KT.LogError("Mascot tick", errT) end
      end)
    elseif event == "PLAYER_REGEN_DISABLED" then
      -- danger: your mascot reacts (not every fight)
      if cur and Ready(cur, "danger", 900) and math.random() < 0.5 then
        if Say("danger") then Mark(cur, "danger") end
      end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
      -- a mage's mascot reacts to your magic (its own timer, so idle moments stay)
      local unit, _, spellID = ...
      if unit ~= "player" or not cur or not IsMage() or not KT.ModuleOn("mascot") then return end
      local magic = MagicEvent(spellID)
      if magic and Ready(cur, "magic", D.MASCOT_MAGIC_CD) and KT.LineGapOK() then
        if Say("spell_" .. magic) then Mark(cur, "magic") end
      end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
      local text, sender = ...
      OnEmote(text, sender, (select(12, ...)))
    else
      C_Timer.After(0.5, Check)
    end
  end, ...)
  if not ok and KT.LogError then KT.LogError("Mascot " .. tostring(event), err) end
end)
