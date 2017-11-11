-- -----------------------------------------------------------------------------
-- segments_2d.adb              Dependable Computing
-- -----------------------------------------------------------------------------

package body segments_2d with SPARK_mode is

   -- Return true if the given point is on the given segment. This code is
   -- adapted from:
   -- http://www.lucidarme.me/?p=1952
   function is_point_on_segment(p: point_2d;
                                s: segment_2d) return Boolean
   is
      AC: vector_2d := vector_from_point_to_point(s.p1, p);
      AB: vector_2d := vector_from_point_to_point(s.p1, s.p2);

      AB_dot_AC: Float := AB * AC;
      AB_dot_AB: Float := AB * AB;

   begin
      -- INFO: Postcondition proves directly on level 1 with wavefront and all
      -- provers.
      return are_vectors_colinear(AC, AB) and then
        (0.0 <= AB_dot_AC and
                AB_dot_AC <= AB_dot_AB);
   end is_point_on_segment;

   -- The code for this is developed from this StackOverflow question:
   -- https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
   -- and approximately matches the unimplementable approach taken in the PVS
   -- PolyCARP library for `open_segment_2Ds_cross_alt`.
   function segment_intersect_kernel(s1: in segment_2d;
                                     s2: in segment_2d) return intersection_record
   is
      -- For readability of comparison to the source algorithm, I'm aliasing
      -- elements of the segments.
      --
      -- The vector/point duality here is a bit ... uncomfortable.

      -- Let p be the start point of s1.
      p: point_2d := s1.p1;

      -- Let r be the vector from p1 to p2 of s1.
      r: vector_2d := s1.p2 - s1.p1;

      -- Let q be the start point of s2.
      q: point_2d := s2.p1;

      -- Let s be the vector from p1 to p2 of s2.
      s: vector_2d := s2.p2 - s2.p1;

      -- Intermediate variable representing the r cross s.
      r_cross_s: Float := cross(r, s);

      -- Intermediate variable for (q - p) x r
      q_minus_p_cross_r: Float := cross((q - p), r);

      result: intersection_record;
   begin
      -- As the algorithm given notes, there are four cases to consider, which
      -- actually yield 5 discrete results.

      -- -----------------------------
      -- 1. The segments are colinear:
      if r_cross_s = 0.0 and q_minus_p_cross_r = 0.0 then
         -- This breaks into further tests to determine colinear overlapping v
         -- colinear non-overlapping.
         colinear: declare
            -- Note that in the original formulation of this algorithm, we had:
            --   t0: Float := ((q - p) * r) / (r * r);
            --   t1: Float := ((q + s - p) * r) / (r * r);
            --   abs_diff: Float := abs(t0 - t1);
            -- and then tested the difference on [0, 1].
            --
            -- We can eliminate the division if we simply test on [0, r*r].
            -- Because r*r is always non-negative, we don't need to case the
            -- inequality to handle a possible sign change.

            t0: Float := (q - p) * r;
            t1: Float := (q + s - p) * r;

            -- TODO: unproved overflow check here
            abs_diff: Float := abs(t0 - t1);
         begin
            if 0.0 <= abs_diff and abs_diff <= (r*r) then
               result.flag := Colinear_Overlapping;
               result.point := zero_point;
            else
               result.flag := Colinear_Non_Overlapping;
               result.point := zero_point;
            end if;
         end colinear;

      -- ----------------------------
      -- 2. The segments are parallel
      elsif r_cross_s = 0.0 and q_minus_p_cross_r /= 0.0 then
         result.flag := Parallel;
         result.point := zero_point;

      else
         pragma Assert(r_cross_s /= 0.0);

         -- The final two cases deal with non-parallel, non-colinear segments.
         -- Either the segments intersect or they don't (because they're not
         -- long enough).
         possibly_intersecting: declare
            q_minus_p_cross_s: Float := cross((q - p), s);

            -- TODO: unproved overflow check here
            t: Float := q_minus_p_cross_s / r_cross_s;

            -- TODO: unproved overflow check here
            u: Float := q_minus_p_cross_r / r_cross_s;
         begin
            -- -------------------------------------------
            -- 3. The segments have a defined intersection
            if 0.0 <= t and t <= 1.0 and 0.0 <= u and u <= 1.0 then
               result.flag := Intersecting;

               -- TODO: both of these fail to prove at level 4
               pragma Assert(if r.x >= 0.0 then t*r.x <= r.x);
               pragma Assert(if r.y >= 0.0 then t*r.y <= r.y);

               -- TODO: unproved range check failures.
               result.point := point_2d'(x => p.x + t*r.x,
                                         y => p.y + t*r.y);

               -- TODO: both of these fail to prove at level 4.
               pragma Assert(is_point_on_segment(result.point, s1));
               pragma Assert(is_point_on_segment(result.point, s2));

               -- --------------------------------------------------
               -- 4. Segments are not parallel but do not intersect.
            else
               result.flag := Non_Parallel_Not_Intersecting;
               result.point := zero_point;
            end if;
         end possibly_intersecting;
      end if;

      return result;
   end segment_intersect_kernel;
end segments_2d;
