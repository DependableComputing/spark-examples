-- -----------------------------------------------------------------------------
-- generic_array_comprehensions.ads Dependable Computing
-- -----------------------------------------------------------------------------

package body generic_array_comprehensions with SPARK_Mode is

   -- Map generic function to_apply to each element of the input array.
   function map(arr: array_type) return array_type is
      -- Note: the pragma Annotate trick to suppress the initialization warning
      -- doesn't appear to work in the instantiation of a generic.
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


   -- Filter the input array using generic function to_filter, returning only
   -- those elements that pass the filter.
   function filter(arr: array_type) return array_type is begin
      -- If the input array is degenerate, then we may as well simply return it
      -- without doing additional work. This saves us from trying to allocate a
      -- degenerate array.
      if arr'Length < 1 then
         return arr;
      else
         declare
            -- Our result may be as large as the input.
            result: array_type := arr;

            -- Index into the result array. We start the index at the integer
            -- before the first index in the input array. Since the indices of
            -- the input are naturals, result_index will be no less than -1.
            result_index: Integer := arr'First - 1;
         begin
            for index in arr'Range loop
               if to_filter(arr(index)) then
                  -- If the tested element matches the filter, we insert into
                  -- the result array.
                  result_index := result_index + 1;

                  result(result_index) := arr(index);
               end if;

               -- Both of these invariants are needed to ensure that all array
               -- accesses are safe.
               pragma Loop_Invariant(result_index >= arr'First - 1);
               pragma Loop_Invariant(result_index <= index);

               -- Summarize the progress of the loop. This invariant proves the
               -- postcondition.
               pragma Loop_Invariant((for all i in arr'First .. result_index =>
                                           to_filter(result(i))));
            end loop;

            -- Slice the result array so that we return an array precisely sized
            -- to hold only those elements that we actually inserted (those
            -- elements that pass the filter).
            --
            -- If no element was inserted, the result_index is arr'First - 1,
            -- which results in a degenerate/empty slice.
            return result(arr'First .. result_index);
         end;
      end if;
   end filter;

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

end generic_array_comprehensions;
