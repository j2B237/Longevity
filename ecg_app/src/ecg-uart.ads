with AVR;
with AVR.MCU;
with AVR.Strings;
with Interfaces;

package ECG.UART is

   pragma Preelaborate;

   use AVR;
   use Interfaces;
   use AVR.Strings;

   type Serial_Speed is new Unsigned_16;
   
   Baud_1200_1MHz    : constant Serial_Speed := 51;
   Baud_4800_1MHz    : constant Serial_Speed := 12;
   Baud_9600_1MHz    : constant Serial_Speed := 12;         -- U2XN = 1 (Double speed mode)
   
   Baud_2400_4MHz    : constant Serial_Speed := 103;
   Baud_4800_4MHz    : constant Serial_Speed := 51;
   Baud_19200_4MHz   : constant Serial_Speed := 12;

   Baud_4800_8MHz    : constant Serial_Speed := 103;
   Baud_9600_8MHz    : constant Serial_Speed := 51;
   Baud_19200_8MHz   : constant Serial_Speed := 25;
   Baud_38400_8MHz   : constant Serial_Speed := 12;

   Baud_4800_12MHz   : constant Serial_Speed := 155;
   Baud_9600_12MHz   : constant Serial_Speed := 77;
   Baud_19200_12MHz  : constant Serial_Speed := 38;
   Baud_57600_12MHz  : constant Serial_Speed := 12;


   -- 14.7456MHz crystal gives 0.0% error rate for 115200bps
   Baud_115200_14_7MHz : constant Serial_Speed := 7;  -- error = 0.0%

   Baud_9600_16MHz   : constant Serial_Speed := 103;
   Baud_19200_16MHz  : constant Serial_Speed := 51;
   Baud_38400_16MHz  : constant Serial_Speed := 25;
   Baud_57600_16MHz  : constant Serial_Speed := 16; -- error = 2.1%
   Baud_76800_16MHz  : constant Serial_Speed := 12;
   Baud_115200_16MHz : constant Serial_Speed := 8;  -- error = 3.7%

   Baud_9600_20MHz   : constant Serial_Speed := 129;
   Baud_19200_20MHz  : constant Serial_Speed := 64;
   Baud_38400_20MHz  : constant Serial_Speed := 32; -- error = 1.4%
   Baud_76800_20MHz  : constant Serial_Speed := 15; -- error = 1.7%
   Baud_115200_20MHz : constant Serial_Speed := 10; -- error = 1.4%

   --  initialize the registers, internal clock and baud rate generator
   procedure Init (Baud_Divider : Serial_Speed;
                   Double_Speed : Boolean := False;
                   Mode : UART_Mode_Kind := polled);
   
   --  Output routines
   procedure Put_Char (C : Character);
   procedure New_Line;
   procedure CRLF;                                    --  DOS like CR & LF
   procedure Put_Line (S : AVR_String);
   procedure Put_UInt8 (Data : Interfaces.Unsigned_8);
   procedure Put_UInt16 (Data : Interfaces.Unsigned_16);


end ECG.UART;