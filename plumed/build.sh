#!/usr/bin/env bash
# Build PLUMED from a plumed/plumed2 checkout (run from inside it) with MSYS2 UCRT64,
# serial (no MPI), no Python wrapper, no documentation. Installs into $PLUMED_PREFIX.
set -euxo pipefail
: "${PLUMED_PREFIX:?set PLUMED_PREFIX}"
PLUMED_PREFIX="$(cygpath -u "$PLUMED_PREFIX")"   # the runner hands a Windows path
./configure --prefix="$PLUMED_PREFIX" \
    --disable-mpi --disable-python --disable-doc --disable-libsearch \
    --enable-modules=all \
    CXX=g++ CC=gcc LIBS="-lopenblas -lfftw3 -lz"
make -j4
make install
ls -la "$PLUMED_PREFIX/bin" "$PLUMED_PREFIX/lib" || true
# the kernel the MD engines load (PLUMED_KERNEL); its Windows name is what we look for
find "$PLUMED_PREFIX" -iname '*plumedKernel*' | tee kernel_files.txt
test -s kernel_files.txt
"$PLUMED_PREFIX/bin/plumed" info --version
