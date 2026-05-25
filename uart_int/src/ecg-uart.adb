package body ECG.UART is

   --------------
   --   Init   --
   --------------

   procedure Init (Baud_Divider : Serial_Speed;
                   Double_Speed : Boolean := False;
                   Mode : UART_Mode_Kind := polled) is

   begin
      -- Configuration UART (Transmission activée)
      MCU.UBRR0H := Interfaces.Unsigned_8 (Baud_Divider / 256);
      MCU.UBRR0L := Interfaces.Unsigned_8 (Baud_Divider mod 256);
      MCU.UCSR0C := 2#00000110#;          -- 8 bit data transmission (UCSZ01 = 1 and UCSZ00 = 1)

      if Mode = polled then
         --  Enable receiver and transmitter
         MCU.UCSR0B := MCU.UCSR0B or (MCU.TXEN0_Mask or MCU.RXEN0_Mask);
      else
         --  Enable receiver, transmitter and interruption on receiver
         MCU.UCSR0B := MCU.UCSR0B or (MCU.TXEN0_Mask or MCU.RXEN0_Mask or AVR.MCU.RXCIE0_Mask);
      end if;
   end Init;

   --------------
   --  Put_Raw --
   --------------

   procedure Put_Raw (Data : Interfaces.Unsigned_8) is
   begin
      -- wait until Data Register Empty (DRE) is signaled
      while (MCU.UCSR0A and MCU.UDRE0_Mask) = 0 loop null; end loop;
      MCU.UDR0 := Data;
   end Put_Raw;

   ----------------
   --  Put_Char  --
   ----------------

   procedure Put_Char (C : Character) is
   begin
      Put_Raw (Character'Pos (C));
   end Put_Char;

   -----------------
   --   New_Line  --
   -----------------

   procedure New_Line is
      EOL : constant := 16#0A#;
   begin
      Put_Raw (EOL);
   end New_Line;

   -----------
   --  CRLF --
   -----------

   procedure CRLF is
      LF : constant := 16#0A#;
      CR : constant := 16#0D#;
   begin
      Put_Raw (LF);
      Put_Raw (CR);
   end CRLF;

   -----------
   --  Put  --
   -----------

   procedure Put (S : AVR_String) is
   begin
      for I in S'Range loop
         Put_Char (S (I));
      end loop;
   end Put;

   ----------------
   --  Put_Line  --
   ----------------

   procedure Put_Line (S : AVR_String) is
   begin
      Put (S);
      New_Line;
   end Put_Line;

   ------------------
   --   Put_UInt8  --
   ------------------

   procedure Put_UInt8 (Data : Interfaces.Unsigned_8) is
      Value         : Interfaces.Unsigned_8 := Data;
      D100, D10     : Interfaces.Unsigned_8 := 0;
      Started       : Boolean := False;
   begin
      -- 1. Extraction des centaines par soustractions successives (max 255)
      while Value >= 100 loop
         D100 := D100 + 1;
         Value     := Value - 100;
      end loop;

      -- 2. Extraction des dizaines
      while Value >= 10 loop
         D10 := D10 + 1;
         Value    := Value - 10;
      end loop;

      -- 3. Affichage des centaines (uniquement si > 0)
      if D100 > 0 then
         Put_Char (Character'Val (48 + D100));            -- 48 est le code ASCII pour '0'
         Started := True;
      end if;

      -- 4. Affichage des dizaines (si > 0 ou si un chiffre a déjà été affiché avant)
      if D10 > 0 or Started then
         Put_Char (Character'Val (48 + D10));
      end if;

      -- 5. Affichage des unités (toujours affichées, même si c'est un zéro seul)
      Put_Char (Character'Val (48 + Value));

   end Put_UInt8;

   --------------------
   --   Put_UInt16   --
   --------------------

   procedure Put_UInt16 (Data : Interfaces.Unsigned_16) is
      V                    : Interfaces.Unsigned_16 := Data;
      D1000, D100, D10, D1 : Interfaces.Unsigned_16 := 0;
      Started              : Boolean := False;
   begin
      -- Décomposition simple sans division lourde si possible, ou division classique :
      D1000 := V / 1000; V := V mod 1000;
      D100  := V / 100;  V := V mod 100;
      D10   := V / 10;
      D1    := V mod 10;

      if D1000 > 0 then
         Put_Char (Character'Val (48 + D1000)); Started := True;
      end if;
      if D100 > 0 or Started then
         Put_Char (Character'Val (48 + D100));  Started := True;
      end if;
      if D10 > 0 or Started then
         Put_Char (Character'Val (48 + D10));
      end if;
      Put_Char (Character'Val (48 + D1));
   end Put_UInt16;


end ECG.UART;