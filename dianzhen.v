module dianzhen(
				input clk_1kHz,
				input [7:0] colred_cat,
				colgreen_dog,
				col_rat,
				input [15:0]led,
				output [7:0] row,
				col_r,
				col_g);
	
	wire [2:0] jishu;
	//����counter8����ʵ����xianshi�����źŲ���ʵ��
	counter8 u1(.count(jishu), .cp(clk_1kHz));
	xianshi u2(.row(row), 
				.col_r(col_r), 
				.col_g(col_g), 
				.colred_cat(colred_cat), 
				.colgreen_dog(colgreen_dog), 
				.col_rat(col_rat),
				.led(led), 
				.cnt(jishu));
endmodule
//ģֵΪ8�ļ���ģ��
module counter8(output reg [2:0] count,
				input cp);
	always@(posedge cp)
	begin
		 if(count == 3'b111) count <= 3'b000;
		 else count <= count + 1'b1;
	end
endmodule
//ɨ����󣬸���è��������������źŶԵ��������źŸ�ֵ
module xianshi(output reg [7:0] row,
				col_r,
				col_g,
				input [7:0] colred_cat,
				colgreen_dog,
				col_rat,
				input [15:0] led,
				input [2:0] cnt);
	
	/*��ɨ�� 
	���ù�������ƣ��ú��������źţ��������źŸ�ֵ�������źŶ�Ӧ��Ϊ0
	8������ʱ���źŸı��ѭ����ʾ��С�����ۿɷֱ������γ�ͼ��
	*/
	always@(cnt)
	begin
	if(led!=16'hffff)
	begin
		case(cnt)
		3'b111:begin
					row <= 8'b0111_1111;
					col_r <= colred_cat;
					col_g <= 8'b0000_0000;
				end
		3'b110:begin
					row <= 8'b1011_1111;
					col_r <= colred_cat;
					col_g <= 8'b0000_0000;
				end
		3'b101:begin
					row <= 8'b1101_1111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0000_0000;
				end
		3'b100:begin
					row <= 8'b1110_1111;
					col_r <= 8'b0000_0000;
					col_g <= colgreen_dog;
				end
		3'b011:begin
					row <= 8'b1111_0111;
					col_r <= 8'b0000_0000;
					col_g <= colgreen_dog;
				end
		3'b010:begin
					row <= 8'b1111_1011;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0000_0000;
				end
		3'b001:begin
					row <= 8'b1111_1101;
					col_r <= col_rat;
					col_g <= col_rat;
				end
		3'b000:begin
					row <= 8'b1111_1110;
					col_r <= col_rat;
					col_g <= col_rat;
				end
		endcase
	end
	else
	begin
		case(cnt)
		3'b111:begin
					row <= 8'b0111_1111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b1000_0001;
				end
		3'b110:begin
					row <= 8'b1011_1111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b1100_0011;
				end
		3'b101:begin
					row <= 8'b1101_1111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b1100_0011;
				end
		3'b100:begin
					row <= 8'b1110_1111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0110_0110;
				end
		3'b011:begin
					row <= 8'b1111_0111;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0110_0110;
				end
		3'b010:begin
					row <= 8'b1111_1011;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0011_1100;
				end
		3'b001:begin
					row <= 8'b1111_1101;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0011_1100;
				end
		3'b000:begin
					row <= 8'b1111_1110;
					col_r <= 8'b0000_0000;
					col_g <= 8'b0001_1000;
				end
		endcase
	end
	end
endmodule