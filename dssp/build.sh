#!/usr/bin/env bash
# Build mkdssp from a cmbi/hssp checkout (run from inside it) with MSYS2 UCRT64.
# Only the mkdssp program is built and installed into $DSSP_PREFIX/bin.
set -euxo pipefail
: "${DSSP_PREFIX:?set DSSP_PREFIX}"
DSSP_PREFIX="$(cygpath -u "$DSSP_PREFIX")"   # the runner hands a Windows path
./autogen.sh
# What MSYS2's Boost actually ships (the log of the next failure starts here)
ls /ucrt64/lib/libboost_* | sed 's|.*/||' | sort | tr '\n' ' '; echo
# Boost.Regex (1.76+) and Boost.System (1.69+) are header-only, and MSYS2 no longer ships a
# libboost_regex / libboost_system to link. hssp's configure still looks for them, and
# autoconf-archive's AX_BOOST_REGEX then fails with a stale message ("Could not link against
# boost_program_options-mt", run 42320443487). Skip the check for a library that is not there;
# the header-only code needs no -l.
skip=()
for lib in regex system; do
  if ! ls /ucrt64/lib/libboost_${lib}-mt.* >/dev/null 2>&1 && ! ls /ucrt64/lib/libboost_${lib}.* >/dev/null 2>&1; then
    echo "build.sh: no libboost_${lib} in /ucrt64/lib (header-only): --with-boost-${lib}=no"
    skip+=("--with-boost-${lib}=no")
  fi
done
# MSYS2's Boost libraries carry the -mt suffix; point the AX_BOOST_* macros at them
./configure --prefix="$DSSP_PREFIX" \
    --with-boost=/ucrt64 --with-boost-libdir=/ucrt64/lib "${skip[@]}" \
    CXXFLAGS="-O2 -DBOOST_TIMER_ENABLE_DEPRECATED"
make -j4 mkdssp
mkdir -p "$DSSP_PREFIX/bin"
cp mkdssp.exe "$DSSP_PREFIX/bin/" 2>/dev/null || cp src/mkdssp.exe "$DSSP_PREFIX/bin/"
"$DSSP_PREFIX/bin/mkdssp.exe" --version
