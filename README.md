# windows-md-tools

Unofficial Windows (x86-64) builds of molecular-simulation programs that have no Windows
release of their own (or none with what is needed here), made with GitHub Actions: MSYS2 /
MinGW-w64 for DSSP and PLUMED, MSVC + CUDA for GROMACS.

| Tool | Workflow | Status |
|---|---|---|
| DSSP 3.0.0 (`mkdssp`, [cmbi/hssp](https://github.com/cmbi/hssp) 3.0.0) | `.github/workflows/dssp.yml` | done; 3.1.2 (cmbi/dssp) also built and passed |
| PLUMED 2.10.2 kernel (`libplumedKernel.dll`) and `plumed` | `.github/workflows/plumed.yml` | done; `plumed driver` gives the expected distances without MSYS2 |
| GROMACS 2025.5 (`gmx`, CUDA, AVX2), shown as `2025.5-moldeck`, with `mdrun -plumed` | `.github/workflows/gromacs.yml` | done; a well-tempered metadynamics run with the PLUMED build gives COLVAR / HILLS of the same form as Linux (headers, rows, times, first value, hill width and height) on an RTX 4070 Ti |

**These builds are unofficial and come with no warranty.** They are not made, checked or
supported by the upstream projects; report problems here, not upstream. Builds of modified
programs carry a version suffix and do not call themselves the official release.

## What a build produces

Each workflow builds one tool from a pinned upstream tag, copies the runtime DLLs it needs
next to it (MinGW-w64: `scripts/bundle_dlls.sh`, with the licence of each DLL's MSYS2 package;
GROMACS: the CUDA, FFTW, dlfcn-win32 and MSVC runtime DLLs it depends on), runs a smoke test
from PowerShell **without the build tools on PATH** (as on a user's machine), and zips the
result. Build artifacts are kept for one day only; nothing is attached to Releases.

## Licences

The scripts in this repository are under the MIT licence (`LICENSE`). The programs built
here keep their own licences, which are copied into each zip under `licenses/`; see
`NOTICE.md`. The exact upstream source of each build is the tag recorded in the zip
(`SOURCE-COMMIT.txt`) plus the scripts and patches in this repository at that commit.
