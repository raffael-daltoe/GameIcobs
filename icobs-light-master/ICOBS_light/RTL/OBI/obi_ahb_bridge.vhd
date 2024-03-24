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
-- OBI to/from AHBLite bridge
-- Author: Soriano Theo
-- Update: 30-05-2020
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library amba3;
use amba3.ahblite.all;

library interface;
use interface.obi_lib.all;

entity obi_2_ahb is
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
end;


----------------------------------------------------------------
architecture arch of obi_2_ahb is

    signal AHB_htrans_s 		: STD_LOGIC_VECTOR ( 1 downto 0 );
    signal last_req 		    : std_logic;
    signal tvalid               : std_logic;
	signal invalid              : std_logic;

    -- OBI
    signal OBI_req_i            : std_logic;
    signal OBI_we_i             : std_logic;
    signal OBI_be_i             : std_logic_vector(3 downto 0);
    signal OBI_addr_i           : std_logic_vector(31 downto 0);
    signal OBI_wdata_i          : std_logic_vector(31 downto 0);
    signal OBI_auser_i          : std_logic;
    signal OBI_wuser_i          : std_logic;
    signal OBI_rready_i         : std_logic;
    signal OBI_aid_i            : std_logic;

    signal OBI_gnt_o            : std_logic;
    signal OBI_rvalid_o         : std_logic;
    signal OBI_rdata_o          : std_logic_vector(31 downto 0);
    signal OBI_ruser_o          : std_logic;
    signal OBI_err_o            : std_logic;
    signal OBI_rid_o            : std_logic;

    signal MTS_s   : MasterToSlave;
    signal STM_s   : SlaveToMaster;

----------------------------------------------------------------
begin

   MTS_s            <= to_record(OBI_MTS_vec);
   OBI_STM_vec      <= to_vector(STM_s);

   OBI_req_i        <= MTS_s.req;
   OBI_we_i         <= MTS_s.we;
   OBI_be_i         <= MTS_s.be;
   OBI_addr_i       <= MTS_s.addr;
   OBI_wdata_i      <= MTS_s.wdata;
   OBI_auser_i      <= MTS_s.auser;
   OBI_wuser_i      <= MTS_s.wuser;
   OBI_rready_i     <= MTS_s.rready;
   OBI_aid_i        <= MTS_s.aid;

   STM_s.gnt        <= OBI_gnt_o;
   STM_s.rvalid     <= OBI_rvalid_o;
   STM_s.rdata      <= OBI_rdata_o;
   STM_s.ruser      <= OBI_ruser_o;
   STM_s.err        <= OBI_err_o;
   STM_s.rid        <= OBI_rid_o;

    -- OBI to AHB --
   AHB_hwrite_o     <= OBI_we_i;

   AHB_hsize_o(2)   <= '0';
   AHB_hsize_o(1)   <= (OBI_be_i(0) and OBI_be_i(1)) and (OBI_be_i(2) and OBI_be_i(3));
   AHB_hsize_o(0)   <= ((OBI_be_i(0) and OBI_be_i(1)) or (OBI_be_i(2) and OBI_be_i(3))) and not (OBI_be_i(0) and OBI_be_i(1)) and (OBI_be_i(2) and OBI_be_i(3));

   AHB_hburst_o     <= "000";

   AHB_hprot_o      <= "1011";

   AHB_htrans_s(0)  <='0';
   AHB_htrans_s(1)  <= OBI_req_i and tvalid;
   AHB_htrans_o     <= AHB_htrans_s;

   AHB_hmastlock_o  <= '0';

   AHB_haddr_o(31 downto 2) <= OBI_addr_i(31 downto 2);
   AHB_haddr_o(1)  <= (OBI_be_i(3) or OBI_be_i (2)) and not OBI_be_i (0);
   AHB_haddr_o(0)  <= (OBI_be_i(3) and not OBI_be_i (2)) or (OBI_be_i(1) and not OBI_be_i (0));

   with OBI_be_i select tvalid <=
		'1' when "0001",
		'1' when "0010",
		'1' when "0011",
		'1' when "0100",
		'1' when "1000",
		'1' when "1100",
		'1' when "1111",
		'0' when others;

   -- AHB to OBI --
    OBI_gnt_o     <= OBI_req_i;
    OBI_err_o     <= AHB_hresp_i and (AHB_hready_i or invalid);
    OBI_rdata_o   <= AHB_hrdata_i;
    OBI_ruser_o   <= '0';
    OBI_rid_o     <= '0';
    OBI_rvalid_o  <= last_req and (AHB_hready_i or invalid);

   process (HRESETn, HCLK) begin
    if HRESETn = '0' then
        AHB_hwdata_o <= (others => '0');
        last_req <= '0';
        invalid <= '0';
    elsif rising_edge(HCLK) then
        last_req         <= OBI_req_i;
        invalid          <= not tvalid;
        AHB_hwdata_o     <= OBI_wdata_i;
    end if;
    end process;



end;
