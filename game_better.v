module game_better(
					input clk,
					rst,
					btn_cat,//��������è����
					btn_dog, //��������������
					btn_rat, //�������������
					btn_ren, //�������˵�������
					sw,//�ܿ���
					input [1:0] levelchoices,//����0��1�����Ѷ�
					output reg [15:0] led,//led���
					output [7:0] seg_f,//����������ź�
					cat,//�����ź�
					output reg [7:0] row,//���������ź�
					col_r,//���������źţ��죩
					col_g,//���������źţ��̣�
					output beeps//�����������ź�
					);
	
	reg [3:0] onboat;//�ڴ��ϣ�3è��2����1��0�ˣ�
	reg [7:0] col_r_cat, col_g_dog, col_rat;
	wire [4:0] key;//��������źţ�3è��2����1��0�ˣ�
	reg [3:0] count;//������
	reg [3:0] cnt_h, cnt_1;//�Ʋ�����ʮλ����λ��
	reg [3:0] pos;//λ�ã�3è��2����1��0�ˣ�
	reg status;//״̬���Ƿ���ã�
	reg [7:0] seg [9:0];//�洢0~9���������ʾ
	reg [7:0] seg1, seg2, seg3, seg4;//ʮλ����λ��ʾ
	parameter [7:0] start = 8'h3; //�����ʼ״̬
	reg level;//�Ѷȿ����ñ�־
	reg [4:0] mstep;//�����
	reg [1:0] tune_id = 0;//����������id
	
	initial//��ʼ��
	begin
		seg[0] = 8'b0011_1111;
		seg[1] = 8'b0000_0110;
		seg[2] = 8'b0101_1011;
		seg[3] = 8'b0100_1111;
		seg[4] = 8'b0110_0110;
		seg[5] = 8'b0110_1101;
		seg[6] = 8'b0111_1101;
		seg[7] = 8'b0000_0111;
		seg[8] = 8'b0111_1111;
		seg[9] = 8'b0110_1111;
		col_r_cat = start;
		col_rat = start;
		col_g_dog = start;
		led = 16'h8000;
		status = 1;
		pos = 0;
		level = 1;
		tune_id = 0;
	end
	/*
	�Ը�λ����ʱ���ź�������Ϊ�����أ�
	���ܿ���sw��״̬status��������İ����ź�key���м��
	�����������λ��״̬pos���ڴ���״̬onboat�͵�������counter�Բ������и��� 
	*/
	always@(posedge clk or posedge key[4])
	begin
		if(key[4])//��λ
		begin
			onboat = 0;
			pos = 0;
			level = 1;
			counter(rst, sw, cnt_1, cnt_h);//��������counter
		end
		else if(!sw)
		begin
			onboat = 0;
			pos = 0;
			level = 1;
			counter(rst, sw, cnt_1, cnt_h);
		end
		else if(status)//�Ƿ�ɲ���
		begin
			if(count == 0)//���԰����´�
			begin
				onboat = 0;
			end
			else if(onboat == 0)//����ʱ�Ž����źţ�������ʱ��Ч��
			begin
				if(key[3] && pos[3] == pos[0])//��è����
				begin
					level = 0;
					onboat[3] = 1;
					pos[3] = ~pos[3];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[2] && pos[2] == pos[0]) //��������
				begin
					level = 0;
					onboat[2] = 1;
					pos[2] = ~pos[2];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[1] && pos[1] == pos[0]) //�������
				begin
					level = 0;
					onboat[1] = 1;
					pos[1] = ~pos[1];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[0])//���Լ�����
				begin
					level = 0;
					onboat[0] = 1;
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
			end
		end
	end
	/*��4Hz��ʱ���źŽ���4s�ļ�ʱ*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//��λ
		begin
			count <= 4'b1111;
		end
		else if(!sw)
		begin
			count <= 4'b1111;
		end
		else if(count == 0)//�ػ�4s
		begin
			count <= 4'b1111;
		end
		else if(onboat)//���Ӽ�ʱ
		begin
			count <= count - 1'b1;
		end
	end
	/*��4Hzʱ���ź�ʵ�ֵ���ı仯����������״̬���任3��*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//��λ
		begin
			col_r_cat = start;
			col_rat = start;
			col_g_dog = start;
		end
		else if(!sw)
		begin
			col_r_cat = 0;
			col_rat = 0;
			col_g_dog = 0;
		end
		else if(sw && col_rat == 0)//��������
		begin
			col_r_cat = start;
			col_rat = start;
			col_g_dog = start;
		end
		else if(count % 4 == 0 && count != 0)//����ÿ��仯һ��
		begin
			if(pos[0]==1)//����
			begin
				if(onboat[3])
				col_r_cat <= {col_r_cat[5:0], col_r_cat[7:6]};
				else if(onboat[2])
				col_g_dog <= {col_g_dog[5:0], col_g_dog[7:6]};
				else if(onboat[1])
				col_rat <= {col_rat[5:0], col_rat[7:6]};
			end
			else//�ҵ���
			begin
				if(onboat[3])
				col_r_cat <= {col_r_cat[1:0], col_r_cat[7:2]};
				else if(onboat[2])
				col_g_dog <= {col_g_dog[1:0], col_g_dog[7:2]};
				else if(onboat[1])
				col_rat <= {col_rat[1:0], col_rat[7:2]};
			end
		end
	end
	/*led��״̬������ʱÿ1/4��仯һ�Σ����ڶ���ȫ�����Ӻ�ȫ��
	�ڴﵽ���������λ�ò��ԣ�ֻ��è����è����һ����ʱȫ��*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//��λ
		begin
			led <= 16'h8000;
			status <= 1;
			tune_id <= 2'd0;
		end
		else if(!sw)
		begin
			led <= 16'h0;
			status <= 1;
			tune_id <= 2'd0;
		end
		else if(sw && led == 0 && col_rat == 0)//��������
		begin
			led <= 16'h8000;
			status <= 1;
			tune_id <= 2'd0;
		end
		else if(count == 4'b1111 && !onboat)//���԰����ж�
		begin
			if(pos == 4'b1111)
			begin
				led <= 16'hffff;
				status <= 0;
				tune_id <= 2'd1;
			end
			else if(pos == 4'b0011 || pos == 4'b1100 || pos == 4'b0101 || pos == 4'b1010 ||(cnt_1 == mstep%10 && cnt_h == mstep/10))
			begin
				led <= 16'h0;
				status <= 0;
				tune_id <= 2'd2;
			end
		end
		else if(count!=4'b1111)//����ʱ
		begin
			if(pos[0] == 1)//����
			begin
				led <= {led[0],led[15:1]};
			end
			else if(pos[0] == 0)//�ҵ���
			begin
				led <= {led[14:0],led[15]};
			end
		end
	end
	//���񣺼Ʋ���
	//��¼��ǰ����
	task counter;
		input rst;
		input switch;
		inout [3:0] count_1;
		inout [3:0] count_h;
		if(rst)
		begin
			count_1 <= 0;
			count_h <= 0;
		end
		else if(!switch)
		begin
			count_1 <= 0;
			count_h <= 0;
		end
		else if(count_1 == 9)
		begin 
			count_h <= count_h + 1; 
			count_1 <= 0; 
		end
		else
			count_1 <= count_1 + 1;
	endtask
	//��ʮλ����λ���������ź�
	always@(cnt_1 or cnt_h)
	begin
		seg2 = seg[cnt_1];
		seg1 = seg[cnt_h];
	end
	//���ݲ���0��1����ϣ�ʵ���Ѷ����ã�������ı�
	always@(levelchoices)
	begin
		if(level)
		begin
			case(levelchoices)
				2'b00:mstep <= 31;
				2'b01:mstep <= 25;
				2'b10:mstep <= 15;
				2'b11:mstep <= 9;
			endcase
		end
	end
	//���Ѷȶ�Ӧ���������ʮλ����λ���������ź�
	always@(levelchoices)
	begin
		seg3 = seg[mstep/10];
		seg4 = seg[mstep%10];
	end
	//�������ź�
	//����1MHz��ʱ���źţ���λ�źš�ʹ���źţ�����id
	//����������ź�
	beeper bp1(.clk(clk),
				.rst(rst),
				.en(sw),
				.tune_id(tune_id),
				.piano_out(beeps));		
	//����ʵ��
	//����1kHz��ʱ�ӣ�è�����Ӧ��״̬������������źţ��졢�̣������źš�
	dianzhen dz1(.clk_1kHz(clk1k),
				.colred_cat(col_r_cat),
				.colgreen_dog(col_g_dog),
				.col_rat(col_rat),
				.row(row),
				.col_r(col_r),
				.col_g(col_g),
				.led(led));			
	//�������ʾ
	//����1kHz��ʱ�ӣ�������ʮλ����λ�������������źţ���������������
	example_seg segs(	.clk_1kHz(clk1k),
						.sw(sw),
						.status(status),
						.seg1(seg1),
						.seg2(seg2),
						.seg3(seg3),
						.seg4(seg4),
						.seg(seg_f),
						.cat(cat),
						.led(led));				
	/*ʱ�ӷ�Ƶ1kHz��4Hz
	�������λ��10λ������1000��
1kHzʱ�ӵ�һ�����ڵ���1MHzʱ�ӵ�1000������
	����ʱ��1MHz�͸�λ�źţ����1kHzʱ��;
	�������λ��18λ������250000��
4Hzʱ�ӵ�һ�����ڵ���1MHzʱ�ӵ�250000������
	����ʱ��1MHz�͸�λ�źţ����4Hzʱ��
	*/
	dividend #(.WIDTH(18), .N(250000)) d1(.clk(clk), .rst_n(0), .clkout(clk4Hz));
	dividend #(.WIDTH(10), .N(1000)) d2(.clk(clk), .rst_n(0), .clkout(clk1k));
	
	/*����
	��è����������˵İ�����������
	����1MHzʱ���źţ���λ�źźͰ����źţ����������İ����ź�
	*/
	debounce deb1(.clk(clk), .rst(0), .key({rst, btn_cat, btn_dog, btn_rat, btn_ren}),
				.key_pulse(key));
endmodule
