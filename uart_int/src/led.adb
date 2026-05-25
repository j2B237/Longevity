with AVR;
with AVR.MCU;

package body LED is

   use AVR;

   --  Constant private entities
   HAS_LED  : constant Boolean := True;
   LED      : Boolean renames MCU.DDRB_Bits (0);
   LED_PORT : Boolean renames MCU.PORTB_Bits (0);
   
   ----------
   -- Init --
   ----------
   procedure Init is 
   begin
      if HAS_LED then
         LED      := AVR.DD_Output;       --  Define PB0 as Output
         LED_PORT := AVR.Low;             --  Turn Led Off
      end if;
      return;
   end Init;

   ---------
   --  On --
   ---------
   procedure On is 
   begin
      if HAS_LED then
         LED_PORT := AVR.High;
      else 
         LED_PORT := AVR.Low;
      end if;
   end On;

   -----------
   --  Off  --
   -----------
   procedure Off is
   begin
      if HAS_LED then
         LED_PORT := AVR.Low;
      end if;
   end Off;

end LED;