import cocotb
from cocotb.clock import Clock
from cocotb.handle import Force
from cocotb.triggers import RisingEdge

from conversion_handler import to_array

VALUE_RS1 = 5
VALUE_RS2 = 7

RS1 = 1
RS2 = 2
RD = 3

ADD = RS2 << 20 | RS1 << 15 | RD << 7 | 0x33

index = 4

@cocotb.test()
async def test_add_instr(dut):
    """Test a fixed add instruction"""

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    # Initialize reset to 1
    dut.nrst.value = Force(1)

    # Retrieving the entry size
    dut.REGS[RS1].value = Force(to_array(VALUE_RS1, 32))
    dut.REGS[RS2].value = Force(to_array(VALUE_RS2, 32))

    dut.MEM[index].value = Force(to_array(ADD, 32))

    # Awaiting Clock rising edge
    # We need to wait for the CPU to fetch the instruction
    # Moreover, the design needs to acknowledge we "forced" values to signals.
    for _ in range(index + 2):
        await RisingEdge(dut.clk)

    assert dut.REGS[RD].value.integer == VALUE_RS1 + VALUE_RS2

