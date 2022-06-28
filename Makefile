
.PHONY: clean
#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#openocd
OCD_INTERFACE =interface/cmsis-dap.cfg 
OCD_TARGET =target/stm32h7x.cfg
######################################
# target
######################################
TARGET = h7

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DSTM32H750xx \
-DUSE_HAL_DRIVER \
-DHSE_VALUE=25000000 \
-DUSE_PRINTF

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
#-Og
OPT = -Og

#######################################
# paths
#######################################
# Build path
BUILD_DIR = build
# AS includes
AS_INCLUDES = 

# C includes
#startup
C_INCLUDES =  \
-ILibrary/CMSIS/Include \
-ILibrary/CMSIS/Device/ST/STM32H7xx/Include \
#std periph
C_INCLUDES += \
-ILibrary/STM32H7xx_HAL_Driver/Inc \
#user
C_INCLUDES += \
-ISYSTEM/Inc \
-IUSER \
#HARDWARE
C_INCLUDES += \
-IHARDWARE/QSPI \
-IHARDWARE/NORFLASH \
#MIDWARE
C_INCLUDES += \

######################################
# source
######################################
# ASM sources
ASM_SOURCES =  \
Library/CMSIS/Device/ST/STM32H7xx/Source/gcc/startup_stm32h750xx.s

# C sources
#CORE
C_SOURCES =  \
Library/CMSIS/Device/ST/STM32H7xx/Source/system_stm32h7xx.c \
SYSTEM/Src/stm32h7xx_it.c \
#Driver Lib
C_SOURCES +=  \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_msp_template.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc_ex.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rng_ex.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_gpio.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr_ex.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart_ex.c \
Library/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_qspi.c \
#USER
C_SOURCES +=  \
USER/main.c \
SYSTEM/Src/bsp_led.c \
SYSTEM/Src/sys_delay.c \
SYSTEM/Src/sys_conf.c \
SYSTEM/Src/sys_usart.c \
#HARDWARE
C_SOURCES += \
HARDWARE/QSPI/qspi.c \
HARDWARE/NORFLASH/norflash.c \
#MIDWARE
C_SOURCES +=  
#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = Library/CMSIS/Device/ST/STM32H7xx/Source/gcc/linker/STM32H750XBTx_FLASH.ld

# libraries -lc
LIBS =	-lm -lc -lnosys 

LIBDIR =


#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m7

# fpu
# NONE for Cortex-M0/M0+/M3
FPU = -mfpu=fpv4-sp-d16
# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# -specs=nano.specs
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)
##########################
# write to flash
##########################
write:
	sudo openocd -f $(OCD_INTERFACE)  -f $(OCD_TARGET) -c init -c halt -c "flash write_image erase $(BUILD_DIR)/$(TARGET).hex" -c reset -c shutdown
 

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
