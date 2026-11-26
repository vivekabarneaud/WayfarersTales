# Map regions

Paint areas over a zone map, write what each place is, and discuss them with Claude before they go into the addon.

## Painting
1. Open `index.html` in Chrome or Edge (they can open a folder and save in place).
2. **Maps folder…**: pick the folder with the zone maps (`Desktop\Wayfarers-maps`). To fill it with every Classic zone map from Wowhead, run:
   `powershell -NoProfile -ExecutionPolicy Bypass -File tools\map\get-maps.ps1` (add `-Force` to download them again).
   The page recognises each image by its name (`Elwynn-Forest.jpg`, `Dun-Morogh.jpg`...), so keep only one image per zone at the top of the folder; the page ignores subfolders. The maps stay on your PC, never in git.
3. Choose a zone, **+ New region**, give it a name, paint (brush `B`, eraser `E`, size `[` `]`, undo `Ctrl+Z`, zoom `Ctrl+wheel`).
4. Write the note: what you see, smell, hear, how it feels, warmer or colder... in your own words.
5. **Save** (`Ctrl+S`). The first time, save as `tools/map/regions.js` (replace the file); after that it saves there directly.

Regions can overlap: a small "fire" region inside a "gnoll camp" adds its details to the camp.

**Check points** (red diamonds): positions measured in game (your Homework notes, the addon's spots). If they sit on the right place, the map is lined up. Add your own with **+ Point** (blue). Refresh them with:
`powershell -ExecutionPolicy Bypass -File tools\map\make-checkpoints.ps1`

## With Claude
Each region has a status:
- **your note**: waiting for Claude.
- **proposed**: Claude wrote a proposal (kind, temperatures, conditions, draft lines) in the card; we discuss it.
- **approved**: the final values are in `final`; only these go into the addon.
- **changed since proposal**: you edited the note after the proposal.

The grid is 200 x 200 cells per zone (0.5 % each, like the game's coordinates). Sub-zones with their own data always win over a painted region (caves under a mountain, inns...).
