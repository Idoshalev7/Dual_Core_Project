`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:21:02 01/11/2025 
// Design Name: 
// Module Name:    ALU_ENV 
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
module ALU_ENV(
   input [31:0] A,
	input [31:0] B,
	input [2:0] ALUF,
	input add,
	input test,
	output OVF,
	output [31:0] ALU_OUT
    );
	 
	
	wire [2:0] F;
	assign F  =  (add)   ? 3'b011 : ALUF[2:0] ; // Forcing add

	wire sub ; 
	assign sub = (~F[0]) | test ;	
	
	wire [31:0] or32_data; 
	wire [31:0] xor32_data;
	wire [31:0] and32_data;
	
	assign or32_data= A | B ;
	assign xor32_data= A ^ B ;
	assign and32_data= A & B ;
	
	wire  neg ;

	wire [31:0] mux_out_F0 ; 
	wire [31:0] mux_out_F1 ; 
	wire [31:0] mux_out_F2 ; 
	wire [31:0] mux_out_test ; 

	wire [31:0] add_sub_out ;
	
	wire COMP_OUT;
	wire [31:0] COMP_OUT_32_data ; 
	assign COMP_OUT_32_data = {31'b0 , COMP_OUT} ;
		
	
		ADD_SUB_32 add_sub (
		.A(A),
		.B(B),
		.sub(sub),
		.S(add_sub_out),
		.neg(neg),
		.ovf(OVF)
		
		);
	
	 
		MUX32bit mux_F0 (
		  .A(xor32_data),
		  .B(or32_data),
		  .sel(F[0]),
		  .O(mux_out_F0)
		);
	
		MUX32bit mux_F1 (
	  .A(mux_out_F0),
	  .B(and32_data),
     .sel(F[1]),
     .O(mux_out_F1)
	);
	
		MUX32bit mux_F2 (
	  .A(add_sub_out),
	  .B(mux_out_F1),
     .sel(F[2]),
     .O(mux_out_F2)
	);

		MUX32bit mux_test (
	  .A(mux_out_F2),
	  .B(COMP_OUT_32_data),
     .sel(test),
     .O(ALU_OUT)
	);
	
		Comparator Comparator_1 (
		.S(add_sub_out),
		.neg(neg),
		.F(F),
		.COMP_OUT(COMP_OUT) 
		);
	

endmodule
