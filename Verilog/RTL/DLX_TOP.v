`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:30:10 01/11/2025 
// Design Name: 
// Module Name:    DLX_TOP 
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
module DLX_TOP(
    input clk,
    input reset,
    input step_en,
    input ACK_N,
    input [4:0] D_ADR,
    input [31:0] DI,
    input P0_pass,              // SyncBox memory access grant
    input P0_success,           // SyncBox reservation/arbitration result
    input P1_in_init,           // Input to indicate if other processor (P1) is in INIT state
	 input  in_idle,
    output A_en,
    output A_sel,
    output AEQZ, 
    output [2:0] ALUF,
    output [31:0] AO,
    output AS_N,
    output B_en,
    output C_en,
    output DINT_sel,
    output [31:0] DO,
    output [31:0] GPR_D,
    output GPR_WE,
    output [31:0] IR,
    output IR_en,
    output Itype,
    output MAR_en,
    output MDR_en,
    output MDR_sel,
    output OVF,
    output PC_en,
    output [1:0] S1_sel,
    output [1:0] S2_sel,
    output WR_N,
    output add,
    output busy,
    output in_init,
    output jlink,
    output mr,
    output mw,
    output shift,
    output stop_n,
    output test,
    output [4:0] DLX_STATE_OUT,
    output [1:0] MAC_STATE_OUT,
	 output [31:0] MAR_OUT,
    output trigger_P0,          // SyncBox VALIDATE trigger
	 output req_P0,
    output P0_mem_complete,     // Memory operation completion
    output atomic_inst_P0,         // Debug flag for atomic instructions (replaces req_P0)
    output R29_addr,            // R32 address for CHECK_WBA_32
    output R30_addr,            // R33 address for WBA_33
    output [1:0] instr_type_P0  // Atomic instruction type
);

    wire right; 
    wire [1:0] ram_adr_sel;

    // Updated: Added atomic instruction support (P0_pass, P0_success, P1_in_init, trigger_P0, P0_mem_complete, atomic_inst, R32_addr, R33_addr, instr_type_P0)
    DLX_CONTROL_TOP DLX_CONTROL_TOP_1 (
        .clk(clk),
        .reset(reset),
        .AEQZ(AEQZ),
        .step_en(step_en),
        .IR(IR),
        .ACK_N(ACK_N),
        .P0_pass(P0_pass),          // New: SyncBox memory access grant
        .P0_success(P0_success),    // New: SyncBox reservation/arbitration result
        .P1_in_init(P1_in_init),    // New: Input to indicate if other processor (P1) is in INIT state
		  .in_idle(in_idle),
        .in_init(in_init),
        .add(add),
        .A_en(A_en),
        .B_en(B_en),
        .C_en(C_en),
        .A_sel(A_sel),
        .AS_N(AS_N),
        .WR_N(WR_N),
        .busy(busy),
        .DINT_sel(DINT_sel),
        .GPR_WE(GPR_WE),
        .IR_en(IR_en),
        .MAR_en(MAR_en),
        .MDR_en(MDR_en),
        .MDR_sel(MDR_sel),
        .PC_en(PC_en),
        .Itype(Itype),
        .jlink(jlink),
        .mr(mr),
        .mw(mw),
        .right(right),
        .S1_sel(S1_sel),
        .S2_sel(S2_sel),
        .shift(shift),
        .stop_n(stop_n),
        .test(test),
        .DLX_STATE_OUT(DLX_STATE_OUT),
        .MAC_STATE_OUT(MAC_STATE_OUT),
        .trigger_P0(trigger_P0),     // New: SyncBox VALIDATE trigger
		  .req_P0(req_P0),
        .P0_mem_complete(P0_mem_complete), // New: Memory operation completion
        .atomic_inst(atomic_inst_P0),   // New: Debug flag for atomic instructions
        .R29_addr(R29_addr),        // New: R29 address for CHECK_WBA_29
        .R30_addr(R30_addr),        // New: R30 address for WBA_30
        .instr_type_P0(instr_type_P0) // New: Atomic instruction type
    );

    DLX_DATAPATH_TOP DLX_DATAPATH_TOP_1 (
        .clk(clk),
        .reset(reset),
        .IR_en(IR_en),
        .A_en(A_en),
        .B_en(B_en),
        .C_en(C_en),
        .S1_SEL(S1_sel),
        .S2_SEL(S2_sel),
        .add(add),
        .test(test),
        .right(right),
        .shift(shift),
        .DI(DI),
        .MDR_en(MDR_en),
        .MAR_en(MAR_en),
        .A_MUX_SEL(A_sel),
        .GPR_WE(GPR_WE),
        .PC_en(PC_en),
        .D_ADR(D_ADR),
        .DINT_MUX_SEL(DINT_sel),
        .MDR_MUX_SEL(MDR_sel),
        .AO(AO),
        .DO(DO),
        .OVF(OVF),
        .GPR_D(GPR_D),
		  .P0_success(P0_success),
        .IR(IR),
        .ram_adr_sel(ram_adr_sel),
        .AEQZ_OUT(AEQZ),
		  .MAR_OUT(MAR_OUT)
    );
        assign ram_adr_sel = {R30_addr, R29_addr};
endmodule
