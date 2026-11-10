#!/usr/bin/env bash
# Build mkdssp from a DSSP 3.x checkout (run from inside it) with MSYS2 UCRT64: cmbi/hssp 3.0.0 by
# default, the version vermouth (martinize2) is tested with; other versions make martinize2 warn
# "DSSP-version", which counts against its -maxwarn. cmbi/dssp 3.1.x builds the same way (it reports
# 3.1.2, run 42764560398). cmbi/hssp 3.1.x no longer carries mkdssp at all (run 42748657812).
# Only the mkdssp program is built and installed into $DSSP_PREFIX/bin.
set -euxo pipefail
: "${DSSP_PREFIX:?set DSSP_PREFIX}"
DSSP_PREFIX="$(cygpath -u "$DSSP_PREFIX")"   # the runner hands a Windows path
./autogen.sh
# What MSYS2's Boost actually ships (the log of the next failure starts here)
ls /ucrt64/lib/libboost_* | sed 's|.*/||' | sort | tr '\n' ' '; echo
# Boost.Regex (1.76+) and Boost.System (1.69+) are header-only, and MSYS2 no longer ships a
# libboost_regex / libboost_system to link. DSSP's configure still looks for them, and
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
    CXXFLAGS="-O2 -DBOOST_TIMER_ENABLE_DEPRECATED -std=c++14"
# -std=c++14: DSSP's Makefile.am sets -std=c++11 in AM_CPPFLAGS, but MSYS2's Boost.Math needs C++14
# (std::remove_extent_t etc., run 42761817875). CXXFLAGS comes later on the compile line, and gcc
# takes the last -std. Not C++17: the 2019 code may use what C++17 removed.
make -j4 mkdssp$(sed -n 's/^EXEEXT = //p' Makefile)
mkdir -p "$DSSP_PREFIX/bin"
cp mkdssp.exe "$DSSP_PREFIX/bin/" 2>/dev/null || cp src/mkdssp.exe "$DSSP_PREFIX/bin/"
"$DSSP_PREFIX/bin/mkdssp.exe" --version
