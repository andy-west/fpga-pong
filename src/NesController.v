module NesController(
	input pixelClock,
	input vSyncStart,
	input CONTROLLER_DATA,
	output reg CONTROLLER_LATCH,
	output reg CONTROLLER_PULSE,
	output reg [7:0] buttons
);

parameter
	buttonA = 8'd0,
	buttonB = 8'd1,
	buttonSelect = 8'd2,
	buttonStart = 8'd3,
	buttonUp = 8'd4,
	buttonDown = 8'd5,
	buttonLeft = 8'd6,
	buttonRight = 8'd7;

// Communication states
localparam
	idle = 0,
	setLatch = 1,
	readButton = 2;

// Latch and pulse timings
localparam
	clocksIn12us = 40000000 / 1000000 * 12,
	clocksIn6us = clocksIn12us / 8'd2;

reg [7:0] commState = idle;
reg [7:0] buttonSelected = buttonA;
reg [15:0] count = 0;

always @(posedge pixelClock)
begin
	if (vSyncStart)
	begin
		count <= 0;
		commState <= setLatch;
	end

	case(commState)
		setLatch:
			begin	
				if (count < clocksIn12us)
					begin
						CONTROLLER_LATCH <= 1;
						count <= count + 1'b1;
					end
				else
					begin
						CONTROLLER_LATCH <= 0;
						count <= clocksIn6us[15:0];
						buttonSelected <= buttonA;
						commState <= readButton;
					end
			end
		readButton:
			begin
				if (count < clocksIn6us)
					CONTROLLER_PULSE <= 1;
				else
					CONTROLLER_PULSE <= 0;

				if (count == clocksIn6us)
					buttons[buttonSelected] <= ~CONTROLLER_DATA;

				if (count < clocksIn12us)
					count <= count + 1'b1;
				else
					// Right D-pad button is the last button we check,
					// so when we're done reading it move to idle state.
					if (buttonSelected == buttonRight)
						commState <= idle;
					else
						begin
							count <= 0;
							buttonSelected <= buttonSelected + 1'b1;
						end
			end
		default:
			begin
				CONTROLLER_LATCH <= 0;
				CONTROLLER_PULSE <= 0;
			end
	endcase
end

endmodule
