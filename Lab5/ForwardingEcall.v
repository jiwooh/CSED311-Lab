module ForwardingEcall (input [4:0] rs1,
                        input [4:0] rs2,
                        input [4:0] rd,
                        input [4:0] EX_MEM_rd,
                        input is_ecall,
                        input [31:0] rd_din,
                        input [31:0] rs1_dout,
                        input [31:0] rs2_dout,
                        input [31:0] EX_MEM_alu_out,
                        output reg [31:0] rs1_dout_forwarded,
                        output reg [31:0] rs2_dout_forwarded);

    always @(*) begin
        if((rs1 == rd) && (rd != 0)) begin
            rs1_dout_forwarded = rd_din;
        end
        else if((EX_MEM_rd == 5'd17) && is_ecall) begin
            rs1_dout_forwarded = EX_MEM_alu_out;
        end
        else begin
            rs1_dout_forwarded = rs1_dout;
        end

        if((rs2 == rd) && (rd != 0)) begin
            rs2_dout_forwarded = rd_din;
        end
        else begin
            rs2_dout_forwarded = rs2_dout;
        end
    end
endmodule
