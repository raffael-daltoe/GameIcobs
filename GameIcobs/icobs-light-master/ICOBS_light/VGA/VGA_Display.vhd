
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.packages.all;
entity VGA_Display is
    Port ( vidon : in  STD_LOGIC;
           hc : in  vector10;
           vc : in  vector10;
           sw: in  STD_LOGIC_VECTOR (11 downto 0);
           red : out  vector4;
           green : out  vector4;
           blue : out  vector4
		);
end VGA_Display;

architecture Behavioral of VGA_Display is

begin

process(vidon, sw)
begin
	
	if vidon = '1' then
		red   <= sw(11 downto 8) ;
		green <= sw(7 downto 4);
		blue  <= sw(3 downto 0); 
	else
	    red   <= (others => '0');
		green <= (others => '0');
		blue  <= (others => '0'); 
	end if;
	
	
end process;

end Behavioral;

