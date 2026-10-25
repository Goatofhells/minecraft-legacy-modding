param([ValidateSet('hello', 'builder', 'miner')][string]$mod = 'hello')
$ErrorActionPreference = 'Stop'
$src = Join-Path (Split-Path $PSScriptRoot -Parent) "examples/$mod"
$root = Join-Path $env:LOCALAPPDATA 'MinecraftLegacy/mods'
$dest = Join-Path $root $mod
if (Test-Path -LiteralPath $dest) {
    throw "The mod folder already exists: $dest. Back it up and install updates manually."
}
New-Item -ItemType Directory -Path $root -Force | Out-Null
Copy-Item -LiteralPath $src -Destination $dest -Recurse
Write-Output "Installed $mod in $dest. Host a world and open Dev Tools > Mods > Reload mods."
