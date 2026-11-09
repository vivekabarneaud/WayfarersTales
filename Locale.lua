-- Wayfarer's Tales - texts (English, the reference language).
-- Every player-facing sentence lives here. Translations (Locale_frFR.lua...)
-- only replace what they define; anything missing stays in English.
-- {pet}, {item}, {tier}, {loyalty}, {old}, {days}, {count} are filled in at runtime.
-- Messages avoid he/she on purpose: we don't know a pet's gender.

local _, KT = ...

local L = {}
KT.L = L

L.PREFIX = "|cffff8fb1Wayfarer's Tales|r "

L.TIERS = {
  "New Acquaintance",
  "Companion",
  "Faithful Friend",
  "Close Friend",
  "Unbreakable Bond",
  "Kindred Spirits",
}

L.TIER_DESC = {
  "You are just getting to know each other.",
  "A real complicity is starting to grow.",
  "You have already shared fine adventures.",
  "Your complicity is obvious to everyone.",
  "You are almost inseparable.",
  "An exceptional bond.",
}

L.HAPPINESS = { "Unhappy", "Content", "Happy" }

L.FOOD_KINDS = { meat = "meat", fish = "fish", cheese = "cheese", bread = "bread", fungus = "mushrooms", fruit = "fruit" }
L.MOODS = { playful = "Playful", sleepy = "Sleepy", cuddly = "Cuddly", curious = "Curious", hungry = "Peckish" }

L.MEMORY = {
  met           = "Your tale together began in {zone}.",
  zone          = "First journey to {zone} together.",
  playerLevel   = "You reached level {level} together.",
  petLevel      = "{pet} reached level {level}.",
  firstCuddle   = "First cuddle.",
  firstFeed     = "First snack from your hand.",
  firstMeal     = "First shared meal.",
  firstCampfire = "First rest together by a campfire.",
  tier          = "Your bond grew: {tier}.",
  loyalty       = "Loyalty grew: {loyalty}.",
  rename        = "{old} became {pet}.",
  kills         = "{count} adventures together.",
  reunion       = "Reunited after {days} days apart.",
  favorite      = "Discovered that {pet} loves {food}!",
  dislike       = "Learned that {pet} isn't a fan of {food}.",
  days          = "{days} days together.",
  anniversary   = "{years} year(s) together!",
}

-- Tooltip / command texts
L.TT_SCORE      = "Affection: %d / 100"
L.TT_NEXT       = "Next: %s at %d"
L.TT_LOYALTY    = "Loyalty: %s"
L.TT_HAPPINESS  = "Happiness: %s"
L.TT_TOGETHER   = "Time together: %s"
L.TT_STATS      = "%d adventures, %d shared meals, %d campfires"
L.TT_MEAL       = "%s is waiting for a bite of your food!"
L.TT_HINT       = "Click or type /wt for more."
L.TT_MOOD       = "Mood today: %s"
L.TT_FAVORITE   = "Favorite food: %s"
L.TT_DISLIKE    = "Not a fan of: %s"
L.TT_SECRET     = "??? (try feeding different foods!)"

-- Window
L.UI_TAB_COMPANION = "Companion"
L.UI_TAB_GUIDE     = "Guide"
L.UI_TAB_OPTIONS   = "Options"
L.UI_LEVEL         = "level"
L.UI_TOGETHER      = "Together"
L.UI_MEMORIES      = "Memories"
L.UI_OTHERS        = "Your other companions"
L.UI_STATS = "Time together: %s\nAdventures: %d\nTimes fed: %d\nShared meals: %d\nCampfire rests: %d\nCuddles: %d"
L.UI_OPT_CHATTY    = "How often does your pet speak up?"
L.UI_CHATTY = { [0] = "Big moments", [1] = "Quiet", [2] = "Normal", [3] = "Chatty" }
L.UI_CHATTY_DESC = {
  [0] = "Only important moments: new bond stages, loyalty, shared meals, campfire rests...",
  [1] = "Your pet reacts about half as often as normal.",
  [2] = "The default balance.",
  [3] = "Your pet reacts to almost everything. Great for testing!",
}
L.UI_OPT_MINIMAP = "Show the minimap button"
L.UI_OPT_HEART   = "Show the heart next to the happiness icon"
L.UI_OPT_DEBUG   = "Debug mode (technical messages in chat)"
L.UI_OPT_LABEL   = "Show \"Wayfarer's Tales\" before your pet's messages"
L.UI_TAB_JOURNAL = "Journal"
L.UI_MODULES     = "Modules"
L.UI_MOD_KINDRED = "Pet companionship (Kindred)"
L.UI_KINDRED_OFF = "The pet companionship module is turned off. You can turn it back on in the Options tab."
L.UI_JOURNAL_EMPTY = "Your journal is empty for now. Every line of your story will be written here."
L.UI_JOURNAL_PAGE  = "Page %d / %d"
L.UI_JOURNAL_FLAGGED = "%d flagged"
L.UI_JOURNAL_COPY  = "Report & ideas"
L.UI_REPORT_IDEAS  = "--- Your ideas & comments (type below, then copy everything) ---"
L.UI_JOURNAL_FLAG_TT = "Flag this line if it felt wrong or out of place (click again to unflag). Flagged lines go into the report."
L.UI_JOURNAL_COPY_HELP = "Add your ideas at the bottom if you like, then press Ctrl+A and Ctrl+C to copy, and paste it in a message to the addon's author."
L.UI_JOURNAL_NOFLAGS = "No flagged lines yet. Use the ! button next to a line in the Journal, or type /wt nope right after an odd line."
L.CMD_NOPE       = "Flagged: %s"
L.CMD_NOPE_NONE  = "Nothing to flag yet."
L.UI_OPT_SOUND   = "Sounds (your pet's voice, chimes for big moments)"
L.CMD_SOUND_TEST = "Sound test for your %s (sound set: %s):"
L.UI_OPT_NOTE    = "Your pet's messages are only visible to you. Affection can drop a little (rude emotes, your pet falling in combat, long stays in the stable), but never below a bond stage you have reached."
L.UI_MINIMAP_CLICK = "Click: open the window"
L.UI_MINIMAP_DRAG  = "Drag: move this button"

