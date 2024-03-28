library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Clock_tb is
-- Testbench has no ports.
end VGA_Clock_tb;

architecture behavior of VGA_Clock_tb is
    --Inputs
    signal reset : std_logic := '0';
    signal mclk  : std_logic := '0';

    --Outputs
    signal clk25 : std_logic;

    -- Clock period definitions
    constant mclk_period : time := 10ns;  -- Modify as per your clock requirements

begin
    clock: entity work.VGA_Clock100hz port map(reset => reset, mclk => mclk, clk100 => clk25);
    -- Clock process definitions
    mclk_process :process
    begin
        mclk <= '0';
        wait for mclk_period/2;
        mclk <= '1';
        wait for mclk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- hold reset state for 100 ns.
        reset <= '1';
        wait for 100 ns;    
        
        reset <= '0';
        wait; -- will wait forever
    end process;
    

end;
