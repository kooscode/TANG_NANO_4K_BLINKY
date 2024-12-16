
# -------------------------------------------------------------------------------
# Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
# -------------------------------------------------------------------------------


CPPFLAGS = -mthumb -mcpu=cortex-m3 -nostartfiles -nostdlib -static -fno-exceptions -O1
CPPSTD = c++20 
CPP = arm-none-eabi-g++
OBJCPY = arm-none-eabi-objcopy

OUTDIR = out
SRCDIR = src

# User CPP files 
ALL_CPP = $(wildcard $(SRCDIR)/*.cpp)
# All User and Gowin OBJ files to build
ALL_OBJ =	$(patsubst $(SRCDIR)/%.cpp, $(OUTDIR)/%.o, $(ALL_CPP))

Done: $(OUTDIR)/firmware.bin
	@echo "\nDone: $<\n"
	@echo "Code + Data + BSS = TotalSize (Make sure this will fit into 16kb SRAM):"
	@arm-none-eabi-size $(OUTDIR)/firmware.elf 

# Compile bootloader
$(OUTDIR)/bootloader.o: bootloader.s
	@echo "Compiling $< >>> $@"
	@mkdir -p $(OUTDIR)
	@$(CPP) $(CPPFLAGS) -c bootloader.s -o $(OUTDIR)/bootloader.o

# Build all object files
$(ALL_OBJ): $(OUTDIR)/%.o: $(SRCDIR)/%.cpp 
	@echo "Compiling $< >>> $@"
	@mkdir -p $(OUTDIR)
	@$(CPP) -std=$(CPPSTD) $(CPPFLAGS) -c $< -o $@

# link everything
$(OUTDIR)/firmware.elf: $(OUTDIR)/bootloader.o $(ALL_OBJ)
	@echo "Linking $@ <<< $< $(ALL_OBJ)"
	@$(CPP) $(CPPFLAGS) -Tfirmware.ld -o $(OUTDIR)/firmware.elf $(OUTDIR)/bootloader.o $(ALL_OBJ)

# covert elf to bin
$(OUTDIR)/firmware.bin: $(OUTDIR)/firmware.elf
	@echo "Converting $< to $@"
	@$(OBJCPY) -O binary $(OUTDIR)/firmware.elf $(OUTDIR)/firmware.bin

clean:
	@rm -fr $(OUTDIR)
	@echo "Cleaned \"$(OUTDIR)\"" 

