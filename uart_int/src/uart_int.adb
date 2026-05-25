---------------------------------------
--  @File : uart_int.adb
--  @Author : Yossep BINYOUM
--  @Brief  : ECG Holter software.
---------------------------------------

with AVR;
with AVR.MCU;
with AVR.Wait;
with Avrada_Rts_Config;
with Interfaces;
with System.Machine_Code;

with ECG;
with ECG.Hardware;
with ECG.Manager;
with ECG.UART;

procedure Uart_Int is

   use AVR;
   use ECG;
   use Interfaces;

   --  Add a delay of 20 ms each sub-routine call
   procedure Wait_MS is new
      AVR.Wait.Generic_Wait_USecs (
            Crystal_Hertz => Avrada_Rts_Config.Clock_Frequency, 
            Micro_Seconds => 20_000);

   Current_Packet : ECG_Packet;

begin
   -- Initialisation
   Hardware.Init_hardware;

   -- Main loop
   loop
      -- On attend en tâche de fond qu'un paquet de 50 échantillons soit complet
      if Packet_Ready then
         ECG.Manager.Get_Ready_Packet (Current_Packet);

         -- Envoi du paquet au format : "Val1,Val2,Val3,...,Val50\n"
         for I in 1 .. Samples_Per_Packet loop
            ECG.UART.Put_UInt16 (Current_Packet (I));
            if I < Samples_Per_Packet then
               ECG.UART.Put_Char (',');
            end if;
         end loop;
         
         -- Fin de paquet : crucial pour App Inventor (DelimiterByte = 10)
         ECG.UART.CRLF;
      end if;
   end loop;

end Uart_Int;
