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
-- OBI Library
-- Author: Aymen Romdhane
-- Update: 17/05/2022
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


-- Number of Slaves and Masters has to be changed manually for now 
package obi_lib is 

-------------- Array of 32bits vectors used for masks and addresses--------------
type t_32bits_vec is array(natural range <>) of std_logic_vector(31 downto 0);
type t_cs_rvalid is array(natural range <>) of integer; 
-------------- OBI Slave interface --------------

type MasterToSlave is record --Port Master Input
    req     :std_logic;
    addr    :std_logic_vector(31 downto 0);
    we      :std_logic;
    be      :std_logic_vector(3 downto 0);
    wdata   :std_logic_vector(31 downto 0);
    auser   :std_logic;
    wuser   :std_logic;
    rready  :std_logic;
    aid     :std_logic;
end record;

type t_addr     is array(natural range <>) of std_logic_vector(31 downto 0);
type t_be       is array(natural range <>) of std_logic_vector(3 downto 0);
type t_wdata    is array(natural range <>) of std_logic_vector(31 downto 0);


type t_MasterToSlave is array(natural range <>) of MasterToSlave;

--Master To Slave vector
subtype MTS_vector is std_logic_vector(73 downto 0); 
-------------- Array of MTS vectors--------------
type t_MTS_vec is array(natural range <>) of MTS_vector;

function to_vector(rec : MasterToSlave) return std_logic_vector;
function to_record(vec : std_logic_vector) return MasterToSlave;


type SlaveToMaster is record --Port Master Output
    gnt     :std_logic;
    rvalid  :std_logic;
    rdata   :std_logic_vector(31 downto 0);
    ruser   :std_logic;
    err     :std_logic;
    rid     :std_logic;
end record;

type t_rdata is array(natural range <>) of std_logic_vector(31 downto 0);
--Array of SlaveToMaster Record ---
type t_SlaveToMaster is array(natural range <>) of SlaveToMaster;



-- Slave To Master vector
subtype STM_vector is std_logic_vector(36 downto 0); 

-------------- Array of STM vectors--------------
type t_STM_vec is array(natural range <>) of STM_vector;

function to_vector(rec : SlaveToMaster) return std_logic_vector;
function to_record(vec : std_logic_vector) return SlaveToMaster;


-------------- Other Functions --------------
---- log2
function f_log2 (x : positive) return natural;

end package;

-----------------------------------------------------------------------------------------
package body obi_lib is

    -- Master To Slave interface to logic vector
    function to_vector(rec : MasterToSlave) return std_logic_vector is
    begin
        return rec.aid & rec.rready & rec.wuser & rec.auser & rec.wdata & rec.be & rec.we & rec.addr & rec.req;
    end function;
    
    -- Master To Slave interface from logic vector
    function to_record(vec : std_logic_vector) return MasterToSlave is
    begin
        return (
            req   => vec(0),
            addr  => vec(32 downto 1),
            we    => vec(33),
            be    => vec(37 downto 34),
            wdata => vec(69 downto 38),
            auser => vec(70),
            wuser => vec(71),
            rready=> vec(72),
            aid   => vec(73)
        );
    end function;

     -- Slave To Master interface to logic vector
    function to_vector(rec : SlaveToMaster) return std_logic_vector is
        begin
            return rec.rid & rec.err & rec.ruser & rec.rdata & rec.rvalid & rec.gnt;
        end function;
        
        -- Slave To Master interface from logic vector
        function to_record(vec : std_logic_vector) return SlaveToMaster is
        begin
            return (
                gnt     => vec(0),
                rvalid  => vec(1),
                rdata   => vec(33 downto 2),
                ruser   => vec(34),
                err     => vec(35),
                rid     => vec(36) 
            );
        end function;   

    function f_log2 (x : positive) return natural is
        variable i : natural;
        begin
        i := 0; 
        if x = 1 then i := 1 ;
        else
            while (2**i < x) and i < 31 loop
                i := i + 1;
            end loop;
        end if;
        return i;
        end function;
end package body;





