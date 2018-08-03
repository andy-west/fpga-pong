module Sound(
	input pixelClock,
	input vSyncStart,
	input collisionBallScreenLeft,
	input collisionBallScreenRight,
	input collisionBallScreenTop,
	input collisionBallScreenBottom,
	input collisionBallPlayerPaddle,
	input collisionBallComputerPaddle,
	output reg SPEAKER
);

reg [25:0] count = 0;
reg [25:0] ticksPerHz;
reg [15:0] durationFrames = 0;

// Frequencies for different sounds
localparam ticks100Hz = 26'd40000000 / 15'd100 / 8'd2;
localparam ticks750Hz = 26'd40000000 / 15'd750 / 8'd2;
localparam ticks1kHz = 26'd40000000 / 15'd1000 / 8'd2;

always @(posedge pixelClock)
begin
	count <= count + 1'b1;

	if (vSyncStart)
		begin
			if (collisionBallScreenLeft | collisionBallScreenRight)
				begin
					count <= 0;
					ticksPerHz <= ticks100Hz;  // Low buzz when ball goes out of bounds
					durationFrames <= 60;
				end
			else
				if (durationFrames == 0)
					begin
						if (collisionBallScreenTop | collisionBallScreenBottom)
							begin
								count <= 0;
								ticksPerHz <= ticks750Hz;
								durationFrames <= 2;
							end

						if (collisionBallPlayerPaddle | collisionBallComputerPaddle)
							begin
								count <= 0;
								ticksPerHz <= ticks1kHz;
								durationFrames <= 2;
							end
					end
				else
					durationFrames <= durationFrames - 1'b1;
		end

	if (durationFrames > 0 & count >= ticksPerHz)
		begin
			SPEAKER <= ~SPEAKER;
			count <= 0;
		end
end

endmodule
