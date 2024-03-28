----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11.12.2017 16:33:36
-- Design Name:
-- Module Name: clkdiv - Behavioral
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

entity clkdiv is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           clk190 : out STD_LOGIC);
end clkdiv;

architecture Behavioral of clkdiv is

SIGNAL count : STD_LOGIC_VECTOR(24 downto 0);

begin

process(rst, clk)
begin
    if rst='1' then count <= (others => '0');
    elsif clk'event and clk='1' then
    count <= count+1;
    end if;
end process;
clk190 <= count(17);

end Behavioral;
