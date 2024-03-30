Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

library interface;
use interface.obi_lib.all;

entity obi_2_rom is
port (
        clk         : in  std_logic;

        -- OBI Slave interface : receive data from OBI Master
        if_slvi_vec       : in  MTS_vector;
        if_slvo_vec       : out STM_vector;

        -- RAM interface
        ena   					: out std_logic;
		addra 					: out std_logic_vector(31 downto 0);
		douta 					: in  std_logic_vector(31 downto 0));
end obi_2_rom;

architecture arch of obi_2_rom is

signal if_slvi   : MasterToSlave;
signal if_slvo   : SlaveToMaster;

begin

  -- OBI INPUT
  if_slvi       <= to_record(if_slvi_vec);

  -- INPUTS
  -- if_slvi.req;         ok
  -- if_slvi.addr;        ok
  -- if_slvi.we;          ok
  -- if_slvi.be;          ok
  -- if_slvi.wdata;       ok

  -- if_slvi.auser;       unused
  -- if_slvi.wuser;       unused
  -- if_slvi.rready;      unused
  -- if_slvi.aid;         unused

  -- OUTPUT
  -- ena                    ok
  -- wea                    ok
  -- addra                  ok
  -- dina                   ok

  addra     <= if_slvi.addr;
  ena       <= if_slvi.req;

  -- MEM OUTPUT
  if_slvo_vec   <= to_vector(if_slvo);

  -- OUTPUTS
  -- if_slvo.gnt     <= ;       1 hardwired
  -- if_slvo.rvalid  <= ;       ok
  -- if_slvo.rdata   <= ;       ok
  -- if_slvo.err     <= ;       0 hardwired

  -- if_slvo.ruser   <= ;       0 hardwired
  -- if_slvo.rid     <= ;       0 hardwired

  -- INPUTS
  -- douta

  valid : process(clk)
  begin
      if (clk'event and clk = '1') then
          if_slvo.rvalid <= if_slvi.req;
	  end if;
  end process;

  if_slvo.rdata   <=   douta;
  if_slvo.gnt     <=   '1';
  if_slvo.err     <=   '0';
  if_slvo.ruser   <=   '0';
  if_slvo.rid     <=   '0';

end arch;
