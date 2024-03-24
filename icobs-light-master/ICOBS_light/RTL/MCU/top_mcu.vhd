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
-- MCU top
-- ICOBS MK7
-- Author: Theo Soriano
-- Update: 07-04-2021
-- LIRMM, Univ Montpellier, CNRS, Montpellier, France
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library common;
use common.constants.all;

library interface;
use interface.obi_lib.all;

library amba3;
use amba3.ahblite.all;

----------------------------------------------------------------
entity top_mcu is
	port (
		-- Reset and clock
		PWRRESET  				: in  std_logic;
        HARDRESET 				: in  std_logic;
        SYSCLK    				: in  std_logic;

		-- I/O
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

		--sw_top_mcu				: in std_logic_vector(11 downto 0);

		vgaRed_top_mcu			: OUT STD_LOGIC_VECTOR(3 downto 0);
		vgaGreen_top_mcu    	: OUT STD_LOGIC_VECTOR(3 downto 0);
		vgaBLue_top_mcu  		: OUT STD_LOGIC_VECTOR(3 downto 0);
	
		Hsync_top_mcu 			: OUT STD_lOGIC;
 		Vsync_top_mcu 			: OUT STD_lOGIC; 

		UART_RX					: in  std_logic;
		UART_TX					: out std_logic);
	end;

