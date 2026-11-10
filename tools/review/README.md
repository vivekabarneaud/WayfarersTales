# Line review tools

Builds the review page (every line of the addon, FR + EN, with its conditions, drafts and
rewrite proposals) that the player uses to approve, tweak or reject lines.

- `Extract.cs`: reads the Lua data files (SensesData, MomentsData, World, Locale) and outputs
  the lines as JSON. Compiled on the fly from PowerShell with `Add-Type`.
- `template.html`: the review page; `__DATA__` and `__REWRITES__` are replaced with the JSON.
- `rewrites.json`: rewrite proposals for Places lines, keyed by line id. `Drafts.lua` in the
  addon is generated from it (`D.REWRITES`), so the proposals can be tried in game.

Build (PowerShell, from this folder):

```powershell
Add-Type -Path .\Extract.cs
$json = [Extractor]::Run("..\..")
$rw = Get-Content .\rewrites.json -Raw -Encoding UTF8
$html = (Get-Content .\template.html -Raw -Encoding UTF8).Replace("__DATA__", $json.Replace("</", "<\/")).Replace("__REWRITES__", $rw.Replace("</", "<\/"))
[IO.File]::WriteAllText("$PWD\line-review.html", $html, (New-Object System.Text.UTF8Encoding($false)))
```

The page's "Copy JSON" output is pasted back to Claude; handled notes are logged in
`docs/field-notes.md` and listed in `Processed.lua`.
