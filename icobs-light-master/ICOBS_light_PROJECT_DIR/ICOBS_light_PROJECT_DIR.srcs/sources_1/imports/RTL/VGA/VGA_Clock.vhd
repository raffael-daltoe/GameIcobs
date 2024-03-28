library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use work.packages.all;

entity VGA_Clock is
    port (
        reset: in STD_LOGIC;
        mclk: in STD_LOGIC;
        clk100: out STD_LOGIC
    );
end VGA_Clock;

architecture Behavioral of VGA_Clock is
    signal q : std_logic_vector(19 downto 0); 
    signal aux : std_logic;
begin
    seq: process(mclk, reset)
    begin
        if reset = '1' then
            q <= (others => '0');
            aux <= '0';
        elsif rising_edge(mclk) then
            if q = "11110100001001000000" then
                aux <= not aux;
                q <= (others => '0');
            else
                q <= q + 1;
            end if;
        end if;
    end process;

    clk100 <= aux;
end Behavioral;