L.GUIDE = table.concat({
  "|cffffd100Your story together|r",
  "Every hunter pet has its own affection score, from 0 to 100. It grows as you care for your pet and live adventures together. Everything is cosmetic and stays on your computer.",
  "",
  "|cffffd100Bond stages|r",
  "0  New Acquaintance\n20  Companion\n40  Faithful Friend\n60  Close Friend\n80  Unbreakable Bond\n100  Kindred Spirits",
  "Your pet's reactions change with your bond: shy at first, then friendly (40+), then devoted (80+).",
  "",
  "|cffffd100Growing your bond|r",
  "Your pet never spells it out: watch its reactions in the chat, they tell you when a moment is waiting for you.",
  "|cffff8fb1Cuddles|r  /pet /hug /love /cuddle /kiss /soothe /comfort /praise /pat /tickle on your pet: +1 (once every 15 min). After a hard fight, comfort it soon after reviving it!",
  "|cffff8fb1Feeding|r  +1 (once every 10 min). Your pet has a secret favorite food (+2) and a food it doesn't like (nothing). Feed it different things to find out!",
  "|cffff8fb1Shared meals|r  Sometimes, when you sit down to eat, your pet asks for a bite. Feed it within 2 minutes: +4 for the same food, +2 for another.",
  "|cffff8fb1Petting requests|r  Now and then your pet asks for attention. /pet within 2 minutes: +2",
  "|cffff8fb1Campfires|r  Sit down by a campfire with your pet: +2",
  "|cffff8fb1Treats|r  When your pet notices food you just looted, feed it that food within 2 minutes: +2",
  "|cffff8fb1Celebrations|r  When your pet levels up, cheer within 2 minutes (/cheer /clap /applaud /bravo /woot): +1",
  "|cffff8fb1Adventures|r  Fighting together and simply spending time together slowly add up.",
  "|cffff8fb1Big moments|r  Level-ups, loyalty milestones, reunions after a long time apart, and anniversaries.",
  "",
  "|cffffd100Emotes|r",
  "|cffff8fb1Playful|r  /dance /cheer /flex /silly /bounce /clap /laugh /giggle /joke: a shy pet is puzzled, a friend joins in (+0.5)",
  "|cffff8fb1Silly|r  /chicken /roar: try them and see...",
  "|cffff8fb1Rest|r  /sleep /sit /kneel /yawn /tired",
  "|cffff8fb1Sadness|r  /cry /sigh /mourn: a close friend comes to comfort you (+0.5)",
  "|cffff8fb1Hello|r  /wave /hello /bow /salute /welcome",
  "|cffff8fb1Hunger|r  /hungry /eat",
  "|cffff8fb1Rude|r  /slap /rude /spit /insult /angry /punch /kick /shoo /threaten /glare: -1. A /sorry within 10 minutes gives back +0.5.",
  "Many of these also get a reaction when you don't target your pet.",
  "",
  "|cffffd100Every day is different|r",
  "Your pet has a mood of the day (playful, sleepy, cuddly, curious or peckish) that changes how it behaves. It also notices new places, campfires, fish you catch, food you loot, the night, water, cities, and when you doze off (auto-AFK).",
  "",
  "|cffffd100Gentle drops|r",
  "Rude emotes, your pet falling in combat (-1) and long stays in the stable (-1 per week) lower affection a little. It never drops below a bond stage you have reached.",
  "",
  "|cffffd100Commands|r",
  "/wt  open this window\n/wt nope  flag the last line as odd\n/wt status  short summary in chat\n/wt memories  your memories in chat\n/wt chatty 0-3  how often your pet speaks up\n/wt sound  hear your pet's sounds\n/wt debug  technical messages\n(/kt still works too)",
}, "\n")

L.CMD_HELP = {
  "/wt - open the Wayfarer's Tales window",
  "/wt status - your pet's story so far, in chat",
  "/wt memories - your memories together",
  "/wt chatty 0-3 - how often your pet speaks up: 0 = only big moments, 1 = quiet, 2 = normal (default), 3 = very chatty",
  "/wt debug - show technical info (for testing)",
  "/wt nope - flag the last line as wrong or odd",
  "/wt sound - hear your pet's sounds",
  "/wt guide, /wt journal, /wt options - open a tab of the window",
  "/wt resetvisits - forget visited places and line cooldowns (for testing)",
}
L.CMD_STATUS_HINT = "Type |cffffd100/wt help|r for all commands."
L.CMD_NO_PET     = "No hunter pet is out right now."
L.CMD_CHATTY     = "Chattiness set to %d."
L.CMD_DEBUG      = "Debug mode: %s"
L.CMD_NO_MEMORY  = "No memories yet. Your story is just beginning!"
L.LOADED_FIRST   = "is installed! Summon your pet and look for the heart next to its happiness icon. Type /wt to open the window."
L.ERROR          = "ran into a problem (please report it): %s"
L.UI_OPT_LANGUAGE = "Language"

-- Message pools: one is picked at random each time.
local M = {}
KT.Messages = M

