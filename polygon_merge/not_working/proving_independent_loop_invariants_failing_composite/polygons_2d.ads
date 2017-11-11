-- -----------------------------------------------------------------------------
-- polygons_2d.ads              Dependable Computing
-- -----------------------------------------------------------------------------

with vectors_2d;
with segments_2d;

package polygons_2d with SPARK_Mode is
   use vectors_2d;
   use segments_2d;

   -- Represent the vertices of a polygon as an array of unspecified range
   -- of the Positives containing 2D points.
   type polygon_2d_vertices is array (Positive range <>) of point_2d;

   -- Return true if the given vertex is in the given vertex array.
   function in_vertices(vertex: point_2d;
                        vertices: polygon_2d_vertices) return Boolean with
     Pre => (vertices'Length >= 1),
     Post => (in_vertices'Result = (for some index in vertices'Range =>
                                        vertices(index) = vertex));

   -- Require that the number of vertices be above 2.
   subtype vertex_count_type is Positive range 3 .. 100;

   -- Represent a 2D polygon without holes by its vertices, which are assumed
   -- to be given in CCW order.
   type polygon_2d(vertex_count: vertex_count_type) is record
      -- Constrain the size of the array of vertices to be exactly as required
      -- based on the numer of vertices.
      vertices: polygon_2d_vertices(1 .. vertex_count);
   end record;

   type polygon_2d_edges is array (Natural range <>) of segment_2d;

   function edges_of_polygon(polygon: polygon_2d) return polygon_2d_edges;
