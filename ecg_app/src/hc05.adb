with ECG.UART;

package body HC05 is
   
   ---------------------------
   --  Transmit_ECG_Packet  --
   ---------------------------
   
   procedure Transmit_ECG_Packet (Data : ECG.ECG_Packet) is
      Current_Packet : ECG.ECG_Packet := Data;
   begin
      -- Envoi du paquet au format : "Val1,Val2,Val3,...,Val50\n"
      for I in 1 .. ECG.Samples_Per_Packet loop
         ECG.UART.Put_UInt16 (Current_Packet (I));
         if I < ECG.Samples_Per_Packet then
            ECG.UART.Put_Char (',');
         end if;
      end loop;
      
      -- Fin de paquet : crucial pour App Inventor (DelimiterByte = 10)
      ECG.UART.Put_Char (ASCII.LF);
   end Transmit_ECG_Packet;


   ---------------------------
   -- UART_Interrupt_Send   --
   ----------------------------

   procedure UART_Interrupt_Send (Data : ECG.ECG_Packet) is
   begin
      -- HEADER Synchronisation value (LSB: 85 (55), MSB: 170 (AA))
      ECG.UART.UART_Send (16#AA55#);
      for I in Data'Range loop
         ECG.UART.UART_Send (Data (I));
      end loop;
      -- FOOTER : Marker value before reading BPM (LSB:  153 (99), MSB: 255 (FF))

      -- Sending BPM Value

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