module debounce(clk, rst, key, key_pulse);

	parameter N = 5;
	input clk;
	input rst;
	input [N-1:0] key;
	output [N-1:0] key_pulse;
	reg [N-1:0] key_rst_pre;
	reg [N-1:0] key_rst;
	wire [N-1:0] key_edge;
	
	always@(posedge clk or posedge rst)
		begin
			if(rst)begin
				key_rst <= {N{1'b0}};
				key_rst_pre <= {N{1'b0}};
			end
			else begin
				key_rst <= ~key;
				key_rst_pre <= key_rst;
			end
		end
		
	assign key_edge = key_rst_pre & (~key_rst);
	
	reg [15:0] cnt;
	
	always@(posedge clk or posedge rst)
		begin
			if(rst)
				cnt <= 16'h0;
			else if(key_edge)
				cnt <= 16'h0;
			else
				cnt <= cnt + 1'h1;
		end
		
	reg [N-1:0] key_sec_pre;
	reg [N-1:0] key_sec;
	
	always@(posedge clk or posedge rst)
		begin
			if(rst)
				key_sec <= {N{1'b0}};
			else if(cnt == 16'h3fff)
				key_sec <= ~key;
		end
	
	always@(posedge clk or posedge rst)
		begin
			if(rst)
				key_sec_pre <= {N{1'b0}};
			else
				key_sec_pre <= key_sec;
		end
	
	assign key_pulse = key_sec_pre & (~key_sec);

endmodule