----------------------------------------------------------------
-- GPIO module with AHB-Lite interface
-- Guillaume Patrigeon
-- Update: 21-02-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library amba3;
use amba3.ahblite.all;

----------------------------------------------------------------
entity ahblite_gpio is generic (N : positive range 1 to 16); port (
	HRESETn     : in  std_logic;
	HCLK        : in  std_logic;
	GCLK        : in  std_logic;
	HSEL        : in  std_logic;
	HREADY      : in  std_logic;

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector;

	-- IO access
	IOP_READ    : in  std_logic_vector(N-1 downto 0);
	IOP_DOUT    : out std_logic_vector(N-1 downto 0);
	IOP_TRIS    : out std_logic_vector(N-1 downto 0));
end;

----------------------------------------------------------------
architecture arch of ahblite_gpio is

	signal transfer : std_logic;
	signal invalid  : std_logic;
	signal SlaveIn  : AHBLite_master;
	signal SlaveOut : AHBLite_slave;

	signal address  : std_logic_vector(9 downto 2);
	signal lastaddr : std_logic_vector(9 downto 2);
	signal lastwr   : std_logic;

	-- Memory organization:
	-- +--------+--------+---------------------------+
	-- | OFFSET | NAME   | DESCRIPTION               |
	-- +--------+--------+---------------------------+
	-- |  x000  | IDR    | Input Data Register       |
	-- |  x004  | ODR    | Output Data Register      |
	-- |  x008  | MODE   | Mode register             |
	-- |  x00C  | ODRAIN | Ouput Drain mode register |
	-- +--------+--------+---------------------------+
	signal RegIDR    : std_logic_vector(N-1 downto 0);
	signal RegODR    : std_logic_vector(N-1 downto 0);
	signal RegMODE   : std_logic_vector(N-1 downto 0);
	signal RegODRAIN : std_logic_vector(N-1 downto 0);

----------------------------------------------------------------
begin

	AHBLITE_OUT <= to_vector(SlaveOut);
	SlaveIn <= to_record(AHBLITE_IN);

	transfer <= HSEL and SlaveIn.HTRANS(1) and HREADY;
	-- Invalid if not a 32-bit aligned transfer
	invalid  <= transfer and (SlaveIn.HSIZE(2) or (not SlaveIn.HSIZE(1)) or SlaveIn.HSIZE(0) or SlaveIn.HADDR(1) or SlaveIn.HADDR(0));

	address <= SlaveIn.HADDR(address'range);

	-- Pin control:
	-- +-------+--------+-------++-------+
	-- |  MODE | ODRAIN |  ODR  ||  OUT  |
	-- +-------+--------+-------++-------+
	-- |   0   |   X    |   X   ||   Z   |
	-- |   1   |   0    |   D   ||   D   |
	-- |   1   |   1    |   0   ||   0   |
	-- |   1   |   1    |   1   ||   Z   |
	-- +-------+--------+-------++-------+
	-- +-------+--------+-------++-------+-------+
	-- |  MODE | ODRAIN |  ODR  ||  TRIS |  DATA |
	-- +-------+--------+-------++-------+-------+
	-- |   0   |   X    |   X   ||   1   |   X   |
	-- |   1   |   0    |   D   ||   0   |   D   |
	-- |   1   |   1    |   D   ||   D   |   0   |
	-- +-------+--------+-------++-------+-------+

	RegIDR(IOP_READ'range) <= IOP_READ(IOP_READ'range);

	CTRL_BLOCK: for i in IOP_DOUT'range generate
		IOP_DOUT(i) <= RegODR(i) when RegODRAIN(i) = '0' else '0';
		IOP_TRIS(i) <= RegODR(i) when RegODRAIN(i) = '1' and RegMODE(i) = '1' else not RegMODE(i);
	end generate;

	----------------------------------------------------------------
	process (HCLK, GCLK, HRESETn) begin
		if HRESETn = '0' then
			-- Reset
			SlaveOut.HREADYOUT <= '1';
			SlaveOut.HRESP <= '0';
			SlaveOut.HRDATA <= (others => '0');

			lastwr <= '0';
			lastaddr <= (others => '0');

			-- Reset values
			RegODR <= (others => '0');
			RegMODE <= (others => '0');
			RegODRAIN <= (others => '0');


		--------------------------------
		elsif rising_edge(HCLK) and GCLK = '1' then
			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"01" => RegODR    <= SlaveIn.HWDATA(RegODR'range);
					when x"02" => RegMODE   <= SlaveIn.HWDATA(RegMODE'range);
					when x"03" => RegODRAIN <= SlaveIn.HWDATA(RegODRAIN'range);
					when others =>
				end case;
			end if;

			-- Check for transfer
			if transfer = '1' and invalid = '0' then
				-- Read operation: retrieve data and fill empty spaces with '0'
				if SlaveIn.HWRITE = '0' then
					SlaveOut.HRDATA <= (others => '0');

					case address is
						when x"00" => SlaveOut.HRDATA(RegIDR'range)    <= RegIDR;
						when x"01" => SlaveOut.HRDATA(RegODR'range)    <= RegODR;
						when x"02" => SlaveOut.HRDATA(RegMODE'range)   <= RegMODE;
						when x"03" => SlaveOut.HRDATA(RegODRAIN'range) <= RegODRAIN;
						when others =>
					end case;
				end if;

				-- Keep address and write command for next cycle
				lastaddr <= address;
				lastwr <= SlaveIn.HWRITE;
			else
				lastwr <= '0';
			end if;
		end if;
	end process;

end;
