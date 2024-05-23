// Program Counter
module PC(  
    input reset,
    input clk,
    input pc_write,
    input [31:0] next_pc,
    input cache_stall,
    output reg [31:0] current_pc
);
  
    always @(posedge clk) begin
        // Reset register file
        if (reset) begin
            current_pc <= 0;
        end
        else if (pc_write & !cache_stall) begin
            current_pc <= next_pc;
        end else begin // data hazard
            current_pc <= current_pc;
        end
    end
endmodule
