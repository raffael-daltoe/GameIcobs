-- ##########################################################
-- ##########################################################
-- ##    __    ______   ______   .______        _______.   ##
-- ##   |  |  /      | /  __  \  |   _  \      /       |   ##
-- ##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
-- ##   |  | |  |     |  |  |  | |   _  <      \   \       ##
-- ##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
-- ##   |__|  \______| \______/  |______/  |_______/       ##
-- ##                                                      ##
-- ##########################################################
-- ##########################################################
-------------------------------------------------------------
-- Arbiter entity
-- Author: Robin Verlegh
-- Update: 26/09/2022
-------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library interface;
use interface.obi_lib.all;

entity arbiter is
    generic (NB_MASTERS : integer := 2);
    port (
        clk : in std_logic;
        reset : in std_logic;
        mstr_cs_slave : in std_logic_vector(NB_MASTERS-1 downto 0);
        arb_cs_slave : out std_logic_vector(NB_MASTERS-1 downto 0)
    );
end entity arbiter;

architecture arch of arbiter is

--signal MASTER_BITS : integer; --Library parameter
signal conflict_cs, arb_cs_slv_eq_o, arb_cs_slv_eq_i, arb_cs_slv_eq_q: std_logic_vector(NB_MASTERS-1 downto 0);
signal conflict : std_logic;
signal count_ones : std_logic_vector(f_log2(NB_MASTERS) downto 0);

--Utilisé dans les boucles if
signal NB_MASTERS_s : integer := NB_MASTERS;
signal true_false : std_logic;
--signal operator_out, operator_or : std_logic;

begin 

process(all)
begin
if (count_ones >= 2) then --here
    true_false <= '1';
else 
    true_false <= '0';
end if;
end process;

process(all)
begin
if (true_false and (not arb_cs_slv_eq_i(0)) and (not arb_cs_slv_eq_q(0))) = '1' then
    arb_cs_slave <= arb_cs_slv_eq_q ;
else 
    arb_cs_slave <= arb_cs_slv_eq_o;
end if;
end process;

prc_arb_cs_slv_eq_q : process (clk, reset) --here
begin
if not reset = '1' then 
    arb_cs_slv_eq_q(0) <= '0'; 
elsif rising_edge(clk) then 
    if (or arb_cs_slv_eq_o) = '1' then
        arb_cs_slv_eq_q <= arb_cs_slv_eq_o;
        -- else arb_cs_slv_eq_q <= (others =>'0');-- change here
    end if;
       
end if;
end process;

process(all)
variable count_ones_bis : std_logic_vector(f_log2(NB_MASTERS) downto 0);
begin
count_ones_bis := (others => '0');
for I in 0 to NB_MASTERS-1 loop 
    count_ones_bis := count_ones_bis + mstr_cs_slave(I);
end loop;
    count_ones <= count_ones_bis;
end process;

--operator : process(temp, operator_out)
--begin
--for i in 0 to NBM-1 loop
--    operator_out <= operator_out or temp(i);
--end loop;
--end process;

prc_check_slave_busy : process(all)
variable temp: std_logic_vector(NB_MASTERS-1 downto 0);
begin
temp := (others => '0');
if count_ones >= 2 then
    if (not arb_cs_slv_eq_i(0) and (not arb_cs_slv_eq_q(0))) = '1' then
        for i in 0 to NB_MASTERS-1 loop 
            for j in 0 to NB_MASTERS-1 loop 
                if (i /= j) then
                    temp(j) := arb_cs_slv_eq_q(j);
                end if;
            end loop;
        arb_cs_slv_eq_o(i) <= arb_cs_slv_eq_i(i) and (not(or temp));
        end loop;
    else 
    arb_cs_slv_eq_o(0) <= arb_cs_slv_eq_i(0);
        for i in 1 to NB_MASTERS-1 loop
            arb_cs_slv_eq_o(i) <= '0';
        end loop;
    end if;
else 
    arb_cs_slv_eq_o <= arb_cs_slv_eq_i;
end if;
                                
end process;

prc_arb_cs_slv_eq : process(all)
begin

arb_cs_slv_eq_i <= (others => '0');
if conflict = '0' then
    arb_cs_slv_eq_i <= mstr_cs_slave;
else
    arb_cs_slv_eq_i <= conflict_cs;
end if;
end process;

prc_conflict_cs : process(all)
begin

conflict_cs <= (others => '0');
for i in 0 to NB_MASTERS-1 loop 
    if mstr_cs_slave(i) = '1' then
        conflict_cs(i) <= '1';
        exit;
    end if;
end loop;
end process;

prc_detect_conflict : process(all)
variable cnt_ones : std_logic_vector(2 downto 0);
begin

cnt_ones := (others => '0');
conflict <= '0';

for i in 0 to NB_MASTERS-1 loop 
    if mstr_cs_slave(i) = '1' then
        cnt_ones := cnt_ones + 1;
    end if;
end loop;
if cnt_ones <= 1 then
    conflict <= '0';
else 
    conflict <= '1';
end if;
end process;

end arch ; -- arch
