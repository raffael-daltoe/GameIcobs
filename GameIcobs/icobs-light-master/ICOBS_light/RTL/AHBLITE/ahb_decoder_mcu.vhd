----------------------------------------------------------------
-- MCU address decoder module
-- Guillaume Patrigeon & Theo Soriano
-- Update: 10-02-2023
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common;
use common.constants.all;

----------------------------------------------------------------
entity ahb_decoder_mcu is port (
	HRESETn 			: in  std_logic;
	HCLK    			: in  std_logic;
	HREADY  			: in  std_logic;

	HADDR   			: in  std_logic_vector(31 downto 0);

	HSEL    			: out std_logic_vector(CID_MAX downto 0);
	LASTSEL 			: out integer range 0 to CID_MAX);
end;

----------------------------------------------------------------
architecture arch of ahb_decoder_mcu is

	signal address 		: std_logic_vector(HADDR'range);
	signal sel 			: CID_ENUM;

----------------------------------------------------------------
begin

	process (HADDR) begin
		address <= HADDR;
	end process;

	process (address) begin
		case address(31 downto 24) is
			when x"11" =>
				case address(23 downto 20) is
					when x"0" =>
						case address(19 downto 10) is
							when x"00" & "00" => sel <= CID_GPIOA;
							when x"00" & "01" => sel <= CID_GPIOB;
							when x"00" & "10" => sel <= CID_GPIOC;

							when x"11" & "00" => sel <= CID_RSTCLK;

							when x"18" & "00" => sel <= CID_TIMER1;

							when x"20" & "00" => sel <= CID_UART1;

							when x"22" & "00" => sel <= CID_MY_PERIPH;  --0001 0001 0000 0010 0010 0000 0000 0000 = 0x11022000

							when x"24" & "00" => sel <= CID_MY_VGA; 	--0001 0001 0000 0100 0100 0000 0000 0000 = 0x11024000

							when others => sel <= CID_DEFAULT;
						end case;
					when others => sel <= CID_DEFAULT;
				end case ;
			when others => sel <= CID_DEFAULT;
		end case;
	end process;


	--------------------------------
	process (sel, HRESETn) begin
		HSEL <= (others => '0');

		if HRESETn = '1' then
			HSEL(CID_ENUM'pos(sel)) <= '1';
		end if;
	end process;

	--------------------------------
	process (HCLK, HRESETn) begin
		if HRESETn = '0' then
			LASTSEL <= 0;

		elsif rising_edge(HCLK) then
			if HREADY = '1' then
				LASTSEL <= CID_ENUM'pos(sel);
			end if;
		end if;
	end process;

end;
