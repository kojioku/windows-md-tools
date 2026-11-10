#!/usr/bin/env bash
# Build PLUMED from a plumed/plumed2 checkout (run from inside it) with MSYS2 UCRT64,
# serial (no MPI), no Python wrapper, no documentation. Installs into $PLUMED_PREFIX.
set -euxo pipefail
: "${PLUMED_PREFIX:?set PLUMED_PREFIX}"
PLUMED_PREFIX="$(cygpath -u "$PLUMED_PREFIX")"   # the runner hands a Windows path
./configure --prefix="$PLUMED_PREFIX" \
    --disable-mpi --disable-python --disable-doc --disable-libsearch \
    --enable-modules=all \
    CXX=g++ CC=gcc LIBS="-lopenblas -lfftw3 -lz" \
    CPPFLAGS="-D_USE_MATH_DEFINES"
# _USE_MATH_DEFINES: MinGW's <cmath> defines M_PI only with it under -std=c++17 (run 42422874267:
# "'M_PI' was not declared" in the membranefusion module).
# -k: keep going past a failing file so that one run lists every error, not only the first directory's.
make -j4 -k
make install
ls -la "$PLUMED_PREFIX/bin" "$PLUMED_PREFIX/lib" || true
# the kernel the MD engines load (PLUMED_KERNEL); its Windows name is what we look for
find "$PLUMED_PREFIX" -iname '*plumedKernel*' | tee kernel_files.txt
test -s kernel_files.txt
"$PLUMED_PREFIX/bin/plumed" info --version
