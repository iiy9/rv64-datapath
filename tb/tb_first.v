module cpu_testbench;
  reg clk;
  reg we;
  reg [4:0] rs1, rs2, rd;
  reg [63:0] wd;
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [63:0] b_in;
  reg [3:0] alu_control;
  integer i;

  wire [63:0] rd1, rd2;
  wire [3:0] alu_ctrl_from_unit;
  wire [63:0] alu_result;
  wire zero;

  // Instantiate regfile
  regfile rf (
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
  );

  // Instantiate ALU control unit
  alu_control_unit cu (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .alu_control(alu_ctrl_from_unit)
  );

  // Instantiate ALU
  alu alu_inst (
    .a(rd1),
    .b(b_in),
    .alu_control(alu_control),
    .result(alu_result),
    .zero(zero)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;
    opcode = 0; funct3 = 0; funct7 = 0;
    b_in = 0; alu_control = 0;

    // Reset all registers to 0
    for (i = 1; i < 32; i = i + 1) begin
      we = 1; rd = i; wd = 0;
      @(posedge clk);
      we = 0; rd = 0; wd = 0;
      @(posedge clk);
    end
    we = 0;
    rd = 0;
    wd = 0;
    @(posedge clk);

    // Write 15 to x1
    $display("Write start: we=%b rd=%d wd=%d at time %0t", we, 1, 15, $time);
    we = 1; rd = 1; wd = 15;
    @(posedge clk);
    we = 0; rd = 0; wd = 0;
    @(posedge clk);
    $display("Write done: we=%b rd=%d wd=%d at time %0t", we, 1, 15, $time);
    @(posedge clk);

    // Write 10 to x2
    $display("Write start: we=%b rd=%d wd=%d at time %0t", we, 2, 10, $time);
    we = 1; rd = 2; wd = 10;
    @(posedge clk);
    we = 0; rd = 0; wd = 0;
    @(posedge clk);
    $display("Write done: we=%b rd=%d wd=%d at time %0t", we, 2, 10, $time);
    @(posedge clk);

    // Set read addresses and wait for a clock cycle
    rs1 = 1; rs2 = 2;
    @(posedge clk);
    $display("Read addresses set: rs1=%d rs2=%d at time %0t", rs1, rs2, $time);
    @(posedge clk); // Wait for register values to be read
    @(posedge clk); // Extra clock to ensure data is stable

    // Test ADD operation (R-type)
    opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000;
    @(posedge clk); // Wait for ALU control to be generated
    alu_control = alu_ctrl_from_unit;
    b_in = rd2;
    @(posedge clk); // Wait for ALU operation to complete
    $display("ADD: x1=%d + x2=%d = %d", rd1, rd2, alu_result);
    @(posedge clk);

    // Test SUB operation (R-type)
    funct7 = 7'b0100000;
    @(posedge clk); // Wait for ALU control to be generated
    alu_control = alu_ctrl_from_unit;
    b_in = rd2;
    @(posedge clk); // Wait for ALU operation to complete
    $display("SUB: x1=%d - x2=%d = %d", rd1, rd2, alu_result);
    @(posedge clk);

    // Test ADDI operation (I-type)
    opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000;
    rs1 = 1; rs2 = 0; // rs2 unused for immediate
    @(posedge clk); // Wait for ALU control to be generated
    alu_control = alu_ctrl_from_unit;
    b_in = 7; // immediate
    @(posedge clk); // Wait for ALU operation to complete
    $display("ADDI: x1=%d + imm=7 = %d", rd1, alu_result);
    @(posedge clk);

    // Test SLTI operation (I-type)
    funct3 = 3'b010;
    @(posedge clk); // Wait for ALU control to be generated
    alu_control = alu_ctrl_from_unit;
    b_in = 20;
    @(posedge clk); // Wait for ALU operation to complete
    $display("SLTI: x1=%d < imm=20 ? Result = %d", rd1, alu_result);
    @(posedge clk);

    // Finish simulation
    $finish;
  end
endmodule