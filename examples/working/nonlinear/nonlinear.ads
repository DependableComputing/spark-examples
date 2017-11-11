-- -----------------------------------------------------------------------------
-- nonlinear.ads                Dependable Computing
-- -----------------------------------------------------------------------------

package nonlinear with SPARK_Mode is
   -- Test proof of a relatively simple nonlinear inequality for two variables.
   --
   -- Precondition here is selected for expediency and to avoid overflow errors
   -- in the assertion.
   function variable_mult(x: Positive;
                          y: Natural) return Boolean
   with Pre => (x < 255 and y < 255);

   -- Test proof of a more complex nonlinear inequality for four variables.
   --
   -- The part of the precondition here bounding a and b above by 255 is
   -- selected for expediency and to avoid overflow errors in the assertion.
   function four_variable_mult(x: Positive;
                               y: Natural;
                               a: Positive;
                               b: Natural) return Boolean
   with Pre => (x <= a and y <= b and a < 255 and b < 255);
end nonlinear;
