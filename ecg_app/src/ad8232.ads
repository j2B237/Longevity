----------------------------------------------------------------------------
--
--  @File : ad8232.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Abstraction for ECG Sensor AD8232. This package
--           call ECG.ADC.Read_ADC subroutine to Get reading.
--           Reading are then consume by ECG.TIMERS client
--           later on.
--         
--                  NOTES ON HOW TO CONNECT ELECTRODES
--          Yours may be coloured differently. Which lead is which? 
--          try touching the leads together:
--           * Non touching: both LEDs lit
--           * LA touching RA: both LEDs lit
--           * LA touching RL: LO+ LED is off
--           * RA touching RL: RO- LED is off
--  @Date : 05/2025
--
---------------------------------------------------------------------------

with AVR;
with AVR.MCU;
with Interfaces;

package AD8232 is

   pragma Preelaborate;

   use AVR;

   procedure Init;
   function Get_Reading return Interfaces.Unsigned_16;

private 
   pragma Inline (Init);

   -- Leads OFF Detection -
   LO_MOINS       : Boolean renames MCU.PORTB_Bits (MCU.PORTB0_Bit);   
   -- Leads OFF Detection +        
   LO_PLUS        : Boolean renames MCU.PORTB_Bits (MCU.PORTB1_Bit);  
   --  Data Direction Registers         
   LO_MOINS_DDR   : Boolean renames MCU.DDRB_Bits (MCU.PORTB0_Bit);
   LO_PLUS_DDR    : Boolean renames MCU.DDRB_Bits (MCU.PORTB1_Bit);
   --  Data Port D Input
   LO_MOINS_PIN   : Boolean renames MCU.PINB_Bits (MCU.PIND0_Bit);
   LO_PLUS_PIN    : Boolean renames MCU.PINB_Bits (MCU.PIND1_Bit);

end AD8232;