`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:40:34 01/11/2025 
// Design Name: 
// Module Name:    SHIFT_Env 
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
module SHIFT_Env(

    input [31:0] shift_in,
    input right,
    input shift,
    output [31:0] shift_out
    );
	 
	 reg [31:0] out_1; 
	always @(*) begin
       if (shift)
		 begin
			 if (right)
			 begin
             out_1 = shift_in >> 1; 
            end 
				else
				begin
              out_1 = shift_in << 1; 
            end
		end 
		else 
		begin
			  out_1 = shift_in; 
		  end
		 end
		 
	assign  shift_out = out_1 ; 

endmodule
