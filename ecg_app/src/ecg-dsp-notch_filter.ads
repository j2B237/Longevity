with Interfaces;

package ECG.DSP.Notch_Filter is

   pragma Preelaborate;
   
   use Interfaces;

   -- Public part of the package
   procedure Reset;

   --  Apply a Notch filter at 50 Hz on a sample (ECG Data)
   function Apply (Sample : Interfaces.Integer_32)
      return Interfaces.Integer_32;

private

   --  Cutt-off Frequency 50 Hz
   FREQUENCY      : constant Interfaces.Integer_32 := 50; 

   --  This factor is used to make CPU job easier
   --  Scaling coef are float point values so we need
   --  to convert them into Integer.        
   SCALE_FACTOR   : constant Interfaces.Integer_32 := 16384;

   -- Scale all coefficients by 2**14 (16384)
   B0 : constant Interfaces.Integer_32 := 16384;
   B1 : constant Interfaces.Integer_32 := -10126;
   B2 : constant Interfaces.Integer_32 := 16384;
   A1 : constant Interfaces.Integer_32 := -9620;
   A2 : constant Interfaces.Integer_32 := 14787;


   --  Internal representation of Notch filter state
   type Notch_State is record
         X1 : Interfaces.Integer_32;   -- x[n-1] Prev entry
         X2 : Interfaces.Integer_32;   -- x[n-2]
         Y1 : Interfaces.Integer_32;   -- y[n-1] Prev output
         Y2 : Interfaces.Integer_32;
      end record;


   --  Private entity represents Notch filter
   --  iteration'state. This object is alternate on each 
   --  ECG.Timers.Timer_COMPA_ISR isr'call therefore 
   --  should be qualified as Volatille

   Internal_Notch_Filter_State : Notch_State := (0, 0, 0, 0);
   pragma Volatile (Internal_Notch_Filter_State);

end ECG.DSP.Notch_Filter;