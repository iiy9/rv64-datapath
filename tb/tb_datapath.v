`timescale 1ns/1ps
// Self-checking: register file -> decoder -> ALU against a behavioural model.
module tb_datapath;
  reg clk = 0, we = 0; reg [4:0] rs1 = 0, rs2 = 0, rd = 0; reg [63:0] wd = 0, imm = 0; reg use_imm = 0;
  reg [6:0] opcode = 0, funct7 = 0; reg [2:0] funct3 = 0;
  wire [63:0] rd1, rd2, res; wire [3:0] ctl; wire zero;
  regfile rf(.clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd), .rd1(rd1), .rd2(rd2));
  alu_control_unit cu(.opcode(opcode), .funct3(funct3), .funct7(funct7), .alu_control(ctl));
  alu dut(.a(rd1), .b(use_imm ? imm : rd2), .alu_control(ctl), .result(res), .zero(zero));
  always #5 clk = ~clk;
  reg [63:0] m [0:31]; integer i, k, errors = 0, seed = 11; reg [63:0] a, b, e;

  // Drive on negedge, so the register file never races with the stimulus.
  task wr(input [4:0] r, input [63:0] v);
    begin we = 1; rd = r; wd = v; if (r != 0) m[r] = v; @(negedge clk); we = 0; end
  endtask
  function [63:0] model(input [63:0] x, y, input [2:0] f3, input alt);
    case (f3)
      0: model = alt ? x - y : x + y;
      1: model = x << y[5:0];
      2: model = ($signed(x) < $signed(y)) ? 1 : 0;
      3: model = (x < y) ? 1 : 0;
      4: model = x ^ y;
      5: if (alt) model = $signed(x) >>> y[5:0]; else model = x >> y[5:0];
      6: model = x | y;
      7: model = x & y;
    endcase
  endfunction
  task check(input alt);
    begin
      #1; e = model(a, b, funct3, alt);
      if (res !== e || zero !== (e == 0)) begin
        errors = errors + 1;
        if (errors < 8) $display("FAIL op %b f3 %0d f7 %b a %h b %h got %h exp %h", opcode, funct3, funct7, a, b, res, e);
      end
    end
  endtask
  initial begin
    m[0] = 0; @(negedge clk);
    for (i = 1; i < 32; i = i + 1) wr(i, {$random(seed), $random(seed)});
    wr(0, 64'hdead); wr(1, 64'h8000_0000_0000_0000); wr(2, 64'hffff_ffff_ffff_ffff); wr(3, 0);
    for (k = 0; k < 4000; k = k + 1) begin
      rs1 = $random(seed); rs2 = $random(seed); funct3 = $random(seed); #1;
      a = m[rs1]; if (rd1 !== a) begin errors = errors + 1; $display("FAIL rs1 x%0d", rs1); end
      if (k % 2) begin                                   // R-type
        opcode = 7'b0110011; use_imm = 0; b = m[rs2];
        funct7 = ((funct3 == 0 || funct3 == 5) && ($random(seed) & 1)) ? 7'h20 : 7'h00;
        if (rd2 !== b) begin errors = errors + 1; $display("FAIL rs2 x%0d", rs2); end
        check(funct7 == 7'h20);
      end else begin                                     // I-type, 6-bit shift amounts
        opcode = 7'b0010011; use_imm = 1; imm = {{52{1'b0}}, 12'b0}; i = $random(seed);
        if (funct3 == 1) imm = {58'b0, i[5:0]};
        else if (funct3 == 5) imm = {52'b0, 1'b0, i[8], 4'b0, i[5:0]};
        else imm = {{52{i[11]}}, i[11:0]};
        funct7 = imm[11:5]; b = imm; check(funct3 == 5 && imm[10]);
      end
    end
    if (errors == 0) $display("PASS datapath: 4000 operations"); else $display("FAIL %0d errors", errors);
    $finish;
  end
endmodule
