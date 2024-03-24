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
-- IBEX OBI VHDL Wrapper
-- ICOBS MK4.2
-- Author: Theo Soriano
-- Update: 23-09-2020
-- LIRMM, Univ Montpellier, CNRS, Montpellier, France
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library interface;
use interface.obi_lib.all;

entity IBEX_OBI is
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
    end;


----------------------------------------------------------------
architecture arch of IBEX_OBI is


    component ibex_core
    port (
        clk_i                   : in  std_logic;
        rst_ni                  : in  std_logic;

        test_en_i               : in  std_logic;

        hart_id_i               : in  std_logic_vector(31 downto 0);
        boot_addr_i             : in  std_logic_vector(31 downto 0);

        instr_req_o             : out std_logic;
        instr_gnt_i             : in  std_logic;
        instr_rvalid_i          : in  std_logic;
        instr_addr_o            : out std_logic_vector(31 downto 0);
        instr_rdata_i           : in  std_logic_vector(31 downto 0);
        instr_err_i             : in  std_logic;

        data_req_o              : out std_logic;
        data_gnt_i              : in  std_logic;
        data_rvalid_i           : in  std_logic;
        data_we_o               : out std_logic;
        data_be_o               : out std_logic_vector(3 downto 0);
        data_addr_o             : out std_logic_vector(31 downto 0);
        data_wdata_o            : out std_logic_vector(31 downto 0);
        data_rdata_i            : in  std_logic_vector(31 downto 0);
        data_err_i              : in  std_logic;

        irq_software_i          : in  std_logic;
        irq_timer_i             : in  std_logic;
        irq_external_i          : in  std_logic;
        irq_fast_i              : in  std_logic_vector(14 downto 0);
        irq_nm_i                : in  std_logic;

        debug_req_i             : in  std_logic;

        fetch_enable_i          : in  std_logic;
        alert_minor_o           : out std_logic;
        alert_major_o           : out std_logic;
        core_sleep_o            : out std_logic);
    end component;


    signal instr_req_s             : std_logic;
    signal instr_gnt_s             : std_logic;
    signal instr_rvalid_s          : std_logic;
    signal instr_addr_s            : std_logic_vector(31 downto 0);
    signal instr_rdata_s           : std_logic_vector(31 downto 0);
    signal instr_err_s             : std_logic;

    signal data_req_s              : std_logic;
    signal data_gnt_s              : std_logic;
    signal data_rvalid_s           : std_logic;
    signal data_we_s               : std_logic;
    signal data_be_s               : std_logic_vector(3 downto 0);
    signal data_addr_s             : std_logic_vector(31 downto 0);
    signal data_wdata_s            : std_logic_vector(31 downto 0);
    signal data_rdata_s            : std_logic_vector(31 downto 0);
    signal data_err_s              : std_logic;

    signal inst_mst_porti    :   SlaveToMaster;
    signal inst_mst_porto    :   MasterToSlave;

    signal data_mst_porti    :   SlaveToMaster;
    signal data_mst_porto    :   MasterToSlave;

----------------------------------------------------------------
begin

    inst_vec_o <= to_vector(inst_mst_porto);
    inst_mst_porti <= to_record(inst_vec_i);

    data_vec_o <= to_vector(data_mst_porto);
    data_mst_porti <= to_record(data_vec_i);

    IBEX_VER_1: ibex_core
    port map (
            clk_i                   => clk_i,
            rst_ni                  => rst_ni,

            test_en_i               => test_en_i,

            hart_id_i               => hart_id_i,
            boot_addr_i             => boot_addr_i,

            instr_req_o             => instr_req_s,
            instr_gnt_i             => instr_gnt_s,
            instr_rvalid_i          => instr_rvalid_s,
            instr_addr_o            => instr_addr_s,
            instr_rdata_i           => instr_rdata_s,
            instr_err_i             => instr_err_s,

            data_req_o              => data_req_s,
            data_gnt_i              => data_gnt_s,
            data_rvalid_i           => data_rvalid_s,
            data_we_o               => data_we_s,
            data_be_o               => data_be_s,
            data_addr_o             => data_addr_s,
            data_wdata_o            => data_wdata_s,
            data_rdata_i            => data_rdata_s,
            data_err_i              => data_err_s,

            irq_software_i          => irq_software_i,
            irq_timer_i             => irq_timer_i,
            irq_external_i          => irq_external_i,
            irq_fast_i              => irq_fast_i,
            irq_nm_i                => irq_nm_i,

            debug_req_i             => debug_req_i,

            fetch_enable_i          => fetch_enable_i,
            alert_minor_o           => alert_minor_o,
            alert_major_o           => alert_major_o,
            core_sleep_o            => core_sleep_o);


    --Inst
    --Outputs
    inst_mst_porto.req    <= instr_req_s;
    inst_mst_porto.addr   <= instr_addr_s;
    inst_mst_porto.we     <= '0';
    inst_mst_porto.be     <= "1111"; --4'hF;
    inst_mst_porto.wdata  <= (others => '0'); --32'h00000000
    inst_mst_porto.auser  <= '0';
    inst_mst_porto.wuser  <= '0';
    inst_mst_porto.rready <= '0';
    inst_mst_porto.aid    <= '0';

    --Inputs
	instr_gnt_s	        <= inst_mst_porti.gnt;
	instr_rvalid_s	    <= inst_mst_porti.rvalid;
	instr_rdata_s	    <= inst_mst_porti.rdata;
	instr_err_s         <= inst_mst_porti.err;
    -- ruser unused
    -- rid unused

    --Master port 1 -> icobs_data
    --Outputs
	data_mst_porto.req      <= data_req_s;
    data_mst_porto.we       <= data_we_s;
	data_mst_porto.be       <= data_be_s;
	data_mst_porto.addr     <= data_addr_s;
	data_mst_porto.wdata    <= data_wdata_s;
    data_mst_porto.auser    <= '0';
    data_mst_porto.wuser    <= '0';
    data_mst_porto.rready   <= '0';
    data_mst_porto.aid      <= '0';

    --Inputs
	data_gnt_s           <= data_mst_porti.gnt;
	data_rvalid_s        <= data_mst_porti.rvalid;
	data_rdata_s         <= data_mst_porti.rdata;
	data_err_s           <= data_mst_porti.err;
    -- ruser unused
    -- rid unused

    inst_addr_o     <= instr_addr_s;
    inst_gnt_o      <= instr_gnt_s;
    inst_rvalid_o   <= instr_rvalid_s;
    data_be_o       <= data_be_s;
    data_addr_o     <= data_addr_s;
    data_gnt_o      <= data_gnt_s;
    data_rvalid_o   <= data_rvalid_s;
    data_we_o       <= data_we_s;

end;
