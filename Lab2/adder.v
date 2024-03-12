module adder (
    input [31:0] x1, 
    input [31:0] x2, 
    output [31:0] y);
    always @(*) begin
        y= x1 + x2;
    end
endmodule