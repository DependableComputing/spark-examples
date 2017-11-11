Point_2d Arrays
---------------

This example does not fully prove, even though it is a copy-paste of the
`integer_arrays` code with only minimal changes to the specification (the 
package name, the `element_type` and the definition of `to_map`). The body
differs only in 

The command line used for SPARK Pro 18.0w (20170905) is:

    gnatprove --codepeer=on -P default.gpr -u point_2d_arrays.adb --prover=alt-ergo,cvc4,z3 --level=4 -j3
    
I believe I was able to get around most of the proof failures by increasing the
timeout, but the increase in proof time arising from merely changing the element
type of the array is troubling.