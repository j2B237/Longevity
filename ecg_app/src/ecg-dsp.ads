----------------------------------------------------------------
--  @File : ecg-dsp.ads (Digital Signal Processing)
--  @AUthor : Yossep BINYOUM
--  @Brief : Apply cascade filter to ECG Signal. This code is
--  based on Peter Balch.
---------------------------------------------------------------

with Interfaces;

package ECG.DSP is

   pragma Preelaborate;

   -- Initialize filters states
   procedure Reset_Filters;

   -- Notch Filter. Eliminate noise at 50Hz frequency
   function Filter_Notch (Sample : Interfaces.Unsigned_16) 
      return Interfaces.Integer_32;

   --  Low pass filter. Attenuation high frequency noise such
   --  as muscles, etc ...
   function Filter_Lowpass (Sample : Interfaces.Integer_32)
      return Interfaces.Unsigned_16;

end ECG.DSP;