----------------------------------------------------------------
architecture arch of top_mcu is

	component IBEX_OBI
    port (
        clk_i                   : in  std_logic;
        rst_ni                  : in  std_logic;

        test_en_i               : in  std_logic;

        hart_id_i               : in  std_logic_vector(31 downto 0);
        boot_addr_i             : in  std_logic_vector(31 downto 0);

		-- Inst OBI master interface
        inst_vec_i       		: in  STM_vector;
        inst_vec_o       		: out MTS_vector;

		-- Data OBI master interface
        data_vec_i       		: in  STM_vector;
        data_vec_o       		: out MTS_vector;

		-- Monitor probes
		core_sleep_o 			: out std_logic;
		inst_addr_o 			: out std_logic_vector(31 downto 0);
		inst_gnt_o 				: out std_logic;
		inst_rvalid_o 			: out std_logic;
		data_be_o 				: out std_logic_vector(3 downto 0);
		data_addr_o 			: out std_logic_vector(31 downto 0);
		data_gnt_o 				: out std_logic;
		data_rvalid_o 			: out std_logic;
		data_we_o 				: out std_logic;

		-- others
        irq_software_i          : in  std_logic;
        irq_timer_i             : in  std_logic;
        irq_external_i          : in  std_logic;
        irq_fast_i              : in  std_logic_vector(14 downto 0);
        irq_nm_i                : in  std_logic;

        debug_req_i             : in  std_logic;

        fetch_enable_i          : in  std_logic;
        alert_minor_o           : out std_logic;
        alert_major_o           : out std_logic);
    end component;

    component mcu_interconnect
    port (
	    clk_i   				: in  std_logic;
	    rst_ni  				: in  std_logic;

        -- Slave interface to connect IBEX inst
        inst_slvi_vec   		: in  MTS_vector;
        inst_slvo_vec   		: out STM_vector;

		-- Slave interface to connect IBEX data
        data_slvi_vec   		: in  MTS_vector;
        data_slvo_vec   		: out STM_vector;

		-- RAM1 OBI master interface
        rom0_vec_i       		: in  STM_vector;
        rom0_vec_o       		: out MTS_vector;

        -- RAM1 OBI master interface
        ram1_vec_i       		: in  STM_vector;
        ram1_vec_o       		: out MTS_vector;

        -- RAM2 OBI master interface
        ram2_vec_i       		: in  STM_vector;
        ram2_vec_o       		: out MTS_vector;

        -- PERIPH OBI master interface
        periph_vec_i       		: in  STM_vector;
        periph_vec_o       		: out MTS_vector);
    end component;

	component obi_2_ram
	port (
		clk         : in  std_logic;

		-- OBI Slave interface : receive data from OBI Master
		if_slvi_vec       : in  MTS_vector;
		if_slvo_vec       : out STM_vector;

		-- RAM interface
		ena   					: out std_logic;
		wea   					: out std_logic_vector(3 downto 0);
		addra 					: out std_logic_vector(31 downto 0);
		dina  					: out std_logic_vector(31 downto 0);
		douta 					: in  std_logic_vector(31 downto 0));
	end component;

	component obi_2_rom
	port (
		clk         : in  std_logic;

		-- OBI Slave interface : receive data from OBI Master
		if_slvi_vec       : in  MTS_vector;
		if_slvo_vec       : out STM_vector;

		-- RAM interface
		ena   					: out std_logic;
		addra 					: out std_logic_vector(31 downto 0);
		douta 					: in  std_logic_vector(31 downto 0));
	end component;

	component SPROM_32x1024 -- ROM0
	port (
		clka  : in  std_logic;
		ena   : in  std_logic;
		addra : in  std_logic_vector(9 downto 0);
		douta : out std_logic_vector(31 downto 0));
	end component;

	component SPRAM_32x16384 -- 64 kB RAM
	port (
		clka  					: in  std_logic;
		ena   					: in  std_logic;
		wea   					: in  std_logic_vector(3 downto 0);
		addra 					: in  std_logic_vector(13 downto 0);
		dina  					: in  std_logic_vector(31 downto 0);
		douta 					: out std_logic_vector(31 downto 0));
	end component;

	component mcu_peripherals
		port (
		PWRRESET  				: in  std_logic;
	    HARDRESET 				: in  std_logic;
	    SYSCLK    				: in  std_logic;
	    RSTn 					: out std_logic;

	    IRQ_FAST  				: out std_logic_vector(14 downto 0);
	    BOOT_ADR				: out std_logic_vector(31 downto 0);

		--sw_mcu	     			: in std_logic_vector(11 downto 0);
	    -- Slave interface to connect PERIPH master
	    periph_slvi_vec   		: in  MTS_vector;
	    periph_slvo_vec   		: out STM_vector;

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

		vgaRed_mcu				: OUT STD_LOGIC_VECTOR(3 downto 0);
		vgaGreen_mcu    		: OUT STD_LOGIC_VECTOR(3 downto 0);
		vgaBLue_mcu  			: OUT STD_LOGIC_VECTOR(3 downto 0);
	
		Hsync_mcu 				: OUT STD_lOGIC;
 		Vsync_mcu 				: OUT STD_lOGIC; 

		UART_RX					: in  std_logic;
		UART_TX					: out std_logic;
		seg						: OUT std_logic_vector(0 to 6);
		an						: OUT std_logic_vector(3 downto 0);
		dp 						: OUT std_logic);
	end component;

	-- Reset
	signal HRESETn   		  	: std_logic;

	-- IBEX SIGNALS
    signal boot_addr_s      	: std_logic_vector(31 downto 0);
	signal irq_fast_s       	: std_logic_vector(14 downto 0);
	signal fetch_enable_s		: std_logic;

    signal alert_minor_s    	: std_logic;
    signal alert_major_s    	: std_logic;

	-- Slave interface to connect IBEX inst
	signal inst_MTS_vec_s   	: MTS_vector;
	signal inst_STM_vec_s   	: STM_vector;

	-- Slave interface to connect IBEX data
	signal data_MTS_vec_s   	: MTS_vector;
	signal data_STM_vec_s   	: STM_vector;

	-- ROM0 OBI master interface
	signal rom0_STM_vec_s       : STM_vector;
	signal rom0_MTS_vec_s       : MTS_vector;

	-- RAM1 OBI master interface
	signal ram1_STM_vec_s       : STM_vector;
	signal ram1_MTS_vec_s       : MTS_vector;

	-- RAM2 OBI master interface
	signal ram2_STM_vec_s       : STM_vector;
	signal ram2_MTS_vec_s       : MTS_vector;

	-- PERIPH OBI master interface
	signal periph_STM_vec_s   	: STM_vector;
	signal periph_MTS_vec_s   	: MTS_vector;

	signal Rom0_en_s		    : std_logic;
    signal Rom0_addr_s	      	: std_logic_vector(31 downto 0);
    signal Rom0_data_out_s	  	: std_logic_vector(31 downto 0);

	signal Ram1_en_s		  	: std_logic;
    signal Ram1_write_s       	: std_logic_vector(3 downto 0);
    signal Ram1_addr_s 	      	: std_logic_vector(31 downto 0);
    signal Ram1_data_in_s     	: std_logic_vector(31 downto 0);
    signal Ram1_data_out_s    	: std_logic_vector(31 downto 0);

	signal Ram2_en_s		  	: std_logic;
    signal Ram2_write_s       	: std_logic_vector(3 downto 0);
    signal Ram2_addr_s 	      	: std_logic_vector(31 downto 0);
    signal Ram2_data_in_s     	: std_logic_vector(31 downto 0);
    signal Ram2_data_out_s    	: std_logic_vector(31 downto 0);

