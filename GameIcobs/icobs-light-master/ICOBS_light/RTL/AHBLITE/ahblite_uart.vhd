----------------------------------------------------------------
-- UART module with AHB-Lite interface
-- Guillaume Patrigeon
-- Update: 10-05-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library amba3;
use amba3.ahblite.all;


----------------------------------------------------------------
entity ahblite_uart is port (
	HRESETn     : in  std_logic;
	HCLK        : in  std_logic;
	GCLK        : in  std_logic;
	HSEL        : in  std_logic;
	HREADY      : in  std_logic;

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector;

	-- Interrupt request
	IRQ         : out std_logic;

	-- IO access
	RXD_READ    : in  std_logic;

	TXD_DOUT    : out std_logic;
	TXD_TRIS    : out std_logic);
end;


----------------------------------------------------------------
architecture arch of ahblite_uart is

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
	-- |  x000  | DATA   | Data Register               |
	-- |  x004  | STATUS | Status Register             |
	-- |  x008  | CR1    | Control Register 1          |
	-- |  x00C  | CR2    | Control Register 2          |
	-- +--------+--------+-----------------------------+

	signal RegRXDATA  : std_logic_vector(7 downto 0);
	signal RegTXDATA  : std_logic_vector(7 downto 0);
	signal RegSTATUS  : std_logic_vector(5 downto 1);
	signal RegCR1     : std_logic_vector(5 downto 0);
	signal RegCR2     : std_logic_vector(15 downto 0);

	-- STATUS signals
	signal FlagRXBF   : std_logic; -- Receive Buffer Full
	signal FlagTXBE   : std_logic; -- Transmit Buffer Empty
	signal FlagTC     : std_logic; -- Transfer Complete
	signal FlagFRERR  : std_logic; -- Framing Error
	signal FlagBRKR   : std_logic; -- Break Received

	-- CR1 signals
	signal SigPE      : std_logic; -- Peripheral Enable
	signal SigRXBFIE  : std_logic; -- Receive Buffer Full Interrupt Enable
	signal SigTXBEIE  : std_logic; -- Transmit Buffer Empty Interrupt Enable
	signal SigTCIE    : std_logic; -- Transfer Complete Interrupt Enable
	signal SigFRERRIE : std_logic; -- Framing Error Interrupt Enable
	signal SigBRKRIE  : std_logic; -- Break Received Interrupt Enable

	-- CR2 signals
	signal SigCLKDIV  : std_logic_vector(15 downto 0);

	-- Receiver signals
	signal RxFilter   : std_logic_vector(3 downto 0);
	signal RxBit      : std_logic;
	signal RxLastBit  : std_logic;

	signal RxCounter  : integer range 0 to 3;
	signal RxStep     : integer range 0 to 10;
	signal RxShifter  : std_logic_vector(7 downto 0);

	-- Transmitter signals
	signal TxCounter  : integer range 0 to 3;
	signal TxStep     : integer range 0 to 10;
	signal TxShifter  : std_logic_vector(7 downto 0);

	-- Others
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
	-- Assign signals for STATUS registers:
	RegSTATUS(1) <= FlagRXBF;
	RegSTATUS(2) <= FlagTXBE;
	RegSTATUS(3) <= FlagTC;
	RegSTATUS(4) <= FlagFRERR;
	RegSTATUS(5) <= FlagBRKR;

	-- Assign signals for CR1 registers:
	SigPE      <= RegCR1(0);
	SigRXBFIE  <= RegCR1(1);
	SigTXBEIE  <= RegCR1(2);
	SigTCIE    <= RegCR1(3);
	SigFRERRIE <= RegCR1(4);
	SigBRKRIE  <= RegCR1(5);

	-- Assign signals for CR2 registers:
	SigCLKDIV <= RegCR2(15 downto 0);

	-- Interrupts:
	IRQ <= SigPE and ((FlagRXBF and SigRXBFIE) or
					(FlagTXBE and SigTXBEIE) or
					(FlagTC and SigTCIE) or
					(FlagFRERR and SigFRERRIE) or
					(FlagBRKR and SigBRKRIE));

	-- Receiver filter:
	RxBit <= ((RxFilter(2) and RxFilter(1)) or (RxFilter(3) and RxFilter(1)) or (RxFilter(3) and RxFilter(2)));

	-- Output always enabled
	TXD_TRIS <= '0';


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
			RegRXDATA <= (others => '0');
			RegTXDATA <= (others => '0');
			RegCR1 <= (others => '0');
			RegCR2 <= (others => '0');

			counter <= (others => '0');

			-- Receiver
			RxFilter  <= (others => '0');
			RxLastBit <= '0';

			RxStep    <= 0;
			RxCounter <= 0;
			RxStep    <= 0;
			RxShifter <= (others => '0');

			FlagRXBF  <= '0';
			FlagFRERR <= '0';
			FlagBRKR  <= '0';

			-- Transmitter
			TxStep    <= 0;
			TxCounter <= 0;
			TxStep    <= 0;
			TxShifter <= (others => '0');

			FlagTXBE <= '1';
			FlagTC   <= '1';

			TXD_DOUT <= '1';


		--------------------------------
		elsif rising_edge(HCLK) and GCLK = '1' then
			-- Bus access

			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"00" => RegTXDATA <= SlaveIn.HWDATA(RegTXDATA'range); FlagTXBE <= '0';

					when x"01" =>
						if SlaveIn.HWDATA(4) = '0' then FlagFRERR <= '0'; end if;
						if SlaveIn.HWDATA(5) = '0' then FlagBRKR <= '0'; end if;

					when x"02" => RegCR1 <= SlaveIn.HWDATA(RegCR1'range);
					when x"03" => RegCR2 <= SlaveIn.HWDATA(RegCR2'range);
					when others =>
				end case;
			end if;

			-- Check for transfer
			if transfer = '1' and invalid = '0' then
				-- Read operation: retrieve data and fill empty spaces with '0'
				if SlaveIn.HWRITE = '0' then
					SlaveOut.HRDATA <= (others => '0');

					case address is
						when x"00" => SlaveOut.HRDATA(RegRXDATA'range) <= RegRXDATA; FlagRXBF <= '0';
						when x"01" => SlaveOut.HRDATA(RegSTATUS'range) <= RegSTATUS;
						when x"02" => SlaveOut.HRDATA(RegCR1'range)    <= RegCR1;
						when x"03" => SlaveOut.HRDATA(RegCR2'range)    <= RegCR2;
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
				counter <= (others => '0');

				-- Receiver
				RxFilter <= (others => '0');
				RxLastBit <= '0';
				RxStep <= 0;

				-- Transmitter
				TxStep <= 0;
				TXD_DOUT <= '1';

			-- Run
			elsif unsigned(counter) = 0 then
				-- Reload counter
				counter <= SigCLKDIV;

				--------------------------------
				-- Receiver

				-- Filter
				RxFilter <= RxFilter(2 downto 0) & RXD_READ;
				RxLastBit <= RxBit;

				-- Check state
				if RxStep = 0 then
					-- Detect start bit
					if RxBit = '0' and RxLastBit = '1' then
						-- Initialize FSM
						RxStep <= 10;
						-- Reset counter
						RxCounter <= 0;
					end if;

				-- Clock divider
				elsif RxCounter = 0 then
					-- Reset counter
					RxCounter <= 3;
					-- Next step
					RxStep <= RxStep - 1;
					-- Check last bit
					if RxStep = 1 then
						-- Should end whith '1'
						if RxBit = '1' then
							-- Update data register and flag
							RegRXDATA <= RxShifter;
							FlagRXBF <= '1';
						-- Check for break
						elsif RxShifter = x"00" then
							FlagBRKR <= '1';
						-- Framing error
						else
							FlagFRERR <= '1';
						end if;
					else
						-- Update shifter
						RxShifter <= RxBit & RxShifter(7 downto 1);
					end if;
				else
					RxCounter <= RxCounter - 1;
				end if;

				--------------------------------
				-- Transmitter

				-- Check state
				if TxStep = 0 then
					-- Shifter empty
					if FlagTXBE = '0' then
						-- Initialize FSM
						TxStep <= 10;
						-- Reset counter
						TxCounter <= 0;
						-- Load shifter with new value
						TxShifter <= RegTXDATA;
						-- Update flags
						FlagTXBE <= '1';
						FlagTC <= '0';
						-- First bit
						TXD_DOUT <= '0';
					else
						FlagTC <= '1';
					end if;

				-- Clock divider
				elsif TxCounter = 3 then
					-- Reset counter
					TxCounter <= 0;
					-- Next step
					TxStep <= TxStep - 1;
					-- Update shifter
					TXD_DOUT <= TxShifter(0);
					TxShifter <= '1' & TxShifter(7 downto 1);
				else
					TxCounter <= TxCounter + 1;
				end if;
			else
				counter <= std_logic_vector(unsigned(counter) - 1);
			end if;
		end if;
	end process;

end;
