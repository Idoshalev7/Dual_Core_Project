`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:46:11 01/11/2025 
// Design Name: 
// Module Name:    Comparator 
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
module Comparator(
   input [31:0] S,
	input neg,
	input [2:0] F,
	output COMP_OUT 
    );
	 
	 wire s_eqz = (S == 32'h00000000) ;
	 assign COMP_OUT = ((~s_eqz) & ((~neg)& F[0])) | ((neg & F[2]) | (s_eqz & F[1])) ;
	 
	 

endmodule