--       with
--         Post =>
--           edges_of_polygon'Result'Length = polygon.vertex_count
--           and
--             edges_of_polygon'Result'Last = polygon.vertex_count
--             and
--               (for all e_ind in edges_of_polygon'Result'Range =>
--                  (if e_ind /= edges_of_polygon'Result'Last then
--                     (for some p_ind in polygon.vertices'First ..polygon.vertices'Last-1 =>
--                          (edges_of_polygon'Result(e_ind).p1 = polygon.vertices(p_ind) and
--                                 edges_of_polygon'Result(e_ind).p2 = polygon.vertices(p_ind+1)))
--                         else
--                     (edges_of_polygon'Result(e_ind).p1 = polygon.vertices(polygon.vertices'Last) and
--                          edges_of_polygon'Result(e_ind).p2 = polygon.vertices(polygon.vertices'First))))
--       and
--         -- All points in the passed in polygon exist as the p2 of some edge
--       (for all p_ind in polygon.vertices'Range =>
--          (for some e_ind in edges_of_polygon'Result'Range =>
--               polygon.vertices(p_ind) = edges_of_polygon'Result(e_ind).p2))
--       and
--         -- All points in the passed in polygon exist as the p1 of some edge
--       (for all p_ind in polygon.vertices'Range =>
--          (for some e_ind in edges_of_polygon'Result'Range =>
--               polygon.vertices(p_ind) = edges_of_polygon'Result(e_ind).p1));


   -- --------------------------------------------------------------------------
   -- Types for Intersection

   type edge_pair_type is array (Positive range 1 .. 2) of segment_2d;

   type edge_product_type is array (Natural range <>) of edge_pair_type;

   null_edge_pair: constant edge_pair_type := edge_pair_type'(null_segment_2d, null_segment_2d);

   -- --------------------------------------------------------------------------
   -- Helper Functions for Intersection

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
   with
     Pre => (edges1'Length < 255 and edges2'Length < 255),
     Post => (
       cartesian_product_of_edges'Result'Length = edges1'Length * edges2'Length

       and

       -- All pairs of edges are in the cartesian product
       (for all i in edges1'Range =>
          (for all j in edges2'Range =>
             (for some k in cartesian_product_of_edges'Result'Range =>
                cartesian_product_of_edges'Result(k) =
                    edge_pair_type'(edges1(i), edges2(j)))))
       and

       -- Only pairs of edges are in the cartesian product
       (for all k in cartesian_product_of_edges'Result'Range =>
          (for some i in edges1'Range =>
             (for some j in edges2'Range =>
                cartesian_product_of_edges'Result(k) =
                    edge_pair_type'(edges1(i), edges2(j))))));


   -- Predicate to test if an edge pair is in an array of edge pairs.
   function in_edge_pairs(edge_pair: edge_pair_type;
                          edge_pairs: edge_product_type) return Boolean
   with
       Ghost,
       Post => (in_edge_pairs'Result = (for some i in edge_pairs'Range =>
                                          edge_pairs(i) = edge_pair));

     -- An expression function that maps an edge pair to are_segments_intersecting
   function edge_filter(edge_pair: edge_pair_type) return Boolean is
     (are_segments_intersecting(edge_pair(1), edge_pair(2)));

   -- Filter an array of edge pairs to find those that are actually intersecting
   function find_intersecting_edge_pairs(arr: edge_product_type) return edge_product_type with
     Post => ((for all i in find_intersecting_edge_pairs'Result'Range =>
                  edge_filter(find_intersecting_edge_pairs'Result(i)))
              and
              (for all i in find_intersecting_edge_pairs'Result'Range =>
                  in_edge_pairs(find_intersecting_edge_pairs'Result(i),
                                arr)));

   -- An expression function that maps an edge pair to segment_intersection
   function intersection_of_edge_pair(edge_pair: edge_pair_type) return point_2d is
     (segment_intersection(edge_pair(1), edge_pair(2)))
   with
     Pre => (are_segments_intersecting(edge_pair(1), edge_pair(2)));


   -- Transform the array of interesting edges into an array of points of
   -- intersections
   function vertices_from_intersecting_edge_pairs(arr: edge_product_type) return polygon_2d_vertices with
     Pre => (for all i in arr'Range =>
               are_segments_intersecting(arr(i)(1), arr(i)(2))),
     Post => (
        vertices_from_intersecting_edge_pairs'Result'First = arr'First and
        vertices_from_intersecting_edge_pairs'Result'Last = arr'Last

        and

        -- All & only because ranges of arrays are the same and because we
        -- assert equality.
        (for all i in vertices_from_intersecting_edge_pairs'Result'Range =>
           vertices_from_intersecting_edge_pairs'Result(i) = intersection_of_edge_pair(arr(i))));



   -- Get the vertices of intersection of two polygons. Here, we state the
   -- postcondition as the properties we want to be true of
   function intersection(polygon1: polygon_2d;
                         polygon2: polygon_2d) return polygon_2d_vertices
   with
     Post => (

     -- All intersections are in the result array
     (for all edge1_index in edges_of_polygon(polygon1)'Range =>
        (for all edge2_index in edges_of_polygon(polygon2)'Range =>
           (if are_segments_intersecting(edges_of_polygon(polygon1)(edge1_index),
                                         edges_of_polygon(polygon2)(edge2_index))
            then
              in_vertices(segment_intersection(edges_of_polygon(polygon1)(edge1_index),
                                               edges_of_polygon(polygon2)(edge2_index)),
                          intersection'Result))))

     and

     -- Only intersections are in the result array
     (for all index in intersection'Result'Range =>
        (for some edge1_index in edges_of_polygon(polygon1)'Range =>
           (for some edge2_index in edges_of_polygon(polygon2)'Range =>
              (are_segments_intersecting(edges_of_polygon(polygon1)(edge1_index),
                                         edges_of_polygon(polygon2)(edge2_index))
               and
               intersection'Result(index) = segment_intersection(edges_of_polygon(polygon1)(edge1_index),
                                                                 edges_of_polygon(polygon2)(edge2_index))))))
     );

   -- Get the vertices of intersection of two polygons using an expression
   -- function based on composition of array comprehension functions. Proof
   -- that this does what we'd like would be deferred to an external system,
   -- like PVS.
   function intersection_expr(polygon1: polygon_2d;
                              polygon2: polygon_2d) return polygon_2d_vertices
   is
     (vertices_from_intersecting_edge_pairs(
                find_intersecting_edge_pairs(
                   cartesian_product_of_edges(edges_of_polygon(polygon1),
                                              edges_of_polygon(polygon2)))));

end polygons_2d;
