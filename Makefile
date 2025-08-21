
PROJECT_NAME     := nrf5_sdk_project
TARGETS          := nrf52840_xxaa
OUTPUT_DIRECTORY := _build

SDK_ROOT         := $(NRF5_SDK_PATH)
PROJ_DIR         := .
TEMPLATE_PATH    := $(SDK_ROOT)/components/toolchain/gcc
GDB_SERVER_TARGET := $${GDB_SERVER_IP}:$${GDB_SERVER_PORT}

$(OUTPUT_DIRECTORY)/nrf52840_xxaa.out: \
  LINKER_SCRIPT  := $(PROJ_DIR)/linker/nrf52840_xxaa.ld

OPT = -O3 -g3
# Uncomment the line below to enable link time optimization
#OPT += -flto

# Source files
SRC_FILES += \
  $(PROJ_DIR)/main.c \
  $(SDK_ROOT)/modules/nrfx/mdk/gcc_startup_nrf52840.S \
  $(SDK_ROOT)/modules/nrfx/mdk/system_nrf52840.c \
  $(SDK_ROOT)/modules/nrfx/soc/nrfx_atomic.c \
  $(SDK_ROOT)/components/boards/boards.c \
  $(SDK_ROOT)/components/libraries/atomic/nrf_atomic.c \
  $(SDK_ROOT)/components/libraries/balloc/nrf_balloc.c \
  $(SDK_ROOT)/components/libraries/memobj/nrf_memobj.c \
  $(SDK_ROOT)/components/libraries/ringbuf/nrf_ringbuf.c \
  $(SDK_ROOT)/components/libraries/strerror/nrf_strerror.c \
  $(SDK_ROOT)/components/libraries/util/app_error.c \
  $(SDK_ROOT)/components/libraries/util/app_error_handler_gcc.c \
  $(SDK_ROOT)/components/libraries/util/app_error_weak.c \
  $(SDK_ROOT)/components/libraries/util/app_util_platform.c \
  $(SDK_ROOT)/components/libraries/util/nrf_assert.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_rtt.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_serial.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_uart.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_default_backends.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_frontend.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_str_formatter.c \
  $(SDK_ROOT)/external/fprintf/nrf_fprintf.c \
  $(SDK_ROOT)/external/fprintf/nrf_fprintf_format.c \
  $(SDK_ROOT)/external/segger_rtt/SEGGER_RTT.c \
  $(SDK_ROOT)/external/segger_rtt/SEGGER_RTT_Syscalls_GCC.c \
  $(SDK_ROOT)/external/segger_rtt/SEGGER_RTT_printf.c

# Include directories
INC_FOLDERS += \
  $(PROJ_DIR) \
  $(PROJ_DIR)/config \
  $(SDK_ROOT)/components \
  $(SDK_ROOT)/components/boards \
  $(SDK_ROOT)/components/drivers_nrf/nrf_soc_nosd \
  $(SDK_ROOT)/components/libraries/atomic \
  $(SDK_ROOT)/components/libraries/balloc \
  $(SDK_ROOT)/components/libraries/bsp \
  $(SDK_ROOT)/components/libraries/delay \
  $(SDK_ROOT)/components/libraries/experimental_section_vars \
  $(SDK_ROOT)/components/libraries/log \
  $(SDK_ROOT)/components/libraries/log/src \
  $(SDK_ROOT)/components/libraries/memobj \
  $(SDK_ROOT)/components/libraries/ringbuf \
  $(SDK_ROOT)/components/libraries/strerror \
  $(SDK_ROOT)/components/libraries/util \
  $(SDK_ROOT)/components/toolchain/cmsis/include \
  $(SDK_ROOT)/external/fprintf \
  $(SDK_ROOT)/external/segger_rtt \
  $(SDK_ROOT)/integration/nrfx \
  $(SDK_ROOT)/modules/nrfx \
  $(SDK_ROOT)/modules/nrfx/hal \
  $(SDK_ROOT)/modules/nrfx/mdk

# Libraries
LIB_FILES += -lc -lnosys -lm

# Common processor flags
PROCESSOR_FLAGS = -mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Common defines
COMMON_DEFINES = \
  -DUSE_APP_CONFIG \
  -DBOARD_PCA10056 \
  -DBSP_DEFINES_ONLY \
  -DCONFIG_GPIO_AS_PINRESET \
  -DFLOAT_ABI_HARD \
  -DNRF52840_XXAA

# C flags
CFLAGS += $(OPT)
CFLAGS += $(PROCESSOR_FLAGS)
CFLAGS += $(COMMON_DEFINES)
CFLAGS += -Wall -Werror
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums

# C++ flags
CXXFLAGS += $(OPT)
CXXFLAGS += $(PROCESSOR_FLAGS)
CXXFLAGS += $(COMMON_DEFINES)

# Assembler flags
ASMFLAGS += -g3
ASMFLAGS += $(PROCESSOR_FLAGS)
ASMFLAGS += $(COMMON_DEFINES)

# Linker flags
LDFLAGS += $(OPT)
LDFLAGS += $(PROCESSOR_FLAGS)
LDFLAGS += -L$(SDK_ROOT)/modules/nrfx/mdk -T$(LINKER_SCRIPT)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += --specs=nano.specs

# Target-specific flags
nrf52840_xxaa: CFLAGS += -D__HEAP_SIZE=8192 -D__STACK_SIZE=8192
nrf52840_xxaa: ASMFLAGS += -D__HEAP_SIZE=8192 -D__STACK_SIZE=8192

# Include template
include $(TEMPLATE_PATH)/Makefile.common

$(foreach target, $(TARGETS), $(call define_target, $(target)))

# PHONY targets
.PHONY: default help flash erase reset

# Default target
default: nrf52840_xxaa

# Print all available targets
help:
	@echo "Available targets:"
	@echo "  nrf52840_xxaa  - Build the main firmware"
	@echo "  flash          - Flash the firmware to device"
	@echo "  erase          - Erase device flash"
	@echo "  reset          - Reset device"
	@echo "  help          - Show this help message"

# Flash the program
flash: default
	@echo "Flashing: $(OUTPUT_DIRECTORY)/nrf52840_xxaa.out"
	gdb-multiarch --batch \
		-ex "target remote $(GDB_SERVER_TARGET)" \
		-ex "monitor halt" \
		-ex "load" \
		-ex "monitor reset" \
		-ex "monitor go" \
		-ex "quit" \
		$(OUTPUT_DIRECTORY)/nrf52840_xxaa.out

# Erase device flash
erase:
	@echo "Erasing device flash..."
	gdb-multiarch --batch \
		-ex "target remote $(GDB_SERVER_TARGET)" \
		-ex "monitor halt" \
		-ex "monitor flash erase" \
		-ex "monitor reset" \
		-ex "quit"

# Reset device
reset:
	@echo "Resetting device..."
	gdb-multiarch --batch \
		-ex "target remote $(GDB_SERVER_TARGET)" \
		-ex "monitor reset" \
		-ex "monitor go" \
		-ex "quit"
