package body ECG.DSP.High_Pass_Filter is
   
   -------------
   --  Reset  --
   -------------

   procedure Reset is
   begin
      High_Pass_Filter_Internal_State.X_Prev    := 0;
      High_Pass_Filter_Internal_State.Y_Prev    := 0;
      High_Pass_Filter_Internal_State.Alpha_Q14 := 0;

      -- Initialize with a default alpha ~= 0.9875 scaled to Q14
      Initialize (16181);
   end Reset;
   
   --------------------
   --   Initialize   --
   --------------------

   procedure Initialize (Alpha_Q14 : in Interfaces.Integer_32) is
   begin
      High_Pass_Filter_Internal_State.X_Prev    := 0;
      High_Pass_Filter_Internal_State.Y_Prev    := 0;
      High_Pass_Filter_Internal_State.Alpha_Q14 := Alpha_Q14;
   end Initialize;

   -------------
   --  Apply  --
   -------------

   function Apply (Input : in Interfaces.Integer_32)
      return Interfaces.Integer_32
   is
      Acc : Interfaces.Integer_32;
   begin
      -- 1. Calcul intermédiaire en 32-bit (Y_prev + Input - X_prev)
      Acc := High_Pass_Filter_Internal_State.Y_Prev
             + Input
             - High_Pass_Filter_Internal_State.X_Prev;

      -- 2. Multiplication par le coefficient Alpha (Q14) en 32-bit
      Acc := (Acc * High_Pass_Filter_Internal_State.Alpha_Q14) / 16384;

      -- 4. Sauvegarde des états pour le prochain échantillon
      High_Pass_Filter_Internal_State.X_Prev := Input;
      High_Pass_Filter_Internal_State.Y_Prev := Acc;

      return Acc;

   end Apply;

end ECG.DSP.High_Pass_Filter;