----------------------------------------------------------------
-- Timer module with AHB-Lite interface
-- Guillaume Patrigeon
-- Update: 21-02-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library amba3;
use amba3.ahblite.all;

----------------------------------------------------------------
entity ahblite_timer is port (
	HRESETn     : in  std_logic;
	HCLK        : in  std_logic;
	GCLK        : in  std_logic;
	HSEL        : in  std_logic;
	HREADY      : in  std_logic;

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector;

	-- Interrupt request
	IRQ         : out std_logic);
end;

----------------------------------------------------------------
architecture arch of ahblite_timer is

	signal transfer : std_logic;
	signal invalid  : std_logic;
	signal SlaveIn  : AHBLite_master;
	signal SlaveOut : AHBLite_slave;

	signal address  : std_logic_vector(9 downto 2);
	signal lastaddr : std_logic_vector(9 downto 2);
	signal lastwr   : std_logic;

	-- Memory organization:
	-- +--------+--------+-----------------------------+
	-- | OFFSET | NAME   | DESCRIPTION                 |
	-- +--------+--------+-----------------------------+
	-- |  x000  | CNT    | Counter Register            |
	-- |  x004  | STATUS | Status Register             |
	-- |  x008  | CR1    | Control Register 1          |
	-- |  x00C  | CR2    | Control Register 2          |
	-- |  x010  | ARR    | Control Register 3          |
	-- +--------+--------+-----------------------------+

	signal RegCNT     : std_logic_vector(15 downto 0);
	signal RegSTATUS  : std_logic_vector(1 downto 1);
	signal RegCR1     : std_logic_vector(1 downto 0);
	signal RegCR2     : std_logic_vector(15 downto 0);
	signal RegARR     : std_logic_vector(15 downto 0);

	-- STATUS signals
	signal FlagUIF    : std_logic; -- Updtae Interrupt Flag

	-- CR1 signals
	signal SigPE      : std_logic; -- Peripheral Enable
	signal SigUIE     : std_logic; -- Updtae Interrupt Enable

	-- CR2 signals
	signal SigPSC     : std_logic_vector(15 downto 0); -- Prescaler

	-- ARR signals
	signal SigARR     : std_logic_vector(15 downto 0); -- Auto Reload Register

	-- Others
	signal prescaler  : std_logic_vector(15 downto 0);
	signal counter    : std_logic_vector(15 downto 0);

----------------------------------------------------------------
begin

	AHBLITE_OUT <= to_vector(SlaveOut);
	SlaveIn <= to_record(AHBLITE_IN);

	transfer <= HSEL and SlaveIn.HTRANS(1) and HREADY;
	-- Invalid if not a 32-bit aligned transfer
	invalid  <= transfer and (SlaveIn.HSIZE(2) or (not SlaveIn.HSIZE(1)) or SlaveIn.HSIZE(0) or SlaveIn.HADDR(1) or SlaveIn.HADDR(0));

	address <= SlaveIn.HADDR(address'range);

	----------------------------------------------------------------
	-- Assign signals for CNT registers:
	RegCNT(15 downto 0) <= counter;

	-- Assign signals for STATUS registers:
	RegSTATUS(1) <= FlagUIF;

	-- Assign signals for CR1 registers:
	SigPE  <= RegCR1(0);
	SigUIE <= RegCR1(1);

	-- Assign signals for CR2 registers:
	SigPSC <= RegCR2(15 downto 0);

	-- Assign signals for ARR registers:
	SigARR <= RegARR(15 downto 0);

	-- Interrupts:
	IRQ <= SigPE and (FlagUIF and SigUIE);

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
			RegCR1 <= (others => '0');
			RegCR2 <= (others => '0');
			RegARR <= (others => '1');

			FlagUIF <= '0';

			prescaler <= (others => '0');
			counter <= (others => '0');

		--------------------------------
		elsif rising_edge(HCLK) and GCLK = '1' then
			-- Bus access

			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"00" => if SigPE = '0' then counter <= SlaveIn.HWDATA(counter'range); end if;
					when x"01" => if SlaveIn.HWDATA(1) = '0' then FlagUIF <= '0'; end if;
					when x"02" => RegCR1 <= SlaveIn.HWDATA(RegCR1'range);
					when x"03" => RegCR2 <= SlaveIn.HWDATA(RegCR2'range);
					when x"04" => RegARR <= SlaveIn.HWDATA(RegARR'range);
					when others =>
				end case;
			end if;

			-- Check for transfer
			if transfer = '1' and invalid = '0' then
				-- Read operation: retrieve data and fill empty spaces with '0'
				if SlaveIn.HWRITE = '0' then
					SlaveOut.HRDATA <= (others => '0');

					case address is
						when x"00" => SlaveOut.HRDATA(RegCNT'range)    <= RegCNT;
						when x"01" => SlaveOut.HRDATA(RegSTATUS'range) <= RegSTATUS;
						when x"02" => SlaveOut.HRDATA(RegCR1'range)    <= RegCR1;
						when x"03" => SlaveOut.HRDATA(RegCR2'range)    <= RegCR2;
						when x"04" => SlaveOut.HRDATA(RegARR'range)    <= RegARR;
						when others =>
					end case;
				end if;

				-- Keep address and write command for next cycle
				lastaddr <= address;
				lastwr <= SlaveIn.HWRITE;
			else
				lastwr <= '0';
			end if;

			--------------------------------
			-- Disable
			if SigPE = '0' then
				prescaler <= (others => '0');
				FlagUIF <= '0';

			elsif unsigned(prescaler) < unsigned(SigPSC) then
				prescaler <= std_logic_vector(unsigned(prescaler) + 1);

			-- Run
			else
				-- Reset prescaler
				prescaler <= (others => '0');

				--------------------------------
				-- Clock divider
				if unsigned(counter) < unsigned(SigARR) then
					-- Increment counter
					counter <= std_logic_vector(unsigned(counter) + 1);

				else
					-- Reset counter
					counter <= (others => '0');
					-- Set update flag
					FlagUIF <= '1';
				end if;
			end if;
		end if;
	end process;

end;
