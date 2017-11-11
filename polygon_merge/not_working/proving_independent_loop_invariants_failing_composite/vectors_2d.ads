-- -----------------------------------------------------------------------------
-- vectors_2d.ads               Dependable Computing
-- -----------------------------------------------------------------------------

-- Declaration of types, constants, and common functions on 2D vectors.
package vectors_2d with SPARK_Mode is
   -- To control overfloat error, define a subrange of float over which points
   -- for our polygons can be defined. Note that this does not completely
   -- eliminate overflow error, though we don't understand why not.
   subtype vector_float_type is Float range -2.0**52 .. 2.0**52;

   -- SPARK doesn't allow us to use Float'Epsilon. So ... We'll define our
   -- own.
   --
   -- TODO: make this smaller?
   vector_float_eps: constant vector_float_type := 0.000_000_000_1;

   -- A 2D vector, represented by an x and a y coordinate.
   type vector_2d is record
      x: vector_float_type;
      y: vector_float_type;
   end record;

   -- An epsilon vector.
   eps_vector: constant vector_2d := vector_2d'(x => vector_float_eps,
                                                y => vector_float_eps);

   -- A zero vector.
   zero_vector: constant vector_2d := vector_2d'(x => 0.0,
                                                 y => 0.0);

   -- Define absolute value of a 2D vector.
   function abs_v2(Left: vector_2d) return vector_2d is
      (vector_2d'(x => abs(Left.x),
                  y => abs(Left.y)));

   -- Define element-wise addition for 2D vectors.
   function "+" (Left: vector_2d;
                 Right: vector_2d) return vector_2d is
      (vector_2d'(x => Left.x + Right.x,
                  y => Left.y + Right.y));

   -- Define element-wise subtraction for 2D vectors.
   function "-" (Left: vector_2d;
                 Right: vector_2d) return vector_2d is
      (vector_2d'(x => Left.x - Right.x,
                  y => Left.y - Right.y));

   -- Define dot product for 2D vectors.
   function "*" (Left: vector_2d;
                 Right: vector_2d) return Float is
      (Left.x * Right.x + Left.y * Right.y);

   -- Define the 2-dimensional cross product for 2D vectors. This is not the
   -- typical cross-product, because it does not result in a new vector.
   function cross(Left: vector_2d;
                  Right: vector_2d) return Float is
      (Left.x * Right.y - Left.y * Right.x);

   function ">" (Left: vector_2d;
                 Right: vector_2d) return Boolean is
      (Left.x > Right.x and Left.y > Right.y);

   function "<" (Left: vector_2d;
                 Right: vector_2d) return Boolean is
      (Left.x < Right.x and Left.y < Right.y);

   function ">=" (Left: vector_2d;
                 Right: vector_2d) return Boolean is
      (Left.x >= Right.x and Left.y >= Right.y);

   function "<=" (Left: vector_2d;
                 Right: vector_2d) return Boolean is
      (Left.x <= Right.x and Left.y <= Right.y);

   -- Return true if the given vectors are colinear.
   function are_vectors_colinear(v1: vector_2d;
                                 v2: vector_2d) return Boolean is
      (abs(cross(v1, v2)) <= vector_float_eps);

   -- Alias a 2D vector to be a 2D point.
   subtype point_2d is vector_2d;

   -- Build a vector pointing from p1 to p2.
   function vector_from_point_to_point(p1: point_2d;
                                       p2: point_2d) return vector_2d is
      (vector_2d'(x => p2.x - p1.x,
                  y => p2.y - p1.y));

   -- Return true if the given three points are on the same line.
   function are_points_colinear(p1: point_2d;
                                p2: point_2d;
                                p3: point_2d) return Boolean is
      (are_vectors_colinear(vector_from_point_to_point(p1,p2),
                            vector_from_point_to_point(p1,p3)));

   -- An epsilon point
   eps_point: constant point_2d := eps_vector;

   -- A zero point
   zero_point: constant point_2d := zero_vector;
end vectors_2d;
