Array Comprehension for Intersection
------------------------------------

The goal of this attempt was to build a proven implementation of a function that
returns the points of intersection between two polygons. To get around the
apparent problem of nested loops with complex operations, we tried an approach
based on array comprehension: 

1. build the cartesian product of the edge arrays from the two polygons

2. filter the product so that only intersecting edge pairs remained

3. transform the filtered edge pairs into an array of the points of intersection

The thought in doing this was that, once the cartesian product was computed,
only single iteration would be required. Moreover, at each step, a relatively
simple and simple-to-prove operation could be conducted.

This didn't actually work very well, because we still needed to reason about the
full complexity of some of what we were hiding in our functions, such as that
all edge pairs had been considered.

Moreover, we ran into a number of proof failures, typically where mixed
quantifiers were involved. The most surprising of these occurred directly after
the cartesian product was returned: we could not prove an assertion that
followed directly from the postcondition. More surprising, we could not *assume*
the assertion and then prove the assertion immediately after the assumption.

There is extensive documentation in the body of `intersection` that identifies
what proves and what doesn't and that tries to lay out the rationale for the
assertions used. Essentially, I took the approach of trying to lead the prover
to my conclusion, as I might with an interactive theorem prover. 

**Note**: this function is incomplete in any case, as it does not adequately 
handle the situation in which two polygons have partially or totally overlapping 
edges.

**Note**: later work on `integer_arrays` developed stronger (and more elegantly
stated) predicates for the contracts on `filter`. Integrating that work may be
desirable, but I think it unlikely to move past all of the proof challenges 
here.