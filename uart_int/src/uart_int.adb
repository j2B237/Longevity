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
with HC05;

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
         HC05.Transmit_ECG_Packet (Current_Packet);
      end if;
   end loop;

end Uart_Int;
