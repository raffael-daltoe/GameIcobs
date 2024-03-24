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
-- 100MHz to 50MHz clock divider
-- Author: Soriano Theo
-- Update: 28-01-2022
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk50 is
    Port ( mclk : in STD_LOGIC;
           clk50 : out STD_LOGIC);
end clk50;

architecture Behavioral of clk50 is
signal count: std_logic_vector(1 downto 0) := "00";
begin

gen_clk25: process(mclk)
begin
    if rising_edge(mclk) then
        count <= count + 1;
    end if;
end process;

clk50 <= count(0);

end Behavioral;
