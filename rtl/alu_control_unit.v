module alu_control_unit(
  input [6:0] opcode,
  input [2:0] funct3,
  input [6:0] funct7,
  output reg [3:0] alu_control
);
  always @(*) begin
    case (opcode)
      7'b0110011: begin // R-type
        case ({funct7, funct3})
          10'b0000000_000: alu_control = 4'b0010; // ADD
          10'b0100000_000: alu_control = 4'b0110; // SUB
          10'b0000000_111: alu_control = 4'b0000; // AND
          10'b0000000_110: alu_control = 4'b0001; // OR
          10'b0000000_100: alu_control = 4'b1101; // XOR
          10'b0000000_010: alu_control = 4'b0111; // SLT
          10'b0000000_011: alu_control = 4'b1001; // SLTU
          10'b0000000_001: alu_control = 4'b1111; // SLL
          10'b0000000_101: alu_control = 4'b1110; // SRL
          10'b0100000_101: alu_control = 4'b1000; // SRA
          default: alu_control = 4'b0000;
        endcase
      end

      7'b0010011: begin // I-type
        case (funct3)
          3'b000: alu_control = 4'b0010; // ADDI
          3'b010: alu_control = 4'b0111; // SLTI
          3'b011: alu_control = 4'b1001; // SLTIU
          3'b100: alu_control = 4'b1101; // XORI
          3'b110: alu_control = 4'b0001; // ORI
          3'b111: alu_control = 4'b0000; // ANDI
          3'b001: alu_control = 4'b1111; // SLLI
          3'b101: begin
            if (funct7 == 7'b0000000)
              alu_control = 4'b1110; // SRLI
            else if (funct7 == 7'b0100000)
              alu_control = 4'b1000; // SRAI
            else
              alu_control = 4'b0000;
          end
          default: alu_control = 4'b0000;
        endcase
      end

      default: alu_control = 4'b0000;
    endcase
  end
endmodule