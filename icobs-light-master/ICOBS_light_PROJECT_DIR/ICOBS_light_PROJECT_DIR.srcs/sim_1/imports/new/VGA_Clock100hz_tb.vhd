library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity VGA_Clock100hz_tb is
end VGA_Clock100hz_tb;

architecture Behavioral of VGA_Clock100hz_tb is
    signal clk,rst,clk100 : std_logic :='0';
begin
    rst <= '1', '0' after 5ns;
    U1: entity work.VGA_Clock100hz port map(mclk=>clk,reset=>rst, clk100=>clk100);

    process
    begin
        if rst = '1' then
            clk <= '0';
        else
            clk <= not clk;
            wait for 5ns;
        end if;
    end process;

end Behavioral;
