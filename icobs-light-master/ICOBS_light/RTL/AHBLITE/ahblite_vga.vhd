----------------------------------------------------------------
-- Peripheral VGA
-- Raffael Daltoe
-- Update: 21-03-2024
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library amba3;
use amba3.ahblite.all;

----------------------------------------------------------------
entity ahblite_vga is
port (
	HRESETn          : in  std_logic;
	HCLK             : in  std_logic;

	HSEL             : in  std_logic;
	HREADY           : in  std_logic;

	sw				 : in std_logic_vector(11 downto 0);
    -- Outputs of VGA 
    vgaRed_ahblite   : OUT std_logic_vector(3 downto 0);
    vgaGreen_ahblite : OUT std_logic_vector(3 downto 0);
    vgaBLue_ahblite  : OUT std_logic_vector(3 downto 0);
    Hsync_ahblite    : OUT std_logic;
    Vsync_ahblite    : OUT std_logic; 

	-- AHB-Lite interface
	AHBLITE_IN  : in  AHBLite_master_vector;
	AHBLITE_OUT : out AHBLite_slave_vector);
end;

----------------------------------------------------------------
architecture arch of ahblite_vga is

	signal transfer : std_logic;
	signal invalid  : std_logic;
	signal SlaveIn  : AHBLite_master;
	signal SlaveOut : AHBLite_slave;

	signal address  : std_logic_vector(9 downto 2);
	signal lastaddr : std_logic_vector(9 downto 2);
	signal lastwr   : std_logic;

	-- Memory organization:
	-- +--------+--------+---------------------------+
	-- | OFFSET | NAME   | DESCRIPTION               |
	-- +--------+--------+---------------------------+
	-- |  x000  | Backgr | Basic R/W Register        |
	-- +--------+--------+---------------------------+

	signal RST 	   : std_logic;

    signal Background : std_logic_vector(31 downto 0);
	signal X1_Position, Y1_Position : std_logic_vector(31 downto 0);
    --signal X1_Position, Y1_Position : std_logic;

----------------------------------------------------------------
begin

    -- DTop_1: entity work.VGA_Display_Top port map(
    --         clk                => HCLK,
    --         btnR               => RST,
    --         Hsync              => Hsync_ahblite,
    --         Vsync              => Vsync_ahblite,
    --         --sw                 => Background (11 DOWNTO 0),
	-- 		sw				   => sw,
    --         vgaRed		   	   => vgaRed_ahblite,
    --         vgaGreen   		   => vgaGreen_ahblite,
    --         vgaBlue   		   => vgaBLue_ahblite
    --    );
	VGA_ROM_TOP : entity work.VGA_TOP port map(
		clk 		=>  HCLK,
        btnC 		=>  RST,
        Hsync 		=>  Hsync_ahblite,
        Vsync 		=>  Vsync_ahblite,
		btnU		=> 	Y1_Position(0),	-- above
		btnD		=> 	Y1_Position(1),	-- below
		btnR		=> 	X1_Position(0),	-- right
		btnL		=> 	X1_Position(1),	-- left
        vgaRed   	=>  vgaRed_ahblite,
        vgaGreen 	=>  vgaGreen_ahblite,
        vgaBlue  	=>  vgaBLue_ahblite

	);

	RST <= not HRESETn;

	AHBLITE_OUT <= to_vector(SlaveOut);
	SlaveIn <= to_record(AHBLITE_IN);

	transfer <= HSEL and SlaveIn.HTRANS(1) and HREADY;
	-- Invalid if not a 32-bit aligned transfer
	invalid  <= transfer and (SlaveIn.HSIZE(2) or (not SlaveIn.HSIZE(1)) or SlaveIn.HSIZE(0) or SlaveIn.HADDR(1) or SlaveIn.HADDR(0));

	address <= SlaveIn.HADDR(address'range);

	----------------------------------------------------------------
	process (HCLK, HRESETn) begin
		if HRESETn = '0' then
			-- Reset
			SlaveOut.HREADYOUT <= '1';
			SlaveOut.HRESP <= '0';
			SlaveOut.HRDATA <= (others => '0');

			lastwr <= '0';
			lastaddr <= (others => '0');

			-- Reset values
            Background <= (others => '0');
			Y1_Position <= (others => '0');
			X1_Position <= (others => '0');
			--Y1_Position <= '0';
			--X1_Position <= '0';
		--------------------------------
		elsif rising_edge(HCLK) then
			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"00" => Background  <= SlaveIn.HWDATA;
                    when x"01" => X1_Position <= SlaveIn.HWDATA;
					when x"02" => Y1_Position <= SlaveIn.HWDATA;
					when others =>
				end case;
			end if;

			-- Check for transfer
			if transfer = '1' and invalid = '0' then
				-- Read operation: retrieve data and fill empty spaces with '0'
				if SlaveIn.HWRITE = '0' then
					SlaveOut.HRDATA <= (others => '0');
					case address is
						when x"00" => SlaveOut.HRDATA <= Background;
						when x"01" => SlaveOut.HRDATA <= X1_Position;
						when x"02" => SlaveOut.HRDATA <= Y1_Position;
						when others =>
					end case;
				end if;

				-- Keep address and write command for next cycle
				lastaddr <= address;
				lastwr <= SlaveIn.HWRITE;
			else
				lastwr <= '0';
			end if;
		end if;
	end process;

end;
