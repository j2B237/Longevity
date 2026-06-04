----------------------------------------------
--  @File   : ecg-hardware.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Manage hardware initialization 
----------------------------------------------


package ECG.Hardware is 

   pragma Preelaborate;

   --  Macro d'activation des interruptions globales
   procedure Enable_Interrupts;
   procedure Init_hardware;

private
   pragma Inline (Enable_Interrupts);

end ECG.Hardware;