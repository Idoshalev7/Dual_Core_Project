`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:00:26 01/11/2025 
// Design Name: 
// Module Name:    ADD_SUB_32 
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
module ADD_SUB_32(
   input [31:0] A,
	input [31:0] B,
	input sub,
	output [31:0] S,
	output neg,
	output ovf
    );

	wire add ; 
	assign add = ~ sub ;
	
	wire cout ;
	
	wire [15:0] out_L ;
	wire [16:0] out_m0 ;//cin =0 
	wire [16:0] out_m1 ;// cin =1 
	wire [16:0] mux_out ; 
	wire cout1 ; 
	wire ovf_l;
	wire ovf_m0;
	wire ovf_m1;
	

	ADSU16 addL (
	.CI(sub),
	.A(A[15:0]),
	.B(B[15:0]),
	.ADD(add),
	.S(out_L),
	.CO(cout1),
	.OFL(ovf_l)
	);
	
	ADSU16 addm0 (
	.CI(1'b0),
	.A(A[31:16]),
	.B(B[31:16]),
	.ADD(add),
	.S(out_m0[15:0]),
	.CO(out_m0[16]),
	.OFL(ovf_m0)
	);
	
	ADSU16 addm1 (
	.CI(1'b1),
	.A(A[31:16]),
	.B(B[31:16]),
	.ADD(add),
	.S(out_m1[15:0]),
	.CO(out_m1[16]),
	.OFL(ovf_m1)
	);
	
   MUX17bit MUX17bit_1 (
	.IN0(out_m0),
	.IN1(out_m1),
	.sel(cout1),
	.O(mux_out)
	);
	
	assign cout = mux_out[16] ; 
	assign S = {mux_out[15:0],out_L[15:0]} ;
	assign ovf = (cout1)? ovf_m1 : ovf_m0;
	assign neg = ovf ^ S[31] ;

endmodule
