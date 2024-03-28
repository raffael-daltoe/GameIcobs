LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VGA_Basic_ROM_Top_tb IS
    -- Testbench doesn't need ports
END VGA_Basic_ROM_Top_tb;

ARCHITECTURE Behavioral OF VGA_Basic_ROM_Top_tb IS
    -- Signal Declaration
    constant mclk_period : time := 10000ps;
    signal clk_tb,btnR_tb,Hsync_tb,Vsync_tb : std_logic;
    signal vgaRed_tb,vgaBlue_tb,vgaGreen_tb : std_logic_vector(3 downto 0);
    signal sw_tb : std_logic_vector(11 downto 0);

BEGIN
    -- Component Instantiation
    UUT : ENTITY work.VGA_Basic_ROM_Top PORT MAP(
        clk => clk_tb,
        btnR => btnR_tb,
        Hsync => Hsync_tb,
        Vsync => Vsync_tb,
        sw    => sw_tb,
        vgaRed => vgaRed_tb,
        vgaGreen => vgaGreen_tb,
        vgaBlue => vgaBlue_tb
    );

    -- Test Stimulus
    stim_proc : PROCESS
    BEGIN
        loop
            FOR i IN 0 TO 4095 LOOP
                sw_tb <= STD_LOGIC_VECTOR(to_unsigned(i, sw_tb'length));
                WAIT FOR 1000us;
            END LOOP;

        end loop;
    END PROCESS stim_proc;




        -- Clock process definitions
        mclk_process :process
        begin
            clk_tb <= '0';
            wait for mclk_period/2;
            clk_tb <= '1';
            wait for mclk_period/2;
        end process;
    
        -- Stimulus process
        reset: process
        begin        
            -- hold reset state for 100 ns.
            btnR_tb <= '1';
            wait for 100 ns;    
            
            btnR_tb <= '0';
            wait; -- will wait forever
        end process;

END Behavioral;