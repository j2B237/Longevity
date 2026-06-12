---------------------------------------
--  @File   : ecg_filter.adb
--  @Author : Yossep BINYOUM
--  @Brief  : ECG Holter software.
---------------------------------------

with AVR;
with AVR.MCU;

with ECG.ADC;
with Interfaces;

with ECG;
with ECG.Hardware;
with ECG.Manager;
with HC05;

procedure ECG_Filter is

   use AVR;
   use ECG;
   use Interfaces;

   Current_Packet : ECG_Packet;

begin
   -- Initialisation
   Hardware.Init_hardware;

   loop
      if Packet_Ready then
         ECG.Manager.Get_Ready_Packet (Current_Packet);
         HC05.UART_Interrupt_Send (Current_Packet);
      end if;
   end loop;

end ECG_Filter;
