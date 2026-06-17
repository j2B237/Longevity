
with AVR;
with AVR.MCU;

package ECG.Interrupt is
   pragma Preelaborate;

   use AVR;
   
   procedure Init_Timer1;
private 
   pragma Inline (Init_Timer1);

   --  ISR For TIMER1
   --  We use TIMER1 on Capture and Compare Mode
   procedure Timer_COMPA_ISR;
   pragma Machine_Attribute (Entity => Timer_COMPA_ISR,
                           Attribute_Name => "signal");
   pragma Export (C, Timer_COMPA_ISR, MCU.Sig_TIMER1_COMPA_String);

end ECG.Interrupt;