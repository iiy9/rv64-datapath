module alu(
  // Initialize the module with inputs and outputs
  input [63:0] a,
  input [63:0] b,
  input [3:0] alu_control,
  output reg [63:0] result,
  output wire zero
);
  // Assign zero to indicate if the result is zero
  assign zero = (result == 64'b0);

  // This module implements a 64-bit ALU with various operations
  always @(*) begin
    case (alu_control)
      4'b0000: result = a & b;  // AND
      4'b0001: result = a | b;  // OR
      4'b0010: result = a + b;  // ADD
      4'b0110: result = a - b;  // SUB
      4'b0111: result = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0; // SLT signed
      4'b1001: result = (a < b) ? 64'b1 : 64'b0;  // SLTU unsigned
      4'b1100: result = ~(a | b); // NOR
      4'b1101: result = a ^ b;  // XOR
      4'b1110: result = a >> b[5:0]; // SRL logical
      4'b1111: result = a << b[5:0]; // SLL logical
      4'b1000: result = $signed(a) >>> b[5:0]; // SRA arithmetic
      default: result = 64'b0;
    endcase
  end
endmodule