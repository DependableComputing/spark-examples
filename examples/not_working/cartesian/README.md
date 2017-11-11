Cartesian
---------

This example does not fully prove. The intent of the function is to return the
cartesian product of two arrays. The intent of the *example* is to illustrate
a particular kind of challenge we have run into with loop invariants: being
able to prove that some property P holds in each iteration of the loop, but
not being able to prove that P holds from the beginning of the loop up to the
current iteration.

More precisely, we can prove this invariant:

    P(some_array(index))
    
but then cannot prove:

    for all i in some_array'First .. index => P(some_array(i))
    

The command line used for SPARK Pro 18.0w (20170905) is:

    gnatprove --codepeer=on -P default.gpr -u cartesian.adb --prover=alt-ergo,cvc4,z3 --level=4 -j3

I set a timeout of an hour, and still made no headway. My laptop's not built for
compute speed, but still....

In some early work on `integer_arrays`, I ran into this same problem at one
time. There, I was able to get around the problem by turning on more provers (it
was an accident that I was running with fewer than all three). Unfortunately, I
did not capture that state for analysis.