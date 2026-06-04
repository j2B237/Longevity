--  @File : led.ads
--  @Author : Yossep BINYOUM
--  @Brief : Simple implementation of LED component

package LED is 
   procedure Init;
   procedure On;
   procedure Off;

private
   pragma Inline (Init);
   pragma Inline (On);
   pragma Inline (Off);
end LED;