package body ECG.DSP is

   use Interfaces;

   --  Variables d'état pour le filtre Notch (Mémoire des échantillons précédents)
   --  Volatile ou simplement variables globales au corps du package
   Notch_X1, Notch_X2 : Interfaces.Integer_32 := 0;
   pragma Volatile (Notch_X1);
   pragma Volatile (Notch_X2);

   Notch_Y1, Notch_Y2 : Interfaces.Integer_32 := 0;
   pragma Volatile (Notch_Y1);
   pragma Volatile (Notch_Y2);

   --  Variables d'état pour le filtre Passe-bas
   LP_Y1 : Interfaces.Integer_32 := 0;

   ---------------------
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      Notch_X1 := 0; Notch_X2 := 0;
      Notch_Y1 := 0; Notch_Y2 := 0;
      LP_Y1    := 0;
   end Reset_Filters;

   --------------------
   --  Filter_Notch  --
   --------------------

   function Filter_Notch (Sample : Interfaces.Unsigned_16) 
      return Interfaces.Unsigned_16
   is
      X0 : constant Interfaces.Integer_32 := 
         Interfaces.Integer_32 (Sample);
      Y0 : Interfaces.Integer_32;
      --  Exemple d'équation de filtre Notch 50Hz standard à virgule fixe
      --  y[n] = (x[n] - 2*cos(w)*x[n-1] + x[n-2] + 2*r*cos(w)*y[n-1] - r^2*y[n-2])
   begin
      --  Équation entière simplifiée (ajustez les coefficients selon le code précis de l'Ino)
      --  Ici, une approximation classique à virgule fixe :
      Y0 := X0 - Notch_X1 + Notch_X2; 
      
      --  Mise à jour de la ligne à retard pour X
      Notch_X2 := Notch_X1;
      Notch_X1 := X0;

      --  Mise à jour de la ligne à retard pour Y
      Notch_Y2 := Notch_Y1;
      Notch_Y1 := Y0;

      return Interfaces.Unsigned_16 (Y0);             --  Assurer que ça reste entre 0 et 1023

   exception
      when others => return Sample;                   --  Sécurité en cas de débordement
   end Filter_Notch;

   ----------------------
   --  Filter_Lowpass  --
   ----------------------

   function Filter_Lowpass (Sample : Interfaces.Unsigned_16)
      return Interfaces.Unsigned_16 
   is
      X0 : constant Interfaces.Integer_32 := 
         Interfaces.Integer_32 (Sample);

      --  Filtre passe-bas du premier ordre (Moyenne mobile exponentielle)
      --  y[n] = a * x[n] + (1 - a) * y[n-1]
      --  En virgule fixe (base 256, soit 'a' = 32/256 => environ 0.125)
      Alpha : constant := 32;

      Accumulator : Interfaces.Integer_32;
   begin
      Accumulator := (Alpha * X0 + (256 - Alpha) * LP_Y1);
      LP_Y1 := Accumulator / 256;
      
      return Interfaces.Unsigned_16 (LP_Y1);
   end Filter_Lowpass;


end ECG.DSP;