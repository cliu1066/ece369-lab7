`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
//
// Student(s) Name and Last Name: 
//      Candice Liu (33%), Andrew Ghartey (33%), Barack Marwanga Asande (33%)
// 
// Module - Top_tb.v
// Description - Testbench for top level design of MIPS 5 stage pipeline
//
////////////////////////////////////////////////////////////////////////////////

module Top_tb();
    reg Clk, Rst;
    wire [31:0] PC_Out, RegWriteData;
    wire [31:0] v0, v1;

    Top u0(
        .Clk(Clk), 
        .Rst(Rst), 
        .PC_Out(PC_Out), 
        .RegWriteData(RegWriteData),
        .v0(v0),
        .v1(v1)
    );
    
    initial begin
        Clk <= 1'b0;
        forever #10 Clk <= ~Clk;
    end
    
    initial begin
        Rst <= 1'b1;
        #20;
        Rst <= 1'b0;
    end
    
endmodule