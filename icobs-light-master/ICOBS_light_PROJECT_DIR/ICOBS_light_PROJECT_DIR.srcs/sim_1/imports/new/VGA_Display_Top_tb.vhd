library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Display_Top_tb is
-- Testbench has no ports.
end VGA_Display_Top_tb;

architecture behavior of VGA_Display_Top_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component VGA_Display_Top
        Port ( clk : in  STD_LOGIC;
               btnR : in  STD_LOGIC;
               Hsync : out  STD_LOGIC;
               Vsync : out  STD_LOGIC;
               sw : in  STD_LOGIC_VECTOR (11 downto 0);
               vgaRed : out  STD_LOGIC_VECTOR (3 downto 0);
               vgaGreen : out  STD_LOGIC_VECTOR (3 downto 0);
               vgaBlue : out  STD_LOGIC_VECTOR (3 downto 0));
    end component;

    --Inputs
    signal clk : std_logic := '0';
    signal btnR : std_logic := '0';
    signal sw : std_logic_vector(11 downto 0) := (others => '0');

    --Outputs
    signal Hsync : std_logic;
    signal Vsync : std_logic;
    signal vgaRed : std_logic_vector(3 downto 0);
    signal vgaGreen : std_logic_vector(3 downto 0);
    signal vgaBlue : std_logic_vector(3 downto 0);

    -- Clock period definitions
    constant clk_period : time := 0.04 us; -- Adjust as needed for your design

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: VGA_Display_Top
        Port map (
            clk => clk,
            btnR => btnR,
            Hsync => Hsync,
            Vsync => Vsync,
            sw => sw,
            vgaRed => vgaRed,
            vgaGreen => vgaGreen,
            vgaBlue => vgaBlue
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
        variable sw_int : integer range 0 to 4095; -- Assuming a 12-bit switch
    begin        
        -- Initialize Inputs
        btnR <= '1';
        sw <= (others => '0');
        sw_int := 0; -- Initialize the switch integer variable


        -- Wait for the global reset to finish
        wait for 100 ns; 
        
        -- Add stimulus here
        -- Example: toggle button and change switch values
        btnR <= '0';
        wait for 1 us;
        while sw_int <= 4095 loop
            sw <= std_logic_vector(to_unsigned(sw_int, sw'length)); -- Convert integer to std_logic_vector
            wait for 2 ms; -- Adjust the delay as needed
            sw_int := sw_int + 1; -- Increment the integer value
    end loop;
        wait; -- will wait forever
    end process;

end behavior;
