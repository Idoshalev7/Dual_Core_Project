`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:08:37 01/09/2025 
// Design Name: 
// Module Name:    DLX_DATAPATH_TOP 
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
module DLX_DATAPATH_TOP(
    input clk,
    input reset,
    input IR_en,
    input A_en,
    input B_en,
    input C_en,
    input [1:0] S1_SEL,
    input [1:0] S2_SEL,
    
    input MDR_en,

    input test,
    input [31:0] DI,
    input MAR_en,
    input add,
    input A_MUX_SEL,
    input PC_en,
    input DINT_MUX_SEL,
    input MDR_MUX_SEL,
    input shift,
    input [4:0] D_ADR,
    input right,
    input GPR_WE,
	 input [1:0] ram_adr_sel,//new
	 input P0_success,
    output AEQZ_OUT,  
    output [31:0] IR, 
    output OVF,       
    output [31:0] DO, 
    output [31:0] GPR_D, 
    output [31:0] AO,
    output [31:0] MAR_OUT	 
	 
	 
	 
);
		
	wire [31:0] A;
	wire [31:0] B;
	wire [31:0] C;
	wire [2:0] ALUF;
	wire [31:0] ALU_OUT;
	wire [31:0] AMUX_OUT;
	wire [4:0] C_ADR;
	wire [4:0] C_ADR_A;
	wire [31:0] DINTMUX_OUT;
	wire [31:0] GPR_A;
	wire [31:0] GPR_B;
	wire [31:0] MDRMUX_OUT;
	wire [5:0] Opcode;
	wire [31:0] PC;
	wire [4:0] RS1;
	wire [4:0] RS2;
	wire [31:0] S1MUX_OUT;
	wire [31:0] S2MUX_OUT;
	wire [31:0] shift_out;
	wire [31:0] sext_imm;
	
	
	REG32bit reg_c (
	 .CLK(clk),
    .CE(C_en),
    .RESET(reset),
    .DI(DINTMUX_OUT),
	 .DOUT(C)
	);
	
	GPR GPR_1 (
	 .clk(clk),
    .GPR_WE(GPR_WE),
    .C(C),
    .A_ADR(RS1),
    .B_ADR(RS2),
    .C_ADR(C_ADR_A),
    .D_ADR(D_ADR),
    .A(GPR_A),
	 .P0_success(P0_success),
	 .ram_adr_sel(ram_adr_sel),
    .B(GPR_B),
    .D(GPR_D),
    .AEQZ(AEQZ_OUT)
	);
	
	 
	  REG32bit REG_A (
	 .CLK(clk),
    .CE(A_en),
    .RESET(reset),
    .DI(GPR_A),
	 .DOUT(A)
	);
	
	  REG32bit REG_B (
	 .CLK(clk),
    .CE(B_en),
    .RESET(reset),
    .DI(GPR_B),
	 .DOUT(B)
	);
	
	MUX32bit MUX_MDR(
	.A(DINTMUX_OUT),
	.B(DI),
	.sel(MDR_MUX_SEL),
	.O(MDRMUX_OUT )
	);
	
	REG32bit REG_MDR (
	 .CLK(clk),
    .CE(MDR_en),
    .RESET(reset),
    .DI(MDRMUX_OUT),
	 .DOUT(DO)
	);
	
	IR_ENV IR_ENV_1 (
	  .clk(clk),
    .IR_en(IR_en),
    .d_in(DI),
    .sext_imm(sext_imm),
	 .ALUF(ALUF),
    .Opcode(Opcode),
    .RS1(RS1),
    .RS2(RS2),
    .IR_OUT(IR),
    .C_ADR(C_ADR)

	);
	
	
	
	  REG32bit REG_PC (
	 .CLK(clk),
    .CE(PC_en),
    .RESET(reset),
    .DI(DINTMUX_OUT),
	 .DOUT(PC)
	);
	
	MUX4_32bit S1_MUX (
	.A(PC),
	.B(A),
	.C(B),
	.D(DO),
	.sel(S1_SEL),
	.O(S1MUX_OUT)
	);
	
	SHIFT_Env SHIFT_Env_1 (
	 .shift_in(S1MUX_OUT),
    .right(right),
    .shift(shift),
    .shift_out(shift_out)
	);
	
	MUX4_32bit S2_MUX (
	.A(B),
	.B(sext_imm),
	.C(32'b0),
	.D(32'b1),
	.sel(S2_SEL),
	.O(S2MUX_OUT)
	);

	
	ALU_ENV ALU_ENV_1(
	.A(S1MUX_OUT),
	.B(S2MUX_OUT),
	.ALUF(ALUF),
	.add(add),
	.test(test),
	.OVF(OVF),
	.ALU_OUT(ALU_OUT)
	);
	
	MUX32bit DINTMUX(
	.A(ALU_OUT),
	.B(shift_out),
	.sel(DINT_MUX_SEL),
	.O(DINTMUX_OUT)
	);
	
	  REG32bit MAR (
	 .CLK(clk),
    .CE(MAR_en),
    .RESET(reset),
    .DI(DINTMUX_OUT),
	 .DOUT(MAR_OUT)
	);
	
	MUX32bit AMUX(
	.A(PC),
	.B(MAR_OUT),
	.sel(A_MUX_SEL),
	.O(AMUX_OUT)
	);

	assign AO = {8'b0, AMUX_OUT[23:0]}; //  in fact thee MMU which disable disable acess to high adresses
	assign C_ADR_A = (ram_adr_sel == 2'b00) ? C_ADR[4:0] :
                 (ram_adr_sel == 2'b01) ? 5'd29 :
                 (ram_adr_sel == 2'b10) ? 5'd30 :
                 5'b0;  // Default case
													

endmodule
