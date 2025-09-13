`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:46:44 12/14/2024 
// Design Name: 
// Module Name:    MAC_STATE_MACHINE 
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
module MAC_STATE_MACHINE(
    input clk,
    input reset,
    input ACK_N,
	 input mr,
	 input mw,
    output stop_n,
    output AS_N,
    output WR_N,
    output busy,
    output [1:0] MAC_STATE_OUT
    );
	 
	reg [1:0] MAC_STATE;
	wire req;
	assign req = mr | mw;
	
	
	
	parameter st_0 = 2'h0 ; // WAIT4REQ
	parameter st_1 = 2'h1 ; // WAIT4ACK
	parameter st_2 = 2'h2 ; // NEXT

	
	always @(posedge clk)
	begin 
	if(reset)
		MAC_STATE = st_0 ;
	else
	begin 
		
		case(MAC_STATE)
			
			st_0 : 
				if(req)
				begin
				MAC_STATE = st_1 ;
				end
				else 
				begin 
				MAC_STATE = st_0;
				end
				
			st_1 : 
					if(~ACK_N)
					begin
					MAC_STATE = st_2 ;
					end
					else 
					begin 
					MAC_STATE = st_1;
					end
			
			st_2 : 
				MAC_STATE = st_0 ;
		
			default : 
			begin 
			MAC_STATE = st_0 ;
			end
		endcase
		end
		end
		
		assign busy = (ACK_N & (req))  ; 
		assign WR_N = ~((MAC_STATE == st_1) & mw);
		assign AS_N = ~(MAC_STATE == st_1);
		assign stop_n = ~(MAC_STATE== st_1) ;
		assign MAC_STATE_OUT = MAC_STATE;
				
		
		
	

endmodule
   



