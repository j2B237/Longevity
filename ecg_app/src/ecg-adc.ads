with Interfaces;
package ECG.ADC is 

   pragma Preelaborate;

   use Interfaces;
   
   procedure Init_ADC0;
   function Read_ADC0 return Interfaces.Unsigned_16;

private
   pragma Inline (Init_ADC0);
end ECG.ADC;