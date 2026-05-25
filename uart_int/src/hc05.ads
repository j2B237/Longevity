--  @File : hc05.ads
--  @Author : Yossep BINYOUM
--  @Brief  : UART transmition using Interrupt on Receive complete

with AVR;
with AVR.MCU;


package HC05 is 

   --  Type enumeratif pour representer l'etat de la LED
   type System_State is (OFF, ON);

   --  Entite public 
   --  Volatile car partage et modifiable par d'autres entities
   --  hors ou presentent dans le meme package.
   Current_State : System_State := OFF with Volatile;

private

   procedure UART_RX_ISR;
   pragma Machine_Attribute (Entity => UART_RX_ISR,
                           Attribute_Name => "signal");
   pragma Export (C, UART_RX_ISR, AVR.MCU.Sig_USART_RX_String);

end HC05;