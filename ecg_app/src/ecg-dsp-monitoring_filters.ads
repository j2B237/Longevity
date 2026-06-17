with Interfaces;

package ECG.DSP.Monitoring_Filters is

   pragma Preelaborate;

   procedure Reset_Filters;
   function Cascade_Filters (Sample : Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16;
   
end ECG.DSP.Monitoring_Filters;