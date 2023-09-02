I_DIR = h
SRC_DIR = src
OBJ_DIR = obj
LD_SCRIPT = linker.ld

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

GCC = riscv64-linux-gnu-gcc

GCC_FLAGS = -march=rv32e -mabi=ilp32e
GCC_FLAGS += -Wall -Wextra
GCC_FLAGS += -O3

CC_FLAGS = $(GCC_FLAGS)
CC_FLAGS += -I$(I_DIR)
GCC_FLAGS += -std=c2x --no-pic

LD_FLAGS = $(GCC_FLAGS)
LD_FLAGS += -T $(LD_SCRIPT)
LD_FLAGS += -flinker-output=exec -no-pie
LD_FLAGS += -nostartfiles -nodefaultlibs -nolibc -nostdlib 
LD_FLAGS += -Xlinker --print-memory-usage
LD_FLAGS += -Xlinker --build-id=none
LD_FLAGS += -Xlinker --gc-sections

OBJDUMP = riscv64-linux-gnu-objdump
OBJDUMP_FLAGS =

OBJCOPY = riscv64-linux-gnu-objcopy
OBJCOPY_FLAGS = -O verilog --verilog-data-width=4 --reverse-bytes=4

MEMFILE_CORRECTOR = ./memfile_corrector.py

OUT_DIR = out
EXE_OUT = $(OUT_DIR)/out.elf
ROM_OUT = $(OUT_DIR)/rom.mem
RAM_OUT = $(OUT_DIR)/ram.mem

SRC_C = $(call rwildcard,$(SRC_DIR),*.c)
OBJ_C = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC_C))
DEP = $(patsubst $(SRC_DIR)/%.c, $(SRC_DIR)/%.d, $(SRC_C))

SRC_S = $(call rwildcard,$(SRC_DIR),*.S)
OBJ_S = $(patsubst $(SRC_DIR)/%.S, $(OBJ_DIR)/%.o, $(SRC_S))

all: $(EXE_OUT) $(ROM_OUT) $(RAM_OUT)

$(ROM_OUT): $(EXE_OUT) 
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .rom.* --change-addresses -0x40000000 $< $@
	$(MEMFILE_CORRECTOR) $@

$(RAM_OUT): $(EXE_OUT)
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .data.* --change-addresses -0x50000000 $< $@
	$(MEMFILE_CORRECTOR) $@

$(EXE_OUT): $(OBJ_C) $(OBJ_S)
	mkdir -p $(dir $@)
	$(GCC) $(LD_FLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(GCC) $(CC_FLAGS) -c -o $@ $<
	rm -f $(SRC_DIR)/$*.d

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S
	mkdir -p $(dir $@)
	$(GCC) $(CC_FLAGS) -c -o $@ $<
	rm -f $(SRC_DIR)/$*.d

%.d: %.c
	$(GCC) -MM -MT $(OBJ_DIR)/$*.o $< $(CC_FLAGS) > $@

include $(DEP)

dissasemble:
	$(OBJDUMP) -d $(EXE_OUT)

clean:
	rm -f *.d
	rm -rf $(OBJ_DIR)
	rm -rf $(OUT_DIR)
	rm -f *~

.PHONY: clean dissasemble all