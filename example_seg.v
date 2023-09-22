module example_seg(input clk_1kHz,
					input sw,
					status,
					input [7:0] seg1,
					seg2,
					seg3,
					seg4,
					input [15:0] led,
					output reg [7:0] seg,
					cat);
	/*
	显示8个数字 用模值为8的计数器计数
	计数器随着时钟信号改变，采用共阳极设计
	数码管阳极信号赋值为对应的数值信号，阴极信号对应位置为0
	*/
	reg [3:0] i;
	always@(posedge clk_1kHz)
		if(i == 7) i <= 0;
		else i <= i + 1;

	always@(i)
		if(!sw)
		begin
			seg <= 8'b0000_0000; 
			cat <= 8'b1111_1111;
		end
	    else if(led)
	    begin
			case(i/2)
				0:begin seg <= seg1; cat <= 8'b1111_1101; end
				1:begin seg <= seg2; cat <= 8'b1111_1110; end
				2:begin seg <= seg3; cat <= 8'b0111_1111; end
				3:begin seg <= seg4; cat <= 8'b1011_1111; end
				default: begin seg <= 8'b0000_0000; cat <= 8'b1111_1111; end
			endcase
		end
		else
		begin
			if(status == 0)
				case(i)
					0:begin seg <= seg3; cat <= 8'b0111_1111; end
					1:begin seg <= seg4; cat <= 8'b1011_1111; end
					2:begin seg <= 8'b0011_1000; cat <= 8'b1101_1111; end
					3:begin seg <= 8'b0011_1111; cat <= 8'b1110_1111; end
					4:begin seg <= 8'b0110_1101; cat <= 8'b1111_0111; end
					5:begin seg <= 8'b0111_1001; cat <= 8'b1111_1011; end
					6:begin seg <= seg1; cat <= 8'b1111_1101; end
					7:begin seg <= seg2; cat <= 8'b1111_1110; end
					default: begin seg <= 8'b0000_0000; cat <= 8'b1111_1111; end
				endcase
			else
				case(i/2)
				0:begin seg <= seg1; cat <= 8'b1111_1101; end
				1:begin seg <= seg2; cat <= 8'b1111_1110; end
				2:begin seg <= seg3; cat <= 8'b0111_1111; end
				3:begin seg <= seg4; cat <= 8'b1011_1111; end
				default: begin seg <= 8'b0000_0000; cat <= 8'b1111_1111; end
			endcase
		end
endmodule