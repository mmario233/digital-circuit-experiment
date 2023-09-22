module game_better(
					input clk,
					rst,
					btn_cat,//按键—带猫过河
					btn_dog, //按键—带狗过河
					btn_rat, //按键—带鼠过河
					btn_ren, //按键—人单独过河
					sw,//总开关
					input [1:0] levelchoices,//拨码0、1设置难度
					output reg [15:0] led,//led输出
					output [7:0] seg_f,//数码管阳极信号
					cat,//阴极信号
					output reg [7:0] row,//点阵阴极信号
					col_r,//点阵阳极信号（红）
					col_g,//点阵阳极信号（绿）
					output beeps//蜂鸣器输入信号
					);
	
	reg [3:0] onboat;//在船上（3猫，2狗，1鼠，0人）
	reg [7:0] col_r_cat, col_g_dog, col_rat;
	wire [4:0] key;//消抖后的信号（3猫，2狗，1鼠，0人）
	reg [3:0] count;//计数器
	reg [3:0] cnt_h, cnt_1;//计步器（十位、个位）
	reg [3:0] pos;//位置（3猫，2狗，1鼠，0人）
	reg status;//状态（是否可用）
	reg [7:0] seg [9:0];//存储0~9的数码管显示
	reg [7:0] seg1, seg2, seg3, seg4;//十位、个位显示
	parameter [7:0] start = 8'h3; //点阵初始状态
	reg level;//难度可设置标志
	reg [4:0] mstep;//最大步数
	reg [1:0] tune_id = 0;//蜂鸣器谱子id
	
	initial//初始化
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
	以复位键和时钟信号上升沿为触发沿，
	对总开关sw，状态status和消抖后的按键信号key进行监测
	，根据情况对位置状态pos、在船上状态onboat和调用任务counter对步数进行更改 
	*/
	always@(posedge clk or posedge key[4])
	begin
		if(key[4])//复位
		begin
			onboat = 0;
			pos = 0;
			level = 1;
			counter(rst, sw, cnt_1, cnt_h);//调用任务counter
		end
		else if(!sw)
		begin
			onboat = 0;
			pos = 0;
			level = 1;
			counter(rst, sw, cnt_1, cnt_h);
		end
		else if(status)//是否可操作
		begin
			if(count == 0)//到对岸后下船
			begin
				onboat = 0;
			end
			else if(onboat == 0)//船空时才接受信号（即过河时无效）
			begin
				if(key[3] && pos[3] == pos[0])//带猫过河
				begin
					level = 0;
					onboat[3] = 1;
					pos[3] = ~pos[3];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[2] && pos[2] == pos[0]) //带狗过河
				begin
					level = 0;
					onboat[2] = 1;
					pos[2] = ~pos[2];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[1] && pos[1] == pos[0]) //带鼠过河
				begin
					level = 0;
					onboat[1] = 1;
					pos[1] = ~pos[1];
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
				else if(key[0])//人自己过河
				begin
					level = 0;
					onboat[0] = 1;
					pos[0] = ~pos[0];
					counter(key[4], sw, cnt_1, cnt_h);
				end
			end
		end
	end
	/*用4Hz的时钟信号进行4s的计时*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//复位
		begin
			count <= 4'b1111;
		end
		else if(!sw)
		begin
			count <= 4'b1111;
		end
		else if(count == 0)//重回4s
		begin
			count <= 4'b1111;
		end
		else if(onboat)//过河计时
		begin
			count <= count - 1'b1;
		end
	end
	/*用4Hz时钟信号实现点阵的变化，四秒四种状态，变换3次*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//复位
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
		else if(sw && col_rat == 0)//开机重置
		begin
			col_r_cat = start;
			col_rat = start;
			col_g_dog = start;
		end
		else if(count % 4 == 0 && count != 0)//点阵每秒变化一次
		begin
			if(pos[0]==1)//左到右
			begin
				if(onboat[3])
				col_r_cat <= {col_r_cat[5:0], col_r_cat[7:6]};
				else if(onboat[2])
				col_g_dog <= {col_g_dog[5:0], col_g_dog[7:6]};
				else if(onboat[1])
				col_rat <= {col_rat[5:0], col_rat[7:6]};
			end
			else//右到左
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
	/*led灯状态，过河时每1/4秒变化一次，并在动物全部过河后全亮
	在达到最大步数或动物位置不对（只有猫狗或猫鼠在一岸）时全灭*/
	always@(posedge clk4Hz or posedge key[4])
	begin
		if(key[4])//复位
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
		else if(sw && led == 0 && col_rat == 0)//开机重置
		begin
			led <= 16'h8000;
			status <= 1;
			tune_id <= 2'd0;
		end
		else if(count == 4'b1111 && !onboat)//到对岸才判断
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
		else if(count!=4'b1111)//过河时
		begin
			if(pos[0] == 1)//左到右
			begin
				led <= {led[0],led[15:1]};
			end
			else if(pos[0] == 0)//右到左
			begin
				led <= {led[14:0],led[15]};
			end
		end
	end
	//任务：计步器
	//记录当前步数
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
	//将十位、个位变成数码管信号
	always@(cnt_1 or cnt_h)
	begin
		seg2 = seg[cnt_1];
		seg1 = seg[cnt_h];
	end
	//根据拨码0、1的组合，实现难度设置，最大步数改变
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
	//将难度对应的最大步数的十位、个位变成数码管信号
	always@(levelchoices)
	begin
		seg3 = seg[mstep/10];
		seg4 = seg[mstep%10];
	end
	//蜂鸣器信号
	//输入1MHz的时钟信号，复位信号、使能信号，谱子id
	//输出蜂鸣器信号
	beeper bp1(.clk(clk),
				.rst(rst),
				.en(sw),
				.tune_id(tune_id),
				.piano_out(beeps));		
	//点阵实现
	//输入1kHz的时钟，猫狗鼠对应的状态，输出点阵列信号（红、绿），行信号。
	dianzhen dz1(.clk_1kHz(clk1k),
				.colred_cat(col_r_cat),
				.colgreen_dog(col_g_dog),
				.col_rat(col_rat),
				.row(row),
				.col_r(col_r),
				.col_g(col_g),
				.led(led));			
	//数码管显示
	//输入1kHz的时钟，步数（十位、个位），输出数码管信号（阳极、阴极）。
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
	/*时钟分频1kHz、4Hz
	传入参数位宽10位，计数1000，
1kHz时钟的一个周期等于1MHz时钟的1000个周期
	输入时钟1MHz和复位信号，输出1kHz时钟;
	传入参数位宽18位，计数250000，
4Hz时钟的一个周期等于1MHz时钟的250000个周期
	输入时钟1MHz和复位信号，输出4Hz时钟
	*/
	dividend #(.WIDTH(18), .N(250000)) d1(.clk(clk), .rst_n(0), .clkout(clk4Hz));
	dividend #(.WIDTH(10), .N(1000)) d2(.clk(clk), .rst_n(0), .clkout(clk1k));
	
	/*消抖
	对猫、狗、鼠和人的按键进行消抖
	输入1MHz时钟信号，复位信号和按键信号，输出消抖后的按键信号
	*/
	debounce deb1(.clk(clk), .rst(0), .key({rst, btn_cat, btn_dog, btn_rat, btn_ren}),
				.key_pulse(key));
endmodule
