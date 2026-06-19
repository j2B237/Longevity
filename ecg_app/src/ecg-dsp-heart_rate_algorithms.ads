-----------------------------------------------------------------
--  @File : ecg-dsp-heart_rate_algorithms.ads
--  @Author : Yossep BINYOUM
--  @Brief  : Compute different constantes such as Heart Rate
--  , Heart Rate Variability.
-----------------------------------------------------------------

with Interfaces;


package ECG.DSP.Heart_Rate_Algorithms is

   pragma Preelaborate;

   use Interfaces;

   function Is_HR_Update return Boolean with Inline;

   --  Return the current BPM value
   function Get_BPM return Interfaces.Unsigned_16;

   --  Amplify the ECG sample linearly for visualization.
   --  The visualizer receives positive unsigned integer values.
   --  The waveform shape is preserved by using a linear scale and
   --  clamping to the Unsigned_16 range.
   procedure Amplify_Sample (Sample : in Interfaces.Unsigned_16;
                           Amplified_Value : out Interfaces.Unsigned_16);

   procedure Initialize;

   --  Update BPM value if we found a new Pic
   procedure Update_Heart_Rate (Clean_Sample : Interfaces.Unsigned_16);

private

   --  This is the Magnitude value in mV of R wave visible in ECG
   --  curve. This value must be update by simple findMax sub-routine
   --  when collecting samples. But For now this match value I observe
   --  when I monitor myself.
   
   THRESHOLD      : constant := 600;
   THRESHOLD_MIN  : constant := 5200;
   THRESHOLD_MAX  : constant := 650;
   NUMERATOR      : constant := 15000;
   AMPLIFICATION_FACTOR : constant Interfaces.Unsigned_32 := 2;
   
   BPM_Counter    : Natural with Volatile;
   BPM_Value      : Interfaces.Unsigned_16 with Volatile;
   Pic_On_Pending : Boolean := False with Volatile;


   --  Flag for monitoring UART Trame content.
   --  We only update UI if we have found new Pic on
   --  R wave.
   HR_Value_Available : Boolean := False with Volatile;

end ECG.DSP.Heart_Rate_Algorithms;