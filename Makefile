###############################################
#											  #
#	Copyright (c) 2021 Nicolás Ruiz Requejo   #
#											  #
#	https://risingedgeonline.com/			  #
# 											  #
###############################################

#########################
#### General options ####
#########################
# Name of main module .c
TARGET=blinkLED
# Your mcu's name-code
MCU = atmega328p
# Your mcu's clock freq
MCU_FREQ = 16000000
 

###########################
#### Programmer params ####
###########################
AVRDUDE = avrdude
PROGRAMMER_TYPE = usbtiny
PROGRAMMER_ARGS = -p $(MCU) -c $(PROGRAMMER_TYPE) -v 

###########################
#### Compiler - linker ####
###########################
CC = avr-gcc
# -g: debug info, -Os: optimize for space
# -Wextra: extra warnings
CFLAGS = -Os -Wextra -std=gnu99
CFLAGS += -DF_CPU=$(MCU_FREQ)
LDFLAGS = -Wl,-Map,$(TARGET).map
ARCHFLAG = -mmcu=$(MCU)
DBGFLAGS = -g
# using string substitution function
# to get list of objects
OBJECTS = $(patsubst %.c,%.o,$(wildcard *.c))

###############
#### Rules ####
###############

.PHONY: all clean view
all: flash

view: 
	@echo $(OBJECTS)

# Generates objects files with pattern rule
%.o: %.c
	$(CC) $(DBGFLAGS) $(CFLAGS) $(ARCHFLAG) -c -o $@ $^

# Pattern rule can not be used to make
# elf target because '%' character is not
# used in the target
$(TARGET).elf: $(OBJECTS)
	$(CC) $(DBGFLAGS) $(ARCHFLAG) -o $@ $^

# Intel format executable file
%.hex: %.elf
	avr-objcopy -j .text -j .data -O ihex $< $@

flash: $(TARGET).hex
	$(AVRDUDE) $(PROGRAMMER_ARGS) -U flash:w:$<

# Connect to the mcu
chip:
	$(AVRDUDE) $(PROGRAMMER_ARGS) -n

clean:
	rm -f *.o $(TARGET).elf $(TARGET).hex \
	$(TARGET).map

# Generate .map file
linkermap: $(OBJECTS)
	$(CC) $(LDFLAGS) $(ARCHFLAG) -o $(TARGET).elf $^
