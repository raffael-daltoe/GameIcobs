#!/usr/bin/env python3
# author: Guillaume Patrigeon
# update: 13-06-2019

import enum



class RecordType(enum.Enum):
	DATAREC = 0
	END = 1
	SEGADDR = 2
	SEGSTRT = 3
	LINADDR = 4
	LINSTRT = 5



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

		ret = RecordType(self.type).name + " @ %04X" % (self.offset)

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
			if line.type == RecordType.DATAREC.value and line.offset == end:
				data += line.data
				end += len(line.data)

			else:
				offset = 0

				while start + offset < end:
					r = RecordLine()
					r.type = RecordType.DATAREC.value
					r.offset = start + offset
					r.data = data[offset:offset + linesize]

					offset += linesize
					newrecords.append(r)

				if line.type == RecordType.DATAREC.value:
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
			r.type = RecordType.DATAREC.value
			r.offset = start + offset
			r.data = data[offset:offset + linesize]

			offset += linesize
			newrecords.append(r)

		self.records = newrecords


	def addLinearOffset(self, offset):
		for line in self.records:
			if line.type == RecordType.LINADDR.value or line.type == RecordType.LINSTRT.value:
				addr = line.data[1] + (line.data[0] << 8)
				addr += offset
				line.data[1] = addr & 0xFF
				line.data[0] = addr >> 8
