--  @File : hc05.ads
--  @Author : Yossep BINYOUM
--  @Brief  : UART transmition using Interrupt on Receive complete

with AVR;
with AVR.MCU;
with ECG;


package HC05 is 

   --  Type enumeratif pour representer l'etat de la LED
   type System_State is (OFF, ON);

   --  Entite public 
   Current_State : System_State := OFF with Volatile;

   procedure Transmit_ECG_Packet (Data : ECG.ECG_Packet);
   
   -- Interrupt routines
   procedure UART_Interrupt_Send (Data : ECG.ECG_Packet);

private

   HEADER : constant := 16#AA55#;
   FOOTER : constant := 16#FF99#;
   
   --procedure UART_RX_ISR;
   --pragma Machine_Attribute (Entity => UART_RX_ISR,
   --                        Attribute_Name => "signal");
   --pragma Export (C, UART_RX_ISR, AVR.MCU.Sig_USART_RX_String);

end HC05;