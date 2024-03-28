library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.VGA_Generic_Package.all;
entity VGA_640_x_480_tb is
-- Testbench has no ports.
end VGA_640_x_480_tb;

architecture behavior of VGA_640_x_480_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component VGA_640_x_480
        Port ( rst : in  STD_LOGIC;
               clk : in  STD_LOGIC;
               hsync : out  STD_LOGIC;
               vsync : out  STD_LOGIC;
               hc : out  STD_LOGIC_VECTOR (9 downto 0);
               vc : out  STD_LOGIC_VECTOR (9 downto 0);
               vidon : out  STD_LOGIC);
    end component;

    --Inputs
    signal rst : std_logic := '0';
    signal clk : std_logic := '0';

    --Outputs
    signal hsync : std_logic;
    signal vsync : std_logic;
    signal hc : std_logic_vector(9 downto 0);
    signal vc : std_logic_vector(9 downto 0);
    signal vidon : std_logic;

    -- Clock period definitions
    constant clk_period : time := 40 ns; -- Adjust as needed for your design

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: VGA_640_x_480
        Port map (
            rst => rst,
            clk => clk,
            hsync => hsync,
            vsync => vsync,
            hc => hc,
            vc => vc,
            vidon => vidon
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- Initialize Inputs
        rst <= '1';
        wait for 100 ns; -- Adjust time for reset duration
        
        rst <= '0';
        -- You can add more test cases here

        wait; -- will wait forever
    end process;

end behavior;
