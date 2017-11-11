package explore_generic_preconditions with SPARK_Mode is

   type integer_array is array (Natural range <>) of Integer;

   function my_sqrt(x: Integer) return Integer with
     Pre => (x >= 0),
     Post => (my_sqrt'Result >= 0);

   function sqrt_array(arr: integer_array) return integer_array with
     Pre => (for all i in arr'Range =>
               arr(i) >= 0);

   function sqrt_array_direct(arr: integer_array) return integer_array with
     Pre => (for all i in arr'Range =>
               arr(i) >= 0);

end explore_generic_preconditions;
