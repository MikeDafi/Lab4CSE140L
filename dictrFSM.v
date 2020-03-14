// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//Finite State Machine of Control Path
// using 3 always 
module dicClockFsm (
		output reg dicRun,     // clock is running
		output reg dicDspMtens,
		output reg dicDspMones,
		output reg dicDspStens,
		output reg dicDspSones,
        	output reg   dicLdMtens,
        	output reg   dicLdMones,
        	output reg   dicLdStens,
        	output reg   dicLdSones,
		output reg   [3:0] di_AMtens, // Actual value of current alarm
		output reg   [3:0] di_AMones, // ^
		output reg   [3:0] di_AStens, // ^
		output reg   [3:0] di_ASones, // ^
		output reg [7:0] A1LocalOutput,  // Current ASCII value being
		output reg [7:0] A2LocalOutput,  // displayed for alarm
		output reg [7:0] A3LocalOutput,  // (Could be different than
		output reg [7:0] A4LocalOutput,  // actual alarm if alarm
		output reg [7:0] A5LocalOutput,  // is not active)
		output reg [7:0] A6LocalOutput,  // ^
		output reg alarm_activated, // @ sign on / alarm active
        	input      det_cr,
        	input      det_S,      // S/s detected
        	input      det_A,
        	input      det_L,
		input      det_num,
		input	   det_num0to5,
		input	   det_atSign,
		input      rst,
		input      clk,
                input      [7:0] charData,
		input	   charDataValid
    );

    // First FSM (clock state)
    reg [3:0] cState = 4'h0;
    reg [3:0] nState = 4'h0;

    // Second FSM (alarm state)	 
    reg cAlarm = 1'b0;
    reg nAlarm = 1'b0;
	 
    localparam
	
	// Alarm activate states (DEACTIVATE AND ACTIVE
	// on Lecture Slides)
	ALARM_OFF_STATE = 1'b0,
	ALARM_ON_STATE = 1'b1,

	// Main clock STOP/RUN states
    	STOP = 4'h0, 
    	RUN = 4'h1, 
	// Time set states (LOAD_TIME in Lecture Slides)
	T1  = 4'h2,
	T2  = 4'h3,
	T3  = 4'h4,
	T4  = 4'h5,
	T5  = 4'h6,
	// Alarm set states (LOAD_ALARM in Lecture Slides)
	A1 = 4'h7,
	A2 = 4'h8,
	A3 = 4'h9,
	A4 = 4'hA,
	A5 = 4'hB,
	A6 = 4'hC;
	 
    // Transition between states
    // Certain Mealy-like outputs
    always @(negedge clk) begin 
	// Reset Load signals on each clock cycle
	dicLdMtens = 0;
	dicLdMones = 0;
	dicLdStens = 0;
	dicLdSones = 0;
	
	if (rst) begin
	        // Reset all values on esc/rst
		// No matter what state 
		nState = STOP;
		alarm_activated = 0;
		nAlarm = ALARM_OFF_STATE;
		di_AMtens = 4'd0;
	        di_AMones = 4'd0;
		di_AStens = 4'd0;
		di_ASones = 4'd0;
		A1LocalOutput = "-"; 
		A2LocalOutput = "-";
		A3LocalOutput = "-";
		A4LocalOutput = "-";
		A5LocalOutput = "-";
		A6LocalOutput = "-";
		end 
	else begin
		// Transitions for Alarm FSM (2 States)
		case(cAlarm)
			ALARM_OFF_STATE : begin		
				// Turn alarm off
				alarm_activated = 0;	
				
				// Switch alarm on @
				if(det_atSign) begin
					nAlarm = ALARM_ON_STATE;
					end
				else begin
					nAlarm = ALARM_OFF_STATE;	
				     end	
			end
			ALARM_ON_STATE : begin			
				// Switch alarm on @
				if(det_atSign) begin
					nAlarm = ALARM_OFF_STATE;
					end
				else begin
					nAlarm = ALARM_ON_STATE;
				        end
				// Turn alarm on
				alarm_activated = 1;
			end
		endcase
		case(cState)
			RUN : begin 
				if(det_A) begin
					nState = A1;
					// Set alarm display for new alarm
					A1LocalOutput = "0";
					A2LocalOutput = "-";
					A3LocalOutput = "-";
					A4LocalOutput = "-";
					A5LocalOutput = "-";
					A6LocalOutput = "-";
					end 
				else if(det_atSign) begin
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					// display current alarm val (00:00 by def)
					A1LocalOutput = "0" + di_AMtens;
					A2LocalOutput = "0" + di_AMones;
					A3LocalOutput = ":";
					A4LocalOutput = "0" + di_AStens;
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
				end
				else if(det_cr) begin
					// Stop alarm
					nState = STOP;
					end
				else if(det_L)  begin
					// Goto load time
					nState = T1;
					end
				else begin
					// Maintain state
					nState = cState;
					end
			end
			STOP : begin
				if(det_A) begin
					nState = A1;
					// Set alarm display for new alarm
					A1LocalOutput = "0";
					A2LocalOutput = "-";
					A3LocalOutput = "-";
					A4LocalOutput = "-";
					A5LocalOutput = "-";
					A6LocalOutput = "-";
				end 
				else if(det_atSign) begin
					// Set display to current alarm vals
					A1LocalOutput = "0" + di_AMtens;
					A2LocalOutput = "0" + di_AMones;
					A3LocalOutput = ":";
					A4LocalOutput = "0" + di_AStens;
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					end
				else if(det_L) begin
					// Goto load time
					nState = T1;
					end
				else if(det_S) begin
					// Start clock on S
					nState = RUN;
					end
				else begin
					// Maintain state
					nState = cState;
					end
			end
			
			T1 : begin 
				if(det_num0to5) begin 
					// Move to T2 and load for 1 clock cycle
					// if we get 0-5
					nState = T2;
					dicLdMtens = 1;
					end
				else begin
					// Maintain state
					nState = cState; 
					end
			end
			T2 : begin 
				if(det_num) begin
					// Move to T3 and load for 1 cycle on num
					nState = T3;
					dicLdMones = 1;
					end
				else begin
					// Maintain state
					nState = cState;
					end 
			end
			T3 : begin	
				if(det_num0to5) begin
					// Move to T4 and load for 1 cycle on 
					// 0-5
					dicLdStens = 1;
					nState = T4;
					end
				else begin
					// Maintain state
					nState = cState; 
					end
			end
			T4 : begin
				if(det_num) begin
					// Move to T5 and load for one cycle on num
					nState = T5;
					dicLdSones = 1;
					end
				else begin
					// Maintain state
					nState = cState;
					end 
			end
			T5 : begin		
				// Wait for enter or s to resume/stop	
				if(det_cr) begin
					nState = STOP;
					end
				else if(det_S) begin
					nState = RUN;
					end
				else begin
					// Wait/Maintain state
					nState = cState;
					end
			end
			
			A1 : begin
				if(det_num0to5) begin
					// Load first alarm val, set next to 0, set colon
					A2LocalOutput = "0";
					A3LocalOutput = ":";
					nState = A2;
					if (charDataValid) begin
						A1LocalOutput = charData;
						end
					end 
				else if(det_atSign) begin
					// Set alarm with current vals (none set yet)
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					A1LocalOutput = "0" + di_AMtens;
					A2LocalOutput = "0" + di_AMones;
					A3LocalOutput = ":";
					A4LocalOutput = "0" + di_AStens;
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
					end
				else begin
					// Maintain state
					nState = cState; 
					end
			end
			A2 : begin
				if(det_num) begin
					// Load second alarm val, set next (after colon) to 0
					nState = A3;
					if(charDataValid) begin
						A2LocalOutput = charData;
						end
					A4LocalOutput = "0";
					end 
				else if(det_atSign) begin
					// Set alarm with current vals (old + new Mtens)
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					di_AMtens = A1LocalOutput[3:0];
					A2LocalOutput = "0" + di_AMones;
					A4LocalOutput = "0" + di_AStens;
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
					end
				else begin
					// Maintain state
					nState = cState; 
					end
			end
			A3 : begin
				if(det_num0to5) begin
					// Load Stens val, set next to 00
					nState = A4;
					if(charDataValid) begin
						A4LocalOutput = charData;
						end
					A5LocalOutput = "0";
				end else if(det_atSign) begin
					// Set alarm with current vals (first 2 new)
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					di_AMtens = A1LocalOutput[3:0];
					di_AMones = A2LocalOutput[3:0];
					A4LocalOutput = "0" + di_AStens;
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
					end	
				else begin
					// Maintain state
					nState = cState; 
					end
			end
			A4 : begin
				if(det_num) begin
					// Set last alarm val
					nState = A5;
					if(charDataValid) begin
						A5LocalOutput = charData;
						end
					end 
				else if(det_atSign) begin
					// Set alarm with current vals (only Sones is old val)
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					di_AMtens = A1LocalOutput[3:0];
					di_AMones = A2LocalOutput[3:0];
					di_AStens = A4LocalOutput[3:0];
					A5LocalOutput = "0" + di_ASones;
					A6LocalOutput = "@";
					end	
				else begin
					// Maintain state
					nState = cState;
				end 
			end
			A5 : begin	
				if(det_atSign) begin
					// Set alarm (FULLY SET)
					nAlarm = ALARM_ON_STATE;
					nState = A6;
					di_AMtens = A1LocalOutput[3:0];
					di_AMones = A2LocalOutput[3:0];
					di_AStens = A4LocalOutput[3:0];
					di_ASones = A5LocalOutput[3:0];
					A6LocalOutput = "@";
					end	
				else begin
					// Otherwise, wait/maintain state
					nState = cState; 
					end
			end
			A6 : begin	
				// Alarm just set state. Wait for stop or run signal
				if(det_S) begin
					nState = RUN;
					end
				else if(det_cr) begin
					nState = STOP;
					end
				end
			// Default should never run, but maintains state
			// just in case
			default : begin 
				nState = cState;
			end
		endcase
		end
	end

	// Set Moore-like output (display signals)
	// Based on current state
	// Reduntant assigments of signals for 
	// Stable signals (fixed half-blinking)
	always @(*) begin
		case (cState)
	        	STOP : begin
				// Not running, displaying all digits
				dicRun = 0;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 1; 
				dicDspSones = 1;
	        		end
	        	RUN : begin
				// Running, dislaying all digits
				dicRun = 1;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 1; 
				dicDspSones = 1;
	        		end
			T1 : begin
				// Maintain dic run, only show digit loading
				dicRun = dicRun;
				dicDspMtens = 1; 
				dicDspMones = 0; 
				dicDspStens = 0; 
				dicDspSones = 0;
			  	end
			T2 : begin
				// Maintain dic run, show 2 loading digits
				dicRun = dicRun;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 0; 
				dicDspSones = 0;
			  	end
			T3 : begin
				// Maintain dic run, show 3 loading digits
				dicRun = dicRun;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 1; 
				dicDspSones = 0;
			  	end
			T4 : begin
				// Maintain dic run, show all digits (last load)
				dicRun = dicRun;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 1; 
				dicDspSones = 1;
			  	end
			T5 : begin
				// Last load (show all digits) / maintain dic run
				dicRun = dicRun;
				dicDspMtens = 1; 
				dicDspMones = 1; 
				dicDspStens = 1; 
				dicDspSones = 1;
			  	end
			default: begin
				// In alarm states, maintain run state and display all
			        dicRun = dicRun;
				dicDspMtens = 1;
				dicDspMones = 1;
				dicDspStens = 1;
				dicDspSones = 1;
			        end
        endcase
   end

   // Update both FSMs each clk cycle
   always @(posedge clk) begin
      	cState <= nState;
	cAlarm <= nAlarm;
   end

endmodule
