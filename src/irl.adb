with Interfaces; use Interfaces;
package body Irl is
   type Grid_T is array (0 .. Max_W * Max_H - 1) of Integer_16;
   type Img_T is array (0 .. Max_W * Max_H - 1) of Unsigned_32;
   Grid : Grid_T := (others => 0);
   Img  : Img_T := (others => 0);
   GW, GH : Integer := 1;

   function Grid_Addr return System.Address is (Grid'Address);
   function Image_Addr return System.Address is (Img'Address);
   function Version return Integer is (200);

   procedure Init (W, H : Integer) is
   begin
      GW := Integer'Max (1, Integer'Min (W, Max_W));
      GH := Integer'Max (1, Integer'Min (H, Max_H));
   end Init;

   function Height_At (X, Y : Integer) return Integer is
   begin
      if X < 0 or else Y < 0 or else X >= GW or else Y >= GH then
         return 0;
      end if;
      return Integer (Grid (Y * GW + X));
   end Height_At;

   function Clamp (V : Float) return Unsigned_32 is
     (if V < 0.0 then 0 elsif V > 255.0 then 255 else Unsigned_32 (V));

   function Lerp (A, B, T : Float) return Float is (A + (B - A) * T);

   --  RGBA packed little-endian (R in low byte) for ImageData
   function Pack (R, G, B : Float) return Unsigned_32 is
     (Clamp (R) or Shift_Left (Clamp (G), 8) or Shift_Left (Clamp (B), 16)
      or 16#FF00_0000#);

   procedure Render is
      H, HE, HN : Float;
      R, G, B, T, Shade : Float;
   begin
      for Y in 0 .. GH - 1 loop
         for X in 0 .. GW - 1 loop
            H := Float (Height_At (X, Y));
            if H <= 0.0 then
               --  sea: light shelf blue to deep blue
               T := Float'Min (1.0, -H / 400.0);
               R := Lerp (120.0, 15.0, T);
               G := Lerp (175.0, 50.0, T);
               B := Lerp (215.0, 120.0, T);
            else
               T := Float'Min (1.0, H / 800.0);
               if T < 0.25 then
                  R := Lerp (90.0, 150.0, T * 4.0);
                  G := Lerp (140.0, 165.0, T * 4.0);
                  B := Lerp (70.0, 90.0, T * 4.0);
               else
                  R := Lerp (150.0, 140.0, (T - 0.25) / 0.75);
                  G := Lerp (165.0, 110.0, (T - 0.25) / 0.75);
                  B := Lerp (90.0, 80.0, (T - 0.25) / 0.75);
               end if;
               --  hillshade from north-west
               HE := Float (Height_At (Integer'Min (X + 1, GW - 1), Y));
               HN := Float (Height_At (X, Integer'Max (Y - 1, 0)));
               Shade := 1.0 + Float'Max (-0.35,
                          Float'Min (0.35, ((H - HE) + (HN - H)) / 120.0));
               R := R * Shade; G := G * Shade; B := B * Shade;
            end if;
            Img (Y * GW + X) := Pack (R, G, B);
         end loop;
      end loop;
   end Render;
end Irl;
