// Program Counter
module PC(  
    input reset,
    input clk,
    input [31:0] next_pc,
    output reg [31:0] current_pc
);
  
    always @(posedge clk) begin
        // Reset register file
        if (reset) begin
            current_pc <= 0;
        end
        else begin
            current_pc <= next_pc;
        end
    end
endmodule
