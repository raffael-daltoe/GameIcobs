library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;

ENTITY VGA_Basic_ROM IS
    PORT (
        vidon : IN STD_LOGIC;
        hc : IN vector10;
        vc : IN vector10;               
        sw : IN vector12;               -- SWITCH OF FPGA
        
        R1  : in unsigned(9 downto 0);  -- REGISTERS WHERE DETERMINE THE POSITION OF FIGURE horizontal
        C1  : in unsigned(9 downto 0);  -- REGISTERS WHERE DETERMINE THE POSITION OF FIGURE vertical
        
        romAddressMap : OUT vector16;       -- ADDRESS OF THE ROM TO TAKE
        romMap : in vector12;                -- ADDRESS OF THE ROOM TAKED TO SPRITE ON SCREEN
        red : OUT vector4;
        green : OUT vector4;
        blue : OUT vector4);    
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS
    SIGNAL spriteOnLeftTop       : STD_LOGIC := '0';    
    SIGNAL spriteOnRightTop      : STD_LOGIC := '0';
    SIGNAL spriteOnLeftDown      : STD_LOGIC := '0';
    SIGNAL spriteOnRightDown     : STD_LOGIC := '0';    
    CONSTANT hbp : unsigned(9 DOWNTO 0) := "0010010000"; -- horizontal back porch = 128 + 16 = 144 ou 96 + 48
    CONSTANT vbp : unsigned(9 DOWNTO 0) := "0000011111"; -- vertical back porch = 2 + 29 = 31

    CONSTANT W1 : unsigned(9 DOWNTO 0) := to_unsigned(280, 10); -- LARGURA
    CONSTANT H1 : unsigned(9 DOWNTO 0) := to_unsigned(155, 10); -- ALTURA
    
    CONSTANT X_INIT_MAP : unsigned(9 DOWNTO 0) := "0000101000";
    CONSTANT Y_INIT_MAP : unsigned(9 DOWNTO 0) := "0001010101";
    
    SIGNAL xpix, ypix : unsigned(9 DOWNTO 0);
    SIGNAL romAddressMap_s : STD_LOGIC_VECTOR(19 DOWNTO 0);

BEGIN

    PROCESS (vc,hc)
    BEGIN
        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + W1 AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + H1) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);      -- X_INIT_MAP = HORIZONTAL
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);      -- Y_INIT_MAP = VERTICAL
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, W1) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnLeftTop <= '1';
        ELSE
            spriteOnLeftTop <= '0';
        END IF;


        IF (unsigned(hc) >= X_INIT_MAP + W1 + hbp AND unsigned(hc) < X_INIT_MAP + hbp + W1 + W1 AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + H1) THEN
            xpix <= (W1 - 1) - (unsigned(hc) - (hbp + X_INIT_MAP + W1)); -- INVERSÃO DO ENDEREÇO
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);                      -- Y_INIT_MAP = VERTICAL
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, W1) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightTop <= '1';
        ELSE
            spriteOnRightTop <= '0';
        END IF; 
        
        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + W1 AND
            unsigned(vc) >= Y_INIT_MAP + H1 + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + H1 + H1 ) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);  -- X_INIT_MAP = HORIZONTAL
            -- Aqui, invertemos a ordem vertical subtraindo ypix de H1 - 1.
            ypix <= H1 - 1 - (unsigned(vc) - (vbp + Y_INIT_MAP) - H1);  -- Y_INIT_MAP = VERTICAL INVERTIDO
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, W1) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);

            spriteOnLeftDown <= '1';
        ELSE
            spriteOnLeftDown <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + W1 + hbp AND unsigned(hc) < X_INIT_MAP + hbp + W1 + W1 AND
            unsigned(vc) >= Y_INIT_MAP + H1 + vbp  AND unsigned(vc) < Y_INIT_MAP + vbp + H1 + H1 ) THEN
            -- Cálculo para espelhamento horizontal
            xpix <= W1 - 1 - (unsigned(hc) - (X_INIT_MAP + W1 + hbp));
            -- Cálculo para espelhamento vertical
            ypix <= H1 - 1 - (unsigned(vc) - (Y_INIT_MAP + H1 + vbp));
        
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, W1) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightDown <= '1';
        ELSE
            spriteOnRightDown <= '0';
        END IF;


    END PROCESS;

    PROCESS (spriteOnLeftTop, spriteOnRightTop, spriteOnLeftDown, spriteOnRightDown, vidon)
    BEGIN
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue <= (OTHERS => '0');

        IF vidon = '1' AND spriteOnLeftTop = '1' THEN
            red <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue <= romMap(3 DOWNTO 0);

        ELSIF vidon = '1' AND spriteOnRightTop = '1' THEN
            red <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnLeftDown = '1' THEN
            red <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnRightDown = '1' THEN
            red <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' THEN
--            red <= (OTHERS => '0');
--            green <= (OTHERS => '0');
--            blue <= (OTHERS => '1');
            red   <= sw(11 downto 8) ;
		    green <= sw(7 downto 4);
		    blue  <= sw(3 downto 0); 

        END IF;
    END PROCESS;

END Behavioral;