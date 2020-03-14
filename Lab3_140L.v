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
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module Lab3_140L (
		input wire       rst,             // reset signal (active high)
		input wire       clk,             // global clock
		input wire       bu_rx_data_rdy,  // data from the uart ready
		input wire [7:0] bu_rx_data,      // data from the uart
		output wire 	 L3_tx_data_rdy,  // data rdy to display
		output wire[7:0] L3_tx_data,      // data to display
		output wire[4:0] L3_led,          //5 LED control - 1: on, 0, off
		output wire      oneSecPluse,     //Generate 0.5 sec high and 0.5 sec low    	  
		output wire[6:0] L3_segment1,     //not used in Lab-2
		output wire[6:0] L3_segment2,     //not used in Lab-2
		output wire[6:0] L3_segment3,     //not used in Lab-2
		output wire[6:0] L3_segment4,     //not used in Lab-2

		output wire[3:0] di_Mtens,        //not used in Lab-2
		output wire[3:0] di_Mones,        //not used in Lab-2
		output wire[3:0] di_Stens,        //not used in Lab-2
		output wire[3:0] di_Sones,        //not used in Lab-2
		output wire[3:0] di_AMtens,       //not used in Lab-2
		output wire[3:0] di_AMones,       //not used in Lab-2
		output wire[3:0] di_AStens,       //not used in Lab-2
		output wire[3:0] di_ASones        //not used in Lab-2
    );
    wire[7:0] rx_data;
    wire rx_data_rdy;
    regrce #(8) Lab3U00 (
    .q(rx_data),
    .d(bu_rx_data),
    .ce(bu_rx_data_rdy),    //clock enable
    .rst(rst),              // synchronous reset
    .clk(clk)
    );
    regrce #(1) Lab3U01 (
    .q(rx_data_rdy),
    .d(bu_rx_data_rdy),
    .ce(1'b1),           //clock enable
    .rst(rst),           // synchronous reset
    .clk(clk)
    );
     
    // generate a sync signal
    //
    //                  | < ------- 1 sec -------|
    //
    //   oneSecStrb_____/----\_________......____/----\_______
    //
    //        clk  ___/--\__/--\__/--\.......__/--\__/--
    //
    wire l_oneSecPluse, l_oneSecStrb;
    Half_Sec_Pulse_Per_Sec secuu0 (
			.i_rst (rst),       //reset
			.i_clk (clk),       //system clk 12MHz 
            .o_sec_tick (l_oneSecPluse),
			.o_sec_enab (l_oneSecStrb)
        );

    wire dicSelectLEDdisp, dicRun;
    wire dicDspMtens, dicDspMones, dicDspStens, dicDspSones; //1:display, 0: don't display
    wire dicLdMtens, dicLdMones, dicLdStens, dicLdSones;     //1:load clk digit, 0: don't load
    wire [7:0] A1LocalOutput;
    wire [7:0] A2LocalOutput;
    wire [7:0] A3LocalOutput;
    wire [7:0] A4LocalOutput;
    wire [7:0] A5LocalOutput;
    wire [7:0] A6LocalOutput;
    wire alarm_activated;
    reg  alarm_flashing;

    dictrl dictrluu0(
        .dicSelectLEDdisp(dicSelectLEDdisp),
	    .dicRun(dicRun),             // clock should run
	    .alarm_activated(alarm_activated),
	    .dicDspMtens(dicDspMtens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspMones(dicDspMones),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspStens(dicDspStens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspSones(dicDspSones),   // 1: update 7 segment; 0: freeze 7 segment display
        .dicLdMtens(dicLdMtens),
        .dicLdMones(dicLdMones),
        .dicLdStens(dicLdStens),
        .dicLdSones(dicLdSones),
	.di_AMtens(di_AMtens),	
	.di_AMones(di_AMones),	
	.di_AStens(di_AStens),	
	.di_ASones(di_ASones),	
	.A1LocalOutput(A1LocalOutput),	
	.A2LocalOutput(A2LocalOutput),	
	.A3LocalOutput(A3LocalOutput),	
	.A4LocalOutput(A4LocalOutput),	
	.A5LocalOutput(A5LocalOutput),
	.A6LocalOutput(A6LocalOutput),
        .rx_data_rdy(rx_data_rdy),// new data from uart rdy
        .rx_data(rx_data),        // new data from uart
        .rst(rst),
	    .clk(clk)
    );

   didp didpuu0(
        // output
	    .di_iMtens(di_Mtens), // current 10's minutes
	    .di_iMones(di_Mones), // current 1's minutes
	    .di_iStens(di_Stens), // current 10's second
	    .di_iSones(di_Sones), // current 1's second
        .o_oneSecPluse(oneSecPluse),
        .L3_led(L3_led),
	.alarm_flashing(alarm_flashing),
		
		//loading clock
        .ldMtens(dicLdMtens), // set to 0 in lab3
        .ldMones(dicLdMones), // set to 0 in lab3
        .ldStens(dicLdStens), // set to 0 in lab3
        .ldSones(dicLdSones), // set to 0 in lab3
	    .ld_num(rx_data[3:0]), 
		
        .dicSelectLEDdisp(dicSelectLEDdisp),		
	    .dicRun(dicRun),                // 1: clock runs, 0: clock freeze 
        .i_oneSecPluse(l_oneSecPluse),	// 0.5 sec on, 0.5sec off
	    .i_oneSecStrb(l_oneSecStrb),    // one strobe per sec
	    .rst(rst),
	    .clk(clk) 	  
	);
	
	always @(posedge clk) begin
		//XOR each bit across the time itself and the alarm, therefore finding the equality between the two times
		if (~(((di_Mtens[3] ^ di_AMtens[3]) | (di_Mtens[2] ^ di_AMtens[2]) | (di_Mtens[1] ^ di_AMtens[1]) | (di_Mtens[0] ^ di_AMtens[0])) | 
			((di_Mones[3] ^ di_AMones[3]) | (di_Mones[2] ^ di_AMones[2]) | (di_Mones[1] ^ di_AMones[1]) | (di_Mones[0] ^ di_AMones[0])) | 
			((di_Stens[3] ^ di_AStens[3]) | (di_Stens[2] ^ di_AStens[2]) | (di_Stens[1] ^ di_AStens[1]) | (di_Stens[0] ^ di_AStens[0])) | 
			((di_Sones[3] ^ di_ASones[3]) | (di_Sones[2] ^ di_ASones[2]) | (di_Sones[1] ^ di_ASones[1]) | (di_Sones[0] ^ di_ASones[0])))) begin
			//gurantee that we can flash if we are in the activated alarm state specified in FSM	
			if (alarm_activated)
				alarm_flashing = 1;
		end
		//shouldn't flash when pressing the escape key or if not activated alarm
		if (rst | ~alarm_activated)
			alarm_flashing = 0;
    	end

    // convert to the presentation of 7 segment display
    bcd2segment dec0 (.segment(L3_segment1), .num(di_Sones), .enable((alarm_flashing) ? (l_oneSecPluse  & dicDspSones) : dicDspSones));
    bcd2segment dec1 (.segment(L3_segment2), .num(di_Stens), .enable((alarm_flashing) ? (l_oneSecPluse  & dicDspStens) :dicDspStens));
    bcd2segment dec2 (.segment(L3_segment3), .num(di_Mones), .enable((alarm_flashing) ? (l_oneSecPluse  & dicDspMones) :dicDspMones));
    bcd2segment dec3 (.segment(L3_segment4), .num(di_Mtens), .enable((alarm_flashing) ? (l_oneSecPluse  & dicDspMtens) :dicDspMtens));

    dispString dspStr (
		  .rdy(L3_tx_data_rdy)
        , .dOut(L3_tx_data)
		, .b0("A") 
		, .b1(A1LocalOutput)
		, .b2(A2LocalOutput)
		, .b3(A3LocalOutput)
		, .b4(A4LocalOutput) 
		, .b5(A5LocalOutput)
		, .b6(alarm_flashing ? "T" : A6LocalOutput)
		, .b7(8'h0d)
		, .go(l_oneSecStrb)	
		, .rst(rst)
		, .clk(clk)
    );
	
endmodule // Lab2_140L
