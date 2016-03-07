`timescale 1ns / 1ps
	module Controller(
		input clk,
	input [7:0] btemp1,
	input [7:0] btemp2,
	input [7:0] btemp3,
	input [7:0] redtemp1,
	input [7:0] redtemp2,
	input [7:0] redtemp3,
	output reg [1:0] winner
    );
	 initial begin
	 winner = 2'b00;
	 end
	 
	 always @ (clk) begin
	if ( btemp1 == 8'b00010101)
			winner <= 2'b10;
	else if ( btemp2 == 8'b00010101)
			winner <= 2'b10;
	else if ( btemp3 == 8'b00010101 )
			winner <= 2'b10;
	else if ( redtemp1 == 8'b00010101 )begin
		if ( btemp1 == 8'b00000000)
		winner <= 2'b01;
		end
	else if ( redtemp2 == 8'b00010101)begin
		if ( btemp2 == 8'b00000000)
		winner <= 2'b01;
		end
	else if ( redtemp3 == 8'b00010101)begin
		if ( btemp3 == 8'b00000000)
		winner <= 2'b01;
		end
		
	else if ( btemp1[0] == 1) begin
		if ( btemp2[0] == 1) begin
			if( btemp3[0] ==1) begin
				winner <= 2'b10;
			end
		end
		else if ( btemp2[2] == 1) begin
			if( btemp3[4] ==1) begin
			winner <= 2'b10;
			end
		end
	end

		else if ( btemp1[2] == 1) begin
		if ( btemp2[2] == 1) begin
			if( btemp3[2] ==1) begin
				winner <= 2'b10;
				end
			end
		end

		else if ( btemp1[4] == 1) begin
			if ( btemp2[4] == 1) begin
				if( btemp3[4] ==1) begin
					winner <= 2'b10;
				end
			end
			
			else if ( btemp2[2] == 1) begin
				if( btemp3[0] ==1) begin
				winner <= 2'b10;
				end
			end
		end
		

		else if ( redtemp1[0] == 1 && btemp1[0] != 1) begin
			if ( redtemp2[0] == 1 && btemp2[0] != 1) begin
				if( redtemp3[0] ==1 && btemp2[0] != 1) begin
					winner <= 2'b01;
				end
			end
			if ( redtemp2[2] == 1 && btemp2[2] != 1) begin
				if (redtemp3[4] == 1 && btemp3[4] != 1)begin
					winner <= 2'b01;
				end
			end		
		end

		else if ( redtemp1[2] == 1 && btemp1[2] != 1) begin
		if ( redtemp2[2] == 1 && btemp2[2] != 1) begin
			if( redtemp3[2] ==1 && btemp3[2] != 1) begin
				winner <= 2'b01;
				end
			end
		end

		else if ( redtemp1[4] == 1 && btemp1[4] != 1) begin
		if ( redtemp2[4] == 1 && btemp2[4] != 1) begin
			if( redtemp3[4] ==1 && btemp3[4] != 1) begin
				winner <= 2'b01;
				end
			end
			if ( redtemp2[2] == 1 && btemp2[2] != 1) begin
				if (redtemp3[0] == 1 && btemp3[0] != 1)begin
					winner <= 2'b01;
				end
			end		
		end

	
		
		else if ( btemp1[0] == 1) begin
		if ( btemp2[2] == 1) begin
			if( btemp3[4] ==1) begin
				winner <= 2'b01;
				end
			end
		end

end
endmodule
