library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.packages.all;
ENTITY VGA_Basic_ROM IS
    PORT (
        vidon : IN STD_LOGIC;
        hc : IN vector10;
        vc : IN vector10;
        sw : IN STD_LOGIC_VECTOR(11 DOWNTO 0); 
        rom_addr4 : OUT vector4;
        M : STD_LOGIC_VECTOR(11 DOWNTO 0);
        red : OUT vector4;
        green : OUT vector4;
        blue : OUT vector4);
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS
    SIGNAL spriteon : STD_LOGIC;
    CONSTANT hbp : unsigned(9 DOWNTO 0) := "0010010000"; -- horizontal back porch = 128 + 16 = 144 ou 96 + 48
    CONSTANT vbp : unsigned(9 DOWNTO 0) := "0000011111"; -- vertical back porch = 2 + 29 = 31

    CONSTANT w : unsigned(19 DOWNTO 0) := to_unsigned(4, 20);
    CONSTANT h : unsigned(19 DOWNTO 0) := to_unsigned(4, 20);
    SIGNAL xpix, ypix, R1, C1 : unsigned(9 DOWNTO 0);

    SIGNAL rom_addr_s : STD_LOGIC_VECTOR(29 DOWNTO 0);
    SIGNAL r2,c2 : vector10;

BEGIN
    r2 <= sw(11 DOWNTO 6) & "0000";
    c2 <= sw(5 DOWNTO 0) & "0000";
    R1 <= unsigned(r2);
    C1 <= unsigned(c2);

    xpix <= unsigned(hc) - (hbp + C1);
    ypix <= unsigned(vc) - (vbp + R1);

    rom_addr_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, w) + xpix);

    rom_addr4 <= rom_addr_s(3 DOWNTO 0);

    spriteon <= '1' WHEN (unsigned(hc) >= C1 + hbp AND unsigned(hc) < C1 + hbp + w AND
        unsigned(vc) >= R1 + vbp AND unsigned(vc) < R1 + vbp + h)
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
        ELSIF vidon = '1' THEN
            red <= (OTHERS => '0');
            green <= (OTHERS => '0');
            blue <= (OTHERS => '1');

        END IF;
    END PROCESS;

END Behavioral;