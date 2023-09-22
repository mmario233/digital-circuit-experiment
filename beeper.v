module beeper(input clk,
				rst,
				en,
				input [1:0] tune_id,
				output piano_out
 );
	
	reg [9:0] t;
	reg [4:0] ttune;
	reg [2:0] t1;
	
	/*
	ʹ��ʱ�ӷ�Ƶģ�����16Hz��ʱ���źţ�ÿ1/16��仯һ��
	��������tune_id���ı�����ttune������beepʵ���������ͬ�ķ������ź�
	*/
	always@(posedge clk16Hz or posedge rst)
	begin
		if(rst)
		begin
			t <= 0;
			t1 <= 0;
			ttune <= 0;
		end
		else if(!en)
		begin
			t <= 0;
			t1 <= 0;
			ttune <= 0;
		end
		else
		begin
			if(tune_id == 0)//С����
			begin
				if(t == 10'd768)t <= 0;
				else t <= t + 1;
				if (t % 128==0);
				else if (t%16==0)ttune = 0;
				else
				case(t/16)
					1:ttune = 8;
					2:ttune = 8;
					3:ttune = 12;
					4:ttune = 12;
					5:ttune = 13;
					6:ttune = 13;
					7:ttune = 12;
					8:ttune = 12;
					9:ttune = 11;
					10:ttune = 11;
					11:ttune = 10;
					12:ttune = 10;
					13:ttune = 9;
					14:ttune = 9;
					15:ttune = 8;
					16:ttune = 8;
					17:ttune = 12;
					18:ttune = 12;
					19:ttune = 11;
					20:ttune = 11;
					21:ttune = 10;
					22:ttune = 10;
					23:ttune = 9;
					24:ttune = 9;
					25:ttune = 12;
					26:ttune = 12;
					27:ttune = 11;
					28:ttune = 11;
					29:ttune = 10;
					30:ttune = 10;
					31:ttune = 9;
					32:ttune = 9;
					33:ttune = 8;
					34:ttune = 8;
					35:ttune = 12;
					36:ttune = 12;
					37:ttune = 13;
					38:ttune = 13;
					39:ttune = 12;
					40:ttune = 12;
					41:ttune = 11;
					42:ttune = 11;
					43:ttune = 10;
					44:ttune = 10;
					45:ttune = 9;
					46:ttune = 9;
					47:ttune = 8;
					48:ttune = 8;
					default:ttune = 0;
				endcase
			end
			else if(tune_id == 2'd1)//���� do re mi fa so la xi
			begin
				t1 <= t1 + 1;
				case(t1)
					1: ttune = 1;
					2: ttune = 2;
					3: ttune = 3;
					4: ttune = 4;
					5: ttune = 5;
					6: ttune = 6;
					7: ttune = 7;
					default:ttune = 0;
				endcase
			end
			else if(tune_id == 2'd2)//���� xi la so fa mi re do
			begin
				t1 <= t1 + 1;
				case(t1)
					1: ttune = 21;
					2: ttune = 20;
					3: ttune = 19;
					4: ttune = 18;
					5: ttune = 17;
					6: ttune = 16;
					7: ttune = 15;
					default:ttune = 0;
				endcase
			end
		end
	end
	
	beep b1(.clk_in(clk),
			.rst_n_in(rst),
			.tune_en(en),
			.tune(ttune),
			.piano_out(piano_out)
			);
	
	dividend #(.WIDTH(18), .N(62500)) d1(.clk(clk), .rst_n(0), .clkout(clk16Hz));
 endmodule
 
 module beep(
			input clk_in,		//ϵͳʱ��
			rst_n_in,		//ϵͳ��λ������Ч
			tune_en,			//������ʹ���ź�
			input [4:0] tune,		//���������ڿ���
			output reg piano_out	//�������������
			);
/*
��Դ���������Է�����ͬ�����ڣ���������𶯵�Ƶ�ʣ����ڷ����������źŵ�Ƶ�ʣ���أ�
Ϊ���÷����������źŲ�����ͬ��Ƶ�ʣ�����ʹ�ü�������������Ƶ��ʵ�֣���ͬ�����ڿ��ƶ�Ӧ��ͬ�ļ�����ֵ����Ƶϵ����
���������ݼ�����ֵ��������Ƶ�����������������ź�
*/
reg [16:0] time_end;
//���ݲ�ͬ�����ڿ��ƣ�ѡ���Ӧ�ļ�����ֵ����Ƶϵ����
//����1��Ƶ��Ϊ261.6Hz�������������ź�����ӦΪ1MHz/261.6Hz = 3822.2��
//��Ϊ������з����������ź��ǰ����������ڷ�ת�ģ����Լ�����ֵ = 3822.2/2 = 1911
//��Ҫ����1911����������ΧΪ0 ~ (1911-1)������time_end = 1910
always@(tune) begin
	case(tune)
		5'd1:	time_end =	17'd1910;	//L1,261.63
		5'd2:	time_end =	17'd1702;	//L2,293.67
		5'd3:	time_end =	17'd1516;	//L3,329.63
		5'd4:	time_end =	17'd1431;	//L4,349.23
		5'd5:	time_end =	17'd1275;	//L5,391.99
		5'd6:	time_end =	17'd1135;	//L6,440
		5'd7:	time_end =	17'd1011;	//L7,493.88
		5'd8:	time_end =	17'd955;	//M1,523.25
		5'd9:	time_end =	17'd850;	//M2,587.33
		5'd10:	time_end =	17'd757;	//M3,659.25
		5'd11:	time_end =	17'd715;	//M4,698.46
		5'd12:	time_end =	17'd637;	//M5,783.99
		5'd13:	time_end =	17'd567;	//M6,880
		5'd14:	time_end =	17'd505;	//M7,987.76
		5'd15:	time_end =	17'd487;	//H1,1025.5
		5'd16:	time_end =	17'd426;	//H2,1174.66
		5'd17:	time_end =	17'd378;	//H3,1318.51
		5'd18:	time_end =	17'd357;	//H4,1396.92
		5'd19:	time_end =	17'd316;	//H5,1576.98
		5'd20:	time_end =	17'd283;	//H6,1760
		5'd21:	time_end =	17'd252;	//H7,1975.52
		default:time_end =	17'd1;	
	endcase
end
 
reg [17:0] time_cnt;
//��������ʹ��ʱ�����������ռ�����ֵ����Ƶϵ��������
always@(posedge clk_in or posedge rst_n_in) begin
	if(rst_n_in) begin
		time_cnt <= 1'b0;
	end else if(!tune_en) begin
		time_cnt <= 1'b0;
	end else if(time_cnt>=time_end) begin
		time_cnt <= 1'b0;
	end else begin
		time_cnt <= time_cnt + 1'b1;
	end
end
 
//���ݼ����������ڣ���ת�����������ź�
always@(posedge clk_in or posedge rst_n_in) begin
	if(rst_n_in) begin
		piano_out <= 1'b0;
	end else if(time_cnt==time_end) begin
		piano_out <= ~piano_out;	//���������������ת�����η�תΪ1Hz
	end else begin
		piano_out <= piano_out;
	end
end
 
endmodule