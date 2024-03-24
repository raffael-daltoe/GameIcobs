----------------------------------------------------------------
-- Reset and clock controller with AHB-Lite interface
-- Guillaume Patrigeon & Theo Soriano
-- Update: 19-06-2021
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library amba3;
use amba3.ahblite.all;

library common;
use common.constants.all;

----------------------------------------------------------------
entity ahblite_rstclk is port (
	HRESETn     : out std_logic;
	HCLK        : in  std_logic;
	HSEL        : in  std_logic;
	HREADY      : in  std_logic;

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector;

	-- Reset
	PWRRESET    : in  std_logic;
	HARDRESET   : in  std_logic;

	-- Gated clocks control
	GCLK        : out std_logic_vector(GCLK_MAX downto 0);

	-- Boot memory selection
	BOOT_ADR 	: out std_logic_vector(31 downto 0));
end;

----------------------------------------------------------------
architecture arch of ahblite_rstclk is

	signal transfer : std_logic;
	signal invalid  : std_logic;
	signal SlaveIn  : AHBLite_master;
	signal SlaveOut : AHBLite_slave;

	signal address  : std_logic_vector(9 downto 2);
	signal lastaddr : std_logic_vector(9 downto 2);
	signal lastwr   : std_logic;

	-- Memory organization:
	-- +--------+-----------+-------------------------------------+
	-- | OFFSET | NAME      | DESCRIPTION                         |
	-- +--------+-----------+-------------------------------------+
	-- |  x000  | RSTSTATUS | Reset status register               |
	-- |  x004  | BOOTOPT   | Boot option register                |
	-- |  x008  |           | RESERVED FOR CLOCK SOURCE SELECTION |
	-- |  x00C  |           | RFU                                 |
	-- |  x010  | CLKENR    | Clock enable register               |
	-- +--------+-----------+-------------------------------------+

	signal RegRSTSTATUS : std_logic_vector(3 downto 0);
	signal RegBOOTOPT   : std_logic_vector(3 downto 0);
	signal RegCLKEN     : std_logic_vector(GCLK_MAX downto 0);

	-- RSTSTATUS signals
	signal FlagPWRRESET  : std_logic; -- Power Reset
	signal FlagHARDRESET : std_logic; -- Hard Reset
	signal FlagWDRESET   : std_logic; -- Watchdog Reset
	signal FlagSOFTRESET : std_logic; -- Software Reset

	-- BOOTOPT signals
	signal SigMEMSEL  : std_logic_vector(1 downto 0); -- Memory selected by user
	signal SigBOOTMEM : std_logic_vector(1 downto 0); -- Boot memory selection

	-- Reset
	signal SOFTRESET 		: std_logic;
	signal WDRESET 			: std_logic;
	signal RESET   			: std_logic;
	signal long_SOFTRESET   : std_logic;

	signal ClrPWRRESET  : std_logic; -- Power Reset
	signal ClrHARDRESET : std_logic; -- Hard Reset
	signal ClrWDRESET   : std_logic; -- Watchdog Reset
	signal ClrSOFTRESET : std_logic; -- Software Reset

	TYPE State_Machine is (WAIT_FOR_SOFT, COUNT);
	signal state, next_state : State_Machine;
	signal CPT_VAL 		: std_logic_vector(4 downto 0);
	signal CPT_EN 		: std_logic;

