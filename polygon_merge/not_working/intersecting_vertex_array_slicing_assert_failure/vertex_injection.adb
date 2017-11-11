package body vertex_injection with SPARK_Mode is

   --       -- Make a copy of the input array that has only unique elements.
   --     function make_unique(arr: polygon_2d_vertices) return polygon_2d_vertices is
   --        result: polygon_2d_vertices(arr'Range) := arr;
   --        result_index: Natural := arr'First - 1;
   --     begin
   --        -- Iterate over all of the elements of the input and assign them into the
   --        -- output if the output does not already contain them.
   --        for i in arr'Range loop
   --           -- Does the output not contain this element?
   --           if (for all j in result'First .. result_index =>
   --                 result(j) /= arr(i))
   --           then
   --              -- Bump our index (which starts before the start of the array).
   --              result_index := result_index + 1;
   --
   --              -- Necessary to prevent the range check below from failing.
   --              pragma Assert(result_index in arr'Range);
   --
   --              -- Assign the element.
   --              result(result_index) := arr(i);
   --           end if;
   --
   --           -- Necessary: we must establish the upper bound on the result index.
   --           pragma Loop_Invariant(result_index <= i);
   --
   --           -- Prove order preservation so far.
   --           pragma Loop_Invariant(preserves_order(result, arr, result'First, result_index));
   --
   --           -- Prove uniqueness so far.
   --           pragma Loop_Invariant(is_unique(result, result'First, result_index));
   --
   --           -- Prove that every element in the result came from the input.
   --           pragma Loop_Invariant(maps_to(result, arr, result'First, result_index));
   --
   --           -- Prove that every element of the input examined so far appears in
   --           -- the output.
   --           pragma Loop_Invariant(maps_to(arr, result, arr'First, i, result'First, result_index));
   --        end loop;
   --
   --        -- Return the slice of the result that has been populated.
   --        return result(arr'First .. result_index);
   --     end make_unique;


   -- Make a copy of the input array that has only unique elements.
   function make_unique(arr: polygon_2d_vertices) return polygon_2d_vertices is
      result: polygon_2d_vertices(arr'Range) := arr;
      result_index: Natural := arr'First - 1;
   begin
      -- Iterate over all of the elements of the input and assign them into the
      -- output if the output does not already contain them.
      for i in arr'Range loop
         -- Does the output not contain this element?
         if (for all j in result'First .. result_index =>
               result(j) /= arr(i))
         then
            -- Bump our index (which starts before the start of the array).
            result_index := result_index + 1;

            -- Necessary to prevent the range check below from failing.
            pragma Assert(result_index in arr'Range);

            -- Assign the element.
            result(result_index) := arr(i);
         end if;

         -- Necessary: we must establish the upper bound on the result index.
         pragma Loop_Invariant(result_index <= i);

         -- Prove uniqueness so far.
         pragma Loop_Invariant(for all n in result'First .. result_index-1 =>
                                 (for all m in n+1 .. result_index =>
                                    result(n) /= result(m)));

         -- Prove that every element in the result came from the input.
         pragma Loop_Invariant(for all n in result'First .. result_index =>
                                 (for some m in arr'Range =>
                                    result(n) = arr(m)));

         -- Prove that every element of the input examined so far appears in
         -- the output.
         pragma Loop_Invariant(for all n in arr'First .. i =>
                                 (for some m in result'First .. result_index =>
                                    result(m) = arr(n)));
      end loop;

      -- Return the slice of the result that has been populated.
      return result(arr'First .. result_index);
   end make_unique;


   --TODO/NOTE: Consider using a set for vertices in the future to avoid needing
   --to remove redundancies
   function inject_intersecting_vertices_into_polygon(vertices: polygon_2d_vertices;
                                                      polygon: polygon_2d) return polygon_2d
   is
      --Note: total result vertices. The size is based on assuming a hypothetical
      --worst-case scenario, where every vertex intersects every edge.
      result_vert: polygon_2d_vertices(1..polygon.vertices'Length + vertices'Length*polygon.vertices'Length) := (others => zero_point);
      intersecting: polygon_2d_vertices(1..vertices'Length) := (others => zero_point);
      edges: polygon_2d_edges := edges_of_polygon(polygon);
      index: Natural := result_vert'First;
      intersect_count: Natural;

      unique_vert: polygon_2d_vertices :=make_unique(vertices);

      index_ghost: Natural := index with Ghost;
      result_vert_ghost: polygon_2d_vertices(result_vert'Range) with Ghost;
   begin

      --TODO: sanitization should occur here first and length checked on the return value.
      if (unique_vert'Length = 0) then
         return polygon;
      end if;

      -- Necessary Assert
      pragma Assert(unique_vert'Length <= vertices'Length);

      -- Sanity Check
      pragma Assert(vertices'Length /= 0);

      -- Sanity Check
      pragma Assert(intersecting'Length = vertices'Length and
                      (vertices'Last-vertices'First)+1 = (intersecting'Last-intersecting'First)+1);

      -- Sanity Check
      pragma Assert(edges'Length = polygon.vertices'Length);

      -- Necessary Assert & Sanity Check
      pragma Assert(edges'Last <= result_vert'Last);

      -- Sanity Check
      pragma Assert(edges'Length + edges'Length * vertices'Length = result_vert'length);

      -- Sanity Check
      --(if the prover doesn't know this, it can't determine all polygon points will be in the result)
      pragma Assert(for all p_ind in polygon.vertices'Range =>
                      (for some e_ind in edges'Range =>
                         edges(e_ind).p1 = polygon.vertices(p_ind)));

      for edge_ind in edges'Range loop

         result_vert_ghost := result_vert;

         intersect_count := 0;
         for vert_ind in unique_vert'Range loop
            pragma Loop_Invariant(intersect_count <= intersecting'Last-1 and intersect_count >= intersecting'First-1);
            pragma Loop_Invariant((if intersect_count >0 then
                                    (for some v_ind in unique_vert'Range =>
                                       intersecting(intersect_count) = unique_vert(v_ind))));

            -- All elements in intersecting so far are unique
            pragma Loop_Invariant(for all i_ind1 in intersecting'First .. intersect_count-1 =>
                                    (for all i_ind2 in intersecting'First+1 .. intersect_count =>
                                       intersecting(i_ind1) /= intersecting(i_ind2)));

            -- All elements of intersecting so far do not equal a polygon vertex
            pragma Loop_Invariant(for all i_ind in intersecting'First .. intersect_count =>
                                    (for all p_ind in polygon.vertices'Range =>
                                       (intersecting(i_ind) /= polygon.vertices(p_ind))));

            -- All elements of intersecting so far do not equal the current edge p1
            -- Note: this should be redundant with the above invariants but can't prove after the loop
            pragma Loop_Invariant(for all i_ind in intersecting'First.. intersect_count =>
                                    intersecting(i_ind) /= edges(edge_ind).p1);

            -- All elements in intersecting so far are on the current line segment
            pragma Loop_Invariant(for all i_ind in intersecting'First.. intersect_count =>
                                    is_point_on_segment(intersecting(i_ind),edges(edge_ind)));

            -- Note: necessary invariant, the prover loses track of result_vert because of this loop
            pragma Loop_Invariant(result_vert = result_vert'Loop_Entry);

            --Note: can't prove this invariant, likely due to mixed quantification
            --Based on the above invariant proving, I believe this invariant must hold
            --              pragma Loop_Invariant((for all int_ind in intersecting'First .. intersect_count =>
            --                                       (for some v_ind in unique_vert'Range =>
            --                                          intersecting(int_ind) = unique_vert(v_ind))));

            --Note: no point is considered intersecting if it is equal to the end points of the edge
            --Note: unique_vert should contain no internal redundancies
            --TODO: checking both p1 and p2 is overkill, consider using only P1 once the example is fully proving
            if (edges(edge_ind).p1 /= unique_vert(vert_ind) and
                  edges(edge_ind).p2 /= unique_vert(vert_ind) and
                  is_point_on_segment(unique_vert(vert_ind),edges(edge_ind))) then
               intersect_count := intersect_count +1;
               intersecting(intersect_count) := unique_vert(vert_ind);

               pragma Assert((for some v_ind in unique_vert'Range =>
                                intersecting(intersect_count) = unique_vert(v_ind)));
            end if;

         end loop;

         --           -- Note: see comments above about invariants. I believe this assume
         --           -- is true, but cannot be proven in the above invariant due to mixed quantification
         --           pragma Assume((for all int_ind in intersecting'First .. intersect_count =>
         --                            (for some v_ind in unique_vert'Range =>
         --                               intersecting(int_ind) = unique_vert(v_ind))));
         --           -- Note: unable to prove the assertion of the assume
         --           pragma Assert((for all int_ind in intersecting'First .. intersect_count =>
         --                            (for some v_ind in unique_vert'Range =>
         --                               intersecting(int_ind) = unique_vert(v_ind))));

         -- Sanity Check
         pragma Assert(result_vert_ghost = result_vert);

         -- Sanity Check
         pragma Assert(intersect_count <= vertices'Length);

         -- Sanity Check
         pragma Assert(intersect_count <= intersecting'Last);


         --ISSUE Description: the prover can't keep track that the index plus the intersection count is <= length of result_vert.
         --Further investigation showed the prover does know the index (for a simplified version of this program) is less than or equal
         --to edges'Length and intersect_count is less than or equal to vertices'Length. Substituting these values
         --into an assert, we are unable to show that edges'Length + vertices'Length is less than or equal to the result_vert length
         --which is based on these values; hence we arrive at the inability to show x + y <= x + y*x;
         --Current Direction: rely on a lemma and use PVS/Coq to prove the property
         Lemma_GTE_Prop1(edges'Length,vertices'Length);

         -- Extra May (likely not necessary)
         Lemma_GTE_Prop1(edges'Last,vertices'Last);

         -- Sanity Check (Lemma test)
         pragma Assert(edges'Length + vertices'Length <= edges'Length + (edges'Length * vertices'Length));

         -- Sanity Check
         pragma Assert(edge_ind <= edges'Length and intersect_count <= vertices'Length);

         -- Sanity Check
         pragma Assert(edge_ind <= edges'Last and intersect_count <= vertices'Last);

         -- Sanity Check
         pragma Assert(result_vert'Length = edges'Length + (edges'Length * vertices'Length));


         --Note: this commented out "original" invariant does not prove, but will prove if separated out
         --into three invariants.
         --           pragma Loop_Invariant(index <= (edge_ind-edges'First + 1) + intersect_count and
         --                                   index >= result_vert'First and
         --                                     (edge_ind-edges'First + 1) + intersect_count <= result_vert'Last);

         --Original working (used for illustration with the above commented out invariant, the invariant is deprecated)
         --           pragma Loop_Invariant(index <= (edge_ind-edges'First + 1) + intersect_count);
         --           pragma Loop_Invariant(index >= result_vert'First);
         --           pragma Loop_Invariant((edge_ind-edges'First + 1) + intersect_count <= result_vert'Last);


         Lemma_GTE_Prop2((edge_ind-edges'First + 1), vertices'Length,edges'Length,vertices'Length);

         --Note: The index at this point plus the intersect_count is <= the composite of all edges so far
         --assessed (recall we are inserting to result_vert the first vertex from each edge), plus
         --the hypothetical maximum number of intersecting vertices (all vertices) that will be
         --inserted into result_vert this iteration
         --This hypothetical index max is also less <= the result_vert max index (result_vert'Last)
         pragma Loop_Invariant(index + intersect_count <= (edge_ind-edges'First + 1) + vertices'Length*(edge_ind-edges'First + 1));
         pragma Loop_Invariant(index >= result_vert'First);
         pragma Loop_Invariant((edge_ind-edges'First + 1) + vertices'Length*(edge_ind-edges'First + 1) <= result_vert'Last);
         pragma Loop_Invariant(index >= (edge_ind-edges'First + 1));

         -- Note: necessary if using intersect_count to index the intersecting array
         pragma Loop_Invariant(intersect_count <= intersecting'Last);

         pragma Loop_Invariant(for all i_ind in intersecting'First.. intersect_count =>
                                 intersecting(i_ind) /= edges(edge_ind).p1);

         -- Note: recap of (hoisting) nested loop invariant
         pragma Loop_Invariant(for all i_ind1 in intersecting'First .. intersect_count-1 =>
                                    (for all i_ind2 in intersecting'First+1 .. intersect_count =>
                                       intersecting(i_ind1) /= intersecting(i_ind2)));

         -- Note: recap of (hoisting) nested loop invariant
         pragma Loop_Invariant(for all i_ind in intersecting'First.. intersect_count =>
                                 intersecting(i_ind) /= edges(edge_ind).p1);

         -- Note: all points in intersecting are on the edge
         pragma Loop_Invariant(for all i_ind in intersecting'First.. intersect_count =>
                                 is_point_on_segment(intersecting(i_ind),edges(edge_ind)));

         --TODO: invariant that says result is p1 append to intersecting

--           --The result vert contains the previous intersect set
--           pragma Loop_Invariant(for all e_ind in edges'First ..edge_ind-1 =>
--                           (for all v_ind in unique_vert'Range =>
--                              (if is_point_on_segment(unique_vert(v_ind), edges(e_ind)) then
--                                   (for some r_ind in result_vert'First .. index -1 =>
--                                        result_vert(r_ind) = unique_vert(v_ind)))));

--           -- result_vert so far contains only elements from unique_vert or
--           -- a p1 from an edge seen so far.
--           pragma Loop_Invariant(for all r_ind in result_vert'First .. index -1 =>
--                                   (for some v_ind in unique_vert'Range =>
--                                      (for some e_ind in edges'First ..edge_ind-1 =>
--                                           (result_vert(r_ind) = unique_vert(v_ind) or
--                                                  result_vert(r_ind) = edges(e_ind).p1))));
--
--
--           pragma Loop_Invariant(for all e_ind in edges'First .. edge_ind-1 =>
--                                   (for some r_ind in result_vert'First .. index-1 =>
--                                      result_vert(r_ind) = edges(e_ind).p1));

         -- Sanity Check
         pragma Assert(index + intersect_count <= result_vert'Last);

         result_vert(index) := edges(edge_ind).p1;

--           --Example for Yannick: note the first invariant proves for the given iteration and all iterations
--           --I would therefore conclude that for all iterations (the last invariant below) the same expression is true
--           --but the last invariant does not prove. The prover cannot make the inductive step here.
--           --Is this a mixed quantifier problem.
--           pragma Loop_Invariant( (for some r_ind in result_vert'First .. index =>
--                                      result_vert(r_ind) = edges(edge_ind).p1));
--
--           pragma Loop_Invariant(index + intersect_count <= (edge_ind-edges'First + 1) + vertices'Length*(edge_ind-edges'First + 1));
--           pragma Loop_Invariant(index >= result_vert'First);
--           pragma Loop_Invariant((edge_ind-edges'First + 1) + vertices'Length*(edge_ind-edges'First + 1) <= result_vert'Last);
--           pragma Loop_Invariant(index >= (edge_ind-edges'First + 1));
--           pragma Loop_Invariant(for all e_ind in edges'First .. edge_ind =>
--                                   (for some r_ind in result_vert'First .. index =>
--                                      result_vert(r_ind) = edges(e_ind).p1));


         index := index+1;

         -- TODO: sort intersecting array by dist to p1 from the current edge

         index_ghost := index;
         result_vert(index .. index+(intersect_count-1)) :=
           intersecting(intersecting'First .. intersecting'First+(intersect_count-1));

         -- Sanity Check (Example for Yannick: This sanity check fails)
         pragma Assert(result_vert(index .. index+(intersect_count-1)) =
                         intersecting(intersecting'First .. intersecting'First+(intersect_count-1)));

         -- TODO: try a for all assert of the slice

         index := index + intersect_count;

         -- Sanity Check
         pragma Assert(intersect_count + index_ghost = index);

         -- Sanity Check
         pragma Assert(result_vert(index-intersect_count-1) = edges(edge_ind).p1);

--           -- Sanity Check
--           pragma Assert(result_vert(index-intersect_count .. index-1) = intersecting(intersecting'First .. intersecting'First+(intersect_count-1)));

      end loop;


--        pragma Assert(for all e_ind in edges'Range =>
--                        (for all v_ind in unique_vert'Range =>
--                           (if is_point_on_segment(unique_vert(v_ind), edges(e_ind)) then
--                                (for some r_ind in result_vert'First .. index -1 =>
--                                     result_vert(r_ind) = unique_vert(v_ind)))));

      -- Sanity Check
      pragma Assert(index >= polygon.vertices'Length);

--        -- Sanity Check
--        pragma Assert(for all p_ind in polygon.vertices'Range =>
--                        (for some r_ind in result_vert'First .. index-1 =>
--                           result_vert(r_ind) = polygon.vertices(p_ind)));

      --If the total number of intersections is 0, then
      --the generated list of polygon vertices will contain new additional
      --points compared to the original polygon.
      --In this case, simply return the original polygon.
      --TODO: additional asserts and invariants should be added to verify
      --this intuitive logic
      if result_vert'Length = polygon.vertices'Length then
         return polygon;
         --Else, return a new polygon where the number of vertices is equal to
         --index-1 (since the index is incremented at the end of the above loop)
         --and the vertices equal to the corresponding subset of result_vert's
         --vertices
      else
         return polygon_2d'(vertex_count => index-1,
                            vertices => result_vert(1 .. index-1));
      end if;

   end inject_intersecting_vertices_into_polygon;



end vertex_injection;
