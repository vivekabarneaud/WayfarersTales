// Wayfarer's Tales - map regions, painted in tools/map/index.html (see README.md).
// Notes are yours; proposal / final / status are filled in with Claude.
window.WT_REGIONS = {
    "version":  1,
    "grid":  200,
    "savedAt":  "2026-11-26T11:39:35.853Z",
    "regions":  [
                    {
                        "id":  "rmwtkep3lgh9",
                        "zone":  1429,
                        "name":  "Northshire river",
                        "note":  "probably clear water",
                        "status":  "proposed",
                        "color":  "#1972e6",
                        "cells":  "aqf.1.5g.1.1.2.5f.5.5e.5.5f.4.5g.4.5g.4.5h.3.5h.3.5h.3.5h.3.5h.2.5i.2.5i.2.5i.2.5i.1.5j.1.5j.1.5i.2.5h.3.5h.2.5h.3.5g.3.5f.4.5g.3.5g.3.5h.2.5i.1.5j.1.5i.2.5i.2.5i.2.5i.1.5h.2.5i.2.5i.2.5i.2.5i.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5i.1.5j.1.5j.1.d1j",
                        "proposal":  "Kind: river · Air: as the zone · Water: 2°C colder than the zone\u0027s water (running down from the hills), about 8°C · Outdoors only\n\nLines (drafts):\n1. (now and then) « Le murmure de la rivière vous accompagne, régulier et paisible. »\n   \"The murmur of the river keeps you company, steady and peaceful.\"\n2. (while swimming) « L\u0027eau de la rivière est fraîche ; elle file autour de vous en clapotant. »\n   \"The river water is cool, and it ripples past you as it flows.\"\n\nQuestion: is the water clear in game? If you\u0027ve seen it, a line can say so; for now none does."
                    },
                    {
                        "id":  "rmwtktapd0u4",
                        "zone":  1429,
                        "name":  "Murloc lake",
                        "note":  "Fishermen are trying to catch fish but the murloc are eating the fish first, i think. they also made little camps and they steal shiny things (probably the baits used by the fishermen?). it should probably smell like fish",
                        "status":  "proposed",
                        "color":  "#6119e6",
                        "cells":  "h7d.1.5j.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5h.2.5i.2.5i.2.5i.2.5i.2.5i.5.5e.8.6.7.4y.9.5.9.4x.a.3.a.4w.p.4v.p.4v.p.4v.p.4v.p.4w.o.4w.o.4x.n.50.j.52.h.56.d.5a.9.5e.4.969",
                        "proposal":  "Kind: lake · Water: automatic (about 10°C) · Outdoors only\n\nLines (drafts):\n1. (now and then) « L\u0027eau du lac sent le poisson et la vase, et sur la rive se dressent les huttes de roseaux des murlocs. »\n   \"The lake smells of fish and silt, and the murlocs\u0027 reed huts stand along the shore.\"\n2. (only when a murloc is in view: new condition) « Des murlocs rôdent au bord de l\u0027eau. Mieux vaut garder un œil sur vos affaires : ils ont un faible pour tout ce qui brille. »\n   \"Murlocs prowl at the water\u0027s edge. Better keep an eye on your things: they have a weakness for anything shiny.\"\n\nQuestion: where do the fishermen stand? Paint a small region there (or note their names): then a line about them losing their catch to the murlocs can be true."
                    },
                    {
                        "id":  "rmwxh3ocdwvz",
                        "zone":  1429,
                        "name":  "Cultivated fields",
                        "note":  "There are pumpkins and boars foraging. ",
                        "status":  "proposed",
                        "color":  "#e67519",
                        "cells":  "nep.4.5f.6.5d.8.5c.8.5c.8.5c.9.5a.a.5b.9.5b.9.5b.9.5b.8.5d.7.5e.5.8y.4.5f.6.5d.7.c.4.4x.8.a.6.4w.8.a.7.4v.8.9.8.4v.8.9.9.4u.7.a.9.4v.6.a.9.4v.5.b.9.5b.9.5b.9.5c.7.5d.7.5e.5.36a",
                        "proposal":  "Kind: farm · Air: as the zone · Outdoors only\n\nThe pumpkins aren\u0027t everywhere in this big region: paint a separate small \"Pumpkin patch\" region where they are, and the pumpkin line goes there.\n\nLines (drafts):\n1. (now and then) « L\u0027air sent la terre retournée, et les champs s\u0027étendent en rangs bien sages jusqu\u0027à la lisière de la forêt. »\n   \"The air smells of turned earth, and the fields stretch in neat rows up to the edge of the forest.\"\n2. (only when a boar is in view) « Des sangliers rôdent autour des champs : les fermiers ne doivent pas beaucoup les aimer. »\n   \"Boars roam around the fields; the farmers can\u0027t be very fond of them.\"\n3. (pumpkin patch) « De grosses citrouilles orange mûrissent entre leurs larges feuilles. »\n   \"Fat orange pumpkins ripen among their broad leaves.\""
                    },
                    {
                        "id":  "rmwxh5fpwfmv",
                        "zone":  1429,
                        "name":  "Vinyard",
                        "note":  "There are vines with fresh grapes (probably insects too, a sweet smell of ripe grapes). And Defias thugs",
                        "status":  "proposed",
                        "color":  "#e6197c",
                        "cells":  "e4j.1.5i.3.5g.5.5f.6.5d.8.5c.8.5c.8.5c.7.5e.6.5e.6.5f.4.5h.2.f1f",
                        "proposal":  "Kind: vineyard · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « Les rangs de vigne ploient sous les grappes, et une odeur sucrée de raisin mûr flotte dans l\u0027air. »\n   \"The rows of vines sag under the bunches, and a sweet smell of ripe grapes hangs in the air.\"\n2. (only when Defias are in view) « Des voyous défias rôdent entre les rangs de vigne. Si près de l\u0027abbaye, la Confrérie ne se cache même plus. »\n   \"Defias thugs lurk between the rows of vines. This close to the Abbey, the Brotherhood doesn\u0027t even bother hiding.\"\n\nQuestion: the insects aren\u0027t visible in game, so a line about them would be a guess. Keep one anyway (by day, in good weather): « Des guêpes bourdonnent autour des grappes, attirées par le sucre. » ?"
                    },
                    {
                        "id":  "rmwxh7reakql",
                        "zone":  1429,
                        "name":  "Logging camp",
                        "note":  "Smells like freshly cut wood",
                        "status":  "proposed",
                        "color":  "#79400c",
                        "cells":  "i6f.5.5e.7.5c.9.5b.a.5a.c.57.e.56.f.55.g.54.h.53.i.52.i.51.j.51.j.51.j.51.j.51.i.52.i.52.i.52.h.54.d.57.c.59.a.5a.a.5c.7.5f.3.8z8",
                        "proposal":  "Kind: camp (logging) · Air: as the zone · Outdoors only\n\nLines (drafts):\n1. (now and then) « L\u0027odeur du bois fraîchement coupé emplit l\u0027air, un mélange de résine et de sciure. »\n   \"The smell of freshly cut wood fills the air, a mix of resin and sawdust.\"\n\nQuestion: what else is there? Log piles, a sawmill, lumberjacks at work? Each thing you\u0027ve seen can become a line."
                    }
                ],
    "checkpoints":  [

                    ]
};
