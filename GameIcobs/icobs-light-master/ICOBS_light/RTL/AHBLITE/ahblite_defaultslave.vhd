----------------------------------------------------------------
-- Default slave for AHB-Lite bus
-- Guillaume Patrigeon
-- Update: 04-10-2018
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library amba3;
use amba3.ahblite.all;


----------------------------------------------------------------
entity ahblite_defaultslave is port (
	HRESETn     : in  std_logic;
	HCLK        : in  std_logic;
	HSEL        : in  std_logic;
	HREADY      : in  std_logic;

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector);
end;


----------------------------------------------------------------
architecture arch of ahblite_defaultslave is

	signal transfer : std_logic;
	signal invalid  : std_logic;
	signal SlaveIn  : AHBLite_master;
	signal SlaveOut : AHBLite_slave;

----------------------------------------------------------------
begin

	AHBLITE_OUT <= to_vector(SlaveOut);
	SlaveIn <= to_record(AHBLITE_IN);

	-- Output port is forced to ground
	SlaveOut.HRDATA <= (others => '0');

	transfer <= HSEL and SlaveIn.HTRANS(1) and HREADY;
	-- Any transfer is invalid
	invalid  <= transfer;

	----------------------------------------------------------------
	process (HCLK, HRESETn) begin
		if HRESETn = '0' then
			-- Reset
			SlaveOut.HREADYOUT <= '1';
			SlaveOut.HRESP <= '0';

		--------------------------------
		elsif rising_edge(HCLK) then
			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;
		end if;
	end process;

end;
