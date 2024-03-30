-- ##########################################################
-- ##########################################################
-- ##    __    ______   ______   .______        _______.   ##
-- ##   |  |  /      | /  __  \  |   _  \      /       |   ##
-- ##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
-- ##   |  | |  |     |  |  |  | |   _  <      \   \       ##
-- ##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
-- ##   |__|  \______| \______/  |______/  |_______/       ##
-- ##                                                      ##
-- ##########################################################
-- ##########################################################
-------------------------------------------------------------
-- MCU peripherals top module
-- ICOBS MK7
-- Author: Theo Soriano
-- Update: 07-04-2021
-- LIRMM, Univ Montpellier, CNRS, Montpellier, France
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library amba3;
use amba3.ahblite.all;

library common;
use common.constants.all;

library interface;
use interface.obi_lib.all;

----------------------------------------------------------------
entity mcu_peripherals is port (
	PWRRESET  				: in  std_logic;
	HARDRESET 				: in  std_logic;
	SYSCLK    				: in  std_logic;
	RSTn 					: out std_logic;

	IRQ_FAST  				: out std_logic_vector(14 downto 0);
	BOOT_ADR				: out std_logic_vector(31 downto 0);

	-- Slave interface to connect PERIPH master
	periph_slvi_vec   		: in  MTS_vector;
	periph_slvo_vec   		: out STM_vector;

	--sw_mcu					: in std_logic_vector(11 downto 0);
	-- GPIO
	IOPA_READ 				: in  std_logic_vector(IOPA_LEN-1 downto 0);
	IOPA_DOUT 				: out std_logic_vector(IOPA_LEN-1 downto 0);
	IOPA_TRIS 				: out std_logic_vector(IOPA_LEN-1 downto 0);

	IOPB_READ 				: in  std_logic_vector(IOPB_LEN-1 downto 0);
	IOPB_DOUT 				: out std_logic_vector(IOPB_LEN-1 downto 0);
	IOPB_TRIS 				: out std_logic_vector(IOPB_LEN-1 downto 0);

	IOPC_READ 				: in  std_logic_vector(IOPC_LEN-1 downto 0);
	IOPC_DOUT 				: out std_logic_vector(IOPC_LEN-1 downto 0);
	IOPC_TRIS 				: out std_logic_vector(IOPC_LEN-1 downto 0);

	seg						: OUT std_logic_vector(0 to 6);
	an						: OUT std_logic_vector(3 downto 0);
	dp 						: OUT std_logic;

	vgaRed_mcu				: OUT STD_LOGIC_VECTOR(3 downto 0);
	vgaGreen_mcu    		: OUT STD_LOGIC_VECTOR(3 downto 0);
	vgaBLue_mcu  			: OUT STD_LOGIC_VECTOR(3 downto 0);
	
	Hsync_mcu 				: OUT STD_lOGIC;
 	Vsync_mcu 				: OUT STD_lOGIC; 


	UART_RX					: in  std_logic;
	UART_TX					: out std_logic);
end;

