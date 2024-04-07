library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 


PACKAGE packages IS
    TYPE rom_array IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
    constant N : INTEGER := 10;
    subtype vector10 is std_logic_vector(9 downto 0);
    subtype vector4 is std_logic_vector(3 downto 0);
    subtype vector7 is std_logic_vector(6 downto 0);
    subtype vector8 is std_logic_vector(7 downto 0);
    subtype vector9  is std_logic_vector(8 downto 0);
    subtype vector11 is std_logic_vector(10 downto 0);
    subtype vector12 is std_logic_vector(11 downto 0);
    subtype vector13 is std_logic_vector(12 downto 0);
    subtype vector16 is std_logic_vector(15 downto 0);
    subtype vector17 is std_logic_vector(16 downto 0);
    subtype vector20 is std_logic_vector(19 downto 0);
    
    CONSTANT rom : rom_array := (
    "000001110000", "000001110001", "000001110010", "000001110011", "000001110100", 
    "000001110101", "000001110110", "000001110111", "000001111000", "000001111001",
    "000010000000", "000010000001", "000010000010", "000010000011", "000010000100", 
    "000010000101", "000010000110", "000010000111", "000010001000", "000010001001",
    "000010010000", "000010010001", "000010010010", "000010010011", "000010010100", 
    "000010010101", "000010010110", "000010010111", "000010011000", "000010011001",
    "000000110000", "000000110001", "000000110010", "000000110011", "000000110100", 
    "000000110101", "000000110110", "000000110111", "000000111000", "000000111001"
    --    "000001000000", "000001000001", "000001000010", "000001000011", "000001000100", 
    --    "000001000101", "000001000110", "000001000111", "000001001000", "000001001001",  
    --    "000001010000", "000001010001", "000001010010", "000001010011", "000001010100", 
    --    "000001010101", "000001010110", "000001010111", "000001011000", "000001011001",
    --    "000001100000", "000001100001", "000001100010", "000001100011", "000001100100", 
    --    "000001100101", "000001100110", "000001100111", "000001101000", "000001101001",
    --    "000001110000", "000001110001", "000001110010", "000001110011", "000001110100", 
    --    "000001110101", "000001110110", "000001110111", "000001111000", "000001111001",
    --    "000010000000", "000010000001", "000010000010", "000010000011", "000010000100", 
    --    "000010000101", "000010000110", "000010000111", "000010001000", "000010001001",
    --    "000010010000", "000010010001", "000010010010", "000010010011", "000010010100", 
    --    "000010010101", "000010010110", "000010010111", "000010011000", "000010011001"

    );
    -- Declare functions
    FUNCTION TotalPixels(width, height : unsigned) RETURN unsigned; --Used to calculate the Total Number of Pixels
    FUNCTION log2(N : NATURAL) RETURN NATURAL; --Used to calculate the size of the std_logic_vectors

    ----     Declare constants

    CONSTANT VGA_WIDTH : INTEGER := 640;
    CONSTANT VGA_HEIGHT : INTEGER := 480;

    CONSTANT HORIZONTAL_PULSE : INTEGER := 96;
    CONSTANT HORIZONTAL_BP : INTEGER := 48;
    CONSTANT HORIZONTAL_FP : INTEGER := 16;

    --Do the sale with VERTICAL constants, according to the specifications for a 640x480 VGA display
     constant VERTICAL_PULSE:  integer := 2; 
     constant VERTICAL_BP:     integer := 29; 
     constant VERTICAL_FP:     integer := 10; 

    --Find the constant value to be calculated depending on the above mentioned constants
    --constant N:                 integer := log2();

    CONSTANT hpixels : unsigned(N - 1 DOWNTO 0) := to_unsigned(VGA_WIDTH + HORIZONTAL_PULSE + HORIZONTAL_BP + HORIZONTAL_FP, N); --800
    CONSTANT hbp : unsigned(N - 1 DOWNTO 0) := to_unsigned(HORIZONTAL_PULSE + HORIZONTAL_BP, N); -- 144
    CONSTANT hfp : unsigned(N - 1 DOWNTO 0) := to_unsigned(VGA_WIDTH + HORIZONTAL_PULSE + HORIZONTAL_BP, N); -- 784 

     constant vlines:    unsigned(N-1 downto 0) := to_unsigned(VGA_HEIGHT + VERTICAL_PULSE + VERTICAL_BP+VERTICAL_FP , N); -- 681
     constant vbp:       unsigned(N-1 downto 0) := to_unsigned(VERTICAL_PULSE + VERTICAL_BP, N ); -- 31
     constant vfp:       unsigned(N-1 downto 0) := to_unsigned(VGA_HEIGHT + VERTICAL_PULSE + VERTICAL_BP, N); -- 530
     
    CONSTANT WMap : unsigned(9 DOWNTO 0) := to_unsigned(249, 10); -- LARGURA
    CONSTANT HMap : unsigned(9 DOWNTO 0) := to_unsigned(138, 10); -- ALTURA
    
    CONSTANT WPacmanOpen : unsigned(9 DOWNTO 0) := to_unsigned(29, 10); -- LARGURA
    CONSTANT HPacmanOpen : unsigned(9 DOWNTO 0) := to_unsigned(29, 10); -- ALTURA
    
    CONSTANT WPacmanClose : unsigned(9 DOWNTO 0) := to_unsigned(29, 10); -- LARGURA
    CONSTANT HPacmanClose : unsigned(9 DOWNTO 0) := to_unsigned(29, 10); -- ALTURA
    
    CONSTANT WFood  : unsigned(9 DOWNTO 0) := to_unsigned(11, 10); -- ALTURA
    CONSTANT HFood  : unsigned(9 DOWNTO 0) := to_unsigned(7, 10); -- ALTURA

    CONSTANT WGhost  : unsigned(9 DOWNTO 0) := to_unsigned(24, 10); -- LARGURA
    CONSTANT HGhost  : unsigned(9 DOWNTO 0) := to_unsigned(24, 10); -- ALTURA

    CONSTANT WWINNER : unsigned(9 DOWNTO 0) := to_unsigned(48,10);
    CONSTANT HWINNER : unsigned(9 DOWNTO 0) := to_unsigned(35,10);

    CONSTANT WLOSER  : unsigned(9 DOWNTO 0) := to_unsigned(49,10);
    CONSTANT HLOSER  : unsigned(9 DOWNTO 0) := to_unsigned(49,10);

    CONSTANT X_INIT_WINNER : unsigned(9 DOWNTO 0) := "0100100010";
    CONSTANT Y_INIT_WINNER : unsigned(9 DOWNTO 0) := "0011100001";

    CONSTANT X_INIT_LOSER  : unsigned(9 DOWNTO 0) := "0100100111";
    CONSTANT Y_INIT_LOSER  : unsigned(9 DOWNTO 0) := "0011010111";

    CONSTANT X_INIT_MAP : unsigned(9 DOWNTO 0) := "0000101000";
    CONSTANT Y_INIT_MAP : unsigned(9 DOWNTO 0) := "0001010101";

    CONSTANT Y_INIT_FOOD0 : unsigned(9 DOWNTO 0) := "0001100110";
    CONSTANT X_INIT_FOOD0 : unsigned(9 DOWNTO 0) := "0001100110";

    CONSTANT Y_INIT_FOOD1 : unsigned(9 DOWNTO 0) := "0010011001";
    CONSTANT X_INIT_FOOD1 : unsigned(9 DOWNTO 0) := "0001101100";

    CONSTANT Y_INIT_FOOD2 : unsigned(9 DOWNTO 0) := "0100000101";
    CONSTANT X_INIT_FOOD2 : unsigned(9 DOWNTO 0) := "0001101100";

    CONSTANT Y_INIT_FOOD3 : unsigned(9 DOWNTO 0) := "0100000101";
    CONSTANT X_INIT_FOOD3 : unsigned(9 DOWNTO 0) := "0111000000";

    CONSTANT Y_INIT_FOOD4 : unsigned(9 DOWNTO 0) := "0010011001";
    CONSTANT X_INIT_FOOD4 : unsigned(9 DOWNTO 0) := "0110111111";

    CONSTANT Y_INIT_FOOD5 : unsigned(9 DOWNTO 0) := "0010011001";
    CONSTANT X_INIT_FOOD5 : unsigned(9 DOWNTO 0) := "0101101000";

    CONSTANT Y_INIT_FOOD6 : unsigned(9 DOWNTO 0) := "0100001010";
    CONSTANT X_INIT_FOOD6 : unsigned(9 DOWNTO 0) := "0101101000";

    CONSTANT Y_INIT_FOOD7 : unsigned(9 DOWNTO 0) := "0100001010";
    CONSTANT X_INIT_FOOD7 : unsigned(9 DOWNTO 0) := "0100010101";

    CONSTANT Y_INIT_FOOD8 : unsigned(9 DOWNTO 0) := "0100111111";
    CONSTANT X_INIT_FOOD8 : unsigned(9 DOWNTO 0) := "0100010101";

    CONSTANT Y_INIT_FOOD9 : unsigned(9 DOWNTO 0) := "0001100010";
    CONSTANT X_INIT_FOOD9 : unsigned(9 DOWNTO 0) := "0100010101";

    CONSTANT Y_INIT_FOOD10 : unsigned(9 DOWNTO 0) := "0001100010";
    CONSTANT X_INIT_FOOD10 : unsigned(9 DOWNTO 0) := "0010111101";

    CONSTANT Y_INIT_FOOD11 : unsigned(9 DOWNTO 0) := "0100111110";
    CONSTANT X_INIT_FOOD11 : unsigned(9 DOWNTO 0) := "0010111101";

    CONSTANT Y_INIT_FOOD12 : unsigned(9 DOWNTO 0) := "0100111110";
    CONSTANT X_INIT_FOOD12 : unsigned(9 DOWNTO 0) := "0101101000";

    CONSTANT Y_INIT_FOOD13 : unsigned(9 DOWNTO 0) := "0011010000";
    CONSTANT X_INIT_FOOD13 : unsigned(9 DOWNTO 0) := "0110010010";

    CONSTANT Y_INIT_FOOD14 : unsigned(9 DOWNTO 0) := "0011010000";
    CONSTANT X_INIT_FOOD14 : unsigned(9 DOWNTO 0) := "0010010101";

    CONSTANT Y_INIT_FOOD15 : unsigned(9 DOWNTO 0) := "0011010000";
    CONSTANT X_INIT_FOOD15 : unsigned(9 DOWNTO 0) := "0111110011";

    CONSTANT Y_INIT_FOOD16 : unsigned(9 DOWNTO 0) := "0011010000";
    CONSTANT X_INIT_FOOD16 : unsigned(9 DOWNTO 0) := "0000111010";

    CONSTANT Y_INIT_FOOD17 : unsigned(9 DOWNTO 0) := "0011010011";
    CONSTANT X_INIT_FOOD17 : unsigned(9 DOWNTO 0) := "0100010110";

    CONSTANT Y_INIT_FOOD18 : unsigned(9 DOWNTO 0) := "0011010011";
    CONSTANT X_INIT_FOOD18 : unsigned(9 DOWNTO 0) := "0011110100";

    CONSTANT Y_INIT_FOOD19 : unsigned(9 DOWNTO 0) := "0010010111";
    CONSTANT X_INIT_FOOD19 : unsigned(9 DOWNTO 0) := "0010011110";

    CONSTANT Y_INIT_FOOD20 : unsigned(9 DOWNTO 0) := "0100001010";
    CONSTANT X_INIT_FOOD20 : unsigned(9 DOWNTO 0) := "0110000110";



END packages;

PACKAGE BODY packages IS

    -- Implementation of the TotalPixels function
    FUNCTION TotalPixels(width, height : unsigned) RETURN unsigned IS
    BEGIN
        RETURN width * height;
    END TotalPixels;

    -- Implementation of the log2 function
    FUNCTION log2(N : NATURAL) RETURN NATURAL IS
        VARIABLE count : NATURAL := 0;
        VARIABLE value : NATURAL := N;
    BEGIN
        WHILE value >= 1 LOOP
            value := value / 2;
            count := count + 1;
        END LOOP;
        RETURN count;
    END log2;
END packages;   