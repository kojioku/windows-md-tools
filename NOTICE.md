# Third-party notices

The zips built by this repository contain programs by other authors, under their own licences.
Each zip carries the licence texts under `licenses/`.

| Program | Upstream | Licence | Changes made here |
|---|---|---|---|
| DSSP 3.0.0 (`mkdssp`) | https://github.com/cmbi/hssp (tag 3.0.0) | the licence files in the upstream tree (`COPYING`, `LICENSE_1_0.txt`) | none (built as released) |
| PLUMED (`plumed.exe`, `libplumedKernel`) | https://github.com/plumed/plumed2 | GNU LGPL v3 (`COPYING.LESSER`) | one fix to a `configure` check for MinGW (`plumed/patch.sh`); PLUMED's own source unchanged |
| dlfcn-win32 (`dlopen` for the PLUMED kernel, linked in) | https://github.com/dlfcn-win32/dlfcn-win32 | MIT | none |
| GROMACS 2025.5 (`gmx.exe`, shown as `2025.5-moldeck`) | https://ftp.gromacs.org/gromacs/ (release tarball, SHA-256 in `SOURCE_SHA256.txt`) | GNU LGPL v2.1 (`COPYING` in the source) | the PLUMED interface enabled on Windows through dlfcn-win32: one change to `cmake/gmxManagePlumed.cmake` (`gromacs/patch.sh`, shipped as `PATCHES_gromacs.sh`); GROMACS's C++ source unchanged |
| FFTW 3 (`fftw3f.dll`, CPU FFTs of GROMACS) | https://www.fftw.org/ (vcpkg port) | GNU GPL v2 or later | none |
| CUDA runtime (`cufft64_*.dll`, linked from GROMACS) | NVIDIA CUDA Toolkit | NVIDIA CUDA EULA, redistributable files (Attachment A) | none |
| Microsoft Visual C++ runtime (`vcruntime140*.dll`, `msvcp140*.dll`, `vcomp140.dll`) | Visual Studio 2022 | Microsoft redistributable | none |
| MinGW-w64 / GCC runtime DLLs | https://github.com/msys2/MINGW-packages | per package, listed in `licenses/mingw/DLLS.txt` | none |

Source for every program is available from the upstream URL at the tag recorded in the zip
(`SOURCE-COMMIT.txt`); the build scripts are in this repository.