M.newPet = {
  "A new tale begins: you and {pet}.",
}
M.newPetHistory = {
  "{pet}'s tale begins here. Your loyalty together already says a lot: you start as {tier}.",
}
M.rename = {
  "{old} will now answer to the name {pet}. A new chapter begins!",
}
M.summon = {
  "{pet} shakes off and trots to your side.",
  "{pet} looks up at you, ready for adventure.",
  "{pet} sniffs the air and settles in beside you.",
  "{pet} stretches lazily, then falls into step with you.",
}
M.reunion = {
  "{pet} bounds over to you, overjoyed to see you again!",
  "{pet} circles around you happily. It's been a while!",
  "{pet} nuzzles your hand as if to ask: where have you been?",
}
M.stableReunion = {
  "{pet} is back from the stables and bursting with joy!",
  "{pet} rushes out of the stables and straight to your side.",
}
M.stableMissed = {
  "{pet} missed you a lot while you were apart.",
}
-- Pools with three lists are "banded": [1] shy (0-39), [2] friendly (40-79), [3] devoted (80+).
M.affection = {
  {
    "{pet} flinches at first, then lets you pet a little.",
    "{pet} sniffs your hand cautiously before accepting the touch.",
    "{pet} holds very still, unsure, but doesn't pull away.",
    "{pet} leans in just a tiny bit. It's a start!",
  },
  {
    "{pet} leans happily into your hand.",
    "{pet} closes both eyes and enjoys the moment.",
    "{pet} rumbles contentedly.",
    "{pet} nudges you for more.",
    "{pet} gives you a long, trusting look.",
  },
  {
    "{pet} melts into your arms, completely at ease.",
    "{pet} rests against you and sighs with pure happiness.",
    "{pet} nuzzles you back, as if to say: you're my favorite.",
    "{pet} rolls over for a belly rub without a second thought.",
  },
}
M.playful = {
  {
    "{pet} watches you warily, not sure what you're doing.",
    "{pet} takes a step back. Is this normal behavior?",
    "{pet} stares at your antics, deeply confused.",
  },
  {
    "{pet} hops around you, trying to join in!",
    "{pet} bounces playfully at your side.",
    "{pet} lets out an excited little growl and joins the fun.",
  },
  {
    "{pet} joins in enthusiastically, as if you'd rehearsed this together!",
    "{pet} spins around with you, absolutely delighted.",
    "{pet} does a clumsy little dance too, very proudly.",
  },
}
M.chicken = {
  {
    "{pet}'s eyes narrow. Was that... prey?",
    "{pet} watches you cluck around and slowly backs away.",
  },
  {
    "{pet} starts stalking you playfully. Cluck at your own risk!",
    "{pet} crouches low, tail twitching, ready to pounce on the chicken.",
  },
  {
    "{pet} pounces on you gently, playing along with your chicken act.",
    "{pet} chases you in circles. Best game ever!",
  },
}
M.roar = {
  {
    "{pet} flattens both ears at your roar.",
    "{pet} jumps, startled by the noise.",
  },
  {
    "{pet} roars back proudly!",
    "{pet} answers with a mighty roar of approval.",
  },
  {
    "{pet} roars with you. The whole land knows you're a pack.",
    "{pet} throws back a head and roars along. What a duo!",
  },
}
M.rest = {
  {
    "{pet} lies down a few steps away, keeping watch.",
    "{pet} settles nearby, still a little wary.",
  },
  {
    "{pet} curls up next to you.",
    "{pet} yawns too and lies down at your feet.",
  },
  {
    "{pet} snuggles against you, warm and safe.",
    "{pet} rests against your lap and dozes off immediately.",
  },
}
M.sad = {
  {
    "{pet} looks at you, unsure what to do.",
    "{pet} watches you from a distance, ears low.",
  },
  {
    "{pet} comes closer and sits quietly beside you.",
    "{pet} nudges your hand gently.",
  },
  {
    "{pet} presses against you and licks your hand. You're not alone.",
    "{pet} won't leave your side until you feel better.",
  },
}
M.greet = {
  { "{pet} glances up at you, curious.", "{pet} blinks at you." },
  { "{pet} perks up and greets you back.", "{pet} trots over to say hello." },
  { "{pet} greets you with a joyful little bounce.", "{pet} rushes over as if you'd been gone for ages." },
}
M.hungry = {
  "{pet}'s stomach rumbles in agreement.",
  "{pet} looks at you, then at your bags. Hint, hint.",
  "{pet} licks both chops hopefully.",
}
M.rude = {
  {
    "{pet} cowers and backs away from you.",
    "{pet} growls nervously.",
  },
  {
    "{pet} flattens both ears and looks hurt.",
    "{pet} turns away, sulking.",
  },
  {
    "{pet} looks at you with big, sad eyes. What did I do?",
    "{pet} seems confused and a little hurt, but stays by your side.",
  },
}
M.sorryForgive = {
  {
    "{pet} hesitates... then slowly comes back to you.",
    "{pet} keeps a wary distance, but the ears come back up.",
  },
  {
    "{pet} forgives you with a gentle nudge.",
    "{pet} sniffs your hand and decides you're forgiven.",
  },
  {
    "{pet} was never really angry. All is forgiven.",
    "{pet} licks your hand as if nothing happened.",
  },
}
M.sorryNothing = {
  "{pet} doesn't know what you're sorry for, but accepts a scratch anyway.",
}
M.afkDoze = {
  { "You doze off. {pet} lies down nearby, one eye open, keeping watch." },
  { "You doze off. {pet} curls up at your feet." },
  { "You doze off. {pet} snuggles against you and dozes off too." },
}
M.afkBack = {
  "You stir. {pet} stretches and yawns.",
  "{pet} perks up as you wake. Time to go?",
}
M.afkBackLong = {
  { "{pet} stayed close by the whole time you were away." },
  { "{pet} kept watch the whole time you were away, and is glad you're back." },
  { "{pet} never left your side while you were away. Not even once." },
}
M.greetMorning = {
  "Good morning! {pet} stretches and yawns, happy to start the day with you.",
  "{pet} greets you with a sleepy morning nuzzle.",
  "A new day begins, and {pet} is already eager for adventure!",
  "{pet} is already up, sniffing the morning air.",
  "{pet} stretches out from nose to toes, then comes to say good morning.",
}
M.greetAfternoon = {
  "{pet} trots over to greet you. What's the plan this afternoon?",
  "{pet} was having a little nap, but jumps up to greet you.",
  "{pet} perks up the moment you arrive.",
  "{pet} greets you happily. Off we go for the afternoon?",
  "{pet} was watching the path, waiting for you.",
}
M.greetEvening = {
  "Good evening! {pet} is glad to see you.",
  "{pet} greets you as the evening settles in.",
  "{pet} comes to sit next to you as the light fades.",
  "{pet} greets you softly. A quiet evening ahead?",
  "{pet} seems glad the day isn't over yet.",
}
M.greetNight = {
  "{pet} blinks sleepily at you. Adventuring at this hour?",
  "A late-night adventure? {pet} is in, of course.",
  "{pet} yawns, then shuffles over to you anyway.",
  "{pet} keeps close. The night is quiet.",
  "{pet} opens one eye, sees you, and gets up at once.",
}
M.newZone = {
  "{pet} sniffs the air of {zone}. A new chapter of your tale!",
  "First steps in {zone} together. {pet} looks around, wide-eyed.",
  "{zone}! {pet} has never smelled anything quite like it.",
}
M.playerLevel = {
  { "Level {level}! {pet} watches the glow around you with curiosity." },
  { "Level {level}! {pet} bounces around you in celebration." },
  { "Level {level}! {pet} is bursting with pride. You did it together!" },
}
M.petLevel = { -- must invite a cheer by itself (no hint in chat)
  "{pet} has grown stronger: level {level}! And keeps glancing at you, clearly waiting for some applause.",
  "{pet} reached level {level} and stands tall, looking at you as if waiting for your cheers.",
  "Level {level} for {pet}! A very expectant look your way: surely this deserves a little celebration?",
}
M.feedFavoriteFirst = {
  "{pet} goes absolutely wild for the {item}! Looks like {food} is a favorite!",
}
M.favoriteRevealed = {
  "{pet} looks especially delighted. Looks like {food} is a favorite!",
}
M.feedFavorite = {
  "{pet} devours the {item} with pure joy. Nothing beats {food}!",
  "{pet}'s eyes light up: {item}! The best!",
  "{pet} finishes the {item} in seconds and looks at you hopefully for more.",
}
M.feedDislikeFirst = {
  "{pet} inspects the {item}... and eats it, very reluctantly. Not a fan of {food}, it seems.",
}
M.feedDislike = {
  "{pet} eats the {item} with zero enthusiasm.",
  "{pet} gives you a look. {food} again?",
}
M.lootFavorite = {
  "{pet} spots your {item} and can barely contain the excitement!",
  "{pet} has eyes only for your {item} now.",
}
-- treat requests: must ask for the food by themselves (no hint in chat)
M.treatAsk = {
  "{pet} looks at your {item}, then at you, then at your {item} again. The message is clear.",
  "{pet} has noticed your {item} and won't stop staring at you. Surely that one's for sharing?",
  "{pet} won't leave your side, eyes fixed on your {item}. A treat, perhaps?",
}
M.treatAskFavorite = {
  "{pet} spots your {item} and can barely contain the excitement. Please, please share?",
  "{pet} has eyes only for your {item}... and for you, who could share it.",
}
M.treatGiven = {
  "{pet} gobbles down the {item} you just found. Best. Treat. Ever.",
  "{pet} was hoping you'd share the {item}, and you did!",
  "{pet} can hardly believe it: the {item}, shared right away!",
}
M.celebrated = {
  "{pet} puffs up with pride at your cheers!",
  "{pet} prances around, soaking up the applause.",
  "{pet} looks at you, beaming. That level was for you too.",
}
M.mood_playful = { "{pet} seems full of energy today!" }
M.mood_sleepy  = { "{pet} seems a bit sleepy today." }
M.mood_cuddly  = { "{pet} seems extra cuddly today." }
M.mood_curious = { "{pet} seems very curious today." }
M.mood_hungry  = { "{pet} seems a little peckish today." }
M.idleMood_playful = {
  "{pet} pounces on a falling leaf.",
  "{pet} darts ahead, then comes racing back.",
}
M.idleMood_sleepy = {
  "{pet} yawns for the third time in a row.",
  "{pet} drags along slowly, eyes half closed.",
}
M.idleMood_cuddly = {
  "{pet} keeps brushing against you as you walk.",
  "{pet} stays glued to your side today.",
}
M.idleMood_curious = {
  "{pet} investigates absolutely everything along the way.",
  "{pet} stops to examine a strange rock.",
}
M.idleMood_hungry = {
  "{pet} keeps glancing at your bags.",
  "{pet} looks at you, then at your bags, then at you again.",
}
M.modePassive    = { "{pet} settles down, calm and gentle.", "{pet} relaxes. No fighting for now." }
M.modeDefensive  = { "{pet} stands guard at your side.", "{pet} stays alert, ready to protect you." }
M.modeAggressive = { "{pet} looks ready for a fight!", "{pet} is itching for some action!" }
M.daysTogether = {
  "{days} days together already! {pet} has come a long way with you.",
}
M.anniversary = {
  "A special day: {years} year(s) since your tale with {pet} began!",
}
M.otherEmote = {
  "{pet} looks at you curiously.",
  "{pet} watches you, puzzled.",
}
M.attentionRequest = {
  {
    "{pet} hesitantly approaches and sniffs your hand.",
    "{pet} sits a little closer than usual, glancing at you.",
  },
  {
    "{pet} nudges your hand, asking for some attention.",
    "{pet} drops down at your feet and looks up expectantly.",
  },
  {
    "{pet} headbutts you gently. Pets. Now. Please.",
    "{pet} flops over right in front of you, demanding cuddles.",
  },
}
M.attentionAnswered = {
  {
    "{pet} accepts the touch, and seems to relax for the first time.",
    "{pet}'s tail gives a small, shy wag.",
  },
  {
    "{pet} wiggles with joy. That was exactly what was needed!",
    "{pet} leans into your hand with a happy sigh.",
  },
  {
    "{pet} is in heaven. You know each other so well.",
    "{pet} rumbles with pure bliss.",
  },
}
M.attentionExpired = {
  "{pet} wanders off, sniffing the ground.",
}
M.comfort = {
  "{pet} presses close to you. Your comfort means a lot after that fight.",
  "{pet} lets out a small sigh of relief at your touch.",
}
M.feed = {
  "{pet} munches on the {item} happily.",
  "{pet} gobbles up the {item} in no time.",
  "{pet} eats the {item}, then licks up the last crumbs.",
  "{pet} savors the {item}, very pleased with you.",
}
M.lootFood = {
  "{pet} stares at your {item} with hungry eyes.",
  "{pet} sniffs your bag. That {item} smells interesting...",
  "{pet} has noticed the {item}. Very much noticed it.",
}
M.fishing = {
  "{pet} watches the {item} flop around, fascinated.",
  "{pet} eyes the fresh {item}. Is that for sharing?",
  "{pet} creeps closer to the {item}, nose twitching.",
}
M.cooking = {
  "The smell of {item} makes {pet}'s nose twitch.",
  "{pet} sits very politely next to the {item}. Very, very politely.",
}
M.mealRequest = {
  "{pet} sits beside you and stares at your {item}. Maybe a bite to share?",
  "{pet} gently paws at your arm, eyes fixed on your {item}.",
  "{pet} sniffs hopefully as you eat your {item}...",
}
M.mealShared = {
  "You share your {item} with {pet}. A meal is better together!",
  "{pet} happily eats the {item} you shared. What a feast!",
}
M.mealOther = {
  "{pet} was hoping for {item}, but this is good too!",
}
M.mealExpired = {
  "{pet} gives up and lies down with a small sigh.",
}
M.campfireNear = {
  "{pet} perks up. A campfire is nearby!",
  "{pet}'s nose lifts toward the smell of woodsmoke.",
}
M.campfireRest = {
  "You and {pet} settle down by the fire. These quiet moments matter.",
  "{pet} curls up by the fire, warm and content.",
  "The fire crackles softly. {pet} rests close to you.",
}
M.campfireEnergized = {
  "{pet} stretches, warm and rested, ready to get back to the adventure!",
  "{pet} looks energized and eager for what comes next.",
  "{pet} gets up full of energy. Onward!",
}
M.kill = {
  "{pet} shakes off after the fight, proud of your teamwork.",
  "{pet} gives you a look that says: we make a good team.",
}
M.death = {
  "{pet} is down... Rest now, brave friend.",
  "{pet} fought bravely and fell.",
}
M.revive = {
  "{pet} gets back up, a little shaken. Some comfort would help.",
}
M.petHungry = { -- happiness dropped: the pet is getting hungry
  "{pet}'s stomach rumbles loudly. Someone is hungry.",
  "{pet} keeps glancing at your bags. Snack time?",
}
M.idle = {
  {
    "{pet} sniffs around, exploring.",
    "{pet} keeps a little distance, watching you.",
    "{pet} stops to scratch an ear, then hurries to catch up.",
    "{pet} investigates a suspicious bush.",
  },
  {
    "{pet} sniffs a flower curiously.",
    "{pet} yawns widely.",
    "{pet} watches a butterfly drift by.",
    "{pet} sticks close to your side.",
    "{pet} trots ahead, then looks back to check you're following.",
  },
  {
    "{pet} bumps against your leg affectionately while walking.",
    "{pet} looks up at you with total trust.",
    "{pet} brings you a stick. Or maybe a bone. Best not to ask.",
    "{pet} walks so close to you that you almost trip. Worth it.",
  },
}
M.idleSwimming = {
  "{pet} paddles happily beside you.",
  "{pet} shakes off water all over you. Thanks.",
}
M.idleResting = {
  "{pet} sniffs at all the new smells around.",
  "{pet} watches the passers-by with great interest.",
}
M.idleNight = {
  "{pet} gazes up at the stars for a moment.",
  "{pet} stays a little closer in the dark.",
}
M.followAfterStay = {
  "{pet} bounds back to your side, delighted to be called!",
  "{pet} has waited patiently and comes running at last.",
}
M.tierUp = {
  "Your bond with {pet} has grown: |cffffd100{tier}|r!",
}
---------------------------------------------------------------------------
-- Body-type versions. "pool_bird", "pool_scaly", "pool_chitin" replace "pool"
-- for those pets. Furry pets (bears, wolves, cats...) use the normal pools.
---------------------------------------------------------------------------

