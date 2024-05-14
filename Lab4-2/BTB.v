module BTB (
    input [31:0] pc,
    input reset,
    input clk,
    input [31:0] real_pc,
    input [31:0] pc_plus_imm,  // for branch & jal
    input [31:0] reg_plus_imm, // for jalr
    input [4:0] real_pc_BHSR,
    input alu_bcond,
    input branch,
    input is_jal,
    input is_jalr,
    output reg [31:0] pred_pc,
    output reg [4:0] BHSR
);

    // tag table + btb + pht
    integer idx;
    reg [31:0] tag_table [0:31];
    reg [31:0] btb       [0:31]; // 32 entry btb
    reg [1:0]  pht       [0:31]; // 2-bit prediction

    // input query
    wire [31:0] query_tag;
    wire [4:0]  query_idx;
    // real pc
    wire [4:0]  real_pc_idx;
    wire [31:0] real_pc_tag;
    wire taken;

    assign query_tag = pc[31:0];
    assign query_idx = pc[6:2] ^ BHSR;

    assign real_pc_tag = real_pc[31:0];
    assign real_pc_idx = real_pc[6:2] ^ real_pc_BHSR;

    reg [4:0] BHSR_tmp;
    assign BHSR = (BHSR_tmp << 1) + {4'b0, taken};

    assign taken = (branch & alu_bcond) | is_jal | is_jalr;

    reg [31:0] dest; // temporary wire for convenience

    always @(posedge clk) begin
        if (reset) begin
            for (idx = 0; idx <= 31; idx = idx + 1) begin
                btb[idx] <= 0; // empty btb
                tag_table[idx] <= -1; // invalid tag
                pht[idx] <= 2'b00;
                BHSR_tmp<=0;
            end
        end
        else begin
            if (is_jal | branch) begin // destination = pc + imm
                dest <= pc_plus_imm;
            end else if (is_jalr) begin // destination = reg + imm
                dest <= reg_plus_imm;
            end

            if ((is_jal | branch| is_jalr ) &&
                (real_pc_tag != tag_table[real_pc_idx] | dest != btb[real_pc_idx])) begin
                tag_table[real_pc_idx] <= real_pc_tag;
                btb[real_pc_idx] <= dest;
            end
            
            // 3. pht : 2-bit prediction
            if (branch | is_jal | is_jalr) begin 
                if (taken) begin
                    case (pht[real_pc_idx])
                        2'b00: pht[real_pc_idx] <= 2'b01;
                        2'b01: pht[real_pc_idx] <= 2'b10;
                        2'b10: pht[real_pc_idx] <= 2'b11;
                        2'b11: pht[real_pc_idx] <= 2'b11;
                    endcase
                end else begin // not taken
                    case (pht[real_pc_idx])
                        2'b00: pht[real_pc_idx] <= 2'b00;
                        2'b01: pht[real_pc_idx] <= 2'b00;
                        2'b10: pht[real_pc_idx] <= 2'b01;
                        2'b11: pht[real_pc_idx] <= 2'b10;
                    endcase
                end
            end
        end
    end

    // 4. finally check "taken?"
    always @(*) begin
        if ( (branch | is_jal | is_jalr) 
            && (query_tag == tag_table[query_idx]) 
            && (pht[query_idx] >= 2'b10)) begin
            pred_pc = btb[query_idx];
        end else begin
            pred_pc = pc + 4;
        end
    end
endmodule
