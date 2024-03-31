library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_Basic_ROM IS
    PORT (
        vidon                   : IN STD_LOGIC;
        hc                      : IN vector10;
        vc                      : IN vector10;               
        sw                      : IN vector12;   -- SWITCH OF FPGA
        changePacman            : IN STD_LOGIC;
        --  REGISTERS
        R_SW0                      : in unsigned(9 downto 0);  -- HORIZONTAL
        C_SW0                      : in unsigned(9 downto 0);  -- VERITICAL
        --R_SW1                      : in unsigned(9 downto 0);  -- TYPE OF PACMAN
        --C_SW1                      : in unsigned(9 downto 0);  -- TYPE OF PACMAN
    
        -- ROM ADDRESSES
        romAddressMap               : OUT vector16;       -- MAP ADDRESS
        romAddressPacmanClosed      : OUT vector10;
        romAddressPacmanOpened      : OUT vector10;
        romAddressGhost             : OUT vector10;
        romAddressFood              : OUT vector7;


        -- ROM DATA INPUT
        romMap                  : IN vector12;       -- MAP    
        romPacmanClosed         : IN vector12;
        romPacmanOpened         : IN vector12;
        romGhost                : IN vector12;
        romFood                 : IN vector12;

        --OUTPUT VGA
        red                     : OUT vector4;
        green                   : OUT vector4;
        blue                    : OUT vector4
);           
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS

    -- DECLARATION OF SIGNALS OF SPRITE
    SIGNAL spriteOnLeftTop          : STD_LOGIC := '0';    
    SIGNAL spriteOnRightTop         : STD_LOGIC := '0';
    SIGNAL spriteOnLeftDown         : STD_LOGIC := '0';
    SIGNAL spriteOnRightDown        : STD_LOGIC := '0'; 
    SIGNAL spritePacmanClose        : STD_LOGIC := '0';   
    SIGNAL spritePacmanOpen         : STD_LOGIC := '0';
    
    -- DECLARATION OF SIGNALS COORDINATES AND ADDRESS OF ROM
    SIGNAL xpix, ypix               : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Pac, ypix_Pac               : UNSIGNED(9 DOWNTO 0);
    SIGNAL romAddressMap_s          : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanClosed_s : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanOpened_s : STD_LOGIC_VECTOR(19 DOWNTO 0);

BEGIN

    PROCESS (vc,hc,R_SW0,C_SW0,xpix,ypix,romAddressMap_s,romAddressPacmanOpened_s,ypix_Pac,xpix_Pac)
    BEGIN
        IF (unsigned(hc) >= R_SW0 + hbp AND unsigned(hc) < R_SW0 + hbp + WPacmanOpen AND
            unsigned(vc) >= C_SW0 + vbp AND unsigned(vc) < C_SW0 + vbp + HPacmanOpen) THEN
            xpix_Pac <= unsigned(hc) - (hbp + R_SW0);   
            ypix_Pac <= unsigned(vc) - (vbp + C_SW0);      
            romAddressPacmanOpened_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Pac, WPacmanOpen) + xpix_Pac);
            romAddressPacmanOpened <= romAddressPacmanOpened_s(9 downto 0);
            spritePacmanOpen <= '1';
        ELSE
            spritePacmanOpen <= '0';
        END IF;
    
        IF (unsigned(hc) >= R_SW0 + hbp AND unsigned(hc) < R_SW0 + hbp + WPacmanClose AND
            unsigned(vc) >= C_SW0 + vbp AND unsigned(vc) < C_SW0 + vbp + HPacmanClose) THEN
            xpix_Pac <= unsigned(hc) - (hbp + R_SW0);      
            ypix_Pac <= unsigned(vc) - (vbp + C_SW0);    
            romAddressPacmanClosed_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Pac, WPacmanClose) + xpix_Pac);
            romAddressPacmanClosed <= romAddressPacmanClosed_s(9 downto 0);
            spritePacmanClose <= '1';
        ELSE
            spritePacmanClose <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);   
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);      
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnLeftTop <= '1';
        ELSE
            spriteOnLeftTop <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + WMap + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap + WMap AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap) THEN
            xpix <= (WMap - 1) - (unsigned(hc) - (hbp + X_INIT_MAP + WMap));   
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);                      
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightTop <= '1';
        ELSE
            spriteOnRightTop <= '0';
        END IF; 
        
        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap AND
            unsigned(vc) >= Y_INIT_MAP + HMap + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap + HMap ) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);
            ypix <= HMap - 1 - (unsigned(vc) - (vbp + Y_INIT_MAP) - HMap);  
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnLeftDown <= '1';
        ELSE
            spriteOnLeftDown <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + WMap + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap + WMap AND
            unsigned(vc) >= Y_INIT_MAP + HMap + vbp  AND unsigned(vc) < Y_INIT_MAP + vbp + HMap + HMap ) THEN
            xpix <= WMap - 1 - (unsigned(hc) - (X_INIT_MAP + WMap + hbp));
            ypix <= HMap - 1 - (unsigned(vc) - (Y_INIT_MAP + HMap + vbp));        
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightDown <= '1';
        ELSE
            spriteOnRightDown <= '0';
        END IF;
    END PROCESS;

    PROCESS (spriteOnLeftTop, spriteOnRightTop, spriteOnLeftDown, spriteOnRightDown, 
             spritePacmanOpen,spritePacmanClose,vidon,sw,romMap,romPacmanOpened,
             romPacmanClosed)
    BEGIN
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue <= (OTHERS => '0');

    
        IF vidon = '1' AND spritePacmanOpen = '1' AND changePacman = '1' THEN
            red   <= romPacmanOpened(11 DOWNTO 8);
            green <= romPacmanOpened(7 DOWNTO 4);
            blue  <= romPacmanOpened(3 DOWNTO 0);
        ELSIF vidon='1' AND spritePacmanClose = '1' AND changePacman = '0' THEN
            red   <= romPacmanClosed(11 DOWNTO 8);
            green <= romPacmanClosed(7 DOWNTO 4);
            blue  <= romPacmanClosed(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnLeftTop = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnRightTop = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnLeftDown = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnRightDown = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' THEN
            red   <= sw(11 downto 8) ;
		    green <= sw(7 downto 4);
		    blue  <= sw(3 downto 0); 

        END IF;
    END PROCESS;

END Behavioral;