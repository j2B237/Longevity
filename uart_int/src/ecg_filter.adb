---------------------------------------
--  @File   : uart_int.adb
--  @Author : Yossep BINYOUM
--  @Brief  : ECG Holter software.
---------------------------------------

with AVR;
with AVR.MCU;

with Interfaces;

with ECG;
with ECG.DSP;
with ECG.Hardware;
with ECG.Manager;
with ECG.UART;
with HC05;

procedure ECG_Filter is

   use AVR;
   use ECG;
   use Interfaces;

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

end ECG_Filter;
