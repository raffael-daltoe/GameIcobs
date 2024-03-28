library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library common;
use common.constants.all;

entity icobs_tb is
--  Port ( );
end icobs_tb;

architecture Behavioral of icobs_tb is


    component ICOBS_light_TOP
        port (
            EXTCLK       	: in  std_logic;

            HARDRESET    	: in  std_logic;

            IOPA            : inout std_logic_vector(IOPA_LEN-1 downto 0);
            IOPB            : inout std_logic_vector(IOPB_LEN-1 downto 0);
            IOPC            : inout std_logic_vector(IOPC_LEN-1 downto 0);

            UART_RX			: in  std_logic;
            UART_TX			: out std_logic);
        end component;

    signal EXTCLK_s       	:  std_logic;
    signal HARDRESET_s    	:  std_logic;
    signal IOPA_s           :  std_logic_vector(IOPA_LEN-1 downto 0);
    signal IOPB_s           :  std_logic_vector(IOPB_LEN-1 downto 0);
    signal IOPC_s           :  std_logic_vector(IOPC_LEN-1 downto 0);
    signal UART_RX_s		:  std_logic := '1';
    signal UART_TX_s		:  std_logic;

    begin

    U0: ICOBS_light_TOP
    port map (
        EXTCLK       	=> EXTCLK_s,

        HARDRESET    	=> HARDRESET_s,

        IOPA            => IOPA_s,
        IOPB            => IOPB_s,
        IOPC            => IOPC_s,

        UART_RX			=> UART_RX_s,
        UART_TX			=> UART_TX_s);

    clock : process begin
        EXTCLK_s <= '0';
        wait for 5ns;
        EXTCLK_s <= '1';
        wait for 5ns;
    end process;

    reset : process begin
        HARDRESET_s <= '1';
        wait for 100ns;
        HARDRESET_s <= '0';
        wait;
    end process;

end Behavioral;
