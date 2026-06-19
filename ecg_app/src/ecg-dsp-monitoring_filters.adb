package body ECG.DSP.Monitoring_Filters is
   
   use Interfaces;
   use ECG.DSP;

   --  Private data type
   type Int32_Array_2 is array (1 .. 2) of Interfaces.Integer_32;
   type Int32_Array_3 is array (1 .. 3) of Interfaces.Integer_32;

   SCALE_FACTOR : constant := 16384;    -- 2^14 = 16384
   MAX : constant := (2 ** 16) - 1;

   -- State variables for Notch Filter
   --  Coef Notch 50Hz mis a l'echelle
   B_Notch : constant Int32_Array_3 := (16_095, -9_947, 16_095);
   A_Notch : constant Int32_Array_3 := (16_384, -9_947, 15_806);

   --  State variables for Low pass filter
   --  Coef Lowpass 40Hz mis a l'echelle
   B_Low : constant Int32_Array_3 := (2_381, 4_762, 2_381);
   A_Low : constant Int32_Array_3 := (16_384, -10_994, 4_134);


   --  State variable for High Pass filter 
   --  First order filter at 0.5 Hz
   B_High : constant Int32_Array_2 := (16_318, -16_318);
   A_High : constant Int32_Array_2 := (16_384, -16_253);

   --  Buffer historique (X => Entrees, Y => Sorties) en Integer_32
   --  pour gerer les valeurs negatives transitoires pendant le filtrage

   X_Notch, Y_Notch  : Int32_Array_3 := (0, 0, 0);
   X_Low,   Y_Low    : Int32_Array_3 := (0, 0, 0);
   X_High,  Y_High   : Int32_Array_2 := (0, 0);

   pragma Volatile (X_Notch);
   pragma Volatile (Y_Notch);
   pragma Volatile (X_Low);
   pragma Volatile (Y_Low);
   pragma Volatile (X_High);
   pragma Volatile (Y_High);

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

   function Cascade_Filters (Sample : Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16 is
      High_Accum,  High_Output  : Interfaces.Integer_32 := 0;
      Notch_Accum, Notch_Output : Interfaces.Integer_32 := 0;
      Low_Accum,   Low_Output   : Interfaces.Integer_32 := 0;
      Final_Output              : Interfaces.Unsigned_16:= 0;
   begin

      -----------------------------------------------------------------
      -- ÉTAGE 1 : Filtre Passe-Haut (0.5 Hz) - Suppression de la dérive
      -----------------------------------------------------------------

      X_High(2) := X_High(1);
      X_High(1) := Interfaces.Integer_32(Sample);
      Y_High(2) := Y_High(1);

      High_Accum := (B_High(1) * X_High(1)) + (B_High(2) * X_High(2)) - 
                    (A_High(2) * Y_High(2));
      High_Output := High_Accum / SCALE_FACTOR;
      Y_High(1)   := High_Output;
  

      -----------------------------------------------------------------
      -- ÉTAGE 2 : Filtre Notch (50 Hz) - Suppression du réseau électrique
      -----------------------------------------------------------------
      --  X_Notch(3) := X_Notch(2);
      --  X_Notch(2) := X_Notch(1);
      --  X_Notch(1) := High_Output;
      --  Y_Notch(3) := Y_Notch(2);
      --  Y_Notch(2) := Y_Notch(1);

      --  Notch_Accum := (B_Notch(1) * X_Notch(1)) + 
      --                 (B_Notch(2) * X_Notch(2)) + 
      --                 (B_Notch(3) * X_Notch(3)) - 
      --                 (A_Notch(2) * Y_Notch(2)) - 
      --                 (A_Notch(3) * Y_Notch(3));
      --  Notch_Output := Notch_Accum / SCALE_FACTOR;
      --  Y_Notch(1)   := Notch_Output;

      -----------------------------------------------------------------
      -- ÉTAGE 2 : Filtre Passe-Bas (40 Hz) - Atténuation des bruits de muscles
      -----------------------------------------------------------------
      X_Low(3) := X_Low(2);
      X_Low(2) := X_Low(1);
      X_Low(1) := High_Output;
      Y_Low(3) := Y_Low(2);
      Y_Low(2) := Y_Low(1);

      Low_Accum := (B_Low(1) * X_Low(1)) + 
                   (B_Low(2) * X_Low(2)) + 
                   (B_Low(3) * X_Low(3)) - 
                   (A_Low(2) * Y_Low(2)) - 
                   (A_Low(3) * Y_Low(3));

      Low_Output := Low_Accum / SCALE_FACTOR;
      Y_Low(1)   := Low_Output;

      -----------------------------------------------------------------
      -- SATURATION SÉCURISÉE (0 - 65535)
      -----------------------------------------------------------------

      if Low_Output < 0 then
         Low_Output := 0;
      elsif Low_Output > MAX then
         Low_Output := MAX;
      end if;

      return Interfaces.Unsigned_16(Low_Output);

   end Apply_High_Pass;

end ECG.DSP.Monitoring_Filters;