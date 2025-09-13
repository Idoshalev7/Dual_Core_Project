`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:48:27 01/04/2025 
// Design Name: 
// Module Name:    DLX_CONTROL_STATE_MACHINE 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Updated for atomic instructions (LR, SC, SWAP, AMOADD) using I-Type format
//
//////////////////////////////////////////////////////////////////////////////////
module DLX_CONTROL_STATE_MACHINE (
    input  clk,
    input  reset,
    input  AEQZ,
    input  step_en,
    input  busy,
    input  [31:0] IR,
    input  P0_pass,              // SyncBox memory access grant
    input  P0_success,           // SyncBox reservation/arbitration result
    input  P1_in_init,           // Input to indicate if other processor (P1) is in INIT state
	 input  in_idle,
    output in_init,
    output mr,
    output mw,
    output add,
    output A_en,
    output B_en,
    output C_en,
    output IR_en,
    output PC_en,
    output MDR_en,
    output MAR_en,
    output MDR_sel,
    output A_sel,
    output DINT_sel,
    output test,
    output Itype,
    output shift,
    output right,
    output jlink,
    output GPR_WE,
    output [1:0] S1_sel,
    output [1:0] S2_sel,
    output [4:0] DLX_STATE_OUT,
    output [1:0] instr_type_P0,  // Atomic instruction type
    output trigger_P0,           // SyncBox VALIDATE trigger
    output req_P0,
	 output P0_mem_complete,      // Memory operation completion
    output atomic_inst,          // Debug flag for atomic instructions (replaces req_P0)
    output R29_addr,             // R32 address for CHECK_WBA_32
    output R30_addr              // R33 address for WBA_33
);

    wire BRANCH_TAKEN;

    // State parameters
    parameter INIT         = 5'b00000;
    parameter FETCH        = 5'b00001;
    parameter DECODE       = 5'b00010;
    parameter HALT         = 5'b00011;
    parameter ALU          = 5'b00100;
    parameter SHIFT        = 5'b00101;
    parameter WBR          = 5'b00110;
    parameter ALUI         = 5'b00111;
    parameter WBI          = 5'b01000;
    parameter TESTI        = 5'b01001;
    parameter ADDRESSCMP   = 5'b01010;
    parameter LOAD         = 5'b01011;
    parameter COPYMDR2C    = 5'b01100;
    parameter COPYGPR2MDR  = 5'b01101;
    parameter STORE        = 5'b01110;
    parameter JR           = 5'b01111;
    parameter SAVEPC       = 5'b10000;
    parameter JALR         = 5'b10001;
    parameter BRANCH       = 5'b10010;
    parameter BTAKEN       = 5'b10011;
    parameter CHECK_WBA_32 = 5'b10100; // New: Validate SyncBox
    parameter ADO          = 5'b10101; // New: AMOADD addition
    parameter WBA          = 5'b10110; // New: Writeback for LR/SWAP
    parameter WBA_33       = 5'b10111; // New: Writeback for AMOADD R33

    reg [4:0] DLX_STATE;
    reg [1:0] instr_type_reg; // Register to hold instr_type_P0
    reg       atomic_inst_reg; // Register to hold atomic_inst
    reg       P0_mem_complete_reg; // Register to hold P0_mem_complete
	 reg       req_P0_reg;

    // Unified state machine and register updates
    always @(posedge clk) begin
        if (reset) begin
            DLX_STATE          <= INIT;
            instr_type_reg     <= 2'b00;
            atomic_inst_reg    <= 1'b0;
            P0_mem_complete_reg <= 1'b0;
				req_P0_reg <= 1'b0;
        end
        else begin
            // Update instr_type_reg and atomic_inst_reg
            if (DLX_STATE == DECODE) begin
				    req_P0_reg <= 1'b0;
				
                case (IR[31:26])
                    6'b100100: begin // LR
                        instr_type_reg <= 2'b00;
                        atomic_inst_reg <= 1'b1;
                    end
                    6'b101100: begin // SC
                        instr_type_reg <= 2'b01;
                        atomic_inst_reg <= 1'b1;
                    end
                    6'b101101: begin // SWAP
                        instr_type_reg <= 2'b11;
                        atomic_inst_reg <= 1'b1;
                    end
                    6'b101110: begin // AMOADD
                        instr_type_reg <= 2'b10;
                        atomic_inst_reg <= 1'b1;
                    end
                    default: begin
                        instr_type_reg <= 2'b00;
                        atomic_inst_reg <= 1'b0;
                    end
                endcase
            end

            // Initialize P0_mem_complete_reg in ADDRESSCMP
            if (DLX_STATE == ADDRESSCMP) begin
                P0_mem_complete_reg <= 1'b0;
					 
					 
					 req_P0_reg <= 1'b1;
					  
            end
            // Update P0_mem_complete_reg for atomic memory operations
            else if ((DLX_STATE == LOAD && instr_type_reg == 2'b00 && P0_pass && ~busy) || // LR
                     (DLX_STATE == STORE && instr_type_reg == 2'b01 && P0_pass && ~busy) || // SC
                     (DLX_STATE == STORE && instr_type_reg == 2'b11 && P0_pass && ~busy) || // SWAP
                     (DLX_STATE == STORE && instr_type_reg == 2'b10 && P0_pass && ~busy)) begin // AMOADD
                P0_mem_complete_reg <= 1'b1;
            end

            // State transitions
            case (DLX_STATE)
                INIT:
                    if (step_en && P1_in_init && in_idle)
                        DLX_STATE <= FETCH;
                    else 
                        DLX_STATE <= INIT;
                
                FETCH:
                    if (~busy)
                        DLX_STATE <= DECODE;
                    else 
                        DLX_STATE <= FETCH;
                
                DECODE:
                    if (IR[31:29] == 3'b110) // Special NOP
                        DLX_STATE <= INIT;
                    else if (IR[31:28] == 4'b0000 && IR[5] == 1'b1) // D2: ALU, R-TYPE OPERATION
                        DLX_STATE <= ALU;
                    else if (IR[31:28] == 4'b0000 && IR[5] == 1'b0) // D4: SHIFT, R-TYPE OPERATION
                        DLX_STATE <= SHIFT;
                    else if (IR[31:29] == 3'b001) // D5: ALUI (ADDI)
                        DLX_STATE <= ALUI;
                    else if (IR[31:29] == 3'b011) // D6: TESTI
                        DLX_STATE <= TESTI;
                    else if (IR[31:30] == 2'b10) // D7: ADR.COMP (LOAD or STORE or Atomic OPERATION)
                        DLX_STATE <= ADDRESSCMP;
                    else if (IR[31:29] == 3'b010 && IR[26] == 1'b0) // D8: JR
                        DLX_STATE <= JR;
                    else if (IR[31:29] == 3'b010 && IR[26] == 1'b1) // D9: SAVEPC
                        DLX_STATE <= SAVEPC;
                    else if (IR[31:28] == 4'b0001) // D12: BRANCH
                        DLX_STATE <= BRANCH;
                    else
                        DLX_STATE <= HALT;
                
                ALU:
                    DLX_STATE <= WBR;
                
                SHIFT:
                    DLX_STATE <= WBR;
                
                ALUI:
                    DLX_STATE <= WBI;
                
                TESTI:
                    DLX_STATE <= WBI;
                
                ADDRESSCMP:
                    if (IR[31:26] == 6'b100100) begin // LR
                        DLX_STATE <= LOAD;
                    end
                    else if (atomic_inst_reg == 1'b1) begin // SC, SWAP, AMOADD
                        DLX_STATE <= CHECK_WBA_32;
                    end
                    else if (IR[29] == 1'b0) begin // Non-atomic load (e.g., lw)
                        DLX_STATE <=CHECK_WBA_32;
                    end
                    else if (IR[29] == 1'b1) begin // Non-atomic store (e.g., sw)
                        DLX_STATE <=CHECK_WBA_32;
                    end
                    else begin
                        DLX_STATE <= INIT; // Default
                    end
                
                CHECK_WBA_32:
                    
                       case (IR[31:26])
                           6'b101100: DLX_STATE <= COPYGPR2MDR; // SC
                           6'b101101: DLX_STATE <= LOAD;        // SWAP
                           6'b101110: DLX_STATE <= LOAD;        // AMOADD
                           default: begin
                               if (IR[29] == 1'b0) begin // Non-atomic load (e.g., lw)
                                  DLX_STATE <= LOAD;
                               end
                               else if (IR[29] == 1'b1) begin // Non-atomic store (e.g., sw)
                                  DLX_STATE <= COPYGPR2MDR;
                               end
                           end
                      endcase
                   
                
                LOAD:
					   if(P0_success||atomic_inst_reg && instr_type_reg == 2'b00)
                    if (~busy && P0_pass)
                        case (IR[31:26])
                            6'b100011:   DLX_STATE <= COPYMDR2C; // LOAD (lw)
                            6'b100100:   DLX_STATE <= COPYMDR2C; // LR
                            6'b101101:   DLX_STATE <= COPYMDR2C; // SWAP
                            6'b101110:   DLX_STATE <= ADO;       // AMOADD (bypass COPYMDR2C)
                            default: DLX_STATE <= INIT;
                        endcase
                    else 
                        DLX_STATE <= LOAD;
                 else DLX_STATE <= INIT;
                COPYMDR2C:
                    case (IR[31:26])
                        6'b100011: DLX_STATE <= WBI;        // LOAD
                        6'b100100: DLX_STATE <= WBA;        // LR
                        6'b101101: DLX_STATE <= COPYGPR2MDR; // SWAP
								6'b101110: DLX_STATE <= STORE ; // AMOADD
                        default: DLX_STATE <= INIT;
                    endcase
                
                ADO:
                    DLX_STATE <= COPYMDR2C; // AMOADD proceeds to store the result
                
                COPYGPR2MDR:
                    case (IR[31:26])
                        6'b101011: DLX_STATE <= STORE; // STORE
                        6'b101100: DLX_STATE <= STORE; // SC
                        6'b101101: DLX_STATE <= STORE; // SWAP
                        default: DLX_STATE <= INIT;
                    endcase
                
                STORE:
                 if(P0_success)
                    if (~busy && P0_pass)
                        if (IR[31:26] == 6'b101110) // AMOADD
                            DLX_STATE <= WBA_33;     // Write AMOADD result to R33
                        else if (IR[31:26] == 6'b101101) // SWAP
                            DLX_STATE <= WBA;        // Write original memory value to R(RS2)
                        else
                            DLX_STATE <= INIT;       // Default to INIT for non-atomic or other atomic stores
                    else 
                        DLX_STATE <= STORE;
								
                 else DLX_STATE <= INIT;
                
                WBA:
                    DLX_STATE <= INIT; // Simplified from if-else
                
                WBA_33:
                    DLX_STATE <= INIT; // Simplified from if-else
                
                SAVEPC: 
                    DLX_STATE <= JALR;
                
                BRANCH:
                    if (BRANCH_TAKEN)
                        DLX_STATE <= BTAKEN;
                    else 
                        DLX_STATE <= INIT;
                
                WBR:
                    DLX_STATE <= INIT; // Simplified from if-else
					 WBI:
				
				    if(step_en)
				      begin
				      DLX_STATE <= FETCH ;
				      end
			    	else 
			   	   begin 
			   	   DLX_STATE <= INIT;
				      end
                
                BTAKEN:
                    DLX_STATE <= INIT; // Simplified from if-else
                
                JALR:
                    DLX_STATE <= INIT; // Simplified from if-else
                
                JR:
                    DLX_STATE <= INIT; // Simplified from if-else
                
                HALT:
                    if (reset)
                        DLX_STATE <= INIT;
                    else 
                        DLX_STATE <= HALT;
                
                default:
                    DLX_STATE <= INIT;
            endcase
        end
    end
    
    // Control signal assignments
    assign S1_sel[0] = DLX_STATE == ALU || DLX_STATE == TESTI || DLX_STATE == ALUI || 
                       DLX_STATE == SHIFT || DLX_STATE == ADDRESSCMP || DLX_STATE == COPYMDR2C ||
                       DLX_STATE == JR || DLX_STATE == JALR || DLX_STATE == ADO; // Updated: Added ADO
    assign S1_sel[1] = DLX_STATE == COPYMDR2C || DLX_STATE == COPYGPR2MDR || DLX_STATE == ADO; // Updated: Added ADO for MDR selection (S1_sel = 2'b11)
    assign S2_sel[0] = DLX_STATE == DECODE || DLX_STATE == TESTI || DLX_STATE == ALUI || 
                       DLX_STATE == ADDRESSCMP || DLX_STATE == BTAKEN; // Updated: Removed ADO to ensure S2_sel = 2'b00 in ADO for B (RD) selection
    assign S2_sel[1] = DLX_STATE == DECODE || DLX_STATE == COPYMDR2C || DLX_STATE == COPYGPR2MDR || 
                       DLX_STATE == JR || DLX_STATE == JALR || DLX_STATE == SAVEPC; // Updated: Ensured S2_sel[1] = 0 in ADO to select B (RD)
    assign in_init = DLX_STATE == INIT || DLX_STATE == HALT;
    assign IR_en = DLX_STATE == FETCH;
    assign PC_en = DLX_STATE == DECODE || DLX_STATE == BTAKEN || DLX_STATE == JR || DLX_STATE == JALR;
    assign add = DLX_STATE == DECODE || DLX_STATE == BTAKEN || DLX_STATE == JR || DLX_STATE == JALR || 
                 DLX_STATE == SAVEPC || DLX_STATE == ALUI || DLX_STATE == ADDRESSCMP || DLX_STATE == ADO; // Updated: Added ADO for AMOADD addition
    assign A_en = DLX_STATE == DECODE;
    assign B_en = DLX_STATE == DECODE; // Updated: Reads RD (IR[20:16]) for all atomic instructions in DECODE, handled in datapath per I-Type format
    assign C_en = (DLX_STATE == ALU || DLX_STATE == TESTI || DLX_STATE == ALUI || DLX_STATE == SHIFT || 
                   DLX_STATE == SAVEPC || DLX_STATE == COPYMDR2C) || 
                  (DLX_STATE == ADO); // Updated: Simplified C_en = 1 for ADO (AMOADD only) since state transition ensures it
    assign mr = (DLX_STATE == FETCH || 
                 (DLX_STATE == LOAD && ((IR[31:26] == 6'b100011 || atomic_inst_reg) && P0_pass))) ? 1'b1 : 1'b0; // Updated: Removed busy and sw from gating, applied P0_pass only to atomic instructions
    assign mw = (DLX_STATE == STORE && 
                 (IR[31:26] == 6'b101011 || (atomic_inst_reg && P0_pass))) ? 1'b1 : 1'b0; // Updated: Removed busy and lw from gating, applied P0_pass only to atomic instructions
    assign MAR_en = DLX_STATE == ADDRESSCMP;
    assign MDR_en = (DLX_STATE == LOAD && ~busy) || DLX_STATE == COPYGPR2MDR || DLX_STATE == ADO; // Updated: Added ADO for AMOADD result
    assign MDR_sel = DLX_STATE == LOAD;
    assign test = DLX_STATE == TESTI;
    assign Itype = DLX_STATE == TESTI || DLX_STATE == ALUI || DLX_STATE == WBI;
    assign shift = DLX_STATE == SHIFT;
    assign right = DLX_STATE == SHIFT && IR[1] == 1'b1;
    assign A_sel = DLX_STATE == STORE || DLX_STATE == LOAD;
    assign DINT_sel = DLX_STATE == SHIFT || DLX_STATE == COPYGPR2MDR || DLX_STATE == COPYMDR2C;
    assign jlink = DLX_STATE == JALR;
    assign GPR_WE = DLX_STATE == JALR || DLX_STATE == WBI || DLX_STATE == WBR || R29_addr || DLX_STATE == WBA || DLX_STATE == WBA_33; // Updated: Added CHECK_WBA_32, WBA, WBA_33 for R32, RD, R33 writes
    assign BRANCH_TAKEN = AEQZ ^ IR[26];
    assign DLX_STATE_OUT = DLX_STATE;
    assign instr_type_P0 = instr_type_reg; // Updated: New signal for atomic instruction type
    assign req_P0 = req_P0_reg; // Updated: New signal for SyncBox VALIDATE
	 assign trigger_P0 = DLX_STATE == ADDRESSCMP;
    assign P0_mem_complete = P0_mem_complete_reg; // Updated: Output tied to register, non-combinatorial for SyncBox stability, set with P0_pass && ~busy, cleared only in ADDRESSCMP
    assign atomic_inst = atomic_inst_reg; // Updated: Debug flag for atomic instructions
    assign R29_addr = (DLX_STATE == LOAD && !(atomic_inst && instr_type_P0==2'b00))||(DLX_STATE == COPYGPR2MDR)? 1'b1 : 1'b0; // Updated: New signal for R32 write address
    assign R30_addr = DLX_STATE == WBA_33 ? 1'b1 : 1'b0; // Updated: New signal for R33 write address

endmodule 