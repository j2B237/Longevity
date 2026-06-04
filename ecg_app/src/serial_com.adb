--------------------------------------------------------------------
--  @File : serial_com.adb
--  @Author : Yossep BINYOUM
--  @Brief  : Calling TIMER1 ISR each 4ms, read ECG using ADC
--  then send data through USB port. Data will be 
--  persist into csv file then proceed using Matlab.
--
------------------------------------------------------------------

with AVR;
with AVR.Wait;
with Avrada_Rts_Config;

with ECG;
with ECG.ADC;
with ECG.DSP;
with ECG.UART;

with AD8232;
with Interfaces;

procedure Serial_Com is 
   use ECG;
   
   --  Delay every 4ms
   procedure Wait_4_MS is 
      new AVR.Wait.Generic_Wait_USecs (Avrada_Rts_Config.Clock_Frequency, 4000);

   Data           : Interfaces.Unsigned_16;
   Clean_Sample   : Interfaces.Unsigned_16;
begin

   --  Initiaization
   --AD8232.Init;
   ADC.Init_ADC0;
   UART.Init (Baud_Divider => UART.Baud_115200_16MHz, Double_Speed => False, Mode => polled);

   --  Main loop
   loop
      
      Data := ADC.Read_ADC0;
      
      --  2. Apply cascade filter 
      --Clean_Sample := ECG.DSP.Filter_Notch (Data);
      --Clean_Sample := ECG.DSP.Filter_Lowpass (Data);

      UART.Put_UInt16 (Data);
      UART.New_Line;
      Wait_4_MS;
   end loop;



end Serial_Com;