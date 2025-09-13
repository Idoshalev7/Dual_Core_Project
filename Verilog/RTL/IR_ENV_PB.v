`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:46:09 07/30/2025 
// Design Name: 
// Module Name:    IR_ENV_PB 
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
module IR_ENV_PB(
     input clk,
    input IR_en,
	 input [31:0] PC,
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
	
	 wire [31:0] rom [0:63]; // 32 entries (enough space for code + padding)
	 


// ---------------- Instructions ----------------
assign rom[0]  = 32'hFC000000; // lr     R1,  R0, data3      * a1
assign rom[1]  = 32'h90020028; // lr     R2,  R0, data4      * a2
assign rom[2]  = 32'h90030029; // lr     R3,  R0, data5      * b11 (col1 top)
assign rom[3]  = 32'h9004002A; // lr     R4,  R0, data6      * b21 (col1 bottom)
assign rom[4]  = 32'h9005002B; // lr     R5,  R0, data7      * b12 (col2 top)
assign rom[5]  = 32'h9006002C; // lr     R6,  R0, data8      * b22 (col2 bottom)

assign rom[6]  = 32'h00003823; // add    R7,  R0, R0         * prod1 = 0
assign rom[7]  = 32'h00034023; // add    R8,  R0, R3         * counter = b11
assign rom[8]  = 32'h111F0004; // beqz   R8,  +4             * skip if b11 == 0
assign rom[9]  = 32'h00E13823; // add    R7,  R7, R1         * accumulate a1
assign rom[10] = 32'h2D08FFFF; // addi   R8,  R8, -1         * dec counter
assign rom[11] = 32'h151FFFFD; // bnez   R8,  -3             * loop

assign rom[12] = 32'h00004823; // add    R9,  R0, R0         * prod2 = 0
assign rom[13] = 32'h00045023; // add    R10, R0, R4         * counter = b21
assign rom[14] = 32'h115F0004; // beqz   R10, +4             * skip if b21 == 0
assign rom[15] = 32'h01224823; // add    R9,  R9, R2         * accumulate a2
assign rom[16] = 32'h2D4AFFFF; // addi   R10, R10, -1        * dec counter
assign rom[17] = 32'h155FFFFD; // bnez   R10, -3             * loop
assign rom[18] = 32'h00E95823; // add    R11, R7, R9         * prod1 + prod2
assign rom[19] = 32'hB80B002F; // amoadd R11, R0, data11     * store C11

assign rom[20] = 32'h00003823; // add    R7,  R0, R0         * prod1 = 0
assign rom[21] = 32'h00054023; // add    R8,  R0, R5         * counter = b12
assign rom[22] = 32'h111F0004; // beqz   R8,  +4             * skip if b12 == 0
assign rom[23] = 32'h00E13823; // add    R7,  R7, R1         * accumulate a1
assign rom[24] = 32'h2D08FFFF; // addi   R8,  R8, -1         * dec counter
assign rom[25] = 32'h151FFFFD; // bnez   R8,  -3             * loop

assign rom[26] = 32'h00004823; // add    R9,  R0, R0         * prod2 = 0
assign rom[27] = 32'h00065023; // add    R10, R0, R6         * counter = b22
assign rom[28] = 32'h115F0004; // beqz   R10, +4             * skip if b22 == 0
assign rom[29] = 32'h01224823; // add    R9,  R9, R2         * accumulate a2
assign rom[30] = 32'h2D4AFFFF; // addi   R10, R10, -1        * dec counter
assign rom[31] = 32'h155FFFFD; // bnez   R10, -3             * loop
assign rom[32] = 32'h00E95823; // add    R11, R7, R9         * prod1 + prod2
assign rom[33] = 32'hB80B0030; // amoadd R11, R0, data12     * store C12

assign rom[34] = 32'hFC000000; // halt                       * end

// ---------------- Padding ----------------
assign rom[35] = 32'hFC000000;
assign rom[36] = 32'hFC000000;
assign rom[37] = 32'hFC000000;
assign rom[38] = 32'hFC000000;
assign rom[39] = 32'hFC000000;
assign rom[40] = 32'hFC000000;
assign rom[41] = 32'hFC000000;
assign rom[42] = 32'hFC000000;
assign rom[43] = 32'hFC000000;
assign rom[44] = 32'hFC000000;
assign rom[45] = 32'hFC000000;
assign rom[46] = 32'hFC000000;
assign rom[47] = 32'hFC000000;
assign rom[48] = 32'hFC000000;
assign rom[49] = 32'hFC000000;
assign rom[50] = 32'hFC000000;
assign rom[51] = 32'hFC000000;
assign rom[52] = 32'hFC000000;
assign rom[53] = 32'hFC000000;
assign rom[54] = 32'hFC000000;
assign rom[55] = 32'hFC000000;
assign rom[56] = 32'hFC000000;
assign rom[57] = 32'hFC000000;
assign rom[58] = 32'hFC000000;
assign rom[59] = 32'hFC000000;
assign rom[60] = 32'hFC000000;
assign rom[61] = 32'hFC000000;
assign rom[62] = 32'hFC000000;
assign rom[63] = 32'hFC000000;




	 always @(posedge clk) begin
		if(IR_en)
		begin
				IR <= rom[PC[5:0]];		
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

