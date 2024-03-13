module twomux (
    input [31:0] x0, 
    input [31:0] x1, 
    input sel, 
    output [31:0] y);
    assign y = sel? x1:x0;
endmodule
