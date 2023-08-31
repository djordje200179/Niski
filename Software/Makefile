I_DIR = h
SRC_DIR = src
OBJ_DIR = obj

CC = riscv64-linux-gnu-gcc
C_FLAGS = -march=rv32em -mabi=ilp32e -Werror -I$(I_DIR) -O3

ASM = riscv64-linux-gnu-as
ASM_FLAGS = --warn --fatal-warnings -march=rv32em -mabi=ilp32e

LD = riscv64-linux-gnu-ld
LD_SCRIPT = linker.ld
LD_FLAGS = -T $(LD_SCRIPT) -melf32lriscv -s

OBJDUMP = riscv64-linux-gnu-objdump
OBJDUMP_FLAGS =

OBJCOPY = riscv64-linux-gnu-objcopy
OBJCOPY_FLAGS =-O verilog --verilog-data-width=4 --reverse-bytes=4

OUT_DIR = out
EXE_OUT = $(OUT_DIR)/out.elf
ROM_OUT = $(OUT_DIR)/rom.mem
RAM_OUT = $(OUT_DIR)/ram.mem

SRC_C = $(wildcard $(SRC_DIR)/*.c)
OBJ_C = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC_C))
DEP = $(patsubst $(SRC_DIR)/%.c, $(SRC_DIR)/%.d, $(SRC_C))

SRC_S = $(wildcard $(SRC_DIR)/*.S)
OBJ_S = $(patsubst $(SRC_DIR)/%.S, $(OBJ_DIR)/%.o, $(SRC_S))

all: $(EXE_OUT) $(ROM_OUT) $(RAM_OUT)

$(ROM_OUT): $(EXE_OUT) 
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .rom.* --change-addresses -0x40000000 $< $@

$(RAM_OUT): $(EXE_OUT)
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .data.* --change-addresses -0x50000000 $< $@

$(EXE_OUT): $(OBJ_C) $(OBJ_S)
	$(LD) $(LD_FLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(C_FLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S
	$(ASM) $(ASM_FLAGS) -c -o $@ $<

%.d: %.c
	$(CC) -MM -MT $(OBJ_DIR)/$*.o $< $(C_FLAGS) > $@

include $(DEP)

dissasemble:
	$(OBJDUMP) -d $(EXE_OUT)

clean:
	rm -f $(OBJ_DIR)/*.o
	rm -f *.d
	rm -f $(OUT_DIR)/*
	rm -f *~

.PHONY: clean dissasemble all