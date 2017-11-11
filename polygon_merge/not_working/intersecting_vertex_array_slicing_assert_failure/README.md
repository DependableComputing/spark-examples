Vertex Injection Array Slicing Failure
------------------------------------

Line 336 of vertex_injection.adb fails. It is a verbatim restatement of an assignment immediately preceding the assert. 

The assignment and assert are as follows: 

		result_vert(index .. index+(intersect_count-1)) :=
           intersecting(intersecting'First .. intersecting'First+(intersect_count-1));

		pragma Assert(result_vert(index .. index+(intersect_count-1)) =
                         intersecting(intersecting'First .. intersecting'First+(intersect_count-1)));

The reported failure is as follows:

		vertex_injection.adb:336:24: medium: assertion might fail, cannot prove result_vert(index .. index+(intersect_count-1)) = intersecting (1..R108b)

1. The failure would seem to suggest the prover cannot handle "array slicing" in this manner. Is there any way of using array slicing that the prover can support, or must we resort to a nested loop?

2. The assertion failure message above is confusing with respect to "(1..R108b)". What does R108b mean? Is it related to the failure to prove? 
