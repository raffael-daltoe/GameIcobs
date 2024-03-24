----------------------------------------------------------------
-- AMBA3 definitions
-- Guillaume Patrigeon
-- Update: 14-01-2019
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------
package AHBLite is
	---------------- AHB-Lite - Master interface ----------------
	-- AHB-Lite master interface
	type AHBLite_master is record
		HWRITE    : std_logic;
		HSIZE     : std_logic_vector(2 downto 0);
		HBURST    : std_logic_vector(2 downto 0);
		HPROT     : std_logic_vector(3 downto 0);
		HTRANS    : std_logic_vector(1 downto 0);
		HMASTLOCK : std_logic;
		HADDR     : std_logic_vector(31 downto 0);
		HWDATA    : std_logic_vector(31 downto 0);
	end record;

	-- AHB-Lite master to slave logic vector
	subtype AHBLite_master_vector is std_logic_vector(77 downto 0);

	-- AHB-Lite master to slave conversion functions
	function to_vector(rec : AHBLite_master) return std_logic_vector;
	function to_record(rec : AHBLite_master) return AHBLite_master;
	function to_record(vec : std_logic_vector) return AHBLite_master;


	---------------- AHB-Lite - Slave interface ----------------
	-- AHB-Lite slave to master interface
	type AHBLite_slave is record
		HREADYOUT : std_logic;
		HRESP     : std_logic;
		HRDATA    : std_logic_vector(31 downto 0);
	end record;

	-- AHB-Lite slave to master logic vector
	subtype AHBLite_slave_vector is std_logic_vector(33 downto 0);

	-- AHB-Lite slave to master conversion functions
	function to_vector(rec : AHBLite_slave) return std_logic_vector;
	function to_record(rec : AHBLite_slave) return AHBLite_slave;
	function to_record(vec : std_logic_vector) return AHBLite_slave;
end package;


----------------------------------------------------------------
package body AHBLite is
	---------------- AHB-Lite - Master interface ----------------
	-- AHB-Lite master interface to logic vector
	function to_vector(rec : AHBLite_master) return std_logic_vector is
	begin
		return rec.HWRITE & rec.HSIZE & rec.HBURST & rec.HPROT & rec.HTRANS & rec.HMASTLOCK & rec.HADDR & rec.HWDATA;
	end function;

	-- AHB-Lite master interface dummy function
	function to_record(rec : AHBLite_master) return AHBLite_master is
	begin
		return rec;
	end function;

	-- AHB-Lite master interface from logic vector
	function to_record(vec : std_logic_vector) return AHBLite_master is
	begin
		return (
			HWRITE    => vec(77),
			HSIZE     => vec(76 downto 74),
			HBURST    => vec(73 downto 71),
			HPROT     => vec(70 downto 67),
			HTRANS    => vec(66 downto 65),
			HMASTLOCK => vec(64),
			HADDR     => vec(63 downto 32),
			HWDATA    => vec(31 downto 0));
	end function;


	---------------- AHB-Lite - Slave interface ----------------
	-- AHB-Lite slave interface to logic vector
	function to_vector(rec : AHBLite_slave) return std_logic_vector is
	begin
		return rec.HREADYOUT & rec.HRESP & rec.HRDATA;
	end function;

	-- AHB-Lite slave interface dummy function
	function to_record(rec : AHBLite_slave) return AHBLite_slave is
	begin
		return rec;
	end function;

	-- AHB-Lite slave interface from logic vector
	function to_record(vec : std_logic_vector) return AHBLite_slave is
	begin
		return (
			HREADYOUT => vec(33),
			HRESP     => vec(32),
			HRDATA    => vec(31 downto 0));
	end function;
end package body;



----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------
package APB is
	---------------- APB - Master interface ----------------
	-- APB master interface
	type APB_master is record
		PWRITE  : std_logic;
		PENABLE : std_logic;
		PADDR   : std_logic_vector(31 downto 0);
		PWDATA  : std_logic_vector(31 downto 0);
	end record;

	-- APB master to slave logic vector
	subtype APB_master_vector is std_logic_vector(65 downto 0);

	-- APB master to slave conversion functions
	function to_vector(rec : APB_master) return std_logic_vector;
	function to_record(rec : APB_master) return APB_master;
	function to_record(vec : std_logic_vector) return APB_master;


	---------------- APB - Slave interface ----------------
	-- APB slave to master interface
	type APB_slave is record
		PREADY  : std_logic;
		PSLVERR : std_logic;
		PRDATA  : std_logic_vector(31 downto 0);
	end record;

	-- APB slave to master logic vector
	subtype APB_slave_vector is std_logic_vector(33 downto 0);

	--APB slave to master conversion functions
	function to_vector(rec : APB_slave) return std_logic_vector;
	function to_record(rec : APB_slave) return APB_slave;
	function to_record(vec : std_logic_vector) return APB_slave;
end package;


----------------------------------------------------------------
package body APB is
	---------------- APB - Master interface ----------------
	-- APB master interface to logic vector
	function to_vector(rec : APB_master) return std_logic_vector is
	begin
		return rec.PWRITE & rec.PENABLE & rec.PADDR & rec.PWDATA;
	end function;

	-- APB master interface dummy function
	function to_record(rec : APB_master) return APB_master is
	begin
		return rec;
	end function;

	-- APB master interface from logic vector
	function to_record(vec : std_logic_vector) return APB_master is
	begin
		return (
			PWRITE  => vec(65),
			PENABLE => vec(64),
			PADDR   => vec(63 downto 32),
			PWDATA  => vec(31 downto 0));
	end function;


	---------------- APB - Slave interface ----------------
	-- APB slave interface to logic vector
	function to_vector(rec : APB_slave) return std_logic_vector is
	begin
		return rec.PREADY & rec.PSLVERR & rec.PRDATA;
	end function;

	-- APB slave interface dummy function
	function to_record(rec : APB_slave) return APB_slave is
	begin
		return rec;
	end function;

	-- APB slave interface from logic vector
	function to_record(vec : std_logic_vector) return APB_slave is
	begin
		return (
			PREADY  => vec(33),
			PSLVERR => vec(32),
			PRDATA  => vec(31 downto 0));
	end function;
end package body;
