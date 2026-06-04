
with ECG;
with ECG.Manager;
with Interfaces;
with ECG.ADC;

package body ECG.Manager is

   use ECG;
   use Interfaces;

   ------------------------
   --  Get_Ready_Packet  --
   ------------------------

   procedure Get_Ready_Packet (Data : out ECG_Packet) is
   begin
      if Filling_Buffer_A then
         Data := ECG.Buffer_A;
      else
         Data := ECG.Buffer_B;
      end if;
      Packet_Ready := False;
   end Get_Ready_Packet;

end ECG.Manager;