begin

	IBEX: IBEX_OBI
    port map (
            clk_i           	=> SYSCLK,
            rst_ni          	=> HRESETn,

            test_en_i          	=> '0',

            hart_id_i          	=> x"00000000",
            boot_addr_i        	=> boot_addr_s,

			inst_vec_i       	=> inst_STM_vec_s,
			inst_vec_o       	=> inst_MTS_vec_s,

			data_vec_i       	=> data_STM_vec_s,
			data_vec_o       	=> data_MTS_vec_s,

            irq_software_i    	=> '0',
            irq_timer_i       	=> '0',
            irq_external_i    	=> '0',
            irq_fast_i        	=> irq_fast_s,
            irq_nm_i          	=> '0',

            debug_req_i        	=> '0',

            fetch_enable_i     	=> '1',
            alert_minor_o      	=> alert_minor_s,
            alert_major_o      	=> alert_major_s);

	interconnect: mcu_interconnect
	port map(
			clk_i           	=> SYSCLK,
			rst_ni          	=> HRESETn,

			inst_slvi_vec   	=> inst_MTS_vec_s,
			inst_slvo_vec   	=> inst_STM_vec_s,

			data_slvi_vec   	=> data_MTS_vec_s,
			data_slvo_vec   	=> data_STM_vec_s,

			rom0_vec_i       	=> rom0_STM_vec_s,
			rom0_vec_o       	=> rom0_MTS_vec_s,

			ram1_vec_i       	=> ram1_STM_vec_s,
			ram1_vec_o       	=> ram1_MTS_vec_s,

			ram2_vec_i       	=> ram2_STM_vec_s,
			ram2_vec_o       	=> ram2_MTS_vec_s,

			periph_vec_i       	=> periph_STM_vec_s,
			periph_vec_o       	=> periph_MTS_vec_s);


	periphs : mcu_peripherals
	port map(
			PWRRESET  			=> PWRRESET,
			HARDRESET 			=> HARDRESET,
			SYSCLK    			=> SYSCLK,
			RSTn 				=> HRESETn,

			IRQ_FAST  			=> irq_fast_s,
			BOOT_ADR			=> boot_addr_s,

			periph_slvi_vec  	=> periph_MTS_vec_s,
			periph_slvo_vec  	=> periph_STM_vec_s,

			IOPA_READ 			=> IOPA_READ,
			IOPA_DOUT 			=> IOPA_DOUT,
			IOPA_TRIS 			=> IOPA_TRIS,

			IOPB_READ 			=> IOPB_READ,
			IOPB_DOUT 			=> IOPB_DOUT,
			IOPB_TRIS 			=> IOPB_TRIS,

			IOPC_READ 			=> IOPC_READ,
			IOPC_DOUT 			=> IOPC_DOUT,
			IOPC_TRIS 			=> IOPC_TRIS,

			-- Outputs of VGA 
			vgaRed_mcu   	 	=> vgaRed_top_mcu,
			vgaGreen_mcu 	 	=> vgaGreen_top_mcu,
			vgaBLue_mcu  	 	=> vgaBLue_top_mcu,
			Hsync_mcu    	 	=> Hsync_top_mcu,
			Vsync_mcu    	 	=> Vsync_top_mcu,

			--sw_mcu				=> sw_top_mcu,

			UART_RX				=> UART_RX,
			UART_TX				=> UART_TX,
			seg  				=> seg,
			an					=> an,
			dp					=> dp);

	rom0_adapter: obi_2_rom
	port map (
		clk         		=> SYSCLK,

		-- OBI Slave interface : receive data from OBI Master
		if_slvi_vec     	=> rom0_MTS_vec_s,
		if_slvo_vec     	=> rom0_STM_vec_s,

		-- RAM interface
		ena   				=> Rom0_en_s,
		addra 				=> Rom0_addr_s,
		douta 				=> Rom0_data_out_s);

	ROM: SPROM_32x1024
	port map (
			clka  				=> SYSCLK,
			ena   				=> Rom0_en_s,
			addra 				=> Rom0_addr_s(11 downto 2),
			douta 				=> Rom0_data_out_s);

	ram1_adapter: obi_2_ram
	port map(
			clk         		=> SYSCLK,

			-- OBI Slave interface : receive data from OBI Master
			if_slvi_vec     	=> ram1_MTS_vec_s,
			if_slvo_vec     	=> ram1_STM_vec_s,

			-- RAM interface
			ena   				=> Ram1_en_s,
			wea   				=> Ram1_write_s,
			addra 				=> Ram1_addr_s,
			dina  				=> Ram1_data_in_s,
			douta 				=> Ram1_data_out_s);

	RAM1: SPRAM_32x16384 -- 64 kB
	port map (
			clka  				=> SYSCLK,
			ena   				=> Ram1_en_s,
			wea   				=> Ram1_write_s,
			addra 				=> Ram1_addr_s(15 downto 2),
			dina  				=> Ram1_data_in_s,
			douta 				=> Ram1_data_out_s);

	ram2_adapter: obi_2_ram
	port map(
			clk         		=> SYSCLK,

			-- OBI Slave interface : receive data from OBI Master
			if_slvi_vec     	=> ram2_MTS_vec_s,
			if_slvo_vec     	=> ram2_STM_vec_s,

			-- RAM interface
			ena   				=> Ram2_en_s,
			wea   				=> Ram2_write_s,
			addra 				=> Ram2_addr_s,
			dina  				=> Ram2_data_in_s,
			douta 				=> Ram2_data_out_s);

	RAM2: SPRAM_32x16384 -- 64 kB
	port map (
			clka  				=> SYSCLK,
			ena   				=> Ram2_en_s,
			wea   				=> Ram2_write_s,
			addra 				=> Ram2_addr_s(15 downto 2),
			dina  				=> Ram2_data_in_s,
			douta 				=> Ram2_data_out_s);

end;
