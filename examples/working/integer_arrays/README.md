Integer Arrays
--------------

All VCs for this package fully prove with the following command-line, using 
SPARK Pro 18.0w (20170905)

    gnatprove --codepeer=on -P default.gpr -u integer_arrays.adb --prover=alt-ergo,cvc4,z3 --level=4 -j3
    
This package forms the basis for the not completely working `generic_arrays` and
`point_2d_arrays`.

Some of the properties proved here seem quite impressive. The ordering property
that was proved for unique and filter is particularly impressive.