----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2017 08:47:25
-- Design Name: 
-- Module Name: mux4x4 - Behavioral
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

entity mux4x4 is
    Port ( E1 : in STD_LOGIC_VECTOR (3 downto 0);
           E2 : in STD_LOGIC_VECTOR (3 downto 0);
           E3 : in STD_LOGIC_VECTOR (3 downto 0);
           E4 : in STD_LOGIC_VECTOR (3 downto 0);
           SEL : in STD_LOGIC_VECTOR (1 downto 0);
           SORTIE : out STD_LOGIC_VECTOR (3 downto 0));
end mux4x4;

architecture Behavioral of mux4x4 is

begin

prc : process (SEL,E1,E2,E3,E4)
begin
case SEL is
     when "00" => SORTIE <= E1;
     when "01" => SORTIE <= E2;
     when "10" => SORTIE <= E3;
     when "11" => SORTIE <= E4;
     when others => SORTIE <= (others => '0');
end case;
end process;
end Behavioral;
