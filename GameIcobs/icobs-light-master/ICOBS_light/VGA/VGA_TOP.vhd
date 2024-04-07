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
              
              R0          : IN STD_LOGIC_VECTOR(9 downto 0);
              C0          : IN STD_LOGIC_VECTOR(9 downto 0);
              R1          : IN STD_LOGIC_VECTOR(9 downto 0);
              C1          : IN STD_LOGIC_VECTOR(9 downto 0);
              R2          : IN STD_LOGIC_VECTOR(9 downto 0);
              C2          : IN STD_LOGIC_VECTOR(9 downto 0);
              R3          : IN STD_LOGIC_VECTOR(9 downto 0);
              C3          : IN STD_LOGIC_VECTOR(9 downto 0);
              R4          : IN STD_LOGIC_VECTOR(9 downto 0);
              C4          : IN STD_LOGIC_VECTOR(9 downto 0);
              
              Winner      : IN STD_LOGIC;
              Loser       : IN STD_LOGIC;

              Register_Foods_S : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              
              sw          : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
              vgaRed      : OUT vector4;
              vgaGreen    : OUT vector4;
              vgaBlue     : OUT vector4

       );
END VGA_TOP;

ARCHITECTURE Behavioral OF VGA_TOP IS

       SIGNAL rst, clk100,clk25, vidon,changePacman_s : STD_LOGIC;
       SIGNAL hc, vc : vector10;

       -- SIGNALS OF REGISTERS
       SIGNAL R0_s                   : unsigned(9 downto 0);            -- movement of pacman
       SIGNAL C0_s                   : unsigned(9 downto 0);            -- movement of pacman
       SIGNAL R1_s                   : unsigned(9 downto 0);            -- control of type of pacman
       SIGNAL C1_s                   : unsigned(9 downto 0);            -- nothing  
       SIGNAL R2_s                   : unsigned(9 downto 0);
       SIGNAL C2_s                   : unsigned(9 downto 0);
       SIGNAL R3_s                   : unsigned(9 downto 0);
       SIGNAL C3_s                   : unsigned(9 downto 0);
       SIGNAL R4_s                   : unsigned(9 downto 0);
       SIGNAL C4_s                   : unsigned(9 downto 0);
      -- SIGNAL R5_s                   : unsigned(9 downto 0);
      -- SIGNAL C5_s                   : unsigned(9 downto 0);     
      SIGNAL winner_s                : STD_LOGIC;
      SIGNAL loser_s                 : STD_LOGIC;
       
       -- SIGNALS OF Memory OUTPUT PROM
       SIGNAL M_map_s                      : vector12;   -- 12 bits
       SIGNAL M_pacmanOpened_s             : vector12;   -- 12 bits
       SIGNAL M_pacmanClosed_s             : vector12;   -- 12 bits
       SIGNAL M_Ghost_s                    : vector12;   -- 12 bits
       SIGNAL M_food_s                     : vector12;   -- 12 bits
       SIGNAL M_loser_s                    : vector12;   -- 12 bits
       SIGNAL M_winner_s                   : vector12;   -- 12 bits
       
       
       -- SIGNALS OF Memory INPUT PROM             
       SIGNAL addr_pacmanOpened_s          : vector10;  -- 11 bits
       SIGNAL addr_pacmanClosed_s          : vector10;  -- 11 bits
       SIGNAL addr_Ghost                   : vector10;  -- 10 bits     
       SIGNAL addr_map_s                   : vector16;  -- 16 bits           
       SIGNAL addr_food_s                  : vector7;   -- 7 bits
       SIGNAL addr_loser_s                 : vector12;
       SIGNAL addr_winner_s                : vector11;

