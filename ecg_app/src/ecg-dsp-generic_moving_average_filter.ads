--
--  @File   : ECG.Dsp.Generic_Moving_Average_Filter.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Encapsulate Logic inside a generic package
--  for compute moving average filter. 
--
with Interfaces;

package ECG.DSP.Generic_Moving_Average_Filter is

   pragma Preelaborate;

   use Interfaces;

   Size : constant := 4;           -- Can be change to 16, 32, 64, 128, etc


   --  Object of this type will be modified by Interrupt routine
   --  therefore should be qualify by Volatile
   type Reading_Array is array (0 .. Size - 1) of Interfaces.Unsigned_16;
   
   -- Record that act as filter object
   type Moving_Avg_Filter is
      record
         Readings       : Reading_Array;
         ReadingIndex   : Natural := 0;
         Total          : Interfaces.Unsigned_32 := 0;
         Average        : Interfaces.Unsigned_16 := 0;
      end record;

   --  Reset filter
   procedure Reset_filter;
   
   --  Procedure Update : that insert a new sample 
   --  before average computing.

   procedure Update (New_Sample : Interfaces.Unsigned_16;
                     Clean_Sample : out Interfaces.Unsigned_16);

private

   Filter : Moving_Avg_Filter with Volatile;

end ECG.DSP.Generic_Moving_Average_Filter;