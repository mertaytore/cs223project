`timescale 1ns / 1ps
module GetLocation(input clk, input [5:0] keycode,output reg [3:0] loc
/*output reg [1:0] loc2, output reg [1:0] loc3*/ );
	
	initial begin
//		loc1 = 2'b11;
//		loc2 = 2'b11;
//		loc3 = 2'b11;
	loc = 4'b1111;
	end
	always@(posedge clk) begin
	
		//9
		if(keycode == 6'b001001)begin
		   loc <= 4'b1001;	
	   end
		//8
		else if(keycode == 6'b001010)
			loc <= 4'b1000;
		//7
		else if(keycode == 6'b001100)
			loc <= 4'b0111;
		//6
		else if(keycode == 6'b010001)
			loc <= 4'b0110;
		//5
		else if(keycode == 6'b010010)
			loc <= 4'b0101;
		//4
		else if(keycode == 6'b010100)
			loc <= 4'b0100;
		//3
		else if(keycode == 6'b100001)
			loc <= 4'b0011;
		//2
		else if(keycode == 6'b100010)
			loc <= 4'b0010;
		//1
		else if(keycode == 6'b100100)
			loc <= 4'b0001;
		
	end
endmodule

module counter(input clk,input start, input[25:0] stateToGo ,output reg finished);
	reg [25:0]state = 0;
	reg [25:0]nextState = 0;
	//state register
	always@(posedge clk)begin
		state <= nextState;
	end
	//output CL
	always@(posedge clk)begin
		if (start == 1)begin
			if(state == stateToGo)
				finished = 1;
			else 
				finished = 0;
		end
	end
	//next state CL
	always@(posedge clk)begin
		if(start == 1)begin
			if(state == stateToGo)
				nextState = 0;
			else
				nextState = state + 1;
		end
	end
endmodule 

//almost working keyboardscanner fsm
module keyboardScanner (input clk, input [2:0] col,output reg [2:0] row, output reg [5:0] keyCode);
	reg [1:0]state=2'b00;
	reg [1:0]nextState=2'b00;
	
	//state register
	always@(posedge clk) begin
		state <= nextState;
	end
	
	//output CL
	always@(posedge clk) begin
			case (state)
				2'b00: row <= 3'b001;
				2'b01: row <= 3'b010;
				2'b10: row <= 3'b100;
				default: row <= 3'b001;
			endcase
		if (col != 3'b000)
			keyCode <= {row[0],row[1],row[2], col[0],col[1],col[2]};
			
	end
	
	//next state CL
	always @(posedge clk) begin
			case (state)
				2'b00: nextState <= 2'b01;
				2'b01: nextState <= 2'b10;
				2'b10: nextState <= 2'b00;
				default: nextState <= 2'b00;
			endcase
	end
	
endmodule
