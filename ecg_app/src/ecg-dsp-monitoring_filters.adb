package body ECG.DSP.Monitoring_Filters is

   High_Pass_Filter_Internal_State : ECG_State with Volatile;
   
   ---------------------
   --  Reset  --
   ---------------------

   procedure Reset is
   begin
      High_Pass_Filter_Internal_State.X_Prev    := 0;
      High_Pass_Filter_Internal_State.Y_Prev    := 0;
      High_Pass_Filter_Internal_State.Alpha_Q14 := 0;

      -- Initialize with a default alpha ~= 0.9875 scaled to Q14
      Initialize_Filter (16181);
   end Reset;
   
   ---------------------------
   --   Initialize_Filter   --
   ---------------------------

   procedure Initialize_Filter (Alpha_Q14 : in Interfaces.Integer_32) is
   begin
      High_Pass_Filter_Internal_State.X_Prev    := 0;
      High_Pass_Filter_Internal_State.Y_Prev    := 0;
      High_Pass_Filter_Internal_State.Alpha_Q14 := Alpha_Q14;
   end Initialize_Filter;

   -----------------------
   --  Apply_High_Pass  --
   -----------------------

   function Apply_High_Pass (Input : in Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16
   is
      Acc             : Interfaces.Integer_32;
      Prod            : Interfaces.Integer_32;
      Unsigned_Output : Interfaces.Unsigned_16;
      Signed_Output   : Interfaces.Integer_16;
   begin
      -- 1. Calcul intermédiaire en 32-bit (Y_prev + Input - X_prev)
      Acc := Interfaces.Integer_32 (High_Pass_Filter_Internal_State.Y_Prev)
             + Interfaces.Integer_32 (Input)
             - Interfaces.Integer_32 (High_Pass_Filter_Internal_State.X_Prev);

      -- 2. Multiplication par le coefficient Alpha (Q14) en 32-bit
      --    Prod = (Acc * Alpha_Q14) / 2^14
      Prod := (Acc * High_Pass_Filter_Internal_State.Alpha_Q14) / 16384;

      -- 3. Saturation dans la plage Integer_16
      if Prod > Interfaces.Integer_32 (Interfaces.Integer_16'Last) then
         Signed_Output := Interfaces.Integer_16'Last;
      elsif Prod < Interfaces.Integer_32 (Interfaces.Integer_16'First) then
         Signed_Output := Interfaces.Integer_16'First;
      else
         Signed_Output := Interfaces.Integer_16 (Prod);
      end if;

      -- 4. Sauvegarde des états pour le prochain échantillon
      High_Pass_Filter_Internal_State.X_Prev := Input;
      High_Pass_Filter_Internal_State.Y_Prev := Signed_Output;

      -- 5. Conversion pour retour Unsigned_16 (clamp negative => 0)
      if Signed_Output < 0 then
         Unsigned_Output := Interfaces.Unsigned_16'First;
      else
         Unsigned_Output := Interfaces.Unsigned_16 (Signed_Output);
      end if;

      return Unsigned_Output;

   end Apply_High_Pass;

end ECG.DSP.Monitoring_Filters;