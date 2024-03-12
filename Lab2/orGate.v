module orGate(
    input x1,
    input x2,
    output wire y
);
    y = x1 | x2;
endmodule