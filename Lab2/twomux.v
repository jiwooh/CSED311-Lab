module twomux (
    input [31:0] a, 
    input [31:0] b, 
    input sel, 
    output [31:0] y
);

assign y = sel ? a : b;

endmodule
