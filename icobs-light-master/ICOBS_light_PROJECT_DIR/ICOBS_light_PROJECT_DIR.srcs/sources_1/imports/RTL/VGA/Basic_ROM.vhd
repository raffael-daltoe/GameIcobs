
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Use numeric_std instead of std_logic_unsigned
use work.packages.all;

ENTITY Basic_ROM IS
	PORT (
		addr : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		M : OUT STD_LOGIC_VECTOR (11 DOWNTO 0));
END Basic_ROM;

ARCHITECTURE Behavioral OF Basic_ROM IS

BEGIN
	PROCESS (addr)
		VARIABLE j : INTEGER;
	BEGIN
		j := to_integer(unsigned(addr)); -- Convert using numeric_std
		M <= rom(j);
	END PROCESS;
END Behavioral;