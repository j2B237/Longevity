package body HC05 is
   
   -------------------
   --  UART_RX_ISR  --
   -------------------

   procedure UART_RX_ISR is 
      Received_Char : Character;
   begin
      --  Lecture du registre UART (UDR0) des qu'un 
      --  mot (8 bits) arrive
      Received_Char := Character'Val (AVR.MCU.UDR0);

      --  Analyse de la valeur recue
      case Received_Char is
         when 'E' => Current_State := OFF;
         when 'A' => Current_State := ON;
         when others => null;                -- On ignore
      end case;
   end UART_RX_ISR;
   
end HC05;