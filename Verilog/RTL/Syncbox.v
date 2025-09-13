`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:33:50 07/22/2025 
// Design Name: 
// Module Name:    Syncbox 
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
module Syncbox (
    input clk,
    input reset,
    input trigger_P0,
    input trigger_P1,
    input req_P0,
    input req_P1,
    input P0_mem_complete,
    input P1_mem_complete,
	 input atomic_inst_P0,
	 input atomic_inst_P1,
    input [31:0] MAR_P0,
    input [31:0] MAR_P1,
    input [1:0] instr_type_P0, // 00=LR, 01=SC, 10=AMOADD, 11=SWAP
    input [1:0] instr_type_P1, // 00=LR, 01=SC, 10=AMOADD, 11=SWAP
    output P0_success,
    output P1_success,
    output P0_pass,
    output P1_pass,
	 output in_idle
);

// States
parameter IDLE = 3'b000, VALIDATE = 3'b001, P0_ONLY_WAIT = 3'b010, P1_ONLY_WAIT = 3'b011,
          BOTH_WAIT_P0 = 3'b101, BOTH_WAIT_P1 = 3'b110;

// Instruction types
parameter LR = 2'b00, SC = 2'b01, AMOADD = 2'b10, SWAP = 2'b11;

// Reservation table
reg [31:0] reservation_mar [0:1];
reg [0:0] reservation_valid [0:1];
reg [1:0] flag;
// Registers
reg [2:0] DLX_STATE;
reg P0_success_reg, P1_success_reg, P0_pass_reg, P1_pass_reg;
reg P0_success_new, P1_success_new;
reg valid_new_0, valid_new_1; // Combinatorial reservation valid signals

// Helper signal declarations
wire P0_is_lr, P1_is_lr, P0_is_mod, P1_is_mod, non_a;
wire P0_own_match, P1_own_match, P0_cross_match, P1_cross_match;

// Helper signal assignments
assign P0_is_lr = instr_type_P0 == LR;
assign P1_is_lr = instr_type_P1 == LR;
assign P0_is_mod = instr_type_P0 != LR;
assign P1_is_mod = instr_type_P1 != LR;
assign P0_own_match = (MAR_P0 == reservation_mar[0]) && reservation_valid[0];
assign P1_own_match = (MAR_P1 == reservation_mar[1]) && reservation_valid[1];
assign P0_cross_match = (MAR_P0 == reservation_mar[1]) && reservation_valid[1];
assign P1_cross_match = (MAR_P1 == reservation_mar[0]) && reservation_valid[0];
assign non_a=!atomic_inst_P0||!atomic_inst_P1;

always @(posedge clk) begin
    if (reset) begin
        DLX_STATE <= IDLE;
        reservation_valid[0] <= 0;
        reservation_valid[1] <= 0;
        reservation_mar[0] <= 0;
        reservation_mar[1] <= 0;
        P0_success_reg <= 0;
        P1_success_reg <= 0;
        P0_pass_reg <= 0;
        P1_pass_reg <= 0;
        P0_success_new = 0;
        P1_success_new = 0;
    end else begin
        case (DLX_STATE)
            IDLE: begin
               
                DLX_STATE <= (trigger_P0 || trigger_P1) ? VALIDATE : IDLE;
            end

            VALIDATE: begin
				    P0_pass_reg <= 0;
                P1_pass_reg <= 0;
                P0_success_new = 0;
                P1_success_new = 0;
				
                valid_new_0 = reservation_valid[0];
                valid_new_1 = reservation_valid[1];
                					 
	 
                if (req_P0 && req_P1) begin
					     if(!atomic_inst_P0) begin
					        P0_success_new = 0;
						     valid_new_0 = 0;
					     end
						  if(!atomic_inst_P1) begin
					        P1_success_new = 0;
                       valid_new_1 = 0;
					     end
						 if (atomic_inst_P0 && atomic_inst_P1)
						 begin
                    if (MAR_P0 == MAR_P1) begin
                        if (P0_is_lr && P1_is_lr) begin
                            P0_success_new = 1;
                            P1_success_new = 1;
                            reservation_mar[0] <= MAR_P0; valid_new_0 = 1;
                            reservation_mar[1] <= MAR_P1; valid_new_1 = 1;  
                        end else if (P0_is_lr) begin
                            P0_success_new = 1;
                            reservation_mar[0] <= MAR_P0; valid_new_0 = 1;
                        end else if (P1_is_lr) begin
                            P1_success_new = 1;
                            reservation_mar[1] <= MAR_P1; valid_new_1 = 1;
                        end else begin
                            P0_success_new = (instr_type_P0 == SC) ? P0_own_match : 1;
                            valid_new_0 = P0_own_match ? 0 : valid_new_0;
                            valid_new_1 = P0_cross_match ? 0 : valid_new_1;
                        end
                    end else begin 
						      
                        if (P0_is_lr) begin
                            P0_success_new = 1; reservation_mar[0] <= MAR_P0; valid_new_0 = 1;
                        end else if (instr_type_P0 == SC) begin
                            P0_success_new = P0_own_match;
                            valid_new_0 = P0_own_match ? 0 : valid_new_0;
									 
                        end else begin
                            P0_success_new = 1;
                            valid_new_0 = P0_own_match ? 0 : valid_new_0;
                            valid_new_1 = P0_cross_match ? 0 : valid_new_1;
									
								
								
                        end

                        if (P1_is_lr) begin
                            P1_success_new = 1; reservation_mar[1] <= MAR_P1; valid_new_1 = 1;
                        end else if (instr_type_P1 == SC) begin
                            P1_success_new = P1_own_match;
                            valid_new_1 = P1_own_match ? 0 : valid_new_1; 
                       								 
                        end else begin
                            P1_success_new = 1;
                            valid_new_1 = P1_own_match ? 0 : valid_new_1; 
                            valid_new_0 = P1_cross_match ? 0 : valid_new_0;
                        end
                    end
						 end
                end else if (req_P0) begin
					     if(!atomic_inst_P0)begin
						     P0_success_new = 1;
							  valid_new_0=0;
							  valid_new_1=0;
						  end
                    else if (P0_is_lr) begin
                        P0_success_new = 1; reservation_mar[0] <= MAR_P0; valid_new_0 = 1;
                    end else begin
                        P0_success_new = (instr_type_P0 == SC) ? P0_own_match : 1;
                        valid_new_0 = P0_own_match ? 0 : valid_new_0;
                        valid_new_1 = P0_cross_match ? 0 : valid_new_1;
                    end
                end else if (req_P1) begin
					 if(!atomic_inst_P1)begin
						     P1_success_new = 1;
							  valid_new_0=0;
							  valid_new_1=0;
						  end
                    else if (P1_is_lr) begin
                        P1_success_new = 1; reservation_mar[1] <= MAR_P1; valid_new_1 = 1;
                    end else begin
                        P1_success_new = (instr_type_P1 == SC) ? P1_own_match : 1;
                        valid_new_1 = P1_own_match ? 0 : valid_new_1;
                        valid_new_0 = P1_cross_match ? 0 : valid_new_0;
                    end
                end

                reservation_valid[0] <= valid_new_0;
                reservation_valid[1] <= valid_new_1;

                P0_success_reg <= P0_success_new;
                P1_success_reg <= P1_success_new;

                if (P0_success_new && !P1_success_new) begin
                    DLX_STATE <= P0_ONLY_WAIT; P0_pass_reg <= 1; P1_pass_reg <= 0;
                end else if (!P0_success_new && P1_success_new) begin
                    DLX_STATE <= P1_ONLY_WAIT; P0_pass_reg <= 0; P1_pass_reg <= 1;
                end else if (P0_success_new && P1_success_new) begin
                    DLX_STATE <= BOTH_WAIT_P0; P0_pass_reg <= 1; P1_pass_reg <= 0;
                end else begin
                    DLX_STATE <= IDLE; P0_pass_reg <= 0; P1_pass_reg <= 0;
                end
            end

            P0_ONLY_WAIT: if (P0_mem_complete) begin DLX_STATE <= IDLE; P0_pass_reg <= 0; end
            P1_ONLY_WAIT: if (P1_mem_complete) begin DLX_STATE <= IDLE; P1_pass_reg <= 0; end
            BOTH_WAIT_P0: if (P0_mem_complete) begin DLX_STATE <= BOTH_WAIT_P1; P0_pass_reg <= 0; P1_pass_reg <= 1; end
            BOTH_WAIT_P1: if (P1_mem_complete) begin DLX_STATE <= IDLE; P1_pass_reg <= 0; end
            default: begin DLX_STATE <= IDLE; P0_success_reg <= 0; P1_success_reg <= 0; P0_pass_reg <= 0; P1_pass_reg <= 0; end
        endcase
    end
end

assign P0_success = P0_success_reg;
assign P1_success = P1_success_reg;
assign P0_pass = P0_pass_reg;
assign P1_pass = P1_pass_reg;
assign in_idle = DLX_STATE == IDLE;
endmodule 