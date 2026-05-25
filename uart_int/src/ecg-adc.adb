with AVR;
with AVR.MCU;

package body ECG.ADC is

   use AVR;

   -----------------
   --  Init_ADC0  --
   -----------------
   
   procedure Init_ADC0 is 
   begin
      -- 1. Configuration de l'ADC (Ref VCC +3.3V, Canal A0, Activation + Prescaler à 128 pour précision)
      MCU.ADMUX  := 2#01000000#; 
      MCU.ADCSRA := 2#10000111#;
   end Init_ADC0;

   --  Internal private subroutine to start ADC 
   --  on Channel 0

   -----------------
   --  Read_ADC0  --
   -----------------

   function Read_ADC0 return Interfaces.Unsigned_16 is
   begin
      -- Start Conversion by settin ADSC bit at 1 in ADCSRA.

      --  C-Like approach
      MCU.ADCSRA := MCU.ADCSRA or MCU.ADSC_Mask;
      -- Ada-Like approach
      -- MCU.ADCSRA_Bits (6) := AVR.High;

      -- Wait until the end of conversion (ADSC repasse a 0)
      while (MCU.ADCSRA and MCU.ADSC_Mask) /= 0 loop
         null;
      end loop;

      --  Return 10-bits value
      return MCU.ADC;
   end Read_ADC0;

end ECG.ADC;