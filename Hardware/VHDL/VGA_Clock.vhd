library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_Clock100hz is
    Generic(N: integer:=8);
    Port ( rst : in STD_LOGIC;
           clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end VGA_Clock100hz;

architecture Behavioral of VGA_Clock100hz is
signal count: std_logic_vector(N-1 downto 0);

begin

process(clk_in, rst)
begin
    if rst='1' then count <= (others=>'0');
    elsif clk_in'event and clk_in='1' then
        count <= count + 1;
    end if;
end process;

clk_out <= count(N-1);

end Behavioral;