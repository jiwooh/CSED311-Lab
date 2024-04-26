// simple 2:1 mux for 4 bit inputs
module twomux4bit (
    input [4:0] x0, 
    input [4:0] x1, 
    input sel, 
    output [4:0] y
);
    assign y = sel ? x1 : x0;
endmodule
