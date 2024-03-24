##################################################################
##################################################################
######    __    ______   ______   .______        _______.   ######
######   |  |  /      | /  __  \  |   _  \      /       |   ######
######   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ######
######   |  | |  |     |  |  |  | |   _  <      \   \       ######
######   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ######
######   |__|  \______| \______/  |______/  |_______/       ######
######                                                      ######
##################################################################
##################################################################
##### MAKEFILE												 #####
##### Author: Soriano Theo									 #####
##### Update: 07-06-2022									 #####
##################################################################

AS  = riscv32-unknown-elf-as
CC  = riscv32-unknown-elf-gcc
CXX = riscv32-unknown-elf-g++
LD  = riscv32-unknown-elf-g++
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump


# ================================================================
OUTDIR = output
OBJDIR = build

PROJECT = testcode_icobs_light

SRC = crt0.S lib/misc/print.c src/main.c lib/libarch/uart.c lib/libarch/timer.c

INC = lib/ibex lib/misc lib/arch lib/libarch src

LIBDIR =
LDSCRIPT = link.ld

GFLAGS   = -march=rv32imc -mabi=ilp32
CFLAGS   = -Wall -Wextra -static -mcmodel=medany -ffunction-sections -fdata-sections -Os -fstrict-volatile-bitfields
CXXFLAGS = -Wall -Wextra -static -mcmodel=medany -ffunction-sections -fdata-sections -Os -fstrict-volatile-bitfields
LDFLAGS  = -Wl,--gc-sections -Wl,-Map=$(OUTDIR)/$(PROJECT).map -nostdlib -nostartfiles

OBJ = $(SRC:%=$(OBJDIR)/%.o)
DEP = $(patsubst %,$(OBJDIR)/%.d,$(filter %.c %.cpp,$(SRC)))


# ================================================================
ifeq ($(OS), Windows_NT)
	exit
else
	RM = rm -f
	RRM = rm -f -r
endif


# ================================================================
all: $(OUTDIR)/$(PROJECT).elf


$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OBJDIR)/.:
	mkdir -p $(@D)

$(OBJDIR)%/.:
	mkdir -p $(@D)


.SECONDEXPANSION:
$(OBJDIR)/%.asm.o: %.asm | $$(@D)/.
	$(AS) $< -o $@ -c $(GFLAGS)

$(OBJDIR)/%.S.o: %.S | $$(@D)/.
	$(AS) $< -o $@ -c $(GFLAGS)

$(OBJDIR)/%.c.o: %.c
$(OBJDIR)/%.c.o: %.c $(OBJDIR)/%.c.d | $$(@D)/.
	$(CC) $< -o $@ -c -MMD -MP $(GFLAGS) $(CFLAGS) $(addprefix -I, $(INC))

$(OBJDIR)/%.cpp.o: %.cpp
$(OBJDIR)/%.cpp.o: %.cpp $(OBJDIR)/%.cpp.d | $$(@D)/.
	$(CXX) $< -o $@ -c -MMD -MP $(GFLAGS) $(CXXFLAGS) $(addprefix -I, $(INC))

$(OUTDIR)/$(PROJECT).elf: $(OBJ) | $(OUTDIR)
	$(LD) $^ -o $@ $(GFLAGS) $(LDFLAGS) $(addprefix -L, $(LIBDIR)) -T $(LDSCRIPT)
	$(OBJCOPY) $@ -O binary $(OUTDIR)/$(PROJECT).bin
	$(OBJCOPY) $@ -O ihex $(OUTDIR)/$(PROJECT).hex
	python3 hex2txt.py --input=$(OUTDIR)/$(PROJECT).hex --coe=$(OUTDIR)/$(PROJECT).coe


.PHONY: clean
clean:
	$(RRM) $(subst /,\\,$(OBJDIR))


.PHONY: dump
dump:
	$(OBJDUMP) -S --disassemble $(OUTDIR)/$(PROJECT).elf > $(OUTDIR)/$(PROJECT).dump


.PHONY: prep
prep:
	$(CC) -E src/main.c $(GFLAGS) $(CFLAGS) $(addprefix -I, $(INC))


.PRECIOUS: $(OBJDIR)/%.d;
$(OBJDIR)/%.d: ;

-include $(DEP)
