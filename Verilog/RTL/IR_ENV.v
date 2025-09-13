`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:45 01/09/2025 
// Design Name: 
// Module Name:    IR_ENV 
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
module IR_ENV(

    input clk,
    input IR_en,
	 input [31:0] d_in,
   
 	 output [31:0] sext_imm,
    output [2:0] ALUF,
	 output [5:0] Opcode,
    output [4:0] RS1,
    output [4:0] RS2,
	
    output [31:0] IR_OUT,
    output [4:0] C_ADR
	 
    );
	
   wire [4:0] RD;
	
	reg [31:0] IR ;
	
	always @(posedge clk) begin
		if(IR_en)
		begin
				IR <= d_in ;		
		end
		else begin
				IR <= IR ;
				end
		end
	
	
	assign IR_OUT = IR  ;	
	assign Opcode = IR[31:26];
	assign RS1 =  IR[25:21];
	assign RS2 = IR[20:16] ;
	assign RD = (IR[31:28] ==4'b0) ? IR[15:11] : IR[20:16] ; // Check if instruction is Rtype or Itype
	assign C_ADR = (IR[31:29]== 3'b010 && IR[26]) ? 5'b11111 : RD[4:0]  ; // For JALR instruction, R(31)= C
	assign ALUF = (IR[31:28] ==4'b0) ? IR[2:0] : IR[28:26] ;
	assign sext_imm =  (IR[15])  ? { 16'hFFFF,IR[15:0]} :{ 16'h0000,IR[15:0]};

endmodule

