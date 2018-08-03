module Renderer(
	input pixelClock,
	input visibleArea,
	input [7:0] gameState,
	input [15:0] screenX,
	input [15:0] screenY,
	input [15:0] ballX,
	input [15:0] ballY,
	input [15:0] playerPaddleY,
	input [15:0] computerPaddleY,
	input [7:0] playerScore,
	input [7:0] computerScore,
	output reg [2:0] screenPixel
);

// Colors
localparam
	black = 3'b000,
	blue = 3'b001,
	green = 3'b010,
	cyan = 3'b011,
	red = 3'b100,
	magenta = 3'b101,
	yellow = 3'b110,
	white = 3'b111;

// Character graphics for digits 9-0.
localparam [149:0] digits = {	
	15'b111101101101111,
	15'b010010010010010,
	15'b111001111100111,
	15'b111001111001111,
	15'b101101111001001,
	15'b111100111001111,
	15'b111100111101111,
	15'b111001001001001,
	15'b111101111101111,
	15'b111101111001001
};

reg [2:0] gameOverBackgroundColor = white;
reg [2:0] backgroundColor = blue;

reg [7:0] digitX;
reg [7:0] digitY;

reg [2:0] ballPixel;
reg [2:0] playerPaddlePixel;
reg [2:0] computerPaddlePixel;
reg [2:0] computedPixel;
reg [2:0] playerDigitPixel;
reg [2:0] computerDigitPixel;

always @(posedge pixelClock)
begin
	if (visibleArea)
	begin
		if (screenX >= ballX
			& screenX < ballX + Ball.width
			& screenY >= ballY
			& screenY < ballY + Ball.height)
			ballPixel <= white;
		else
			ballPixel <= black;

		if (screenX >= PlayerPaddle.x
			& screenX < PlayerPaddle.x + PlayerPaddle.width
			& screenY >= playerPaddleY
			& screenY < playerPaddleY + PlayerPaddle.height)
			playerPaddlePixel <= cyan;
		else
			playerPaddlePixel <= black;

		if (screenX >= ComputerPaddle.x
			& screenX < ComputerPaddle.x + ComputerPaddle.width
			& screenY >= computerPaddleY
			& screenY < computerPaddleY + ComputerPaddle.height)
			computerPaddlePixel <= cyan;
		else
			computerPaddlePixel <= black;

		playerDigitPixel <= black;
		computerDigitPixel <= black;

		// Scan through 3x5 pixels of player and computer score digits.
		for (digitY = 8'd0; digitY < 8'd5; digitY = digitY + 1'b1)
			begin
				for (digitX = 8'd0; digitX < 8'd3; digitX = digitX + 1'b1)
					begin
						if (screenX >= digitX * 12 + 200
							& screenX < digitX * 12 + 211
							& screenY >= digitY * 12 + 30
							& screenY < digitY * 12 + 41
							& digits[149 - (15 * playerScore + digitY * 3 + digitX)])
							playerDigitPixel <= yellow;

						if (screenX >= digitX * 12 + 564
							& screenX < digitX * 12 + 575
							& screenY >= digitY * 12 + 30
							& screenY < digitY * 12 + 41
							& digits[149 - (15 * computerScore + digitY * 3 + digitX)])
							computerDigitPixel <= yellow;
					end
			end

		computedPixel <= ballPixel | playerPaddlePixel | computerPaddlePixel | playerDigitPixel | computerDigitPixel;

		if (computedPixel == black)  // Black gets replaced by background color.
			if (gameState == GameState.stateGameOver)
				// Produce a checkerboard dither pattern with black and background color.
				// Makes background "dim" when game is over.
				if (screenX[0] + screenY[0])
					screenPixel <= gameOverBackgroundColor;
				else
					screenPixel <= black;
			else
				screenPixel <= backgroundColor;
		else
			screenPixel <= computedPixel;
	end
end

endmodule
