#!/usr/bin/env bash
# Source fixes for building PLUMED with MinGW-w64. Run from inside a plumed/plumed2 checkout.
# Each fix is a fixed-string replacement that must hit an exact number of times; anything else
# stops the build (a silent no-op would hide that upstream changed the code).
set -euo pipefail

replace() {   # replace FILE COUNT OLD NEW
  local file=$1 want=$2 old=$3 new=$4 got
  got=$(grep -cF -- "$old" "$file" || true)
  if [ "$got" != "$want" ]; then
    echo "patch.sh: expected $want line(s) with '$old' in $file, found $got" >&2
    exit 1
  fi
  OLD="$old" NEW="$new" perl -0pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$file"
  echo "patch.sh: $file: $got line(s) fixed"
}

# 1. configure's "filesystem library" check builds a std::string from a std::filesystem::path.
#    On Windows path::value_type is wchar_t, so there is no such conversion and the check fails
#    ("C++17 filesystem library not supported", run 42221678678). PLUMED's own code already uses
#    .string() (src/tools/Tools.cpp, Tools::ls); only the check needs it.
replace configure    3 'std::string(dir_entry.path().filename())' 'dir_entry.path().filename().string()'
replace configure.ac 1 'std::string(dir_entry.path().filename())' 'dir_entry.path().filename().string()'
