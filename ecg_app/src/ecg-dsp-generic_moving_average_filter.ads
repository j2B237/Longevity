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

   Size : constant := 6;           -- Can be change to 16, 32, 64, 128, etc


   --  Object of this type will be modified by Interrupt routine
   --  therefore should be qualify by Volatile
   type Reading_Array is array (0 .. Size - 1) of Interfaces.Integer_32;
   
   -- Record that act as filter object
   type Moving_Avg_Filter is
      record
         Readings       : Reading_Array;
         ReadingIndex   : Natural := 0;
         Total          : Interfaces.Integer_32 := 0;
         Average        : Interfaces.Integer_32 := 0;
      end record;

   --  Reset filter
   procedure Reset_filter;

   function Apply (Input : Interfaces.Integer_32)
      return Interfaces.Integer_32;


private

   Filter : Moving_Avg_Filter with Volatile;

end ECG.DSP.Generic_Moving_Average_Filter;