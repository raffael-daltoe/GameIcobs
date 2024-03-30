Ibex Core Based System MK7
================================================================

<div align="center"><img src="/ICOBS_MK7/IMG/logo_ICOBS_bl.png" width="200"/></div>

# OBI Crossbar
## General Description 

The interconnect used in ICOBS MK7 architecture is based on the Open Bus Interface (OBI) protocol which is used by many RISC-V cores including Ibex. Our OBI crossbar can be generated with any given number of masters and slaves. In the figure below, it is generated with 2 master ports and 3 slave ports. Each Master_Port entity contains an address decoder and each Slave_Port entity has an arbiter which ensures only one master at a time ensures data transfer. The signals going in and out of the crossbar are signals generated by an interconnect, in our case we have 2 different interconnects, one for the Monitoring Unit and the other one for the MCU. Masters and Slaves exchange many signals throughout the execution cycles. We have regrouped all the signals into 2 different record. A SlaveToMaster (STM) record contains all the signals that each slave send to every master inside the crossbar and a MasterToSlave (MTS) record contains all the signals that each master sends to every slave inside the crossbar. 

**The STM record is made of the following signals :**
| Signal | Description |
| ----------- | ----------- |
| **gnt**           | Grant. Ready to accept address transfer |
| **rvalid**        | Response transfer request. rvalid = 1 signals availability of valid response phase signals | 
| **rdata[31:0]**   | Read data (reading only transactions) | 
| **ruser**         | Response phase User signals (reading only transactions | 
| **err**           | Error | 
| **rid**           | Response Phase transaction identifier | 


**The MTS record is made of the following signals :**

| Signal | Description |
| ----------- | ----------- |
|**req**         |Address transfer request |
|**addr[31:0]**  |Address |
|**we**      	 |Write Enable. High for write and low for read transaction |
|**be[3:0]**     |Byte enable. Which byte to read/write |
|**wdata[31:0]** |Write Data |
|**auser**   	 |Address Phase User signals |
|**wuser**   	 |Additional Address Phase User signals |
|**rready**  	 |Ready to accept response transfer |
|**aid**     	 |Address Phase transaction identifier |

These record along with some functions are declared in our library obi_lib.vhd.	

## OBI Library
In this library we define many signals and types that are used in the different modules related to the OBI interconnect

| Signal | Description |
| ----------- | ----------- |
|**t_32bits_vec**       |Array of 32 bits std_logic_vector used mostly for addresses|
|**t_cs_rvalid**        |Array of integers used in the Master Port |
|**t_addr**      	    |Array of addr signals declared in MTS record|
|**t_be**               |Array of be signals declared in MTS record|
|**t_wdata**            |Array of wdata signals declared in MTS record|
|**t_rdata**   	        |Array of rdata signals declared in STM record|
|**t_MasterToSlave**    |Array of MTS records|
|**t_SlaveToMaster**    |Array of STM records|
|**MTS_vector**         |An std_logic_vector of 74bits containing the MTS record values used as I/O of entities|
|**STM_vector**         |An std_logic_vector of 32bits containing the STM record values used as I/O of entities|
|**t_MTS_vec**         |Array of MTS_vector signals|
|**t_STM_vec**         |Array of STM_vector signals|

The library also conatins some functions we used in our crossbar :
| Function | Input | Output | Description |
| ----------- | ----------- | ----------- | ----------- | 
|**f_log2**     |positive|integer|Calculates the base 2 logarithm of the input|
|**to_record**  |std_logic_vector|SlaveToMaster|Converts a STM_vector signal into a record|
|**to_vector**  |SlaveToMaster|std_logic_vector|Converts a STM record into an std_logic_vector|
|**to_record**  |std_logic_vector|MasterToSlave|Converts a MTS_vector signal into a record|
|**to_vector**  |MasterToSlave|std_logic_vector|Converts a MTS record into an std_logic_vector|


```vhdl
entity crossbar is
    generic (
        NB_SLAVES   : integer := 3;
        NB_MASTERS  : integer := 2);
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
```
<div align="center"><img src="/ICOBS_MK7/IMG/xbar.svg" width="800"/></div>


## Port_Master
```vhdl
 entity port_master is
    generic (
        NB_SLAVES : integer := 3; 
        NB_MASTERS : integer := 2); 
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
```
Each Master_Port recieves its data from two different sources. The first one is from the crossbar itself in the form of one MTS record sent specifically to each Master as well as all the slave base addresses and their address masks. This data is sent to slaves. \
The second source of data is all the slave ports instantiated inside the crossbar, but only one slave's data are taken into consideration. The choice of the said slave is determined through the decoder module. Then we look into these signals according to the OBI specifications and send them to the crossbar top entity through *if_slvo_vec*.

# <div align="center"><img src="/ICOBS_MK7/IMG/master.svg" width="600"/></div>

## Port_Slave


``` vhdl
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
```
Each Port_Slave also gets his data from two different sources just like the Master_Port. The first being the crossbar in which the port has been instantiated in the form of *if_msti_vec* which is an STM_vector type of signals. This data is sent to all the master ports once the arbiter determines that the port slave had been selected. \
The second source of data is all the master ports instantiated in the crossbar and only the data of one master port will be sent over to the crossbar through the *if_msto_vec* signal.

<div align="center"><img src="/ICOBS_MK7/IMG/slave.svg" width="600"/></div>
