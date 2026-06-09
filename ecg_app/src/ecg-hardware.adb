with System.Machine_Code;

with ECG;
with ECG.ADC;
with ECG.DSP;
with ECG.Manager;
with ECG.TIMERS;
with ECG.UART;
with AD8232;
with LED;

package body ECG.Hardware is
      
   -------------------------
   --  Enable_Interrupts --
   ------------------------

   procedure Enable_Interrupts is
   begin
      System.Machine_Code.Asm ("sei", Volatile => True);
   end Enable_Interrupts;

   --------------------
   --  Init_hardware --
   --------------------

   procedure Init_hardware is
   begin

      --  Led config
      LED.Init;

      --  ECG.DSP.Reset_Filters;
      
      --  Config AD8232
      AD8232.Init;

      --  Config ADC on Channel 0
      ECG.ADC.Init_ADC0;

      --  Config Timer1 in mode CTC
      ECG.TIMERS.Init_Timer1;

      -- Config UART
      ECG.UART.Init
        (Baud_Divider => ECG.UART.Baud_115200_16MHz, 
        Double_Speed => False, Mode => interrupt_tx);

      Enable_Interrupts;
   end Init_hardware;

end ECG.Hardware;
