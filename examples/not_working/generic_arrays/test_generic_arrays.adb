-- -----------------------------------------------------------------------------
-- test_generic_arrays.adb      Dependable Computing
-- -----------------------------------------------------------------------------

-- Since SPARK will not prove anything about a generic until it is instantiated,
-- this simple package instantiates each generic function in the arrays package
-- so that proofs can be run.

package body test_generic_arrays with SPARK_Mode is
   -- Test the array map generic function using the mult_neg_one function.
   function test_map(arr: integer_array) return integer_array is
      function map_use is new map (to_map => mult_neg_one);
   begin
      return map_use(arr);
   end test_map;

   -- Test the array filter generic function using the even predicate.
   function test_filter(arr: integer_array) return integer_array is
      function filter_use is new filter (to_filter => even);
   begin
      return filter_use(arr);
   end test_filter;

   function test_unique(arr: integer_array) return integer_array is begin
      pragma Assert(arr'First > 0);
      return make_unique(arr);
   end test_unique;
end test_generic_arrays;
