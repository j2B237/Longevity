--  @File : button.ads
--  @Author : Yossep BINYOUM
--  @Brief : Basic implementation for a psuh Button 
--  We use polling mode to capture even.


package BUTTON is 
   procedure Init;
   function IsButtonPressed return Boolean;
private
   pragma Inline (Init);
   pragma Inline (IsButtonPressed);
end BUTTON;