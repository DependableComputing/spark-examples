Proving Independent Invariants Fail in Composition 
------------------------------------

In polygon_2d.adb in function, in the function edges_of_polygon, there is a loop where two invariants seem to interfere. It is possible to prove the invariants separately, but when they are combined, they fail. To get around this, the code contains assumes before the invariants since presumably the invariant has already been proven. 

The code is commented to document the assumptions that were added. The first assume is on line 60, and the second is on line 92. There associated invariants are on lines 66 and 99 respectively. 

To illustrate the problem, try commenting out the assume on line 60, and all other loop invariants and assumes. The invariant at line 66 will succeed. Commenting back in the other invariants without assumes will result in invariant failure. 

1. Is it correct that if these invariants prove independently they should prove in composition? 

2. Why would the increased complexity in loop context result in these invariants failing? Is there a way to complete the invariant proof without assumes? 
