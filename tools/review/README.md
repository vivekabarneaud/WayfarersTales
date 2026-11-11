# Line review tools

Builds the review page (every line of the addon, FR + EN, with its conditions, drafts and
rewrite proposals) that the player uses to approve, tweak or reject lines.

- `Extract.cs`: reads the Lua data files (SensesData, MomentsData, More, World, Locale) and
  outputs the lines as JSON. Compiled on the fly from PowerShell with `Add-Type`.
- `template.html`: the review page; `__DATA__`, `__REWRITES__` and `__HANDLED__` are replaced
  with the JSON.
- `rewrites.json`: rewrite proposals for Places lines, keyed by line id. `Drafts.lua` in the
  addon holds the same proposals (`D.REWRITES`), so they can be tried in game: keep both in sync.
- `handled.json`: review notes already handled (`id` + the exact `comment`, or `"general"`).
  The page clears them from the reviewer's browser when it loads; a newer comment on the same
  line stays.

Build (PowerShell; the addon folder's full path must be given to `Run`):

```powershell
$root = "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\WayfarersTales"
Set-Location "$root\tools\review"
Add-Type -Path .\Extract.cs
$json = [Extractor]::Run($root)
$rw = Get-Content .\rewrites.json -Raw -Encoding UTF8
$hd = Get-Content .\handled.json -Raw -Encoding UTF8
$html = (Get-Content .\template.html -Raw -Encoding UTF8).Replace("__DATA__", $json.Replace("</", "<\/")).Replace("__REWRITES__", $rw.Replace("</", "<\/")).Replace("__HANDLED__", $hd.Replace("</", "<\/"))
[IO.File]::WriteAllText("$PWD\line-review.html", $html, (New-Object System.Text.UTF8Encoding($false)))
```

The page's "Copy JSON" output is pasted back to Claude; handled notes are logged in
`docs/field-notes.md` and added to `handled.json` (review page) or `Processed.lua` (in game).
