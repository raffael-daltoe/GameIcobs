library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_Basic_ROM_Top IS
       PORT (
              clk : IN STD_LOGIC;
              btnR : IN STD_LOGIC;
              Hsync : OUT STD_LOGIC;
              Vsync : OUT STD_LOGIC;
              sw : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
              vgaRed : OUT vector4;
              vgaGreen : OUT vector4;
              vgaBlue : OUT vector4
       );
END VGA_Basic_ROM_Top;

ARCHITECTURE Behavioral OF VGA_Basic_ROM_Top IS

       SIGNAL rst, clk25, vidon : STD_LOGIC;
       SIGNAL hc, vc : vector10;
       SIGNAL M : STD_LOGIC_VECTOR (11 DOWNTO 0);
       SIGNAL addr : vector4;
BEGIN
    U1 : ENTITY work.VGA_Clock PORT MAP (mclk => clk, reset => rst, clk25 => clk25);
    U2 : ENTITY work.VGA_640_x_480 PORT MAP (rst => rst, clk => clk25, hsync => Hsync, vsync => Vsync, hc => hc, vc => vc, vidon => vidon);
    U3 : ENTITY work.VGA_Basic_ROM PORT MAP (vidon => vidon, hc => hc, vc => vc, sw => sw, M => M, rom_addr4 => addr, red => vgaRed, green => vgaGreen, blue => vgaBlue);
    U4 : ENTITY work.Basic_ROM PORT MAP (addr => addr, M => M);

       rst <= btnR;

END Behavioral;