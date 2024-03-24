library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg_top is
    Port ( mclk : in STD_LOGIC;
           rst : in STD_LOGIC;
           E1 : in STD_LOGIC_VECTOR (3 downto 0);
           E2 : in STD_LOGIC_VECTOR (3 downto 0);
           E3 : in STD_LOGIC_VECTOR (3 downto 0);
           E4 : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end seg_top;

architecture Behavioral of seg_top is

component clkdiv is
    PORT(rst : in STD_LOGIC;
         clk : in STD_LOGIC;
         clk190 : out STD_LOGIC);
end component;

COMPONENT compteur is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           sortie : out  STD_LOGIC_VECTOR (1 downto 0));
end COMPONENT;

COMPONENT mux4x4
    Port ( E1 : in STD_LOGIC_VECTOR (3 downto 0);
           E2 : in STD_LOGIC_VECTOR (3 downto 0);
           E3 : in STD_LOGIC_VECTOR (3 downto 0);
           E4 : in STD_LOGIC_VECTOR (3 downto 0);
           SEL : in STD_LOGIC_VECTOR (1 downto 0);
           SORTIE : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component gestion_an
    Port ( entree : in STD_LOGIC_VECTOR (1 downto 0);
           rst : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component hex7seg
  port(
    hex: in std_logic_vector(3 downto 0);
    a_to_g: out std_logic_vector(0 to 6));
end component;

signal sortie_cpt : STD_LOGIC_VECTOR (1 downto 0);
signal sortie_mux : STD_LOGIC_VECTOR (3 downto 0);
signal clkdiv190 : STD_LOGIC;

begin

dut2: clkdiv PORT MAP (
        rst => rst,
        clk => mclk,
        clk190 => clkdiv190);

dut4: compteur PORT MAP (
        rst => rst,
        clk => clkdiv190,
        sortie => sortie_cpt);

dut5: mux4x4 PORT MAP (
        E1 => E1,
        E2 => E2,
        E3 => E3,
        E4 => E4,
        SEL => sortie_cpt,
        SORTIE =>sortie_mux);

dut6: gestion_an PORT MAP (
        entree => sortie_cpt,
        rst => rst,
        an => an);

dut7: hex7seg PORT MAP (
        hex => sortie_mux,
        a_to_g => seg);

end Behavioral;
