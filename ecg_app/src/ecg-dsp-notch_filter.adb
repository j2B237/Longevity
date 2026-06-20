package body ECG.DSP.Notch_Filter is

   -------------
   --  Reset  --
   -------------

   procedure Reset is
   begin
      Internal_Notch_Filter_State.X1 := 0;
      Internal_Notch_Filter_State.X2 := 0;
      Internal_Notch_Filter_State.Y1 := 0;
      Internal_Notch_Filter_State.Y2 := 0;
   end Reset;


   -------------
   --  Apply  --
   -------------

   function Apply (Sample : Interfaces.Integer_32)
      return Interfaces.Integer_32 
   is
      Acc : Interfaces.Integer_32;
   begin
      -- 1. Calcul de l'équation aux différences en 32 bits
      Acc :=  B0 * Sample
            + B1 * Internal_Notch_Filter_State.X1
            + B2 * Internal_Notch_Filter_State.X2
            - A1 * Internal_Notch_Filter_State.Y1
            - A2 * Internal_Notch_Filter_State.Y2;
      
      -- 2. Division par 2^14
      Acc := Acc / SCALE_FACTOR;

      -- 3. Mis a jours de la memoire des signaux (decalage temporel)
      Internal_Notch_Filter_State.X2 := Internal_Notch_Filter_State.X1;
      Internal_Notch_Filter_State.X1 := Sample;

      Internal_Notch_Filter_State.Y2 := Internal_Notch_Filter_State.Y1;
      Internal_Notch_Filter_State.Y1 := Acc;

      return Acc;

   end Apply;

end ECG.DSP.Notch_Filter;