with ECG.DSP.Generic_Moving_Average_Filter;

package body ECG.DSP is

   use Interfaces;

   --------------------------------------------
   --  Variables d'état pour le filtre Notch --
   --------------------------------------------
   SCALE : constant := 16384;

   type Int32_Array is array (1 .. 3) of Interfaces.Integer_32;

   --  Echelle de mise en conformite entiere : 2^14 = 16384
   --  Coef Notch 50Hz mis a l'echelle
   B_Notch : constant Int32_Array := (16_095, -9_947, 16_095);
   A_Notch : constant Int32_Array := (16_384, -9_947, 15_806);

   -------------------------------------------------
   --  Variables d'état pour le filtre Passe-bas  --
   -------------------------------------------------

   --  Coef Lowpass 40Hz mis a l'echelle
   B_Low : constant Int32_Array := (2_381, 4_762, 2_381);
   A_Low : constant Int32_Array := (16_384, -10_994, 4_134);
   
   --  Buffer historique (X => Entrees, Y => Sorties) en Integer_32
   --  pour gerer les valeurs negatives transitoires pendant le filtrage

   X_Notch, Y_Notch  : Int32_Array := (0, 0, 0);
   X_Low, Y_Low      : Int32_Array := (0, 0, 0);

   pragma Volatile (X_Notch);
   pragma Volatile (Y_Notch);
   pragma Volatile (X_Low);
   pragma Volatile (Y_Low);

   ---------------------
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      --  Reset Notch and lowpass filter params
      
      X_Notch := (0, 0, 0);
      Y_Notch := (0, 0, 0);
      X_Low   := (0, 0, 0);
      Y_Low   := (0, 0, 0);

      --  Reset Moving Average Filter
      ECG.DSP.Generic_Moving_Average_Filter.Reset_filter;
      
   end Reset_Filters;

   --------------------
   --  Filter_Notch  --
   --------------------

   function Filter_Notch (Sample : Interfaces.Unsigned_16) 
      return Interfaces.Integer_32
   is
      Notch_Accum : Interfaces.Integer_32;
      Notch_Output : Interfaces.Integer_32;
   begin
     
     --  Decalage temporelle des anciennes valeurs
     X_Notch (3) := X_Notch (2);
     X_Notch (2) := X_Notch (1);
     X_Notch (1) := Interfaces.Integer_32 (Sample);

     Y_Notch (3)  := Y_Notch (2);
     Y_Notch (2)  := Y_Notch (1);

     --  Calcul du produit de convolution
     Notch_Accum := (B_Notch(1) * X_Notch(1)) + 
                  (B_Notch(2) * X_Notch(2)) + 
                  (B_Notch(3) * X_Notch(3)) - 
                  (A_Notch(2) * Y_Notch(2)) - 
                  (A_Notch(3) * Y_Notch(3));

      --  Bits shift vers la droite de 14 bits
      --  Notch_Output := Notch_Accum / SCALE;
      Notch_Output := Interfaces.Integer_32 (Notch_Accum / SCALE);
      Y_Notch (1)  := Notch_Output;

      --  Output of Notch becomes Input of Lowpass filter
      return Notch_Output;

   end Filter_Notch;

   ----------------------
   --  Filter_Lowpass  --
   ----------------------

   function Filter_Lowpass (Sample : Interfaces.Integer_32)
      return Interfaces.Unsigned_16 
   is
      Low_Accum : Interfaces.Integer_32;
      Low_Output : Interfaces.Unsigned_16;
   begin
     
      --   Low pass filter at 40Hz.
      X_Low (3) := X_Low (2);
      X_Low (2) := X_Low (1);
      X_Low (1) := Sample;

      Y_Low (3) := Y_Low (2);
      Y_Low (2) := Y_Low (1);

      -- Calcul du produit de convolution
      Low_Accum := (B_Low(1) * X_Low(1)) + 
                   (B_Low(2) * X_Low(2)) + 
                   (B_Low(3) * X_Low(3)) - 
                   (A_Low(2) * Y_Low(2)) - 
                   (A_Low(3) * Y_Low(3));

      Y_Low (1)  := Low_Accum / SCALE;
      Low_Output := Interfaces.Unsigned_16 (Y_Low (1));

      --  Protection against overflow
      if Low_Output < 0 then 
         Low_Output := 0;
      elsif Low_Output >= 65535 then
         Low_Output := 65535;
      end if;

      return Low_Output;

   end Filter_Lowpass;


end ECG.DSP;