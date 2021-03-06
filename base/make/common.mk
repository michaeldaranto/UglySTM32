# Check to make sure that the required variables are set
# Modification by YD3BRB 28-04-2022

ifndef DEVICE
    $(error Please set the required DEVICE variable in your makefile.)
endif

ifndef FLASH
    $(error Please set the required FLASH variable in your makefile.)
endif

# Standard values for (linked) base & cmsis folders
STM32_BASE_PATH   ?= ../../../base
STM32_CMSIS_PATH  ?= ../../../cmsis

# base sub-folders
BASE_LINKER   = $(STM32_BASE_PATH)/linker
BASE_MAKE     = $(STM32_BASE_PATH)/make
BASE_STARTUP  = $(STM32_BASE_PATH)/startup

# Standard values for project folders
BIN_FOLDER ?= ../bin
OBJ_FOLDER ?= ../obj
SRC_FOLDER ?= ../src
INC_FOLDER ?= ../inc

# Determine the series folder name
include $(BASE_MAKE)/series-folder-name.mk

# Include the series-specific makefile
include $(BASE_MAKE)/$(SERIES_FOLDER)/common.mk
MAPPED_DEVICE ?= $(DEVICE)

# The toolchain path, defaults to using the globally installed toolchain
ifdef TOOLCHAIN_PATH
    TOOLCHAIN_SEPARATOR = /
endif

TOOLCHAIN_PATH	    ?= ../../../tools/bin/
TOOLCHAIN_SEPARATOR ?=
TOOLCHAIN_PREFIX    ?= arm-none-eabi-

CC      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
CXX     = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)g++
LD      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ld -v
AR      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ar
AS      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objdump
SIZE    = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)size

# Flags - Overall Options
CPPFLAGS += -specs=nosys.specs

# Flags - C Language Options
CFLAGS += -ffreestanding

# Flags - C++ Language Options
CXXFLAGS += -fno-threadsafe-statics
CXXFLAGS += -fno-rtti
CXXFLAGS += -fno-exceptions
CXXFLAGS += -fno-unwind-tables

# Flags - Warning Options
CPPFLAGS += -Wall
CPPFLAGS += -Wextra

# Flags - Debugging Options
CPPFLAGS += -g

# Flags - Optimization Options
CPPFLAGS += -ffunction-sections
CPPFLAGS += -fdata-sections
CPPFLAGS += -Os

# Flags - Preprocessor options
CPPFLAGS += -D $(MAPPED_DEVICE)

## Flags - Assembler Options
CPPFLAGS += -Wa,--defsym,CALL_ARM_SYSTEM_INIT=1

# Flags - Linker Options
# CPPFLAGS += -nostdlib
CPPFLAGS += -Wl,-L$(BASE_LINKER),-T$(BASE_LINKER)/$(SERIES_FOLDER)/$(DEVICE).ld

# Flags - Directory Options
CPPFLAGS += -I$(INC_FOLDER)
CPPFLAGS += -I$(BASE_STARTUP)

# Flags - Machine-dependant options
CPPFLAGS += -mcpu=$(SERIES_CPU)
CPPFLAGS += -march=$(SERIES_ARCH)
CPPFLAGS += -mtune=$(SERIES_CPU)
CPPFLAGS += -mlittle-endian
CPPFLAGS += -mthumb
CPPFLAGS += -masm-syntax-unified

# Output files
ELF_FILE_NAME ?= stm32_executable.elf
BIN_FILE_NAME ?= stm32_bin_image.bin

OBJ_FILE_NAME ?= startup_$(MAPPED_DEVICE).o

ELF_FILE_PATH = $(BIN_FOLDER)/$(ELF_FILE_NAME)
BIN_FILE_PATH = $(BIN_FOLDER)/$(BIN_FILE_NAME)
OBJ_FILE_PATH = $(OBJ_FOLDER)/$(OBJ_FILE_NAME)

# Input files
SRC ?=
SRC += $(SRC_FOLDER)/*.c

# Startup file

DEVICE_STARTUP = $(BASE_STARTUP)/$(SERIES_FOLDER)/$(MAPPED_DEVICE).s

# Include the CMSIS files

    CPPFLAGS += -I$(STM32_CMSIS_PATH)/ARM/inc
    CPPFLAGS += -I$(STM32_CMSIS_PATH)/$(SERIES_FOLDER)/inc

    SRC += $(STM32_CMSIS_PATH)/$(SERIES_FOLDER)/src/*.c

# Make all
all:$(BIN_FILE_PATH)

$(BIN_FILE_PATH): $(ELF_FILE_PATH)
	$(OBJCOPY) -O binary $^ $@

$(ELF_FILE_PATH): $(SRC) $(OBJ_FILE_PATH) | $(BIN_FOLDER)
#	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $^ -o $@
	$(CC) $(CPPFLAGS) $(CFLAGS) $^ -o $@ 
$(OBJ_FILE_PATH): $(DEVICE_STARTUP) | $(OBJ_FOLDER)
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $^ -o $@
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $^ -o $@
$(BIN_FOLDER):
	mkdir $(BIN_FOLDER)

$(OBJ_FOLDER):
	mkdir $(OBJ_FOLDER)

# OpenOCD parameters
OOCD		?= openocd
OOCD_INTERFACE	?= stlink

# Make clean
clean:
	rm -f $(ELF_FILE_PATH)
	rm -f $(BIN_FILE_PATH)
	rm -f $(OBJ_FILE_PATH)

# Make flash
flash:
#	st-flash write $(BIN_FOLDER)/$(BIN_FILE_NAME) $(FLASH)

# OpenOCD  
	$(OOCD) -f interface/$(OOCD_INTERFACE).cfg -f target/$(OOCD_TARGET).cfg \
	-c "program $(BIN_FOLDER)/$(ELF_FILE_NAME) verify reset exit"

.PHONY: all clean flash
