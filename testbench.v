`timescale 1ns/1ns


module testbench();

reg HCLK;
wire HSEL;
reg HRESETn;
reg HREADY;
wire HREADYOUT;
reg [31: 0] HADDR;
reg [1: 0] HTRANS;
reg HWRITE;
reg [2: 0] HSIZE;
reg [31: 0] HWDATA;
reg [2: 0] count;
wire [31: 0] HRDATA;
reg [7: 0] init_image;
integer i;

initial begin
	HCLK <= 0;
	HRESETn <= 1;

	init_image <= 8'b0000_1111;

	#20 
	HRESETn = 0;
	#20
	HRESETn = 1;

	HTRANS <= 2'b10;
	HSIZE <= 3'b010;
end

always #10 HCLK = ~HCLK;
assign HSEL = HADDR[0];

always @(posedge HCLK or negedge HRESETn) begin
	if(!HRESETn) begin
		HADDR <= 0;
		HREADY <= 0;
		HTRANS <= 2'b00;
		HWRITE <= 0;
		HSIZE <= 2'b00;
		HWDATA <= 0;
		count <= 3'b0;
	end
	else begin
		if(count == 0) begin
			HADDR <= 32'b0000_0000_0000_0000_0000_0000_0000_0001;
			HWRITE <= 0;
			HREADY <= 1;
			count = count + 1;
		end
		else if(count == 1) begin
			HADDR <= 32'b0000_0000_0000_0000_0000_0000_0000_0001;
			HWRITE <= 1;
			HREADY <= 1;
			count = count + 1;
		end
		else if(count == 2) begin
			HWDATA <= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
			HADDR <= 32'b0000_0000_0000_0000_0000_0000_0001_0001;
			HREADY <= 1;
			HWRITE <= 0;
			count = count + 1;
		end
		else if(count == 3) begin
			HADDR <= 32'b0000_0000_0000_0000_0000_0000_0000_1000;
			HWRITE <= 0;
			HREADY <= 1;
			count = count + 1;
		end
		else begin
			HADDR <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
			HWRITE <= 0;
			HREADY <= 0;
			count <= count + 1;
		end
	end
end

AHB2SLAVE test(.HSEL(HSEL), .HCLK(HCLK), .HRESETn(HRESETn), .HREADY(HREADY), .HADDR(HADDR), 
	.HTRANS(HTRANS), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWDATA(HWDATA), .HREADYOUT(HREADYOUT), .HRDATA(HRDATA), .init_image(init_image));

endmodule