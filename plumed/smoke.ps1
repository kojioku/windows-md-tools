# Smoke test for the packaged PLUMED, from PowerShell with MSYS2 NOT on PATH.
#   - `plumed info --version` prints a version
#   - `plumed driver` on two atoms 1.0 / 1.5 / 2.0 nm apart writes those distances
#     to COLVAR (the kernel computes a collective variable; no MD engine involved)
param([string]$Prefix, [string]$Out = "smoke-out")
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $Out | Out-Null
$env:PATH = "$Prefix\bin;$Prefix\lib;C:\Windows\System32;C:\Windows"
$exe = Join-Path $Prefix "bin\plumed.exe"
$ver = & $exe info --version 2>&1 | Out-String
$ver | Set-Content "$Out\version.txt"
if ($LASTEXITCODE -ne 0) { throw "plumed info --version failed: $ver" }
Copy-Item (Join-Path $PSScriptRoot "data\*") $Out
Push-Location $Out
& $exe driver --plumed plumed.dat --ixyz two_atoms.xyz --length-units A 2>&1 | Set-Content driver.log
$rc = $LASTEXITCODE
Pop-Location
if ($rc -ne 0) { throw "plumed driver failed: $(Get-Content $Out\driver.log -Raw)" }
$vals = Get-Content "$Out\COLVAR" | Where-Object { $_ -notmatch '^#' } | ForEach-Object { [double](($_ -split '\s+' | Where-Object { $_ })[1]) }
Write-Host "PLUMED $($ver.Trim()); distances [nm]: $($vals -join ', ')"
$want = 1.0, 1.5, 2.0
for ($i = 0; $i -lt 3; $i++) { if ([math]::Abs($vals[$i] - $want[$i]) -gt 1e-6) { throw "distance $i = $($vals[$i]), expected $($want[$i])" } }
