module Game(
	input CLOCK_50,
	input CONTROLLER_DATA,
	output CONTROLLER_LATCH,
	output CONTROLLER_PULSE,
	output reg [7:0] LED,
	output RED,
	output GREEN,
	output BLUE,
	output HSYNC,
	output VSYNC,
	output SPEAKER
);

wire pixelClock;
wire vSyncStart;
wire visibleArea;
wire [7:0] state;
wire [7:0] playerScore;
wire [7:0] computerScore;
wire [7:0] buttons;
wire [15:0] screenX;
wire [15:0] screenY;
wire [2:0] activePixel;
wire [15:0] ballX;
wire [15:0] ballY;
wire [7:0] ballXSpeed;
wire [7:0] ballYSpeed;
wire [15:0] playerPaddleY;
wire [15:0] computerPaddleY;
wire collisionBallScreenLeft;
wire collisionBallScreenRight;
wire collisionBallScreenTop;
wire collisionBallScreenBottom;
wire collisionBallPlayerPaddle;
wire collisionBallComputerPaddle;

// Instantiate modules.

Ball ball(pixelClock, vSyncStart, state, buttons,
	collisionBallScreenLeft, collisionBallScreenRight, collisionBallScreenTop, collisionBallScreenBottom,
	collisionBallPlayerPaddle, collisionBallComputerPaddle, ballX, ballY, ballXSpeed, ballYSpeed);

Collision collision(pixelClock, vSyncStart, ballX, ballY, ballXSpeed, ballYSpeed, playerPaddleY, computerPaddleY,
	collisionBallScreenLeft, collisionBallScreenRight, collisionBallScreenTop, collisionBallScreenBottom,
	collisionBallPlayerPaddle, collisionBallComputerPaddle);

ComputerPaddle computerPaddle(pixelClock, vSyncStart, state, ballY, collisionBallComputerPaddle, computerPaddleY);
NesController controller(pixelClock, vSyncStart, CONTROLLER_DATA, CONTROLLER_LATCH, CONTROLLER_PULSE, buttons);
GameState gameState(pixelClock, vSyncStart, buttons, collisionBallScreenLeft, collisionBallScreenRight, state, playerScore, computerScore);
PlayerPaddle playerPaddle(pixelClock, vSyncStart, buttons, playerPaddleY);
Renderer renderer(pixelClock, visibleArea, state, screenX, screenY, ballX, ballY, playerPaddleY, computerPaddleY, playerScore, computerScore, activePixel);

Sound sound(pixelClock, vSyncStart, collisionBallScreenLeft, collisionBallScreenRight,
	collisionBallScreenTop, collisionBallScreenBottom, collisionBallPlayerPaddle, collisionBallComputerPaddle, SPEAKER);

Vga vga(pixelClock, activePixel, RED, GREEN, BLUE, HSYNC, VSYNC, vSyncStart, visibleArea, screenX, screenY);
VgaPll vgaPll(CLOCK_50, pixelClock);

// Illuminate LEDs to show what controller buttons are pressed.

always @(posedge pixelClock)
	if (vSyncStart)
		LED <= buttons;

endmodule
