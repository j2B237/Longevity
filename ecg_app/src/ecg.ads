----------------------------------------------------------------------------------------------------
--  Onde P : Représente l'activation électrique des oreillettes (les cavités supérieures du cœur).
--  Complexe QRS : Représente l'activation des ventricules (les cavités inférieures).
--  Onde T : Correspond à la phase de repos et de récupération du muscle cardiaque
-----------------------------------------------------------------------------------------------------
with AVR;
with Interfaces;

package ECG is

   pragma Preelaborate; 
   -- This tells the compiler to proceed to initialization
   --  of objects in the library level before proceding the
   --- main program.
   
   SAMPLES_PER_PACKET : constant Positive := 25;
   type ECG_Packet is array (Positive range 1 .. SAMPLES_PER_PACKET) of Interfaces.Unsigned_16;
   
   --  Double buffer (Like OpenGL API)
   Buffer_A : ECG_Packet;
   Buffer_B : ECG_Packet;

   type UART_Mode_Kind is (polled, interrupt_rx, interrupt_tx, interrupt_rx_tx);

   Packet_Ready : Boolean := False with Volatile;

   --  Samples count (1 to SAMPLES_PER_PACKET)
   Sample_Index : Positive := 1;

   --  Flag to know which tampon is currently being 
   --  fullfill (True = A, False = B)
   Filling_Buffer_A : Boolean := True;

end ECG;