# windows-md-tools

Unofficial Windows (x86-64) builds of molecular-simulation helper programs that have
no Windows release of their own, made with GitHub Actions and MSYS2 / MinGW-w64.

| Tool | Workflow | Status |
|---|---|---|
| DSSP 3.x (`mkdssp`, [cmbi/hssp](https://github.com/cmbi/hssp)) | `.github/workflows/dssp.yml` | first build |
| PLUMED kernel (DLL) | planned | — |
| GROMACS with the PLUMED interface | planned | — |

**These builds are unofficial and come with no warranty.** They are not made, checked or
supported by the upstream projects; report problems here, not upstream. Builds of modified
programs carry a version suffix and do not call themselves the official release.

## What a build produces

Each workflow builds one tool from a pinned upstream tag, copies the MinGW-w64 runtime DLLs
it needs next to it (`scripts/bundle_dlls.sh`, with the licence of each DLL's MSYS2 package),
runs a smoke test from PowerShell **without MSYS2 on PATH** (as on a user's machine), and
zips the result. Build artifacts are kept for one day only; nothing is attached to Releases.

## Licences

The scripts in this repository are under the MIT licence (`LICENSE`). The programs built
here keep their own licences, which are copied into each zip under `licenses/`; see
`NOTICE.md`. The exact upstream source of each build is the tag recorded in the zip
(`SOURCE-COMMIT.txt`) plus the scripts and patches in this repository at that commit.
