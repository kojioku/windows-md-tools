#!/usr/bin/env bash
# Build PLUMED from a plumed/plumed2 checkout (run from inside it) with MSYS2 UCRT64,
# serial (no MPI), no Python wrapper, no documentation. Installs into $PLUMED_PREFIX.
set -euxo pipefail
: "${PLUMED_PREFIX:?set PLUMED_PREFIX}"
# Mixed paths (D:/a/...): MSYS make accepts them and so do the native programs that the build runs
# and that get installed. A Unix-style path (/d/a/...) is baked into plumed.exe as its root and
# cannot be opened by it (run 42761822532: "directory iterator cannot open directory
# [/d/a/.../plumed2/]" when make ran plumed gen_json).
PLUMED_PREFIX="$(cygpath -m "$PLUMED_PREFIX")"
export PLUMED_ROOT="$(cygpath -m "$PWD")"
./configure --prefix="$PLUMED_PREFIX" \
    --disable-mpi --disable-python --disable-doc --disable-libsearch \
    --enable-modules=all \
    CXX=g++ CC=gcc LIBS="-lopenblas -lfftw3 -lz -ldl" \
    CPPFLAGS="-D_USE_MATH_DEFINES" \
    SOEXT=dll LDSHARED="g++ -shared"
# The kernel DLL (libplumedKernel.dll) is what an MD engine loads at run time (PLUMED_KERNEL).
# Run 42764562956 built and installed everything but only static libraries: MinGW has no dlopen,
# so configure disabled __PLUMED_HAS_DLOPEN and left SOEXT empty. dlfcn-win32 (MSYS2's
# mingw-w64-ucrt-x86_64-dlfcn, MIT; dlopen on top of LoadLibrary) provides -ldl; SOEXT and
# LDSHARED tell configure how to make a DLL.
# _USE_MATH_DEFINES: MinGW's <cmath> defines M_PI only with it under -std=c++17 (run 42422874267:
# "'M_PI' was not declared" in the membranefusion module).
# -k: keep going past a failing file so that one run lists every error, not only the first directory's.
make -j4 -k
make install
# Windows looks for a DLL next to the program (and on PATH), not in lib/: plumed.exe could not
# start with the kernel in lib/ (run 42816531356). Keep both DLLs in bin/, where the DLL bundler
# also walks their imports; an MD engine is given bin/libplumedKernel.dll via PLUMED_KERNEL.
mv "$PLUMED_PREFIX"/lib/libplumedKernel.dll "$PLUMED_PREFIX"/lib/libplumed.dll "$PLUMED_PREFIX/bin/"
ls -la "$PLUMED_PREFIX/bin" "$PLUMED_PREFIX/lib" || true
# the kernel the MD engines load (PLUMED_KERNEL); its Windows name is what we look for
find "$PLUMED_PREFIX" -iname '*plumedKernel*' | tee kernel_files.txt
test -s kernel_files.txt
"$PLUMED_PREFIX/bin/plumed" info --version
