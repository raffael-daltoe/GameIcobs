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
-- Master Port entity
-- Author: Aymen Romdhane
-- Update: 26/09/2022
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;

library interface;
use interface.obi_lib.all;

entity port_master is
    generic (
        NB_SLAVES : integer := 4; 
        NB_MASTERS : integer := 4); 
    port (

        clk                 : in std_logic;
        reset_n             : in std_logic;

        -- Receive data from slaves
        stm_gnt          : in std_logic_vector(NB_SLAVES-1 downto 0);
        stm_rvalid       : in std_logic_vector(NB_SLAVES-1 downto 0);
        stm_rdata        : in t_rdata(NB_SLAVES-1 downto 0);
        stm_ruser        : in std_logic_vector(NB_SLAVES-1 downto 0);
        stm_err          : in std_logic_vector(NB_SLAVES-1 downto 0);
        stm_rid          : in std_logic_vector(NB_SLAVES-1 downto 0);

        -- Send data to slaves
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
        cs_rvalid_o         : out std_logic_vector(f_log2(NB_SLAVES)-1 downto 0);

        -- Signals for Address Decoder
        slave_base_address  : in t_32bits_vec(NB_SLAVES-1 downto 0);
        slave_address_mask  : in t_32bits_vec(NB_SLAVES-1 downto 0);
        decoder_cs          : out std_logic_vector(NB_SLAVES-1 downto 0);

        -- OBI Slave interface : receive data from OBI Master
        slvi_vec         : in MTS_vector;
        slvo_vec         : out STM_vector
    );
end  port_master;

architecture rtl of port_master is
    constant SLAVES_BIT : integer := f_log2(NB_SLAVES);
    type t_cs_rvalid_vec is array(natural range <>) of std_logic_vector(f_log2(NB_SLAVES)-1 downto 0);
    signal cs_rvalid_i_vec : t_cs_rvalid_vec(NB_MASTERS-2 downto 0);
    ---- Functions declaration -----

    -- returns the index of the first bit at 1 ~ This function is used mostly to select slaves
    function onehot2idx(onehot : std_logic_vector) return integer is
        variable onehot2idx : integer;
        begin
            for i in 0 to NB_SLAVES-1 loop
                if onehot(i) = '1' then
                    onehot2idx := i;
                end if ;
            end loop;
            return onehot2idx;
    end function;

    -- Detect if there is conflict between slave_sel_q and cs_rvalid_i then generates slave_sel_rep
    function gen_slv_sel_rep_f
                (in0 : std_logic_vector(SLAVES_BIT-1 downto 0);
                in1 : t_cs_rvalid_vec(NB_MASTERS-2 downto 0);
                in2 : std_logic)
                return std_logic_vector is
        variable gen_slv_sel_rep : std_logic_vector(SLAVES_BIT-1 downto 0);
    begin
        gen_slv_sel_rep := (others => '0');
        if (or in0 = '1') then
            for i in 0 to NB_MASTERS-2 loop
                if ((in0 = in1(i)) and in2 = '1') then
                    gen_slv_sel_rep := (others => '0');
                    exit;
                else
                    gen_slv_sel_rep := in0;
                end if;
            end loop;
        end if ;
        return gen_slv_sel_rep;
    end function;

    --Detect if there is a conflict between slave_sel_q and cs_rvalid_i
    function dectect_conflict_rvalid
                (in0 : std_logic_vector(SLAVES_BIT-1 downto 0);
                in1 : t_cs_rvalid_vec(NB_MASTERS-2 downto 0);
                in2 : std_logic)
                return std_logic is
        variable rvalid_conflict : std_logic;
    begin
        rvalid_conflict := '0';
        if (or in0 = '1') then
            for i in 0 to NB_MASTERS-2 loop
                if ((in0 = in1(i)) and in2 = '1') then
                    rvalid_conflict := '1';
                    exit;
                end if;
            end loop;
        end if ;
        return rvalid_conflict;
    end function;

    -- Decoder declaration
    component decoder
        generic(NB_SLAVES : integer := 2); -- NS : Number of slaves
        Port (
            slave_base_address : in t_32bits_vec(NB_SLAVES-1 downto 0);
            slave_address_mask : in t_32bits_vec(NB_SLAVES-1 downto 0);
            addr               : in std_logic_vector(31 downto 0);
            req                : in std_logic;
            decoder_cs         : out std_logic_vector(NB_SLAVES-1 downto 0)
        );
    end component;

    -- Slave interface
    signal slv   : MasterToSlave;
    signal slvo  : SlaveToMaster;

    signal err_inv_addr, err_wait_state         :   std_logic;
    signal conflict, conflict_q                 :   std_logic;
    signal gnt_q, rvalid_q, ruser_q, err_q      :   std_logic;
    signal rid_q                                :   std_logic;
    signal rdata_q                              :   std_logic_vector(31 downto 0);
    signal slave_sel, slave_sel_q               :   std_logic_vector(SLAVES_BIT-1 downto 0);
    signal slave_sel_rep                        :   std_logic_vector(SLAVES_BIT-1 downto 0);
    signal cs_from_adcdr, cs_from_adcdr_q       :   std_logic_vector(NB_SLAVES-1 downto 0);
    signal mst_granted, mst_granted_q           :   std_logic;
    signal mst_granted_rep                      :   std_logic;
    signal mst_slave_sel, cs_gnt                :   std_logic_vector(SLAVES_BIT-1 downto 0);
    signal cs_rvalid, cs_rvalid_q, tip_q        :   std_logic;
    signal cs_rvalid_temp                       :   std_logic_vector(SLAVES_BIT-1 downto 0);

