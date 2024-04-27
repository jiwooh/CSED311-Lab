`include "opcodes.v"

module ForwardingUnit(input [6:0] opcode,
                       input [4:0] rs1,
                       input [4:0] rs2,

                       input [4:0] dist1_rd,
                       input dist1_reg_write,

                       input [4:0] dist2_rd,
                       input dist2_reg_write,

                       output reg [1:0] forwardA,
                       output reg [1:0] forwardB);

// forwardX = 00 : No Forwarding
//          = 01 : Distance 1 Forwarding
//          = 10 : Distance 2 Forwarding
//          = 11 : Unused

always @(*) begin
    // rs1 Forwarding
    if (opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM || opcode == `LOAD || opcode == `STORE) begin
        if (rs1 == dist1_rd && dist1_rd != 0 && dist1_reg_write) begin
            forwardA = 2'b01; // Distance 1 Forwarding
        end else if (rs1 == dist2_rd && dist2_rd != 0 && dist2_reg_write) begin
            forwardA = 2'b10; // Distance 2 Forwarding
        end else begin
            forwardA = 2'b00; // No Forwarding
        end
    end else begin
        forwardA = 2'b00;
    end

    // rs2 Forwarding
    if (opcode == `ARITHMETIC || opcode == `LOAD || opcode == `STORE) begin
        if (rs1 == dist1_rd && dist1_rd != 0 && dist1_reg_write) begin
            forwardB = 2'b01; // Distance 1 Forwarding
        end else if (rs1 == dist2_rd && dist2_rd != 0 && dist2_reg_write) begin
            forwardB = 2'b10; // Distance 2 Forwarding
        end else begin
            forwardB = 2'b00; // No Forwarding
        end
    end else begin
        forwardB = 2'b00;
    end
end
endmodule
