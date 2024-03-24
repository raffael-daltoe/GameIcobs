#!/usr/bin/env python3

import argparse

# hexdecoder.py
# update: 13-06-2019
RecordType_Str = ["DATA", "END", "SEGADDR", "SEGSTRT", "LINADDR", "LINSTRT"]

RecordType_DATAREC = 0
RecordType_END = 1
RecordType_SEGADDR = 2
RecordType_SEGSTRT = 3
RecordType_LINADDR = 4
RecordType_LINSTRT = 5


class RecordLine:
	def __init__(self, line=None):
		if line:
			self.decode(line)
		else:
			self.offset = None
			self.type = None
			self.data = None


	def __str__(self):
		if self.type == None:
			return None

		ret = RecordType_Str[self.type] + " @ %04X" % (self.offset)

		for d in self.data:
			ret += " %02X" % (d)

		return ret


	def decode(self, line):
		line = line.strip()

		if line[0] != ':':
			raise Exception("ERROR: First character invalid")

		line = line[1:]

		if len(line) & 1 or len(line) < 10:
			raise Exception("ERROR: Line length is invalid")

		try:
			sum = 0
			for i in range(0, (len(line) - 2), 2):
				sum += int(line[i:i + 2], 16)
		except:
			raise Exception("ERROR: Line contains invalid characters")

		sum = (-sum) & 0xFF
		if sum != int(line[-2:], 16):
			raise Exception("ERROR: Wrong checksum (" + str(sum) + " <> " + str(int(line[-2:], 16)) + ")")

		self.offset = int(line[2:6], 16)
		self.type = int(line[6:8], 16)

		size = int(line[0:2], 16)
		self.data = []
		for i in range(size):
			self.data.append(int(line[8 + 2 * i:10 + 2 * i], 16))
			sum += self.data[-1]

		if len(self.data) != size:
			raise Exception("ERROR: Line length is invalid")


	def encode(self):
		if self.type == None:
			return None

		size = len(self.data)
		ret = ":%02X%04X%02X" % (size, self.offset, self.type)
		sum = size + (self.offset & 0xFF) + (self.offset >> 8) + self.type

		for d in self.data:
			ret += "%02X" % (d)
			sum += d

		ret += "%02X" % ((-sum) & 0xFF)
		return ret



class RecordBloc:
	def __init__(self, stream=None):
		self.records = []

		if stream:
			self.decode(stream)


	def decode(self, stream):
		if stream.closed:
			return

		n = 0
		for line in stream.readlines():
			n += 1

			if line == "":
				continue

			try:
				self.records.append(RecordLine(line))
			except:
				print("Error at line " + str(n))
				raise


	def encode(self, stream):
		if stream.closed:
			return

		for line in self.records:
			stream.write(line.encode())
			stream.write("\n")


	def reformat(self, linesize):
		newrecords = []
		data = []
		start = 0
		end = 0

		for line in self.records:
			if line.type == RecordType_DATAREC and line.offset == end:
				data += line.data
				end += len(line.data)

			else:
				offset = 0

				while start + offset < end:
					r = RecordLine()
					r.type = RecordType_DATAREC
					r.offset = start + offset
					r.data = data[offset:offset + linesize]

					offset += linesize
					newrecords.append(r)

				if line.type == RecordType_DATAREC:
					data = line.data
					start = line.offset
					end = start + len(line.data)

				else:
					newrecords.append(line)
					data = []
					start = 0
					end = 0

		offset = 0

		while start + offset < end:
			r = RecordLine()
			r.type = RecordType_DATAREC
			r.offset = start + offset
			r.data = data[offset:offset + linesize]

			offset += linesize
			newrecords.append(r)

		self.records = newrecords


	def addLinearOffset(self, offset):
		for line in self.records:
			if line.type == RecordType_LINADDR or line.type == RecordType_LINSTRT:
				addr = line.data[1] + (line.data[0] << 8)
				addr += offset
				line.data[1] = addr & 0xFF
				line.data[0] = addr >> 8



# hexconverter.py
# update: 16-05-2019
import sys, traceback



