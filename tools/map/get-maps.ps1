# Downloads the Classic zone maps from Wowhead into your maps folder, named so index.html recognises them.
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File tools/map/get-maps.ps1
# Existing files are kept; add -Force to download them again. The images stay on your PC, never in git.
param([string]$Folder = "$env:USERPROFILE\Desktop\Wayfarers-maps", [switch]$Force)

# Wowhead names map images by zone (area) ID, not by the game's map ID.
$zones = [ordered]@{
  "Elwynn-Forest" = 12; "Stormwind" = 1519; "Westfall" = 40; "Redridge-Mountains" = 44; "Duskwood" = 10
  "Dun-Morogh" = 1; "Ironforge" = 1537; "Loch-Modan" = 38; "Wetlands" = 11; "Hillsbrad-Foothills" = 267
  "Alterac-Mountains" = 36; "Arathi-Highlands" = 45; "The-Hinterlands" = 47; "Badlands" = 3; "Searing-Gorge" = 51
  "Burning-Steppes" = 46; "Swamp-of-Sorrows" = 8; "Deadwind-Pass" = 41; "Blasted-Lands" = 4; "Stranglethorn-Vale" = 33
  "Tirisfal-Glades" = 85; "Undercity" = 1497; "Silverpine-Forest" = 130; "Western-Plaguelands" = 28; "Eastern-Plaguelands" = 139
  "Teldrassil" = 141; "Darnassus" = 1657; "Darkshore" = 148; "Ashenvale" = 331; "Stonetalon-Mountains" = 406
  "Desolace" = 405; "Feralas" = 357; "Thousand-Needles" = 400; "Dustwallow-Marsh" = 15; "Tanaris" = 440
  "Un-Goro-Crater" = 490; "Silithus" = 1377; "Felwood" = 361; "Winterspring" = 618; "Azshara" = 16; "Moonglade" = 493
  "Durotar" = 14; "Orgrimmar" = 1637; "Mulgore" = 215; "Thunder-Bluff" = 1638; "The-Barrens" = 17
}

# Where WoW Forever differs from the original Classic maps, take Wowhead's later version (checked in game).
$version = @{ "Stormwind" = "wrath" }  # the harbour is there

New-Item -ItemType Directory -Force $Folder | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$web = New-Object Net.WebClient
$web.Headers["User-Agent"] = "Mozilla/5.0"
$got = 0; $kept = 0; $failed = @()
foreach ($name in $zones.Keys) {
  $file = Join-Path $Folder "$name.jpg"
  if ((Test-Path $file) -and -not $Force) { $kept++; continue }
  try {
    $v = if ($version[$name]) { $version[$name] } else { "classic" }
    $web.DownloadFile("https://wow.zamimg.com/images/wow/$v/maps/enus/original/$($zones[$name]).jpg", $file)
    $got++
  } catch { $failed += $name; Remove-Item $file -ErrorAction SilentlyContinue }
}
"{0} downloaded, {1} already there" -f $got, $kept
if ($failed) { "Failed: " + ($failed -join ", ") }
