// simple 3:1 mux
module DataMux (
    input [31:0] x0, 
    input [31:0] x1, 
    input [31:0] x2, 
    input [31:0] x3, 
    input [1:0] sel, 
    output reg [31:0] y
);
    always @(*) begin
        if (sel == 2'b00) begin
            y = x0;
        end else if (sel == 2'b01) begin
            y = x1;
        end else if (sel == 2'b10) begin
            y = x2;
        end else if (sel == 2'b11) begin
            y = x3;
        end else begin
            y = 32'b0;
        end
    end

endmodule
