#!/usr/bin/env bash
# Patches applied to the GROMACS source tree before the Windows build (run from its top folder).
#
# 1. cmake/gmxManagePlumed.cmake: GROMACS 2025's PLUMED interface (mdrun -plumed) loads the
#    PLUMED kernel with dlopen (src/external/plumed/Plumed.h, __PLUMED_HAS_DLOPEN), and the
#    CMake stops on Windows ("PLUMED is not supported on Windows"). dlfcn-win32 (MIT, a thin
#    layer over LoadLibrary / GetProcAddress) gives dlopen / dlsym / dlerror on Windows, so the
#    Windows branch takes it from find_package(dlfcn-win32) and turns the interface on.
#    Plumed.h has no Windows code of its own: with dlfcn.h available it builds unchanged.
#    MSVC must report the real C++ standard (/Zc:__cplusplus): Plumed.h selects its C++11
#    parts with "#if __cplusplus > 199711L", and MSVC says 199711L by default.
#    The kernel is the MinGW libplumedKernel.dll of the plumed workflow; Plumed.h talks to it
#    through C functions only (plumed_cmd and the nothrow handler), so the compilers may differ.
set -euo pipefail
f=cmake/gmxManagePlumed.cmake
python3 - "$f" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '''    if(WIN32)
        if(GMX_USE_PLUMED STREQUAL "ON")
                message(FATAL_ERROR "PLUMED is not supported on Windows. Reconfigure with -DGMX_USE_PLUMED=OFF.")
        endif()
    elseif'''
new = '''    if(WIN32)
        # windows-md-tools: dlopen on Windows from dlfcn-win32 (MIT). See gromacs/patch.sh.
        find_package(dlfcn-win32 CONFIG QUIET)
        if(dlfcn-win32_FOUND AND NOT GMX_USE_PLUMED STREQUAL "OFF")
            set(PLUMED_DIR "${CMAKE_SOURCE_DIR}/src/external/plumed")
            target_link_libraries(plumedgmx INTERFACE dlfcn-win32::dl)
            # Plumed.h picks its C++11 parts (the nullptr_t overload of SafePtr, long long)
            # with "#if __cplusplus > 199711L", and MSVC reports 199711L unless told otherwise:
            # without this, cmd("...", nullptr) is an ambiguous call (C2668).
            target_compile_options(plumedgmx INTERFACE $<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>)
            target_include_directories(plumedgmx SYSTEM INTERFACE $<BUILD_INTERFACE:${PLUMED_DIR}>)
            set(GMX_PLUMED_ACTIVE ON PARENT_SCOPE)
            message(STATUS "PLUMED interface on Windows with dlfcn-win32 (${dlfcn-win32_DIR})")
        elseif(GMX_USE_PLUMED STREQUAL "ON")
            message(FATAL_ERROR "PLUMED on Windows needs dlfcn-win32 (find_package(dlfcn-win32 CONFIG)).")
        endif()
    elseif'''
if s.count(old) != 1:
    sys.exit("gmxManagePlumed.cmake: the Windows branch is not the one this patch knows")
open(p, "w", encoding="utf-8", newline="\n").write(s.replace(old, new))
print("patched " + p)
PY