BEGIN
    
    -- PORT MAPS OF THE PROM SPRITES

    U_MAP : ENTITY work.prom_map 
    port map (clka          =>     clk25, 
              addra         =>     addr_map_s, 
              douta         =>     M_map_s);

     U_GHOST1: ENTITY work.prom_ghost
     port map(clka          =>     clk25, 
              addra         =>     addr_Ghost, 
              douta         =>     M_Ghost_s);

    U_PACMANClosed: ENTITY work.prom_pacmanClosed
    port map (clka          =>     clk25, 
              addra         =>     addr_pacmanClosed_s, 
              douta         =>     M_pacmanClosed_s);

    U_PACMANOpened: ENTITY work.prom_pacmanOpened
    port map (clka          =>     clk25, 
              addra         =>     addr_pacmanOpened_s, 
              douta         =>     M_pacmanOpened_s);
              
    U_Food: ENTITY work.prom_addr_food_s
    port map (clka          =>     clk25, 
              addra         =>     addr_food_s, 
              douta         =>     M_food_s);
    
    U_Winner: ENTITY work.prom_winner
    port map (clka          =>     clk25, 
              addra         =>     addr_winner_s, 
              douta         =>     M_winner_s);

    U_Loser: ENTITY work.prom_loser
    port map (clka          =>     clk25, 
              addra         =>     addr_loser_s, 
              douta         =>     M_loser_s);


    -- PORT MAPS OF CLOCK, AND VSYNC/HSYNC
    U1 : ENTITY work.VGA_Clock 
    PORT MAP (mclk          =>     clk, 
              reset         =>     rst,
              clk25         =>     clk25);
    
    U6: ENTITY work.Pacman_Clock
    PORT MAP(clk_50mhz      => clk,
           rst              => rst,
           clk_1hz          => changePacman_s            
    );


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


    -- CONNECTION WITH THE ROM AND SENDING TO OUTPUT OF THIS MODULE
    U3 : ENTITY work.VGA_Basic_ROM 
    PORT MAP (vidon         =>      vidon, 
              hc            =>      hc,     
              vc            =>      vc, 
              changePacman  =>      changePacman_s,

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

              Register_Foods          =>      Register_Foods_S,
--              R_SW5         =>      R5_s,
--              C_SW5         =>      C5_s,


              -- CONNECTION WITH Memory OUTPUT PROM
              romMap               =>      M_map_s,
              romPacmanClosed      =>      M_pacmanClosed_s,
              romPacmanOpened      =>      M_pacmanOpened_s,
              romGhost             =>      M_Ghost_s,
              romFood              =>      M_food_s,
              romLoser             =>      M_loser_s,
              romWinner            =>      M_winner_s,
              
              -- CONNECTION WITH Memory INPUT PROM
              romAddressMap            =>  addr_map_s,
              romAddressPacmanClosed   =>  addr_pacmanClosed_s,
              romAddressPacmanOpened   =>  addr_pacmanOpened_s,
              romAddressGhost          =>  addr_Ghost,
              romAddressFood           =>  addr_food_s,            
              romAddressLoser          =>  addr_loser_s, 
              romAddressWinner         =>  addr_winner_s,

              win               => winner_s,        
              lose              => loser_s,

              red               =>      vgaRed, 
              green             =>      vgaGreen, 
              blue              =>      vgaBlue, 
              sw                =>      sw);



    -- TAKING VALUE OF THE REGISTERS AND RESET

    rst <= btnC;


    R0_s      <= to_unsigned(to_integer(unsigned(R0)), R0'length); 
    C0_s      <= to_unsigned(to_integer(unsigned(C0)), C0'length); 
    R1_s      <= to_unsigned(to_integer(unsigned(R1)), R1'length); 
    C1_s      <= to_unsigned(to_integer(unsigned(C1)), C1'length); 
    R2_s      <= to_unsigned(to_integer(unsigned(R2)), R2'length); 
    C2_s      <= to_unsigned(to_integer(unsigned(C2)), C2'length); 
    R3_s      <= to_unsigned(to_integer(unsigned(R3)), R3'length); 
    C3_s      <= to_unsigned(to_integer(unsigned(C3)), C3'length); 
    R4_s      <= to_unsigned(to_integer(unsigned(R4)), R4'length); 
    C4_s      <= to_unsigned(to_integer(unsigned(C4)), C4'length);  
    loser_s   <= Loser; 
    winner_s  <= Winner;
    
    
END Behavioral;