----------------------------------------------------------------
begin

	AHBLITE_OUT <= to_vector(SlaveOut);
	SlaveIn <= to_record(AHBLITE_IN);

	transfer <= HSEL and SlaveIn.HTRANS(1) and HREADY;
	-- Invalid if not a 32-bit aligned transfer
	invalid  <= transfer and (SlaveIn.HSIZE(2) or (not SlaveIn.HSIZE(1)) or SlaveIn.HSIZE(0) or SlaveIn.HADDR(1) or SlaveIn.HADDR(0));

	address <= SlaveIn.HADDR(address'range);

	----------------------------------------------------------------
	-- Assign signals for RSTSTATUS registers:
	RegRSTSTATUS(0) <= FlagPWRRESET;
	RegRSTSTATUS(1) <= FlagHARDRESET;
	RegRSTSTATUS(2) <= FlagWDRESET;
	RegRSTSTATUS(3) <= FlagSOFTRESET;

	-- Assign signals for BOOTOPT registers:
	RegBOOTOPT(1 downto 0) <= SigMEMSEL;
	RegBOOTOPT(3 downto 2) <= SigBOOTMEM;

	-- Gated clocks control output
	GCLK <= RegCLKEN;

	----------------------------------------------------------------
	-- Not implemented
	WDRESET <= '1';

	-- Reset
	HRESETn <= RESET;

	-- Reset synchronization
	process (HCLK, PWRRESET) begin
		if PWRRESET = '0' then
			RESET  <= '0';

			FlagPWRRESET  <= '1';
			FlagHARDRESET <= '0';
			FlagWDRESET   <= '0';
			FlagSOFTRESET <= '0';

			SigBOOTMEM <= (others => '0');

		elsif rising_edge(HCLK) then
			RESET <= HARDRESET and WDRESET and not long_SOFTRESET;

			if ClrPWRRESET = '1' then
				FlagPWRRESET <= '0';
			end if;

			if ClrHARDRESET = '1' then
				FlagHARDRESET <= '0';
			end if;

			if ClrWDRESET = '1' then
				FlagWDRESET <= '0';
			end if;

			if ClrSOFTRESET = '1' then
				FlagSOFTRESET <= '0';
			end if;

			-- Software reset
			if HARDRESET = '0' then
				FlagHARDRESET <= '1';

			-- Watchdog reset
			elsif WDRESET = '0' then
				FlagWDRESET <= '1';

			-- Software reset
			elsif SOFTRESET = '1' then
				FlagSOFTRESET <= '1';
			end if;

			-- Reset values
			if (HARDRESET and WDRESET) = '0' then
				SigBOOTMEM <= (others => '0');

			elsif SOFTRESET = '1' then
				SigBOOTMEM <= SigMEMSEL;
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	process (HCLK, RESET, PWRRESET, HARDRESET, WDRESET) begin
		if RESET = '0' then
			-- Reset
			SlaveOut.HREADYOUT <= '1';
			SlaveOut.HRESP <= '0';
			SlaveOut.HRDATA <= (others => '0');

			lastwr <= '0';
			lastaddr <= (others => '0');

			if (PWRRESET and HARDRESET and WDRESET) = '0' then
				SigMEMSEL <= (others => '0');
			end if;

			RegCLKEN <= (others => '0');

			ClrPWRRESET  <= '0';
			ClrHARDRESET <= '0';
			ClrWDRESET   <= '0';
			ClrSOFTRESET <= '0';

			SOFTRESET    <= '0';

		--------------------------------
		elsif rising_edge(HCLK) then
			-- Bus acces

			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"00" =>
						if SlaveIn.HWDATA(0) = '0' then ClrPWRRESET  <= '1'; end if;
						if SlaveIn.HWDATA(1) = '0' then ClrHARDRESET <= '1'; end if;
						if SlaveIn.HWDATA(2) = '0' then ClrWDRESET   <= '1'; end if;
						if SlaveIn.HWDATA(3) = '0' then ClrSOFTRESET <= '1'; end if;

					when x"01" =>
							SigMEMSEL <= SlaveIn.HWDATA(SigMEMSEL'range);
							SOFTRESET <= SlaveIn.HWDATA(8);

					when x"04" => RegCLKEN  <= SlaveIn.HWDATA(RegCLKEN'range);
					when others =>
				end case;
			end if;

			-- Check for transfer
			if transfer = '1' and invalid = '0' then
				-- Read operation: retrieve data and fill empty spaces with '0'
				if SlaveIn.HWRITE = '0' then
					SlaveOut.HRDATA <= (others => '0');

					case address is
						when x"00" => SlaveOut.HRDATA(RegRSTSTATUS'range) <= RegRSTSTATUS;
						when x"01" => SlaveOut.HRDATA(RegBOOTOPT'range)   <= RegBOOTOPT;
						when x"04" => SlaveOut.HRDATA(RegCLKEN'range)     <= RegCLKEN;
						when others =>
					end case;
				end if;

				-- Keep address and write command for next cycle
				lastaddr <= address;
				lastwr <= SlaveIn.HWRITE;
			else
				lastwr <= '0';
			end if;

			-- Clear flags
			if ClrPWRRESET = '1' then
				ClrPWRRESET  <= '0';
			end if;

			if ClrHARDRESET = '1' then
				ClrHARDRESET <= '0';
			end if;

			if ClrWDRESET = '1' then
				ClrWDRESET   <= '0';
			end if;

			if ClrSOFTRESET = '1' then
				ClrSOFTRESET <= '0';
			end if;
		end if;
	end process;

	process (HCLK, PWRRESET, SigMEMSEL) begin
		if PWRRESET = '0' then
			BOOT_ADR <= x"08000000";
		elsif rising_edge(HCLK) then
			case SigMEMSEL is
				when "01" => BOOT_ADR <= x"10000000";
				when others => BOOT_ADR <= x"08000000";
			end case;
		end if;
	end process;

	process (HCLK, PWRRESET, CPT_EN) begin
		if PWRRESET = '0' then
			CPT_VAL <= (others => '0');
		elsif rising_edge(HCLK) then
			if CPT_EN = '1' then
				CPT_VAL <= std_logic_vector(unsigned(CPT_VAL) + 1);
			else
				CPT_VAL <= (others => '0');
			end if;
		end if;
	end process;

	process (HCLK, PWRRESET)
    begin
        if PWRRESET = '0' then
            state <= WAIT_FOR_SOFT;
        elsif rising_edge(HCLK) then
            state <= next_state;
        end if;
    end process;

	process (state, SOFTRESET, CPT_VAL)
    begin
    case state is
        when WAIT_FOR_SOFT => if SOFTRESET = '1' then
                                next_state <= COUNT;
                            else
                                next_state <= WAIT_FOR_SOFT;
                            end if;

        when COUNT    => if CPT_VAL(4) = '1' then
                                next_state <= WAIT_FOR_SOFT;
                            else
                                next_state <= COUNT;
                            end if;
    end case;
    end process;

	process(state)
	begin
		long_SOFTRESET <= '0';
		CPT_EN <= '0';
		if state = COUNT then
			long_SOFTRESET <= '1';
			CPT_EN <= '1';
		end if;
	end process;

end;
