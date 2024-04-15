// simple 2:1 mux
module fourmux (
    input [31:0] x0, 
    input [31:0] x1, 
    input [31:0] x2, 
    input [31:0] x3, 
    input [1:0] sel, 
    output [31:0] y
);
    assign y = (sel==0) ? (x0)
               : ((sel==1) ? x1 : ((sel==2)? x2 : x3)); 
endmodule
