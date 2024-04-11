library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Pacman_Clock is
    Port ( clk_50mhz : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_1hz : out STD_LOGIC);
end Pacman_Clock;

architecture Behavioral of Pacman_Clock is
    signal counter: std_logic_vector(25 downto 0) := (others => '0');
    signal tmp_clk_1hz: STD_LOGIC := '0';
begin
    process(clk_50mhz, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            tmp_clk_1hz <= '0';
        elsif rising_edge(clk_50mhz) then
            if counter = "10111110101111000010000000" then 
                counter <= (others => '0');
                tmp_clk_1hz <= NOT tmp_clk_1hz;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_1hz <= tmp_clk_1hz;

end Behavioral;