-- Birds (owls, carrion birds, tallstriders)
M.campfireNear_bird = {
  "{pet} fluffs up at the warmth of a nearby campfire.",
  "{pet} turns toward the crackling of a nearby fire.",
}
M.campfireRest_bird = {
  "{pet} perches by the fire, feathers puffed up, perfectly content.",
  "{pet} tucks in by the fire and half-closes both eyes.",
}
M.affection_bird = {
  { "{pet} ruffles at your touch, unsure, but stays put.", "{pet} eyes your hand, then allows a careful scratch." },
  { "{pet} leans into your hand and coos softly.", "{pet} fluffs up happily under your fingers." },
  { "{pet} nibbles your fingers gently. That's love, bird style.", "{pet} tucks against you and chirps contentedly." },
}
M.playful_bird = {
  { "{pet} watches your moves, deeply baffled." },
  { "{pet} bobs up and down to your rhythm!", "{pet} flaps around you, joining in!" },
  { "{pet} spreads both wings and dances along, delighted." },
}
M.chicken_bird = {
  "{pet} watches your chicken act with deep professional offense.",
  "{pet} squawks back at you. Is this a challenge?",
}
M.attentionRequest_bird = {
  "{pet} chirps insistently at you. Attention, please!",
  "{pet} hops right in front of you and refuses to move.",
}
M.attentionAnswered_bird = { "{pet} chirps happily and fluffs up." }
M.mealRequest_bird = {
  "{pet} hops closer and eyes your {item} with great interest.",
  "{pet} watches your {item} with a sideways look. Sharing is caring?",
}
M.lootFood_bird = { "{pet} eyes your {item} and gives a hopeful chirp." }
M.treatAsk_bird = { "{pet} eyes your {item} and gives a hopeful chirp. Is that one for sharing?" }
M.fishing_bird = { "{pet} stares at the {item} with the focus of a born hunter." }
M.hungry_bird = { "{pet} chirps hungrily in agreement." }
M.rude_bird = {
  { "{pet} flutters back, alarmed." },
  { "{pet} ruffles up and turns away, offended." },
  { "{pet} looks at you, hurt, feathers drooping." },
}
M.sad_bird = {
  { "{pet} watches you quietly from a distance." },
  { "{pet} hops closer and sits beside you." },
  { "{pet} snuggles against you, feathers warm. You're not alone." },
}
M.sorryForgive_bird = { "{pet} fluffs up again. You're forgiven." }
M.idle_bird = {
  "{pet} preens a few feathers.",
  "{pet} hops after a beetle.",
  "{pet} stretches both wings, then folds them neatly.",
}

