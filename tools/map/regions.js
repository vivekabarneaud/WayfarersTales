// Wayfarer's Tales - map regions, painted in tools/map/index.html (see README.md).
// Notes are yours; proposal / final / status are filled in with Claude.
window.WT_REGIONS = {
    "version":  1,
    "grid":  200,
    "savedAt":  "2026-11-26T16:23:50.685Z",
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
                    }
                ],
    "checkpoints":  [

                    ]
};
