-- -----------------------------------------------------------------------------
-- generic_array_comprehensions.ads Dependable Computing
-- -----------------------------------------------------------------------------

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

package generic_array_comprehensions with SPARK_Mode is

   -- Map function, genericized with a function to map to each element of the
   -- input array.
   generic
      -- The element type for the array.
      type element_type is private;

      -- An array of element_type with an unspecified Natural range.
      type array_type is array (Natural range <>) of element_type;

      -- The function to map
      with function to_map(element: element_type) return element_type;

   function map(arr: array_type) return array_type with
     Post => (for all i in arr'Range =>
                map'Result(i) = to_map(arr(i)));


   -- Filter function, genericized with a function to filter each element of the
   -- input array.
   generic
      -- The element type for the array.
      type element_type is private;

      -- An array of element_type with an unspecified Natural range.
      type array_type is array (Natural range <>) of element_type;

      -- The function to use for filtering
      with function to_filter(element: element_type) return Boolean;

   function filter(arr: array_type) return array_type with
     Post => (for all i in filter'Result'Range =>
                to_filter(filter'Result(i)));


   -- Transform function, genericized with a function to transform each element
   -- of the input array to an element of the type of the result array.
   generic
      -- The element type for the array.
      type element_type is private;

      -- An array of element_type with an unspecified Natural range.
      type array_type is array (Natural range <>) of element_type;

      -- The element type for the result array.
      type result_element_type is private;

      -- A default element, so that we can initialize the result array.
      Default_Result_Element: result_element_type;

      -- An array of element_type with an unspecified Natural range.
      type result_array_type is array (Natural range <>) of result_element_type;

      -- The function to map
      with function to_transform(element: element_type) return result_element_type;

   function transform(arr: array_type) return result_array_type with
     Post => (for all i in arr'Range =>
                transform'Result(i) = to_transform(arr(i)));


end generic_array_comprehensions;
