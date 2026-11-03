# Smoke test for the packaged mkdssp, run from PowerShell with MSYS2 NOT on PATH
# (as on a user's machine). Checks what a caller such as vermouth relies on:
#   - `mkdssp --version` prints a version x.y.z on stdout
#   - `mkdssp -i <pdb>` (ATOM records only, no header / CRYST1) writes the classic
#     DSSP 2/3 table, whose header line starts with "  #  RESIDUE AA"
# and prints the secondary-structure string for 1L2Y (model 1).
param([string]$Prefix, [string]$Out = "smoke-out")
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $Out | Out-Null
$env:PATH = "$Prefix\bin;C:\Windows\System32;C:\Windows"
$exe = Join-Path $Prefix "bin\mkdssp.exe"
$ver = & $exe --version 2>&1 | Out-String
$ver | Set-Content "$Out\version.txt"
if ($ver -notmatch '\d+\.\d+\.\d+') { throw "no x.y.z in --version: $ver" }
$pdb = Join-Path $PSScriptRoot "data\1l2y_model1_atoms.pdb"
$res = & $exe -i $pdb 2>"$Out\stderr.txt"
if ($LASTEXITCODE -ne 0) { throw "mkdssp -i failed: $(Get-Content $Out\stderr.txt -Raw)" }
$res | Set-Content "$Out\1l2y.dssp"
$i = [array]::FindIndex([string[]]$res, [Predicate[string]]{ param($l) $l.StartsWith("  #  RESIDUE AA") })
if ($i -lt 0) { throw "no '  #  RESIDUE AA' header line" }
$ss = ($res[($i + 1)..($res.Count - 1)] | Where-Object { $_.Length -gt 16 -and $_[13] -ne '!' } |
       ForEach-Object { if ($_[16] -eq ' ') { 'C' } else { [string]$_[16] } }) -join ''
"$ss" | Set-Content "$Out\1l2y_ss.txt"
Write-Host "version: $($ver.Trim())"
Write-Host "1L2Y model 1 secondary structure: $ss (mdtraj on Linux: CHHHHHHHTTGGGGTCCCCC)"
if ($ss.Length -ne 20) { throw "expected 20 residues, got $($ss.Length)" }
