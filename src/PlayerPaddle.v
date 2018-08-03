module PlayerPaddle(
	input pixelClock,
	input vSyncStart,
	input [7:0] buttons,
	output reg [15:0] y
);

parameter
	width = 8'd16,
	height = 8'd48;

// Paddle is on left side of screen.
parameter x = 8;

// Start halfway down.
initial y = 16'd300 - height / 8'd2;

localparam [7:0] speed = 5;

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		// Move up when button is pressed, but not beyond top of screen.
		if (buttons[NesController.buttonUp] & y > speed)
			y <= y - speed;

		// Move down when button is pressed, but not beyond bottom of screen.
		if (buttons[NesController.buttonDown] & y + height < Vga.vVisibleLines - speed)
			y <= y + speed;
	end
end

endmodule
