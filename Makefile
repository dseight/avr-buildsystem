include config.mak

CROSS := avr-

AS := $(CROSS)gcc
CC := $(CROSS)gcc
SIZE := $(CROSS)size
OBJCOPY := $(CROSS)objcopy

PROGRAMMER ?= usbasp

CFLAGS := -Wall -Wextra -Werror
CFLAGS += -Os -DF_CPU=$(CLOCK)UL -mmcu=$(DEVICE)


obj-y += main.o

all: main.hex
# Dummy command so that make thinks it has done something
	@true

main.bin: $(obj-y)
	$(call LINK, $^)

main.hex: main.bin
	@rm -f main.hex
	$(call quiet-command, $(OBJCOPY) -j .text -j .data -O ihex $< $@ \
		,"GEN","$@")

size: main.bin
	@$(SIZE) --format=avr --mcu=$(DEVICE) main.bin

flash: all
	avrdude -p $(DEVICE) $(PROGRAMMER) -U flash:w:main.hex:i


.PHONY: all clean cscope size flash

# Flags for dependency generation
DGFLAGS = -MMD -MP -MT $@ -MF $(@D)/$(*F).d

%.o: %.c
	$(call quiet-command, $(CC) $(INCLUDES) $(DGFLAGS) $(CFLAGS) $($@-cflags) \
	       -c -o $@ $<,"CC","$@")

%.o: %.S
	$(call quiet-command, $(AS) $(INCLUDES) $(DGFLAGS) $(CFLAGS) \
	       -c -o $@ $<,"AS","$@")

LINK = $(call quiet-command, $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $1 \
      $(LIBS),"LINK","$@")

# Usage: $(call quiet-command,command and args,"NAME","args to print")
# This will run "command and args", and print the 'quiet' output in the
# format "  NAME     args to print"
# NAME should be a short name of the command, 7 letters or fewer.
# If called with only a single argument, will print nothing in quiet mode.
quiet-command = $(if $(2),@printf "  %-7s %s\n" $2 $3 && $1, @$1)

clean:
	find . -name '*.[oda]' -type f -exec rm {} +
	rm -f main.bin
	rm -f main.hex
	rm -f tags cscope.*

ctags:
	rm -f tags
	find . -name '*.[hc]' -exec ctags --append {} +

cscope:
	rm -f ./cscope.*
	find . -name "*.[chsS]" -print > ./cscope.files
	cscope -b -i./cscope.files

# Include generated dependencies
-include $(wildcard *.d)
