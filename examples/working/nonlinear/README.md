Nonlinear
---------

This example shows that SPARK can handle some nonlinear arithmetic quite well,
if z3 and cvc4 are both in the solver set. Curiously, however, we've run into
situations in which these same properties cannot be proved when asserted in the
context of a larger subprogram.