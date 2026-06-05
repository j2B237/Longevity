---------------------------------------
--  @File   : ecg_filter.adb
--  @Author : Yossep BINYOUM
--  @Brief  : ECG Holter software.
---------------------------------------

with AVR;
with AVR.MCU;
with AVR.UART;
with AVR.Wait;
with Avrada_Rts_Config;

with ECG.ADC;
with Interfaces;

with ECG;
with ECG.DSP;
with ECG.Hardware;
with ECG.Manager;
with ECG.UART;
with HC05;
with LED;

procedure ECG_Filter is

   use AVR;
   use ECG;
   use Interfaces;


   procedure Wait_1_Sec is 
      new AVR.Wait.Generic_Wait_USecs (Avrada_Rts_Config.Clock_Frequency, 1_000_000);


   Current_Packet : ECG_Packet;
   Led_State : Boolean := False with Volatile;
   Sample : Interfaces.Unsigned_16 := 0;

begin
   -- Initialisation
   Hardware.Init_hardware;

   --  Led initialization
   --  LED.Init;

   --  --  Init ADC
   --  ECG.ADC.Init_ADC0;


   --  --  USART0 initialization 
   --  ECG.UART.Init (Baud_Divider => ECG.UART.Baud_115200_16MHz, 
   --                 Double_Speed => False, 
   --                 Mode => interrupt_tx);

   --  --  Enable global interruptions
   --  ECG.Hardware.Enable_Interrupts;

   --  LED.On;
   --  Wait_1_Sec;


   -- Main loop
   loop
      
      -- Get a sample from ADC0
      --  Sample := ECG.ADC.Read_ADC0;

      --  ECG.UART.UART_Send (16#AA55#);
      --  ECG.UART.UART_Send (Sample);

      --  if Led_State then
      --     LED.On;
      --     Led_State := not Led_State;
      --  else
      --     LED.Off;
      --     Led_State := not Led_State;
      --  end if;

      --  Wait_1_Sec;

      -- On attend en tâche de fond qu'un paquet de 
      -- SAMPLES_PER_PACKET échantillons soit complet
      if Packet_Ready then
         ECG.Manager.Get_Ready_Packet (Current_Packet);
         HC05.UART_Interrupt_Send (Current_Packet);
      end if;
   end loop;

end ECG_Filter;