-- Scaly (crocolisks, raptors, turtles, wind serpents)
M.campfireNear_scaly = {
  "{pet} turns toward the warmth of a nearby campfire. Basking time?",
  "{pet} flicks a tongue at the smoky air.",
}
M.campfireRest_scaly = {
  "{pet} stretches out by the fire, soaking up the heat with great satisfaction.",
}
M.affection_scaly = {
  { "{pet} goes very still under your hand, watching you." },
  { "{pet} closes both eyes slowly, enjoying the scratch." },
  { "{pet} leans fully against you with a deep, contented rumble." },
}
M.attentionRequest_scaly = { "{pet} nudges your leg with a cool snout, asking for attention." }
M.attentionAnswered_scaly = { "{pet} rumbles contentedly." }
M.mealRequest_scaly = { "{pet} stares at your {item} without blinking. At all." }
M.lootFood_scaly = { "{pet}'s tongue flicks at the scent of your {item}." }
M.treatAsk_scaly = { "{pet}'s tongue flicks at the scent of your {item}, eyes fixed on you. A treat, perhaps?" }
M.fishing_scaly = { "{pet} watches the {item} very, very closely." }
M.hungry_scaly = { "{pet}'s tongue flicks hungrily." }
M.rude_scaly = {
  { "{pet} hisses and backs away." },
  { "{pet} gives you a cold, unblinking stare." },
  { "{pet} looks hurt, but stays by your side." },
}
M.sad_scaly = {
  { "{pet} watches you, unsure." },
  { "{pet} lies down close to you." },
  { "{pet} rests a heavy head against you. You're not alone." },
}
M.sorryForgive_scaly = { "{pet} blinks slowly. Forgiven." }
M.idle_scaly = {
  "{pet} basks in a patch of sunlight.",
  "{pet} flicks a tongue curiously at the air.",
  "{pet} blinks slowly, perfectly calm.",
}