----------------------------------------------------------------
architecture arch of mcu_peripherals is

	component obi_2_ahb
	port (
		HRESETn : in  std_logic;
		HCLK    : in  std_logic;

		-- OBI Slave interface : receive data from OBI Master
		OBI_MTS_vec       : in  MTS_vector;
		OBI_STM_vec       : out STM_vector;

		-- AHB Lite
		AHB_hrdata_i 		: in  STD_LOGIC_VECTOR ( 31 downto 0 );
		AHB_hready_i 		: in  STD_LOGIC;
		AHB_hresp_i 		: in  STD_LOGIC;
		AHB_haddr_o 		: out STD_LOGIC_VECTOR ( 31 downto 0 );
		AHB_hburst_o 		: out STD_LOGIC_VECTOR ( 2 downto 0 );
		AHB_hmastlock_o 	: out STD_LOGIC;
		AHB_hprot_o 		: out STD_LOGIC_VECTOR ( 3 downto 0 );
		AHB_hsize_o 		: out STD_LOGIC_VECTOR ( 2 downto 0 );
		AHB_htrans_o 		: out STD_LOGIC_VECTOR ( 1 downto 0 );
		AHB_hwdata_o 		: out STD_LOGIC_VECTOR ( 31 downto 0 );
		AHB_hwrite_o 		: out STD_LOGIC);
	end component;

	component ahb_decoder_mcu
	port (
		HRESETn : in  std_logic;
		HCLK    : in  std_logic;
		HREADY  : in  std_logic;

		HADDR   : in  std_logic_vector(31 downto 0);

		HSEL    : out std_logic_vector(CID_MAX downto 0);
		LASTSEL : out integer range 0 to CID_MAX);
	end component;

	component ahblite_defaultslave
	port (
		HRESETn     : in  std_logic;
		HCLK        : in  std_logic;
		HSEL        : in  std_logic;
		HREADY      : in  std_logic;

		-- AHB-Lite interface
		AHBLITE_IN  : in  AHBLite_master_vector;
		AHBLITE_OUT : out AHBLite_slave_vector);
	end component;

	component ahblite_rstclk
	port (
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
	end component;

	component ahblite_gpio
	generic (N : positive range 1 to 16);
	port (
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
	end component;

	component ahblite_timer port (
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
	end component;

	component ahblite_uart
	port (
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
	end component;

	component ahblite_my_periph
	port (
		HRESETn     : in  std_logic;
		HCLK        : in  std_logic;

		HSEL        : in  std_logic;
		HREADY      : in  std_logic;

		seg			: OUT std_logic_vector(0 to 6);
		an			: OUT std_logic_vector(3 downto 0);
		dp 			: OUT std_logic;

		-- AHB-Lite interface
		AHBLITE_IN  : in  AHBLite_master_vector;
		AHBLITE_OUT : out AHBLite_slave_vector);
	end component;

	component ahblite_vga
	port (
		HRESETn          : in  std_logic;
		HCLK             : in  std_logic;

		HSEL             : in  std_logic;
		HREADY           : in  std_logic;

		-- Outputs of VGA 
		vgaRed_ahblite   : OUT std_logic_vector(3 downto 0);
		vgaGreen_ahblite : OUT std_logic_vector(3 downto 0);
		vgaBLue_ahblite  : OUT std_logic_vector(3 downto 0);
		Hsync_ahblite    : OUT std_logic;
		Vsync_ahblite    : OUT std_logic; 

		-- AHB-Lite interface
		AHBLITE_IN  : in  AHBLite_master_vector;
		AHBLITE_OUT : out AHBLite_slave_vector);
	end component;

	-- Reset
	signal HRESETn   : std_logic;

	-- Clock
	signal HCLK : std_logic;
	signal GCLK : std_logic_vector(GCLK_MAX downto 0);

	-- Memory selection
	signal REMAP_s : std_logic_vector(1 downto 0);

	-- AHB-Lite bus
	signal AHBLite_in   : AHBLite_slave;
	signal AHBLite_out  : AHBLite_master;
	signal MasterIn     : AHBLite_slave;
	signal MasterOut    : AHBLite_master;
	signal BusMasterIn  : AHBLite_slave_vector;
	signal BusMasterOut : AHBLite_master_vector;

	type BUS_SLAVE_ARRAY is array (0 to CID_MAX) of AHBLite_slave_vector;
	signal BusSlaveArray : BUS_SLAVE_ARRAY;

	signal HSEL    : std_logic_vector(CID_MAX downto 0);
	signal LASTSEL : integer range 0 to CID_MAX;

	----------------------------------------------------------------
	-- GPIO
	signal GPIOA_DOUT : std_logic_vector(IOPA_LEN-1 downto 0);
	signal GPIOB_DOUT : std_logic_vector(IOPB_LEN-1 downto 0);
	signal GPIOC_DOUT : std_logic_vector(IOPC_LEN-1 downto 0);

	signal GPIOA_TRIS : std_logic_vector(IOPA_LEN-1 downto 0);
	signal GPIOB_TRIS : std_logic_vector(IOPB_LEN-1 downto 0);
	signal GPIOC_TRIS : std_logic_vector(IOPC_LEN-1 downto 0);

	signal M_AHB_0_haddr 		: STD_LOGIC_VECTOR ( 31 downto 0 );
	signal M_AHB_0_hburst 		: STD_LOGIC_VECTOR ( 2 downto 0 );
	signal M_AHB_0_hmastlock 	: STD_LOGIC;
	signal M_AHB_0_hprot 		: STD_LOGIC_VECTOR ( 3 downto 0 );
	signal M_AHB_0_hrdata 		: STD_LOGIC_VECTOR ( 31 downto 0 );
	signal M_AHB_0_hready 		: STD_LOGIC;
	signal M_AHB_0_hresp 		: STD_LOGIC;
	signal M_AHB_0_hsize 		: STD_LOGIC_VECTOR ( 2 downto 0 );
	signal M_AHB_0_htrans 		: STD_LOGIC_VECTOR ( 1 downto 0 );
	signal M_AHB_0_hwdata 		: STD_LOGIC_VECTOR ( 31 downto 0 );
	signal M_AHB_0_hwrite 		: STD_LOGIC;

begin

	-- Port map to ahblite_my_periph
	U_MY_PERIPH: ahblite_my_periph 
	port map ( 
		HRESETn 	=> HRESETn,
		HCLK    	=> HCLK,
		HSEL    	=> HSEL(CID_ENUM'pos(CID_MY_PERIPH)),
		HREADY  	=> MasterIn.HREADYOUT,
		AHBLITE_IN 	=> BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_MY_PERIPH)),
		seg  		=> seg,
		an			=> an,
		dp			=> dp
	);

	VGA_PERIPH: ahblite_vga
	port map(
		HRESETn          => HRESETn,
		HCLK             => HCLK,

		HSEL             => HSEL(CID_ENUM'pos(CID_MY_VGA)),
		HREADY           => MasterIn.HREADYOUT,

		--btnu 			=>	IOPC(0),				-- IOPC[0] = BTNU
		--btnl 			=>	IOPC(1),				-- IOPC[1] = BTNL
		--btnr 			=>	IOPC(2),				-- IOPC[2] = BTNR
		--btnd 			=>	IOPC(3),				-- IOPC[3] = BTND


		--sw				 => IOPA_READ(15 DOWNTO 0),
		-- Outputs of VGA 
		vgaRed_ahblite   => vgaRed_mcu,
		vgaGreen_ahblite => vgaGreen_mcu,
		vgaBLue_ahblite  => vgaBLue_mcu,
		Hsync_ahblite    => Hsync_mcu,
		Vsync_ahblite    => Vsync_mcu,

		-- AHB-Lite interface
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_MY_VGA))
	);
	
	bridge: obi_2_ahb
	port map (
		HRESETn => HRESETn,
		HCLK    => HCLK,

		-- OBI Slave interface : receive data from OBI Master
		OBI_MTS_vec       	=> periph_slvi_vec,
		OBI_STM_vec       	=> periph_slvo_vec,

		-- AHB Lite
		AHB_hrdata_i 		=> M_AHB_0_hrdata,
		AHB_hready_i 		=> M_AHB_0_hready,
		AHB_hresp_i 		=> M_AHB_0_hresp,
		AHB_haddr_o 		=> M_AHB_0_haddr,
		AHB_hburst_o 		=> M_AHB_0_hburst,
		AHB_hmastlock_o 	=> M_AHB_0_hmastlock,
		AHB_hprot_o 		=> M_AHB_0_hprot,
		AHB_hsize_o 		=> M_AHB_0_hsize,
		AHB_htrans_o 		=> M_AHB_0_htrans,
		AHB_hwdata_o 		=> M_AHB_0_hwdata,
		AHB_hwrite_o 		=> M_AHB_0_hwrite);

	U_DECODER: ahb_decoder_mcu
	port map (
		HRESETn => HRESETn,
		HCLK    => HCLK,
		HREADY  => MasterIn.HREADYOUT,
		HADDR   => MasterOut.HADDR,
		HSEL    => HSEL,
		LASTSEL => LASTSEL);

	U_DEFAULTSLAVE: ahblite_defaultslave
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		HSEL        => HSEL(CID_ENUM'pos(CID_DEFAULT)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_DEFAULT)));

	U_RSTCLK: ahblite_rstclk
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		HSEL        => HSEL(CID_ENUM'pos(CID_RSTCLK)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_RSTCLK)),
		PWRRESET    => PWRRESET,
		HARDRESET   => HARDRESET,
		GCLK        => GCLK,
		BOOT_ADR    => BOOT_ADR);

	U_GPIOA: ahblite_gpio
	generic map (IOPA_LEN)
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		GCLK        => GCLK(GCLK_ENUM'pos(GCLK_GPIOA)),
		HSEL        => HSEL(CID_ENUM'pos(CID_GPIOA)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_GPIOA)),
		IOP_READ    => IOPA_READ,
		IOP_DOUT    => IOPA_DOUT,
		IOP_TRIS    => IOPA_TRIS);

	U_GPIOB: ahblite_gpio
	generic map (IOPB_LEN)
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		GCLK        => GCLK(GCLK_ENUM'pos(GCLK_GPIOB)),
		HSEL        => HSEL(CID_ENUM'pos(CID_GPIOB)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_GPIOB)),
		IOP_READ    => IOPB_READ,
		IOP_DOUT    => IOPB_DOUT,
		IOP_TRIS    => IOPB_TRIS);

	U_GPIOC: ahblite_gpio
	generic map (IOPC_LEN)
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		GCLK        => GCLK(GCLK_ENUM'pos(GCLK_GPIOC)),
		HSEL        => HSEL(CID_ENUM'pos(CID_GPIOC)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_GPIOC)),
		IOP_READ    => IOPC_READ,
		IOP_DOUT    => IOPC_DOUT,
		IOP_TRIS    => IOPC_TRIS);

	U_TIMER1: ahblite_timer
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		GCLK        => GCLK(GCLK_ENUM'pos(GCLK_TIMER1)),
		HSEL        => HSEL(CID_ENUM'pos(CID_TIMER1)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_TIMER1)),
		IRQ         => IRQ_FAST(0));

	U_UART1: ahblite_uart
	port map (
		HRESETn     => HRESETn,
		HCLK        => HCLK,
		GCLK        => GCLK(GCLK_ENUM'pos(GCLK_UART1)),
		HSEL        => HSEL(CID_ENUM'pos(CID_UART1)),
		HREADY      => MasterIn.HREADYOUT,
		AHBLITE_IN  => BusMasterOut,
		AHBLITE_OUT => BusSlaveArray(CID_ENUM'pos(CID_UART1)),
		IRQ         => IRQ_FAST(4),
		RXD_READ    => UART_RX,
		TXD_DOUT    => UART_TX);

	AHBLite_out.HADDR 		<=	M_AHB_0_haddr;
	AHBLite_out.HBURST 		<=	M_AHB_0_hburst;
	AHBLite_out.HMASTLOCK 	<=	M_AHB_0_hmastlock;
	AHBLite_out.HPROT 		<=	M_AHB_0_hprot;
	AHBLite_out.HSIZE 		<=	M_AHB_0_hsize;
	AHBLite_out.HTRANS 		<=	M_AHB_0_htrans;
	AHBLite_out.HWDATA 		<=	M_AHB_0_hwdata;
	AHBLite_out.HWRITE 		<=	M_AHB_0_hwrite;

	M_AHB_0_hrdata 			<= AHBLite_in.HRDATA;
	M_AHB_0_hready 			<= AHBLite_in.HREADYOUT;
	M_AHB_0_hresp 			<= AHBLite_in.HRESP;

	BusMasterOut <= to_vector(AHBLite_out);
	AHBLite_in <= to_record(BusMasterIn);

	MasterIn  <= to_record(BusMasterIn);
	MasterOut <= to_record(BusMasterOut);

	HCLK <= SYSCLK;
	RSTn <= HRESETn;

	-- AHB-Lite bus multiplexor
	BusMasterIn <= BusSlaveArray(LASTSEL);

	IRQ_FAST(3 downto 1) <= (others => '0');
	IRQ_FAST(11 downto 5) <= (others => '0');
	IRQ_FAST(14 downto 13) <= (others => '0');

end;
