I_DIR = h
SRC_DIR = src
OBJ_DIR = obj
OUT_DIR = out

EXE_OUT = $(OUT_DIR)/out.elf
ROM_OUT = $(OUT_DIR)/rom.mem
RAM_OUT = $(OUT_DIR)/ram.mem
MAP_OUT = $(OUT_DIR)/out.map
ASM_OUT = $(OUT_DIR)/out.dump

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

TOOL_PREFIX = riscv64-unknown-elf-

GCC = $(TOOL_PREFIX)gcc

GCC_FLAGS = -march=rv32im -mabi=ilp32 -mno-div
GCC_FLAGS += --no-pic
GCC_FLAGS += -std=c2x -ffreestanding -nostdlib

CC_FLAGS = $(GCC_FLAGS)
CC_FLAGS += -I$(I_DIR)
CC_FLAGS += -O3
CC_FLAGS += -Wall -Wextra
CC_FLAGS += -Werror-implicit-function-declaration
CC_FLAGS += -mstrict-align
CC_FLAGS += -mriscv-attribute
CC_FLAGS += -fno-zero-initialized-in-bss
CC_FLAGS += -fstack-usage

LD_SCRIPT = linker.ld
LD_LIBS = -lgcc

LD_FLAGS = $(GCC_FLAGS)
LD_FLAGS += -T $(LD_SCRIPT)
LD_FLAGS += --enable-multilib -flinker-output=exec -no-pie
LD_FLAGS += -Xlinker --print-memory-usage
LD_FLAGS += -Xlinker --build-id=none
LD_FLAGS += -Xlinker --gc-sections
LD_FLAGS += -fstack-limit-symbol=MAIN_THREAD_STACK_START
LD_FLAGS += -Xlinker -Map=$(MAP_OUT)

OBJDUMP = $(TOOL_PREFIX)objdump
OBJDUMP_FLAGS =

OBJCOPY = $(TOOL_PREFIX)objcopy
OBJCOPY_FLAGS = -O verilog --verilog-data-width=4 --reverse-bytes=4

EMULATOR = qemu-system-riscv64

MEMFILE_CORRECTOR = ./memfile_corrector.py

SRC_C = $(call rwildcard,$(SRC_DIR),*.c)
OBJ_C = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC_C))
DEP = $(patsubst $(SRC_DIR)/%.c, $(SRC_DIR)/%.d, $(SRC_C))

SRC_S = $(call rwildcard,$(SRC_DIR),*.S)
OBJ_S = $(patsubst $(SRC_DIR)/%.S, $(OBJ_DIR)/%.o, $(SRC_S))

all: $(EXE_OUT) $(ROM_OUT) $(RAM_OUT)

clean:
	find . -name "*.d" -type f -delete
	rm -rf $(OBJ_DIR)
	rm -rf $(OUT_DIR)
	rm -rf *~

$(ROM_OUT): $(EXE_OUT) 
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .rom.* --change-addresses -0x40000000 $< $@
	$(MEMFILE_CORRECTOR) $@

$(RAM_OUT): $(EXE_OUT)
	$(OBJCOPY) $(OBJCOPY_FLAGS) -j .ram.* --change-addresses -0x50000000 $< $@
	$(MEMFILE_CORRECTOR) $@

$(EXE_OUT): $(OBJ_C) $(OBJ_S)
	@mkdir -p $(dir $@)
	$(GCC) $(LD_FLAGS) -o $@ $^ $(LD_LIBS)
	@$(OBJDUMP) -D $@ > $(ASM_OUT)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(GCC) $(CC_FLAGS) -c -o $@ $<
	@rm -f $(SRC_DIR)/$*.d

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S
	@mkdir -p $(dir $@)
	$(GCC) $(CC_FLAGS) -c -o $@ $<
	@rm -f $(SRC_DIR)/$*.d

%.d: %.c
	@$(GCC) -MM -MT $(OBJ_DIR)/$*.o $< $(CC_FLAGS) > $@

include $(DEP)

.PHONY: clean all