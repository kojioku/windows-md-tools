#!/usr/bin/env bash
# Build mkdssp from a cmbi/hssp checkout (run from inside it) with MSYS2 UCRT64.
# Only the mkdssp program is built and installed into $DSSP_PREFIX/bin.
set -euxo pipefail
: "${DSSP_PREFIX:?set DSSP_PREFIX}"
DSSP_PREFIX="$(cygpath -u "$DSSP_PREFIX")"   # the runner hands a Windows path
./autogen.sh
# MSYS2's Boost libraries carry the -mt suffix; point the AX_BOOST_* macros at them
./configure --prefix="$DSSP_PREFIX" \
    --with-boost=/ucrt64 --with-boost-libdir=/ucrt64/lib \
    CXXFLAGS="-O2 -DBOOST_TIMER_ENABLE_DEPRECATED"
make -j4 mkdssp
mkdir -p "$DSSP_PREFIX/bin"
cp mkdssp.exe "$DSSP_PREFIX/bin/" 2>/dev/null || cp src/mkdssp.exe "$DSSP_PREFIX/bin/"
"$DSSP_PREFIX/bin/mkdssp.exe" --version
