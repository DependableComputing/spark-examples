-- -----------------------------------------------------------------------------
-- segments_2d.ads              Dependable Computing
-- -----------------------------------------------------------------------------

-- Build segments off of vectors and points.
with vectors_2d;

-- Declaration of types and functions on segments.
package segments_2d with SPARK_Mode is
   use vectors_2d;

   -- A 2D segment.
   type segment_2d is record
      p1: point_2d;
      p2: point_2d;
   end record;

   -- A zero-length segment at (0.0, 0.0)
   null_segment_2d: constant segment_2d := segment_2d'(p1 => zero_point,
                                                       p2 => zero_point);


   -- Return true if the given point is on the given segment.
   --
   -- TODO: more information is generated through the function than is currently
   -- available. Do we want a more robust computation that we wrap with simpler
   -- predicates? Specifically, the dot-product test at the end tells us
   -- something about where on the segment the point lies.
   function is_point_on_segment(p: point_2d;
                                s: segment_2d) return Boolean with
     Post => (if is_point_on_segment'Result then
                are_vectors_colinear(vector_from_point_to_point(s.p1, p),
                                     vector_from_point_to_point(s.p1, s.p2))
                and
                (0.0 <= (vector_from_point_to_point(s.p1, s.p2) *
                         vector_from_point_to_point(s.p1, p))
                 and
                 (vector_from_point_to_point(s.p1, s.p2) *
                  vector_from_point_to_point(s.p1, p)) <=
                    (vector_from_point_to_point(s.p1, s.p2) *
                     vector_from_point_to_point(s.p1, s.p2))));


   -- This type reports the different conditions that arise when checking if
   -- two segments intersect.
   type segment_intersection_type is (Colinear_Overlapping,
                                      Colinear_Non_Overlapping,
                                      Parallel,
                                      Intersecting,
                                      Non_Parallel_Not_Intersecting);

   -- This type encapsulates the results from the segment intersection kernel,
   -- which needs to be able to tell us if there is an intersection as well as
   -- where the intersection occurs.
   --
   -- TODO: incorporate t and u into this type, so that we have full knowledge
   -- from the kernel?
   type intersection_record is record
      flag: segment_intersection_type;
      point: point_2d;
   end record;

   -- Analyze two segments to determine if and where they intersect.
   --
   -- INFO: The postcondition for this function proves, but only because of the
   -- asserts in the body that, at present, do not prove. So the proof is not
   -- complete.
   function segment_intersect_kernel(s1: in segment_2d;
                                     s2: in segment_2d) return intersection_record with
     Post => (if segment_intersect_kernel'Result.flag = Intersecting then
                is_point_on_segment(segment_intersect_kernel'Result.point, s1) and
                is_point_on_segment(segment_intersect_kernel'Result.point, s2));


   -- Return true if two line segments intersect.
   function are_segments_intersecting(s1: segment_2d;
                                      s2: segment_2d) return Boolean is
      (segment_intersect_kernel(s1, s2).flag = Intersecting);

   -- Return the point of intersection between two segments that are known
   -- to intersect.
   --
   -- TODO: postcondition?
   function segment_intersection(s1: segment_2d;
                                 s2: segment_2d) return point_2d is
     (segment_intersect_kernel(s1, s2).point)
   with
     Pre => (are_segments_intersecting(s1, s2));
end segments_2d;
