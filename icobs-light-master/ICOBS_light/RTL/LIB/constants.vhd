----------------------------------------------------------------
-- Constants definition
-- Guillaume Patrigeon & Theo Soriano
-- Update: 19-06-2021
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------
package constants is
	----------------------------------------------------------------

	-- Ranges
	constant IOPA_LEN : integer := 16;
	constant IOPB_LEN : integer := 16;
	constant IOPC_LEN : integer := 4;

	----------------------------------------------------------------
	-- Gated clocks
	type GCLK_ENUM is (
		GCLK_GPIOA,
		GCLK_GPIOB,
		GCLK_GPIOC,

		GCLK_TIMER1,

		GCLK_UART1);

	constant GCLK_MAX : integer := GCLK_ENUM'pos(GCLK_ENUM'right);

	----------------------------------------------------------------
	-- Components identifier
	type CID_ENUM is (
		CID_DEFAULT,

		CID_GPIOA,
		CID_GPIOB,
		CID_GPIOC,

		CID_RSTCLK,

		CID_TIMER1,

		CID_UART1,
		
		CID_MY_PERIPH,
		
		CID_MY_VGA
		);

	constant CID_MAX : integer := CID_ENUM'pos(CID_ENUM'right);

end package;
