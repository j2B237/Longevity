package body ECG.DSP.Heart_Rate_Algorithms is

   --------------------
   --   Initialize   --
   --------------------

   procedure Initialize is
   begin
      BPM_Counter        := 0;
      BPM_Value          := 0;
      Pic_On_Pending     := False;
      HR_Value_Available := False;
   end Initialize;

   --------------------
   --  Is_HR_Update  --
   --------------------

   function Is_HR_Update return Boolean is
   begin
      return HR_Value_Available;
   end Is_HR_Update;

   -----------------
   --   Get_BPM   --
   -----------------

   function Get_BPM return Interfaces.Unsigned_16 is
   begin
      return BPM_Value;
   end Get_BPM;

   -------------------------
   --  Update_Heart_Rate  --
   -------------------------

   procedure Update_Heart_Rate (Clean_Sample : Interfaces.Unsigned_16) 
   is
   begin
      
      --  Increment counter each call
      BPM_Counter := @ + 1;

      -- THRESHOLD = 600
      if Clean_Sample > THRESHOLD then
         if not Pic_On_Pending then
            Pic_On_Pending := True;
            
            --  Protect against zero division error at runtime and if BPM_Counter 
            --  is too low
            if BPM_Counter > 10 then
               BPM_Value            := Interfaces.Unsigned_16 (NUMERATOR / BPM_Counter);
               HR_Value_Available   := True;
            end if;

            --  Reset BPM_Counter
            BPM_Counter := 0;
         end if;
      else
         --  Signal is below THRESHOLD value, we search for the next Pic
         --  Protection against Hythereis
         if Clean_Sample < (THRESHOLD - 50) then
            Pic_On_Pending       := False;
         end if;
      end if;

   end Update_Heart_Rate;

end ECG.DSP.Heart_Rate_Algorithms;