library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity Mover_A_tb is
end Mover_A_tb;

architecture Behavioral of Mover_A_tb is
    signal clk,rst : STD_LOGIC;
	signal R1,C1 : unsigned(9 downto 0);

begin
    Tb: ENTITY work.Mover_A port map( clk=> clk, rst=>rst, R1=>R1,C1=>C1);
    
    rst <= '1', '0' after 5ns;
    mclk_process :process
    begin
        clk <= '0';
        wait for 10ms;
        clk <= '1';
        wait for 10ms;
    end process;



end Behavioral;
