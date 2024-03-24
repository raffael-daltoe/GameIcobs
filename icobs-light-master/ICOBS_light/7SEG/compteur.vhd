----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2017 15:50:52
-- Design Name: 
-- Module Name: compteur - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compteur is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sortie : out STD_LOGIC_VECTOR (1 downto 0));
end compteur;

architecture Behavioral of compteur is

signal cpt : STD_LOGIC_VECTOR (1 downto 0);

begin
process(clk, rst)
    begin
    if rst='1' then cpt <= (others => '0');
    elsif clk'event and clk='1' then
            cpt <= cpt+1;
    end if;
end process;
sortie <= cpt;

end Behavioral;
