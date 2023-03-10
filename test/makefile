# Makefile

TOPLEVEL_LANG = verilog
SIM = verilator

# Directories definition
TEST_DIRECTORY = $(shell pwd)
SRC_DIRECTORY = $(shell dirname $(TEST_DIRECTORY))/src

# Default verilog file to test
VERILOG_FILE = riscvproc_final.v
TOPLEVEL = rvcore

# Test to simulate
TEST = ARITH
MODULE = test_arithmetic_instr

## Definition of default generic values for each file

# Arithmetic instruction test:
ifeq ($(TEST), ARITH)
	MODULE = test_arithmetic_instr
endif

# Pointing to the VHDL file to test
VERILOG_SOURCES = $(SRC_DIRECTORY)/$(VERILOG_FILE)

EXTRA_ARGS += --trace --trace-structs

clean:
	rm *.vcd
	rm *.xml
	rm -r sim_build

include $(shell cocotb-config --makefiles)/Makefile.sim

