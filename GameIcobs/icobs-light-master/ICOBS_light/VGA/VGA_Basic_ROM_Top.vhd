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
              btnU,btnD,btnL,btnC  : IN STD_LOGIC;
              --sw : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
              vgaRed : OUT vector4;
              vgaGreen : OUT vector4;
              vgaBlue : OUT vector4
       );
END VGA_Basic_ROM_Top;

ARCHITECTURE Behavioral OF VGA_Basic_ROM_Top IS

       SIGNAL rst, clk100,clk25, vidon : STD_LOGIC;
       SIGNAL hc, vc : vector10;
       SIGNAL M : STD_LOGIC_VECTOR (11 DOWNTO 0);
       SIGNAL addr : vector16;
       SIGNAL R1,C1 : unsigned(9 downto 0);
BEGIN
    U1 : ENTITY work.VGA_Clock PORT MAP (mclk => clk, reset => rst,clk25 => clk25);
    U2 : ENTITY work.VGA_640_x_480 PORT MAP (rst => rst, clk => clk25, hsync => Hsync, vsync => Vsync, hc => hc, vc => vc, vidon => vidon);
    U3 : ENTITY work.VGA_Basic_ROM PORT MAP (vidon => vidon, hc => hc, vc => vc, R1=>R1, C1 =>C1, M => M, rom_addr4 => addr, red => vgaRed, green => vgaGreen, blue => vgaBlue);
    U4 : ENTITY work.prom_sprite port map(clka => clk25,addra => addr, douta => M );
    U5 : ENTITY work.VGA_Clock100hz generic map (N => 19)  port map(clk_in => clk,rst => rst, clk_out => clk100 );
    U6 : ENTITY work.Mover_A port map(clk => clk100, rst => rst, R1 => R1, C1 => C1,btnD => btnD, btnU => btnU, btnL => btnL, btnR => btnR);
    --U4 : ENTITY work.Basic_ROM PORT MAP (addr => addr, M => M);
       rst <= btnC;

END Behavioral;