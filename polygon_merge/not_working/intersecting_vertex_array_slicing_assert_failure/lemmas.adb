package body Lemmas with SPARK_mode is

   --Note: proofs within spark require the use of the compiler flag -gnato13
   --to use arbitrary precision to avoid overflow warnings.
   pragma Warnings
     (Off, "postcondition does not check the outcome of calling");

   procedure Lemma_GTE_Prop1(x: Integer; y: Integer)
   is
   begin
      pragma Assert(x + y <= x + y * x);
   end Lemma_GTE_Prop1;

   procedure Lemma_GTE_Prop2(x: Integer; y: Integer; a: Integer; b: Integer)
   is
   begin
      pragma Assert(x + y*x <= a + b*a);
   end Lemma_GTE_Prop2;


end Lemmas;
