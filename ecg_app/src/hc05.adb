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