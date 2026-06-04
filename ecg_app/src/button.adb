with AVR;
with AVR.MCU;
with Interfaces;


package body BUTTON is

   use AVR;
   use Interfaces;

   --  Constant entities. We can use them for conditionnal compilation

   HAS_BUTTON     : constant Boolean := True;
   BUTTON         : Boolean renames MCU.DDRD_Bits  (2);
   BUTTON_PORT    : Boolean renames MCU.PORTD_Bits (2);
   
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


   ---------------------
   -- IsButtonPressed --
   ---------------------
   function IsButtonPressed return Boolean is
      State : Unsigned_8 := MCU.PIND;
   begin
      if HAS_BUTTON then
         -- Le bouton est actif (LOW) donc Niveau bas.
         if ((State and Shift_Left (1, Integer (MCU.PORTB2_Bit))) = 0) then
            return True;
         else 
            return False;
         end if;
      else
         return False;
      end if;
   end IsButtonPressed;

end BUTTON;