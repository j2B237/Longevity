package body ECG.DSP.Generic_Moving_Average_Filter is

   -------------------
   --  Init_Filter  --
   -------------------

   procedure Init_Filter is
   begin
      for I in 0 .. Size - 1 loop
         Filter.Readings (I) := 0;
      end loop;
   end Init_Filter;


   --------------------
   --  Reset_Filter  --
   --------------------

   procedure Reset_filter is
   begin
   
      Init_Filter;

      Filter.ReadingIndex  := 0;
      Filter.Total         := 0;
      Filter.Average       := 0;
   end Reset_filter;


   --------------
   --  Apply  --
   -------------

   function Apply (Input : Interfaces.Integer_32)
      return Interfaces.Integer_32
   is  
      --  Get the old value from the filter array
      Old_Sample : Interfaces.Integer_32 := 
                  Filter.Readings (Filter.ReadingIndex);
   begin
      --  Remove the old value before overriding
      Filter.Total := @ - Old_Sample;

      --  Store the new value at current index
      Filter.Readings (Filter.ReadingIndex) := Input;

      --  Update total with the new value
      Filter.Total := @ + Input;

      --  Move to next elements
      Filter.ReadingIndex := @ + 1;
      if Filter.ReadingIndex >= Size then
         Filter.ReadingIndex := 0;
      end if;

      Filter.Average := Filter.Total / Interfaces.Integer_32 (Size);
      return Filter.Average;
   end Apply;
   

end ECG.DSP.Generic_Moving_Average_Filter;