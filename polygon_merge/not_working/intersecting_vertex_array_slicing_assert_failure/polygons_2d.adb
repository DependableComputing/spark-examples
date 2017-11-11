-- -----------------------------------------------------------------------------
-- polygons_2d.adb              Dependable Computing
-- -----------------------------------------------------------------------------

package body polygons_2d with SPARK_Mode is

   -- Return true if the given vertex is in the given vertex array.
   function in_vertices(vertex: point_2d;
                        vertices: polygon_2d_vertices) return Boolean
   is
      found: Boolean := False;
   begin
      for vertex_index in vertices'Range loop
         found := found or else vertices(vertex_index) = vertex;

         -- Summarize the loop up to this point.
         pragma Loop_Invariant(found = (for some index in vertices'First .. vertex_index =>
                                          vertices(index) = vertex));
      end loop;

      return found;
   end in_vertices;



   function edges_of_polygon(polygon: polygon_2d) return polygon_2d_edges is
      edges: polygon_2d_edges(1 .. polygon.vertices'Length) := (others => null_segment_2d);
   begin
      -- Iterate over each vertex in the polygon.
      for vertex_index in polygon.vertices'First .. polygon.vertices'Last loop

         if vertex_index = polygon.vertices'Last then
            -- Sanity Check
            pragma Assert((vertex_index-polygon.vertices'First)+1 = edges'Last);

            edges((vertex_index-polygon.vertices'First)+1) :=
              segment_2d'(p1 => polygon.vertices(vertex_index),
                          p2 => polygon.vertices(polygon.vertices'First));
         else
            edges((vertex_index-polygon.vertices'First)+1) :=
              segment_2d'(p1 => polygon.vertices(vertex_index),
                          p2 => polygon.vertices(vertex_index+1));
         end if;

--           -- Sanity Check
--           pragma Assert(for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--                           (edges(e_ind).p1 = polygon.vertices(vertex_index)));
--           -- Sanity Check
--           pragma Assert(if vertex_index = polygon.vertices'Last then
--                           (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--                                (edges(e_ind).p2 = polygon.vertices(polygon.vertices'First)))
--                         else
--                           (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--                                (edges(e_ind).p2 = polygon.vertices(vertex_index+1))));


--
--           -- CAN PROVE AS AN INVARIANT IF NO OTHER INVARIANTS ARE PRESENT
--           -- ASSUMING SINCE PRESUMABLY THIS HAS ALREADY BEEN PROVEN
--           pragma Assume(for all p_ind in polygon.vertices'First .. vertex_index =>
--                                    (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--                                         polygon.vertices(p_ind) = edges(e_ind).p1));
--
--           -- all vertices seen so far are a p1 of every edge so far created
--           -- (Example for Yannick: proves no problem without other invariants, fails with other invariants with timeout 120)
--           pragma Loop_Invariant(for all p_ind in polygon.vertices'First .. vertex_index =>
--                                    (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--                                         polygon.vertices(p_ind) = edges(e_ind).p1));
--
--           -- Cases for p2
--                    -- VARIANT 1: Can't prove
--  --           pragma Loop_Invariant(for all p_ind in polygon.vertices'First+1 .. vertex_index =>
--  --                                   (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--  --                                        polygon.vertices(p_ind) = edges(e_ind).p2));
--           -- VARIANT 2: Can't prove
--  --           pragma Loop_Invariant(for all p_ind in polygon.vertices'First .. vertex_index =>
--  --                                   (if p_ind = polygon.vertices'Last then
--  --                                      (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--  --                                           polygon.vertices(p_ind) = edges(e_ind).p2)
--  --                                    else
--  --                                       (for some e_ind in edges'First .. (vertex_index-polygon.vertices'First)+1 =>
--  --                                           polygon.vertices(p_ind+1) = edges(e_ind).p2)));
--
--
--           -- When the last vertex is seen, the last element of edges p1 is the current the current (last) and the p2 is the first
--           pragma Loop_Invariant(if vertex_index = polygon.vertices'Last then
--                                    edges(edges'Last).p1 = polygon.vertices(vertex_index) and
--                                   edges(edges'Last).p2 = polygon.vertices(polygon.vertices'First));
--
--           -- CAN PROVE AS AN INVARIANT IF THE ABOVE ASSUMED INVARIANT IS COMMENTED OUT
--           -- ASSUMING SINCE PRESUMABLY THIS HAS ALREADY BEEN PROVEN
--           pragma Assume(if vertex_index /= polygon.vertices'Last then
--                                   (for all e_ind in edges'First..(vertex_index-polygon.vertices'First)+1 =>
--                                        (for some p_ind in polygon.vertices'First .. vertex_index =>
--                                             (edges(e_ind).p1 = polygon.vertices(p_ind) and
--                                                    edges(e_ind).p2 = polygon.vertices(p_ind+1)))));
--
--           -- When the last vertex has not been seen, all edges so far added have p1 = i (some vertex seen so far) and p2 = i+1
--           pragma Loop_Invariant(if vertex_index /= polygon.vertices'Last then
--                                   (for all e_ind in edges'First..(vertex_index-polygon.vertices'First)+1 =>
--                                        (for some p_ind in polygon.vertices'First .. vertex_index =>
--                                             (edges(e_ind).p1 = polygon.vertices(p_ind) and
--                                                    edges(e_ind).p2 = polygon.vertices(p_ind+1)))));

         pragma Loop_Invariant((for all e_ind in edges'First..(vertex_index-polygon.vertices'First)+1 =>
                (if e_ind /= edges'Last then
                   (for some p_ind in polygon.vertices'First .. vertex_index =>
                        (edges(e_ind).p1 = polygon.vertices(p_ind) and
                               edges(e_ind).p2 = polygon.vertices(p_ind+1)))
                 else
                     (edges(e_ind).p1 = polygon.vertices(polygon.vertices'Last) and
                     edges(e_ind).p2 = polygon.vertices(polygon.vertices'First)))));


      end loop;

      return edges;
   end edges_of_polygon;






--     -- Return an array of segments representing the edges of the polygon, in
--     -- the same order in which the vertices are specified. The first edge in the
--     -- array is the edge from the last vertext to the first vertex.
--     function edges_of_polygon(polygon: polygon_2d) return polygon_2d_edges is
--        -- The index of the previous vertex. Initially, we set this to be the last
--        -- vertex since, for a closed polygon, there is an edge from the last to
--        -- the first vertex.
--        prev_vertex_index: Integer := polygon.vertex_count;
--
--        -- The number of edges in a polygon is equal to the number of vertices of
--        -- the polygon.
--        edges: polygon_2d_edges(1 .. polygon.vertex_count) := (others => null_segment_2d);
--     begin
--        -- Iterate over each vertex in the polygon.
--        for vertex_index in 1 .. polygon.vertex_count loop
--           -- Build an edge from the previous vertex to the current vertex.
--           edges(vertex_index) :=
--             segment_2d'(p1 => polygon.vertices(prev_vertex_index),
--                         p2 => polygon.vertices(vertex_index));
--
--            -- This knowledge is essential for the prover to determine that all of
--           -- our array references are safe.
--           pragma Loop_Invariant(if vertex_index = 1 then
--                                    prev_vertex_index = polygon.vertex_count
--                                 else
--                                    prev_vertex_index = vertex_index-1
--                                );
--           pragma Loop_Invariant(for all edge_ind in 1..vertex_index =>
--              (for some vert_ind in 1..vertex_index =>
--               (if vert_ind  = 1 then
--                    edges(edge_ind).p1 = polygon.vertices(polygon.vertices'Last) and
--                    edges(edge_ind).p2 = polygon.vertices(vert_ind)
--                else
--                    edges(edge_ind).p1 = polygon.vertices(vert_ind-1 ) and
--                    edges(edge_ind).p2 = polygon.vertices(vert_ind))));
--
--           -- index of the previous vertex will be the index of the current vertex
--           prev_vertex_index := vertex_index;
--        end loop;
--
--        return edges;
--     end edges_of_polygon;


   -- --------------------------------------------------------------------------
   -- Helper Functions for Intersection

   -- Predicate to test if an edge pair is in an array of edge pairs.
   function in_edge_pairs(edge_pair: edge_pair_type;
                          edge_pairs: edge_product_type) return Boolean
   is
      found: Boolean := False;
   begin
      for index in edge_pairs'Range loop
         found := found or else edge_pairs(index) = edge_pair;

         -- Summarize the loop up to this point.
         pragma Loop_Invariant(found = (for some i in edge_pairs'First .. index =>
                                          edge_pairs(i) = edge_pair));
      end loop;

      return found;
   end in_edge_pairs;


   -- Generate the cartesian product of two edges contain polygon edges.
   --
   -- Note: previously, I have been unable to complete the proof for this
   -- function, so I am currently omitting the postcondition or the correctness-
   -- relevant properties.
   --
   -- TODO: complete proof of correctness for this function.
   --
   -- Note: the simplicity of the function may obviate any real need for the
   -- proof.
   --
   -- Note also that I've explored tighter preconditions, but had trouble with
   -- the nonlinear arithmetic failing on me.
   function cartesian_product_of_edges(edges1: polygon_2d_edges;
                                       edges2: polygon_2d_edges) return edge_product_type
   is
      result_length: constant Natural := edges1'Length * edges2'Length;

      result: edge_product_type(1 .. result_length) := (others => null_edge_pair);

      result_index: Natural := 0;
   begin
      for index1 in edges1'Range loop
         for index2 in edges2'Range loop
            result_index := result_index + 1;

            result(result_index) := edge_pair_type'(edges1(index1), edges2(index2));

            -- Precisely state how the result index changes.
            pragma Loop_Invariant(result_index = (index1 - edges1'First) * edges2'Length + (index2 - edges2'First) + 1);
         end loop;

         -- Precisely state how the result index changes.
         pragma Loop_Invariant(result_index = (index1 - edges1'First + 1) * edges2'Length);
      end loop;

      return result;
   end cartesian_product_of_edges;


   -- Filter an array of edge pairs to find those that are actually intersecting
   function find_intersecting_edge_pairs(arr: edge_product_type) return edge_product_type is begin
      -- If the input array is degenerate, then we may as well simply return it
      -- without doing additional work. This saves us from trying to allocate a
      -- degenerate array.
      if arr'Length < 1 then
         return arr;
      else
         declare
            -- Our result may be as large as the input.
            result: edge_product_type := arr;

            -- Index into the result array. We start the index at the integer
            -- before the first index in the input array. Since the indices of
            -- the input are naturals, result_index will be no less than -1.
            result_index: Integer := arr'First - 1;
         begin
            for index in arr'Range loop
               if edge_filter(arr(index)) then
                  -- If the tested element matches the filter, we insert into
                  -- the result array.
                  result_index := result_index + 1;

                  result(result_index) := arr(index);

                  pragma Assert(in_edge_pairs(result(result_index), arr));
               end if;

               -- Both of these invariants are needed to ensure that all array
               -- accesses are safe.
               pragma Loop_Invariant(result_index >= arr'First - 1);
               pragma Loop_Invariant(result_index <= index);

               -- Summarize the progress of the loop. This invariant is
               -- sufficient to prove the 1st part of the postcondition.
               pragma Loop_Invariant((for all i in arr'First .. result_index =>
                                        edge_filter(result(i))));

               -- Summarize the progress of the loop. This invariant is
               -- sufficient to prove the 2nd part of the postcondition.
               pragma Loop_Invariant((for all i in arr'First .. result_index =>
                                        in_edge_pairs(result(i), arr)));
            end loop;

            -- Slice the result array so that we return an array precisely sized
            -- to hold only those elements that we actually inserted (those
            -- elements that pass the filter).
            --
            -- If no element was inserted, the result_index is arr'First - 1,
            -- which results in a degenerate/empty slice.
            return result(arr'First .. result_index);
         end;
      end if;
   end find_intersecting_edge_pairs;


   -- Transform the arary of interesting edges into an array of points of
   -- intersections
   function vertices_from_intersecting_edge_pairs(arr: edge_product_type) return polygon_2d_vertices is
      result: polygon_2d_vertices(arr'Range) := (others => zero_point);
   begin
      for index in arr'Range loop
         -- Apply the function to the current element and insert into the result
         -- array.
         result(index) := intersection_of_edge_pair(arr(index));

         -- Summarize the progress of the loop. This invariant proves the
         -- postcondition.
         pragma Loop_Invariant((for all i in arr'First .. index =>
                                  result(i) = intersection_of_edge_pair(arr(i))));
      end loop;

      return result;
   end vertices_from_intersecting_edge_pairs;


   function intersection(polygon1: polygon_2d;
                         polygon2: polygon_2d) return polygon_2d_vertices
   is
      -- Compute the edges of both polygons, and store in temporaries, as we'll
      -- use them repeatedly.
      edges1: polygon_2d_edges := edges_of_polygon(polygon1);
      edges2: polygon_2d_edges := edges_of_polygon(polygon2);


      -- Compute the cartesian product of the two arrays of edges.
      edge_pairs: edge_product_type := cartesian_product_of_edges(edges1, edges2);

      -- FIXME: Introducing these assumptions does not enable its restatement as an
      -- assertion to prove. This suggests that no amount of using postconditions
      pragma Assume((for all e1 in edges1'Range =>
                       (for all e2 in edges2'Range =>
                          (for some i in edge_pairs'Range =>
                              edge_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))))));

      pragma Assume((for all i in edge_pairs'Range =>
                       (for some e1 in edges1'Range =>
                          (for some e2 in edges2'Range =>
                             edge_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))))));

      -- All edges in cartesian product:
      --
      -- Follows via equality rule from post condition of cartesian product
      --
      -- TODO: does not prove
      pragma Assert((for all e1 in edges1'Range =>
                       (for all e2 in edges2'Range =>
                          (for some i in edge_pairs'Range =>
                              edge_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))))));

      -- Only edges in cartesian product:
      --
      -- Follows via equality rule from post condition of cartesian product
      --
      -- TODO: does not prove
      pragma Assert((for all i in edge_pairs'Range =>
                       (for some e1 in edges1'Range =>
                          (for some e2 in edges2'Range =>
                             edge_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))))));


      -- Filter the product of edges so that we retain only those that are
      -- intersecting.
      intersecting_pairs: edge_product_type := find_intersecting_edge_pairs(edge_pairs);

      -- Only filtered edges in intersecting_pairs:
      --
      -- Follows via equality rule from postcondition of find_intersecting
      pragma Assert((for all i in intersecting_pairs'Range =>
                       edge_filter(intersecting_pairs(i))));

      -- Expansion of above:
      --
      -- Follows via equality rule from definition of edge filter
      pragma Assert((for all i in intersecting_pairs'Range =>
                       are_segments_intersecting(intersecting_pairs(i)(1),
                                                 intersecting_pairs(i)(2))));

      -- Only pairs from edge_pairs in intersecting_pairs:
      --
      -- Follows via equality rule from postcondition of find_intersecting
      pragma Assert((for all i in intersecting_pairs'Range =>
                       in_edge_pairs(intersecting_pairs(i), edge_pairs)));

      -- Expansion of above:
      --
      -- Follows via equality rule from definition of in_edge_pairs
      --
      -- TODO: does not prove
      pragma Assert((for all i in intersecting_pairs'Range =>
                       (for some j in edge_pairs'Range =>
                          intersecting_pairs(i) = edge_pairs(j))));

      -- Only edges in intersecting_pairs
      --
      -- Follows via equality rule (sort of?) from "only edges in cartesian
      -- product"
      --
      -- TODO: does not prove
      pragma Assert((for all i in intersecting_pairs'Range =>
                       (for some e1 in edges1'Range =>
                          (for some e2 in edges2'Range =>
                             intersecting_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))))));

      -- Only edges that are intersecting in intersecting_pairs
      --
      -- TODO: does not prove
      pragma Assert((for all i in intersecting_pairs'Range =>
                       (for some e1 in edges1'Range =>
                          (for some e2 in edges2'Range =>
                             (intersecting_pairs(i) = edge_pair_type'(edges1(e1), edges2(e2))
                              and
                              are_segments_intersecting(edges1(e1), edges2(e2)))))));


      -- Transform the array of intersecting pairs of edges into an array of
      -- the vertices of intersection.
      vertices_of_intersection: polygon_2d_vertices := vertices_from_intersecting_edge_pairs(intersecting_pairs);

      -- Only vertices of intersection are in the vertices_of_intersection
      --
      -- TODO: does not prove
      pragma Assert((for all i in vertices_of_intersection'Range =>
                       (for some e1 in edges_of_polygon(polygon1)'Range =>
                            (for some e2 in edges_of_polygon(polygon2)'Range =>
                               (are_segments_intersecting(edges_of_polygon(polygon1)(e1),
                                                          edges_of_polygon(polygon2)(e2))
                                and then
                                vertices_of_intersection(i) = segment_intersection(edges_of_polygon(polygon1)(e1),
                                                                                   edges_of_polygon(polygon2)(e2)))))));

   begin
      return vertices_of_intersection;
   end intersection;

end polygons_2d;
