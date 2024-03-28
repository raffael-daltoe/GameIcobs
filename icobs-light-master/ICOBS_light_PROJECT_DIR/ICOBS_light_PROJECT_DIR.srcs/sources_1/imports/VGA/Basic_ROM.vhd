
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Use numeric_std instead of std_logic_unsigned
use work.packages.all;

ENTITY Basic_ROM IS
	PORT (
		addr : IN vector16;
		M : OUT vector12
		--M : OUT vector16
		);
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