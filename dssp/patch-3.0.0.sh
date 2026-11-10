#!/usr/bin/env bash
# Source fixes for building DSSP 3.0.0 (cmbi/hssp tag 3.0.0) with MinGW-w64 and a current Boost.
# Run from inside the checkout. Every fix must hit an exact count, else the build stops (a silent
# no-op would hide that the source is not what this was written for).
set -euo pipefail

count() { cat "$@" | grep -oF -- "$PAT" | wc -l | tr -d ' '; }

replace_all() {   # replace_all COUNT OLD NEW FILE...
  local want=$1 old=$2 new=$3; shift 3
  PAT=$old; local got; got=$(count "$@")
  if [ "$got" != "$want" ]; then
    echo "patch-3.0.0.sh: expected $want x '$old' in $*, found $got" >&2; exit 1
  fi
  for f in "$@"; do OLD="$old" NEW="$new" perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$f"; done
  echo "patch-3.0.0.sh: '$old' -> '$new': $got"
}

# 1. Boost.TR1 was removed from Boost (1.65). std::tuple / std::tie / std::make_tuple are the same
#    thing in C++11 (run 42772768258: "boost/tr1/tuple.hpp: No such file or directory").
replace_all 1 '#include <boost/tr1/tuple.hpp>' '#include <tuple>' src/primitives-3d.h
replace_all 7 'std::tr1::' 'std::' src/structure.h src/dssp.cpp src/primitives-3d.h \
    src/structure.cpp src/primitives-3d.cpp

# 2. mas.h defines nullptr as NULL whenever no *macro* nullptr exists - i.e. always, since nullptr is
#    a keyword. With MinGW's NULL that breaks libstdc++ (run 42772768258: "invalid conversion from
#    'long long int' to 'std::_List_node<boost::thread*>*'" inside boost::thread_group).
replace_all 1 '#define nullptr NULL' '/* nullptr is a C++11 keyword (MinGW build: define removed) */' src/mas.h
