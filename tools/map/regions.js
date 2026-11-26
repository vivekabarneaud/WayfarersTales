// Wayfarer's Tales - map regions, painted in tools/map/index.html (see README.md).
// Notes are yours; proposal / final / status are filled in with Claude.
window.WT_REGIONS = {
    "version":  1,
    "grid":  200,
    "savedAt":  "2026-11-26T18:11:59.409Z",
    "regions":  [
                    {
                        "id":  "rmwtkep3lgh9",
                        "zone":  1429,
                        "name":  "Northshire river",
                        "note":  "probably clear water",
                        "status":  "proposed",
                        "color":  "#1972e6",
                        "cells":  "aqf.1.5g.1.1.2.5f.5.5e.5.5f.4.5g.4.5g.4.5h.3.5h.3.5h.3.5h.3.5h.2.5i.2.5i.2.5i.2.5i.1.5j.1.5j.1.5i.2.5h.3.5h.2.5h.3.5g.3.5f.4.5g.3.5g.3.5h.2.5i.1.5j.1.5i.2.5i.2.5i.2.5i.1.5h.2.5i.2.5i.2.5i.2.5i.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5i.1.5j.1.5j.1.d1j",
                        "proposal":  "Kind: river · Air: as the zone · Water: about 8°C (2°C colder than the zone\u0027s water, running down from the hills) · Outdoors only\n\nLines (drafts):\n1. (now and then) « Un petit « plouf » vous fait tourner la tête : un poisson vient de sauter. L\u0027air sent la mousse humide. »\n   \"A small splash makes you turn your head: a fish just jumped. The air smells of damp moss.\"\n2. (while swimming) « L\u0027eau froide file entre vos doigts, et de petits poissons s\u0027écartent devant vous. »\n   \"The cold water slips between your fingers, and little fish dart out of your way.\""
                    },
                    {
                        "id":  "rmwtktapd0u4",
                        "zone":  1429,
                        "name":  "Murloc lake",
                        "note":  "Fishermen are trying to catch fish but the murloc are eating the fish first, i think. they also made little camps and they steal shiny things (probably the baits used by the fishermen?). it should probably smell like fish",
                        "status":  "proposed",
                        "color":  "#6119e6",
                        "cells":  "h7d.1.5j.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5i.2.5i.5.5e.8.6.7.4y.9.5.9.4x.a.3.a.4w.p.4v.p.4v.p.4v.p.4v.p.4w.o.4w.o.4x.n.50.j.52.h.56.d.5a.9.5e.4.969",
                        "proposal":  "Kind: lake · Water: automatic (about 10°C) · Outdoors only\n\nLines (drafts):\n1. (while moving) « Le lac sent le poisson et la vase, et une grenouille se tait d\u0027un coup à votre approche. »\n   \"The lake smells of fish and silt, and a frog falls silent as you come near.\"\n2. (only when a murloc is in view: new condition) « Une odeur d\u0027écailles mouillées et de poisson pas très frais flotte autour des murlocs. Gardez un œil sur vos affaires : tout ce qui brille les attire. »\n   \"A smell of wet scales and not-so-fresh fish hangs around the murlocs. Keep an eye on your things: anything shiny draws them.\"\n\nQuestion: where do the fishermen stand? Paint a small region there (or note their names): then a line about them can be true."
                    },
                    {
                        "id":  "rmwxh3ocdwvz",
                        "zone":  1429,
                        "name":  "Cultivated fields",
                        "note":  "There are pumpkins and boars foraging. ",
                        "status":  "proposed",
                        "color":  "#e67519",
                        "cells":  "nep.4.5f.6.5d.8.5c.8.5c.8.5c.9.5a.a.5b.9.5b.9.5b.9.5b.8.5d.7.5e.5.8y.4.5f.6.5d.7.c.4.4x.8.a.6.4w.8.a.7.4v.8.9.8.4v.8.9.9.4u.7.a.9.4v.6.a.9.4v.5.b.9.5b.9.5b.9.5c.7.5d.7.5e.5.36a",
                        "proposal":  "Kind: farm · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « L\u0027air sent la terre retournée et le foin coupé. »\n   \"The air smells of turned earth and cut hay.\"\n2. (while moving) « Un corbeau s\u0027envole d\u0027un sillon en croassant, dérangé par votre passage. »\n   \"A crow takes off from a furrow, cawing, disturbed as you pass.\"\n3. (only when a boar is in view) « On entend les sangliers renifler et grogner en retournant la terre. »\n   \"You can hear the boars snuffling and grunting as they root up the soil.\"\n4. (pumpkin patch) « Une odeur douceâtre de courge trop mûre monte d\u0027entre les larges feuilles. »\n   \"A sweetish smell of overripe squash rises from among the broad leaves.\"\n\nThe pumpkins aren\u0027t everywhere in this big region: paint a separate small \"Pumpkin patch\" region where they are, and line 4 goes there."
                    },
                    {
                        "id":  "rmwxh5fpwfmv",
                        "zone":  1429,
                        "name":  "Vinyard",
                        "note":  "There are vines with fresh grapes (probably insects too, a sweet smell of ripe grapes). And Defias thugs",
                        "status":  "proposed",
                        "color":  "#e6197c",
                        "cells":  "e4j.1.5i.3.5g.5.5f.6.5d.8.5c.8.5c.8.5c.7.5e.6.5e.6.5f.4.5h.2.f1f",
                        "proposal":  "Kind: vineyard · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « Entre les rangs flotte une odeur de raisin trop mûr, presque de vin. »\n   \"Between the rows hangs a smell of overripe grapes, almost of wine.\"\n2. (by day, warm and dry) « Des guêpes bourdonnent autour des grappes, ivres de sucre. »\n   \"Wasps buzz around the bunches, drunk on sugar.\"\n3. (only when Defias are in view) « Une odeur de tabac froid traîne entre les rangs : les Défias ne sont pas loin. »\n   \"A smell of stale tobacco lingers between the rows: the Defias aren\u0027t far.\""
                    },
                    {
                        "id":  "rmwxh7reakql",
                        "zone":  1429,
                        "name":  "Logging camp",
                        "note":  "Smells like freshly cut wood",
                        "status":  "proposed",
                        "color":  "#79400c",
                        "cells":  "i6f.5.5e.7.5c.9.5b.a.5a.c.57.e.56.f.55.g.54.h.53.i.52.i.51.j.51.j.51.j.51.j.51.i.52.i.52.i.52.h.54.d.57.c.59.a.5a.a.5c.7.5f.3.8z8",
                        "proposal":  "Kind: camp (logging) · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « L\u0027air sent la résine et la sciure, et une fine poussière de bois vous chatouille le nez. »\n   \"The air smells of resin and sawdust, and a fine wood dust tickles your nose.\"\n\nQuestion: what else is there? Log piles, a sawmill, lumberjacks at work? Each thing you\u0027ve seen can give a sound or a smell."
                    },
                    {
                        "id":  "rmwxtbcxg6dy",
                        "zone":  1431,
                        "name":  "Stitches road",
                        "note":  "the main road, where Stitches (big elite skull lvl undead boss) roams towards Darkshire. It\u0027s very dark, a few sparse lanterns light the stone paved road. we can hear crows and owls, and wood creaking, wolves howling. it probably smells like dirt. There are also dead trees around, and spider nests and silk hanging from the trees, slowly swinging with the wind.",
                        "status":  "proposed",
                        "color":  "#e6194b",
                        "cells":  "gs5.1.5j.1.5i.2.5i.2.5h.2.2v.3.2k.2.2u.7.2g.2.2u.9.2e.3.2s.4.5.3.2d.2.2s.4.7.4.28.5.2o.6.a.6.24.5.2n.7.d.6.1o.6.6.5.2o.4.1.1.h.5.1l.h.2r.1.o.4.1i.5.3.8.3j.5.1f.3.3z.6.1b.2.43.9.14.3.47.8.11.4.49.8.z.2.4g.4.x.2.4j.4.u.3.4k.4.t.2.4n.7.n.3.4o.d.f.3.4q.f.a.4.4w.4.1.6.8.4.56.3.6.3.59.3.3.4.5b.3.2.3.5d.7.5e.5.9hd",
                        "photos":  [
                                       "rmwxtbcxg6dy-mwxtq42v04.jpg"
                                   ],
                        "proposal":  "Kind: road through the woods · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (while moving) « Un fil de soie invisible vous colle au visage. Vous l\u0027arrachez d\u0027un geste, sans trop vouloir savoir d\u0027où il pend. »\n   \"An invisible thread of silk sticks to your face. You brush it off, rather not knowing where it hangs from.\"\n2. (now and then, no storm) « Une chouette hulule juste au-dessus de vous. Le bois mort grince, alors que l\u0027air ne bouge pas. »\n   \"An owl hoots right above you. The dead wood creaks, though the air is perfectly still.\"\n3. (now and then: here the distance is the point) « Au loin, un loup hurle. Un deuxième lui répond, plus près. »\n   \"Far off, a wolf howls. A second one answers, closer.\"\n4. (only when Stitches is in view: new condition) « Une puanteur de chair morte et de vieux fil poisseux flotte autour du géant recousu, et le sol tremble sous ses pas. »\n   \"A stench of dead flesh and old, sticky thread hangs around the stitched giant, and the ground shakes under his steps.\""
                    },
                    {
                        "id":  "rmwxtqbk8l52",
                        "zone":  1431,
                        "name":  "Raven hill",
                        "note":  "An abandoned little village with a stone statue in the middle, covered with ivy or moss. the lanterns are turned off and are swinging with the wind. There is nobody, no enemy, no other npc than Jitters and he is friendly.\nInside the homes it\u0027s all broken, spider webs and bones, broken windows, empty fireplaces.\nThere could be flies",
                        "status":  "proposed",
                        "color":  "#3cb44b",
                        "cells":  "gul.5.5f.6.5d.8.5c.8.5c.8.5b.9.5b.8.5c.7.5e.5.5f.5.5h.1.cgx",
                        "photos":  [
                                       "rmwxtqbk8l52-mwxtsfps9p.jpg",
                                       "rmwxtqbk8l52-mwxtvdf2a4.jpg"
                                   ],
                        "proposal":  "Kind: abandoned village · Air: as the zone · New flag \"abandoned\": the cosy lines for stepping inside (\"calm and peaceful\") never play here\n\nLines (drafts):\n1. (stepping into a house) « Une odeur de poussière froide et de bois pourri vous saisit, et le plancher gémit sous vos pas. »\n   \"A smell of cold dust and rotten wood grips you, and the floorboards groan under your feet.\"\n2. (outdoors, now and then) « Une lanterne éteinte grince au bout de sa chaîne. Personne n\u0027est venu la rallumer depuis longtemps. »\n   \"An unlit lantern creaks at the end of its chain. No one has come to light it in a long time.\"\n3. (not cold) « Des mouches bourdonnent autour de vous, lourdes et lentes. Vous préférez ne pas chercher ce qui les attire. »\n   \"Flies buzz around you, heavy and slow. You\u0027d rather not look for what draws them.\""
                    },
                    {
                        "id":  "rmwxu3y98kl8",
                        "zone":  1431,
                        "name":  "Watch camp",
                        "note":  "A little camp with wardens of the watch. it\u0027s crude, there is a campfire and a lot of torches, so it could be warmer than the rest of the area. ",
                        "status":  "proposed",
                        "color":  "#4363d8",
                        "cells":  "kfu.2.5h.4.5g.5.5f.5.5f.4.5h.3.9nf",
                        "photos":  [
                                       "rmwxu3y98kl8-mwxu5pz9d2.jpg"
                                   ],
                        "proposal":  "Kind: camp (the Night Watch) · Air: +3°C (the campfire and the torches) · Outdoors only\n\nLines (drafts):\n1. (now and then) « La chaleur du feu vous gagne les joues, et l\u0027odeur de la fumée et de la poix des torches vous pique le nez. »\n   \"The warmth of the fire reaches your cheeks, and the smell of smoke and torch pitch stings your nose.\"\n2. (calm, no crowd) « Le feu crépite, et le bois humide siffle en brûlant. »\n   \"The fire crackles, and the damp wood hisses as it burns.\""
                    },
                    {
                        "id":  "rmwxu9icjqog",
                        "zone":  1431,
                        "name":  "Rotten orchard",
                        "note":  "An orchard with rows of dead trees. In the center there is an even bigger tree, dead too. Not a single leaf on these trees, and there are a lot of worgens roaming. They took the abandoned farm for themselves, and even made camps in the middle of the orchard, under the bigger tree",
                        "status":  "proposed",
                        "color":  "#f58231",
                        "cells":  "kgv.2.5f.6.5e.8.5b.a.5a.a.59.b.58.d.57.d.56.e.55.f.55.f.54.g.54.g.54.g.55.f.55.f.56.e.56.e.57.d.59.b.5a.9.5e.5.75g",
                        "photos":  [
                                       "rmwxu9icjqog-mwxuivrksw.jpg",
                                       "rmwxu9icjqog-mwxujczm3w.jpg"
                                   ],
                        "proposal":  "Kind: orchard (dead) · Air: as the zone · Outdoors only. \"Le Verger pourrissant\" is also a sub-zone in game: the region adds the worgen camps under the big tree.\n\nLines (drafts):\n1. (now and then) « L\u0027herbe sent la pomme pourrie, une odeur sucrée et aigre qui vous colle à la gorge. »\n   \"The grass smells of rotten apples, a sweet and sour smell that sticks in your throat.\"\n2. (while moving) « Une pomme ratatinée roule sous votre pied. »\n   \"A shrivelled apple rolls under your foot.\"\n3. (only when a worgen is in view) « Une odeur de fourrure mouillée et de sang séché flotte entre les arbres. Les worgens ont fait de ce verger le leur. »\n   \"A smell of wet fur and dried blood hangs between the trees. The worgens have made this orchard their own.\""
                    },
                    {
                        "id":  "rmwxuy72n0kd",
                        "zone":  1431,
                        "name":  "Darkshire",
                        "note":  "It has a central stone paved square with a fountain with no water in it. There is a blacksmith, and the mayor\u0027s office probably, which has a big clock. the inn is lively and warm with a fireplace running, and lit with a lot of candles",
                        "status":  "proposed",
                        "color":  "#911eb4",
                        "cells":  "doz.1.5i.3.5g.5.5f.7.5d.7.5d.8.5b.9.5b.9.5b.9.5c.8.5c.8.5e.5.fgw",
                        "photos":  [
                                       "rmwxuy72n0kd-mwxuztjypc.jpg",
                                       "rmwxuy72n0kd-mwxv0els76.jpg"
                                   ],
                        "proposal":  "Kind: village · Air: as the zone\n\nLines (drafts):\n1. (outdoors, on the hour of the game clock: new trigger) « La grande horloge sonne l\u0027heure. Les coups résonnent longtemps sur la place. »\n   \"The great clock strikes the hour. The chimes ring out over the square for a long time.\"\n2. (outdoors, now and then) « Le tintement régulier d\u0027un marteau sur l\u0027enclume monte de la forge. »\n   \"The steady ring of a hammer on the anvil rises from the forge.\"\n3. (inside the inn: replaces the two current lines, which say the inn is dim and hushed) « La chaleur de l\u0027âtre vous enveloppe, avec l\u0027odeur de la cire chaude, de la bière et du bois qui brûle. Ici, on en oublierait presque la nuit du dehors. »\n   \"The warmth of the hearth wraps around you, with the smell of warm wax, beer and burning wood. In here, you could almost forget the night outside.\"\n4. (idea, new trigger: when the town crier shouts that Stitches is coming) « Autour de la place, des volets claquent et quelqu\u0027un pousse un verrou en hâte. »\n   \"Around the square, shutters bang shut and someone hurriedly slides a bolt.\""
                    },
                    {
                        "id":  "rmwxv5othh95",
                        "zone":  1431,
                        "name":  "Pumpking patch",
                        "note":  "a few sparse pumpkins growing, not many leaves, a scarecrow in the middle, some chickens pecking and a wooden windmill creaking ",
                        "status":  "proposed",
                        "color":  "#42d4f4",
                        "cells":  "fux.3.5g.5.5e.6.5e.6.5e.6.5e.6.5e.6.5e.6.5f.5.5h.3.dm3",
                        "photos":  [
                                       "rmwxv5othh95-mwxv6v33hh.jpg",
                                       "rmwxv5othh95-mwxv77tjgn.jpg"
                                   ],
                        "proposal":  "Kind: farm (pumpkin patch) · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « L\u0027air sent la terre froide et la courge qui commence à pourrir. »\n   \"The air smells of cold earth and squash beginning to rot.\"\n2. (now and then) « Le vieux moulin grince au-dessus du champ, un long gémissement de bois sec. »\n   \"The old windmill creaks above the field, a long groan of dry wood.\"\n3. (only when a chicken is in view) « On entend les poules caqueter et gratter la terre entre les rangs. »\n   \"You can hear the chickens clucking and scratching at the soil between the rows.\""
                    }
                ],
    "checkpoints":  [

                    ]
};
