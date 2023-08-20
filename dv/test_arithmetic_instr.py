import cocotb
from cocotb.clock import Clock
from cocotb.handle import Force
from cocotb.triggers import RisingEdge

from conversion_handler import to_array

# Fix values in registers 1 and 2
VALUE_RS1 = 8
VALUE_RS2 = 2

RS1 = 1
RS2 = 2

# Chose destination registers for each instructions
RD_ADD = 3
RD_SUB = 4
RD_SLL = 5
RD_SRL = 6

# Declare the RISC-V instructions
ADD = RS2 << 20 | RS1 << 15 | RD_ADD << 7 | 0x33
SUB = 0x20 << 25 | RS2 << 20 | RS1 << 15 | RD_SUB << 7 | 0x33
SLL = RS2 << 20 | RS1 << 15 | 0x1 << 12 | RD_SLL << 7 | 0x33
SRL = RS2 << 20 | RS1 << 15 | 0x5 << 12 | RD_SRL << 7 | 0x33

# We start at memory index 1, then we have to wait a cycle
# Because of the way the tests are made, having separate tests for instructions
# We increase it by 2 after each test


@cocotb.test()
async def test_add_instr(dut):
    """Test the ADD instruction"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    # Initialize reset to 1
    dut.nrst.value = Force(1)

    # Retrieving the entry size
    dut.REGS[RS1].value = Force(to_array(VALUE_RS1, 32))
    dut.REGS[RS2].value = Force(to_array(VALUE_RS2, 32))

    dut.MEM[1].value = Force(to_array(ADD, 32))

    # Awaiting Clock rising edge
    # We need to wait for the CPU to fetch the instruction
    # Moreover, the design needs to acknowledge we "forced" values to signals.
    for _ in range(3):
        await RisingEdge(dut.clk)

    assert dut.REGS[RD_ADD].value.integer == VALUE_RS1 + VALUE_RS2


@cocotb.test()
async def test_sub_instr(dut):
    """Test the SUB instruction"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    dut.MEM[3].value = Force(to_array(SUB, 32))

    for _ in range(2):
        await RisingEdge(dut.clk)

    assert dut.REGS[RD_SUB].value.integer == VALUE_RS1 - VALUE_RS2


@cocotb.test()
async def test_sll_instr(dut):
    """Test the SLL instruction"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    dut.MEM[5].value = Force(to_array(SLL, 32))

    for _ in range(2):
        await RisingEdge(dut.clk)

    assert dut.REGS[RD_SLL].value.integer == VALUE_RS1 << VALUE_RS2


@cocotb.test()
async def test_srl_instr(dut):
    """Test the SRL instruction"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    dut.MEM[7].value = Force(to_array(SRL, 32))

    for _ in range(2):
        await RisingEdge(dut.clk)

    assert dut.REGS[RD_SRL].value.integer == VALUE_RS1 >> VALUE_RS2
