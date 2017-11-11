-- -----------------------------------------------------------------------------
-- point_2d_arrays.adb          Dependable Computing
-- -----------------------------------------------------------------------------

package body point_2d_arrays with SPARK_Mode is

   -- Return an index of the given element in the array, or return zero if the
   -- element is not in the array.
   function index_of(element: element_type;
                     arr: array_type) return Natural
   is
      found: Boolean := False with Ghost;
      index: Natural := 0;
   begin
      for i in arr'Range loop
         if arr(i) = element then
            index := i;
            found := True;
         end if;

         -- Found implies valid range for index - needed for later tests.
         pragma Loop_Invariant(if found then index in arr'Range else index = 0);

         -- Found implies that the vertex was found -- needed for the
         -- postcondition.
         pragma Loop_Invariant(if found then arr(index) = element);

         -- Found is true when we find a vertex -- needed to show that found is
         -- always eventually true, given our precondition.
         pragma Loop_Invariant(found = in_array(element, arr, arr'First, i));
      end loop;

      return index;
   end index_of;


   function insert_into_array(element: element_type;
                              index: Positive;
                              arr: array_type) return array_type
   is
      -- Make the initialization with `element` so we don't have to know some
      -- default value for the element type - makes this more generic.
      result: array_type(arr'First .. arr'Last + 1) := (others => element);
   begin
      result(result'First .. index-1) := arr(arr'First .. index-1);
      result(index) := element;
      result(index+1 .. result'Last) := arr(index .. arr'Last);

      return result;
   end insert_into_array;

   -- Delete from the given array at the given index.
   function delete_from_array(index: Positive;
                              arr: array_type) return array_type
   is
      -- Make the initialization with the first element of arr so we don't have
      -- to know some default value for the element type - makes this more
      -- generic.
      result: array_type(arr'First .. arr'Last - 1) :=
        (others => arr(arr'First));
   begin
      result(result'First .. index-1) := arr(arr'First .. index-1);

      -- We have to guard this, to avoid overflow on the index+1.
      if index < arr'Last then
         result(index .. result'Last) := arr(index+1 .. arr'Last);
      end if;

      return result;
   end delete_from_array;

   -- Make a copy of the input array that has only unique elements.
   function make_unique(arr: array_type) return array_type is
      -- Our result may be as large as the input.
      result: array_type := arr;

      -- Index into the result array. We start the index at the integer
      -- before the first index in the input array. Since the indices of
      -- the input are Positive, result_index will be no less than 0.
      result_index: Natural := arr'First - 1;
   begin
      -- Iterate over all of the elements of the input and assign them into the
      -- output if the output does not already contain them.
      for i in arr'Range loop
         -- Does the output not contain this element?
         if (for all j in result'First .. result_index =>
               result(j) /= arr(i))
         then
            -- Bump our index (which starts before the start of the array).
            result_index := result_index + 1;

            -- Necessary to prevent the range check below from failing.
            pragma Assert(result_index in arr'Range);

            -- Assign the element.
            result(result_index) := arr(i);
         end if;

         -- Necessary: we must establish the upper bound on the result index.
         pragma Loop_Invariant(result_index <= i);

         -- Prove order preservation so far.
         pragma Loop_Invariant(preserves_order(result, arr, result'First, result_index));

         -- Prove that every element in the result came from the input.
         pragma Loop_Invariant(maps_to(result, arr, result'First, result_index));

         -- Prove that every element of the input examined so far appears in
         -- the output.
         pragma Loop_Invariant(maps_to(arr, result, arr'First, i, result'First, result_index));

         -- Prove uniqueness so far.
         pragma Loop_Invariant(is_unique(result, result'First, result_index));
      end loop;

      -- Return the slice of the result that has been populated.
      return result(result'First .. result_index);
   end make_unique;


   -- Filter the input array using generic function to_filter, returning only
   -- those elements that pass the filter.
   function filter(arr: array_type) return array_type is
      -- Our result may be as large as the input.
      result: array_type := arr;

      -- Index into the result array. We start the index at the integer
      -- before the first index in the input array. Since the indices of
      -- the input are Positive, result_index will be no less than 0.
      result_index: Natural := arr'First - 1;
   begin
      for i in arr'Range loop
         if to_filter(arr(i)) then
            -- If the tested element matches the filter, we insert into
            -- the result array.
            result_index := result_index + 1;

            -- Necessary to prevent the range check below from failing.
            pragma Assert(result_index in arr'Range);

            result(result_index) := arr(i);
         end if;

         -- Necessary: we must establish the upper bound on the result index.
         pragma Loop_Invariant(result_index <= i);

         -- Prove order preservation so far.
         pragma Loop_Invariant(if result_index >= result'First then
                                  preserves_order(result, arr, result'First, result_index));

         -- Prove that every element in the result came from the input.
         pragma Loop_Invariant(if result_index >= result'First then
                                  maps_to(result, arr, result'First, result_index));

         -- Summarize the progress of the loop. This invariant proves the
         -- postcondition.
         pragma Loop_Invariant((for all i in result'First .. result_index =>
                                  to_filter(result(i))));
      end loop;

      -- Return the slice of the result that has been populated.
      return result(result'First .. result_index);
   end filter;

   -- Map generic function to_apply to each element of the input array.
   function map(arr: array_type) return array_type is
      result: array_type := arr;
   begin
      for index in arr'Range loop
         -- Apply the function to the current element and insert into the result
         -- array.
         result(index) := to_map(arr(index));

         -- Summarize the progress of the loop. This invariant proves the
         -- postcondition.
         pragma Loop_Invariant((for all i in arr'First .. index =>
                                  result(i) = to_map(arr(i))));
      end loop;

      return result;
   end map;

   -- Transform function, genericized with a function to transform each element
   -- of the input array to an element of the type of the result array.
   function transform(arr: array_type) return result_array_type is
      -- Note: the pragma Annotate trick to suppress the initialization warning
      -- doesn't appear to work in the instantiation of a generic.
      result: result_array_type(arr'Range) := (others => Default_Result_Element);
   begin
      for index in arr'Range loop
         -- Apply the function to the current element and insert into the result
         -- array.
         result(index) := to_transform(arr(index));

         -- Summarize the progress of the loop. This invariant proves the
         -- postcondition.
         pragma Loop_Invariant((for all i in arr'First .. index =>
                                  result(i) = to_transform(arr(i))));
      end loop;

      return result;
   end transform;
end point_2d_arrays;
