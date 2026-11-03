--  Irlmaier Simulation core: terrain grid and map rendering.
with System;
package Irl is
   Max_W : constant := 640;
   Max_H : constant := 400;
   function Grid_Addr return System.Address;
   pragma Export (C, Grid_Addr, "irl_grid");
   function Image_Addr return System.Address;
   pragma Export (C, Image_Addr, "irl_image");
   procedure Init (W, H : Integer);
   pragma Export (C, Init, "irl_init");
   procedure Render;
   pragma Export (C, Render, "irl_render");
   function Height_At (X, Y : Integer) return Integer;
   pragma Export (C, Height_At, "irl_height");
   function Version return Integer;  --  e.g. 200 = 0.2.0
   pragma Export (C, Version, "irl_version");
end Irl;
