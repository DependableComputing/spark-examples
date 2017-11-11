-- -----------------------------------------------------------------------------
-- test_generic_arrays.ads      Dependable Computing
-- -----------------------------------------------------------------------------

-- Since SPARK will not prove anything about a generic until it is instantiated,
-- this simple package instantiates each generic function in the arrays package
-- so that proofs can be run.

with generic_arrays;

package test_generic_arrays with SPARK_Mode is
   -- array of integers with an unspecified Natural range.
   type integer_array is array (Positive range <>) of Integer;

   -- Instantiate the generic for integer_array.
   package integer_arrays is new generic_arrays(element_type => Integer,
                                                array_type   => integer_array);

   -- Pull the components of the package into this namespace.
   use integer_arrays;

   -- Expression function to multiply an integer by negative one.
   --
   -- NOTE: we can use an if expression, here. This allows us to avoid overflow
   -- if i = Integer'First (because 2's complement).
   function mult_neg_one(i: Integer) return Integer is
      (if i = Integer'First then Integer'Last else i * (-1));

   -- Test the map function.
   function test_map(arr: integer_array) return integer_array with
     Pre => (for all i in arr'Range =>
               (i > Integer'First));


   -- Simple even predicate.
   function even(i: Integer) return Boolean is
      (i mod 2 = 0);

   -- Test the filter.
   function test_filter(arr: integer_array) return integer_array with
     Post => (for all i in test_filter'Result'Range =>
                test_filter'Result(i) mod 2 = 0);

   function test_unique(arr: integer_array) return integer_array with
     Post => is_unique(test_unique'Result);
end test_generic_arrays;
