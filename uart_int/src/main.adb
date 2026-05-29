with ECG;
with ECG.UART;
with ECG.Hardware;
with HC05;

with AVR;
with AVR.Wait;
with Avrada_Rts_Config;

procedure Main is
   use ECG;
   use AVR;

   procedure Wait_MS is new 
      AVR.Wait.Generic_Wait_USecs (Avrada_Rts_Config.Clock_Frequency, 900_000);  

begin

   Hardware.Init_hardware;
   loop
      UART.Put_Line ("Hello Ada World. AVR programming with Ada is cool");
      --UART.Put_Char (ASCII.LF);
      Wait_MS;
   end loop;
end Main;