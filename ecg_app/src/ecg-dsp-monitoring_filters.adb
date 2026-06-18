with ECG.DSP.Generic_Moving_Average_Filter;

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
   --  B_Low : constant Int32_Array_3 := (2_381, 4_762, 2_381);
   --  A_Low : constant Int32_Array_3 := (16_384, -10_994, 4_134);

   --  State variables for Low pass filter
   --  Coef Lowpass 60Hz mis a l'echelle
   B_Low : constant Int32_Array_3 := (4501, 9002, 4501);
   A_Low : constant Int32_Array_3 := (16384, -1206, 2827);

   --  State variable for High Pass filter 
   --  First order filter at 0.5 Hz
   B_High : constant Int32_Array_2 := (16_318, -16_318);
   --A_High : constant Int32_Array_2 := (16_384, -16_253);
   A_High : constant Int32_Array_2 := (16_384, -1_253);

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
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      X_Notch  := (0, 0, 0);
      Y_Notch  := (0, 0, 0);
      X_Low    := (0, 0, 0);
      Y_Low    := (0, 0, 0);
      X_High   := (0, 0);
      Y_High   := (0, 0);
   end Reset_Filters;

   -----------------------
   --  Cascade_Filters  --
   -----------------------
   function Cascade_Filters (Sample : Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16 is
      
      X0, Y0       : Interfaces.Integer_32;
      High_Accum   : Interfaces.Integer_32;
      Notch_Accum  : Interfaces.Integer_32;
      Low_Accum    : Interfaces.Integer_32;
      Final_Output : Interfaces.Integer_32;
   begin

      -----------------------------------------------------------------
      -- ÉTAGE 1 : Filtre Passe-Haut (0.5 Hz)
      -----------------------------------------------------------------
      X0 := Interfaces.Integer_32(Sample);
      
      -- Calcul basé sur l'état présent (X_High(1) est x[n-1])
      High_Accum := (B_High(1) * X0) + (B_High(2) * X_High(1)) - 
                    (A_High(2) * Y_High(1));
      
      Y0 := High_Accum / SCALE_FACTOR;

      -- Sauvegarde et décalage de l'historique pour le prochain échantillon
      X_High(1) := X0;
      Y_High(1) := Y0;


      -----------------------------------------------------------------
      -- ÉTAGE 2 : Filtre Notch (50 Hz)
      -----------------------------------------------------------------
      X0 := Y0; -- L'entrée du Notch est la sortie du Passe-Haut
      
      Notch_Accum := (B_Notch(1) * X0) + 
                     (B_Notch(2) * X_Notch(1)) + 
                     (B_Notch(3) * X_Notch(2)) - 
                     (A_Notch(2) * Y_Notch(1)) - 
                     (A_Notch(3) * Y_Notch(2));
      
      Y0 := Notch_Accum / SCALE_FACTOR;

      -- Décalage historique Notch (Du plus ancien au plus récent)
      X_Notch(2) := X_Notch(1);
      X_Notch(1) := X0;
      Y_Notch(2) := Y_Notch(1);
      Y_Notch(1) := Y0;


      -----------------------------------------------------------------
      -- ÉTAGE 3 : Filtre Passe-Bas (60 Hz)
      -----------------------------------------------------------------
      X0 := Y0;
      
      Low_Accum := (B_Low(1) * X0) + 
                   (B_Low(2) * X_Low(1)) + 
                   (B_Low(3) * X_Low(2)) - 
                   (A_Low(2) * Y_Low(1)) - 
                   (A_Low(3) * Y_Low(2));

      Y0 := Low_Accum / SCALE_FACTOR;

      -- Décalage historique Passe-Bas
      X_Low(2) := X_Low(1);
      X_Low(1) := X0;
      Y_Low(2) := Y_Low(1);
      Y_Low(1) := Y0;


      -----------------------------------------------------------------
      -- RECENTRAGE ET SATURATION SÉCURISÉE
      -----------------------------------------------------------------
      -- 1. On applique l'offset de 512 pour remettre le signal à mi-échelle
      
      Final_Output := Y0 + 512;

      -- 2. Saturation stricte pour empêcher les débordements de l'Unsigned_16
      if Final_Output < 0 then
         Final_Output := 0;
      elsif Final_Output > MAX then
         Final_Output := MAX;
      end if;

      return Interfaces.Unsigned_16(Final_Output);

   end Cascade_Filters;


end ECG.DSP.Monitoring_Filters;