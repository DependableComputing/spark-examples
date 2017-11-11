with generic_array_comprehensions;

-- This package is designed to illustrate the challenge posed by preconditions
-- on generic subprogram formal parameters: that they cannot be proven, in
-- general. We cannot edit the precondition on a generic subprogram when we
-- instantiate the generic and we cannot reference the precondition on the
-- formal parameter when we write the precondition for the generic, so there is
-- an apparent mismatch.
--
-- One might argue that we should not instantiate a generic subprogram with an
-- actual parameter that has a precondition that was not previously identified
-- for the generic subprogram's foraml parameter.

package body explore_generic_preconditions with SPARK_Mode is
   use generic_array_comprehensions;

   function my_sqrt(x: Integer) return Integer is begin
      return 5;
   end my_sqrt;

   -- FIXME: does not prove precondition, because of problem with preconditions
   -- on generic subprogram formal parameters.
   function sqrt_array(arr: integer_array) return integer_array is
      function sqrt_map is new map(element_type    => Integer,
                                   array_type      => integer_array,
                                   to_map          => my_sqrt);
   begin
      return sqrt_map(arr);
   end sqrt_array;

   -- This fully proves.
   function sqrt_array_direct(arr: integer_array) return integer_array is
      result: integer_array := arr;
   begin
      for index in arr'Range loop
         result(index) := my_sqrt(arr(index));
      end loop;

      return result;
   end sqrt_array_direct;

end explore_generic_preconditions;
