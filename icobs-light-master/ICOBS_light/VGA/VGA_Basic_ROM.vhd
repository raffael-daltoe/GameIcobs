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
        R1  : in unsigned(9 downto 0);
        C1  : in unsigned(9 downto 0);
        
        R2  : in unsigned(9 downto 0);
        C2  : in unsigned(9 downto 0);
        
        --rom_addr4 : OUT vector16;
        rom_addr4 : out std_logic_vector(12 downto 0);
        M : in vector12;
        
        M_2_sprite : in vector12;
        --rom_addr4_2_sprite : out vector16;
        rom_addr4_2_sprite : out std_logic_vector(12 downto 0);
        red : OUT vector4;
        green : OUT vector4;
        blue : OUT vector4);
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS
    SIGNAL spriteon,spriteon_2_sprite : STD_LOGIC;
    CONSTANT hbp : unsigned(9 DOWNTO 0) := "0010010000"; -- horizontal back porch = 128 + 16 = 144 ou 96 + 48
    CONSTANT vbp : unsigned(9 DOWNTO 0) := "0000011111"; -- vertical back porch = 2 + 29 = 31

    CONSTANT w : unsigned(9 DOWNTO 0) := to_unsigned(80, 10);       -- crash
    CONSTANT h : unsigned(9 DOWNTO 0) := to_unsigned(90, 10);
    

    CONSTANT w2 : unsigned(9 DOWNTO 0) := to_unsigned(101, 10);      -- crash
    CONSTANT h2 : unsigned(9 DOWNTO 0) := to_unsigned(72, 10);
    
    
    --SIGNAL xpix, ypix, R1, C1 : unsigned(9 DOWNTO 0);

    SIGNAL xpix, ypix,xpix2,ypix2 : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_s,rom_addr_s_2_sprite : STD_LOGIC_VECTOR(19 DOWNTO 0);
    --SIGNAL r2,c2 : vector10;

BEGIN
    --r2 <= sw(11 DOWNTO 6) & "0000";
    --c2 <= sw(5 DOWNTO 0) & "0000";
    --R1 <= unsigned(r2);
    --C1 <= unsigned(c2);
    --R1 <= unsigned(X);
    --C1 <= unsigned(Y);

    xpix <= unsigned(hc) - (hbp + C1);
    ypix <= unsigned(vc) - (vbp + R1);

    xpix2 <= unsigned(hc) - (hbp + C2);
    ypix2 <= unsigned(vc) - (vbp + R2);


    rom_addr_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, w) + xpix);
    rom_addr4 <= rom_addr_s(12 downto 0);
    
    rom_addr_s_2_sprite <= STD_LOGIC_VECTOR(TotalPixels(ypix2,w) + xpix2);
    rom_addr4_2_sprite <= rom_addr_s_2_sprite(12 downto 0);
    
    spriteon <= '1' WHEN (unsigned(hc) >= C1 + hbp AND unsigned(hc) < C1 + hbp + w AND
        unsigned(vc) >= R1 + vbp AND unsigned(vc) < R1 + vbp + h)
        ELSE
        '0';

    spriteon_2_sprite <= '1' WHEN (unsigned(hc) >= C2 + hbp AND unsigned(hc) < C2 + hbp + w2 AND
        unsigned(vc) >= R2 + vbp AND unsigned(vc) < R2 + vbp + h2)
        ELSE
        '0';
        
    PROCESS (spriteon, vidon, M)
    BEGIN
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue <= (OTHERS => '0');

        IF vidon = '1' AND spriteon = '1' THEN
            red <= M(11 DOWNTO 8);
            green <= M(7 DOWNTO 4);
            blue <= M(3 DOWNTO 0);
        ELSIF vidon = '1' and spriteon_2_sprite = '1' THEN
            red <= M_2_sprite(11 DOWNTO 8);
            green <= M_2_sprite(7 DOWNTO 4);
            blue <= M_2_sprite(3 DOWNTO 0);
        ELSIF vidon = '1' THEN
            red   <= sw(11 downto 8) ;
		    green <= sw(7 downto 4);
		    blue  <= sw(3 downto 0); 
        END IF;
    END PROCESS;

END Behavioral;