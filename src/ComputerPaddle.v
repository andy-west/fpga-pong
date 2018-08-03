module ComputerPaddle(
	input pixelClock,
	input vSyncStart,
	input [7:0] gameState,
	input [15:0] ballY,
	input collisionBallComputerPaddle,
	output reg [15:0] y
);

parameter
	width = 8'd16,
	height = 8'd48;

// Paddle is on right side of screen.
parameter x = 800 - width - 8;

// Start halfway down.
initial y = Vga.vVisibleLines / 8'd2 - height / 8'd2;

localparam [255:0] random = {
	128'HC57AF409D01FFD07558F17C906EA3919,
	128'HBCBBC7044F7C2B06D13E8F8DFD32887E
};

reg [7:0] randomIndex = 0;
reg [7:0] speed = 5;

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		if (collisionBallComputerPaddle)
			begin
				if (random[randomIndex +:4] < 3)
					speed <= 4;
				else
					speed <= 5;

				randomIndex <= randomIndex + 8'd4;
			end

		if (gameState == GameState.statePlaying)
			begin
				// If paddle is below ball move up, but not beyond top of screen.
				if (y + height / 2 > ballY + Ball.height / 2 & y > speed)
					y <= y - speed;

				// If paddle is above ball move down, but not beyond bottom of screen.
				if (y + height / 2 < ballY + Ball.height / 2 & y + height < Vga.vVisibleLines - speed)
					y <= y + speed;
			end
		else
			speed <= 5;
	end
end

endmodule
