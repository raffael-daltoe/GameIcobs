library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_Basic_ROM IS
    PORT (
        vidon : IN STD_LOGIC;
        hc : IN vector10;
        vc : IN vector10;
        sw : IN vector12; 

        -- REGISTERS WHERE ONLY THE SW IMPLEMENTATION CHANGE
        R_SW0           : in unsigned(9 downto 0);
        C_SW0           : in unsigned(9 downto 0);

        R_SW1           : in unsigned(9 downto 0);
        C_SW1           : in unsigned(9 downto 0);

        R_SW2           : in unsigned(9 downto 0);
        C_SW2           : in unsigned(9 downto 0);

        R_SW3           : in unsigned(9 downto 0);
        C_SW3           : in unsigned(9 downto 0);

        R_SW4           : in unsigned(9 downto 0);
        C_SW4           : in unsigned(9 downto 0);

        R_SW5           : in unsigned(9 downto 0);
        C_SW5           : in unsigned(9 downto 0);
                
        -- CONNECTION WITH Memory INPUT PROM   
        --addr_ghost1_ROM : out vector11;
        addr_pacman_ROM : out vector11;
        addr_map_ROM    : out vector16;

        -- CONNECTION WITH Memory OUTPUT PROM
        M_map_ROM       : in vector12;
        M_pacman_ROM    : in vector12;    
        --M_ghost1_ROM    : in vector12;

        red : OUT vector4;
        green : OUT vector4;
        blue : OUT vector4);
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS
    CONSTANT hbp : unsigned(9 DOWNTO 0) := "0010010000"; -- horizontal back porch = 128 + 16 = 144 ou 96 + 48
    CONSTANT vbp : unsigned(9 DOWNTO 0) := "0000011111"; -- vertical back porch = 2 + 29 = 31

    -- CONSTANTS OF WEIGHT AND HEIGHT
    CONSTANT W0 : unsigned(9 DOWNTO 0) := to_unsigned(45,10); -- PACMAN
    CONSTANT H0 : unsigned(9 DOWNTO 0) := to_unsigned(45,10);

    CONSTANT W1 : unsigned(9 DOWNTO 0) := to_unsigned(280,10); -- MAP
    CONSTANT H1 : unsigned(9 DOWNTO 0) := to_unsigned(155,10);

    CONSTANT W2 : unsigned(9 DOWNTO 0) := to_unsigned(40,10); -- GHOST1
    CONSTANT H2 : unsigned(9 DOWNTO 0) := to_unsigned(40,10); 


    -- SIGNALS TO CONTROL THE MEMORY INPUT ROM  | MAYBE CHANGE TO STD_LOGIC_VECTOR(19 DOWNTO 0)!!
    SIGNAL M_map_s                     : vector20;
    SIGNAL M_pacman_s                  : vector20;
    --SIGNAL M_ghost1_s                  : vector20;
               

    -- SIGNALS TO CONTROL THE PIXELS
    SIGNAL ypix_C0                     : unsigned(9 DOWNTO 0);
    SIGNAL ypix_C1                     : unsigned(9 DOWNTO 0);
    SIGNAL ypix_C2                     : unsigned(9 DOWNTO 0);
    SIGNAL ypix_C3                     : unsigned(9 DOWNTO 0);
    SIGNAL ypix_C4                     : unsigned(9 DOWNTO 0);
    SIGNAL ypix_C5                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R0                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R1                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R2                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R3                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R4                     : unsigned(9 DOWNTO 0);
    SIGNAL xpix_R5                     : unsigned(9 DOWNTO 0);

    -- SIGNALS OF THE SPRITEON
    SIGNAL spriteonPacman              : STD_LOGIC;
    SIGNAL spriteonMap                 : STD_LOGIC;

    -- SIGNALS OF TRANSITION OF SPRITES
    SIGNAL flagGhost1                  : STD_LOGIC := '0';
    SIGNAL flagGhost2                  : STD_LOGIC := '0';
    SIGNAL flagGhost3                  : STD_LOGIC := '0';
    SIGNAL flagGhost4                  : STD_LOGIC := '0';
    SIGNAL flagMap                     : STD_LOGIC := '0';
    SIGNAL mirrorRightTop              : STD_LOGIC := '0';
    SIGNAL mirrorRightBelow            : STD_LOGIC := '0';
    SIGNAL mirrorLeftBelow             : STD_LOGIC := '0';
    SIGNAL mirrorLeftTop               : STD_LOGIC := '1';      -- START    

        -- Additional signals for mirror logic
    SIGNAL h_mirror : unsigned(9 DOWNTO 0);
    SIGNAL v_mirror : unsigned(9 DOWNTO 0);

    CONSTANT SCREEN_WIDTH : unsigned(10 DOWNTO 0) := to_unsigned(640, 11);
    CONSTANT SCREEN_HEIGHT : unsigned(10 DOWNTO 0) := to_unsigned(480, 11);      

