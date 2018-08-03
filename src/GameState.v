module GameState(
	input pixelClock,
	input vSyncStart,
	input [7:0] buttons,
	input collisionBallScreenLeft,
	input collisionBallScreenRight,
	output reg [7:0] state = stateGameOver,
	output reg [7:0] playerScore = 0,
	output reg [7:0] computerScore = 0
);

// Game states
parameter
	stateGameOver = 8'd0,
	statePlaying = 8'd1,
	statePlayerScored = 8'd2,
	stateComputerScored = 8'd3;

reg startButtonReleased = 0;
reg [15:0] count = 0;

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		case(state)
			stateGameOver:
				begin
					// Wait until button is not pressed before checking to see if it's pressed.
					// This way we don't skip the game-over state if button is already held down.
					if (~buttons[NesController.buttonStart])
						startButtonReleased <= 1;

					if (startButtonReleased & buttons[NesController.buttonStart])
						begin
							playerScore <= 0;
							computerScore <= 0;
							state <= statePlaying;
						end
				end
			statePlaying:
				begin
					if (collisionBallScreenLeft)
						begin
							count <= 0;
							state <= stateComputerScored;
						end

					if (collisionBallScreenRight)
						begin
							count <= 0;
							state <= statePlayerScored;
						end
				end
			statePlayerScored:
				begin
					if (playerScore == 9)
						state <= stateGameOver;
					else
						if (count == 0)
							begin
								playerScore <= playerScore + 1'b1;

								if (playerScore == 9)
									state <= stateGameOver;

								count <= count + 1'b1;
							end
						else
							begin
								if (count < 60 * 2)
									begin
										count <= count + 1'b1;
									end
								else
									begin
										if (buttons[NesController.buttonA])
											state <= statePlaying;
									end
							end
				end
			stateComputerScored:
				begin
					if (computerScore == 9)
						state <= stateGameOver;
					else
						if (count == 0)
							begin
								computerScore <= computerScore + 1'b1;
								count <= count + 1'b1;
							end
						else
							begin
								if (count < 60 * 2)
									begin
										count <= count + 1'b1;
									end
								else
									begin
										if (buttons[NesController.buttonA])
											state <= statePlaying;
									end
							end
				end
		endcase
	end
end

endmodule
