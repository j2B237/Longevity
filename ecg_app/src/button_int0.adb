with AVR;
with AVR.MCU;

with BUTTON;
with ECG.Hardware;
with LED;

procedure Button_INT0 is

begin

   -- Button initialization
   BUTTON.Init_Interrupt;
   LED.Init;
   
   ECG.Hardware.Enable_Interrupts;

   loop
      --  Do nothing while CPU is running interrupt
      null;
   end loop;
end Button_INT0;