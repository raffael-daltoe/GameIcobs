----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 22.12.2017 08:25:51
-- Design Name:
-- Module Name: hex7seg - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;

entity hex7seg is
  port(
    hex: in std_logic_vector(3 downto 0);
    a_to_g: out std_logic_vector(0 to 6));
end hex7seg;

architecture Behavioral of hex7seg is
begin
  process (hex)
    begin
      case hex is
      when x"0" => a_to_g <="0000001"; -- 0
      when x"1" => a_to_g <="1001111"; -- 1
      when x"2" => a_to_g <="0010010"; -- 2
      when x"3" => a_to_g <="0000110"; -- 3
      when x"4" => a_to_g <="1001100"; -- 4
      when x"5" => a_to_g <="0100100"; -- 5
      when x"6" => a_to_g <="0100000"; -- 6
      when x"7" => a_to_g <="0001111"; -- 7
      when x"8" => a_to_g <="0000000"; -- 8
      when x"9" => a_to_g <="0000100"; -- 9
      when x"A" => a_to_g <="0001000"; -- A
      when x"B" => a_to_g <="1100000"; -- b
      when x"C" => a_to_g <="0110001"; -- C
      when x"D" => a_to_g <="1000010"; -- d
      when x"E" => a_to_g <="0110000"; -- E
      when others => a_to_g <="1111111"; -- ' '
    end case;
  end process;

end Behavioral;
