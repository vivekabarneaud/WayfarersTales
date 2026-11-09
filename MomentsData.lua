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
--   chance = how often it plays when it can (x0.5 with the Rare rhythm, x1.4 with Often)
--   gap    = it never plays less than this many seconds after another Senses line
--   shares = uses the timer of another moment (e.g. stepping in and stepping out)
D.MOMENT_RULES = {
  eat             = { cd = 900,  chance = 0.6, gap = 20 },
  eatItem         = { cd = 900,  chance = 0.6, gap = 20, shares = "eat" },
  drink           = { cd = 900,  chance = 0.5, gap = 20 },
  drinkItem       = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  drinkWater      = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  drinkConjured   = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  drinkMilk       = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  drinkJuice      = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  drinkDew        = { cd = 900,  chance = 0.5, gap = 20, shares = "drink" },
  afterFight      = { cd = 900,  chance = 1,   gap = 0 },
  afterFightClose = { cd = 900,  chance = 1,   gap = 0, shares = "afterFight" },
  quiet           = { cd = 1200, chance = 1,   gap = 120 },
  herb            = { cd = 1200, chance = 0.5, gap = 60 },
  mine            = { cd = 1200, chance = 0.5, gap = 60 },
  skin            = { cd = 1200, chance = 0.5, gap = 60 },
  hearth          = { cd = 600,  chance = 1,   gap = 30 },
  landing         = { cd = 600,  chance = 0.8, gap = 30 },
  dawn            = { cd = 3600, chance = 1,   gap = 30 },
  dusk            = { cd = 3600, chance = 1,   gap = 30 },
  goIn            = { cd = 900,  chance = 0.5, gap = 60, shares = "door" },
  goOut           = { cd = 900,  chance = 0.5, gap = 60, shares = "door" },
  bank            = { cd = 1800, chance = 0.6, gap = 20 },
  mail            = { cd = 1800, chance = 0.6, gap = 20 },
  auction         = { cd = 1800, chance = 0.6, gap = 20 },
  trainer         = { cd = 1800, chance = 0.6, gap = 20 },
  learnProfession = { cd = 0,    chance = 1,   gap = 0 },
  craftRankUp     = { cd = 600,  chance = 1,   gap = 0 },
  learnRecipe     = { cd = 1800, chance = 0.35, gap = 30 },
  revive          = { cd = 0,    chance = 1,   gap = 0 },
  reviveSick      = { cd = 0,    chance = 1,   gap = 0, shares = "revive" },
}

-- Each profession's own lines use the timer of the general ones
for _, k in ipairs({ "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism", "leatherworking",
  "mining", "skinning", "tailoring", "cooking", "firstaid", "fishing" }) do
  D.MOMENT_RULES["learn_" .. k] = { cd = 0,   chance = 1, gap = 0, shares = "learnProfession" }
  D.MOMENT_RULES["rank_" .. k]  = { cd = 600, chance = 1, gap = 0, shares = "craftRankUp" }
