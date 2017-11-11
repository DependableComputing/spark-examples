Generic Arrays
--------------

This example does not fully prove, when instantiated with Integers, even though
the code used to construct the generic is exactly the same as `integer_arrays`.
The command line used for SPARK Pro 18.0w (20170905) is:

    gnatprove --codepeer=on -P default.gpr -u generic_arrays.adb --prover=alt-ergo,cvc4,z3 --level=4 -j3
    
It would also be nice if SPARK could prove functional correctness of a generic, 
before instantiation. I realize not all properties can be shown prior to 
instantiation, but many (most?) probably can.

As a final note, there is a very tricky problem we ran into with generics that
has to do with the use of preconditions on generic subprogram actual parameters. 
When a generic subprogram actual parameter has a precondition that is narrower
than the precondition on the generic subprogram formal parameter:

1. The compiler doesn't catch the type error (and neither does the examiner) and
2. Even if the precondition is fully satisfied when the generic is used, the
   proof system seems to be unable to make use of the precondition for later
   reasoning.
   
The relationship between SPARK and generics seems tricky and worth further
exploration. 