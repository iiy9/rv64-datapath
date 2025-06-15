module regfile(
  // Initialize the module with inputs and outputs
  input clk,
  input we,
  input [4:0] rs1, rs2, rd,
  input [63:0] wd,
  output wire [63:0] rd1, rd2
);

  // This module implements a 32-entry register file with 64-bit wide registers.
  reg [63:0] regs [31:0];

  // Control the write operation
  assign rd1 = (rs1 == 0) ? 64'b0 : regs[rs1];
  assign rd2 = (rs2 == 0) ? 64'b0 : regs[rs2];

  always @(posedge clk) begin
    if (we && rd != 0) begin
      // Write data to the register file if write enable is high and rd is not zero
      regs[rd] <= wd;
      $display("Regfile write: regs[%0d] <= %0d at time %0t", rd, wd, $time);
    end
  end
endmodule