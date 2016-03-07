`timescale 1ns / 1ps
module DotMatrix(
		input clk,
		input turn,
		input [1:0] winner,
	   input  [5:0] loc,
		output  reg oe, //output enable
		
		output reg  SH_CP, // shift register clk pulse
		output reg ST_CP, // store register clk pulse
		output reg reset, // reset for the shift register
		/*output reg [7:0] blue2,*/
		output reg DS, // digital signal
		/*output reg [7:0] KATOT,*/
		output reg [2:0] K,
		output reg [7:0] btemp,btemp1,btemp2,btemp3,redtemp,redtemp1,redtemp2,redtemp3,
		
		output [3:0] AN,
		output [6:0] C,
		output       DP	
    );
	 //DotMatrix sa(clk,loc1,loc2,loc3,oe,SH_CP,ST_CP,reset,DS,/*KATOT,*/K);
	wire [24:1] message;
	reg [7:0] red;
	
	//*****************************
	//seven segment
	reg [3:0] current_digit, cur_dig_AN;
	reg [6:0] segments;
	
	assign AN = (cur_dig_AN);// AN signals are active low,
				  // and must be enabled to display digit
	assign C = ~segments;     // since the CA values are active low
	assign DP = 1;            // the dot point is always off 
			  // (0 = on, since it is active low)
									  
	// the 18-bit counter, runs at 50 MHz, so bit16 changes each 1.3 millisecond
	localparam N=18;
	reg [N-1:0] count;
	reg [3:0] first, second,third,fourth;
	
	always@(winner)begin 
		 if(winner == 2'b01) begin first =4'b0010; second =4'b0010; third = 4'b0010; fourth =4'b0010;end
		 else if (winner == 2'b10) begin first =4'b1011; second =4'b1011; third = 4'b1011; fourth = 4'b1011;end
	end
	
	always@(count, first, second, third, fourth)begin
		case(count[17:16])
			 00: begin current_digit = fourth;  cur_dig_AN = 4'b1110; end
			 01: begin current_digit = third;   cur_dig_AN = 4'b1101; end
			 10: begin current_digit = second; cur_dig_AN = 4'b1011; end
			 11: begin current_digit = first; cur_dig_AN = 4'b0111; end
						 // right most, AN4
			default: begin current_digit = 4'bxxxx; cur_dig_AN = 4'bxxxx; end			 
		endcase
		end
	
	always @ (current_digit)
		case (current_digit)
		4'b0000: segments = 7'b111_0001;  // L
		4'b0001: segments = 7'b100_0001;  // U
		4'b0010: segments = 7'b000_0101;  // R
		4'b0011: segments = 7'b111_1111;  // empty
		4'b0100: segments = 7'b011_0011;  // 4
		4'b0101: segments = 7'b101_1011;  // 5
		4'b0110: segments = 7'b101_1111;  // 6
		4'b0111: segments = 7'b111_0000;  // 7
		4'b1000: segments = 7'b111_1111;  // 8
		4'b1001: segments = 7'b111_0011;  // 9
		4'b1010: segments = 7'b111_0111;  // A
		4'b1011: segments = 7'b001_1111;  // b
		4'b1100: segments = 7'b000_1101;  // c
		4'b1101: segments = 7'b011_1101;  // d
		4'b1110: segments = 7'b100_1111;  // E
		4'b1111: segments = 7'b100_0111;  // F
		default: segments = 7'bxxx_xxxx;
		endcase		
	
	//***********************************
reg keriz;
//	reg [7:0] green;
//	reg [7:0] btemp;
//	reg [7:0] btemp1;
//	reg [7:0] btemp2;
//	reg [7:0] btemp3;
//	reg [7:0] redtemp1;
//	reg [7:0] redtemp;
//	reg [7:0] redtemp2;
//	reg [7:0] redtemp3;
	
	initial begin
	   red = 8'hFF;
		//blue2=blue;
	   //green = 8'h00;	
		//blue = 8'h00;
		btemp  =  8'b00000000;
		btemp1 =  8'b00000000;
		btemp3 =  8'b00000000;
		btemp2 =  8'b00000000;
		redtemp = 8'b00000000;
		redtemp1 =8'b00000000;
		redtemp2 =8'b00000000;
		redtemp3 =8'b00000000;
	end
	//assign 
	assign message[24:20] = redtemp;
	assign message[8:4] = btemp;
	assign message[16:12] = red;
	
	
	reg f;
	reg e;
	
	reg[1:0] counter;
	reg[8:0] i = 1; // --data signalin seri olarak iletilmesini kontrol eder.
	reg[2:0] a = 0;
	reg[9:0] d = 0;
	always@(posedge clk)
	begin
		counter = counter+1;
		f<= counter[1]; // clk signal for the shift register
		e<= ~f;
	end	
		//------------------------------------------------------------
	always@( posedge e)
		begin	
		//seri olarak datayý almak için her clk pulse tan sonra i bir arttýrýlýyor.
			i = i+9'b000000001;
		end	

	always@(*)
		begin
			if (i < 9'b000000100) // baþlangýçta i 4'e gelene kadar sisteme reset atýlýr.
				reset<=0;
			else
				reset<=1;
			if (i>9'b000000011 && i<9'b000011100) //4'le 27 arasýnda data akýþý seri olarak.
				DS<=message[i-9'b000000011];
			else 
				DS<=0;
				
			if (i<9'b000011100) //i 28'e geldiðinde data akýþý datamlanýyor.24 bit data alýnmýþ oluyor. bu sureden sonra clk durduluyor yeni data akýþýna kadar.
				begin
					SH_CP<=f;             
					ST_CP<=e;
				end
				
			else
				begin
					SH_CP<=0;
					ST_CP<=1;
				end
end
			always @(posedge f)//clk un durduðu surede OE=0 yani output registerin çýkýþýnda aktif durumda.
			begin
				if (i>9'b000011100 && i<9'b110011101)
					oe<=0;
				else
					oe<=1;
			end		

			always @(posedge f) //bir satýr tamamlandýðýnda a bir arttýrýlýyor 2. satýra geçmek için.
			begin	
				if (i==9'b110011110)
					begin
					a = a+1;
					//i <=9'b0;
					end
			end

			always @(posedge f) //satrlar ve sutunlar tamamlandýðýnda yeni görüntü için(ful ekran) d bir arttýrýlýyor.
			begin	
				if (i==9'b110011110)
					if (a==7) 
						d=d+1;
			end			
		//a katotlarý taramak için kullanýlýyor.
	always@( a)
		begin
			 //if (a==1 | a==2) begin
			 case(a)
			 3'b001: begin
			 if(turn) begin
				case(loc)
					 6'b001100:
					case(btemp1)
						8'b00000000:begin
							btemp1   <=8'b00000001;
							end
						8'b00000100:begin
							btemp1<=8'b00000101;
							end
						8'b00010000:begin
							btemp1<=8'b00010001;
							end
						8'b00010100:begin
							btemp1<=8'b00010101;
							end
						8'b00010101:begin
							btemp1<=8'b00010101;

							end
						endcase
						
				6'b010100:
				case(btemp1)
					8'b00000000:begin
						btemp1<=8'b00000100;
						end
					8'b00000001:begin
						btemp1<=8'b00000101;
						end
					8'b00010000:begin
						btemp1<=8'b00010100;
						end
					8'b00010001:begin
						btemp1<=8'b00010101;
						end
					8'b00010101:begin
						btemp1<=8'b00010101;
						end
				endcase
				
				 6'b100100:
				case(btemp1)
					8'b00000000:
						btemp1<=8'b00010000;
					8'b00000001:
						btemp1<=8'b00010001;
					8'b00000100:
						btemp1<=8'b00010100;
					8'b00000101:
						btemp1<=8'b00010101;
					8'b00010101:
						btemp1<=8'b00010101;
				endcase
				endcase
				end
				
				else begin
					case(loc)
					 6'b001100:
					case(redtemp1)
						8'b00000000:begin
							redtemp1   <=8'b00000001;
							end
						8'b00000100:begin
							redtemp1<=8'b00000101;
							end
						8'b00010000:begin
							redtemp1<=8'b00010001;
							end
						8'b00010100:begin
							redtemp1<=8'b00010101;
							end
						8'b00010101:begin
							redtemp1<=8'b00010101;

							end
						endcase
						
				6'b010100:
				case(redtemp1)
					8'b00000000:begin
						redtemp1<=8'b00000100;
						end
					8'b00000001:begin
						redtemp1<=8'b00000101;
						end
					8'b00010000:begin
						redtemp1<=8'b00010100;
						end
					8'b00010001:begin
						redtemp1<=8'b00010101;
						end
					8'b00010101:begin
						redtemp1<=8'b00010101;
						end
				endcase
				
				6'b100100:
				case(redtemp1)
					8'b00000000:
						redtemp1<=8'b00010000;
					8'b00000001:
						redtemp1<=8'b00010001;
					8'b00000100:
						redtemp1<=8'b00010100;
					8'b00000101:
						redtemp1<=8'b00010101;
					8'b00010101:
						redtemp1<=8'b00010101;
				endcase
				
				endcase
				end
				redtemp <= redtemp1;
				K <= 3'b000;
				btemp <= btemp1;
				red <= 8'b00001010;
				end
	
			3'b011:begin
			//	KATOT<=8'b00001000;
					   red <= 8'b10111111;
						K <= 3'b001;
						btemp <= 8'b00000000;
				end
				
			3'b101:  begin
			if(turn) begin
				case(loc)
				 6'b001010:
					case(btemp2)
						8'b00000000:
							btemp2<=8'b00000001;
						8'b00000100:
							btemp2<=8'b00000101;
						8'b00010000:
							btemp2<=8'b00010001;
						8'b00010100:
							btemp2<=8'b00010101;
						8'b00010101:
							btemp2<=8'b00010101;
						endcase	
						
				 6'b010010:
					case(btemp2)
						8'b00000000:
							btemp2<=8'b00000100;
						8'b00000001:
							btemp2<=8'b00000101;
						8'b00010000:
							btemp2<=8'b00010100;
						8'b00010001:
							btemp2<=8'b00010101;
						8'b00010101:
							btemp2<=8'b00010101;
					endcase
				
				6'b100010:
					case(btemp2)
						
						8'b00000000:
							btemp2<=8'b00010000;
						8'b00000001:
							btemp2<=8'b00010001;
						8'b00000100:
							btemp2<=8'b00010100;
						8'b00000101:
							btemp2<=8'b00010101;
						8'b00010101:
							btemp2<=8'b00010101;
					endcase
				endcase
				end
			//	
				else begin
					case(loc)
					6'b001010:
					case(redtemp2)
						8'b00000000:begin
							redtemp2   <=8'b00000001;
							end
						8'b00000100:begin
							redtemp2<=8'b00000101;
							end
						8'b00010000:begin
							redtemp2<=8'b00010001;
							end
						8'b00010100:begin
							redtemp2<=8'b00010101;
							end
						8'b00010101:begin
							redtemp2<=8'b00010101;

							end
						endcase
						
				6'b010010:
				case(redtemp2)
					8'b00000000:begin
						redtemp2<=8'b00000100;
						end
					8'b00000001:begin
						redtemp2<=8'b00000101;
						end
					8'b00010000:begin
						redtemp2<=8'b00010100;
						end
					8'b00010001:begin
						redtemp2<=8'b00010101;
						end
					8'b00010101:begin
						redtemp2<=8'b00010101;
						end
				endcase
				
				6'b100010:
				case(redtemp2)
					8'b00000000:
						redtemp2<=8'b00010000;
					8'b00000001:
						redtemp2<=8'b00010001;
					8'b00000100:
						redtemp2<=8'b00010100;
					8'b00000101:
						redtemp2<=8'b00010101;
					8'b00010101:
						redtemp2<=8'b00010101;
				endcase
				
				endcase
				end
				redtemp <= redtemp2;
				red <= 8'b00001010;
				btemp<= btemp2;
				K <= 3'b010;

				end
			3'b110: begin
				red <= 8'b10111111;
				 K <= 3'b011;
				btemp <= 8'b00000000;
				end
				
			3'b111: begin
				if(turn) begin
				case(loc)
					6'b001001:
					case(btemp3)
						8'b00000000:
							btemp3<=8'b00000001;
						8'b00000100:
							btemp3<=8'b00000101;
						8'b00010000:
							btemp3<=8'b00010001;
						8'b00010100:
							btemp3<=8'b00010101;
						8'b00010101:
							btemp3<=8'b00010101;
						endcase	
						
				6'b010001:
				case(btemp3)
					8'b00000000:
						btemp3<=8'b00000100;
					8'b00000001:
						btemp3<=8'b00000101;
					8'b00010000:
						btemp3<=8'b00010100;
					8'b00010001:
						btemp3<=8'b00010101;
					8'b00010101:
						btemp3<=8'b00010101;
				endcase
				
				6'b100001:
				case(btemp3)
					8'b00000000:
						btemp3<=8'b00010000;
					8'b00000001:
						btemp3<=8'b00010001;
					8'b00000100:
						btemp3<=8'b00010100;
					8'b00000101:
						btemp3<=8'b00010101;
					8'b00010101:
						btemp3<=8'b00010101;
				endcase
				endcase
				end
					else  begin
					case(loc)
					6'b001001:
					case(redtemp3)
						8'b00000000:begin
							redtemp3   <=8'b00000001;
							end
						8'b00000100:begin
							redtemp3<=8'b00000101;
							end
						8'b00010000:begin
							redtemp3<=8'b00010001;
							end
						8'b00010100:begin
							redtemp3<=8'b00010101;
							end
						8'b00010101:begin
							redtemp3<=8'b00010101;

							end
						endcase
						
				6'b010001:
				case(redtemp3)
					8'b00000000:begin
						redtemp3<=8'b00000100;
						end
					8'b00000001:begin
						redtemp3<=8'b00000101;
						end
					8'b00010000:begin
						redtemp3<=8'b00010100;
						end
					8'b00010001:begin
						redtemp3<=8'b00010101;
						end
					8'b00010101:begin
						redtemp3<=8'b00010101;
						end
				endcase
				
				6'b100001:
				case(redtemp3)
					8'b00000000:
						redtemp3<=8'b00010000;
					8'b00000001:
						redtemp3<=8'b00010001;
					8'b00000100:
						redtemp3<=8'b00010100;
					8'b00000101:
						redtemp3<=8'b00010101;
					8'b00010101:
						redtemp3<=8'b00010101;
				endcase
				
				endcase
				end
				btemp <= btemp3;
				redtemp <= redtemp3;
				red <= 8'b10101010;
				K <= 3'b100;
			end		
		3'b000:begin
			case (winner)
			2'b00: keriz = 0;// K <= 3'b110;
			2'b01: K <= 3'b101;
			2'b10: K <= 3'b101;
			2'b11: K <= 3'b100;//K <= 3'b110;
			endcase
//			else if (winner == 2'b11)begin
//			 K <= 3'b101;
//			 end
		end
endcase
		end
endmodule



module comboModule(input clk,turn, input  [2:0]col,output [2:0] row, output [2:0] K,output DS,/*output [7:0] KATOT,*/
							/*output [3:0] loc1*//*,loc2,loc3*/output oe,reset,SH_CP,ST_CP,output [5:0]kCode,/*output[1:0] winner,*/
							output [7:0] rt,bt, output [3:0] AN, output [6:0] C, output DP	);
	wire wait100,wait20,start,loc1;
	wire [1:0]winner;
	wire [7:0]b1,b2,b3,r1,r2,r3;
	keyboardScanner kScan(wait100/*,wait20, start*/,col,row,kCode);
	counter c100(clk,1,26'd500000,wait100);
	//counter c20(clk,start,26'd500000,wait20);
	//SevenSegment SS(clk,kCode,CA,CB,CC,CD,CE,CF,CG,AN0,AN1,AN2,AN3);
	GetLocation as(clk,kCode,loc1);
	DotMatrix sa(clk,turn,winner,kCode,oe,SH_CP,ST_CP,reset,DS,/*KATOT,*/K,bt,b1,b2,b3,rt,r1,r2,r3,AN,C,DP);
   Controller ccc(clk,b1,b2,b3,r1,r2,r3,winner);
 	

 endmodule
