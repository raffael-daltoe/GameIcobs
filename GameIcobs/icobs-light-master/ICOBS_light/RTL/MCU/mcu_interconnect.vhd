library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;

library interface;
use interface.obi_lib.all;

entity mcu_interconnect is
    port (
        clk_i   				: in  std_logic;
	    rst_ni  				: in  std_logic;

        -- Slave interface to connect IBEX inst
        inst_slvi_vec   		: in  MTS_vector;
        inst_slvo_vec   		: out STM_vector;

		-- Slave interface to connect IBEX data
        data_slvi_vec   		: in  MTS_vector;
        data_slvo_vec   		: out STM_vector;

        -- ROM0 OBI master interface
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
end entity mcu_interconnect;

architecture behv of mcu_interconnect is

    constant NB_MASTER  : integer  := 2;
    constant NB_SLAVES  : integer  := 4;

    signal mst_porto    :   t_SlaveToMaster(NB_MASTER-1 downto 0);
    signal t_mst_porto  :   t_STM_vec(NB_MASTER-1 downto 0);
    signal mst_porti    :   t_MasterToSlave(NB_MASTER-1 downto 0);
    signal t_mst_porti  :   t_MTS_vec(NB_MASTER-1 downto 0);

    signal slv_porto    :   t_MasterToSlave(NB_SLAVES-1 downto 0);
    signal t_slv_porto  :   t_MTS_vec(NB_SLAVES-1 downto 0);
    signal slv_porti    :   t_SlaveToMaster(NB_SLAVES-1 downto 0);
    signal t_slv_porti  :   t_STM_vec(NB_SLAVES-1 downto 0);

	-- xbar config
    signal slv_addr_b   :   t_32bits_vec(NB_SLAVES-1 downto 0);
    signal slv_mask     :   t_32bits_vec(NB_SLAVES-1 downto 0);

    component crossbar is
        generic (
            NB_SLAVES  : integer := 2;  --number of slaves
            NB_MASTERS : integer := 4); -- number of masters
        port (
            -- Inputs
            mclk : in std_logic;
            reset_n : in std_logic;
            slave_base_address : in t_32bits_vec(Nb_Slaves-1 downto 0);
            slave_address_mask : in t_32bits_vec(Nb_Slaves-1 downto 0);

            -- Slave ports, OBI slaves connect to these
            slv_porti_vec       : in  t_STM_vec(Nb_Slaves-1 downto 0);
            slv_porto_vec       : out t_MTS_vec(Nb_Slaves-1 downto 0);
            --I/O of Slave Ports
            mst_porti_vec        : in t_MTS_vec(Nb_Masters-1 downto 0);
            mst_porto_vec        : out t_STM_vec(Nb_Masters-1 downto 0)
            );
    end component ;

begin

    slv_addr_b(0) <=    x"08000000"; --port 1 -> ROM0 -> 0x0800 0000
    slv_addr_b(1) <=    x"10000000"; --port 2 -> RAM1 -> 0x1000 0000
    slv_addr_b(2) <=    x"10010000"; --port 3 -> RAM2 -> 0x1001 0000
    slv_addr_b(3) <=    x"11000000"; --port 4 -> AHB-Lite BUS -> 0x1100 0000

    slv_mask(0)   <=    x"00000FFF"; --port 1 -> ROM0 -> 0x1000
    slv_mask(1)   <=    x"0000FFFF"; --port 1 -> RAM1 -> 0x1 0000
    slv_mask(2)   <=    x"0000FFFF"; --port 2 -> RAM2 -> 0x1 0000
    slv_mask(3)   <=    x"00FFFFFF"; --port 3 -> AHB-Lite BUS

    t_mst_porti(0)      <= inst_slvi_vec;
    inst_slvo_vec       <= t_mst_porto(0);

    t_mst_porti(1)      <= data_slvi_vec;
    data_slvo_vec       <= t_mst_porto(1);

    t_slv_porti(0) <= rom0_vec_i;
    rom0_vec_o <= t_slv_porto(0);

    t_slv_porti(1) <= ram1_vec_i;
    ram1_vec_o <= t_slv_porto(1);

    t_slv_porti(2) <= ram2_vec_i;
    ram2_vec_o <= t_slv_porto(2);

    t_slv_porti(3) <= periph_vec_i;
    periph_vec_o <= t_slv_porto(3);

    --Interconnect
    interconnect : crossbar generic map (NB_SLAVES => NB_SLAVES, NB_MASTERS => NB_MASTER)
                      port map (
                        mclk                        => clk_i,
                        reset_n                     => rst_ni,
                        slave_base_address          => slv_addr_b,
                        slave_address_mask          => slv_mask,
                        -- Interface
                        --I/O of Master Ports
                        slv_porti_vec               => t_slv_porti,
                        slv_porto_vec               => t_slv_porto,
                        --I/O of Slave Ports
                        mst_porti_vec               => t_mst_porti,
                        mst_porto_vec               => t_mst_porto
                      );
end behv ; -- behv
