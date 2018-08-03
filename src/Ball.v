module Ball(
	input pixelClock,
	input vSyncStart,
	input [7:0] gameState,
	input [7:0] buttons,
	input collisionBallScreenLeft,
	input collisionBallScreenRight,
	input collisionBallScreenTop,
	input collisionBallScreenBottom,
	input collisionBallPlayerPaddle,
	input collisionBallComputerPaddle,
	output reg [15:0] x,
	output reg [15:0] y,
	output reg [7:0] xSpeed,
	output reg [7:0] ySpeed
);

parameter
	width = 8'd16,
	height = 8'd16;

// Start ball in the middle of the screen.

initial x = Vga.hVisiblePixels / 8'd2 - width / 8'd2;
initial y = Vga.vVisibleLines / 8'd2 - height / 8'd2;

initial xSpeed = 5;
initial ySpeed = 5;

reg xDirection = 0;
reg yDirection = 0;

reg [31:0] computerPaddleX = ComputerPaddle.x;
reg [31:0] playerPaddleX = PlayerPaddle.x;
reg [31:0] playerPaddleWidth = PlayerPaddle.width;

always @(posedge pixelClock)
begin
	if (vSyncStart)
		begin
			if (gameState == GameState.statePlaying)
				begin
					if (xDirection)  // Ball is moving right.
						begin
							if (collisionBallScreenRight)
								begin
									xDirection <= 0;
								end
							else
								begin
									if (collisionBallComputerPaddle)
										begin
											// Fix ball location in case it's intersecting paddle.
											x <= computerPaddleX[15:0] - width - 1'b1;

											// Flip ball direction to move left.
											xDirection <= 0;
										end
									else
										begin
											// Move ball right, but prevent if from going off-screen.
											if (x + width + xSpeed < Vga.hVisiblePixels)
												x <= x + xSpeed;
											else
												x <= Vga.hVisiblePixels - width;
										end
								end
						end
					else
						begin
							if (collisionBallScreenLeft)
								begin
									xDirection <= 1;
								end
							else
								begin
									if (collisionBallPlayerPaddle)
										begin
											// Fix ball location in case it's intersecting paddle.
											x <= playerPaddleX[15:0] + playerPaddleWidth[15:0];

											// Flip ball direction to move right.
											xDirection <= 1;
										end
									else
										begin
											// Move ball left, but prevent if from going off-screen.
											if (x > xSpeed)
												x <= x - xSpeed;
											else
												x <= 0;
										end
								end
						end

					if (yDirection)  // Ball is moving down.
						begin
							if (collisionBallScreenBottom)
								begin
									// Flip ball direction to move up.
									yDirection <= 0;
								end
							else
								begin
									// Move ball down, but prevent if from going off-screen.
									if (y + height + ySpeed < Vga.vVisibleLines)
										y <= y + ySpeed;
									else
										y <= Vga.vVisibleLines - height;
									end
						end
					else
						begin
							if (collisionBallScreenTop)
								begin
									// Flip ball direction to move down.
									yDirection <= 1;
								end
							else
								begin
									// Move ball up, but prevent if from going off-screen.
									if (y > ySpeed)
										y <= y - ySpeed;
									else
										y <= 0;
								end
						end
				end
			else
				begin
					// Move ball to the middle of the screen.
					x <= Vga.hVisiblePixels / 8'd2 - width / 8'd2;
					y <= Vga.vVisibleLines / 8'd2 - height / 8'd2;
				end
		end
end

endmodule