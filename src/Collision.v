module Collision(
	input pixelClock,
	input vSyncStart,
	input [15:0] ballX,
	input [15:0] ballY,
	input [7:0] ballXSpeed,
	input [7:0] ballYSpeed,
	input [15:0] playerPaddleY,
	input [15:0] computerPaddleY,
	output reg collisionBallScreenLeft = 0,
	output reg collisionBallScreenRight = 0,
	output reg collisionBallScreenTop = 0,
	output reg collisionBallScreenBottom = 0,
	output reg collisionBallPlayerPaddle = 0,
	output reg collisionBallComputerPaddle = 0
);

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		if (ballX == 0)
			collisionBallScreenLeft <= 1;
		else
			collisionBallScreenLeft <= 0;
			
		if (ballX + Ball.width == Vga.hVisiblePixels)
			collisionBallScreenRight <= 1;
		else
			collisionBallScreenRight <= 0;

		if (ballY == 0)
			collisionBallScreenTop <= 1;
		else
			collisionBallScreenTop <= 0;

		if (ballY + Ball.height == Vga.vVisibleLines)
			collisionBallScreenBottom <= 1;
		else
			collisionBallScreenBottom <= 0;
			
		if (ballX < PlayerPaddle.x + PlayerPaddle.width + ballXSpeed
			& ballY > playerPaddleY
			& ballY < playerPaddleY + PlayerPaddle.height)
			collisionBallPlayerPaddle <= 1;
		else
			collisionBallPlayerPaddle <= 0;
			
		if (ballX + Ball.width >= ComputerPaddle.x - ballXSpeed
			& ballY > computerPaddleY
			& ballY < computerPaddleY + ComputerPaddle.height)
			collisionBallComputerPaddle <= 1;
		else
			collisionBallComputerPaddle <= 0;
	end
end

endmodule
