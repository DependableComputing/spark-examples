
with vectors_2d;
with segments_2d;
with polygons_2d;
with lemmas;

package vertex_injection with SPARK_Mode is
   use vectors_2d;
   use segments_2d;
   use polygons_2d;
   use lemmas;


   --     -- Predicate to test if an element is in an array.
   --     function in_array(element: point_2d;
   --                       arr: polygon_2d_vertices) return Boolean
   --     is
   --       (for some i in arr'Range =>
   --           arr(i) = element);
   --
   --     -- Predicate to test if an element is in an array in the specified range.
   --     function in_array(element: point_2d;
   --                       arr: polygon_2d_vertices;
   --                       first: Positive;
   --                       last: Positive) return Boolean
   --     is
   --       (for some i in first .. last =>
   --           arr(i) = element)
   --     with
   --     Pre => first in arr'Range and last in arr'Range;
   --
   --     -- Predicate to test if element1 appears after element2 in an array.
   --     function is_after(element1: point_2d;
   --                       element2: point_2d;
   --                       arr: polygon_2d_vertices) return Boolean
   --     is
   --       (for some i in arr'Range =>
   --          (for some j in arr'Range =>
   --                arr(i) = element1 and
   --               arr(j) = element2 and
   --               i > j));
   --
   --     -- Predicate to test if an array has only unique elements.
   --     function is_unique(arr: polygon_2d_vertices) return Boolean is
   --       (for all i in arr'Range =>
   --          (for all j in arr'Range =>
   --               (if arr(i) = arr(j) then
   --                       i = j)));
   --
   --     -- Predicate to test if an array has only unique elements in the specified
   --     -- range.
   --     --
   --     -- Use this in a loop invariant in which an array `result` with unique
   --     -- elements is being built up by setting:
   --     --
   --     --   first => result'First
   --     --   last => current_index_into_result
   --     function is_unique(arr: polygon_2d_vertices;
   --                        first: Positive;
   --                        last: Positive) return Boolean
   --     is
   --       (for all i in first .. last =>
   --          (for all j in first .. last =>
   --               (if arr(i) = arr(j) then
   --                       i = j)))
   --     with
   --     Pre => first in arr'Range and last in arr'Range;
   --
   --
   --     -- An array1 maps to an array2 if every element in array1 is in array2.
   --     --
   --     -- I need a better name for this.
   --     function maps_to(array1: polygon_2d_vertices;
   --                      array2: polygon_2d_vertices) return Boolean
   --     is
   --       (for all i in array1'Range =>
   --           in_array(array1(i), array2));
   --
   --     -- Predicate to test if array1 maps to array2 over the specified range
   --     -- of array1 (but the complete range of array2).
   --     --
   --     -- Use this in a loop invariant to say that an array1 being assembled from
   --     -- contains only elements drawn from array2 like this:
   --     --
   --     -- array1_first => array1'First
   --     -- array1_last => current_index_of_array1
   --     function maps_to(array1: polygon_2d_vertices;
   --                      array2: polygon_2d_vertices;
   --                      array1_first: Positive;
   --                      array1_last: Positive) return Boolean
   --     is
   --       (for all i in array1_first .. array1_last =>
   --           in_array(array1(i), array2))
   --     with
   --     Pre => array1_first in array1'Range and array1_last in array1'Range;
   --
   --     -- Predicate to test if the specified range of array1 maps to the
   --     -- specified range of array2.
   --     --
   --     -- Use this in a loop invariant to say that every element of some array2
   --     -- that has been examined so far has been placed into some array1:
   --     --
   --     -- array1_first => array1'First
   --     -- array1_last => current_index_of_array1
   --     --
   --     -- array2_first => array2'First
   --     -- array2_last => current_index_of_array2
   --     function maps_to(array1: polygon_2d_vertices;
   --                      array2: polygon_2d_vertices;
   --                      array1_first: Positive;
   --                      array1_last: Positive;
   --                      array2_first: Positive;
   --                      array2_last: Positive) return Boolean
   --     is
   --       (for all i in array1_first .. array1_last =>
   --           in_array(array1(i), array2, array2_first, array2_last))
   --     with
   --     Pre => array1_first in array1'Range and array1_last in array1'Range and
   --       array2_first in array2'Range and array2_last in array2'Range;
   --
   --     -- Predicate to test if array1 preserves the order of elements of array2.
   --     --
   --     -- That is, for every pair of elements a,b in array1, if a appears after b
   --     -- in array1, then a should appear after b in array2.
   --     --
   --     -- Note that this implies that every element in array1 maps to an element in
   --     -- array2.
   --     function preserves_order(array1: polygon_2d_vertices;
   --                              array2: polygon_2d_vertices) return Boolean
   --     is
   --       (if array1'Length > 0 then
   --          (for all i in array1'First .. array1'Last-1 =>
   --               (for all j in i+1 .. array1'Last =>
   --                     is_after(array1(i), array1(j), array2))));
   --
   --     -- Predicate to test if the specified range of array1 perserves the order of
   --     -- elements of array2.
   --     --
   --     -- Use this in a loop invariant to say that as you build up array1, the order
   --     -- of elements of array2 is preserved:
   --     --
   --     -- array1_first => array1'First
   --     -- array1_last => current_index_of_array1
   --     function preserves_order(array1: polygon_2d_vertices;
   --                              array2: polygon_2d_vertices;
   --                              array1_first: Positive;
   --                              array1_last: Positive) return Boolean
   --     is
   --       (for all i in array1_first .. array1_last-1 =>
   --          (for all j in i+1 .. array1_last =>
   --                is_after(array1(i), array1(j), array2)))
   --     with
   --     Pre => array1_first in array1'Range and array1_last in array1'Range;
   --
   --     -- Make a copy of the input array that has only unique elements.
   --     function make_unique(arr: polygon_2d_vertices) return polygon_2d_vertices with
   --       Post => (
   --                -- Every element of result appears in input
   --                  maps_to(arr, make_unique'Result)
   --
   --                and
   --
   --                -- Every element of input appears in result
   --                  maps_to(make_unique'Result, arr)
   --
   --                and
   --
   --                -- Order of elements in input is preserved in result
   --                  preserves_order(make_unique'Result, arr)
   --
   --                and
   --
   --                -- Every element of the result is unique
   --                  is_unique(make_unique'Result)
   --                and
   --                --The result length is <= to the passed in set of vertices
   --                  make_unique'Result'Length <= arr'Length
   --                and
   --                --The result First is the same as the passed in first
   --                  make_unique'Result'First = arr'First
   --               );





   -- TODO: make this function generic and move to a general utility package
   -- TODO: consider applying injective, surjective, total and partial logic here
   -- i.e., make_unique is a total function that is non-injective surjective
   -- Make a copy of the input array that has only unique elements.
   function make_unique(arr: polygon_2d_vertices) return polygon_2d_vertices with
   --Pre => arr'Last < Positive'Last,
     Post => (
              (for all i in make_unique'Result'First .. make_unique'Result'Last-1 =>
                   (for all j in i+1 .. make_unique'Result'Last =>
                      make_unique'Result(i) /= make_unique'Result(j)))

              and

                (for all i in make_unique'Result'Range =>
                     (for some j in arr'Range =>
                          make_unique'Result(i) = arr(j)))

              and

                (for all i in arr'Range =>
                     (for some j in make_unique'Result'Range =>
                          make_unique'Result(j) = arr(i)))
              and
              --The result length is <= to the passed in set of vertices
                make_unique'Result'Length <= arr'Length
              and
              --The result First is the same as the passed in first
                make_unique'Result'First = arr'First
             );

   function inject_intersecting_vertices_into_polygon(vertices: polygon_2d_vertices;
                                                      polygon: polygon_2d) return polygon_2d
     with
   --         Pre => polygon.vertices'Length + (polygon.vertices'Length * vertices'Length) < vertex_count_type'Last;
     Pre => polygon.vertices'Length + (polygon.vertices'Length * vertices'Length) < 100;
   --       Post =>
   --         --Every vertex of the passed in polygon is in the returned polygon
   --         (for all p_ind in polygon.vertices'Range =>
   --            (for some r_ind in inject_intersecting_vertices_into_polygon'Result.vertices'Range =>
   --                   inject_intersecting_vertices_into_polygon'Result.vertices(r_ind) = polygon.vertices(p_ind)));


end vertex_injection;
