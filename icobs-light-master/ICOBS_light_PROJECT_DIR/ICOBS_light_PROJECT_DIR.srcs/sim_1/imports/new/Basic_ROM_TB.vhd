LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Basic_ROM_TB IS
    -- Testbench doesn't need ports
END Basic_ROM_TB;

ARCHITECTURE Behavioral OF Basic_ROM_TB IS
    -- Signal Declaration
    SIGNAL tb_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL tb_M : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

    -- Component Instantiation
    UUT : ENTITY work.Basic_ROM PORT MAP(
        addr => tb_addr,
        M => tb_M
        );

    -- Test Stimulus
    stim_proc : PROCESS
    BEGIN
        -- Apply test vectors
        -- Example: Set address and wait to observe the output
        FOR i IN 0 TO 4095 LOOP
            tb_addr <= STD_LOGIC_VECTOR(to_unsigned(i, tb_addr'length));
            WAIT FOR 100 ns;
        END LOOP;

        -- Continue with other test vectors

        WAIT; -- Wait indefinitely; this will terminate the simulation
    END PROCESS stim_proc;

END Behavioral;