end

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
  drink = {
    { en = "You drink in long, slow sips.", fr = "Vous buvez à longues gorgées, sans vous presser." },
    { en = "You sit down and drink slowly, letting your breath settle.", fr = "Vous vous asseyez et buvez lentement, le temps de reprendre votre souffle." },
  },
  drinkItem = {
    { en = "You sip your {item} slowly. It does you good.", fr = "Vous sirotez votre {item} lentement. Ça fait du bien." },
    { en = "You sit down and drink slowly, letting your breath settle.", fr = "Vous vous asseyez et buvez lentement, le temps de reprendre votre souffle." },
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
    { en = "The sky grows paler. A new day is beginning.", fr = "Le ciel pâlit. Un nouveau jour commence.", when = { notBiomes = NO_DARK } },
  },
  dusk = {
    { en = "The light turns golden, then slowly fades. Evening is falling.", fr = "La lumière se fait dorée, puis décline doucement. Le soir tombe.", when = { notBiomes = NO_DARK } },
    { en = "The shadows grow longer. Night is coming.", fr = "Les ombres s'allongent. La nuit approche.", when = { notBiomes = NO_DARK } },
    { en = "Darkness slowly settles over the land.", fr = "L'obscurité s'installe lentement sur le pays.", when = { notBiomes = NO_DARK } },
  },

  -- Stepping indoors and out (one shared timer)
  goIn = {
    { en = "The sounds of the outside fade as you step inside.", fr = "Les bruits du dehors s'estompent quand vous entrez." },
    { en = "Inside, the air is still.", fr = "À l'intérieur, l'air est immobile." },
    { en = "Your eyes take a moment to adjust to the dimmer light.", fr = "Vos yeux mettent un instant à s'habituer à la pénombre.",
      when = { night = false, notBiomes = NO_DARK } },
  },
  goOut = {
    { en = "You step back out into the open air.", fr = "Vous ressortez à l'air libre." },
    { en = "The open sky above you again.", fr = "Le ciel à nouveau au-dessus de vous." },
    { en = "You squint a little in the daylight.", fr = "Vous plissez un peu les yeux à la lumière du jour.",
      when = { night = false, notBiomes = NO_DARK } },
    { en = "The night air greets you as you step outside.", fr = "L'air de la nuit vous accueille dehors.", when = { night = true } },
  },

  -- City errands
  bank = {
    { en = "The banker greets you with a polite nod.", fr = "On vous accueille au guichet d'un signe de tête poli." },
    { en = "Behind the counter, coins clink softly as they are counted.", fr = "Derrière le comptoir, des pièces tintent doucement tandis qu'on les compte." },
  },
  mail = {
    { en = "You open the mailbox, hoping for good news.", fr = "Vous ouvrez la boîte aux lettres, en espérant de bonnes nouvelles." },
    { en = "You check the mailbox, just in case.", fr = "Vous jetez un œil à la boîte aux lettres, au cas où." },
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
  learn_alchemy = {
    { en = "Alchemy: vials, herbs and strange vapors. You'll have to get used to the smell.", fr = "L'alchimie : des fioles, des herbes et d'étranges vapeurs. Il va falloir vous habituer à l'odeur." },
    { en = "Your first lesson in alchemy: measure twice, pour once. And never sniff an unknown vial.", fr = "Première leçon d'alchimie : mesurer deux fois, verser une seule. Et ne jamais renifler une fiole inconnue." },
  },
  rank_alchemy = {
    { en = "Your potions are getting clearer, your measures more precise. Alchemy is starting to make sense.", fr = "Vos potions gagnent en pureté, vos dosages en précision. L'alchimie commence à prendre tout son sens." },
  },
  learn_blacksmithing = {
    { en = "Blacksmithing: fire, iron and a heavy hammer. Your arms are going to remember this.", fr = "La forge : du feu, du fer et un lourd marteau. Vos bras vont s'en souvenir." },
    { en = "You learn to read the color of hot metal: red, orange, then that pale yellow that means it's time to strike.", fr = "Vous apprenez à lire la couleur du métal chaud : rouge, orange, puis ce jaune pâle qui annonce qu'il est temps de frapper." },
  },
  rank_blacksmithing = {
    { en = "Your hammer blows grow steadier, your metal truer. The anvil is starting to know you.", fr = "Vos coups de marteau se font plus sûrs, votre métal plus droit. L'enclume commence à vous connaître." },
  },
  learn_enchanting = {
    { en = "Enchanting: drawing the magic out of objects and weaving it into others. Your fingertips tingle just thinking about it.", fr = "L'enchantement : tirer la magie des objets pour la tisser dans d'autres. Rien que d'y penser, le bout de vos doigts picote." },
    { en = "You learn to feel the faint hum of magic sleeping inside things. Enchanting has begun.", fr = "Vous apprenez à sentir le léger bourdonnement de la magie endormie dans les choses. L'enchantement commence." },
  },
  rank_enchanting = {
    { en = "The arcane currents feel clearer now, easier to bend. Your enchantments hold better.", fr = "Les courants arcaniques vous semblent plus clairs, plus faciles à plier. Vos enchantements tiennent mieux." },
  },
  learn_engineering = {
    { en = "Engineering: gears, blasting powder and a healthy dose of luck. What could possibly go wrong?", fr = "L'ingénierie : des engrenages, de la poudre explosive et une bonne dose de chance. Qu'est-ce qui pourrait mal tourner ?" },
    { en = "You leave with a head full of schematics and a strong urge to blow something up. Carefully. Probably.", fr = "Vous repartez la tête pleine de schémas et une furieuse envie de faire exploser quelque chose. Prudemment. Sans doute." },
  },
  rank_engineering = {
    { en = "Fewer singed eyebrows, more working gadgets. Your engineering is coming along nicely.", fr = "Moins de sourcils roussis, plus de gadgets qui marchent. Votre ingénierie fait de beaux progrès." },
  },
  learn_herbalism = {
    { en = "Herbalism: from now on, every flower along the road is worth a second look.", fr = "L'herboristerie : désormais, chaque fleur au bord du chemin mérite un second regard." },
    { en = "You learn to tell a precious herb from a common weed, and to pick it gently so it grows back.", fr = "Vous apprenez à distinguer une herbe précieuse d'une mauvaise herbe, et à la cueillir en douceur pour qu'elle repousse." },
  },
  rank_herbalism = {
    { en = "You spot herbs faster now, even half hidden in the grass.", fr = "Vous repérez les herbes plus vite désormais, même à moitié cachées dans la végétation." },
  },
  learn_leatherworking = {
    { en = "Leatherworking: hides, needles and thread. And patience, mostly.", fr = "Le travail du cuir : des peaux, des aiguilles et du fil. Et surtout de la patience." },
    { en = "You run your fingers over a piece of leather and start to see what it could become.", fr = "Vous passez les doigts sur un morceau de cuir et commencez à entrevoir ce qu'il pourrait devenir." },
  },
  rank_leatherworking = {
    { en = "Your stitches are tighter, your leather more supple. The craft is in your hands now.", fr = "Vos coutures sont plus serrées, votre cuir plus souple. Le métier est entre vos mains." },
  },
  learn_mining = {
    { en = "Mining: from now on, every vein of ore in the rock is calling your name.", fr = "Le minage : désormais, chaque filon dans la roche vous appelle." },
    { en = "You learn where to strike so the rock gives way: along the vein, never against it.", fr = "Vous apprenez où frapper pour que la roche cède : le long du filon, jamais contre." },
  },
  rank_mining = {
    { en = "Your pick finds the weak spot in the rock faster now.", fr = "Votre pioche trouve plus vite le point faible de la roche." },
  },
  learn_skinning = {
    { en = "Skinning: not the most glamorous craft, but nothing goes to waste.", fr = "Le dépeçage : pas le métier le plus glamour, mais rien ne se perd." },
    { en = "You learn to work the knife slowly and cleanly along the hide. Your stomach will get used to it.", fr = "Vous apprenez à manier le couteau lentement et proprement, le long de la peau. Votre estomac s'y fera." },
  },
  rank_skinning = {
    { en = "Your knife moves surer now, and the hides come off whole.", fr = "Votre couteau se fait plus sûr, et les peaux viennent entières." },
  },
  learn_tailoring = {
    { en = "Tailoring: needle, thread and a lot of cloth. Every scrap of fabric you find just became interesting.", fr = "La couture : du fil, une aiguille et beaucoup de tissu. Chaque bout d'étoffe que vous trouverez devient intéressant." },
    { en = "You learn to measure, cut and stitch. Somewhere, a very fine robe is waiting to be made.", fr = "Vous apprenez à mesurer, couper et coudre. Quelque part, une très belle robe attend d'être faite." },
  },
  rank_tailoring = {
    { en = "Your stitches are finer, your seams straighter. Tailoring suits you.", fr = "Vos points sont plus fins, vos coutures plus droites. La couture vous va bien." },
  },
  learn_cooking = {
    { en = "Cooking: a warm meal after a long day is worth more than gold.", fr = "La cuisine : un bon repas chaud après une longue journée vaut plus que de l'or." },
    { en = "You learn the basics: a good fire, the right moment, and a pinch of salt. Your companions will thank you.", fr = "Vous apprenez les bases : un bon feu, le bon moment, et une pincée de sel. Vos compagnons vous remercieront." },
  },
  rank_cooking = {
    { en = "Less burnt, more delicious. Your cooking is getting better.", fr = "Moins de brûlé, plus de délicieux. Votre cuisine s'améliore." },
  },
  learn_firstaid = {
    { en = "First aid: clean bandages and steady hands. One day, this will save a life. Maybe yours.", fr = "Le secourisme : des bandages propres et des mains sûres. Un jour, ça sauvera une vie. Peut-être la vôtre." },
    { en = "You learn to wrap a wound tight, but not too tight. It's harder than it looks.", fr = "Vous apprenez à bander une plaie bien serré, mais pas trop. C'est plus difficile qu'il n'y paraît." },
  },
  rank_firstaid = {
    { en = "Your bandages are tighter, cleaner, faster. You could patch up a whole army.", fr = "Vos bandages sont plus serrés, plus propres, plus rapides. Vous pourriez soigner toute une armée." },
  },
  learn_fishing = {
    { en = "Fishing: a line, a hook, and all the patience in the world.", fr = "La pêche : une ligne, un hameçon, et toute la patience du monde." },
    { en = "From now on, every pond and every river looks a little different. What might be hiding down there?", fr = "Désormais, chaque mare et chaque rivière vous semble un peu différente. Qu'est-ce qui peut bien se cacher là-dessous ?" },
  },
  rank_fishing = {
    { en = "You read the water better now: the ripples, the shadows, the right moment to pull.", fr = "Vous lisez mieux l'eau désormais : les rides, les ombres, le bon moment pour ferrer." },
  },

  learnRecipe = {
    { en = "A new recipe: {item}. You can't wait to try it.", fr = "Nouvelle recette : {item}. Vous avez hâte d'essayer." },
    { en = "You go over the steps of the recipe in your head, again and again: {item}.", fr = "Vous repassez les étapes de la recette dans votre tête, encore et encore : {item}." },
    { en = "You carefully commit it to memory: {item}.", fr = "Vous la gravez soigneusement dans votre mémoire : {item}." },
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
