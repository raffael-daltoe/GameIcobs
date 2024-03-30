##########################################################
##########################################################
##    __    ______   ______   .______        _______.   ##
##   |  |  /      | /  __  \  |   _  \      /       |   ##
##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
##   |  | |  |     |  |  |  | |   _  <      \   \       ##
##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
##   |__|  \______| \______/  |______/  |_______/       ##
##                                                      ##
##########################################################
##########################################################
# MAKEFILE												 #
# Author: Soriano Theo									 #
# Update: 23-09-2020									 #
##########################################################

AS  = riscv32-unknown-elf-as
CC  = riscv32-unknown-elf-gcc
CXX = riscv32-unknown-elf-g++
LD  = riscv32-unknown-elf-g++
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

# ================================================================
OUTDIR = output
OBJDIR = build

PROJECT = demo-icobs-light

INC = 	lib/ibex \
 		lib/misc \
		lib/arch \
		lib/libarch \
		src \

APP_SRCS := 	crt0.S \
		lib/misc/print.c \
		lib/libarch/uart.c \
		lib/libarch/timer.c \
		src/main.c \



SRC := \
	$(APP_SRCS) \

LIBDIR =
LDSCRIPT = link.ld

C_CXX_FLAGS = \
		-flto  \
		-Wall -Wextra \
		-static -mcmodel=medany -O3 \
		-ffunction-sections -fdata-sections -fstrict-volatile-bitfields -fdce

GFLAGS   = -march=rv32imc -mabi=ilp32
CFLAGS   = $(addprefix -D, $(MACROS)) $(C_CXX_FLAGS)
CXXFLAGS = $(addprefix -D, $(MACROS)) $(C_CXX_FLAGS) -fno-use-cxa-atexit
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

$(OBJDIR)/%.cc.o: %.cc
$(OBJDIR)/%.cc.o: %.cc $(OBJDIR)/%.cc.d | $$(@D)/.
	$(CXX) $< -o $@ -c -MMD -MP $(GFLAGS) $(CXXFLAGS) $(addprefix -I, $(INC))

$(OUTDIR)/$(PROJECT).elf: $(OBJ) | $(OUTDIR)
	$(LD) $^ -o $@ $(GFLAGS) $(LDFLAGS) $(addprefix -L, $(LIBDIR)) -T $(LDSCRIPT)
	$(OBJCOPY) $@ -O binary $(OUTDIR)/$(PROJECT).bin
	$(OBJCOPY) $@ -O ihex $(OUTDIR)/$(PROJECT).hex


.PHONY: clean
clean:
	$(RRM) $(subst /,\\,$(OBJDIR))


.PHONY: dump
dump:
	$(OBJDUMP) -S --disassemble $(OUTDIR)/$(PROJECT).elf > $(OUTDIR)/$(PROJECT).dump


.PHONY: prep
prep:
	$(CC) -E src/main.c $(GFLAGS) $(CFLAGS) $(addprefix -I, $(INC))


.PHONY: coe
coe:
	python3 hex2txt.py --input=$(OUTDIR)/$(PROJECT).hex --coe=$(OUTDIR)/$(PROJECT).coe


.PRECIOUS: $(OBJDIR)/%.d;
$(OBJDIR)/%.d: ;

-include $(DEP)
