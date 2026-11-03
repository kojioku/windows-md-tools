# PLUMED for Windows

`bin/plumed.exe`, the PLUMED kernel library (`libplumedKernel`) and the MinGW-w64 runtime DLLs
they need. Unofficial build, no warranty. Built from https://github.com/plumed/plumed2 at the
tag in `SOURCE-COMMIT.txt`, unmodified, serial (no MPI), without the Python wrapper.

    plumed info --version
    plumed driver --plumed plumed.dat --ixyz traj.xyz

An MD engine loads the kernel through the environment variable `PLUMED_KERNEL` (the full path
of the kernel library). Licence: GNU LGPL v3 (`licenses/plumed/COPYING.LESSER`); see `NOTICE.md`.
