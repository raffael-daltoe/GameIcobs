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

    -- Outputs of VGA 
    vgaRed_ahblite   : OUT std_logic_vector(3 downto 0);
    vgaGreen_ahblite : OUT std_logic_vector(3 downto 0);
    vgaBLue_ahblite  : OUT std_logic_vector(3 downto 0);
    Hsync_ahblite    : OUT std_logic;
    Vsync_ahblite    : OUT std_logic;

	seg			: OUT std_logic_vector(0 to 6);
	an			: OUT std_logic_vector(3 downto 0);
	dp 			: OUT std_logic; 

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
	-- |  0x00  | Backgr | Basic R/W Register        |
	-- |  0x01  | X1_Pos | Basic R/W Register 		 |
	-- |  0x02  | Y1_Pos | Basic R/W Register 	     |
	-- +--------+--------+---------------------------+

	signal RST 	   : std_logic;

    signal Background : std_logic_vector(31 downto 0);
    signal Scoreboard : std_logic_vector(31 downto 0);

	signal Register_Foods : std_logic_vector(31 downto 0);
	signal X0_Position, Y0_Position : std_logic_vector(31 downto 0);
	
	signal X1_Position, Y1_Position : std_logic_vector(31 downto 0);
	signal X2_Position, Y2_Position : std_logic_vector(31 downto 0);

	signal X3_Position, Y3_Position : std_logic_vector(31 downto 0);
	signal X4_Position, Y4_Position : std_logic_vector(31 downto 0);


----------------------------------------------------------------
begin

     DTop_1: entity work.VGA_TOP port map(
            clk                => HCLK,
            btnC               => RST,
            Hsync              => Hsync_ahblite,
            Vsync              => Vsync_ahblite,

        	sw                 => Background (11 DOWNTO 0),

			R0				   => Y0_Position(9 downto 0),
			C0				   => X0_Position(9 downto 0),	
			R1				   => Y1_Position(9 downto 0),
			C1				   => X1_Position(9 downto 0),
			R2				   => Y2_Position(9 downto 0),
			C2				   => X2_Position(9 downto 0),	
			R3				   => Y3_Position(9 downto 0),	
			C3				   => X3_Position(9 downto 0),	
			R4				   => Y4_Position(9 downto 0),
			C4				   => X4_Position(9 downto 0),
            Register_Foods_S   => Register_Foods,
            
            vgaRed		   	   => vgaRed_ahblite,
            vgaGreen   		   => vgaGreen_ahblite,
            vgaBlue   		   => vgaBLue_ahblite

        );

	U_SEG_CTRL: entity work.seg_top port map(
		mclk => HCLK,
		rst  => RST,
		E1   => Scoreboard(3 downto 0),
		E2   => Scoreboard(7 downto 4),
		E3   => Scoreboard(11 downto 8),
		E4   => Scoreboard(15 downto 12),
		seg  => seg,
		an   => an,
		dp   => dp
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
            Background     <= (others => '0');
			Y0_Position    <= (others => '0');
			X0_Position    <= (others => '0');
			Y1_Position    <= (others => '0');
			X1_Position    <= (others => '0');
			Y2_Position    <= (others => '0');
			X2_Position    <= (others => '0');
			Y3_Position    <= (others => '0');
			X3_Position    <= (others => '0');
			Y4_Position    <= (others => '0');
			X4_Position    <= (others => '0');
			--Scoreboard     <= (others => '0');
			Register_Foods <= (others => '0');
			Scoreboard <=  (others => '0');
			--Y5_Position <= (others => '0');
			--X5_Position <= (others => '0');
			
		--------------------------------
		elsif rising_edge(HCLK) then
			-- Error management
			SlaveOut.HREADYOUT <= not invalid;
			SlaveOut.HRESP <= invalid or not SlaveOut.HREADYOUT;

			-- Performe write if requested last cycle and no error occured
			if SlaveOut.HRESP = '0' and lastwr = '1' then
				case lastaddr is
					when x"00" => Background  <= SlaveIn.HWDATA;					
                    when x"01" => X0_Position <= SlaveIn.HWDATA;
					when x"02" => Y0_Position <= SlaveIn.HWDATA;					
                    when x"03" => X1_Position <= SlaveIn.HWDATA;
					when x"04" => Y1_Position <= SlaveIn.HWDATA;
					when x"05" => X2_Position <= SlaveIn.HWDATA;
					when x"06" => Y2_Position <= SlaveIn.HWDATA;
                    when x"07" => X3_Position <= SlaveIn.HWDATA;
					when x"08" => Y3_Position <= SlaveIn.HWDATA;
					when x"09" => X4_Position <= SlaveIn.HWDATA;
					when x"0A" => Y4_Position <= SlaveIn.HWDATA;
					when x"0B" => Register_Foods  <= SlaveIn.HWDATA;
					when x"0C" => Scoreboard <= SlaveIn.HWDATA;
					--when x"0C" => Y5_Position <= SlaveIn.HWDATA;
					
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
						when x"01" => SlaveOut.HRDATA <= X0_Position;
						when x"02" => SlaveOut.HRDATA <= Y0_Position;
						when x"03" => SlaveOut.HRDATA <= X1_Position;
						when x"04" => SlaveOut.HRDATA <= Y1_Position;
						when x"05" => SlaveOut.HRDATA <= X2_Position;
						when x"06" => SlaveOut.HRDATA <= Y2_Position;
						when x"07" => SlaveOut.HRDATA <= X3_Position;
						when x"08" => SlaveOut.HRDATA <= Y3_Position;
						when x"09" => SlaveOut.HRDATA <= X4_Position;
						when x"0A" => SlaveOut.HRDATA <= Y4_Position;
						when x"0B" => SlaveOut.HRDATA <= Register_Foods;
						when x"0C" => SlaveOut.HRDATA <= Scoreboard;
						--when x"0C" => SlaveOut.HRDATA <= Y5_Position;
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
