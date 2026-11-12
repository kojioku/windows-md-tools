# GROMACS for Windows (CUDA, with the PLUMED interface)

`bin/gmx.exe` and the DLLs it needs. **Unofficial build, no warranty**; it reports itself as
`2025.5-moldeck` so that it is never taken for an official GROMACS. Built from the GROMACS release
tarball (SHA-256 in `SOURCE_SHA256.txt`) with MSVC and CUDA 12.8, SIMD AVX2_256, thread-MPI,
CUDA kernels for compute capability 5.0 to 9.0 (GROMACS's default list). Without an NVIDIA GPU
it runs on the CPU.

The only change to GROMACS: `mdrun -plumed`, which upstream CMake refuses on Windows, is enabled
by giving GROMACS's PLUMED wrapper (`Plumed.h`, which loads the kernel with `dlopen`) the
dlfcn-win32 library (`PATCHES_gromacs.sh`). The PLUMED kernel is not inside: use the PLUMED for
Windows build of the same repository and point `PLUMED_KERNEL` at its `libplumedKernel.dll`
(its `bin` folder on `PATH` too, for the MinGW DLLs):

    set PLUMED_KERNEL=C:\path\to\plumed-win\bin\libplumedKernel.dll
    set PATH=C:\path\to\plumed-win\bin;%PATH%
    gmx mdrun -deffnm md -plumed plumed.dat

Licences: GROMACS GNU LGPL v2.1; FFTW (bundled, CPU FFTs) GNU GPL v2 or later, which puts the
package as a whole under the GPL's terms; dlfcn-win32 MIT; the CUDA and MSVC runtime DLLs under
their vendors' redistribution terms. See `NOTICE.md`.
