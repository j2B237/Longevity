--  @File : led.ads
--  @Author : Yossep BINYOUM
--  @Brief : Simple implementation of LED component

package LED is 
   pragma Preelaborate;
   
   procedure Init;
   procedure On;
   procedure Off;
   procedure Toggle;

private
   pragma Inline (Init);
   pragma Inline (On);
   pragma Inline (Off);
end LED;