#!/usr/bin/env python3
# author: Guillaume Patrigeon
# update: 23-03-2017



class CRC8():
	CRC = 0

	def __init__(self, polynomial=7):
		self.CRC = 0
		self.table = []
		self.setPolynomial(polynomial)


	def setPolynomial(self, polynomial):
		self.polynomial = polynomial
		del self.table[:]

		for i in range(256):
			k = i

			for j in range(8):
				k <<= 1
				if k & 0x100:
					k ^= self.polynomial

			self.table.append(k & 0xFF)


	def pushByte(self, b):
		self.CRC = self.table[(self.CRC ^ b) & 0xFF]



if __name__ == "__main__":
	crc = CRC8()

	crc.pushByte(0xAB)
	crc.pushByte(0xCD)

	print("%02X" % crc.CRC)