-- Chitin (spiders, scorpids, crabs)
M.campfireNear_chitin = {
  "{pet} clicks curiously at the smell of smoke.",
  "{pet} scuttles a little faster toward the warmth.",
}
M.campfireRest_chitin = { "{pet} settles by the fire, legs tucked in, quietly content." }
M.affection_chitin = {
  { "{pet} raises a leg warily, then lowers it again." },
  { "{pet} clicks softly under your hand." },
  { "{pet} taps your arm gently, a gesture saved only for you." },
}
M.attentionRequest_chitin = { "{pet} taps your boot several times. Attention requested." }
M.attentionAnswered_chitin = { "{pet} clicks with delight." }
M.mealRequest_chitin = { "{pet} clicks hungrily at the sight of your {item}." }
M.lootFood_chitin = { "{pet} clicks excitedly at your {item}." }
M.treatAsk_chitin = { "{pet} clicks excitedly at your {item}, then turns to you. Sharing?" }
M.fishing_chitin = { "{pet} snaps at the air near the {item}. Hungry?" }
M.hungry_chitin = { "{pet} clicks hungrily in agreement." }
M.rude_chitin = {
  { "{pet} rears up defensively." },
  { "{pet} scuttles away and sulks." },
  { "{pet} seems hurt, but stays close." },
}
M.sad_chitin = {
  { "{pet} clicks uncertainly." },
  { "{pet} settles right next to you." },
  { "{pet} won't leave your side until you feel better." },
}
M.sorryForgive_chitin = { "{pet} clicks softly. Forgiven." }
M.idle_chitin = {
  "{pet} scuttles after a tiny bug.",
  "{pet} taps the ground curiously.",
  "{pet} cleans a leg with great care.",
}

M.loyaltyUp = {
  "{pet}'s loyalty has grown: |cffffd100{loyalty}|r!",
}

---------------------------------------------------------------------------
-- Elements module (body comfort). Lines speak about YOU, so they stay true
-- whatever the weather looks like: no "the snow falls", only what you feel.
---------------------------------------------------------------------------

L.UI_TAB_BODY     = "Body"
L.UI_MOD_ELEMENTS = "Body comfort (Elements): cold, heat, wetness, thirst"
L.EL_TITLE        = "Body comfort"
L.EL_TEMP         = "Temperature: %s"
L.EL_TEMP_STATES  = { freezing = "Freezing", cold = "Cold", ok = "Comfortable", hot = "Hot", overheat = "Overheating" }
L.EL_WET          = "Wetness: %d%%"
L.EL_THIRST       = "Thirst: %s"
L.EL_HUNGER       = "Hunger: %s"
L.EL_ENERGY       = "Energy: %s"
L.EL_NEED_STATES  = { ok = "Fine", thirsty = "Thirsty", parched = "Parched", hungry = "Hungry", starving = "Starving",
  tired = "Tired", exhausted = "Exhausted" }
