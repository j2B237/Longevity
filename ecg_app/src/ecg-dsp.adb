package body ECG.DSP is

   use Interfaces;

   --------------------------------------------
   --  Variables d'état pour le filtre Notch --
   --------------------------------------------
   
   Notch_X1, Notch_X2 : Interfaces.Integer_32 := 0;
   pragma Volatile (Notch_X1);
   pragma Volatile (Notch_X2);

   Notch_Y1, Notch_Y2 : Interfaces.Integer_32 := 0;
   pragma Volatile (Notch_Y1);
   pragma Volatile (Notch_Y2);

   -------------------------------------------------
   --  Variables d'état pour le filtre Passe-bas  --
   -------------------------------------------------

   --  Les coefficients du filtre passe-bas a phase lineaire 

   --  Un filtre d'ordre 10 introduit un retard 
   --  D = 70 / 2 = 35 echantillons

   Filter_Order : constant := 70;

   -- Coefficients pour filtre d'ordre 6 (Virgule fixe *1024)
   Filter_Coefs : constant array (0 .. Filter_Order) of Interfaces.Integer_32 := (
   0,
   -1,
   -1,
   1,
   1,
   0,
   -2,
   -1,
   1,
   3,
   0,
   -4,
   -3,
   3,
   6,
   0,
   -8,
   -6,
   6,
   12,
   0,
   -15,
   -11,
   12,
   22,
   0,
   -30,
   -21,
   25,
   48,
   0,
   -75,
   -63,
   95,
   310,
   410,
   310,
   95,
   -63,
   -75,
   0,
   48,
   25,
   -21,
   -30,
   0,
   22,
   12,
   -11,
   -15,
   0,
   12,
   6,
   -6,
   -8,
   0,
   6,
   3,
   -3,
   -4,
   0,
   3,
   1,
   -1,
   -2,
   0,
   1,
   1,
   -1,
   -1,
   0
   );



   --  Historique des 8 derniers echantillons 
   Last_Samples : array(0 .. Filter_Order) of Interfaces.Integer_32 := (others => 0) with Volatile_Components;
   pragma Volatile (Last_Samples);

   Head : Natural := 0 with Volatile;

   ---------------------
   --  Reset_Filters  --
   ---------------------

   procedure Reset_Filters is
   begin
      Notch_X1 := 0; Notch_X2 := 0;
      Notch_Y1 := 0; Notch_Y2 := 0;
      Head     := 0;

      for I in 0 .. Filter_Order loop
         Last_Samples (I) := 0;
      end loop;
   end Reset_Filters;

   --------------------
   --  Filter_Notch  --
   --------------------

   function Filter_Notch (Sample : Interfaces.Unsigned_16) 
      return Interfaces.Unsigned_16
   is
      X0 : constant Interfaces.Integer_32 := 
         Interfaces.Integer_32 (Sample);
      Y0 : Interfaces.Integer_32 := 0; 
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
      -- Correction : Initialisation explicite indispensable en Ada
      Accumulator : Interfaces.Integer_32 := 0;
      Sign_Index  : Integer := 0;
   begin
      -- On stocke le signal arrivant
      Last_Samples (Head) := Interfaces.Integer_32 (Sample);
  
      --  Equation de convolution
      for K in 0 .. Filter_Order loop
         Sign_Index := Head - K;
         
         -- Gestion stricte et sûre du buffer circulaire pour AVR
         if Sign_Index < 0 then
            Sign_Index := Sign_Index + (Filter_Order + 1);
         end if;

         Accumulator := @ + (Filter_Coefs (K) * Last_Samples (Sign_Index));
      end loop;

      --  On fait avancer la tête du buffer circulaire
      Head := (@ + 1) mod (Filter_Order + 1);

      --  Compensation du gain : On divise par 1024
      Accumulator := @ / 1024;

      --  Sécurité Anti-saturation de l'ADC (0 .. 1023)
      if Accumulator < 0 then
         return 0;
      elsif Accumulator > 1023 then
         return 1023;
      else
         return Interfaces.Unsigned_16 (Accumulator);
      end if;

   end Filter_Lowpass;


end ECG.DSP;