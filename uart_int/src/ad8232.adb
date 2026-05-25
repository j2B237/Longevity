with ECG.ADC;

package body AD8232 is

   use ECG;

   --  Compilation constant
   IS_CONNECTED : constant Boolean := True;

   ------------
   --  Init  --
   ------------

   procedure Init is
   begin
      -- Define Pins as INPUT
      LO_MOINS_DDR   := AVR.DD_Input;
      LO_PLUS_DDR    := AVR.DD_Input;  
      -- Make sure no internal PULL-UP resistors
      -- are connected    
      LO_MOINS       := AVR.Low;
      LO_PLUS        := AVR.Low;
   end Init;


   -------------------
   --  Get_Reading  --
   -------------------

   function Get_Reading return Interfaces.Unsigned_16 is
   begin
      --  Leads disconnected return 0
      if LO_MOINS_PIN = AVR.High or LO_PLUS_PIN = AVR.High then
         return Interfaces.Unsigned_16 (0);
      else
         return ECG.ADC.Read_ADC0;
      end if;
   end Get_Reading;

end AD8232;