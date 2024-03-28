# Project structure

- **lib**:
    - **arch**: System architecture definitions
    - **ibex**: Ibex core definitions
    - **libarch**: Peripherals drivers
    - **misc**: Miscellaneous
- **src**: Demo application source files
- **crt0.S**: Startup file
- **link.ld**: Linker script
- **hex2txt.py**: Python script to convert the hex file to other formats such as .txt, .coe or even .vhd
- **install_riscv_toolchain.sh**: RISC-V toolchain installation script
- **makefile**: makefile

# Add source

- **First step**: create .h or .c file
- **Second step**: update INC and SRC variable in the makefile

# Makefile commands

To compile all the sources in the build directory, generate output files in the output directory and generate .coe and .txt files in the main directory, use the following command:

```bash
$ make all
```

To generate a dump file in the output directory:

```bash
$ make dump
```

Finally to clean the make and remove the build directory:

```bash
$ make clean
```

# RISC-V Toolchain installation

## Installation with dedicated script

Once the project cloned, to install the toolchain, you can go in the project repository and run the installation script (install_riscv_toolchain.sh) with the following command:
```bash
$ source install_riscv_toolchain.sh
```
This script will download, configure and build the toolchain in the project folder (./compiler). It is possible to copy/paste the script somewhere else to install the toolchain outside the project repository.
Where the script is located (LOC_SCRIPT), the toochain build will be in the compiler folder, to finish the installation, add ${LOC_SCRIPT}/compiler/bin to your PATH:
```bash
$ export PATH=${LOC_SCRIPT}/compiler/bin:$PATH
```

## Manual installation

To manually install the toolchain, the first step is to download the package lists from the repositories and update them to get information on the newest versions of packages and their dependencies
```bash
$ sudo apt-get update
```

Then you can install all the dependencies:
```bash
$ sudo apt-get install make git gcc autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev nodejs
```

Use the following command to clone the RISC-V toolchain repository:
```bash
$ git clone https://github.com/riscv/riscv-gnu-toolchain
```

Then, go in the riscv-gnu-toolchain repository:
```bash
$ cd riscv-gnu-toolchain
```

To ensure that you are using the same version of the toolchain that this project was tested with, run the following command:
```bash
$ git checkout 663b3852189acae826d99237cef45e629dfd6471
```

You can create a variable that containt the installation path of the compiler:
```bash
$ INSTALL_ROOT = /your/installation/path
```

Finally, you can configure and build the Newlib cross-compiler:
```bash
$ ./configure --prefix=${INSTALL_ROOT} --disable-linux --disable-gdb --disable-multilib --with-arch=rv32imc --with-abi=ilp32 --with-cmodel=medlow
$ make -j8
```

To use the toolchain, add /your/installation/path/bin to your PATH:
```bash
$ export PATH=/your/installation/path/bin:$PATH
```
