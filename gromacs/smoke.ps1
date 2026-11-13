# Smoke test of the packaged GROMACS, with nothing but the package and System32 on PATH
# (no MSVC, no CUDA toolkit, no vcpkg): gmx starts, says it is the CUDA + PLUMED build,
# and runs 200 steps of a water box on the CPU (the runner has no GPU) with -plumed, loading
# the MinGW libplumedKernel.dll of the plumed workflow. COLVAR and HILLS must come out.
# Without -PlumedKernel the MD runs without -plumed (the check of -plumed is then skipped, and said so).
param([string]$Gmx, [string]$PlumedKernel = "", [string]$Data, [string]$Work)
$ErrorActionPreference = "Continue"     # native programs write to stderr; judge by exit codes
$extra = if ($PlumedKernel) { "$(Split-Path $PlumedKernel);" } else { "" }
$env:PATH = "$(Split-Path $Gmx);$extra$env:SystemRoot\System32;$env:SystemRoot"
New-Item -ItemType Directory -Force -Path $Work | Out-Null
Set-Location $Work
function Run([string]$what, [string[]]$argv) {
    & $Gmx @argv *> "$what.log"
    if ($LASTEXITCODE -ne 0) { Get-Content "$what.log" -Tail 40; throw "gmx $what failed ($LASTEXITCODE)" }
}
& $Gmx --version *> version.log
if ($LASTEXITCODE -ne 0) { Get-Content version.log; throw "gmx --version failed" }
$v = Get-Content version.log -Raw
foreach ($want in @("moldeck", "GPU support:\s+CUDA", "SIMD instructions:\s+AVX2_256")) {
    if ($v -notmatch $want) { Get-Content version.log; throw "gmx --version lacks '$want'" }
}
& $Gmx mdrun -h *> mdrun_help.log
if ((Get-Content mdrun_help.log -Raw) -notmatch "-plumed") { throw "mdrun has no -plumed option" }
Run "solvate" @("solvate", "-cs", "spc216.gro", "-box", "2", "2", "2", "-o", "w.gro")
$n = (Select-String -Path w.gro -Pattern "OW").Count
@('#include "oplsaa.ff/forcefield.itp"', '#include "oplsaa.ff/spce.itp"', '[ system ]', 'water', '[ molecules ]', "SOL $n") |
    Set-Content -Encoding ascii topol.top
Run "grompp" @("grompp", "-f", "$Data\smoke.mdp", "-c", "w.gro", "-p", "topol.top", "-o", "md.tpr")
if (!$PlumedKernel) {
    Run "mdrun" @("mdrun", "-deffnm", "md", "-nt", "2")
    Select-String -Path md.log -Pattern "GPU|Performance:" | Select-Object -First 8 | ForEach-Object { $_.Line }
    Write-Output "smoke test passed WITHOUT -plumed (no PLUMED kernel given)"
    exit 0
}
Copy-Item "$Data\plumed_smoke.dat" plumed.dat
$env:PLUMED_KERNEL = $PlumedKernel
Run "mdrun" @("mdrun", "-deffnm", "md", "-plumed", "plumed.dat", "-nt", "2")
foreach ($f in @("COLVAR", "HILLS")) {
    if (!(Test-Path $f)) { Get-Content md.log -Tail 40; throw "$f was not written" }
    $lines = (Get-Content $f | Where-Object { $_ -notmatch "^#" }).Count
    Write-Output ("{0}: {1} lines" -f $f, $lines)
    if ($lines -lt 5) { throw "$f has $lines data lines" }
}
Select-String -Path md.log -Pattern "PLUMED|GPU|Performance:" | Select-Object -First 12 | ForEach-Object { $_.Line }
Write-Output "smoke test passed"
