# Wayfarer's Tales - copies the addon from this repo into the game's AddOns folder.
# The AddOns copy is disposable: it can be wiped (by the CurseForge app, for example)
# and rebuilt by running this script again. Dev.lua is copied too, so the game runs in dev mode.
#
# Usage (PowerShell, from anywhere):  & "C:\Users\vvkbr\Projects\WayfarersTales\tools\deploy.ps1"

param(
    [string]$Target = "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\WayfarersTales"
)

$src = Split-Path $PSScriptRoot -Parent

# Safety: never mirror onto the repo itself, and only into a folder named like the addon.
if ((Resolve-Path $src).Path -eq $Target) { Write-Error "Target is the repo itself."; exit 1 }
if ((Split-Path $Target -Leaf) -ne "WayfarersTales") { Write-Error "Unexpected target: $Target"; exit 1 }
if (Test-Path (Join-Path $Target ".git")) { Write-Error "Target contains a git repo, not touching it: $Target"; exit 1 }

robocopy $src $Target /MIR /XD .git docs tools .claude /XF TODO.md RELEASE_NOTES.md .gitattributes .gitignore .pkgmeta /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { Write-Error "Deploy failed (robocopy code $LASTEXITCODE)"; exit 1 }

"Deployed to $Target ($((Get-ChildItem $Target -File).Count) files). Restart the game to load the changes."
exit 0
