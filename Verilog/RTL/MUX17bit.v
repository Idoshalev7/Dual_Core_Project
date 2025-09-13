`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:19:36 01/11/2025 
// Design Name: 
// Module Name:    MUX17bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MUX17bit(
     input  [16:0] IN0,
    input  [16:0] IN1,
    input  sel,
    output [16:0] O
    );

assign O = (sel) ? IN1:IN0;


endmodule
