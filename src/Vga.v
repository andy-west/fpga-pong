module Vga(
	input pixelClock,
	input [2:0] activePixel,
	output reg RED,
	output reg GREEN,
	output reg BLUE,
	output reg HSYNC,
	output reg VSYNC,
	output reg vSyncStart,
	output reg visibleArea,
	output reg [15:0] screenX,
	output reg [15:0] screenY
);

reg [15:0] hPos = 0;
reg [15:0] vPos = 0;

parameter [15:0] hVisiblePixels = 800;
localparam [7:0] hBackPorchPixels = 88;
localparam [7:0] hSyncPixels = 128;
localparam [7:0] hFrontPorchPixels = 40;
localparam [15:0] hTotalPixels = hVisiblePixels + hFrontPorchPixels + hSyncPixels + hBackPorchPixels;

parameter [15:0] vVisibleLines = 600;
localparam [7:0] vBackPorchLines = 23;
localparam [7:0] vSyncLines = 4;
localparam [7:0] vFrontPorchLines = 1;
localparam [15:0] vTotalLines = vVisibleLines + vFrontPorchLines + vSyncLines + vBackPorchLines;

always @(posedge pixelClock)
begin
	hPos <= hPos + 1'b1;

	if (hPos >= hTotalPixels)
	begin
		hPos <= 0;
		vPos <= vPos + 1'b1;

		if (vPos >= vTotalLines)
			vPos <= 0;
	end

	if ((vPos >= vBackPorchLines)
		& (vPos < vBackPorchLines + vVisibleLines)
		& (hPos >= hBackPorchPixels)
		& (hPos < hBackPorchPixels + hVisiblePixels))
		begin
			visibleArea <= 1;

			RED <= activePixel[2];
			GREEN <= activePixel[1];
			BLUE <= activePixel[0];
		end
	else
		begin
			visibleArea <= 0;

			RED <= 0;
			GREEN <= 0;
			BLUE <= 0;
		end

	if (hPos < hTotalPixels - hSyncPixels)
		HSYNC <= 1;
	else
		HSYNC <= 0;

	if (vPos < vTotalLines - vSyncLines)
		VSYNC <= 1;
	else
		VSYNC <= 0;

	// This happens one clock tick per frame.
	if (vPos == vTotalLines - vSyncLines & hPos == 0)
		vSyncStart <= 1;
	else
		vSyncStart <= 0;

	screenX <= hPos - hBackPorchPixels;
	screenY <= vPos - vBackPorchLines;
end

endmodule
