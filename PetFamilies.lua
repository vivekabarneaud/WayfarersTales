-- Wayfarer's Tales - hunter pets: a few lines per family (bear, boar, cat...), on top of
-- the lines for their body type (furry, bird, scaly, chitin). Keyed like D.FAMILY_SOUND.
-- Events: idle (any idle moment), campfire (resting or near a fire), affection (/pet...).
-- when: the usual Senses conditions (still = you're standing still, moving = walking,
-- weather = "rain"...). minBand / maxBand: bond 1 low, 2 middle, 3 high.
-- French: nothing agrees with the pet.

local _, KT = ...
local D = KT.Data

local RAIN = { weather = "rain", indoors = false }

D.PET_FAMILY_CHANCE = 0.4 -- when a family line fits, how often it's picked over the usual ones

D.PET_FAMILY_LINES = {
  bear = {
    idle = {
      { draft = true, when = { still = true },
        en = "{pet} rears up on its hind legs, sniffs the air for a long while, then drops heavily back onto all fours.",
        fr = "{pet} se dresse sur ses pattes arrière, renifle l'air longuement, puis retombe lourdement à quatre pattes." },
      { draft = true, when = { still = true },
        en = "{pet} rubs its back against your legs with an energy that nearly knocks you over.",
        fr = "{pet} se frotte le dos contre vos jambes avec une énergie qui manque de vous renverser." },
      { draft = true,
        en = "{pet} lets out a low growl, more for conversation than as a threat.",
        fr = "{pet} pousse un grognement sourd, plus pour la conversation que pour la menace." },
      { draft = true,
        en = "{pet} yawns so wide you can see all its teeth. There are a lot of them.",
        fr = "{pet} bâille si grand que vous apercevez toutes ses dents. Il y en a beaucoup." },
      { draft = true, when = RAIN,
        en = "{pet} shakes itself in the rain and sprays you on the way, without the slightest apology.",
        fr = "{pet} s'ébroue sous la pluie et vous asperge au passage, sans la moindre excuse." },
    },
    campfire = {
      { draft = true,
        en = "{pet} sprawls out full length by the fire, like a big fur rug that breathes.",
        fr = "{pet} s'étale de tout son long près du feu, comme un gros tapis de fourrure qui respire." },
    },
    affection = {
      { draft = true, minBand = 3,
        en = "{pet} rests its big head on your shoulder. You feel all its weight, and all its trust.",
        fr = "{pet} pose sa grosse tête sur votre épaule. Vous sentez tout son poids, et toute sa confiance." },
    },
  },

  boar = {
    idle = {
      { draft = true, when = { still = true },
        en = "{pet} roots through the ground with its snout, grunting, in total concentration.",
        fr = "{pet} fouille le sol de son groin en grognant, avec une concentration totale." },
      { draft = true, when = { still = true },
        en = "{pet} scrapes the earth with a hoof, then looks at you as if it were your turn to dig.",
        fr = "{pet} gratte la terre d'un sabot, puis vous regarde comme si c'était à vous de creuser." },
      { draft = true, when = { still = true },
        en = "{pet} sniffs your pockets noisily: there must be something to eat in there.",
        fr = "{pet} renifle bruyamment vos poches : il doit bien y avoir quelque chose à manger là-dedans." },
      { draft = true, when = RAIN,
        en = "{pet} rolls in the mud with delight. You'll pretend you don't know each other.",
        fr = "{pet} se roule avec délice dans la boue. Vous ferez semblant de ne pas vous connaître." },
    },
    campfire = {
      { draft = true,
        en = "{pet} lies down by the fire, snout on its front legs, and lets out a long, contented sigh.",
        fr = "{pet} se couche près du feu, le groin posé sur les pattes, et pousse un long soupir satisfait." },
    },
    affection = {
      { draft = true,
        en = "{pet} nudges your hand with its snout, asking for a scratch.",
        fr = "{pet} vous pousse la main d'un coup de groin pour réclamer une caresse." },
    },
  },

  cat = {
    idle = {
      { draft = true, when = { still = true },
        en = "{pet} stretches for a long time, claws sliding out and back in, then yawns wide enough to unhinge its jaw.",
        fr = "{pet} s'étire longuement, les griffes qui sortent et rentrent, puis bâille à s'en décrocher la mâchoire." },
      { draft = true, when = { moving = true },
        en = "{pet} pads along without the slightest sound. Even you make more noise.",
        fr = "{pet} avance à pas feutrés, sans le moindre bruit. Même vous, vous faites plus de bruit." },
      { draft = true,
        en = "{pet} purrs, a deep purr you can feel all the way into your chest.",
        fr = "{pet} ronronne, un ronronnement grave qui vous vibre jusque dans la poitrine." },
      { draft = true,
        en = "{pet} flicks the tip of its tail: something, somewhere, has caught its attention.",
        fr = "{pet} fouette l'air du bout de la queue : quelque chose, quelque part, a retenu son attention." },
      { draft = true, when = RAIN,
        en = "{pet} shakes one paw after the other in the rain, looking deeply offended.",
        fr = "{pet} secoue une patte après l'autre sous la pluie, l'air profondément offensé." },
    },
    campfire = {
      { draft = true,
        en = "{pet} stretches out by the fire, head on its paws, the flames in its half-closed eyes.",
        fr = "{pet} s'allonge près du feu, la tête sur les pattes, les flammes dans ses yeux mi-clos." },
    },
    affection = {
      { draft = true,
        en = "{pet} rubs its big head against you and nearly knocks you off balance.",
        fr = "{pet} frotte sa grosse tête contre vous et vous déséquilibre presque." },
    },
  },

  owl = {
    idle = {
      { draft = true, when = { night = true, indoors = false },
        en = "{pet} lets out a deep hoot into the night. Far away, nothing answers.",
        fr = "{pet} lance un hululement grave dans la nuit. Au loin, rien ne répond." },
      { draft = true, when = { night = false },
        en = "In broad daylight, {pet} squints, as if the light were a personal offense.",
        fr = "En plein jour, {pet} plisse les yeux, comme si la lumière l'offensait personnellement." },
      { draft = true, when = { still = true },
        en = "{pet} lands next to you without a sound. You didn't hear a thing, despite its wingspan.",
        fr = "{pet} se pose près de vous sans un bruit. Vous n'avez rien entendu, malgré son envergure." },
      { draft = true,
        en = "{pet} ruffles its feathers, and a little down floats around you for a moment.",
        fr = "{pet} ébouriffe ses plumes, et un duvet léger flotte un instant autour de vous." },
      { draft = true, when = RAIN,
        en = "{pet} fluffs up its feathers in the rain and gives you a dark look.",
        fr = "{pet} gonfle ses plumes sous la pluie et vous lance un regard noir." },
    },
    campfire = {
      { draft = true,
        en = "The flames of the fire dance in {pet}'s big round eyes.",
        fr = "Les flammes du feu dansent dans les grands yeux ronds de {pet}." },
    },
  },

  raptor = {
    idle = {
      { draft = true,
        en = "{pet} makes a series of little clicks in its throat. You don't know what it means, and maybe that's for the best.",
        fr = "{pet} émet une série de petits claquements de gorge. Vous ne savez pas ce que ça veut dire, et c'est peut-être mieux ainsi." },
      { draft = true, when = { still = true },
        en = "{pet} taps the ground with its big curved claw, impatiently.",
        fr = "{pet} tapote le sol de sa grande griffe recourbée, avec impatience." },
      { draft = true,
        en = "{pet} sniffs the air, jaws half open on rows of teeth, then snaps them shut with a dry clack.",
        fr = "{pet} renifle l'air, la gueule entrouverte sur des rangées de dents, puis referme la mâchoire d'un claquement sec." },
      { draft = true, when = { still = true },
        en = "{pet} hops from one foot to the other: standing still is really not its thing.",
        fr = "{pet} sautille d'une patte sur l'autre : rester sans bouger n'est vraiment pas son fort." },
      { draft = true, when = RAIN,
        en = "{pet} lifts its snout to the sky and lets the rain run down its scales.",
        fr = "{pet} lève le museau vers le ciel et laisse la pluie couler sur ses écailles." },
    },
    campfire = {
      { draft = true,
        en = "{pet} lies down by the fire, its long tail curled around its body.",
        fr = "{pet} se couche près du feu, sa longue queue enroulée autour du corps." },
    },
    affection = {
      { draft = true,
        en = "{pet} rests its scaly head against your hand, surprisingly gentle for a creature with so many teeth.",
        fr = "{pet} pose sa tête écailleuse contre votre main, avec une douceur étonnante pour une créature qui a autant de dents." },
    },
  },

  serpent = {
    idle = {
      { draft = true,
        en = "{pet} weaves through the air around you, with a faint rustle of wings.",
        fr = "{pet} ondule dans l'air autour de vous, dans un léger froissement d'ailes." },
      { draft = true,
        en = "{pet} hisses softly, a strange sound that brings to mind the wind in the grass.",
        fr = "{pet} siffle doucement, un son étrange qui rappelle le vent dans les herbes." },
      { draft = true, when = { still = true },
        en = "When you stop, {pet} hovers above you, head turned toward the horizon.",
        fr = "Quand vous vous arrêtez, {pet} plane au-dessus de vous, la tête tournée vers l'horizon." },
      { draft = true, when = RAIN,
        en = "{pet} weaves through the rain, between the drops, with obvious delight.",
        fr = "{pet} ondule sous la pluie, entre les gouttes, avec une évidente délectation." },
    },
    campfire = {
      { draft = true,
        en = "{pet} coils up by the fire, wings folded, and its scales take on the color of the flames.",
        fr = "{pet} se love près du feu, les ailes repliées, et ses écailles prennent la couleur des flammes." },
    },
    affection = {
      { draft = true,
        en = "{pet} gently wraps its long tail around your arm.",
        fr = "{pet} enroule doucement sa longue queue autour de votre bras." },
    },
  },
}
