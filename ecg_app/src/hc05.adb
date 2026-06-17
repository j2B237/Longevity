with ECG.UART;
with ECG.DSP.Heart_Rate_Algorithms;

package body HC05 is
   
   use ECG;
   use ECG.DSP;
   
   ---------------------------
   --  Transmit_ECG_Packet  --
   ---------------------------
   
   procedure Transmit_ECG_Packet (Data : ECG_Packet) is
      Current_Packet : ECG_Packet := Data;
   begin
      -- Envoi du paquet au format : "Val1,Val2,Val3,...,Val50\n"
      for I in 1 .. ECG.Samples_Per_Packet loop
         UART.Put_UInt16 (Current_Packet (I));
         if I < ECG.Samples_Per_Packet then
            UART.Put_Char (',');
         end if;
      end loop;
      
      -- Fin de paquet : crucial pour App Inventor (DelimiterByte = 10)
      UART.Put_Char (ASCII.LF);
   end Transmit_ECG_Packet;


   ---------------------------
   -- UART_Interrupt_Send   --
   ----------------------------
   --  This procedure send over UART 56 bytes of data

   procedure UART_Interrupt_Send (Data : ECG_Packet) is
   begin
      --  Compute BPM first
      for I in Data'Range loop
         Heart_Rate_Algorithms.Update_Heart_Rate (Data (I));
      end loop;

      -- HEADER Synchronisation value (LSB: 85 (55), MSB: 170 (AA))
      UART.UART_Send (HEADER);

      --  Trame body contains 25 samples x 2 bytes = 50 bytes (octets) 
      for I in Data'Range loop
         UART.UART_Send (Data (I));
      end loop;

      -- FOOTER : Marker value before reading BPM (LSB:  153 (99), MSB: 255 (FF))
      UART.UART_Send (FOOTER);

      if Heart_Rate_Algorithms.Is_HR_Update then
         --  Send BPM Value
         UART.UART_Send (Heart_Rate_Algorithms.Get_BPM);
      else
         UART.UART_Send (0);
      end if;

   end UART_Interrupt_Send;

   -------------------
   --  UART_RX_ISR  --
   -------------------

   --  procedure UART_RX_ISR is 
   --     Received_Char : Character;
   --  begin
   --     --  Lecture du registre UART (UDR0) des qu'un 
   --     --  mot (8 bits) arrive
   --     Received_Char := Character'Val (AVR.MCU.UDR0);

   --     --  Analyse de la valeur recue
   --     case Received_Char is
   --        when 'E' => Current_State := OFF;
   --        when 'A' => Current_State := ON;
   --        when others => null;                -- On ignore
   --     end case;
   --  end UART_RX_ISR;
   
end HC05;