# RV64 datapath blocks

64-bit ALU, ALU control decoder (R-type and I-type) and a 32x64 register file in Verilog.

The blocks were written in June 2025. In November 2026 a self-checking test with 4,000 random operations was added; it found that SRLI and SRAI failed for shift amounts of 32 and above, which is fixed.

Run with `make` (Icarus Verilog).
