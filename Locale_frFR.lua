-- Wayfarer's Tales - textes en français.
-- Remplace les textes anglais de Locale.lua quand la langue est le français.
-- Tout ce qui manque ici reste en anglais.
-- On ne connaît pas le sexe du familier : pas de "il/elle", et pas d'adjectifs
-- qui s'accordent avec lui (ravi/ravie...). Les objets sont introduits par
-- "votre {item}" pour éviter le/la.

local _, KT = ...
local L, M = {}, {}
KT.FR = { L = L, M = M }

L.TIERS = {
  "Nouvelle rencontre",
  "Compagnon",
  "Ami fidèle",
  "Grand ami",
  "Lien indéfectible",
  "Âmes sœurs",
}

L.TIER_DESC = {
  "Vous apprenez à vous connaître.",
  "Une belle complicité commence à naître.",
  "Vous avez déjà vécu de belles aventures.",
  "Votre complicité saute aux yeux.",
  "Vous êtes presque inséparables.",
  "Un lien exceptionnel.",
}

L.HAPPINESS = { "Malheureux", "Content", "Heureux" }

L.FOOD_KINDS = { meat = "viande", fish = "poisson", cheese = "fromage", bread = "pain", fungus = "champignons", fruit = "fruits" }
-- "Humeur du jour : Joueuse" (s'accorde avec "humeur")
L.MOODS = { playful = "Joueuse", sleepy = "Somnolente", cuddly = "Câline", curious = "Curieuse", hungry = "Gourmande" }

L.MEMORY = {
  met           = "Début de votre histoire : {zone}.",
  zone          = "Premier voyage ensemble : {zone}.",
  playerLevel   = "Niveau {level} atteint ensemble.",
  petLevel      = "{pet} a atteint le niveau {level}.",
  firstCuddle   = "Premier câlin.",
  firstFeed     = "Première friandise donnée de votre main.",
  firstMeal     = "Premier repas partagé.",
  firstCampfire = "Premier repos ensemble au coin du feu.",
  tier          = "Votre lien a grandi : {tier}.",
  loyalty       = "La loyauté a grandi : {loyalty}.",
  rename        = "{old} s'appelle désormais {pet}.",
  kills         = "{count} aventures ensemble.",
  reunion       = "Retrouvailles après {days} jours de séparation.",
  favorite      = "Nourriture préférée de {pet} découverte : {food} !",
  dislike       = "{pet} n'aime pas trop ça : {food}.",
  days          = "{days} jours ensemble.",
  anniversary   = "{years} an(s) ensemble !",
}

L.TT_SCORE      = "Affection : %d / 100"
L.TT_NEXT       = "Palier suivant : %s à %d"
L.TT_LOYALTY    = "Loyauté : %s"
L.TT_HAPPINESS  = "Bonheur : %s"
L.TT_TOGETHER   = "Temps passé ensemble : %s"
L.TT_STATS      = "%d aventures, %d repas partagés, %d feux de camp"
L.TT_MEAL       = "%s attend une bouchée de votre repas !"
L.TT_HINT       = "Cliquez ou tapez /wt pour en savoir plus."
L.TT_MOOD       = "Humeur du jour : %s"
L.TT_FAVORITE   = "Nourriture préférée : %s"
L.TT_DISLIKE    = "Pas fan de : %s"
L.TT_SECRET     = "??? (essayez différentes nourritures !)"

L.UI_TAB_COMPANION = "Compagnon"
L.UI_TAB_GUIDE     = "Guide"
L.UI_TAB_OPTIONS   = "Options"
L.UI_LEVEL         = "niveau"
L.UI_TOGETHER      = "Ensemble"
L.UI_MEMORIES      = "Souvenirs"
L.UI_OTHERS        = "Vos autres compagnons"
L.UI_STATS = "Temps passé ensemble : %s\nAventures : %d\nRepas donnés : %d\nRepas partagés : %d\nRepos au coin du feu : %d\nCâlins : %d"
L.UI_OPT_CHATTY    = "À quelle fréquence votre familier réagit-il ?"
L.UI_CHATTY = { [0] = "Grands moments", [1] = "Discret", [2] = "Normal", [3] = "Bavard" }
L.UI_CHATTY_DESC = {
  [0] = "Seulement les moments importants : nouveaux paliers, loyauté, repas partagés, repos au coin du feu...",
  [1] = "Votre familier réagit environ deux fois moins souvent.",
  [2] = "L'équilibre par défaut.",
  [3] = "Votre familier réagit à presque tout. Idéal pour tester !",
}
L.UI_OPT_MINIMAP  = "Afficher le bouton de la minicarte"
L.UI_OPT_HEART    = "Afficher le cœur à côté de l'icône de bonheur"
L.UI_OPT_DEBUG    = "Mode débogage (messages techniques dans le chat)"
L.UI_OPT_LABEL    = "Afficher « Wayfarer's Tales » devant les messages du familier"
L.UI_TAB_JOURNAL  = "Journal"
L.UI_MODULES      = "Modules"
L.UI_MOD_KINDRED  = "Compagnie du familier (Kindred)"
L.UI_KINDRED_OFF  = "Le module du familier est désactivé. Vous pouvez le réactiver dans l'onglet Options."
L.UI_JOURNAL_EMPTY = "Votre journal est vide pour l'instant. Chaque ligne de votre histoire sera écrite ici."
L.UI_JOURNAL_PAGE  = "Page %d / %d"
L.UI_JOURNAL_FLAGGED = "%d signalée(s)"
L.UI_JOURNAL_COPY  = "Rapport & idées"
L.UI_REPORT_IDEAS  = "--- Vos idées et remarques (écrivez en dessous, puis copiez tout) ---"
L.UI_JOURNAL_FLAG_TT = "Signalez cette ligne si elle vous a semblé fausse ou hors de propos (cliquez à nouveau pour annuler). Les lignes signalées vont dans le rapport."
L.UI_JOURNAL_COPY_HELP = "Ajoutez vos idées en bas si vous voulez, puis Ctrl+A et Ctrl+C pour copier, et collez le tout dans un message à l'équipe de l'addon."
L.UI_JOURNAL_NOFLAGS = "Aucune ligne signalée pour l'instant. Utilisez le bouton ! à côté d'une ligne du Journal, ou tapez /wt nope juste après une ligne bizarre."
L.CMD_NOPE       = "Signalée : %s"
L.CMD_NOPE_NONE  = "Rien à signaler pour l'instant."
L.UI_OPT_SOUND    = "Sons (la voix du familier, carillons des grands moments)"
L.UI_OPT_LANGUAGE = "Langue"
L.CMD_SOUND_TEST  = "Test des sons de votre %s (sons : %s) :"
L.UI_OPT_NOTE     = "Les messages de votre familier ne sont visibles que par vous. L'affection peut baisser un peu (emotes grossières, familier tombé au combat, longs séjours à l'écurie), mais jamais sous un palier déjà atteint."
L.UI_MINIMAP_CLICK = "Clic : ouvrir la fenêtre"
L.UI_MINIMAP_DRAG  = "Glisser : déplacer ce bouton"

L.GUIDE = table.concat({
  "|cffffd100Votre histoire|r",
  "Chaque familier de chasseur a son propre score d'affection, de 0 à 100. Il grandit quand vous prenez soin de votre familier et vivez des aventures ensemble. Tout est cosmétique et reste sur votre ordinateur.",
  "",
  "|cffffd100Paliers du lien|r",
  "0  Nouvelle rencontre\n20  Compagnon\n40  Ami fidèle\n60  Grand ami\n80  Lien indéfectible\n100  Âmes sœurs",
  "Les réactions de votre familier évoluent avec votre lien : timides au début, puis amicales (40+), puis dévouées (80+).",
  "",
  "|cffffd100Renforcer votre lien|r",
  "Votre familier ne vous dira jamais rien en toutes lettres : observez ses réactions dans le chat, elles vous signalent quand un moment vous attend.",
  "|cffff8fb1Câlins|r  /pet /hug /love /cuddle /kiss /soothe /comfort /praise /pat /tickle sur votre familier : +1 (une fois toutes les 15 min). Après un combat difficile, réconfortez-le juste après l'avoir ressuscité !",
  "|cffff8fb1Nourriture|r  +1 (une fois toutes les 10 min). Votre familier a une nourriture préférée secrète (+2) et une qu'il n'aime pas (rien). Essayez différentes choses pour les découvrir !",
  "|cffff8fb1Repas partagés|r  Parfois, quand vous vous asseyez pour manger, votre familier réclame une bouchée. Nourrissez-le dans les 2 minutes : +4 pour la même nourriture, +2 pour une autre.",
  "|cffff8fb1Demandes de câlins|r  De temps en temps, votre familier réclame de l'attention. /pet dans les 2 minutes : +2",
  "|cffff8fb1Feux de camp|r  Asseyez-vous au coin du feu avec votre familier : +2",
  "|cffff8fb1Friandises|r  Quand votre familier remarque de la nourriture que vous venez de ramasser, donnez-la-lui dans les 2 minutes : +2",
  "|cffff8fb1Célébrations|r  Quand votre familier gagne un niveau, félicitez-le dans les 2 minutes (/cheer /clap /applaud /bravo /woot) : +1",
  "|cffff8fb1Aventures|r  Combattre ensemble et simplement passer du temps ensemble rapportent un peu, petit à petit.",
  "|cffff8fb1Grands moments|r  Montées de niveau, paliers de loyauté, retrouvailles après une longue séparation et anniversaires.",
  "",
  "|cffffd100Emotes|r",
  "(Les commandes anglaises fonctionnent aussi sur un client français.)",
  "|cffff8fb1Joueuses|r  /dance /cheer /flex /silly /bounce /clap /laugh /giggle /joke : un familier timide reste perplexe, un ami se joint à vous (+0,5)",
  "|cffff8fb1Farfelues|r  /chicken /roar : essayez pour voir...",
  "|cffff8fb1Repos|r  /sleep /sit /kneel /yawn /tired",
  "|cffff8fb1Tristesse|r  /cry /sigh /mourn : un grand ami vient vous réconforter (+0,5)",
  "|cffff8fb1Salutations|r  /wave /hello /bow /salute /welcome",
  "|cffff8fb1Faim|r  /hungry /eat",
  "|cffff8fb1Grossières|r  /slap /rude /spit /insult /angry /punch /kick /shoo /threaten /glare : -1. Un /sorry dans les 10 minutes rend +0,5.",
  "Beaucoup de ces emotes provoquent aussi une réaction sans cibler votre familier.",
  "",
  "|cffffd100Chaque jour est différent|r",
  "Votre familier a une humeur du jour (joueuse, somnolente, câline, curieuse ou gourmande) qui change son comportement. Il remarque aussi les nouveaux lieux, les feux de camp, les poissons que vous pêchez, la nourriture que vous ramassez, la nuit, l'eau, les villes, et quand vous vous assoupissez (absence automatique).",
  "",
  "|cffffd100Baisses en douceur|r",
  "Les emotes grossières, un familier tombé au combat (-1) et les longs séjours à l'écurie (-1 par semaine) font un peu baisser l'affection. Jamais sous un palier déjà atteint.",
  "",
  "|cffffd100Commandes|r",
  "/wt  ouvrir cette fenêtre\n/wt nope  signaler la dernière ligne comme bizarre\n/wt status  résumé dans le chat\n/wt memories  vos souvenirs dans le chat\n/wt chatty 0-3  fréquence des réactions\n/wt sound  écouter les sons de votre familier\n/wt debug  messages techniques\n(/kt fonctionne toujours)",
}, "\n")

L.CMD_HELP = {
  "/wt - ouvrir la fenêtre Wayfarer's Tales",
  "/wt status - l'histoire de votre familier, dans le chat",
  "/wt memories - vos souvenirs ensemble",
  "/wt chatty 0-3 - fréquence des réactions : 0 = grands moments seulement, 1 = discret, 2 = normal (par défaut), 3 = bavard",
  "/wt debug - informations techniques (pour les tests)",
  "/wt nope - signaler la dernière ligne comme fausse ou bizarre",
  "/wt sound - écouter les sons de votre familier",
  "/wt guide, /wt journal, /wt options - ouvrir un onglet de la fenêtre",
  "/wt resetvisits - oublier les lieux visités et le repos des lignes (pour les tests)",
}
L.CMD_STATUS_HINT = "Tapez |cffffd100/wt help|r pour toutes les commandes."
L.CMD_NO_PET    = "Aucun familier de chasseur n'est invoqué pour le moment."
L.CMD_CHATTY    = "Fréquence des réactions réglée sur %d."
L.CMD_DEBUG     = "Mode débogage : %s"
L.CMD_NO_MEMORY = "Pas encore de souvenirs. Votre histoire ne fait que commencer !"
L.LOADED_FIRST  = "est installé ! Invoquez votre familier et cherchez le cœur à côté de son icône de bonheur. Tapez /wt pour ouvrir la fenêtre."
L.ERROR         = "a rencontré un problème (merci de le signaler) : %s"

---------------------------------------------------------------------------
-- Messages
---------------------------------------------------------------------------

M.newPet = {
  "Une nouvelle histoire commence : vous et {pet}.",
}
M.newPetHistory = {
  "L'histoire de {pet} commence ici. Votre loyauté en dit déjà long : vous commencez au palier {tier}.",
}
M.rename = {
  "{old} répondra désormais au nom de {pet}. Un nouveau chapitre commence !",
}
M.summon = {
  "{pet} s'ébroue et trottine jusqu'à vous.",
  "{pet} lève les yeux vers vous : l'aventure peut commencer.",
  "{pet} renifle l'air et s'installe à vos côtés.",
  "{pet} s'étire paresseusement, puis vous emboîte le pas.",
}
M.reunion = {
  "{pet} bondit vers vous, débordant de joie !",
  "{pet} tourne joyeusement autour de vous. Ça faisait longtemps !",
  "{pet} vous pousse la main du museau, comme pour demander : où étiez-vous ?",
}
M.stableReunion = {
  "{pet} revient de l'écurie, débordant de joie !",
  "{pet} sort de l'écurie en courant et file droit vers vous.",
}
M.stableMissed = {
  "Vous avez beaucoup manqué à {pet} pendant votre séparation.",
}
M.affection = {
  {
    "{pet} sursaute d'abord, puis se laisse caresser un peu.",
    "{pet} renifle prudemment votre main avant d'accepter la caresse.",
    "{pet} ne bouge plus, sur la réserve, mais ne se dérobe pas.",
    "{pet} se penche, juste un tout petit peu. C'est un début !",
  },
  {
    "{pet} se presse joyeusement contre votre main.",
    "{pet} ferme les yeux et savoure l'instant.",
    "{pet} grogne de contentement.",
    "{pet} vous donne un petit coup de tête pour en avoir plus.",
    "{pet} vous adresse un long regard plein de confiance.",
  },
  {
    "{pet} se blottit dans vos bras, en toute confiance.",
    "{pet} s'appuie contre vous avec un soupir de pur bonheur.",
    "{pet} vous rend votre câlin, comme pour dire : tu es ma personne préférée.",
    "{pet} se roule sur le dos pour réclamer des gratouilles sur le ventre.",
  },
}
M.playful = {
  {
    "{pet} vous observe avec méfiance, sans comprendre ce que vous faites.",
    "{pet} recule d'un pas. Est-ce bien normal ?",
    "{pet} fixe vos pitreries, profondément perplexe.",
  },
  {
    "{pet} sautille autour de vous pour participer !",
    "{pet} bondit joyeusement à vos côtés.",
    "{pet} pousse un petit grognement excité et se joint à la fête.",
  },
  {
    "{pet} se joint à vous avec enthousiasme, comme si vous aviez répété ensemble !",
    "{pet} tourbillonne avec vous, aux anges.",
    "{pet} esquisse une petite danse maladroite, très fièrement.",
  },
}
M.chicken = {
  {
    "Les yeux de {pet} se plissent. C'était... une proie ?",
    "{pet} vous regarde caqueter et recule lentement.",
  },
  {
    "{pet} commence à vous traquer pour jouer. Caquetez à vos risques et périls !",
    "{pet} se tapit, la queue frémissante, sur le point de bondir sur le poulet.",
  },
  {
    "{pet} vous saute dessus en douceur et joue le jeu du poulet.",
    "{pet} vous poursuit en rond. Le meilleur jeu du monde !",
  },
}
M.roar = {
  {
    "{pet} couche les oreilles en entendant votre rugissement.",
    "{pet} sursaute au bruit.",
  },
  {
    "{pet} vous répond par un rugissement plein de fierté !",
    "{pet} répond par un puissant rugissement d'approbation.",
  },
  {
    "{pet} rugit avec vous. Tout le pays sait que vous formez une meute.",
    "{pet} renverse la tête et rugit avec vous. Quel duo !",
  },
}
M.rest = {
  {
    "{pet} se couche à quelques pas et monte la garde.",
    "{pet} s'installe non loin, encore un peu sur ses gardes.",
  },
  {
    "{pet} se roule en boule à côté de vous.",
    "{pet} bâille à son tour et se couche à vos pieds.",
  },
  {
    "{pet} se blottit contre vous, au chaud et en sécurité.",
    "{pet} se pose contre vos genoux et s'endort aussitôt.",
  },
}
M.sad = {
  {
    "{pet} vous regarde, sans savoir quoi faire.",
    "{pet} vous observe de loin, les oreilles basses.",
  },
  {
    "{pet} s'approche et s'assoit tranquillement près de vous.",
    "{pet} pousse doucement votre main du museau.",
  },
  {
    "{pet} se serre contre vous et vous lèche la main. Vous n'êtes pas {seul|seule|seul·e}.",
    "{pet} ne vous quittera pas tant que vous n'irez pas mieux.",
  },
}
M.greet = {
  { "{pet} lève les yeux vers vous avec curiosité.", "{pet} cligne des yeux en vous regardant." },
  { "{pet} se redresse et vous salue à son tour.", "{pet} trottine vers vous pour dire bonjour." },
  { "{pet} vous accueille avec un petit bond de joie.", "{pet} accourt comme après des siècles d'absence." },
}
M.hungry = {
  "Le ventre de {pet} gargouille en signe d'approbation.",
  "{pet} vous regarde, puis regarde vos sacs. Message reçu ?",
  "{pet} se lèche les babines avec espoir.",
}
M.rude = {
  {
    "{pet} se recroqueville et recule.",
    "{pet} grogne nerveusement.",
  },
  {
    "{pet} couche les oreilles, l'air blessé.",
    "{pet} se détourne et boude.",
  },
  {
    "{pet} vous regarde avec de grands yeux tristes. Qu'est-ce que j'ai fait ?",
    "{pet} ne comprend pas, ça fait de la peine... mais reste à vos côtés.",
  },
}
M.sorryForgive = {
  {
    "{pet} hésite... puis revient lentement vers vous.",
    "{pet} garde ses distances, mais les oreilles se redressent.",
  },
  {
    "{pet} vous pardonne d'un petit coup de museau.",
    "{pet} renifle votre main et décide de vous pardonner.",
  },
  {
    "{pet} ne vous en a jamais vraiment voulu. Tout est pardonné.",
    "{pet} vous lèche la main comme si de rien n'était.",
  },
}
M.sorryNothing = {
  "{pet} ne sait pas pourquoi vous vous excusez, mais accepte une gratouille quand même.",
}
M.afkDoze = {
  { "Vous vous assoupissez. {pet} se couche non loin, un œil ouvert, pour monter la garde." },
  { "Vous vous assoupissez. {pet} se roule en boule à vos pieds." },
  { "Vous vous assoupissez. {pet} se blottit contre vous et s'endort à son tour." },
}
M.afkBack = {
  "Vous remuez. {pet} s'étire et bâille.",
  "{pet} dresse la tête à votre réveil. On y va ?",
}
M.afkBackLong = {
  { "{pet} n'a pas quitté les environs pendant votre absence." },
  { "{pet} a monté la garde pendant toute votre absence et se réjouit de votre retour." },
  { "{pet} n'a pas quitté vos côtés une seule seconde pendant votre absence." },
}
M.greetMorning = {
  "Bonjour ! {pet} s'étire et bâille : une nouvelle journée commence avec vous.",
  "{pet} vous accueille avec un câlin tout ensommeillé du matin.",
  "Une nouvelle journée commence, et {pet} a déjà envie d'aventure !",
  "{pet} est déjà debout et hume l'air du matin.",
  "{pet} s'étire du bout du nez au bout des pattes, puis vient vous dire bonjour.",
}
M.greetAfternoon = {
  "{pet} trottine vers vous pour vous saluer. Quel est le programme cet après-midi ?",
  "{pet} faisait une petite sieste, mais bondit pour vous accueillir.",
  "{pet} se redresse dès que vous arrivez.",
  "{pet} vous accueille joyeusement. En route pour l'après-midi ?",
  "{pet} surveillait le chemin en vous attendant.",
}
M.greetEvening = {
  "Bonsoir ! {pet} se réjouit de vous voir.",
  "{pet} vous accueille alors que le soir tombe.",
  "{pet} vient s'asseoir près de vous alors que la lumière décline.",
  "{pet} vous accueille doucement. Une soirée tranquille en vue ?",
  "{pet} se réjouit que la journée ne soit pas encore finie.",
}
M.greetNight = {
  "{pet} cligne des yeux d'un air ensommeillé. L'aventure, à cette heure-ci ?",
  "Une aventure nocturne ? {pet} est de la partie, bien sûr.",
  "{pet} bâille, puis vient vers vous quand même.",
  "{pet} reste tout près. La nuit est calme.",
  "{pet} ouvre un œil, vous voit, et se lève aussitôt.",
}
M.newZone = {
  "{pet} hume l'air de ce nouvel endroit : {zone}. Un nouveau chapitre de votre histoire !",
  "Premiers pas ensemble : {zone}. {pet} regarde partout, les yeux écarquillés.",
  "{zone} ! {pet} n'a jamais rien senti de pareil.",
}
M.playerLevel = {
  { "Niveau {level} ! {pet} observe la lueur autour de vous avec curiosité." },
  { "Niveau {level} ! {pet} bondit autour de vous pour fêter ça." },
  { "Niveau {level} ! {pet} déborde de fierté. Vous l'avez fait ensemble !" },
}
M.petLevel = { -- doit inviter à féliciter de lui-même (aucun conseil dans le chat)
  "{pet} gagne en puissance : niveau {level} ! Et vous jette des coups d'œil, en attente de vos applaudissements.",
  "{pet} atteint le niveau {level}, la tête haute, et guette vos acclamations du regard.",
  "Niveau {level} pour {pet} ! Un regard plein d'attente vers vous : ça mérite bien une petite fête, non ?",
}
M.feedFavoriteFirst = {
  "{pet} perd la tête devant votre {item} ! Nourriture préférée découverte : {food} !",
}
M.favoriteRevealed = {
  "{pet} semble aux anges. Nourriture préférée découverte : {food} !",
}
M.feedFavorite = {
  "{pet} dévore votre {item} avec une joie immense. Le meilleur !",
  "Les yeux de {pet} s'illuminent : {item} ! Le top !",
  "{pet} engloutit votre {item} en quelques secondes et vous regarde avec espoir pour en avoir encore.",
}
M.feedDislikeFirst = {
  "{pet} inspecte votre {item}... puis finit par manger, très à contrecœur. Pas fan de ça, visiblement : {food}.",
}
M.feedDislike = {
  "{pet} mange votre {item} sans le moindre enthousiasme.",
  "{pet} vous jette un regard. Encore ça ? ({food})",
}
M.lootFavorite = {
  "{pet} repère votre {item} et a du mal à contenir son excitation !",
  "{pet} n'a plus d'yeux que pour votre {item}.",
}
M.treatAsk = {
  "{pet} regarde votre {item}, puis vous, puis votre {item} à nouveau. Le message est clair.",
  "{pet} a remarqué votre {item} et ne vous quitte plus des yeux. C'est pour partager, non ?",
  "{pet} ne vous lâche plus d'une semelle, les yeux rivés sur votre {item}. Une petite friandise, peut-être ?",
}
M.treatAskFavorite = {
  "{pet} repère votre {item} et a du mal à contenir son excitation. Vous partagez, dites ?",
  "{pet} n'a plus d'yeux que pour votre {item}... et pour vous, qui pourriez partager.",
}
M.treatGiven = {
  "{pet} engloutit votre {item} en un clin d'œil. Meilleure. Friandise. Du monde.",
  "{pet} espérait que vous partagiez votre {item}, et vous l'avez fait !",
  "{pet} n'en revient pas : un partage immédiat !",
}
M.celebrated = {
  "{pet} se gonfle de fierté sous vos acclamations !",
  "{pet} se pavane, savourant les applaudissements.",
  "{pet} vous regarde avec des étoiles plein les yeux. Ce niveau, c'est aussi grâce à vous.",
}
M.mood_playful = { "{pet} déborde d'énergie aujourd'hui !" }
M.mood_sleepy  = { "{pet} bâille déjà beaucoup aujourd'hui." }
M.mood_cuddly  = { "{pet} a très envie de câlins aujourd'hui." }
M.mood_curious = { "{pet} s'intéresse à tout aujourd'hui." }
M.mood_hungry  = { "{pet} a un petit creux aujourd'hui." }
M.idleMood_playful = {
  "{pet} bondit sur une feuille qui tombe.",
  "{pet} file devant, puis revient en courant.",
}
M.idleMood_sleepy = {
  "{pet} bâille pour la troisième fois d'affilée.",
  "{pet} traîne des pattes, les yeux mi-clos.",
}
M.idleMood_cuddly = {
  "{pet} ne cesse de se frotter contre vous en marchant.",
  "{pet} ne vous lâche pas d'une semelle aujourd'hui.",
}
M.idleMood_curious = {
  "{pet} inspecte absolument tout sur le chemin.",
  "{pet} s'arrête pour examiner une pierre étrange.",
}
M.idleMood_hungry = {
  "{pet} n'arrête pas de lorgner vos sacs.",
  "{pet} vous regarde, puis vos sacs, puis vous à nouveau.",
}
M.modePassive    = { "{pet} se détend. Pas de combat pour l'instant.", "{pet} retrouve son calme." }
M.modeDefensive  = { "{pet} monte la garde à vos côtés.", "{pet} reste aux aguets pour vous protéger." }
M.modeAggressive = { "{pet} est d'humeur à se battre !", "{pet} brûle d'en découdre !" }
M.daysTogether = {
  "Déjà {days} jours ensemble ! {pet} a fait un sacré bout de chemin avec vous.",
}
M.anniversary = {
  "Un jour spécial : {years} an(s) depuis le début de votre histoire avec {pet} !",
}
M.otherEmote = {
  "{pet} vous regarde avec curiosité.",
  "{pet} vous observe, perplexe.",
}
M.attentionRequest = {
  {
    "{pet} s'approche timidement et renifle votre main.",
    "{pet} s'assoit un peu plus près que d'habitude en vous jetant des coups d'œil.",
  },
  {
    "{pet} pousse votre main du museau pour réclamer de l'attention.",
    "{pet} se couche à vos pieds et lève les yeux vers vous avec espoir.",
  },
  {
    "{pet} vous donne un petit coup de tête. Câlins. Maintenant. S'il vous plaît.",
    "{pet} se laisse tomber juste devant vous pour réclamer des câlins.",
  },
}
M.attentionAnswered = {
  {
    "{pet} accepte la caresse et semble se détendre pour la première fois.",
    "{pet} remue timidement la queue.",
  },
  {
    "{pet} frétille de joie. C'était exactement ce qu'il fallait !",
    "{pet} se presse contre votre main avec un soupir heureux.",
  },
  {
    "{pet} est au paradis. Vous vous connaissez si bien.",
    "{pet} gronde de pur bonheur.",
  },
}
M.attentionExpired = {
  "{pet} s'éloigne en reniflant le sol.",
}
M.comfort = {
  "{pet} se serre contre vous. Votre réconfort compte beaucoup après ce combat.",
  "{pet} pousse un petit soupir de soulagement à votre contact.",
}
M.feed = {
  "{pet} grignote joyeusement votre {item}.",
  "{pet} engloutit votre {item} en un rien de temps.",
  "{pet} mange votre {item}, puis lèche les dernières miettes.",
  "{pet} savoure votre {item} avec gratitude.",
}
M.lootFood = {
  "{pet} fixe votre {item} avec des yeux gourmands.",
  "{pet} renifle votre sac. Votre {item} sent bien bon...",
  "{pet} a remarqué votre {item}. Vraiment très remarqué.",
}
M.fishing = {
  "{pet} regarde votre {item} frétiller avec fascination.",
  "{pet} lorgne votre {item}. C'est pour partager ?",
  "{pet} se rapproche de votre {item}, le museau frémissant.",
}
M.cooking = {
  "L'odeur de votre {item} fait frémir le museau de {pet}.",
  "{pet} s'assoit très poliment à côté de votre {item}. Très, très poliment.",
}
M.mealRequest = {
  "{pet} s'assoit à côté de vous et fixe votre {item}. Une petite bouchée à partager ?",
  "{pet} vous tapote doucement le bras, les yeux rivés sur votre {item}.",
  "{pet} renifle avec espoir pendant que vous mangez votre {item}...",
}
M.mealSniff = {
  "{pet} s'approche de votre {item}... et recule aussitôt. Non merci.",
  "{pet} jette un œil à votre {item} et se détourne, l'air pas du tout impressionné.",
  "{pet} lance un regard méfiant à votre {item}, puis un regard franchement vexé.",
}
M.mealShared = {
  "Vous partagez votre {item} avec {pet}. Un repas, c'est meilleur à deux !",
  "{pet} savoure avec joie ce que vous avez partagé. Quel festin !",
}
M.mealOther = {
  "{pet} espérait un peu de votre {item}, mais ça fera très bien l'affaire !",
}
M.mealExpired = {
  "{pet} abandonne et se couche avec un petit soupir.",
}
M.campfireNear = {
  "{pet} dresse la tête. Un feu de camp, tout près !",
  "Le museau de {pet} se tourne vers l'odeur de fumée de bois.",
}
M.campfireRest = {
  "Vous vous installez au coin du feu avec {pet}. Ces moments calmes comptent.",
  "{pet} se roule en boule près du feu, au chaud et en paix.",
  "Le feu crépite doucement. {pet} se repose tout près de vous.",
}
M.campfireEnergized = {
  "{pet} s'étire après ce bon repos : en route pour l'aventure !",
  "{pet} déborde d'énergie et a hâte de la suite.",
  "{pet} se relève d'un bond. En avant !",
}
M.kill = {
  "{pet} s'ébroue après le combat. Beau travail d'équipe !",
  "{pet} vous lance un regard qui veut dire : on forme une sacrée équipe.",
}
M.death = {
  "{pet} est à terre... Repose-toi, cœur vaillant.",
  "{pet} a combattu avec bravoure, jusqu'au bout.",
}
M.revive = {
  "{pet} se relève, encore sous le choc. Un peu de réconfort serait le bienvenu.",
}
M.petHungry = {
  "Le ventre de {pet} gargouille bruyamment. Quelqu'un a faim.",
  "{pet} lorgne vos sacs. C'est l'heure du goûter ?",
}
M.idle = {
  {
    "{pet} renifle les alentours, en pleine exploration.",
    "{pet} garde un peu ses distances et vous observe.",
    "{pet} s'arrête pour se gratter l'oreille, puis se dépêche de vous rattraper.",
    "{pet} inspecte un buisson suspect.",
  },
  {
    "{pet} renifle une fleur avec curiosité.",
    "{pet} bâille à s'en décrocher la mâchoire.",
    "{pet} regarde passer un papillon.",
    "{pet} reste tout près de vous.",
    "{pet} trottine devant, puis se retourne pour vérifier que vous suivez.",
  },
  {
    "{pet} vous frôle affectueusement la jambe en marchant.",
    "{pet} lève vers vous un regard plein de confiance.",
    "{pet} vous rapporte un bâton. Ou peut-être un os. Mieux vaut ne pas demander.",
    "{pet} marche si près de vous que vous manquez de trébucher. Ça vaut le coup.",
  },
}
M.idleSwimming = {
  "{pet} nage joyeusement à vos côtés.",
  "{pet} s'ébroue et vous éclabousse de partout. Merci.",
}
M.idleResting = {
  "{pet} renifle toutes ces nouvelles odeurs.",
  "{pet} observe les passants avec grand intérêt.",
}
M.idleNight = {
  "{pet} lève un instant les yeux vers les étoiles.",
  "{pet} reste un peu plus près de vous dans l'obscurité.",
}
M.followAfterStay = {
  "{pet} accourt vers vous dès que vous l'appelez !",
  "{pet} a attendu patiemment et arrive enfin en courant.",
}
M.tierUp = {
  "Votre lien avec {pet} a grandi : |cffffd100{tier}|r !",
}
M.loyaltyUp = {
  "La loyauté de {pet} a grandi : |cffffd100{loyalty}|r !",
}

-- Oiseaux (chouettes, charognards, hauts-trotteurs)
M.campfireNear_bird = {
  "{pet} gonfle ses plumes à la chaleur d'un feu de camp tout proche.",
  "{pet} se tourne vers le crépitement d'un feu tout proche.",
}
M.campfireRest_bird = {
  "{pet} se perche près du feu, plumes gonflées, parfaitement à l'aise.",
  "{pet} se blottit près du feu et ferme à demi les yeux.",
}
M.affection_bird = {
  { "{pet} ébouriffe ses plumes sous votre main, sur la réserve, mais ne bouge pas.", "{pet} observe votre main, puis accepte une gratouille prudente." },
  { "{pet} se presse contre votre main en roucoulant doucement.", "{pet} gonfle joyeusement ses plumes sous vos doigts." },
  { "{pet} vous mordille gentiment les doigts. C'est de l'amour, version oiseau.", "{pet} se blottit contre vous en gazouillant de contentement." },
}
M.playful_bird = {
  { "{pet} observe vos mouvements, profondément perplexe." },
  { "{pet} se dandine au rythme de votre danse !", "{pet} bat des ailes autour de vous pour participer !" },
  { "{pet} déploie ses ailes et danse avec vous, aux anges." },
}
M.chicken_bird = {
  "{pet} observe votre imitation de poulet avec une profonde indignation professionnelle.",
  "{pet} vous répond par un cri strident. C'est un défi ?",
}
M.attentionRequest_bird = {
  "{pet} piaille avec insistance. De l'attention, s'il vous plaît !",
  "{pet} sautille juste devant vous et refuse de bouger.",
}
M.attentionAnswered_bird = { "{pet} gazouille joyeusement en gonflant ses plumes." }
M.mealRequest_bird = {
  "{pet} sautille plus près et lorgne votre {item} avec grand intérêt.",
  "{pet} regarde votre {item} de biais. Un petit partage ?",
}
M.lootFood_bird = { "{pet} lorgne votre {item} en poussant un petit cri plein d'espoir." }
M.treatAsk_bird = { "{pet} lorgne votre {item} en poussant un petit cri plein d'espoir. C'est pour partager ?" }
M.fishing_bird = { "{pet} fixe votre {item} avec la concentration d'un chasseur né." }
M.hungry_bird = { "{pet} piaille de faim en signe d'approbation." }
M.rude_bird = {
  { "{pet} recule dans un battement d'ailes affolé." },
  { "{pet} se hérisse et se détourne, l'air vexé." },
  { "{pet} vous regarde, les plumes tombantes, le cœur gros." },
}
M.sad_bird = {
  { "{pet} vous observe de loin, en silence." },
  { "{pet} sautille plus près et se pose à côté de vous." },
  { "{pet} se blottit contre vous, plumes chaudes. Quelqu'un est là pour vous." },
}
M.sorryForgive_bird = { "{pet} regonfle ses plumes. C'est pardonné." }
M.idle_bird = {
  "{pet} lisse quelques plumes.",
  "{pet} sautille après un scarabée.",
  "{pet} étire ses ailes, puis les replie soigneusement.",
}

-- Écailles (crocilisques, raptors, tortues, serpents des vents)
M.campfireNear_scaly = {
  "{pet} se tourne vers la chaleur d'un feu de camp tout proche. L'heure de se réchauffer ?",
  "{pet} goûte l'air enfumé du bout de la langue.",
}
M.campfireRest_scaly = {
  "{pet} s'étale près du feu et absorbe la chaleur avec une immense satisfaction.",
}
M.affection_scaly = {
  { "{pet} se fige sous votre main et vous observe." },
  { "{pet} ferme lentement les yeux et savoure la gratouille." },
  { "{pet} s'appuie de tout son poids contre vous avec un grondement satisfait." },
}
M.attentionRequest_scaly = { "{pet} vous pousse la jambe de son museau froid pour réclamer de l'attention." }
M.attentionAnswered_scaly = { "{pet} gronde de contentement." }
M.mealRequest_scaly = { "{pet} fixe votre {item} sans cligner des yeux. Pas une seule fois." }
M.lootFood_scaly = { "La langue de {pet} frétille à l'odeur de votre {item}." }
M.treatAsk_scaly = { "La langue de {pet} frétille à l'odeur de votre {item}, le regard fixé sur vous. Une friandise, peut-être ?" }
M.fishing_scaly = { "{pet} observe votre {item} de très, très près." }
M.hungry_scaly = { "La langue de {pet} frétille de faim." }
M.rude_scaly = {
  { "{pet} siffle et recule." },
  { "{pet} vous lance un regard froid, sans ciller." },
  { "{pet} accuse le coup, mais reste à vos côtés." },
}
M.sad_scaly = {
  { "{pet} vous observe, sans savoir quoi faire." },
  { "{pet} se couche tout près de vous." },
  { "{pet} pose sa lourde tête contre vous. Quelqu'un est là pour vous." },
}
M.sorryForgive_scaly = { "{pet} cligne lentement des yeux. C'est pardonné." }
M.idle_scaly = {
  "{pet} se prélasse dans un rayon de soleil.",
  "{pet} goûte l'air du bout de la langue.",
  "{pet} cligne lentement des yeux, parfaitement calme.",
}

-- Carapaces (araignées, scorpides, crabes)
M.campfireNear_chitin = {
  "{pet} cliquette avec curiosité à l'odeur de la fumée.",
  "{pet} trottine un peu plus vite vers la chaleur.",
}
M.campfireRest_chitin = { "{pet} s'installe près du feu, pattes repliées, paisible." }
M.affection_chitin = {
  { "{pet} lève une patte avec méfiance, puis la repose." },
  { "{pet} cliquette doucement sous votre main." },
  { "{pet} vous tapote doucement le bras, un geste qui vous est réservé." },
}
M.attentionRequest_chitin = { "{pet} tapote votre botte plusieurs fois. Attention requise." }
M.attentionAnswered_chitin = { "{pet} cliquette de joie." }
M.mealRequest_chitin = { "{pet} cliquette d'appétit en voyant votre {item}." }
M.lootFood_chitin = { "{pet} cliquette d'excitation devant votre {item}." }
M.treatAsk_chitin = { "{pet} cliquette d'excitation devant votre {item}, puis se tourne vers vous. On partage ?" }
M.fishing_chitin = { "{pet} s'agite près de votre {item}. Une petite faim ?" }
M.hungry_chitin = { "{pet} cliquette de faim en signe d'approbation." }
M.rude_chitin = {
  { "{pet} se dresse sur la défensive." },
  { "{pet} file bouder dans un coin." },
  { "{pet} accuse le coup, mais reste tout près." },
}
M.sad_chitin = {
  { "{pet} cliquette sans trop savoir quoi faire." },
  { "{pet} s'installe juste à côté de vous." },
  { "{pet} ne vous quittera pas tant que vous n'irez pas mieux." },
}
M.sorryForgive_chitin = { "{pet} cliquette doucement. C'est pardonné." }
M.idle_chitin = {
  "{pet} trottine après un minuscule insecte.",
  "{pet} tapote le sol avec curiosité.",
  "{pet} nettoie une patte avec grand soin.",
}

---------------------------------------------------------------------------
-- Module Elements (confort du corps). Pas d'adjectifs sur le personnage
-- (trempé/trempée...) : on parle de ce que vous ressentez, de vos vêtements.
---------------------------------------------------------------------------

L.UI_TAB_BODY     = "Corps"
L.UI_MOD_ELEMENTS = "Confort du corps (Elements) : froid, chaleur, humidité, soif"
L.EL_TITLE        = "Confort du corps"
L.EL_TEMP         = "Température : %s"
L.EL_TEMP_STATES  = { freezing = "Glacial", cold = "Froid", ok = "Confortable", hot = "Chaud", overheat = "Étouffant" }
L.EL_WET          = "Humidité : %d %%"
L.EL_THIRST       = "Soif : %s"
L.EL_HUNGER       = "Faim : %s"
L.EL_ENERGY       = "Énergie : %s"
L.EL_NEED_STATES  = { ok = "Ça va", thirsty = "Soif", parched = "Gorge desséchée", hungry = "Faim", starving = "{Affamé|Affamée|Affamé·e}",
  tired = "Fatigue", exhausted = "À bout de forces" }
L.UI_OPT_THERMO   = "Afficher le thermomètre près de la minicarte"
L.UI_OPT_GENDER   = "Votre personnage (pour les accords)"
L.UI_GENDER_AUTO  = "Auto"
L.UI_GENDER_M     = "Masculin"
L.UI_GENDER_F     = "Féminin"
L.UI_GENDER_N     = "Neutre"
L.EL_THERMO_TITLE = "Thermomètre"
L.EL_AIR          = "Air : %s"
L.EL_YOU_FEEL     = "Ressenti : %s"
L.EL_THERMO_HINT  = "Clic : confort du corps. Clic droit : °C / °F. Glisser : déplacer."
L.EL_CLIMATE      = { [-2] = "climat glacial", [-1] = "climat froid", [0] = "climat doux", [1] = "climat chaud", [2] = "climat brûlant" }
L.EL_INDOORS      = "à l'intérieur"
L.EL_NIGHT        = "nuit"
L.EL_FIRE         = "près d'un feu"
L.EL_SWIMMING     = "dans l'eau"
L.EL_HERE         = "Ici : %s"
L.EL_MOVE_HINT    = "Clic : détails. Maj + glisser : déplacer."
L.EL_OFF          = "Le module de confort du corps est désactivé. Vous pouvez le réactiver dans l'onglet Options."
L.EL_PAGE_INTRO   = "Ce que ressent votre personnage. Purement cosmétique : rien ici ne change vos caractéristiques."
L.EL_PAGE_TIPS    = "Se réchauffer : un feu de camp, une auberge, un toit au-dessus de la tête.\nSe rafraîchir : rentrer à l'intérieur, attendre la nuit, se baigner.\nSe sécher : le temps, et bien plus vite près d'un feu.\nLa soif : buvez n'importe quoi. Elle monte plus vite quand il fait chaud.\nLa faim : asseyez-vous et mangez.\nL'énergie : reposez-vous dans une auberge ou en ville, asseyez-vous au coin du feu, ou somnolez un moment."
L.EL_GUIDE = table.concat({
  "|cffffd100Confort du corps (Elements)|r",
  "Votre personnage ressent le froid, la chaleur, l'eau, la soif, la faim et la fatigue, et vous le dit dans le chat. L'onglet Corps montre les détails. (Dans les Options, vous pouvez aussi afficher des icônes ou des barres près de votre portrait.)",
  "|cffff8fb1Froid et chaleur|r  Chaque zone a son climat. Les nuits sont plus fraîches dehors. Feux de camp, auberges et toits vous réchauffent ; être mouillé vous refroidit.",
  "|cffff8fb1Humidité|r  Nager vous trempe. Vous séchez avec le temps, plus vite à la chaleur ou près d'un feu.",
  "|cffff8fb1Soif|r  Monte doucement avec le temps, plus vite dans les zones chaudes et en combat. Boire n'importe quoi vous désaltère.",
  "|cffff8fb1Faim|r  Monte en deux heures environ, plus vite en combat ou quand vous avez froid. Manger vous rassasie.",
  "|cffff8fb1Énergie|r  Après quelques heures d'aventure, la fatigue arrive. Reposez-vous dans une auberge ou en ville, au coin du feu, ou somnolez un moment.",
  "|cffff8fb1Thermomètre|r  Le bouton près de la minicarte indique la température de l'air. Votre corps la suit, mais l'eau, un feu ou une auberge changent votre ressenti.",
}, "\n")

M.coldEnter = {
  "Un frisson vous parcourt l'échine.",
  "Le froid commence à vous mordre les doigts.",
  "Vous resserrez votre col contre le froid.",
}
M.freezingEnter = {
  "Vous grelottez de plus en plus. Il vous faut de la chaleur.",
  "Vos dents claquent. Vos doigts s'engourdissent.",
}
M.coldRemind = {
  "Vous frissonnez.",
  "Vous vous frottez les mains pour les réchauffer.",
  "Vous avez le bout du nez glacé.",
}
M.freezingRemind = {
  "Vous ne sentez presque plus vos doigts.",
  "Le froid vous gagne jusqu'aux os.",
}
M.warmBack = {
  "La chaleur revient peu à peu dans vos doigts.",
  "Vous cessez enfin de frissonner.",
}
M.hotEnter = {
  "Des gouttes de sueur perlent sur votre front.",
  "La chaleur commence à peser.",
}
M.overheatEnter = {
  "La chaleur devient écrasante. Il faut vous rafraîchir.",
  "La tête vous tourne un peu avec cette chaleur.",
}
M.hotRemind = {
  "Vous essuyez la sueur de votre front.",
  "Vos vêtements vous collent à la peau.",
}
M.overheatRemind = {
  "La chaleur est accablante.",
  "Chaque pas pèse plus lourd sous cette chaleur.",
}
M.coolBack = {
  "Vous vous sentez plus au frais.",
  "Quel soulagement de se rafraîchir.",
}
M.soaked = {
  "Vos vêtements sont trempés jusqu'au dernier fil.",
  "Vous êtes {trempé|trempée|trempé·e} jusqu'aux os.",
  "L'eau ruisselle de vos vêtements à chaque pas.",
}
M.dry = {
  "Vos vêtements sont enfin secs.",
}
M.body_thirsty = {
  "Vous avez la gorge sèche.",
  "Une gorgée d'eau ne serait pas de refus.",
}
M.body_parched = {
  "Vos lèvres sont gercées. Il vous faut de l'eau.",
  "Vous donneriez n'importe quoi pour une gorgée d'eau.",
}
M.drinkRelief = {
  "Ah, ça va mieux.",
  "Ça fait du bien par où ça passe.",
}
M.body_hungry = {
  "Votre ventre gargouille.",
  "Vous mangeriez bien quelque chose.",
}
M.body_starving = {
  "La faim vous affaiblit.",
  "Votre estomac vous fait mal. Il faut manger.",
}
M.eatRelief = {
  "Voilà qui fait du bien.",
  "Bien mieux. Votre estomac vous remercie.",
}
M.body_tired = {
  "Vous bâillez.",
  "Vos paupières sont lourdes.",
}
M.body_exhausted = {
  "Vous avancez sur vos dernières forces. Un peu de repos vous ferait du bien.",
  "Chaque pas vous coûte. Il vous faut un vrai repos.",
  "Vous êtes {épuisé|épuisée|épuisé·e}. Il est temps de souffler un peu.",
}
M.restRelief = {
  "Le repos vous a fait du bien.",
  "Vous vous sentez {ragaillardi|ragaillardie|ragaillardi·e}, prêt{|e|·e} à repartir.",
  "Vos forces sont revenues.",
}
M.fireWarm = {
  "La chaleur du feu est une bénédiction.",
  "Vous profitez de la chaleur du feu.",
}
M.indoorsWarm = {
  "Il fait plus chaud ici.",
  "Enfin à l'abri du froid.",
}

---------------------------------------------------------------------------
-- Module Senses (ambiance). Les lignes elles-mêmes sont dans SensesData.lua.
---------------------------------------------------------------------------

L.UI_TAB_SENSES   = "Ambiance"
L.UI_MOD_SENSES   = "Lignes d'ambiance (Senses)"
L.UI_OPT_RHYTHM   = "Fréquence des lignes d'ambiance"
L.UI_RHYTHM       = { [0] = "Jamais", [1] = "Rare", [2] = "Normal", [3] = "Souvent" }
L.SN_OFF          = "Le module d'ambiance est désactivé. Vous pouvez le réactiver dans l'onglet Options."
L.SN_YES, L.SN_NO = "oui", "non"
L.SN_PLACE        = "Lieu : %s  (carte %s)"
L.SN_WEATHER      = "Météo : %s"
L.SN_WEATHER_NONE = "inconnue"
L.SN_WEATHER_UNKNOWN = "type %s, intensité %s (pas encore identifiée : dites-moi ce que vous voyez !)"
L.SN_WEATHERS     = { clear = "dégagé", rain = "pluie", snow = "neige", sand = "tempête de sable" }
L.SN_TIME         = "Moment : %s, air %s"
L.SN_DAY, L.SN_NIGHT = "jour", "nuit"
L.SN_INOUT        = "À l'intérieur : %s   Ville ou auberge : %s"
L.SN_CROWD        = "Monde autour : %s  (%d à proximité, %d qui parlent)"
L.SN_CROWDS       = { quiet = "calme", lively = "animé", crowded = "bondé" }
L.SN_CROWD_UNKNOWN = "impossible à dire (activez les barres de nom alliées pour aider)"
L.SN_LINES        = "Lignes pour ici : %d possibles maintenant, %d pas maintenant"
L.SN_ARRIVE_TAG   = "(première visite)"
L.SN_TAGS = {
  generic = "partout", biome = "paysage : %s", zone = "cette zone", subzone = "ce lieu précis",
  day = "en journée", night = "la nuit", indoors = "à l'intérieur", outdoors = "dehors", resting = "ville ou auberge",
  swimming = "en nageant", weather = "météo : %s", crowd = "monde : %s",
  airBelow = "air sous %s", airAbove = "air au-dessus de %s", notBiomes = "sauf : %s", place = "lieu : %s",
  long = "longue", spot = "cet endroit", moving = "en marchant", hearth = "pierre de foyer", calm = "sans foule",
}
L.SN_POS = "Position : %s   Endroit : %s"
L.SN_LANDSCAPE = "Paysage : %s   Niveaux de la zone : %s"

-- En entrant dans une zone loin de votre niveau
M.dangerHigh = {
  "Un frisson vous parcourt. Cet endroit est bien trop dangereux pour vous.",
  "Tout votre instinct vous dit de faire demi-tour.",
  "Vous vous sentez minuscule ici. Ce qui vit sur ces terres pourrait vous écraser.",
}
M.dangerMid = {
  "Vous ne vous sentez pas à votre place ici. Mieux vaut rester sur vos gardes.",
  "Les créatures d'ici semblent plus coriaces que celles dont vous avez l'habitude.",
  "Quelque chose vous dit que cette terre n'est pas encore pour vous.",
}
M.dangerNone = {
  "Vous parcourez ces terres avec assurance : peu de choses ici peuvent vous menacer.",
  "Ces terres n'ont plus rien de dangereux pour vous.",
}
M.dangerNear = {
  "Les poils de votre nuque se hérissent. Quelque chose de très dangereux est tout proche.",
  "Vous sentez une présence menaçante tout près. Quelque chose ici vous dépasse de loin.",
}
-- une touche du paysage avant le sentiment de danger
M.dangerFlavor_gloom    = { "Les ombres entre les arbres semblent bouger d'elles-mêmes." }
M.dangerFlavor_swamp    = { "L'eau trouble pourrait cacher n'importe quoi." }
M.dangerFlavor_hostile  = { "Ici, la terre elle-même semble hostile." }
M.dangerFlavor_cold     = { "Le vent hurle comme un avertissement." }
M.dangerFlavor_volcanic = { "L'air enfumé vous brûle les poumons." }
M.dangerFlavor_sick     = { "Quelque chose de malsain flotte dans l'air." }
M.dangerFlavor_wild     = { "Les terres autour de vous semblent retenir leur souffle." }

-- le familier le sent aussi
M.petDangerHigh = {
  "{pet} se colle à vos jambes, les oreilles plaquées, un grondement sourd dans la gorge.",
  "{pet} hume l'air et recule d'un pas, le poil hérissé.",
}
M.petDangerHigh_bird   = { "{pet} se gonfle et reste tout près de vous, les yeux aux aguets." }
M.petDangerHigh_scaly  = { "{pet} siffle doucement et ne vous quitte plus d'un pas." }
M.petDangerHigh_chitin = { "{pet} lève les deux pattes avant, sur la défensive." }
M.petDangerMid = {
  "{pet} reste un peu plus près de vous que d'habitude.",
  "{pet} jette des coups d'œil autour, sur ses gardes.",
}
M.petDangerNone = {
  "{pet} trottine fièrement devant vous. Rien ici ne vous fait peur, à tous les deux.",
}
M.petDangerNone_bird = { "{pet} se pavane fièrement devant vous." }
M.petDangerNear = {
  "{pet} gronde vers quelque chose que vous ne voyez pas bien.",
  "{pet} se fige, les yeux rivés sur le danger, tous les muscles tendus.",
}
M.petDangerNear_bird   = { "{pet} pousse un cri d'alerte." }
M.petDangerNear_scaly  = { "{pet} siffle, les yeux rivés sur le danger." }
M.petDangerNear_chitin = { "{pet} cliquette nerveusement, les yeux rivés sur le danger." }
L.CMD_RESET_VISITS = "Lieux visités et repos des lignes oubliés : toutes les lignes peuvent rejouer."
L.UI_OPT_STYLE = "Longueur des lignes d'ambiance"
L.UI_OPT_BODYSTYLE = "Confort du corps à côté de votre portrait"
L.UI_BODYSTYLE = { none = "Texte seul", bars = "Barres", icons = "Icônes" }
L.UI_STYLE     = { short = "Courtes", mixed = "Mélangées", rich = "Riches" }
L.SN_PROPOSE_LABEL = "Proposer une ligne pour ce lieu :"
L.SN_PROPOSE      = "Proposer"
L.SN_PROPOSED     = "Merci ! Votre ligne est enregistrée avec ce lieu. Elle sera dans la fenêtre « Rapport & idées »."
L.UI_REPORT_PROPOSALS = "--- Lignes proposées ---"
L.SN_PLAY_TT      = "Afficher cette ligne dans le chat maintenant, pour voir comment elle rend. (Un aperçu : la ligne n'est pas consommée.)"
L.SN_REASONS = {
  night = "seulement la nuit", day = "seulement le jour", indoors = "seulement à l'intérieur",
  outdoors = "seulement dehors", resting = "seulement en ville ou à l'auberge", swimming = "seulement en nageant",
  airBelow = "seulement quand il fait plus froid", airAbove = "seulement quand il fait plus chaud",
  biome = "pas dans ce paysage", sub = "seulement dans un lieu précis",
  weatherWait = "en attente des données météo", weather = "pas avec cette météo",
  crowdUnknown = "a besoin de savoir qui est là", crowd = "pas avec ce monde-là",
  cooldown = "déjà jouée, revient dans %s", moving = "seulement en marchant", calm = "pas quand il y a foule",
}
L.SN_BIOMES = {
  forest = "forêt", plains = "plaines", farmland = "terres agricoles sèches", hills = "collines", mountain = "montagnes", snow = "neige",
  desert = "désert", savanna = "savane", badlands = "terres arides", canyon = "canyon", jungle = "jungle",
  swamp = "marais", marsh = "marécages", coast = "côte", gloom = "terres sombres", plague = "terres pestiférées",
  wasteland = "terres désolées", volcanic = "terres volcaniques", corrupted = "forêt corrompue", city = "ville",
  forge = "cité-forge", undercity = "cité souterraine", unknown = "pas encore décrit",
}
L.SN_GUIDE = table.concat({
  "|cffffd100Ambiance (Senses)|r",
  "De temps en temps, une courte ligne décrit le monde autour de vous : une odeur, un bruit, le vent, la météo. La première fois que vous arrivez dans un nouveau lieu, il vous accueille avec sa propre ligne.",
  "En entrant dans un lieu que vous connaissez déjà (un village, une ferme, un quartier), une ligne peut aussi l'évoquer, au plus une fois toutes les 10 minutes (15 avec le rythme Rare, 5 avec Souvent).",
  "Les petits moments ont aussi leurs lignes, chacun avec son propre minuteur : un combat difficile, un repas, une cueillette ou une extraction de minerai, le dépeçage, votre pierre de foyer, l'atterrissage après un long vol, l'aube et le crépuscule, entrer ou sortir d'un bâtiment, la banque, la boîte aux lettres, l'hôtel des ventes, votre maître de métier ou de classe, apprendre un métier ou une recette, le retour à la vie, ou simplement rester immobile un moment.",
  "Les lignes dépendent du paysage, du lieu précis, du jour ou de la nuit, de l'intérieur ou de l'extérieur, de la météo et du monde autour de vous.",
  "L'onglet Ambiance montre ce que l'addon voit là où vous êtes, et toutes les lignes qui pourraient apparaître ici. Si une ligne vous semble fausse, signalez-la avec /wt nope.",
}, "\n")
