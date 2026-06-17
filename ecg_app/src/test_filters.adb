with HC05;
with ECG;
with ECG.DSP;
with ECG.Hardware;
with ECG.Manager;

procedure Test_Filters is

   use ECG;
   use ECG.DSP;

   Current_Packet : ECG.ECG_Packet := (others => 0);
begin

   --  Initialize the system
   ECG.Hardware.Init_hardware;

   --  Main loop

   loop
      if Packet_Ready then
         Manager.Get_Ready_Packet (Current_Packet);
         HC05.UART_Interrupt_Send (Current_Packet);
      end if;
   end loop;
end Test_Filters;