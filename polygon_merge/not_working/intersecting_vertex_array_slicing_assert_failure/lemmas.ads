package Lemmas
 with SPARK_Mode,
      Pure,
      Ghost is

   procedure Lemma_GTE_Prop1(x: Integer; y: Integer) with
     Global => null,
     Pre => x >= 1 and y >= 1,
     Post => (x + y <= x + y * x);

   procedure Lemma_GTE_Prop2(x: Integer; y: Integer; a: Integer; b: Integer) with
     Global => null,
     Pre => x <= a and y <= b and x >=1 and y >=1,
     Post => (x + y*x <= a + b*a);


end Lemmas;