begin
    --Converting the array of integers into an array of vectors
    cs_rvalid_i_GEN : for i in 0 to NB_MASTERS-2 generate
        cs_rvalid_i_vec(i) <= std_logic_vector(to_unsigned(cs_rvalid_i(i), f_log2(NB_SLAVES)));
    end generate;
    -- Converting the input array of slave interface into a record
    slv <= to_record(slvi_vec);

    -- Choosing the slave port
    slave_sel <=  std_logic_vector( to_unsigned(onehot2idx(cs_from_adcdr), SLAVES_BIT))
                 or std_logic_vector(to_unsigned(onehot2idx(cs_from_adcdr_q), SLAVES_BIT));
    slave_sel_q <= std_logic_vector(to_unsigned(onehot2idx(cs_from_adcdr_q),SLAVES_BIT));
    mst_slave_sel <=std_logic_vector(to_unsigned(onehot2idx(cs_from_adcdr),SLAVES_BIT)) ;

    mst_granted <= slave_sel_from_slv(to_integer(mst_slave_sel)) or slave_sel_from_slv(to_integer(slave_sel));


    rvalid_temp : process(clk, reset_n)
    begin
        if reset_n = '0' then
            cs_rvalid_temp(0) <= '0'; -- first change
        elsif rising_edge(clk) then
            if ((slv.req and not gnt_q) or
            (not slv.req and rvalid_q)) = '1'  then --second change
                cs_rvalid_temp <= (others => '0');
            else
                cs_rvalid_temp <= slave_sel;
            end if ;
        end if;
    end process ; -- rvalid_temp
    cs_rvalid_o <= cs_rvalid_temp;

    -- Detecting conflicts between slaves
    conflicts : process( all )
    begin
        slave_sel_rep   <= gen_slv_sel_rep_f(slave_sel_q, cs_rvalid_i_vec, mst_granted);
        conflict        <= dectect_conflict_rvalid(slave_sel_q, cs_rvalid_i_vec, mst_granted);
    end process ; -- conflicts

    --
    grant : process( clk, reset_n)
    begin
        if reset_n = '0' then
            mst_granted_q        <= '0';
            conflict_q          <= '0';
            mst_granted_rep     <= '0';
            tip_q               <= '0';
            cs_rvalid_q         <= '0';
        elsif (rising_edge(clk)) then
            cs_rvalid_q         <= cs_rvalid;
            tip_q               <= rvalid_q;
            conflict_q          <= conflict;
            mst_granted_q       <= mst_granted;
            if (mst_granted and conflict) = '1' then 
                mst_granted_rep <= '1';
            elsif (rvalid_q and (not slv.req)) = '1' then
                mst_granted_rep <= '0';
            end if;
        end if ;
    end process ; -- grant

    rvalid : process( all )
    begin
        if (mst_granted_q = '1') then
            cs_rvalid <= '1';
        elsif (tip_q and (not mst_granted_q)) = '1' then
            cs_rvalid <= '0';
        else
            cs_rvalid <= cs_rvalid_q;
        end if ;
    end process ; -- rvalid

    select_gnt : process( all )
    begin
        if (mst_granted_q and (not rvalid_q)) = '1' then
            cs_gnt <= slave_sel_q;
        elsif (slv.req or rvalid_q) = '1' then
            cs_gnt <= mst_slave_sel;
        else
            cs_gnt <= slave_sel_rep;
        end if ;
    end process ; -- select_gnt

    mts_req      <= slv.req;
    mts_addr     <= slv.addr;
    mts_we       <= slv.we;
    mts_be       <= slv.be;
    mts_wdata    <= slv.wdata;
    mts_auser    <= slv.auser;
    mts_wuser    <= slv.wuser;
    mts_rready   <= slv.rready;
    mts_aid      <= slv.aid;

    -- Slave Interface outputs :
    ruser_rid : process(all)
    begin
        if (mst_granted = '1') then
            ruser_q <= stm_ruser(to_integer(slave_sel));
            rid_q   <= stm_rid(to_integer(slave_sel));
        else
            ruser_q <= '0';
            rid_q <= '0';
        end if;
    end process ; -- ruser_rid

    err : process( all )
    begin
        if mst_granted_rep = '1' then
            err_q <= stm_err(to_integer(slave_sel_rep));
        elsif (cs_rvalid and (not(conflict_q or conflict))) = '1' then
            err_q <= stm_err(to_integer(slave_sel));
        elsif (err_wait_state = '1') then
            err_q <= '1';
        else
            err_q <= '0';
        end if ;
    end process ; -- err

    gnt_qs : process( all )
    begin
        if (mst_granted and (slv.req)) = '1' then
            gnt_q <= stm_gnt(to_integer(cs_gnt));
        elsif (slv.req and (not mst_granted)  and (not (or(cs_from_adcdr)))) = '1' then
            gnt_q <= '1';
        else
            gnt_q <= '0';
        end if;
    end process ; -- gnt_q

    rvalid_qs : process(all)
    begin
        if mst_granted_rep = '1' then
            rvalid_q <= stm_rvalid(to_integer(slave_sel_rep));
        elsif (cs_rvalid and (not(conflict_q or conflict)) ) = '1' then
            rvalid_q <= stm_rvalid(to_integer(slave_sel));
        elsif (err_wait_state = '1') then
            rvalid_q <= '1';
        else
            rvalid_q <= '0';
        end if ;
    end process ; -- rvalid_q

    rdata_qs : process(all)
    begin
        if mst_granted_rep = '1' then
            rdata_q <= stm_rdata(to_integer(slave_sel_rep));
        elsif (cs_rvalid and (not(conflict_q or conflict))) = '1' then
            rdata_q <= stm_rdata(to_integer(slave_sel));
        else
            rdata_q <= (others => '0');
        end if ;
    end process ; -- rdata_q

    err_ws : process( clk, reset_n )
    begin
        if reset_n = '0' then
            err_inv_addr    <= '0';
            err_wait_state  <= '0';
        elsif (rising_edge(clk)) then
            if (not mst_granted and slv.req and (nor cs_from_adcdr)) = '1' then
                err_inv_addr <= '1';
            else
                err_inv_addr <= '0';
            end if ;
            if (err_inv_addr and (not mst_granted_q) and (not slv.req)) = '1' then
                err_wait_state <= '1';
            else
                err_wait_state <= '0';
            end if;
        end if ;
    end process ; -- err_ws

    cs_adcdr : process( clk, reset_n)
    begin
        if reset_n = '0' then
            cs_from_adcdr_q <= (others =>'0');
        elsif (rising_edge(clk)) then
            if (slv.req or rvalid_q or gnt_q or err_q) = '1' then
                cs_from_adcdr_q <= cs_from_adcdr;
            end if;
        end if ;
    end process ;

    decoder_cs      <= cs_from_adcdr;

    slvo.gnt     <= gnt_q;
    slvo.rvalid  <= rvalid_q;
    slvo.rdata   <= rdata_q;
    slvo.ruser   <= ruser_q;
    slvo.err     <= err_q;
    slvo.rid     <= rid_q;

    slvo_vec    <= to_vector(slvo);

    dcdr : decoder generic map (NB_SLAVES => NB_SLAVES)
                   port map (
                    slave_base_address => slave_base_address,
                    slave_address_mask => slave_address_mask,
                    addr               => slv.addr,
                    req                => slv.req,
                    decoder_cs         => cs_from_adcdr);

end architecture rtl;
