import serial
import pathlib
import os
import time
from lib_loader.hexdecoder import *
from lib_loader.crc8 import *
from sys import exit, argv

# Print iterations progress
def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', printEnd = "\r"):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    # Print New Line on Complete
    if iteration == total:
        print()

HEX_FILE = argv[1]
COM_PORT = argv[2]

# Retrieve filename
filename = HEX_FILE

CRCINIT = 12
MSGMAXLEN = 80

# Check filename
if filename == "" or not os.path.exists(filename):
    print("No file")

# Try to open file
try:
    file = open(filename, "r")
except:
    print("Could not open file")

# Retrieve records
try:
    hexrecs = RecordBloc(file)
    hexrecs.reformat(64)
except:
    # Close file
    print("Invalid file")
    file.close()

# Close file
file.close()

total = len(hexrecs.records)

ser = serial.Serial(COM_PORT, 115200)
ser.flushInput()

step = 0
RecvCRC = CRC8()
SendCRC = CRC8()
buffer = []

# printProgressBar(0, total, prefix = 'Progress:', suffix = 'Complete', length = 70)

print("Start loading code")

while 1:
    if step == 0:
        # Flush input
        ser.flushInput()

        count = 0
        itRecord = iter(hexrecs.records)
        step = 1

    # Prepare message
    elif step == 1:
        record = next(itRecord)
        count += 1

        # Build message
        data = bytes([0, record.type])
        data += record.offset.to_bytes(2, "little")

        if record.type == RecordType.DATAREC.value or record.type == RecordType.END.value:
            data += bytes(record.data)
        elif record.type == RecordType.LINADDR.value or record.type == RecordType.SEGADDR.value:
            data += bytes([record.data[1], record.data[0]])

        retry = 5
        step = 2

    # Send message
    elif step == 2:
        SendCRC.CRC = CRCINIT

        s = len(data)
        SendCRC.pushByte(s)

        for d in data:
            SendCRC.pushByte(d)

        m = [0x01, s]
        m += data
        m.append(SendCRC.CRC)

        ser.write(bytes(m))

        timeout = time.time() + .25
        step = 3

    # Wait for reply
    elif step == 3:
        if time.time() > timeout:
            if retry:
                step = 2
                retry -= 1

            else:
                print("Timeout error, please reset the target")
                step = 0

        if ser.inWaiting():
            rcvdata = ser.read(5)
            txt = ""
            under_step = 0
            for c in bytes(rcvdata):
                RecvCRC.pushByte(c)

                if under_step == 0:
                    if c != 0x01:
                        txt += chr(c)
                        continue

                    RecvCRC.CRC = CRCINIT
                    del buffer[:]
                    timeout = time.time() + 0.1
                    under_step = 1

                elif under_step == 1:
                    length = c

                    if length > MSGMAXLEN:
                        under_step = 0
                    else:
                        under_step = 2

                elif under_step == 2:
                    buffer.append(c)

                    if len(buffer) >= length:
                        under_step = 3

                elif under_step == 3:
                    if not RecvCRC.CRC:
                        break
                    under_step = 0

            if len(buffer) == 2:
                if buffer[1] == 0x06:
                    printProgressBar(count, total, prefix = ' Progress:', suffix = 'Complete ', length = 70)
                    if count == total:
                        print("#### Success ####")
                        step = 0
                        break
                    else:
                        step = 1

            else:
                print("\033[91mTransfert error. Please reset the board.\033[0m", end="\r")
                step = 0

while True:
    try:
        rcv = False
        if ser.inWaiting()>0:
            print(ser.read().decode("utf-8"), end="")
    except Exception as e:
        print(e)
        break
    except KeyboardInterrupt:
        print("keyboard interrupt")
        exit()

