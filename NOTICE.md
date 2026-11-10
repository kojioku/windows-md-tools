# Third-party notices

The zips built by this repository contain programs by other authors, under their own licences.
Each zip carries the licence texts under `licenses/`.

| Program | Upstream | Licence | Changes made here |
|---|---|---|---|
| DSSP 3.x (`mkdssp`) | https://github.com/cmbi/dssp | the licence files in the upstream tree (`COPYING`, `LICENSE_1_0.txt`) | none (built as released) |
| PLUMED (`plumed.exe`, `libplumedKernel`) | https://github.com/plumed/plumed2 | GNU LGPL v3 (`COPYING.LESSER`) | one fix to a `configure` check for MinGW (`plumed/patch.sh`); PLUMED's own source unchanged |
| MinGW-w64 / GCC runtime DLLs | https://github.com/msys2/MINGW-packages | per package, listed in `licenses/mingw/DLLS.txt` | none |

Source for every program is available from the upstream URL at the tag recorded in the zip
(`SOURCE-COMMIT.txt`); the build scripts are in this repository.
