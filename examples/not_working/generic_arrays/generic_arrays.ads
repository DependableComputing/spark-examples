-- -----------------------------------------------------------------------------
-- generic_arrays.ads                   Dependable Computing
-- -----------------------------------------------------------------------------

-- This package provides proving operations for generic arrays.
generic
   -- The element type for the array.
   type element_type is private;

   -- An array of element_type with an unspecified Positive range.
   type array_type is array (Positive range <>) of element_type;

package generic_arrays with SPARK_Mode is
   -- ----------------------------------------------------------------------- --
   -- Predicates

   -- Predicate to test if an element is in an array.
   function in_array(element: element_type;
                     arr: array_type) return Boolean
   is
      (for some i in arr'Range =>
          arr(i) = element);

   -- Predicate to test if an element is in an array in the specified range.
   function in_array(element: element_type;
                     arr: array_type;
                     first: Positive;
                     last: Positive) return Boolean
   is
      (for some i in first .. last =>
          arr(i) = element)
   with
     Pre => first in arr'Range and last in arr'Range;

   -- Predicate to test if element1 appears after element2 in an array.
   function is_after(element1: element_type;
                     element2: element_type;
                     arr: array_type) return Boolean
   is
     (for some i in arr'Range =>
         (for some j in arr'Range =>
             arr(i) = element1 and
             arr(j) = element2 and
             i > j));

   -- Predicate to test if an array has only unique elements.
   function is_unique(arr: array_type) return Boolean is
      (for all i in arr'Range =>
          (for all j in arr'Range =>
              (if arr(i) = arr(j) then
                  i = j)));

   -- Predicate to test if an array has only unique elements in the specified
   -- range.
   --
   -- Use this in a loop invariant in which an array `result` with unique
   -- elements is being built up by setting:
   --
   --   first => result'First
   --   last => current_index_into_result
   function is_unique(arr: array_type;
                      first: Positive;
                      last: Positive) return Boolean
   is
      (for all i in first .. last =>
          (for all j in first .. last =>
              (if arr(i) = arr(j) then
                  i = j)))
   with
     Pre => first in arr'Range and last in arr'Range;


   -- An array1 maps to an array2 if every element in array1 is in array2.
   --
   -- I need a better name for this.
   function maps_to(array1: array_type;
                    array2: array_type) return Boolean
   is
      (for all i in array1'Range =>
          in_array(array1(i), array2));

   -- Predicate to test if array1 maps to array2 over the specified range
   -- of array1 (but the complete range of array2).
   --
   -- Use this in a loop invariant to say that an array1 being assembled from
   -- contains only elements drawn from array2 like this:
   --
   -- array1_first => array1'First
   -- array1_last => current_index_of_array1
   function maps_to(array1: array_type;
                    array2: array_type;
                    array1_first: Positive;
                    array1_last: Positive) return Boolean
   is
      (for all i in array1_first .. array1_last =>
          in_array(array1(i), array2))
   with
     Pre => array1_first in array1'Range and array1_last in array1'Range;

   -- Predicate to test if the specified range of array1 maps to the
   -- specified range of array2.
   --
   -- Use this in a loop invariant to say that every element of some array2
   -- that has been examined so far has been placed into some array1:
   --
   -- array1_first => array1'First
   -- array1_last => current_index_of_array1
   --
   -- array2_first => array2'First
   -- array2_last => current_index_of_array2
   function maps_to(array1: array_type;
                    array2: array_type;
                    array1_first: Positive;
                    array1_last: Positive;
                    array2_first: Positive;
                    array2_last: Positive) return Boolean
   is
      (for all i in array1_first .. array1_last =>
          in_array(array1(i), array2, array2_first, array2_last))
   with
     Pre => array1_first in array1'Range and array1_last in array1'Range and
            array2_first in array2'Range and array2_last in array2'Range;

   -- Predicate to test if array1 preserves the order of elements of array2.
   --
   -- That is, for every pair of elements a,b in array1, if a appears after b
   -- in array1, then a should appear after b in array2.
   --
   -- Note that this implies that every element in array1 maps to an element in
   -- array2.
   function preserves_order(array1: array_type;
                            array2: array_type) return Boolean
   is
      (if array1'Length > 0 then
         (for all i in array1'First .. array1'Last-1 =>
             (for all j in i+1 .. array1'Last =>
                 is_after(array1(i), array1(j), array2))));

   -- Predicate to test if the specified range of array1 perserves the order of
   -- elements of array2.
   --
   -- Use this in a loop invariant to say that as you build up array1, the order
   -- of elements of array2 is preserved:
   --
   -- array1_first => array1'First
   -- array1_last => current_index_of_array1
   function preserves_order(array1: array_type;
                            array2: array_type;
                            array1_first: Positive;
                            array1_last: Positive) return Boolean
   is
      (for all i in array1_first .. array1_last-1 =>
          (for all j in i+1 .. array1_last =>
              is_after(array1(i), array1(j), array2)))
   with
     Pre => array1_first in array1'Range and array1_last in array1'Range;


   -- ----------------------------------------------------------------------- --
   -- Element operations

   -- Return an index of the given element in the array, or return zero if the
   -- element is not in the array.
   function index_of(element: element_type;
                     arr: array_type) return Natural
   with
     Post => (if in_array(element, arr) then
                 index_of'Result in arr'Range and arr(index_of'Result) = element
              else
                 index_of'Result = 0);

   -- Insert the given element into the given array at the given index.
   function insert_into_array(element: element_type;
                              index: Positive;
                              arr: array_type) return array_type
   with
     Pre => (arr'Last < Positive'Last - 1 and index in arr'Range),
     Post => (
       insert_into_array'Result'First = arr'First and
       insert_into_array'Result'Last = arr'Last + 1

       and

       (for all i in arr'First .. index-1 =>
          arr(i) = insert_into_array'Result(i))

       and

       insert_into_array'Result(index) = element

       and

       (for all i in index .. arr'Last =>
          arr(i) = insert_into_array'Result(i+1))
     );

   -- Delete from the given array at the given index.
   function delete_from_array(index: Positive;
                              arr: array_type) return array_type
   with
     Pre => (arr'Length > 0 and index in arr'Range),
     Post => (
       delete_from_array'Result'First = arr'First and
       delete_from_array'Result'Last = arr'Last - 1

       and

       (for all i in arr'First .. index-1 =>
          arr(i) = delete_from_array'Result(i))

       and

       (if index < arr'Last then
          (for all i in index+1 .. arr'Last =>
              arr(i) = delete_from_array'Result(i-1)))
     );

   -- ----------------------------------------------------------------------- --
   -- Array comprehensions

   -- Make a copy of the input array that has only unique elements.
   function make_unique(arr: array_type) return array_type with
     Post => (
       -- Every element of result appears in input
       maps_to(arr, make_unique'Result)

       and

       -- Every element of input appears in result
       maps_to(make_unique'Result, arr)

       and

       -- Order of elements in input is preserved in result
       preserves_order(make_unique'Result, arr)

       and

       -- Every element of the result is unique
       is_unique(make_unique'Result)
     );

   -- Filter function, genericized with a function to filter each element of the
   -- input array.
   generic
      with function to_filter(element: element_type) return Boolean;

   function filter(arr: array_type) return array_type with
     Post => (
       -- Every element of result comes from input
       maps_to(filter'Result, arr)

       and

       -- Order of elements in input is preserved in result
       preserves_order(filter'Result, arr)

       and

       -- Filters
       (for all i in filter'Result'Range =>
           to_filter(filter'Result(i)))
     );

   -- Map function, genericized with a function to map to each element of the
   -- input array.
   generic
      with function to_map(element: element_type) return element_type;

   function map(arr: array_type) return array_type with
     Post => (for all i in arr'Range =>
                map'Result(i) = to_map(arr(i)));


   -- Transform an array into another array, by way of a transformation function
   --
   -- This works like map, except the result type is of a different type than
   -- the input type.
   generic
      -- The element type for the result array.
      type result_element_type is private;

      -- A default element, so that we can initialize the result array. This makes
      -- it more generic-y. We can't use the tricks we used above for this. We
      -- could potentially call transform on the first element to fill the array,
      -- but transform might be expensive.
      Default_Result_Element: result_element_type;

      -- An array of element_type with an unspecified Natural range.
      type result_array_type is array (Positive range <>) of result_element_type;

   -- The function to map for transformation.
      with function to_transform(element: element_type) return result_element_type;

   function transform(arr: array_type) return result_array_type with
     Post => (for all i in arr'Range =>
                transform'Result(i) = to_transform(arr(i)));
end generic_arrays;
