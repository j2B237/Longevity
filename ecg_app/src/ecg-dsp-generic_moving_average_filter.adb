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


   ---------------
   --   Update  --
   ---------------

   procedure Update (New_Sample : Interfaces.Unsigned_16; 
                     Clean_Sample : out Interfaces.Unsigned_16) is

      --  Get the old value from the filter array
      Old_Sample : Interfaces.Unsigned_16 := 
                  Filter.Readings (Filter.ReadingIndex);
   begin
      --  Remove the old value before overriding
      Filter.Total := @ - Interfaces.Unsigned_32 (Old_Sample);

      --  Store the new value at current index
      Filter.Readings (Filter.ReadingIndex) := New_Sample;

      --  Update total with the new value
      Filter.Total := @ + Interfaces.Unsigned_32 (New_Sample);

      --  Move to next elements
      Filter.ReadingIndex := @ + 1;
      if Filter.ReadingIndex >= Size then
         Filter.ReadingIndex := 0;
      end if;

      Filter.Average := Interfaces.Unsigned_16 (
                        Filter.Total / Interfaces.Unsigned_32 (Size)
                     );
      Clean_Sample := Filter.Average;

   end Update;

end ECG.DSP.Generic_Moving_Average_Filter;