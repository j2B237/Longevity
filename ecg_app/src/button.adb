with AVR.Real_Time;

with Interfaces;
with LED;

package body BUTTON is


   use AVR;
   use Interfaces;


   -- Package-level entities

   HAS_BUTTON     : constant Boolean := True;
   BUTTON         : Boolean renames MCU.DDRD_Bits  (MCU.PORTD2_Bit);
   BUTTON_PORT    : Boolean renames MCU.PORTD_Bits (MCU.PORTD2_Bit);
   
   ----------
   -- Init --
   ----------
   procedure Init is
   begin
      
      if HAS_BUTTON then
         -- Initialisation PD2 en mode Input
         BUTTON := AVR.DD_Input;
         -- Active la resistance interne de Pull-up
         BUTTON_PORT := AVR.High;
      else
         -- Par default la broche est en mode Input
         -- On s'assure juste que la resistance de Pull-Up
         -- n'est pas cablee.
         BUTTON_PORT := AVR.Low;
      end if;
      return;
   end Init;

   ----------------------
   --  Init_Interrupt  --
   ----------------------

   procedure Init_Interrupt is
   begin
      --  Enable PD2 as Input with Pull-Up resistor
      Init;

      --  Activate INT0
      MCU.EIMSK := MCU.EIMSK or MCU.INT0_Mask;

   end Init_Interrupt;

   ---------------------
   -- IsButtonPressed --
   ---------------------
   function IsButtonPressed return Boolean is
      State : Unsigned_8 := MCU.PIND;
   begin
      if HAS_BUTTON then
         -- Le bouton est actif (LOW) donc Niveau bas.
         if ((State and Shift_Left (1, Integer (MCU.PORTD2_Bit))) = 0) then
            return True;
         else 
            return False;
         end if;
      else
         return False;
      end if;
   end IsButtonPressed;


   ------------
   --   ISR  --
   ------------

   procedure Button_INTO_ISR is
      
   begin
      LED.Toggle;
   end Button_INTO_ISR;

end BUTTON;