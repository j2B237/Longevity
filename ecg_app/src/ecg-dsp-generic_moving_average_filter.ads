--
--  @File   : ECG.Dsp.Generic_Moving_Average_Filter.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Encapsulate Logic inside a generic package
--  for compute moving average filter. 
--
with Interfaces;

generic
   Size : Positive := 8;           -- Can be change to 16, 32, 64, 128, etc
package ECG.DSP.Generic_Moving_Average_Filter is

   --  Object of this type will be modified by Interrupt routine
   --  therefore should be qualify by Volatile
   type Reading_Array is array (0 .. Size - 1) of Interfaces.Unsigned_16;
   pragma Volatile (Reading_Array);
   
   -- Record that act as filter object
   type Moving_Avg_Filter is
      record
         Readings       : Reading_Array := (others => 0);
         ReadingIndex   : Positive := 0;
         Total          : Interfaces.Unsigned_32;
         Average        : Interfaces.Unsigned_32;
      end record;

   --  Procedure Update : that insert a new sample 
   --  before average computing.

   procedure Update (Filter : in out Moving_Avg_Filter; 
                     New_Sample : Interfaces.Unsigned_16);

end ECG.DSP.Generic_Moving_Average_Filter;