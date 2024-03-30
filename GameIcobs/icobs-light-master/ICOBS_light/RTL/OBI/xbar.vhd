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
-- Crossbar entity
-- Author: Aymen Romdhane
-- Update: 17/05/2022
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;

library interface;
use interface.obi_lib.all;

entity crossbar is
    generic (
        NB_SLAVES   : integer := 4; --number of slaves
        NB_MASTERS  : integer := 2); -- number of masters
    port (
        mclk                : in std_logic;
        reset_n             : in std_logic;
        slave_base_address  : in t_32bits_vec(Nb_Slaves-1 downto 0);
        slave_address_mask  : in t_32bits_vec(Nb_Slaves-1 downto 0);
        -- Slave ports, OBI slaves connect to these
        slv_porti_vec       : in  t_STM_vec(Nb_Slaves-1 downto 0);
        slv_porto_vec       : out t_MTS_vec(Nb_Slaves-1 downto 0);
        -- Master ports, OBI masters connect to these
        mst_porti_vec       : in t_MTS_vec(Nb_Masters-1 downto 0);
        mst_porto_vec       : out t_STM_vec(Nb_Masters-1 downto 0)
    );
end entity crossbar;

architecture archi of crossbar is

    component port_master
        generic (
            NB_SLAVES : integer := 3; --number of slaves
            NB_MASTERS : integer := 2); -- number of masters
            port (
                clk                 : in std_logic;
                reset_n             : in std_logic;

                -- Recieving data from slaves
                stm_gnt          : in std_logic_vector(NB_SLAVES-1 downto 0);
                stm_rvalid       : in std_logic_vector(NB_SLAVES-1 downto 0);
                stm_rdata        : in t_rdata(NB_SLAVES-1 downto 0);
                stm_ruser        : in std_logic_vector(NB_SLAVES-1 downto 0);
                stm_err          : in std_logic_vector(NB_SLAVES-1 downto 0);
                stm_rid          : in std_logic_vector(NB_SLAVES-1 downto 0);
                -- Sending data to slaves
                mts_req          : out std_logic;
                mts_addr         : out std_logic_vector(31 downto 0);
                mts_we           : out std_logic;
                mts_be           : out std_logic_vector(3 downto 0);
                mts_wdata        : out std_logic_vector(31 downto 0);
                mts_auser        : out std_logic;
                mts_wuser        : out std_logic;
                mts_rready       : out std_logic;
                mts_aid          : out std_logic;

                slave_sel_from_slv  : in std_logic_vector(NB_SLAVES-1 downto 0);
                cs_rvalid_i         : in t_cs_rvalid(NB_MASTERS-2 downto 0);
                cs_rvalid_o         : out std_logic_vector(f_log2(NB_SLAVES)-1 downto 0); --log2 NS -1

                -- Signals to Address Decoder
                slave_base_address  : in t_32bits_vec(NB_SLAVES-1 downto 0);
                slave_address_mask  : in t_32bits_vec(NB_SLAVES-1 downto 0);
                decoder_cs          : out std_logic_vector(NB_SLAVES-1 downto 0);

                -- OBI Slave interface : receive data from OBI Master
                slvi_vec       : in MTS_vector;
                slvo_vec       : out STM_vector
            );
    end component;


    component port_slave
        generic (NB_MASTERS : integer := 2); --Number of Masters
        port (
            clk                     : in std_logic;
            reset_n                 : in std_logic;

            cs_from_master          : in std_logic_vector(NB_MASTERS-1 downto 0);
            slave_sel_tomst         : out std_logic_vector(NB_MASTERS-1 downto 0);

            -- OBI slave interface : receive data from OBI Master
            mts_req              : in std_logic_vector(NB_MASTERS-1 downto 0);
            mts_addr             : in t_addr(NB_MASTERS-1 downto 0);
            mts_we               : in std_logic_vector(NB_MASTERS-1 downto 0);
            mts_be               : in t_be(NB_MASTERS-1 downto 0);
            mts_wdata            : in t_wdata(NB_MASTERS-1 downto 0);
            mts_auser            : in std_logic_vector(NB_MASTERS-1 downto 0);
            mts_wuser            : in std_logic_vector(NB_MASTERS-1 downto 0);
            mts_rready           : in std_logic_vector(NB_MASTERS-1 downto 0);
            mts_aid              : in std_logic_vector(NB_MASTERS-1 downto 0);

            stm_gnt              : out std_logic;
            stm_rvalid           : out std_logic;
            stm_rdata            : out std_logic_vector(31 downto 0);
            stm_ruser            : out std_logic;
            stm_err              : out std_logic;
            stm_rid              : out std_logic;

            -- OBI Master Interface : send data to OBI Slaves
            msti_vec             : in STM_vector;
            msto_vec             : out MTS_vector
        );
    end component;
    signal SLAVES_BITS      :   integer := f_log2(Nb_Slaves);
    signal OBI_BE_WIDTH     :   integer := 4;

    -- Output signals from master ports are stored in arrays
    signal frommst_req      :   std_logic_vector(Nb_Masters-1 downto 0);
    signal frommst_addr     :   t_addr(Nb_Masters-1 downto 0);
    signal frommst_we       :   std_logic_vector(Nb_Masters-1 downto 0);
    signal frommst_be       :   t_be(Nb_Masters-1 downto 0);
    signal frommst_wdata    :   t_wdata(Nb_Masters-1 downto 0);
    signal frommst_auser    :   std_logic_vector(Nb_Masters-1 downto 0);
    signal frommst_wuser    :   std_logic_vector(Nb_Masters-1 downto 0);
    signal frommst_rready   :   std_logic_vector(Nb_Masters-1 downto 0);
    signal frommst_aid      :   std_logic_vector(Nb_Masters-1 downto 0);


    type t_2D_tomst is array(Nb_Masters-1 downto 0) of std_logic_vector(Nb_Slaves-1 downto 0);
    subtype rdata_arr is t_rdata(Nb_Slaves-1 downto 0);
    type t_2D_tomst_rdata is array (Nb_Masters-1 downto 0) of rdata_arr;

    -- Incomming signals from slave ports are stored in 2D arrays
    signal tomst_gnt        :   t_2D_tomst;
    signal tomst_rvalid     :   t_2D_tomst;
    signal tomst_rdata      :   t_2D_tomst_rdata;
    signal tomst_ruser      :   t_2D_tomst;
    signal tomst_err        :   t_2D_tomst;
    signal tomst_rid        :   t_2D_tomst;

    type t_2D_toslv is array (Nb_Slaves-1 downto 0) of std_logic_vector(Nb_Masters-1 downto 0);

    subtype addr_array is t_addr(Nb_Masters-1 downto 0);
    type t_2D_toslv_addr is array (Nb_Slaves-1 downto 0) of addr_array;

    subtype wdata_array is t_wdata(Nb_Masters-1 downto 0);
    type t_2D_toslv_wdata is array (Nb_Slaves-1 downto 0) of wdata_array;

    subtype be_array is t_be(Nb_Masters-1 downto 0);
    type t_2D_toslv_be is array (Nb_Slaves-1 downto 0) of be_array;

    -- Incomming signals from masters are stored in 2D arrays
    signal toslv_req        :   t_2D_toslv;
    signal toslv_addr       :   t_2D_toslv_addr;
    signal toslv_we         :   t_2D_toslv;
    signal toslv_be         :   t_2D_toslv_be;
    signal toslv_wdata      :   t_2D_toslv_wdata;
    signal toslv_auser      :   t_2D_toslv;
    signal toslv_wuser      :   t_2D_toslv;
    signal toslv_rready     :   t_2D_toslv;
    signal toslv_aid        :   t_2D_toslv;

    -- Output signals from slaves are stored in arrays
    signal fromslv_gnt      :   std_logic_vector(Nb_Slaves-1 downto 0);
    signal fromslv_rvalid   :   std_logic_vector(Nb_Slaves-1 downto 0);
    signal fromslv_rdata    :   t_rdata(Nb_Slaves-1 downto 0);
    signal fromslv_ruser    :   std_logic_vector(Nb_Slaves-1 downto 0);
    signal fromslv_err      :   std_logic_vector(Nb_Slaves-1 downto 0);
    signal fromslv_rid      :   std_logic_vector(Nb_Slaves-1 downto 0);

    type t_mst_slv is array (Nb_Masters-1 downto 0) of std_logic_vector(Nb_Slaves-1 downto 0);
    type t_slv_mst is array (Nb_Slaves-1 downto 0) of std_logic_vector(Nb_Masters-1 downto 0);

    signal cs_from_mst      :   t_mst_slv;
    signal cs_to_slv        :   t_slv_mst;

    signal tomst_slave_sel  :   t_mst_slv;
    signal fromslv_slave_sel:   t_slv_mst;

    subtype array_cs_rvalid is t_cs_rvalid(Nb_Masters-2 downto 0);
    type t_2D_log2 is array (Nb_Masters-1 downto 0) of array_cs_rvalid;

    subtype sb_vec is std_logic_vector(f_log2(Nb_Slaves)-1 downto 0);
    type t_SB is array(natural range <>) of sb_vec;

    signal cs_rvalid_i_from_mst : t_2D_log2;
    signal cs_rvalid_o_to_mst   : t_SB(Nb_Masters-1 downto 0);

    begin

    MASTER_PORTS_GEN : for i in 0 to Nb_Masters-1  generate
    gen_mp : port_master
        generic map (NB_SLAVES => Nb_Slaves, NB_MASTERS => Nb_Masters)
        port map (
            clk                 =>  mclk,
            reset_n             =>  reset_n,
            stm_gnt          =>  tomst_gnt     (i),
            stm_rvalid       =>  tomst_rvalid  (i),
            stm_rdata        =>  tomst_rdata   (i),
            stm_ruser        =>  tomst_ruser   (i),
            stm_err          =>  tomst_err     (i),
            stm_rid          =>  tomst_rid     (i),
            mts_req          =>  frommst_req   (i),
            mts_addr         =>  frommst_addr  (i),
            mts_we           =>  frommst_we    (i),
            mts_be           =>  frommst_be    (i),
            mts_wdata        =>  frommst_wdata (i),
            mts_auser        =>  frommst_auser (i),
            mts_wuser        =>  frommst_wuser (i),
            mts_rready       =>  frommst_rready(i),
            mts_aid          =>  frommst_aid   (i),

            slave_sel_from_slv  =>  tomst_slave_sel(i),
            cs_rvalid_i         =>  cs_rvalid_i_from_mst(i),
            cs_rvalid_o         =>  cs_rvalid_o_to_mst(i),

            slave_base_address  =>  slave_base_address,
            slave_address_mask  =>  slave_address_mask,
            decoder_cs          =>  cs_from_mst(i),

            slvi_vec         =>  mst_porti_vec(i),
            slvo_vec         =>  mst_porto_vec(i)
        );
    end generate;

    l1: for s in 0 to Nb_Slaves-1 generate
        l2: for m in 0 to Nb_Masters-1 generate
                toslv_req   (s)(m)    <=  frommst_req   (m);
                toslv_addr  (s)(m)    <=  frommst_addr  (m);
                toslv_we    (s)(m)    <=  frommst_we    (m);
                toslv_be    (s)(m)    <=  frommst_be    (m);
                toslv_wdata (s)(m)    <=  frommst_wdata (m);
                toslv_auser (s)(m)    <=  frommst_auser (m);
                toslv_wuser (s)(m)    <=  frommst_wuser (m);
                toslv_rready(s)(m)    <=  frommst_rready(m);
                toslv_aid   (s)(m)    <=  frommst_aid   (m);
        end generate l2;
    end generate l1;

    cs_rvalid : process( all )
    variable k : integer;
    begin
    for l in 0 to Nb_Masters-1  loop
        k := 0;
        for t in 0 to Nb_Masters-1 loop
            if (l/=t) then
                cs_rvalid_i_from_mst(l)(k) <= to_integer(cs_rvalid_o_to_mst(t));
                k := k + 1;
            end if ;
        end loop;
    end loop;
    end process ; -- cs_rvalid

    loop1: for i in 0 to Nb_Slaves-1 generate
        loop2: for j in 0 to Nb_Masters-1 generate
            cs_to_slv(i)(j) <= cs_from_mst(j)(i);
        end generate loop2;
    end generate loop1;

    loop3: for i in 0 to Nb_Masters-1 generate
        loop4: for j in 0 to Nb_Slaves-1 generate
            tomst_slave_sel(i)(j) <= fromslv_slave_sel(j)(i);
        end generate loop4;
    end generate loop3; --fromslv_slave_sel

    l3: for m in 0 to Nb_Masters-1 generate
        l4: for s in 0 to Nb_Slaves-1 generate
            tomst_gnt   (m)(s)  <= fromslv_gnt   (s);
            tomst_rvalid(m)(s)  <= fromslv_rvalid(s);
            tomst_rdata (m)(s)  <= fromslv_rdata (s);
            tomst_ruser (m)(s)  <= fromslv_ruser (s);
            tomst_err   (m)(s)  <= fromslv_err   (s);
            tomst_rid   (m)(s)  <= fromslv_rid   (s);
        end generate l4;
    end generate l3;

    SLAVE_PORTS_GEN : for i in 0 to Nb_Slaves-1  generate
    gen_sp : port_slave
        generic map (NB_MASTERS => Nb_Masters)
        port map (
            clk                 =>  mclk,
            reset_n             =>  reset_n,

            cs_from_master      =>  cs_to_slv(i),
            slave_sel_tomst     =>  fromslv_slave_sel(i),

            mts_req          =>  toslv_req   (i),
            mts_addr         =>  toslv_addr  (i),
            mts_we           =>  toslv_we    (i),
            mts_be           =>  toslv_be    (i),
            mts_wdata        =>  toslv_wdata (i),
            mts_auser        =>  toslv_auser (i),
            mts_wuser        =>  toslv_wuser (i),
            mts_rready       =>  toslv_rready(i),
            mts_aid          =>  toslv_aid   (i),
            stm_gnt          =>  fromslv_gnt   (i),
            stm_rvalid       =>  fromslv_rvalid(i),
            stm_rdata        =>  fromslv_rdata (i),
            stm_ruser        =>  fromslv_ruser (i),
            stm_err          =>  fromslv_err   (i),
            stm_rid          =>  fromslv_rid   (i),

            msti_vec         =>  slv_porti_vec(i),
            msto_vec         =>  slv_porto_vec(i)
        );
    end generate;

end architecture archi;