L.UI_OPT_THERMO   = "Show the thermometer by the minimap"
L.UI_OPT_GENDER   = "Your character (for grammar in French)"
L.UI_GENDER_AUTO  = "Auto"
L.UI_GENDER_M     = "Male"
L.UI_GENDER_F     = "Female"
L.UI_GENDER_N     = "Neutral"
L.EL_THERMO_TITLE = "Thermometer"
L.EL_AIR          = "Air: %s"
L.EL_YOU_FEEL     = "You feel: %s"
L.EL_THERMO_HINT  = "Click: body comfort. Right-click: °C / °F. Drag: move."
L.EL_CLIMATE      = { [-2] = "freezing climate", [-1] = "cold climate", [0] = "mild climate", [1] = "warm climate", [2] = "scorching climate" }
L.EL_INDOORS      = "indoors"
L.EL_NIGHT        = "night"
L.EL_FIRE         = "near a fire"
L.EL_SWIMMING     = "in the water"
L.EL_HERE         = "Here: %s"
L.EL_MOVE_HINT    = "Click: details. Shift + drag: move."
L.EL_OFF          = "The body comfort module is turned off. You can turn it back on in the Options tab."
L.EL_PAGE_INTRO   = "How your character feels. Pure flavor: nothing here changes your stats."
L.EL_PAGE_TIPS    = "Warm up: a campfire, an inn, any roof over your head.\nCool down: get indoors, wait for the night, take a swim.\nDry off: time, and much faster by a fire.\nThirst: drink anything. It drops faster in the heat.\nHunger: sit down and eat.\nEnergy: rest at an inn or in a city, sit by a campfire, or doze off a while."
L.EL_GUIDE = table.concat({
  "|cffffd100Body comfort (Elements)|r",
  "Your character feels the cold, the heat, the water, thirst, hunger and tiredness, and tells you about it in the chat. The Body tab shows the details. (In Options, you can also show icons or bars by your portrait.)",
  "|cffff8fb1Cold & heat|r  Each zone has its own climate. Nights are colder outside. Campfires, inns and roofs warm you up; being wet chills you.",
  "|cffff8fb1Wetness|r  Swimming soaks you. You dry off over time, faster in the heat or by a fire.",
  "|cffff8fb1Thirst|r  Slowly grows over time, faster in hot zones and in combat. Drinking anything quenches it.",
  "|cffff8fb1Hunger|r  Grows over about two hours, faster in combat or when you're cold. Eating fills you up.",
  "|cffff8fb1Energy|r  After a few hours of adventuring you get tired. Rest at an inn or in a city, sit by a campfire, or doze off.",
  "|cffff8fb1Thermometer|r  The button by the minimap shows the air temperature. Your body follows it, but being wet, a fire or an inn change how you feel.",
}, "\n")

M.coldEnter = {
  "A chill runs down your spine.",
  "The cold starts to bite at your fingers.",
  "You pull your collar tighter against the cold.",
}
M.freezingEnter = {
  "You're shivering hard now. You need warmth.",
  "Your teeth chatter. Your fingers are going numb.",
}
M.coldRemind = {
  "You shiver.",
  "You rub your hands together to warm them.",
  "The tip of your nose is freezing.",
}
M.freezingRemind = {
  "You can barely feel your fingers.",
  "The cold is getting into your bones.",
}
M.warmBack = {
  "Warmth slowly returns to your fingers.",
  "You finally stop shivering.",
}
M.hotEnter = {
  "Sweat beads on your forehead.",
  "The heat is starting to weigh on you.",
}
M.overheatEnter = {
  "The heat is overwhelming. You need to cool down.",
  "Your head is spinning a little in this heat.",
}
M.hotRemind = {
  "You wipe the sweat from your brow.",
  "Your clothes stick to your skin.",
}
M.overheatRemind = {
  "The heat is crushing.",
  "Every step feels heavier in this heat.",
}
M.coolBack = {
  "You feel cooler now.",
  "What a relief to cool down.",
}
M.soaked = {
  "Your clothes are soaked through.",
  "Water drips from your clothes with every step.",
}
M.dry = {
  "Your clothes are finally dry.",
}
M.body_thirsty = {
  "Your throat feels dry.",
  "You could use a drink.",
}
M.body_parched = {
  "Your lips are cracked. You need water.",
  "You'd give anything for a sip of water.",
}
M.drinkRelief = {
  "Ah, that's better.",
  "That drink tastes wonderful.",
}
-- body_ prefix: these are about YOU (the pet has its own "hungry" emote reaction)
M.body_hungry = {
  "Your stomach growls.",
  "You could eat something.",
}
M.body_starving = {
  "You feel weak with hunger.",
  "Your stomach aches. You need to eat.",
}
M.eatRelief = {
  "That hit the spot.",
  "Much better. Your stomach is happy.",
}
M.body_tired = {
  "You yawn.",
  "Your eyelids feel heavy.",
}
M.body_exhausted = {
  "You're running on fumes. A rest would do you good.",
  "Every step costs you. You need a real rest.",
}
M.restRelief = {
  "You feel refreshed and ready to go.",
  "Your strength has come back.",
}
M.fireWarm = {
  "The warmth of the fire is a blessing.",
  "You soak up the warmth of the fire.",
}
M.indoorsWarm = {
  "It's warmer in here.",
  "Out of the cold at last.",
}

---------------------------------------------------------------------------
-- Senses module (immersion lines). The lines themselves are in SensesData.lua.
---------------------------------------------------------------------------

L.UI_TAB_SENSES   = "Ambiance"
L.UI_MOD_SENSES   = "Immersion lines (Senses)"
L.UI_OPT_RHYTHM   = "How often immersion lines appear"
L.UI_RHYTHM       = { [0] = "Never", [1] = "Rare", [2] = "Normal", [3] = "Often" }
L.SN_OFF          = "The immersion module is turned off. You can turn it back on in the Options tab."
L.SN_YES, L.SN_NO = "yes", "no"
L.SN_PLACE        = "Place: %s  (map %s)"
L.SN_WEATHER      = "Weather: %s"
L.SN_WEATHER_NONE = "unknown"
L.SN_WEATHER_UNKNOWN = "type %s, intensity %s (not identified yet: please tell what you see!)"
L.SN_WEATHERS     = { clear = "clear", rain = "rain", snow = "snow", sand = "sandstorm" }
L.SN_TIME         = "Time: %s, air %s"
L.SN_DAY, L.SN_NIGHT = "day", "night"
L.SN_INOUT        = "Indoors: %s   City or inn: %s"
L.SN_CROWD        = "People around: %s  (%d nearby, %d talking)"
L.SN_CROWDS       = { quiet = "quiet", lively = "lively", crowded = "crowded" }
L.SN_CROWD_UNKNOWN = "can't tell (turn on friendly name plates to help)"
L.SN_LINES        = "Lines for here: %d possible now, %d not now"
L.SN_ARRIVE_TAG   = "(first visit)"
L.SN_TAGS = {
  generic = "anywhere", biome = "landscape: %s", zone = "this zone", subzone = "this exact place",
  day = "daytime", night = "night", indoors = "indoors", outdoors = "outdoors", resting = "city or inn",
  swimming = "swimming", weather = "weather: %s", crowd = "crowd: %s",
  airBelow = "air below %s", airAbove = "air above %s", notBiomes = "not in: %s", place = "place: %s",
  long = "long", spot = "this spot",
}
L.SN_POS = "Position: %s   Spot: %s"
L.SN_LANDSCAPE = "Landscape: %s   Zone levels: %s"

