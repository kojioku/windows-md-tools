# mkdssp for Windows (DSSP 3.x)

`bin/mkdssp.exe` with the MinGW-w64 runtime DLLs it needs. No installation: put `bin/` on PATH
or call the program by its full path.

    mkdssp --version
    mkdssp -i protein.pdb > protein.dss

Built from https://github.com/cmbi/hssp at the tag in `SOURCE-COMMIT.txt`, unmodified. DSSP 3.x
writes the classic DSSP 2/3 table that programs calling `mkdssp -i` (for example
vermouth / martinize2) read; DSSP 4.x has a different command line and output and cannot
stand in for it.

Unofficial build, no warranty. Licences: `licenses/` and `NOTICE.md`.

Reference for the smoke test (`data/1l2y_model1_atoms.pdb`: PDB entry 1L2Y, model 1, ATOM records
only; PDB data are CC0): the secondary-structure string from mdtraj's DSSP on Linux is
`CHHHHHHHTTGGGGTCCCCC`.
