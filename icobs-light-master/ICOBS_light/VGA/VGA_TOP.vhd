library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_TOP IS
       PORT (
              clk : IN STD_LOGIC;
              --btnR : IN STD_LOGIC;
              Hsync : OUT STD_LOGIC;
              Vsync : OUT STD_LOGIC;
              --btnU,btnD,btnL,btnC  : IN STD_LOGIC;
              btnC  : in std_logic;
              Y_IN  : in std_logic_vector(9 downto 0);
              X_IN  : in std_logic_vector(9 downto 0);

              X2_IN  :  in std_logic_vector(9 downto 0);
              Y2_IN  : in std_logic_vector(9 downto 0);

              sw : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
              vgaRed : OUT vector4;
              vgaGreen : OUT vector4;
              vgaBlue : OUT vector4
       );
END VGA_TOP;

ARCHITECTURE Behavioral OF VGA_TOP IS

       SIGNAL rst, clk100,clk25, vidon : STD_LOGIC;
       SIGNAL hc, vc : vector10;
       SIGNAL M,M_2_sprite : STD_LOGIC_VECTOR (11 DOWNTO 0);
       --SIGNAL addr,addr_2_sprite : vector16;
       signal addr, addr_2_sprite : std_logic_vector(12 downto 0);
       SIGNAL R1,C1,R2,C2 : unsigned(9 downto 0);
       signal X1_TOP, Y1_TOP : unsigned(9 downto 0);
       signal X2_TOP, Y2_TOP : unsigned(9 downto 0);
       
BEGIN
    U1 : ENTITY work.VGA_Clock PORT MAP (mclk => clk, reset => rst,clk25 => clk25);
    U2 : ENTITY work.VGA_640_x_480 PORT MAP (rst => rst, clk => clk25, hsync => Hsync, vsync => Vsync, hc => hc, vc => vc, vidon => vidon);
    U3 : ENTITY work.VGA_Basic_ROM PORT MAP (vidon => vidon, hc => hc, vc => vc, 
                                                R1=>R1, C1 =>C1, M => M, rom_addr4 => addr, 
                                                
                                                M_2_sprite => M_2_sprite ,
                                                rom_addr4_2_sprite => addr_2_sprite,
                                                R2 => R2 , C2 => C2,
                                                
                                                red => vgaRed, green => vgaGreen, blue => vgaBlue, 
                                                sw => sw);
    
    
    U4 : ENTITY work.prom_sprite port map(clka => clk25,addra => addr, douta => M );  -- crash 80x90 | 7200
    U5 : ENTITY work.VGA_Clock100hz generic map (N => 19)  port map(clk_in => clk,rst => rst, clk_out => clk100 );
    U6 : ENTITY work.Mover_A port map( X_IN => X1_TOP , Y_IN => Y1_TOP, C1 => C1 , R1 => R1);
    U7 : ENTITY work.prom_sprite2 port map(clka => clk25, addra => addr_2_sprite , douta => M_2_sprite);   -- crazy 101x72 | 7272
    U8 : ENTITY work.Mover_A port map( X_IN => X2_TOP , Y_IN => Y2_TOP , C1 => C2 , R1 => R2);


    --U6 : ENTITY work.Mover_A port map(clk => clk100, rst => rst, R1 => R1, C1 => C1,btnD => btnD, btnU => btnU, btnL => btnL, btnR => btnR);
    --U4 : ENTITY work.Basic_ROM PORT MAP (addr => addr, M => M);
    rst <= btnC;
    X1_TOP <= to_unsigned(to_integer(unsigned(X_IN)), X_IN'length);
    Y1_TOP <= to_unsigned(to_integer(unsigned(Y_IN)), X_IN'length);
    
    X2_TOP <= to_unsigned(to_integer(unsigned(X2_IN)), X2_IN'length);
    Y2_TOP <= to_unsigned(to_integer(unsigned(Y2_IN)), Y2_IN'length);
END Behavioral;