BEGIN
    -- DEFINITION OF EACH PIXEL
    ypix_C0 <= unsigned(hc) - (hbp + C_SW0);    -- PACMAN
    xpix_R0 <= unsigned(vc) - (hbp + R_SW0);

    ypix_C1 <= unsigned(hc) - (hbp + C_SW1);    -- GHOST1
    xpix_R1 <= unsigned(vc) - (hbp + R_SW1);
    
    ypix_C2 <= unsigned(hc) - (hbp + C_SW2);    -- GHOST2
    xpix_R2 <= unsigned(vc) - (hbp + R_SW2);

    ypix_C3 <= unsigned(hc) - (hbp + C_SW3);    -- GHOST3
    xpix_R3 <= unsigned(vc) - (hbp + R_SW3);

    ypix_C4 <= unsigned(hc) - (hbp + C_SW4);    -- GHOST4
    xpix_R4 <= unsigned(vc) - (hbp + R_SW4);

    ypix_C5 <= unsigned(hc) - (hbp + C_SW5);    -- MAP
    xpix_R5 <= unsigned(vc) - (hbp + R_SW5);


    -- ATTRIBUTION OF VALUES
    M_map_s    <=  STD_LOGIC_VECTOR(TotalPixels(ypix_C0, W1) + xpix_R0); -- MAP  
    M_pacman_s <=  STD_LOGIC_VECTOR(TotalPixels(ypix_C1, W0) + xpix_R1); -- PACMAN

    -- M_ghost1_s <= 
    -- STD_LOGIC_VECTOR(TotalPixels(ypix_C2, W2) + xpix_R2) WHEN flagGhost1 = '1' ELSE
    -- STD_LOGIC_VECTOR(TotalPixels(ypix_C3, W2) + xpix_R3) WHEN flagGhost2 = '1' ELSE
    -- STD_LOGIC_VECTOR(TotalPixels(ypix_C4, W2) + xpix_R4) WHEN flagGhost3 = '1' ELSE
    -- STD_LOGIC_VECTOR(TotalPixels(ypix_C5, W2) + xpix_R5);

    -- OUTPUT OF THE ADDRESS ROM
    addr_map_ROM     <= M_map_s(15 DOWNTO 0);
    addr_pacman_ROM  <= M_pacman_s(10 downto 0);
    --addr_ghost1_ROM  <= M_ghost1_s(10 downto 0);
    
    -- MIRRORS
    -- HORIZONTAL MIRROR
    h_mirror <= unsigned(hc) WHEN unsigned(hc) < unsigned(SCREEN_WIDTH(10 DOWNTO 1)/2) ELSE
            unsigned(SCREEN_WIDTH(10 DOWNTO 1)) - 1 - unsigned(hc);
    -- VERTICAL MIRROR
    v_mirror <= unsigned(vc) WHEN unsigned(vc) < unsigned(SCREEN_HEIGHT(10 DOWNTO 1)/2) ELSE 
            unsigned(SCREEN_HEIGHT(10 DOWNTO 1)) - 1 - unsigned(vc);

