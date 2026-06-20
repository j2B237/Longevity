with ECG.DSP.Generic_Moving_Average_Filter;
with ECG.DSP.High_Pass_Filter;
with ECG.DSP.Notch_Filter;

package body ECG.DSP is

   use Interfaces;

   ---------------------
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      --  Reset High-pass filter
      High_Pass_Filter.Reset;

      --  Reset Notch Filter
      Notch_Filter.Reset;
      
      --  Reset Moving Average Filter
      ECG.DSP.Generic_Moving_Average_Filter.Reset_filter;
      
   end Reset_Filters;

   ----------------------------
   --  Apply_Cascade_Filters  --
   ----------------------------

   function Apply_Cascade_Filters (Sample : Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16
   is
      Sample_32    : Interfaces.Integer_32 := Interfaces.Integer_32 (Sample);
      HP_Out       : Interfaces.Integer_32;
      Notch_Out    : Interfaces.Integer_32;
      LP_Out       : Interfaces.Integer_32;
      Final_Signal : Interfaces.Integer_32;
   begin
      -- 1. Le Passe-Haut supprime l'offset de l'ADC (Le signal passe autour de 0)
      HP_Out := High_Pass_Filter.Apply (Sample_32);

      -- 2. Le Notch élimine le 50 Hz sans couper les valeurs négatives
      Notch_Out := Notch_Filter.Apply (HP_Out);

      -- 3. Le Passe-bas (Moyenne glissante) nettoie les bruits de muscles
      LP_Out := Generic_Moving_Average_Filter.Apply (Notch_Out);

      -- 4. RECENTRAGE NUMÉRIQUE POUR L'APPLICATION (Offset DC de 512)
      --    On remet la ligne de base pile au milieu de l'écran de l'application
      Final_Signal := LP_Out + 512;

      -- 5. SATURATION STRICTE 10 BITS (Cohérence avec MAX = 1023)
      if Final_Signal < 0 then
         Final_Signal := 0;
      elsif Final_Signal > Interfaces.Integer_32 (MAX) then
         Final_Signal := Interfaces.Integer_32 (MAX);
      end if;

      return Interfaces.Unsigned_16 (Final_Signal);
   end Apply_Cascade_Filters;


end ECG.DSP;