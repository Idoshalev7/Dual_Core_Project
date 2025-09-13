`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:35:50 07/30/2025 
// Design Name: 
// Module Name:    DLX_CONTROL_TOP_PB 
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
module DLX_CONTROL_TOP_PB(
   input clk,
    input reset,
    input AEQZ,
    input step_en,
    input [31:0] IR,
    input ACK_N,
    input P0_pass,
    input P0_success,
    input P1_in_init,
	 input  in_idle,
    output in_init,
    output add,
    output A_en,
    output B_en,
    output C_en,
    output A_sel,
    output AS_N,
    output WR_N,
    output busy,
    output DINT_sel,
    output GPR_WE,
    output IR_en,
    output MAR_en,
    output MDR_en,
    output MDR_sel,
    output PC_en,
    output Itype,
    output jlink,
    output mr,
    output mw,
    output right,
    output [1:0] S1_sel,
    output [1:0] S2_sel,
    output shift,
    output stop_n,
    output test,
    output [4:0] DLX_STATE_OUT,
    output [1:0] MAC_STATE_OUT,
    output trigger_P0,
	 output req_P0,
    output P0_mem_complete,
    output atomic_inst,
    output R29_addr,
    output R30_addr,
    output [1:0] instr_type_P0
);

    wire stop_wire;
    reg stop_reg;
    wire IR_en_wire;

    // Instantiate MAC_STATE_MACHINE
    MAC_STATE_MACHINE MAC_STATE_MACHINE_PB (
        .clk(clk),
        .reset(reset),
        .ACK_N(ACK_N),
        .mr(mr),
        .mw(mw),
        .stop_n(stop_wire),
        .AS_N(AS_N),
        .WR_N(WR_N),
        .busy(busy),
        .MAC_STATE_OUT(MAC_STATE_OUT)
    );

    // Instantiate DLX_CONTROL_STATE_MACHINE
    DLX_CONTROL_STATE_MACHINE_PB DLX_CONTROL_STATE_MACHINE_PB_1 (
        .clk(clk),
        .reset(reset),
        .AEQZ(AEQZ),
        .step_en(step_en),
        .busy(busy),
        .IR(IR),
        .P0_pass(P0_pass),
        .P0_success(P0_success),
        .P1_in_init(P1_in_init),
		  .in_idle(in_idle),
        .in_init(in_init),
        .mr(mr),
        .mw(mw),
        .add(add),
        .A_en(A_en),
        .B_en(B_en),
        .C_en(C_en),
        .IR_en(IR_en_wire),
        .PC_en(PC_en),
        .MDR_en(MDR_en),
        .MAR_en(MAR_en),
        .MDR_sel(MDR_sel),
        .A_sel(A_sel),
        .DINT_sel(DINT_sel),
        .test(test),
        .Itype(Itype),
        .shift(shift),
        .right(right),
        .jlink(jlink),
        .GPR_WE(GPR_WE),
        .S1_sel(S1_sel),
        .S2_sel(S2_sel),
        .DLX_STATE_OUT(DLX_STATE_OUT),
        .instr_type_P0(instr_type_P0),
        .trigger_P0(trigger_P0),
		  .req_P0(req_P0),
        .P0_mem_complete(P0_mem_complete),
        .atomic_inst(atomic_inst),
        .R29_addr(R29_addr),
        .R30_addr(R30_addr)
    );

    // Logic for IR_en and stop_n
    assign IR_en = IR_en_wire && ((~ACK_N)||P1_in_init);

    always @(posedge clk)
        stop_reg <= stop_wire;

    assign stop_n = (stop_reg || stop_wire) || (~ACK_N);

endmodule
