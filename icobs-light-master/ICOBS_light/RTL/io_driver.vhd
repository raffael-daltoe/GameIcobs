----------------------------------------------------------------
-- I/O driver for FPGA implementation
-- Guillaume Patrigeon
-- Update: 12-02-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------
entity io_driver is generic (N : integer := 16); port (
	TS : in    std_logic_vector(N-1 downto 0);
	WR : in    std_logic_vector(N-1 downto 0);
	RD : out   std_logic_vector(N-1 downto 0);
	IO : inout std_logic_vector(N-1 downto 0));
end;


----------------------------------------------------------------
architecture arch of io_driver is

	component IBUF is
	port (
		I : in  std_logic;
		O : out std_logic);
	end component;


	component OBUFT is
	port (
		T : in  std_logic;
		I : in  std_logic;
		O : out std_logic);
	end component;


----------------------------------------------------------------
begin

	IO_BUF: for i in 0 to N-1 generate
		-- Inputs
		I_BUF: IBUF port map (
			I => IO(i),
			O => RD(i));

		-- Outputs
		O_BUF: OBUFT port map (
			T => TS(i),
			I => WR(i),
			O => IO(i));
	end generate;

end;
