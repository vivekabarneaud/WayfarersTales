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
  { "owl", { "owl", "chouette", "hibou", "grand-duc" }, whole = true },
  { "frog", { "frog", "toad", "grenouille", "crapaud" }, whole = true },
  { "panda", { "panda" }, whole = true }, -- Bébé panda / Panda Cub (seen a lot, 2026-11-13)
  -- every chicken: Poulet des prairies, Coq d'Ancona, the clockwork chicken... (2026-11-13)
  { "chicken", { "chicken", "poulet", "poule", "hen", "coq", "rooster" }, whole = true },
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

  -- Owls (drafts, 2026-11-12): drowsy by day, wide awake at night
  owl = {
    idle = {
      { draft = true, when = { night = false },
        en = "In broad daylight, {pet} is half asleep, one eye closed, the other still keeping watch on you.",
        fr = "En plein jour, {pet} somnole à moitié, un œil fermé, l'autre qui vous surveille quand même." },
      { draft = true, when = { night = false },
        en = "{pet} blinks slowly, as if daylight were a personal ordeal.",
        fr = "{pet} cligne lentement des yeux, comme si la lumière du jour était une épreuve personnelle." },
      { draft = true, when = { night = true, indoors = false },
        en = "{pet} lets out a deep hoot that fades into the darkness.",
        fr = "{pet} lance un hululement grave qui se perd dans l'obscurité." },
      { draft = true, when = { night = true },
        en = "Now that night has come, there's nothing sleepy left about {pet}: its big round eyes search the darkness.",
        fr = "La nuit venue, {pet} n'a plus rien d'endormi : ses grands yeux ronds fouillent l'obscurité." },
      { draft = true,
        en = "{pet} turns its head almost all the way round to look at you. You can't get used to it.",
        fr = "{pet} tourne la tête presque complètement vers l'arrière pour vous regarder. Vous n'arrivez pas à vous y habituer." },
      { draft = true,
        en = "{pet} sways its head left and right, then up and down, to get a better fix on you.",
        fr = "{pet} balance la tête de gauche à droite, puis de haut en bas, pour mieux vous situer." },
      { draft = true,
        en = "{pet} lands right next to you. You didn't hear a thing.",
        fr = "{pet} se pose tout près de vous. Vous n'avez rien entendu arriver." },
      { draft = true,
        en = "{pet} ruffles its feathers, then smooths them back in a single shiver.",
        fr = "{pet} ébouriffe ses plumes, puis les remet en place d'un seul frisson." },
      { draft = true, maxBand = 1,
        en = "{pet} stares at you for a long time, without blinking, with a slightly intimidating gravity.",
        fr = "{pet} vous fixe longuement, sans ciller, avec une gravité un peu intimidante." },
      { draft = true, minBand = 3,
        en = "{pet} lands on your arm and rubs its head against your cheek, very gently.",
        fr = "{pet} se pose sur votre bras et frotte sa tête contre votre joue, tout doucement." },
    },
    idleGrass = {
      { draft = true, when = GRASS,
        en = "{pet} snaps its head toward the grass, motionless, listening to a sound you can't hear.",
        fr = "{pet} tourne brusquement la tête vers l'herbe, immobile, à l'écoute d'un bruit que vous n'entendez pas." },
    },
    rain = {
      { draft = true,
        en = "{pet} hunches its head into its shoulders in the rain and gives you a look heavy with reproach.",
        fr = "{pet} rentre la tête dans les épaules sous la pluie et vous lance un regard lourd de reproches." },
    },
    afterRain = {
      { draft = true,
        en = "The rain stops. {pet} shakes itself, and a little shower of drops falls around you.",
        fr = "La pluie cesse. {pet} se secoue, et une petite pluie de gouttes retombe autour de vous." },
    },
    cold = {
      { draft = true,
        en = "{pet} fluffs up its feathers until it's twice its size, and huddles against you.",
        fr = "{pet} gonfle ses plumes au point de doubler de volume, et se serre contre vous." },
    },
    sit = {
      { draft = true,
        en = "As soon as you sit down, {pet} lands on your knee, closes its eyes and doesn't move again.",
        fr = "Dès que vous vous asseyez, {pet} se pose sur votre genou, ferme les yeux et ne bouge plus." },
    },
    afkLap = {
      { draft = true,
        en = "When you come back, {pet} is asleep on your shoulder, head tucked into its feathers. You get up very gently.",
        fr = "À votre retour, {pet} dort sur votre épaule, la tête rentrée dans les plumes. Vous vous levez tout doucement." },
    },
    campfire = {
      { draft = true,
        en = "{pet} perches near the fire; the flames dance in its big round eyes.",
        fr = "{pet} se perche près du feu ; les flammes se reflètent dans ses grands yeux ronds." },
    },
    cuddle = {
      { draft = true, maxBand = 1,
        en = "{pet} lets your hand come closer... then clacks its beak, to let you know that's enough.",
        fr = "{pet} vous laisse approcher la main... puis claque du bec, pour vous signaler que ça suffit." },
      { draft = true, minBand = 2, maxBand = 2,
        en = "{pet} tilts its head so you'll scratch the top of it.",
        fr = "{pet} incline la tête pour que vous lui grattiez le dessus du crâne." },
      { draft = true, minBand = 3,
        en = "{pet} closes its eyes under your fingers and lets out a very soft little hoot.",
        fr = "{pet} ferme les yeux sous vos doigts et pousse un petit hululement très doux." },
    },
    newPlace = {
      { draft = true,
        en = "{pet} studies this new place by turning its head every which way, without moving the rest of its body.",
        fr = "{pet} observe ce nouvel endroit en tournant la tête dans tous les sens, sans bouger le reste du corps." },
    },
    nap = {
      { draft = true,
        en = "{pet} perches close by, eyes half closed, as if to watch over your sleep.",
        fr = "{pet} se perche tout près, les yeux mi-clos, comme pour veiller sur votre sommeil." },
    },
    danger = {
      { draft = true,
        en = "{pet} spreads its wings wide and clacks its beak, every feather on end.",
        fr = "{pet} déploie grand les ailes et claque du bec, toutes plumes hérissées." },
    },
    meal_meat = {
      { draft = true,
        en = "You hold out a piece of your {item} to {pet}, who swallows it whole.",
        fr = "Vous tendez un morceau de votre {item} à {pet}, qui l'avale tout rond." },
    },
  },

  -- Frogs (drafts, 2026-11-12)
  frog = {
    idle = {
      { draft = true,
        en = "{pet} puffs out its throat and lets out a loud croak. Then a second one, in case you missed the first.",
        fr = "{pet} gonfle sa gorge et lâche un coassement sonore. Puis un deuxième, au cas où vous n'auriez pas entendu le premier." },
      { draft = true,
        en = "{pet} stays perfectly still... then flicks out its tongue, so fast you don't have time to see what it caught.",
        fr = "{pet} reste parfaitement immobile... puis projette sa langue d'un coup, si vite que vous n'avez pas le temps de voir ce qu'elle a attrapé." },
      { draft = true, when = { moving = true },
        en = "{pet} follows you in little hops, with a soft \"plop\" at every landing.",
        fr = "{pet} vous suit par petits bonds, avec un léger « ploc » à chaque atterrissage." },
      { draft = true,
        en = "When {pet} swallows, its eyes sink into its head for a moment. It's fascinating, and a little unsettling.",
        fr = "Quand {pet} avale, ses yeux s'enfoncent un instant dans sa tête. C'est fascinant, et un peu dérangeant." },
      { draft = true,
        en = "If not for the steady beat of its throat, you could mistake {pet} for a pebble.",
        fr = "Sans le battement régulier de sa gorge, on pourrait prendre {pet} pour un caillou." },
      { draft = true, maxBand = 1,
        en = "{pet} watches you from a safe distance, legs folded, ready to leap.",
        fr = "{pet} vous observe à bonne distance, les pattes repliées, prêtes à bondir." },
      { draft = true, minBand = 3,
        en = "{pet} hops onto your foot and settles there, as if it were the best perch in the world.",
        fr = "{pet} saute sur votre pied et s'y installe, comme si c'était le meilleur perchoir du monde." },
      { draft = true, when = { swimming = true },
        en = "You swim, and {pet} swims beside you, in its element at last.",
        fr = "Vous nagez, et {pet} nage à vos côtés, enfin dans son élément." },
    },
    idleGrass = {
      { draft = true, when = GRASS,
        en = "{pet} disappears into the grass. A moment of worry... then a little hop, right next to you.",
        fr = "{pet} disparaît dans l'herbe. Un instant d'inquiétude... puis un petit bond, juste à côté de vous." },
    },
    rain = {
      { draft = true,
        en = "The rain starts, and {pet} seems to come alive: little hops, croaks, all its energy back.",
        fr = "La pluie commence, et {pet} semble revivre : petits bonds, coassements, toute son énergie retrouvée." },
    },
    afterRain = {
      { draft = true,
        en = "The rain has left puddles, and {pet} jumps into the first one with a satisfied \"plop\".",
        fr = "La pluie a laissé des flaques, et {pet} saute dans la première venue avec un « ploc » satisfait." },
    },
    cold = {
      { draft = true,
        en = "In the cold, {pet} moves less and less. You offer it shelter in the hollow of your hands.",
        fr = "Avec le froid, {pet} bouge de moins en moins. Vous lui offrez un abri au creux de vos mains." },
    },
    sit = {
      { draft = true,
        en = "As soon as you sit down, {pet} climbs onto your knee and settles there. You feel its coolness through the cloth.",
        fr = "Dès que vous vous asseyez, {pet} grimpe sur votre genou et s'y installe. Vous sentez sa fraîcheur à travers le tissu." },
    },
    afkLap = {
      { draft = true,
        en = "When you come back, {pet} hasn't moved from your knee, not even an inch. When you get up, a little hop, and the road goes on.",
        fr = "À votre retour, {pet} n'a pas bougé de votre genou, pas même d'un millimètre. Quand vous vous levez, un petit bond, et la route reprend." },
    },
    campfire = {
      { draft = true,
        en = "{pet} approaches the fire carefully, then backs away and settles a little further off, well away from the flames.",
        fr = "{pet} s'approche du feu, prudemment, puis recule et s'installe un peu plus loin, à bonne distance des flammes." },
    },
    cuddle = {
      { draft = true, maxBand = 1,
        en = "{pet} lets you touch it with a fingertip... then hops out of reach.",
        fr = "{pet} se laisse toucher du bout du doigt... puis bondit hors de portée." },
      { draft = true, minBand = 2, maxBand = 2,
        en = "{pet} stays under your finger, throat pulsing, eyes half closed.",
        fr = "{pet} reste sous votre doigt, la gorge qui palpite, les yeux mi-clos." },
      { draft = true, minBand = 3,
        en = "{pet} lets out a very soft little croak when you stroke its back. You'd swear it was a purr.",
        fr = "{pet} lâche un petit coassement très doux quand vous lui caressez le dos. Vous jureriez que c'est un ronronnement." },
    },
    newPlace = {
      { draft = true,
        en = "{pet} explores this new place in big leaps, then comes back to you, throat beating fast.",
        fr = "{pet} explore ce nouvel endroit à grands bonds, puis revient vers vous, la gorge battant à toute vitesse." },
    },
    nap = {
      { draft = true,
        en = "{pet} snuggles against you, closes its eyes and stops moving. All you can hear now is your own breathing.",
        fr = "{pet} se blottit contre vous, ferme les yeux et ne bouge plus. On n'entend plus que votre respiration." },
    },
    danger = {
      { draft = true,
        en = "{pet} suddenly puffs up to twice its size, and looks at you as if that should be enough to scare the enemy away.",
        fr = "{pet} se gonfle d'un coup, deux fois sa taille, et vous regarde comme si c'était suffisant pour faire fuir l'ennemi." },
    },
  },
  -- The panda cub (2026-11-13): round, clumsy, always rolling over, black eye patches,
  -- thick fur that's coarser than it looks. Likes fruit (no bamboo in the game).
  -- French: "panda" is masculine (il, lui).
  panda = {
    idle = {
      { draft = true,
        en = "{pet} trips over its own paws, rolls over once, then sits up as if it had meant to.",
        fr = "{pet} trébuche sur ses propres pattes, fait une roulade, puis se rassoit comme si c'était fait exprès." },
      { draft = true,
        en = "{pet} sits down on its bottom, hind legs stretched out in front, and looks at you, very pleased with itself.",
        fr = "{pet} s'assoit sur son derrière, les pattes arrière tendues devant lui, et vous regarde, très content de lui." },
      { draft = true, when = { moving = true },
        en = "{pet} trots after you with its rolling gait, all round and in no hurry.",
        fr = "{pet} trottine derrière vous de sa démarche chaloupée, tout rond et sans se presser." },
      { draft = true,
        en = "{pet} scratches its ear with a hind paw, loses its balance and ends up on its back.",
        fr = "{pet} se gratte l'oreille avec une patte arrière, perd l'équilibre et finit sur le dos." },
      { draft = true, maxBand = 1,
        en = "{pet} watches you from behind its black eye patches, not yet sure what to make of you.",
        fr = "{pet} vous observe derrière ses taches noires, sans trop savoir encore quoi penser de vous." },
      { draft = true, minBand = 3, when = { still = true },
        en = "{pet} wraps both front paws around your leg and won't let go.",
        fr = "{pet} s'agrippe à votre jambe de ses deux pattes avant et ne veut plus la lâcher." },
    },
    idleGrass = {
      { draft = true, when = GRASS,
        en = "{pet} rolls in the grass, all four paws in the air, and gets up covered in bits of green.",
        fr = "{pet} se roule dans l'herbe, les quatre pattes en l'air, et se relève couvert de brins verts." },
    },
    rain = {
      { draft = true,
        en = "The rain starts. {pet} shakes its head, then decides it doesn't mind: its fur is thick.",
        fr = "La pluie commence. {pet} secoue la tête, puis décide que ça lui est égal : sa fourrure est épaisse." },
    },
    afterRain = {
      { draft = true,
        en = "{pet} has found a patch of mud. Its white fur is a lot less white now.",
        fr = "{pet} a trouvé un coin de boue. Sa fourrure blanche l'est beaucoup moins, maintenant." },
    },
    cold = {
      { draft = true,
        en = "In its thick fur, {pet} doesn't seem to mind the cold. It huddles against you anyway, in case you do.",
        fr = "Dans sa fourrure épaisse, {pet} ne semble pas craindre le froid. Il se blottit quand même contre vous, au cas où vous, vous auriez froid." },
    },
    sit = {
      { draft = true,
        en = "As soon as you sit down, {pet} climbs onto your lap, heavier than it looks, and settles there with a sigh.",
        fr = "Dès que vous vous asseyez, {pet} grimpe sur vos genoux, plus lourd qu'il n'en a l'air, et s'y installe avec un soupir." },
    },
    afkLap = {
      { draft = true,
        en = "When you come back, {pet} is asleep on your lap, on its back, paws in the air.",
        fr = "À votre retour, {pet} dort sur vos genoux, sur le dos, les pattes en l'air." },
    },
    campfire = {
      { draft = true,
        en = "{pet} sits by the fire, round as a ball, and its eyelids slowly droop.",
        fr = "{pet} s'assoit près du feu, rond comme une boule, et ses paupières tombent doucement." },
    },
    cuddle = {
      { draft = true, maxBand = 1,
        en = "{pet} lets you stroke it, then pushes your hand away with a paw, very gently.",
        fr = "{pet} se laisse caresser, puis repousse votre main d'un coup de patte, tout doucement." },
      { draft = true, minBand = 2, maxBand = 2,
        en = "{pet}'s fur is coarser than you'd think, and very warm underneath.",
        fr = "Le pelage de {pet} est plus rêche qu'on ne l'imagine, et tout chaud en dessous." },
      { draft = true, minBand = 3,
        en = "{pet} rolls onto its back so you can scratch its round belly.",
        fr = "{pet} se roule sur le dos pour que vous lui grattiez son ventre tout rond." },
    },
    newPlace = {
      { draft = true,
        en = "{pet} explores this new place at its own pace, sniffs everything, then sits down in the middle of the path to think it over.",
        fr = "{pet} explore ce nouvel endroit à son rythme, renifle tout, puis s'assoit au milieu du chemin pour réfléchir." },
    },
    nap = {
      { draft = true,
        en = "{pet} falls asleep before you, curled up against you, snoring very softly.",
        fr = "{pet} s'endort avant vous, roulé en boule contre vous, avec un tout petit ronflement." },
    },
    danger = {
      { draft = true,
        en = "{pet} hides behind your legs, and only its black ears stick out.",
        fr = "{pet} se cache derrière vos jambes, et seules ses oreilles noires dépassent." },
    },
    meal_fruit = {
      { draft = true,
        en = "{pet} holds a piece of your {item} in both paws and nibbles it very seriously.",
        fr = "{pet} tient un morceau de votre {item} entre ses deux pattes et le grignote très sérieusement." },
    },
  },
  -- Chickens (2026-11-13): every chicken shares these (Poulet des prairies, Coq d'Ancona,
  -- the clockwork chicken...). French: "poulet" is masculine (il, lui). Red comb seen on
  -- the Poulet des prairies. Likes bread (crumbs).
  -- notPetType = 10: not for a clockwork chicken (feathers, worms, sleep, eating...);
  -- notName: not for a rooster (brooding); onlyName: only for a rooster (crowing).
  chicken = {
    idle = {
      { draft = true,
        en = "{pet} pecks at the ground in quick little jabs, convinced there's treasure down there.",
        fr = "{pet} picore le sol à petits coups secs, persuadé d'y trouver un trésor." },
      { draft = true,
        en = "{pet} scratches the dirt with one foot, then the other, steps back and inspects the result.",
        fr = "{pet} gratte la terre d'une patte, puis de l'autre, recule d'un pas et inspecte le résultat." },
      { draft = true, when = { moving = true },
        en = "{pet} hurries after you, head bobbing back and forth with every step.",
        fr = "{pet} vous suit d'un pas pressé, la tête qui avance et recule à chaque enjambée." },
      { draft = true, notPetType = 10,
        en = "{pet} fluffs up its feathers, shakes from head to tail, and goes sleek again.",
        fr = "{pet} gonfle ses plumes, se secoue de la tête à la queue, et redevient tout lisse." },
      { draft = true, notPetType = 10,
        en = "{pet} lets out a string of little clucks, as if commenting on everything it sees.",
        fr = "{pet} pousse une série de petits gloussements, comme s'il commentait tout ce qu'il voit." },
      { draft = true, maxBand = 1,
        en = "{pet} looks at you with one eye, then the other, head tilted. It hasn't decided yet whether you can be trusted.",
        fr = "{pet} vous observe d'un œil, puis de l'autre, en penchant la tête. Il n'a pas encore décidé si vous étiez fiable." },
      { draft = true, minBand = 3, notPetType = 10, notName = { "coq", "rooster" }, when = { still = true },
        en = "{pet} settles at your feet and fluffs up its feathers, like a hen on her eggs.",
        fr = "{pet} s'installe à vos pieds et gonfle ses plumes, comme une poule qui couve." },
      { draft = true, notPetType = 10, when = { night = true },
        en = "It's night, and {pet} has only one idea: find a perch and sleep.",
        fr = "Il fait nuit, et {pet} n'a qu'une idée : trouver un perchoir et y dormir." },
    },
    idleGrass = {
      { draft = true, notPetType = 10, when = GRASS,
        en = "{pet} half-disappears into the tall grass; only its red comb sticks out.",
        fr = "{pet} disparaît à moitié dans l'herbe haute ; seule sa crête rouge dépasse." },
    },
    dawn = {
      { draft = true, onlyName = { "coq", "rooster" },
        en = "At dawn, {pet} draws itself up and lets out a cock-a-doodle-doo loud enough to wake the whole neighbourhood.",
        fr = "À l'aube, {pet} se dresse sur ses ergots et lance un cocorico à réveiller tout le voisinage." },
    },
    rain = {
      { draft = true,
        en = "The rain starts. {pet} pulls its head in and looks deeply offended.",
        fr = "La pluie commence. {pet} rentre la tête dans les épaules et prend un air profondément offensé." },
    },
    afterRain = {
      { draft = true, notPetType = 10,
        en = "{pet} pecks at the worms the rain brought out. For it, the shower was worth it.",
        fr = "{pet} picore les vers que la pluie a fait sortir. Pour lui, l'averse en valait la peine." },
    },
    cold = {
      { draft = true, notPetType = 10,
        en = "{pet} fluffs up every feather against the cold, round as a ball of yarn. You hold it close to warm it.",
        fr = "{pet} gonfle toutes ses plumes contre le froid, rond comme une pelote. Vous le prenez contre vous pour le réchauffer." },
    },
    sit = {
      { draft = true, notPetType = 10, notName = { "coq", "rooster" },
        en = "As soon as you sit down, {pet} settles against your leg as if brooding... nothing at all.",
        fr = "Dès que vous vous asseyez, {pet} se cale contre votre jambe et s'y installe pour couver… rien du tout." },
    },
    afkLap = {
      { draft = true, notPetType = 10,
        en = "When you come back, {pet} is asleep against you, head tucked under its wing.",
        fr = "À votre retour, {pet} dort contre vous, la tête sous l'aile." },
    },
    campfire = {
      { draft = true, notPetType = 10,
        en = "{pet} keeps well away from the fire. A chicken near a campfire: it doesn't like the sound of that.",
        fr = "{pet} se tient à bonne distance du feu. Un poulet près d'un feu de camp, ça ne lui dit rien qui vaille." },
    },
    cuddle = {
      { draft = true, maxBand = 1, notPetType = 10,
        en = "{pet} lets you brush its feathers, then walks three steps away, clucking indignantly.",
        fr = "{pet} se laisse effleurer, puis s'éloigne de trois pas en gloussant, vexé." },
      { draft = true, minBand = 2, maxBand = 2, notPetType = 10,
        en = "{pet} stays under your hand and makes a small, contented trill.",
        fr = "{pet} reste sous votre main et pousse un petit roucoulement satisfait." },
      { draft = true, minBand = 3,
        en = "{pet} crouches down as soon as you reach out, so you can stroke its back.",
        fr = "{pet} s'accroupit dès que vous tendez la main, pour que vous puissiez lui caresser le dos." },
    },
    newPlace = {
      { draft = true, notPetType = 10,
        en = "{pet} explores this new place, pecking at anything that sticks out, then comes back to you cackling.",
        fr = "{pet} explore ce nouvel endroit en picorant tout ce qui dépasse, puis revient vers vous en caquetant." },
    },
    nap = {
      { draft = true, notPetType = 10,
        en = "{pet} snuggles against you, head under its wing. Soon, not a single cluck.",
        fr = "{pet} se cale contre vous, la tête sous l'aile. Bientôt, plus un gloussement." },
    },
    danger = {
      { draft = true, notPetType = 10,
        en = "{pet} squawks in panic and flaps its wings in every direction. Not very discreet.",
        fr = "{pet} pousse des caquètements affolés et bat des ailes dans tous les sens. Pas très discret." },
    },
    meal_bread = {
      { draft = true, notPetType = 10,
        en = "You crumble a little of your {item} for {pet}, who pecks up every crumb at top speed.",
        fr = "Vous émiettez un peu de votre {item} pour {pet}, qui picore chaque miette à toute vitesse." },
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
    chicken = {
      spell_polymorph = {
        { draft = true,
          en = "{pet} looks the sheep up and down, as if to say it would never have let anyone do that to it.",
          fr = "{pet} toise le mouton, l'air de dire qu'il n'aurait jamais laissé personne lui faire ça." } },
    },
    panda = {
      spell_polymorph = {
        { draft = true,
          en = "{pet} looks at the sheep, then at you, then rolls onto its back. Apparently that's its answer to everything.",
          fr = "{pet} regarde le mouton, puis vous, puis se roule sur le dos. Apparemment, c'est sa réponse à tout." } },
    },
    frog = {
      spell_polymorph = {
        { draft = true,
          en = "{pet} hops a few careful steps away from you. Just in case.",
          fr = "{pet} s'éloigne prudemment de vous de quelques bonds. Juste au cas où." } },
      spell_frostNova = {
        { draft = true,
          en = "Frost bursts out around you; {pet} jumps back and gives you an icy look. Literally.",
          fr = "Le givre jaillit autour de vous ; {pet} saute en arrière et vous lance un regard glacial. Littéralement." } },
    },
    owl = {
      spell_evocation = {
        { draft = true,
          en = "During your evocation, {pet} watches you gravely, like an old master keeping an eye on a student.",
          fr = "Pendant votre évocation, {pet} vous observe gravement, comme un vieux maître qui surveille son élève." } },
      spell_intellect = {
        { draft = true,
          en = "The glow of your spell shines in {pet}'s eyes, and it nods slowly, with an approving look.",
          fr = "La lueur de votre sort se reflète dans les yeux de {pet}, qui hoche lentement la tête, l'air approbateur." } },
      spell_polymorph = {
        { draft = true,
          en = "{pet} stares at the sheep with a predator's interest. Better not to know what's going on in its head.",
          fr = "{pet} fixe le mouton avec un intérêt de prédateur. Mieux vaut ne pas savoir ce qui se passe dans sa tête." } },
    },
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

local MECHANICAL = 10 -- pet type of clockwork mascots

-- Does the mascot's name contain one of these words? (onlyName / notName on a line:
-- e.g. a rooster doesn't brood, only a rooster crows at dawn)
local function NameHas(words)
  local n = ((cur and cur.name) or ""):lower()
  for _, w in ipairs(words) do
    if n:find(w, 1, true) then return true end
  end
  return false
end

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
    -- a clockwork version of a mascot with a personality (the clockwork chicken) keeps
    -- its clicks and whirs too (its personality lines skip what a machine can't do)
    if cur.petType == MECHANICAL then Add(FAMILY[MECHANICAL] and FAMILY[MECHANICAL][event]) end
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
      and (not line.onlyName or NameHas(line.onlyName)) and not (line.notName and NameHas(line.notName))
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
local wasNight, dawnAt

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

  -- dawn, outdoors (a rooster crows): a few seconds after the dawn line itself
  local night = KT.World.IsNight()
  if wasNight and not night and not env.indoors and not IsInInstance() then dawnAt = now end
  wasNight = night
  if dawnAt and now - dawnAt >= 10 then
    if now - dawnAt > 120 then
      dawnAt = nil
    elseif not env.combat and KT.LineGapOK() then
      dawnAt = nil
      if Ready(cur, "dawn", 3600) and Say("dawn") then Mark(cur, "dawn") end
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
