`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:23:43 08/02/2025 
// Design Name: 
// Module Name:    Dual_Core_Top 
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
module Dual_Core_Top(
    input clk,                  // Shared: Clock signal
    input reset,                // Shared: Reset signal
    input step_en,              // DLX: Step enable for DLX_TOP
    input ACK_N,                // DLX: Acknowledge input for DLX_TOP
    input [4:0] D_ADR,          // DLX: Data address input for DLX_TOP
    input [31:0] DI,            // DLX: Data input for DLX_TOP
   
    output AS_N,
	 output WR_N,
	 output [31:0] AO,
	 output [31:0] DO,
	 output in_init,
	 output stop_n,
	 output [31:0] GPR_D,
	 




  	

	 
	 
	 output PA_success,          // Syncbox: Success flag for P0
    output PB_success,          // Syncbox: Success flag for P1 (ignored for now)
    output PA_pass,             // Syncbox: Pass flag for P0
    output PB_pass ,             // Syncbox: Pass flag for P1 (ignored for now)
	 output in_idle
);
 
     wire A_en_A;                // DLX: Address enable output from DLX_TOP
    wire A_sel_A;               // DLX: Address select output from DLX_TOP
    wire AEQZ_A;                // DLX: Zero flag output from DLX_TOP
    wire [2:0] ALUF_A;          // DLX: ALU function output from DLX_TOP
    wire [31:0] AO_A;           // DLX: ALU output from DLX_TOP
    wire AS_N_A;                // DLX: Address strobe output from DLX_TOP
    wire B_en_A;                // DLX: B enable output from DLX_TOP
    wire C_en_A;                // DLX: C enable output from DLX_TOP
    wire DINT_sel_A;            // DLX: Data integer select output from DLX_TOP
    wire [31:0] DO_A;           // DLX: Data output from DLX_TOP
    wire [31:0] GPR_D_A;        // DLX: General purpose register data output from DLX_TOP
    wire GPR_WE_A;              // DLX: General purpose register write enable from DLX_TOP
    wire [31:0] IR_A;           // DLX: Instruction register output from DLX_TOP
    wire IR_en_A;               // DLX: Instruction register enable from DLX_TOP
    wire Itype_A;               // DLX: Instruction type output from DLX_TOP
    wire MAR_en_A;              // DLX: Memory address register enable from DLX_TOP
    wire MDR_en_A;              // DLX: Memory data register enable from DLX_TOP
    wire MDR_sel_A;             // DLX: Memory data register select from DLX_TOP
    wire OVF_A;                 // DLX: Overflow flag from DLX_TOP
    wire PC_en_A;               // DLX: Program counter enable from DLX_TOP
    wire [1:0] S1_sel_A;        // DLX: Select 1 output from DLX_TOP
    wire [1:0] S2_sel_A;        // DLX: Select 2 output from DLX_TOP
    wire WR_N_A;                // DLX: Write enable output from DLX_TOP
    wire add_A;                 // DLX: Add operation output from DLX_TOP
    wire busy_A;                // DLX: Busy signal output from DLX_TOP
    wire in_init_A;             // DLX: Initialization flag from DLX_TOP
    wire jlink_A;               // DLX: Jump link output from DLX_TOP
    wire mr_A;                  // DLX: Memory read request from DLX_TOP
    wire mw_A;                  // DLX: Memory write request from DLX_TOP
    wire shift_A;               // DLX: Shift operation output from DLX_TOP
    wire stop_n_A;              // DLX: Stop signal output from DLX_TOP
    wire test_A;                // DLX: Test output from DLX_TOP
    wire [4:0] DLX_STATE_OUT_A; // DLX: DLX state output from DLX_TOP
    wire [1:0] MAC_STATE_OUT_A; // DLX: MAC state output from DLX_TOP
    wire trigger_PA;            // DLX: Trigger for Syncbox validation
    wire PA_mem_complete;     // DLX: Memory operation completion flag
    wire atomic_inst_PA;        // DLX: Atomic instruction flag
    wire R29_addr_A;            // DLX: R29 address output
    wire R30_addr_A;            // DLX: R30 address output
    wire [1:0] instr_type_PA;   // DLX: Instruction type for PA
	 
	 wire [31:0] MAR_OUT_A;
 
   



 	 wire A_en_B;                // DLX: Address enable output from DLX_TOP
    wire A_sel_B;               // DLX: Address select output from DLX_TOP
    wire AEQZ_B;                // DLX: Zero flag output from DLX_TOP
    wire [2:0] ALUF_B;          // DLX: ALU function output from DLX_TOP
    wire [31:0] AO_B;           // DLX: ALU output from DLX_TOP
    wire AS_N_B;                // DLX: Address strobe output from DLX_TOP
    wire B_en_B;                // DLX: B enable output from DLX_TOP
    wire C_en_B;                // DLX: C enable output from DLX_TOP
    wire DINT_sel_B;            // DLX: Data integer select output from DLX_TOP
    wire [31:0] DO_B;           // DLX: Data output from DLX_TOP
    wire [31:0] GPR_D_B;        // DLX: General purpose register data output from DLX_TOP
    wire GPR_WE_B;              // DLX: General purpose register write enable from DLX_TOP
    wire [31:0] IR_B;           // DLX: Instruction register output from DLX_TOP
    wire IR_en_B;               // DLX: Instruction register enable from DLX_TOP
    wire Itype_B;               // DLX: Instruction type output from DLX_TOP
    wire MAR_en_B;              // DLX: Memory address register enable from DLX_TOP
    wire MDR_en_B;              // DLX: Memory data register enable from DLX_TOP
    wire MDR_sel_B;             // DLX: Memory data register select from DLX_TOP
    wire OVF_B;                 // DLX: Overflow flag from DLX_TOP
    wire PC_en_B;               // DLX: Program counter enable from DLX_TOP
    wire [1:0] S1_sel_B;        // DLX: Select 1 output from DLX_TOP
    wire [1:0] S2_sel_B;        // DLX: Select 2 output from DLX_TOP
    wire WR_N_B;                // DLX: Write enable output from DLX_TOP
    wire add_B;                 // DLX: Add operation output from DLX_TOP
    wire busy_B;                // DLX: Busy signal output from DLX_TOP
    wire in_init_B;             // DLX: Initialization flag from DLX_TOP
    wire jlink_B;               // DLX: Jump link output from DLX_TOP
    wire mr_B;                  // DLX: Memory read request from DLX_TOP
    wire mw_B;                  // DLX: Memory write request from DLX_TOP
    wire shift_B;               // DLX: Shift operation output from DLX_TOP
    wire stop_n_B;              // DLX: Stop signal output from DLX_TOP
    wire test_B;                // DLX: Test output from DLX_TOP
    wire [4:0] DLX_STATE_OUT_B; // DLX: DLX state output from DLX_TOP
    wire [1:0] MAC_STATE_OUT_B; // DLX: MAC state output from DLX_TOP
    wire trigger_PB;            // DLX: Trigger for Syncbox validation
    wire PB_mem_complete;       // DLX: Memory operation completion flag
    wire atomic_inst_PB;        // DLX: Atomic instruction flag
    wire R29_addr_B;            // DLX: R29 address output
    wire R30_addr_B;            // DLX: R30 address output
    wire [1:0] instr_type_PB;   // DLX: Instruction type for P1
    wire [31:0] MAR_OUT_B; 
 
 
 

 
    wire bus_sel;               // wires relevant processor to outer bus
 
 
 
 
 
 
 
    // Instantiate Syncbox
    Syncbox syncbox_inst (
        .clk(clk),                  // Shared: Clock signal
        .reset(reset),              // Shared: Reset signal
        .trigger_P0(trigger_PA),    // DLX: Trigger for Syncbox validation
        .trigger_P1(trigger_PB),          // Syncbox: P1 trigger (ignored, set to 0)
        .req_P0(req_PA),                // Shared: Memory request from DLX_TOP as req_P0
        .req_P1(req_PB	),              // Syncbox: P1 request (ignored, set to 0)
        .P0_mem_complete(PA_mem_complete), // DLX: Memory operation completion flag
        .P1_mem_complete(PB_mem_complete),     // Syncbox: P1 memory complete (ignored, set to 0)
		  .atomic_inst_P0(atomic_inst_PA),
		  .atomic_inst_P1(atomic_inst_PB),
        .MAR_P0(MAR_OUT_A),            // Shared: Memory address register enable as MAR_P0
        .MAR_P1(MAR_OUT_B),              // Syncbox: P1 memory address (ignored, set to 0)
        .instr_type_P0(instr_type_PA), // DLX: Instruction type for P0
        .instr_type_P1(instr_type_PB),       // Syncbox: P1 instruction type (ignored, set to 0)
        .P0_success(PA_success),    // Shared: Success flag for P0
        .P1_success(PB_success),    // Syncbox: P1 success (ignored, left unconnected in practice)
        .P0_pass(PA_pass),          // Shared: Pass flag for P0
        .P1_pass(PB_pass),           // Syncbox: P1 pass (ignored, left unconnected in practice)
		  .in_idle(in_idle)
    );






    
	 // Instantiate DLX_TOP (Processor PA)
DLX_TOP dlx_top_inst_pa (
        .clk(clk),                    // Shared: Clock signal
        .reset(reset),                // Shared: Reset signal
        .step_en(step_en),            // DLX: Step enable for DLX_TOP
        .ACK_N(ACK_N),                // DLX: Acknowledge input for DLX_TOP
        .D_ADR(D_ADR),                // DLX: Data address input for DLX_TOP
        .DI(DI),                      // DLX: Data input for DLX_TOP
        .P0_pass(PA_pass),            // Shared: Pass flag for PA
        .P0_success(PA_success),      // Shared: Success flag for PA
        .P1_in_init(in_init_B),       
        .in_idle(in_idle),
        .A_en(A_en_A),                // DLX: Address enable output from DLX_TOP
        .A_sel(A_sel_A),              // DLX: Address select output from DLX_TOP
        .AEQZ(AEQZ_A),                // DLX: Zero flag output from DLX_TOP
        .ALUF(ALUF_A),                // DLX: ALU function output from DLX_TOP
        .AO(AO_A),                    // DLX: ALU output from DLX_TOP
        .AS_N(AS_N_A),                // DLX: Address strobe output from DLX_TOP
        .B_en(B_en_A),                // DLX: B enable output from DLX_TOP
        .C_en(C_en_A),                // DLX: C enable output from DLX_TOP
        .DINT_sel(DINT_sel_A),        // DLX: Data integer select output from DLX_TOP
        .DO(DO_A),                    // DLX: Data output from DLX_TOP
        .GPR_D(GPR_D_A),              // DLX: General purpose register data output from DLX_TOP
        .GPR_WE(GPR_WE_A),            // DLX: General purpose register write enable from DLX_TOP
        .IR(IR_A),                    // DLX: Instruction register output from DLX_TOP
        .IR_en(IR_en_A),              // DLX: Instruction register enable from DLX_TOP
        .Itype(Itype_A),              // DLX: Instruction type output from DLX_TOP
        .MAR_en(MAR_en_A),            // DLX: Memory address register enable from DLX_TOP
        .MDR_en(MDR_en_A),            // DLX: Memory data register enable from DLX_TOP
        .MDR_sel(MDR_sel_A),          // DLX: Memory data register select from DLX_TOP
        .OVF(OVF_A),                  // DLX: Overflow flag from DLX_TOP
        .PC_en(PC_en_A),              // DLX: Program counter enable from DLX_TOP
        .S1_sel(S1_sel_A),            // DLX: Select 1 output from DLX_TOP
        .S2_sel(S2_sel_A),            // DLX: Select 2 output from DLX_TOP
        .WR_N(WR_N_A),                // DLX: Write enable output from DLX_TOP
        .add(add_A),                  // DLX: Add operation output from DLX_TOP
        .busy(busy_A),                // DLX: Busy signal output from DLX_TOP
        .in_init(in_init_A),          // DLX: Initialization flag from DLX_TOP
        .jlink(jlink_A),              // DLX: Jump link output from DLX_TOP
        .mr(mr_A),                    // DLX: Memory read request from DLX_TOP
        .mw(mw_A),                    // DLX: Memory write request from DLX_TOP
        .shift(shift_A),              // DLX: Shift operation output from DLX_TOP
        .stop_n(stop_n_A),            // DLX: Stop signal output from DLX_TOP
        .test(test_A),                // DLX: Test output from DLX_TOP
        .DLX_STATE_OUT(DLX_STATE_OUT_A), // DLX: DLX state output from DLX_TOP
        .MAC_STATE_OUT(MAC_STATE_OUT_A), // DLX: MAC state output from DLX_TOP
        .MAR_OUT(MAR_OUT_A),
        .trigger_P0(trigger_PA),      // DLX: Trigger for Syncbox validation
        .req_P0(req_PA),
        .P0_mem_complete(PA_mem_complete), // DLX: Memory operation completion flag
        .atomic_inst_P0(atomic_inst_PA),   // DLX: Atomic instruction flag
        .R29_addr(R29_addr_A),        // DLX: R29 address output
        .R30_addr(R30_addr_A),        // DLX: R30 address output
        .instr_type_P0(instr_type_PA) // DLX: Instruction type for P0
    );
	 
	 
	 
	 
	 
	 
	 // Instantiate DLX_TOP (Processor PB)
    DLX_TOP_PB dlx_top_inst_pb (
        .clk(clk),                    // Shared: Clock signal
        .reset(reset),                // Shared: Reset signal
        .step_en(step_en),            // DLX: Step enable for DLX_TOP
        .ACK_N(ACK_N),                // DLX: Acknowledge input for DLX_TOP
        .D_ADR(D_ADR),                // DLX: Data address input for DLX_TOP
        .DI(DI),                      // DLX: Data input for DLX_TOP
		  .P0_pass(PB_pass),          // Shared: Pass flag for PB
        .P0_success(PB_success),    // Shared: Success flag for PB
		  .P1_in_init(in_init_A),       
		  .in_idle(in_idle),
        .A_en(A_en_B),                // DLX: Address enable output from DLX_TOP
        .A_sel(A_sel_B),              // DLX: Address select output from DLX_TOP
        .AEQZ(AEQZ_B),                // DLX: Zero flag output from DLX_TOP
        .ALUF(ALUF_B),                // DLX: ALU function output from DLX_TOP
        .AO(AO_B),                    // DLX: ALU output from DLX_TOP
        .AS_N(AS_N_B),                // DLX: Address strobe output from DLX_TOP
        .B_en(B_en_B),                // DLX: B enable output from DLX_TOP
        .C_en(C_en_B),                // DLX: C enable output from DLX_TOP
        .DINT_sel(DINT_sel_B),        // DLX: Data integer select output from DLX_TOP
        .DO(DO_B),                    // DLX: Data output from DLX_TOP
        .GPR_D(GPR_D_B),              // DLX: General purpose register data output from DLX_TOP
        .GPR_WE(GPR_WE_B),            // DLX: General purpose register write enable from DLX_TOP
        .IR(IR_B),                    // DLX: Instruction register output from DLX_TOP
        .IR_en(IR_en_B),              // DLX: Instruction register enable from DLX_TOP
        .Itype(Itype_B),              // DLX: Instruction type output from DLX_TOP
        .MAR_en(MAR_en_B),            // DLX: Memory address register enable from DLX_TOP
        .MDR_en(MDR_en_B),            // DLX: Memory data register enable from DLX_TOP
        .MDR_sel(MDR_sel_B),          // DLX: Memory data register select from DLX_TOP
        .OVF(OVF_B),                  // DLX: Overflow flag from DLX_TOP
        .PC_en(PC_en_B),              // DLX: Program counter enable from DLX_TOP
        .S1_sel(S1_sel_B),            // DLX: Select 1 output from DLX_TOP
        .S2_sel(S2_sel_B),            // DLX: Select 2 output from DLX_TOP
        .WR_N(WR_N_B),                // DLX: Write enable output from DLX_TOP
        .add(add_B),                  // DLX: Add operation output from DLX_TOP
        .busy(busy_B),                // DLX: Busy signal output from DLX_TOP
        .in_init(in_init_B),          // DLX: Initialization flag from DLX_TOP
        .jlink(jlink_B),              // DLX: Jump link output from DLX_TOP
        .mr(mr_B),                    // DLX: Memory read request from DLX_TOP
        .mw(mw_B),                    // DLX: Memory write request from DLX_TOP
        .shift(shift_B),              // DLX: Shift operation output from DLX_TOP
        .stop_n(stop_n_B),            // DLX: Stop signal output from DLX_TOP
        .test(test_B),                // DLX: Test output from DLX_TOP
        .DLX_STATE_OUT(DLX_STATE_OUT_B), // DLX: DLX state output from DLX_TOP
        .MAC_STATE_OUT(MAC_STATE_OUT_B), // DLX: MAC state output from DLX_TOP
		  .MAR_OUT(MAR_OUT_B),
        .trigger_P0(trigger_PB),      // DLX: Trigger for Syncbox validation
		  .req_P0(req_PB),
        .P0_mem_complete(PB_mem_complete), // DLX: Memory operation completion flag
        .atomic_inst_P0(atomic_inst_PB),   // DLX: Atomic instruction flag
        .R29_addr(R29_addr_B),        // DLX: R29 address output
        .R30_addr(R30_addr_B),        // DLX: R30 address output
        .instr_type_P0(instr_type_PB) // DLX: Instruction type for PB
    );
	 
	     assign bus_sel = DLX_STATE_OUT_A!=5'b00001 && DLX_STATE_OUT_A!=5'b00010 && PB_success && PB_pass;
		 
  		  assign AO = bus_sel? AO_B : AO_A;
		  assign DO = bus_sel? DO_B : DO_A;
		  assign AS_N = bus_sel? AS_N_B : AS_N_A;
		  assign WR_N = bus_sel? WR_N_B : WR_N_A;
		  assign GPR_D = GPR_D_A;
		  
		  assign in_init=in_init_A && in_init_B && in_idle;
		  
		   assign stop_n=stop_n_A && stop_n_B;
		  endmodule 