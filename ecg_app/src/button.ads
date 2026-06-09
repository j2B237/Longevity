--  @File : button.ads
--  @Author : Yossep BINYOUM
--  @Brief : Basic implementation for a psuh Button 
--          We use interruption mode to capture ecg event.

with AVR;
with AVR.MCU;

package BUTTON is 

   use AVR;

   procedure Init;
   procedure Init_Interrupt;
   
   function IsButtonPressed return Boolean;
   

private
   pragma Inline (Init);
   pragma Inline (IsButtonPressed);

   -----------
   --  ISR  --
   -----------
   
   procedure Button_INTO_ISR;
   pragma Machine_Attribute (Entity => Button_INTO_ISR, 
                           Attribute_Name => "signal");
   pragma Export (C, Button_INTO_ISR, MCU.Sig_INT0_String);

end BUTTON;