-- Adjusting addr_map_ROM for mirror effect
    --addr_map_ROM <= std_logic_vector(to_unsigned((to_integer(v_mirror) * to_integer(SCREEN_WIDTH/2)) + to_integer(h_mirror), addr_map_ROM'length));


    -- DEFINITIONS OF THE VALUES OF SPRITEON
    spriteonPacman <= '1' WHEN (unsigned(hc) >= R_SW0 + hbp AND unsigned(hc) < R_SW0 + hbp + W0 AND
        unsigned(vc) >= C_SW0 + vbp AND unsigned(vc) < C_SW0 + vbp + H0)
        ELSE
        '0';

    spriteonMap    <= '1' WHEN (unsigned(hc) >= R_SW5 + hbp AND unsigned(hc) < R_SW5 + hbp + W1 AND
        unsigned(vc) >= C_SW5 + vbp AND unsigned(vc) < C_SW5 + vbp + H1)
        ELSE
        '0';

        PROCESS (spriteonMap,spriteonPacman, M_map_ROM, M_pacman_ROM, vidon )
    BEGIN
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue <= (OTHERS => '0');

        IF vidon = '1' AND spriteonMap = '1' THEN
            -- Check for sprite visibility and set color outputs
                -- Output color values for the map
                red   <= M_map_ROM(11 DOWNTO 8);
                green <= M_map_ROM(7  DOWNTO 4);
                blue  <= M_map_ROM(3  DOWNTO 0);
            -- Add additional conditions for other sprites here
            ELSE
                -- Default color values
                red   <= sw(11 downto 8);
                green <= sw(7 downto 4);
                blue  <= sw(3 downto 0);
            END IF;
        --END IF;
    END PROCESS;
        
    -- -- SENDING THE VALUES TO THE OUTPUT OF THE MODULE
    -- PROCESS (spriteonPacman, M_map_ROM, M_pacman_ROM, vidon )
    -- BEGIN
    --     red <= (OTHERS => '0');
    --     green <= (OTHERS => '0');
    --     blue <= (OTHERS => '0');

    --     IF vidon = '1' AND spriteonMap = '1' THEN
    --         IF mirrorLeftTop = '1' THEN
    --             red        <= M_map_ROM(11 DOWNTO 8);
    --             green      <= M_map_ROM(7  DOWNTO 4);
    --             blue       <= M_map_ROM(3  DOWNTO 0);
    --             mirrorLeftTop  = '0';
    --             mirrorRightTop = '1';
    --         ELSIF mirrorRightTop = '1' THEN
    --             red        <= M_map_ROM(11 DOWNTO 8);
    --             green      <= M_map_ROM(7  DOWNTO 4);
    --             blue       <= M_map_ROM(3  DOWNTO 0);
    --             mirrorRightTop  = '0';
    --             mirrorLeftBelow = '1';
    --         ELSIF mirrorLeftBelow = '1' THEN
    --             red        <= M_map_ROM(11 DOWNTO 8);
    --             green      <= M_map_ROM(7  DOWNTO 4);
    --             blue       <= M_map_ROM(3  DOWNTO 0);
    --             mirrorLeftBelow  = '0';
    --             mirrorRightBelow = '1';
    --         ELSIF mirrorRightBelow = '1' THEN
    --             red        <= M_map_ROM(11 DOWNTO 8);
    --             green      <= M_map_ROM(7  DOWNTO 4);
    --             blue       <= M_map_ROM(3  DOWNTO 0);
    --             mirrorRightBelow = '0';
    --             mirrorLeftTop    = '1';
    --         END IF;
    --     -- IF vidon = '1' AND spriteonPacman = '1' THEN
    --         -- red        <= M_pacman_ROM(11 DOWNTO 8);
    --         -- green      <= M_pacman_ROM(7  DOWNTO 4);
    --         -- blue       <= M_pacman_ROM(3  DOWNTO 0);
    --         -- flagGhost1 <= '1';
    --     -- ELSIF vidon = '1' AND flagGhost1 = '1'  THEN    -- SOMETHING ELSE
    --         -- IF M_pacman_ROM(11 DOWNTO 8) /= x"FFFF" THEN
    --             -- red   <= std_logic_vector(resize(unsigned(M_pacman_ROM(11 DOWNTO 8)) * 12, 4));
    --             -- green <= std_logic_vector(resize(unsigned(M_pacman_ROM( 7 DOWNTO 4)) * 12, 4));
    --             -- blue  <= std_logic_vector(resize(unsigned(M_pacman_ROM( 3 DOWNTO 0)) * 12, 4));
    --         -- ELSE 
    --             -- red        <= M_pacman_ROM(11 DOWNTO 8);
    --             -- green      <= M_pacman_ROM(7  DOWNTO 4);
    --             -- blue       <= M_pacman_ROM(3  DOWNTO 0);
    --         -- END IF;
    --         -- flagGhost2 <= '1';
    --         -- flagGhost1 <= '0'; 
    --     -- ELSIF vidon = '1' AND flagGhost2 = '1' THEN     -- SOMETHING ELSE
    --         -- IF M_pacman_ROM(11 DOWNTO 8) /= x"FFFF" THEN
    --             -- red   <= std_logic_vector(resize(unsigned(M_pacman_ROM(11 DOWNTO 8)) * 2, 4));
    --             -- green <= std_logic_vector(resize(unsigned(M_pacman_ROM( 7 DOWNTO 4)) * 2, 4));
    --             -- blue  <= std_logic_vector(resize(unsigned(M_pacman_ROM( 3 DOWNTO 0)) * 2, 4));
    --         -- ELSE 
    --             -- red        <= M_pacman_ROM(11 DOWNTO 8);
    --             -- green      <= M_pacman_ROM(7  DOWNTO 4);
    --             -- blue       <= M_pacman_ROM(3  DOWNTO 0);
    --         -- END IF;
    --         -- flagGhost2 <= '0';
    --         -- flagGhost3 <= '1'; 

    --     -- ELSIF vidon = '1' AND flagGhost3 = '1' THEN     -- SOMETHING ELSE
    --         -- IF M_pacman_ROM(11 DOWNTO 8) /= x"FFFF" THEN
    --             -- red   <= std_logic_vector(resize(unsigned(M_pacman_ROM(11 DOWNTO 8)) * 6, 4));
    --             -- green <= std_logic_vector(resize(unsigned(M_pacman_ROM( 7 DOWNTO 4)) * 6, 4));
    --             -- blue  <= std_logic_vector(resize(unsigned(M_pacman_ROM( 3 DOWNTO 0)) * 6, 4));
    --         -- ELSE 
    --             -- red        <= M_pacman_ROM(11 DOWNTO 8);
    --             -- green      <= M_pacman_ROM(7  DOWNTO 4);
    --             -- blue       <= M_pacman_ROM(3  DOWNTO 0);
    --         -- END IF;
    --         -- flagGhost3 <= '0';
    --         -- flagGhost4 <= '1'; 

    --     -- ELSIF vidon = '1' AND flagGhost4 = '1' THEN     -- SOMETHING ELSE
    --         -- IF M_pacman_ROM(11 DOWNTO 8) /= x"FFFF" THEN
    --             -- red   <= std_logic_vector(resize(unsigned(M_pacman_ROM(11 DOWNTO 8)) * 9, 4));
    --             -- green <= std_logic_vector(resize(unsigned(M_pacman_ROM( 7 DOWNTO 4)) * 9, 4));
    --             -- blue  <= std_logic_vector(resize(unsigned(M_pacman_ROM( 3 DOWNTO 0)) * 9, 4));
    --         -- ELSE 
    --             -- red        <= M_pacman_ROM(11 DOWNTO 8);
    --             -- green      <= M_pacman_ROM(7  DOWNTO 4);
    --             -- blue       <= M_pacman_ROM(3  DOWNTO 0);
    --         -- END IF;
    --         -- flagGhost4 <= '0';
    --         -- flagMap    <= '1';

    --     -- ELSIF vidon = '1' AND flagMap = '1' THEN
    --         -- red        <= M_map_ROM(11 DOWNTO 8);
    --         -- green      <= M_map_ROM(7  DOWNTO 4);
    --         -- blue       <= M_map_ROM(3  DOWNTO 0);
    --         -- flagMap    <= '0';

    --     -- ELSIF vidon = '1' AND spriteonGhost1 = '1' THEN
    --     --     red   <= M_ghost1_ROM(11 DOWNTO 8);
    --     --     green <= M_ghost1_ROM(7  DOWNTO 4);
    --     --     blue  <= M_ghost1_ROM(3  DOWNTO 0);
    --     -- ELSIF vidon = '1' AND spriteonGhost2 = '1' THEN
    --     --     red   <= M_ghost2_ROM(11 DOWNTO 8);
    --     --     green <= M_ghost2_ROM(7  DOWNTO 4);
    --     --     blue  <= M_ghost2_ROM(3  DOWNTO 0);
    --     -- ELSIF vidon = '1' AND spriteonGhost3 = '1' THEN
    --     --     red   <= M_ghost3_ROM(11 DOWNTO 8);
    --     --     green <= M_ghost3_ROM(7  DOWNTO 4);
    --     --     blue  <= M_ghost3_ROM(3  DOWNTO 0);
    --     -- ELSIF vidon = '1' AND spriteonGhost4 = '1' THEN
    --     --     red   <= M_ghost4_ROM(11 DOWNTO 8);
    --     --     green <= M_ghost4_ROM(7  DOWNTO 4);
    --     --     blue  <= M_ghost4_ROM(3  DOWNTO 0);
    --     -- ELSIF vidon = '1' AND spriteonMap = '1' THEN
    --     --     red   <= M_map_ROM(11 DOWNTO 8);
    --     --     green <= M_map_ROM(7  DOWNTO 4);
    --     --     blue  <= M_map_ROM(3  DOWNTO 0);
    --     ELSIF vidon = '1' THEN
    --         red   <= sw(11 downto 8);
	-- 	    green <= sw(7 downto 4);
	-- 	    blue  <= sw(3 downto 0);
    --     END IF;
    -- END PROCESS;

END Behavioral;