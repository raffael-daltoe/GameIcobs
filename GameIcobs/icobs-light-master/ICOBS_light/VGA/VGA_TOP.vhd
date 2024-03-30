library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_TOP IS
       PORT (
              clk         : IN STD_LOGIC;
              btnC        : in std_logic;

              Hsync       : OUT STD_LOGIC;
              Vsync       : OUT STD_LOGIC;
              
              R0          : STD_LOGIC_VECTOR(9 downto 0);
              C0          : STD_LOGIC_VECTOR(9 downto 0);
              R1          : STD_LOGIC_VECTOR(9 downto 0);
              C1          : STD_LOGIC_VECTOR(9 downto 0);
              R2          : STD_LOGIC_VECTOR(9 downto 0);
              C2          : STD_LOGIC_VECTOR(9 downto 0);
              R3          : STD_LOGIC_VECTOR(9 downto 0);
              C3          : STD_LOGIC_VECTOR(9 downto 0);
              R4          : STD_LOGIC_VECTOR(9 downto 0);
              C4          : STD_LOGIC_VECTOR(9 downto 0);
              R5          : STD_LOGIC_VECTOR(9 downto 0);
              C5          : STD_LOGIC_VECTOR(9 downto 0);

              sw          : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
              vgaRed      : OUT vector4;
              vgaGreen    : OUT vector4;
              vgaBlue     : OUT vector4
       );
END VGA_TOP;

ARCHITECTURE Behavioral OF VGA_TOP IS

       SIGNAL rst, clk100,clk25, vidon : STD_LOGIC;
       SIGNAL hc, vc : vector10;

       -- SIGNALS OF REGISTERS
       SIGNAL R0_s                   : unsigned(9 downto 0);
       SIGNAL C0_s                   : unsigned(9 downto 0);
       SIGNAL R1_s                   : unsigned(9 downto 0);
       SIGNAL C1_s                   : unsigned(9 downto 0);
       SIGNAL R2_s                   : unsigned(9 downto 0);
       SIGNAL C2_s                   : unsigned(9 downto 0);
       SIGNAL R3_s                   : unsigned(9 downto 0);
       SIGNAL C3_s                   : unsigned(9 downto 0);
       SIGNAL R4_s                   : unsigned(9 downto 0);
       SIGNAL C4_s                   : unsigned(9 downto 0);
       SIGNAL R5_s                   : unsigned(9 downto 0);
       SIGNAL C5_s                   : unsigned(9 downto 0);     
       
       -- SIGNALS OF Memory OUTPUT PROM
       SIGNAL M_map_s                : vector12;   
       SIGNAL M_pacman_s             : vector12;
       --SIGNAL M_ghost1_s             : vector12;

       -- SIGNALS OF Memory INPUT PROM             
       --SIGNAL addr_ghost1_s          : vector11;
       SIGNAL addr_pacman_s          : vector11;
       SIGNAL addr_map_s             : vector16;              


BEGIN
    
    -- PORT MAPS OF THE PROM SPRITES

    U_MAP : ENTITY work.prom_map 
    port map (clka          =>     clk25, 
              addra         =>     addr_map_s, 
              douta         =>     M_map_s);

--     U_GHOST1: ENTITY work.prom_ghost1_blue 
--     port map(clka           =>     clk25, 
--               addra         =>     addr_ghost1_s, 
--               douta         =>     M_ghost1_s);

    U_PACMAN: ENTITY work.prom_pacman 
    port map (clka          =>     clk25, 
              addra         =>     addr_pacman_s, 
              douta         =>     M_pacman_s);


    -- PORT MAPS OF CLOCK, AND VSYNC/HSYNC
    U1 : ENTITY work.VGA_Clock 
    PORT MAP (mclk          =>     clk, 
              reset         =>     rst,
              clk25         =>     clk25);

    U2 : ENTITY work.VGA_640_x_480 
    PORT MAP (rst           =>     rst, 
              clk           =>     clk25, 
              hsync         =>     Hsync, 
              vsync         =>     Vsync, 
              hc            =>     hc, 
              vc            =>     vc, 
              vidon         =>     vidon);

           
    U5 : ENTITY work.VGA_Clock100hz 
    generic map (N => 19)  
    port map(clk_in         =>      clk,
             rst            =>      rst, 
             clk_out        =>      clk100);

--    U6: ENTITY work.Map_Replicator
--    port map(
--       clka                 =>      clk25,
--       addra                =>      addr_map_s,
--       douta                =>      M_map_s
--    );

    -- CONNECTION WITH THE ROM AND SENDING TO OUTPUT OF THIS MODULE
    U3 : ENTITY work.VGA_Basic_ROM 
    PORT MAP (vidon         =>      vidon, 
              hc            =>      hc,     
              vc            =>      vc, 
              
              -- CONNECTION WITH THE REGISTERS 
              R_SW0         =>      R0_s,      
              C_SW0         =>      C0_s,

              R_SW1         =>      R1_s,
              C_SW1         =>      C1_s,

              R_SW2         =>      R2_s,
              C_SW2         =>      C2_s,

              R_SW3         =>      R3_s,
              C_SW3         =>      C3_s,

              R_SW4         =>      R4_s,
              C_SW4         =>      C4_s,

              R_SW5         =>      R5_s,
              C_SW5         =>      C5_s,


              -- CONNECTION WITH Memory OUTPUT PROM
              M_map_ROM         =>      M_map_s,
              M_pacman_ROM      =>      M_pacman_s,
              --M_ghost1_ROM      =>      M_ghost1_s,

              
              -- CONNECTION WITH Memory INPUT PROM   
              --addr_ghost1_ROM   =>      addr_ghost1_s,
              addr_pacman_ROM   =>      addr_pacman_s,
              addr_map_ROM      =>      addr_map_s,

              red               =>      vgaRed, 
              green             =>      vgaGreen, 
              blue              =>      vgaBlue, 
              sw                =>      sw);



    -- TAKING VALUE OF THE REGISTERS AND RESET

    rst <= btnC;


    R0_s <= to_unsigned(to_integer(unsigned(R0)), R0'length); 
    C0_s <= to_unsigned(to_integer(unsigned(C0)), C0'length); 
    R1_s <= to_unsigned(to_integer(unsigned(R1)), R1'length); 
    C1_s <= to_unsigned(to_integer(unsigned(C1)), C1'length); 
    R2_s <= to_unsigned(to_integer(unsigned(R2)), R2'length); 
    C2_s <= to_unsigned(to_integer(unsigned(C2)), C2'length); 
    R3_s <= to_unsigned(to_integer(unsigned(R3)), R3'length); 
    C3_s <= to_unsigned(to_integer(unsigned(C3)), C3'length); 
    R4_s <= to_unsigned(to_integer(unsigned(R4)), R4'length); 
    C4_s <= to_unsigned(to_integer(unsigned(C4)), C4'length); 
    R5_s <= to_unsigned(to_integer(unsigned(R5)), R5'length); 
    C5_s <= to_unsigned(to_integer(unsigned(C5)), C5'length); 
    
END Behavioral;