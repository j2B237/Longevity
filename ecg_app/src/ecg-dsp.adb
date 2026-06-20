with ECG.DSP.Generic_Moving_Average_Filter;
with ECG.DSP.High_Pass_Filter;

package body ECG.DSP is

   use Interfaces;

   ---------------------
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      --  Reset High-pass filter
      High_Pass_Filter.Reset;

      --  Reset Moving Average Filter
      ECG.DSP.Generic_Moving_Average_Filter.Reset_filter;
      
   end Reset_Filters;


end ECG.DSP;