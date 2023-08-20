from cocotb.types import LogicArray, Range


def to_array(input: int, nb_bits: int) -> LogicArray:
    """Convert the int value to a logic array"""

    return LogicArray(input, Range(nb_bits - 1, "downto", 0))
