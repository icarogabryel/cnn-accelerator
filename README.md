# CNN Accelerator

In this repository, you will find the hardware design for a Convolutional Neural Network (CNN) accelerator described in VHDL. It multiplies a 32-bit integer with a 7-bit constant from a 3x3 kernel and accumulates the results.

## The multiplier

The multiplier uses a parallel approach of the radix-4 Booth's algorithm. In this case, the 7-bit constant is used as the multiplier to generate only 4 partial products. Firstly, the architecture should use a wallace tree to sum the partial products. However, with only two levels, it was decided to use a four way adder that uses a 4:2 compressor internally to reduce the size of the circuit.
