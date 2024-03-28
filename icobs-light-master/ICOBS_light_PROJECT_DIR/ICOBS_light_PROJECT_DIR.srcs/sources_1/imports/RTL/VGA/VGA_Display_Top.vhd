
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.packages.all;
entity VGA_Display_Top is
    Port ( clk : in  STD_LOGIC;
           btnR : in  STD_LOGIC;
           Hsync : out  STD_LOGIC;
           Vsync : out  STD_LOGIC;
           sw: in  STD_LOGIC_VECTOR (11 downto 0);
           vgaRed : out  vector4;
           vgaGreen : out  vector4;
           vgaBlue : out  vector4);
end VGA_Display_Top;

architecture Behavioral of VGA_Display_Top is

signal rst, clk25, vidon: std_logic;
signal hc, vc: vector10;


begin

rst <= btnR;

U1: entity work.VGA_Clock port map ( mclk => clk, reset => rst, clk25=> clk25);
U2: entity work.VGA_640_x_480 port map ( rst => rst, clk => clk25, hsync => Hsync, vsync => Vsync, hc => hc, vc => vc, vidon => vidon);
U3: entity work.VGA_Display port map ( vidon => vidon, hc => hc, vc => vc, sw => sw, red => vgaRed, green => vgaGreen, blue => vgaBlue);

end Behavioral;

