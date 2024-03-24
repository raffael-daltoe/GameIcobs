----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2017 16:19:09
-- Design Name: 
-- Module Name: gestion_an - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gestion_an is
    Port ( entree : in STD_LOGIC_VECTOR (1 downto 0);
           rst : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0));
end gestion_an;

architecture Behavioral of gestion_an is

begin

process(entree, rst)
    begin
    if rst = '1' then
        an <= (others => '1');
    else
        case entree is
        when "00" => an <= "0111";
        when "01" => an <= "1011";
        when "10" => an <= "1101";
        when "11" => an <= "1110";
        when others => an <= (others => '1');
        end case;
    end if;
end process;

end Behavioral;
