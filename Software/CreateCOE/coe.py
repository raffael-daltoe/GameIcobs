import sys
from PIL import Image
import numpy as np

def image_to_coe(image_path, coe_path, downscale_factor, num_bits):
    # Load and downscale the image
    img = Image.open(image_path)
    if downscale_factor < 1:
        width = int(img.width * downscale_factor)
        height = int(img.height * downscale_factor)
        img = img.resize((width, height), Image.LANCZOS)
    
    img = np.array(img)
    height, width = img.shape[:2]

    # Open output file
    with open(coe_path, 'w') as s:
        # Write header
        s.write('; VGA Memory Map\n')
        s.write('; .COE file with hex coefficients\n')
        s.write(f'; Height: {height}, Width: {width}, Bits: {num_bits}\n\n')
        s.write('memory_initialization_radix=16;\n')
        s.write('memory_initialization_vector=\n')

        cnt = 0

        for r in range(height):
            for c in range(width):
                cnt += 1
                R, G, B = img[r, c, :3]
                Rb = format(R, '08b')
                Gb = format(G, '08b')
                Bb = format(B, '08b')

                if num_bits == 12:
                    # 12-bit color depth
                    Outbyte = Rb[:4] + Gb[:4] + Bb[:4]
                    s.write(f'{int(Outbyte, 2):03X}')  # 3 hex digits for 12 bits
                else:
                    # 8-bit color depth
                    Outbyte = Rb[:3] + Gb[:3] + Bb[:2]
                    hex_value = f'{int(Outbyte, 2):X}'
                    if len(hex_value) < 2:
                        hex_value = '0' + hex_value
                    s.write(hex_value)

                # Formatting with commas and new lines
                if c == width - 1 and r == height - 1:
                    s.write(';')
                else:
                    if cnt % 32 == 0:
                        s.write(',\n')
                    else:
                        s.write(',')

    print(f"COE file generated successfully: {coe_path}")
    return height, width

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <image_path> <coe_output_path> <downscale_factor> <number_of_bits>")
    else:
        image_path = sys.argv[1]
        coe_path = sys.argv[2]
        downscale_factor = float(sys.argv[3])
        num_bits = int(sys.argv[4])
        if num_bits not in [8, 12]:
            print("Number of bits must be 8 or 12")
        else:
            height, width = image_to_coe(image_path, coe_path, downscale_factor, num_bits)
            print(f"Image dimensions: {width}x{height} and size Port A = {width*height}")
