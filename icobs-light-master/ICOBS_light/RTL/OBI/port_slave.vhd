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
-- Slave Port entity
-- Author: Kevin Bard, Aymen Romdhane, Robin Verlegh
-- Update: 26/09/2022
-------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;

library interface;
use interface.obi_lib.all;

entity port_slave is
    generic (NB_MASTERS : integer := 2);
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
        msti_vec           : in STM_vector;
        msto_vec           : out MTS_vector
    );
end entity port_slave;

architecture archi of port_slave is

    component arbiter is
        generic (NB_MASTERS : integer := 2);
        port (
            clk : in std_logic;
            reset : in std_logic;
            mstr_cs_slave : in std_logic_vector(NB_MASTERS-1 downto 0);
            arb_cs_slave : out std_logic_vector(NB_MASTERS-1 downto 0)
        );
    end component;

    signal msti : SlaveToMaster;
    signal msto : MasterToSlave;
    constant MASTER_BITS : integer := f_log2(NB_MASTERS);
    signal slv_sel, slv_sel_q : std_logic;
    signal cs_from_arb : std_logic_vector(NB_MASTERS - 1 downto 0);
    signal granted_master_idx : std_logic_vector(MASTER_BITS - 1 downto 0);


    function onehot2idx(onehot : std_logic_vector) return integer is
        variable onehot2idx : integer;
        begin
            for i in 0 to NB_MASTERS-1 loop
                if onehot(i) = '1' then
                    onehot2idx := i;  
                end if ;
            end loop;
            return onehot2idx;
    end function;

    begin
    
    msti <= to_record(msti_vec);
    granted_master_idx <= std_logic_vector(to_unsigned(onehot2idx(cs_from_arb),MASTER_BITS));

    --Stop transfer when rvalid is high
    process(clk, reset_n) 
    begin 
    if reset_n = '0' then 
        slv_sel_q <= '0'; 
    elsif rising_edge(clk) then     
        if slv_sel ='1' then 
            slv_sel_q <= '1';    
        elsif  msti.rvalid = '1' then 
            slv_sel_q <= '0'; 
        end if;
    end if;
    end process;

    msto.be      <= mts_be    (to_integer(granted_master_idx))   when slv_sel = '1' else (others => '0');    
    msto.req     <= mts_req   (to_integer(granted_master_idx))   when slv_sel = '1' else '0';
    msto.addr    <= mts_addr  (to_integer(granted_master_idx))   when slv_sel = '1' else (others => '0');              
    msto.we      <= mts_we    (to_integer(granted_master_idx))   when slv_sel = '1' else '0'; 
    msto.wdata   <= mts_wdata (to_integer(granted_master_idx))   when slv_sel = '1' else (others => '0');             
    msto.auser   <= mts_auser (to_integer(granted_master_idx))   when slv_sel = '1' else '0';                
    msto.wuser   <= mts_wuser (to_integer(granted_master_idx))   when slv_sel = '1' else '0';
    msto.rready  <= mts_rready(to_integer(granted_master_idx))   when slv_sel = '1' else '0';
    msto.aid     <= mts_aid   (to_integer(granted_master_idx))   when slv_sel = '1' else '0';

    stm_rvalid  <= msti.rvalid   when slv_sel_q = '1'  else '0';
    stm_rdata   <= msti.rdata    when slv_sel_q = '1'  else (others => '0');
    stm_err     <= msti.err      when slv_sel_q = '1'  else '0';
    stm_gnt     <= msti.gnt      when slv_sel = '1'    else '0';
    stm_ruser   <= msti.ruser    when slv_sel = '1'    else '0';
    stm_rid     <= msti.rid      when slv_sel = '1'    else '0';


    slv_sel <= or cs_from_arb;
    slave_sel_tomst <= cs_from_arb; 

    msto_vec <= to_vector(msto);

    arbiterbis : arbiter generic map(NB_MASTERS => NB_MASTERS)
                        port map(clk => clk, 
                        reset => reset_n, 
                        arb_cs_slave => cs_from_arb , 
                        mstr_cs_slave => cs_from_master);


end architecture archi;