-- Entering a zone far from your level
M.dangerHigh = {
  "A chill runs through you. This place is far too dangerous for you.",
  "Every instinct tells you to turn back.",
  "You feel very small here. Whatever lives in these lands could crush you.",
}
M.dangerMid = {
  "You feel out of place here. Better stay on your guard.",
  "The creatures here look tougher than what you're used to.",
  "Something tells you this land isn't for you yet.",
}
M.dangerNone = {
  "You walk these lands with confidence: little here can threaten you.",
  "These lands hold no more danger for you.",
}
M.dangerNear = {
  "The hair on the back of your neck stands up. Something very dangerous is close.",
  "You feel a threatening presence nearby. Something here is far beyond you.",
}
-- a touch of the landscape before the danger feeling
M.dangerFlavor_gloom    = { "The shadows between the trees seem to move on their own." }
M.dangerFlavor_swamp    = { "The murky water could hide anything." }
M.dangerFlavor_hostile  = { "Out here, the land itself seems hostile." }
M.dangerFlavor_cold     = { "The wind howls like a warning." }
M.dangerFlavor_volcanic = { "The smoky air burns your lungs." }
M.dangerFlavor_sick     = { "Something sickly and wrong hangs in the air." }
M.dangerFlavor_wild     = { "The land around you seems to hold its breath." }

-- the pet senses it too
M.petDangerHigh = {
  "{pet} presses against your legs, ears flat, a low growl in the throat.",
  "{pet} sniffs the air and backs up a step, fur bristling.",
}
M.petDangerHigh_bird   = { "{pet} puffs up and stays very close, eyes darting everywhere." }
M.petDangerHigh_scaly  = { "{pet} hisses softly and won't leave your side." }
M.petDangerHigh_chitin = { "{pet} raises both front legs, on the defensive." }
M.petDangerMid = {
  "{pet} stays a little closer to you than usual.",
  "{pet} keeps glancing around, wary.",
}
M.petDangerNone = {
  "{pet} trots ahead proudly. Nothing here scares the two of you.",
}
M.petDangerNone_bird = { "{pet} struts proudly ahead of you." }
M.petDangerNear = {
  "{pet} growls at something you can't quite see.",
  "{pet} freezes, staring at the danger, every muscle tense.",
}
M.petDangerNear_bird   = { "{pet} lets out a sharp warning cry." }
M.petDangerNear_scaly  = { "{pet} hisses, staring at the danger." }
M.petDangerNear_chitin = { "{pet} clicks nervously, staring at the danger." }
L.CMD_RESET_VISITS = "Visited places and line cooldowns forgotten: every line can play again."
L.UI_OPT_STYLE = "Immersion line length"
L.UI_OPT_BODYSTYLE = "Body comfort next to your character frame"
L.UI_BODYSTYLE = { none = "Text only", bars = "Bars", icons = "Icons" }
L.UI_STYLE     = { short = "Short", mixed = "Mixed", rich = "Rich" }
L.SN_PROPOSE_LABEL = "Propose a line for this place:"
L.SN_PROPOSE      = "Propose"
L.SN_PROPOSED     = "Thanks! Your line was saved with this place. It will be in the \"Report & ideas\" box."
L.UI_REPORT_PROPOSALS = "--- Proposed lines ---"
L.SN_PLAY_TT      = "Show this line in the chat now, to see how it reads. (A preview: it doesn't use the line up.)"
L.SN_REASONS = {
  night = "only at night", day = "only by day", indoors = "only indoors", outdoors = "only outdoors",
  resting = "only in a city or inn", swimming = "only while swimming", airBelow = "only when colder",
  airAbove = "only when warmer", biome = "not in this landscape", sub = "only in a particular place",
  weatherWait = "waiting for weather data", weather = "not in this weather",
  crowdUnknown = "needs to know who's around", crowd = "not with this crowd",
  cooldown = "already played, back in %s",
}
L.SN_BIOMES = {
  forest = "forest", plains = "plains", farmland = "dry farmland", hills = "hills", mountain = "mountains", snow = "snow",
  desert = "desert", savanna = "savanna", badlands = "badlands", canyon = "canyon", jungle = "jungle",
  swamp = "swamp", marsh = "marsh", coast = "coast", gloom = "gloomy lands", plague = "plaguelands",
  wasteland = "wasteland", volcanic = "volcanic lands", corrupted = "corrupted forest", city = "city",
  forge = "forge city", undercity = "underground city", unknown = "not described yet",
}
L.SN_GUIDE = table.concat({
  "|cffffd100Ambiance (Senses)|r",
  "Now and then, a short line describes the world around you: a smell, a sound, the wind, the weather. The first time you reach a new place, it greets you with a line of its own.",
  "Lines depend on the landscape, the exact place, day or night, indoors or out, the weather and how many people are around.",
  "The Ambiance tab shows what the addon sees where you stand, and every line that could appear here. If a line ever feels wrong, flag it with /wt nope.",
}, "\n")

-- Keep an untouched copy of the English texts, so the language can be switched
-- back and forth (other languages are laid over these, see Locale_frFR.lua).
local function copy(t)
  local c = {}
  for k, v in pairs(t) do c[k] = v end
  return c
end
KT.EN = { L = copy(L), M = copy(M) }
