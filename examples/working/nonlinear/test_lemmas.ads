-- -----------------------------------------------------------------------------
-- test_lemmas.ads              Dependable Computing
-- -----------------------------------------------------------------------------

-- Lemmas to use in testing the use of lemmas.

package test_lemmas with SPARK_Mode,
                         Pure,
                         Ghost
is
   -- This is a generic (true) inequality that requires nonlinear arithmetic
   -- to prove. We checked this with Wolfram|Alpha:
   --
   -- https://www.wolframalpha.com/input/?i=simplify(x+%3E%3D+1+and+y+%3E%3D+0+implies+x+%2B+y+%3C%3D+x+%2B+y+*+x)
   procedure Lemma_GTE_Prop1(x: Integer;
                             y: Integer)
   with
     Global => null,
     Pre => (x >= 1) AND (y >= 0),
     Post => (x + y <= x + y * x);
end test_lemmas;
