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
-- Decoder entity
-- Author: Aymen Romdhane
-- Update: 17/05/2022
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.numeric_std_unsigned.all;

library interface;
use interface.obi_lib.all;

entity decoder is
    generic(NB_SLAVES : integer := 2); -- NS : Number of slaves
    Port ( 
        slave_base_address : in t_32bits_vec(NB_SLAVES-1 downto 0);
        slave_address_mask : in t_32bits_vec(NB_SLAVES-1 downto 0);
        addr               : in std_logic_vector(31 downto 0);
        req                : in std_logic;
        decoder_cs         : out std_logic_vector(NB_SLAVES-1 downto 0)
    );
end decoder;

architecture Behavioral of decoder is
signal cs_slaves : std_logic_vector(NB_SLAVES-1 downto 0);
signal xnor_addr_dcdr, addr_masked_dcdr : t_32bits_vec(NB_SLAVES-1 downto 0);

begin 

addr_dcdr: for I in 0 to NB_SLAVES-1 generate

    xnor_addr_dcdr(I)   <=  addr xnor slave_base_address(I);
    addr_masked_dcdr(I) <=  xnor_addr_dcdr(I) or slave_address_mask(I);
    cs_slaves(I)        <=  and addr_masked_dcdr(I); 

end generate addr_dcdr;

process(all)
begin
    for i in 0 to NB_SLAVES-1 loop
        if req = '1' then
            decoder_cs(I) <= cs_slaves(I);
        else decoder_cs(I) <= '0';
        end if;
    end loop;
end process;
   
end Behavioral;
