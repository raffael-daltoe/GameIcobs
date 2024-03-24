----------------------------------------------------------------
-- Power-On Reset for FPGA
-- Guillaume Patrigeon
-- Update: 16-04-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


----------------------------------------------------------------
entity poweron_reset is port (
	CLK : in  std_logic;
	RST : out std_logic);
end;


----------------------------------------------------------------
architecture arch of poweron_reset is

	signal R : std_logic_vector(4 downto 0) := (others => '0');


----------------------------------------------------------------
begin

	RST <= R(4);


	process (CLK, R) begin
		if R(4) = '0' and rising_edge(CLK) then
			R <= std_logic_vector(unsigned(R) + 1);
		end if;
	end process;

end;
