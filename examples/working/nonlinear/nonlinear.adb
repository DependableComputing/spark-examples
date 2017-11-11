-- -----------------------------------------------------------------------------
-- nonlinear.ads                Dependable Computing
-- -----------------------------------------------------------------------------

-- Tests/examples related to nonlinear arithmetic in assertions.

with test_lemmas;

package body nonlinear with SPARK_Mode is
   -- Test proof of a relatively simple nonlinear inequality for two variables.
   function variable_mult(x: Positive;
                          y: Natural) return Boolean
   is begin
      -- This lemma provides the assertion below in its postcondition.
      --test_lemmas.Lemma_GTE_Prop1(x,y);

      -- cvc4 and z3 can prove this directly. alt-ergo cannot, and requires the
      -- lemma above to prove this.
      pragma Assert(x + y <= x + y * x);

      return x > y;
   end variable_mult;

   -- Test proof of a more complex nonlinear inequality for four variables.
   function four_variable_mult(x: Positive;
                               y: Natural;
                               a: Positive;
                               b: Natural) return Boolean
   is begin
      -- cvc4 and z3 can prove this directly.
      pragma Assert(x + y * x <= a + b * a);

      return x > y;
   end four_variable_mult;

end nonlinear;
