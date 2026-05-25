---------------------------------------------
--  @File : ecg-manager.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Double buffering controller. 
---------------------------------------------

with AVR.MCU;

package ECG.Manager is
   pragma Preelaborate;
   use AVR;

   --  Get the last ready ECG packet
   procedure Get_Ready_Packet (Data : out ECG_Packet);
   

private

end ECG.Manager;