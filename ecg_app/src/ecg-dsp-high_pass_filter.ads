with Interfaces;

--  Formule de calcul pour le coeficient d'un filtre Passe-haut
--
--  1. La constante de Temps RC
--  Fc (Frequence de coupure) = 0.5 Hz
-- 
--  RC = 1 / 2 * pi * Fc
--
--  2. Calcul de la periode d'echantillonnage
--  Fe (Frequence d'echantillonnage) = 250 Hz
--  
--  Te = 1 / Fe = 1 / 250 = 0,004 s
--
--  3. Calcul du coeficient
--
--  Alpha = RC / (RC + Te)
--
--  Conversion du coeficient en valeur entiere
-- 
--  Alpha_Int = Alpha * 2^16
--

package ECG.DSP.High_Pass_Filter is

   pragma Preelaborate;

   use Interfaces;
   
   --  procedure Reset_Filters;
   --  function Cascade_Filters (Sample : Interfaces.Unsigned_16)
   --     return Interfaces.Unsigned_16;

   type ECG_State is private;

   procedure Reset;

   -- Applique le filtre passe-haut sur un échantillon ECG
   function Apply (Input : in Interfaces.Integer_32) 
      return Interfaces.Integer_32;

private

   -- Initialise le filtre avec le coefficient Alpha mis à l'échelle en Q14 (0..16384)
   procedure Initialize (Alpha_Q14 : in Interfaces.Integer_32);

   type ECG_State is record
      X_Prev    : Interfaces.Integer_32 := 0;
      -- Y_Prev en unsigned permet de conserver des valeurs d'ondes
      -- Q et S negatif malgres le recentrage a zero fait par
      -- le filtre passe-haut
      Y_Prev    : Interfaces.Integer_32 := 0;
      Alpha_Q14 : Interfaces.Integer_32 := 0;          -- Alpha_Q14 = 0.9875 (0.9875 * 16384)
   end record;


   High_Pass_Filter_Internal_State : ECG_State := (others => 0);
   pragma Volatile (High_Pass_Filter_Internal_State);
   
end ECG.DSP.High_Pass_Filter;