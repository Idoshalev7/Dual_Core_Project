`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:55:36 08/26/2025 
// Design Name: 
// Module Name:    Dual_Core_Top_io_sim 
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
module Dual_Core_Top_io_sim(
    input CLK_IN,
    input RST,
	 input PC_step_en,
    
    output AS_N,
	 output WR_N,
	 output [31:0] AO,
	 output [31:0] DO,
   
  
	 

	 
	 output PA_success,          // Syncbox: Success flag for P0
    output PB_success,          // Syncbox: Success flag for P1 (ignored for now)
    output PA_pass,             // Syncbox: Pass flag for P0
    output PB_pass ,             // Syncbox: Pass flag for P1 (ignored for now)
	 output in_idle
	 
	 
	 
	 
	 
	 
	 );

   
	
	
	
	wire clk;
	wire reset;
	wire ACK_N;
	wire step_en;
	wire [31:0] D_IN;


	IO_SIM #(.ADDR_WIDTH(10)) io_sim (.CLK_IN(CLK_IN),.RST_IN(RST),.STEP_IN(PC_step_en),.AS_N(AS_N),
	.WR_N(WR_N),.MAO(AO),.MDO(DO),.CLK(clk),.RST(reset),.STEP(step_en),.ACK_N(ACK_N),.DO(D_IN));
	
	
	
	// Instantiate Dual_Core_Top
    Dual_Core_Top dual_core_inst (
    .clk(clk),            // Shared: Clock signal
    .reset(reset),        // Shared: Reset signal
    .step_en(step_en),    // DLX: Step enable for DLX_TOP
    .ACK_N(ACK_N),        // DLX: Acknowledge input for DLX_TOP
    .DI(D_IN),              // DLX: Data input for DLX_TOP
    .AS_N(AS_N),          // DLX: Address strobe output
    .WR_N(WR_N),          // DLX: Write enable output
    .AO(AO),              // DLX: Address output
    .DO(DO),              // DLX: Data output

    .PA_success(PA_success),  // Syncbox: Success flag for PA
    .PB_success(PB_success),  // Syncbox: Success flag for PB
    .PA_pass(PA_pass),        // Syncbox: Pass flag for PA
    .PB_pass(PB_pass),        // Syncbox: Pass flag for PB

    .in_idle(in_idle)         // Syncbox/DLX: Idle state indicator
);
endmodule