def convert(HEX_FILE, BIN_FILE=None, BTXT_FILE=None, HTXT_FILE=None, COE_FILE=None, VHDL_FILE=None, show=False):
	try:
		hexfile = open(HEX_FILE, "r")
	except:
		print("ERROR: Cannot open", HEX_FILE)
		return 1

	if BIN_FILE:
		try:
			binfile = open(BIN_FILE, "wb")
		except:
			print("ERROR: Cannot open", BIN_FILE)
			BIN_FILE = None

	if BTXT_FILE:
		try:
			btxtfile = open(BTXT_FILE, "w")
		except:
			print("ERROR: Cannot open", BTXT_FILE)
			BTXT_FILE = None

	if HTXT_FILE:
		try:
			htxtfile = open(HTXT_FILE, "w")
		except:
			print("ERROR: Cannot open", HTXT_FILE)
			HTXT_FILE = None

	if COE_FILE:
		try:
			coefile = open(COE_FILE, "w")
		except:
			print("ERROR: Cannot open", COE_FILE)
			COE_FILE = None

	if VHDL_FILE:
		try:
			vhdlfile = open(VHDL_FILE, "w")
		except:
			print("ERROR: Cannot open", VHDL_FILE)
			VHDL_FILE = None

	try:
		data = RecordBloc(hexfile)
		data.reformat(4)

		if COE_FILE:
			coefile.write("memory_initialization_radix = 16;\n")
			coefile.write("memory_initialization_vector = \n")
		if VHDL_FILE:
			vhdlfile.write("""library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

library interface;
use interface.obi_lib.all;

entity ROM is
generic (
    add_bits        : integer := 11;
    data_bits       : integer := 32);
port (
    SYSCLK          : in std_logic;
    -- OBI Slave interface : receive data from OBI Master
    if_slvi_vec     : in  MTS_vector;
    if_slvo_vec     : out STM_vector);
end ROM;

architecture Arch of ROM is

    signal clk_s         : std_logic;
    signal addr_s        : std_logic_vector(add_bits-1 downto 0);
    signal req_addr_s    : std_logic_vector(add_bits-1 downto 0);
    signal data_out_s    : std_logic_vector(31 downto 0);

    signal if_slvi   : MasterToSlave;
    signal if_slvo   : SlaveToMaster;

    type rom_type is array (0 to 2**add_bits) of std_logic_vector(data_bits-1 downto 0);

    constant rom : rom_type := (
""")

		for r in data.records:
			if show:
				print(r)

			if r.type == RecordType_DATAREC:

				if BIN_FILE:
					binfile.write(bytes(r.data))

				if BTXT_FILE or HTXT_FILE or COE_FILE or VHDL_FILE:
					d = 0
					i = len(r.data)
					while i:
						i -= 1
						d <<= 8
						d += r.data[i]

					if BTXT_FILE:
						btxtfile.write("{:0>32b}\n".format(d))

					if HTXT_FILE:
						htxtfile.write("{:0>8X}\n".format(d))

					if COE_FILE:
						coefile.write("{:0>8X}\n".format(d))

					if VHDL_FILE:
						vhdlfile.write("        x\"{:0>8X}\",\n".format(d))
		if VHDL_FILE:
			vhdlfile.write("""        others => (others => '0')
    );

begin

    -- OBI INPUT
    if_slvi         <= to_record(if_slvi_vec);

    addr_s          <= if_slvi.addr(add_bits+1 downto 2);

    -- MEM OUTPUT
    if_slvo_vec   <= to_vector(if_slvo);

    valid : process(SYSCLK)
    begin
        if (SYSCLK'event and SYSCLK = '1') then
            if_slvo.rvalid <= if_slvi.req;
        end if;
    end process;

	addr_req : process(SYSCLK)
    begin
        if (SYSCLK'event and SYSCLK = '1') then
            req_addr_s <= addr_s;
        end if;
    end process;

    if_slvo.rdata   <=   data_out_s;
    if_slvo.gnt     <=   '1';
    if_slvo.err     <=   '0';
    if_slvo.ruser   <=   '0';
    if_slvo.rid     <=   '0';

    data_out_s<=rom(conv_integer(req_addr_s));

end Arch;
""")
	except:
		traceback.print_exc()

	hexfile.close()

	if BIN_FILE:
		binfile.close()

	if BTXT_FILE:
		btxtfile.close()

	if HTXT_FILE:
		htxtfile.close()

	if COE_FILE:
		coefile.close()

	if VHDL_FILE:
		vhdlfile.close()

	return 0



# hex2txt.py
import os

def main():

	parser = argparse.ArgumentParser()
	parser.add_argument("-i", "--input", help="input .hex file")
	parser.add_argument("--bin", help="output .bin file", default=None)
	parser.add_argument("--htxt", help="output HTXT .txt file", default=None)
	parser.add_argument("--btxt", help="output BTXT .txt file", default=None)
	parser.add_argument("--coe", help="output .coe file", default=None)
	parser.add_argument("--vhdl", help="output .vhdl file", default=None)
	args = parser.parse_args()

	if args.input == None :
		print("missing \"--input\" or \"-i\" argument")
		return
	if not args.input.endswith(".hex") :
		print("illegal \"--input\" or \"-i\" argument. must be \".hex\" file")
		return

	convert(args.input,
			BIN_FILE=args.bin,
			HTXT_FILE=args.htxt,
			BTXT_FILE=args.btxt,
			COE_FILE=args.coe,
			VHDL_FILE=args.vhdl
	)


if __name__ == "__main__":
	main()
