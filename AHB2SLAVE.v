module AHB2SLAVE
#(parameter PixelBitWidth = 8, parameter Height = 32, parameter Width = 32)
(
	//AHBLITE INTERFACE
		//Slave Select Signals
			input wire HSEL,
		//Global Signal
			input wire HCLK,
			input wire HRESETn,
		//Address, Control & Write Data
			input wire HREADY,
			input wire [31:0] HADDR,
			input wire [1:0] HTRANS,
			input wire HWRITE,
			input wire [2:0] HSIZE,
			
			input wire [31:0] HWDATA,
		// Transfer Response & Read Data
			output reg HREADYOUT,
			output reg [31:0] HRDATA,

		//init_image
			input [7: 0] init_image
);

reg AddressPhase_HSEL;
reg AddressPhase_HWRITE;
reg [1: 0] AddressPhase_HTRANS;
reg [31: 0] AddressPhase_HADDR;
reg [2: 0] AddressPhase_HSIZE;

reg [PixelBitWidth - 1: 0] Image[Height * Width - 1: 0];
integer i;


//assign HREADYOUT = 1;

always @(posedge HCLK or negedge HRESETn) begin
	if (!HRESETn) begin
		// reset
		AddressPhase_HSEL <= 1'b0;
        AddressPhase_HWRITE <= 1'b0;
        AddressPhase_HTRANS <= 2'b00;
		AddressPhase_HADDR <= 32'h0;
		AddressPhase_HSIZE <= 3'b000;
		HREADYOUT <= 0;
		HRDATA <= 32'b0;
		for(i = 0; i < Height * Width - 1; i = i + 1) begin
			Image[i] <= init_image;
		end
		//Image <= init_image;
	end
	else if (HREADY & HSEL) begin
		AddressPhase_HSEL <= HSEL;
        AddressPhase_HWRITE <= HWRITE;
        AddressPhase_HTRANS <= HTRANS;
		AddressPhase_HADDR <= HADDR;
		AddressPhase_HSIZE <= HSIZE;
		HREADYOUT <= 1;

		//if being selected and read, load data to read data line. Next posedge of clk, master will read HRDATA
		if(~HWRITE & HTRANS[1]) begin
 			HRDATA[31: 24] <= Image[HADDR[10: 1]][PixelBitWidth - 1: 0];
			HRDATA[23: 16] <= Image[HADDR[10: 1] + 1][PixelBitWidth - 1: 0];
			HRDATA[15: 8] <= Image[HADDR[10: 1] + 2][PixelBitWidth - 1: 0];
			HRDATA[7: 0] <= Image[HADDR[10: 1] + 3][PixelBitWidth - 1: 0];
		end
	end
	else begin
		HREADYOUT <= 0;
		AddressPhase_HSEL <= 1'b0;
        AddressPhase_HWRITE <= 1'b0;
        AddressPhase_HTRANS <= 2'b00;
		AddressPhase_HADDR <= 32'h0;
		AddressPhase_HSIZE <= 3'b000;
	end
end


always @(posedge HCLK) begin
	if(AddressPhase_HSEL & AddressPhase_HWRITE & AddressPhase_HTRANS[1]) begin
		//write 4 bytes
		Image[AddressPhase_HADDR[10: 1]][PixelBitWidth - 1: 0] <= HWDATA[31: 24];
		Image[AddressPhase_HADDR[10: 1] + 1][PixelBitWidth - 1: 0] <= HWDATA[23: 16];
		Image[AddressPhase_HADDR[10: 1] + 2][PixelBitWidth - 1: 0] <= HWDATA[15: 8];
		Image[AddressPhase_HADDR[10: 1] + 3][PixelBitWidth - 1: 0] <= HWDATA[7: 0];
	end
end

endmodule