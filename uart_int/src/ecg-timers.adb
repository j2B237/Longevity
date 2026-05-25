with AVR;
with AVR.MCU;
with Interfaces;
with AD8232;

package body ECG.TIMERS is

   use AVR;

   -------------------
   --  Init_Timer1  --
   -------------------

   procedure Init_Timer1 is
   begin
      -- 2. Configuration du Timer 1 pour interruption toutes les 4 ms (Mode CTC)
      MCU.TCCR1A := 0;
      MCU.TCCR1B := 2#00001011#; -- Mode CTC, Prescaler = 64
      MCU.OCR1AH := Interfaces.Unsigned_8 (999 / 256);
      MCU.OCR1AL := Interfaces.Unsigned_8 (999 mod 256);
      MCU.TIMSK1 := MCU.OCIE1A_Mask; -- Activer l'interruption Compare Match A
   end Init_Timer1;


   ------------------------
   --  Timer_COMPA_ISR   --
   ------------------------

   procedure Timer_COMPA_ISR is 
      Current_Sample : Interfaces.Unsigned_16;
   begin
      --  Reading AD8232 sensor through ADC
      Current_Sample := AD8232.Get_Reading;

      --  Store ECG data in the current active buffer
      if Filling_Buffer_A then
         Buffer_A (Sample_Index) := Current_Sample;
      else
         Buffer_B (Sample_Index) := Current_Sample;
      end if;

      --  Buffer swapping through Index management
      if Sample_Index = SAMPLES_PER_PACKET then
         Sample_Index := 1;
         Filling_Buffer_A := not Filling_Buffer_A;
         Packet_Ready := True;                     --  Warn main to send data through UART
      else 
         Sample_Index := @ + 1;                    --  Equal to i := i + 1
      end if;

   end Timer_COMPA_ISR;
   
end ECG.TIMERS;