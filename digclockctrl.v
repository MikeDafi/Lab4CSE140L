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

module dictrl(
        output    dicSelectLEDdisp, //select LED
	output 	  dicRun,           // clock should run
	output 	  dicDspMtens,
	output 	  dicDspMones,
	output 	  dicDspStens,
	output 	  dicDspSones,
        output    dicLdMtens,
        output    dicLdMones,
        output    dicLdStens,
        output    dicLdSones,
	output    [3:0] di_AMtens,
	output    [3:0] di_AMones,
	output    [3:0] di_AStens,
	output    [3:0] di_ASones,
	output    [7:0] A1LocalOutput,
	output    [7:0] A2LocalOutput,
	output    [7:0] A3LocalOutput,
	output    [7:0] A4LocalOutput,
	output    [7:0] A5LocalOutput,
	output    [7:0] A6LocalOutput,
	output      alarm_activated,
        input 	    rx_data_rdy,// new data from uart rdy
        input [7:0] rx_data,    // new data from uart
        input 	  rst,
	input 	  clk
    );
	
    wire   det_cr; //to retrieve the character return key
    wire   det_S; //to retrieve the 'S' key to start clock
    wire   det_A; // to retrieve the 'A' key to set Alarm
    wire   det_L; //to retrieve 'L' key to load
    wire   det_num; // to retrieve key numbers for eventually loading itme or alarm
    wire   det_num0to5; // to retrieve the tens values needed for load and alarm
    wire   det_atSign; // for enabling the alarm
   
    decodeKeys dek ( 
        .det_cr(det_cr),
	.det_S(det_S),             
        .det_N(dicSelectLEDdisp),
	.det_A(det_A),
	.det_L(det_L),
	.det_num(det_num),
	.det_num0to5(det_num0to5),
	.det_atSign(det_atSign),
	.charData(rx_data),      .charDataValid(rx_data_rdy)
    );

    
    dicClockFsm dicfsm (
            .dicRun(dicRun),
	    .alarm_activated(alarm_activated),
            .dicDspMtens(dicDspMtens), 
	    .dicDspMones(dicDspMones),
            .dicDspStens(dicDspStens), 
	    .dicDspSones(dicDspSones),
            .det_cr(det_cr),
            .det_S(det_S), 
            .det_A(det_A),
	    .det_L(det_L),
	    .det_num(det_num),
	    .det_num0to5(det_num0to5),
	    .det_atSign(det_atSign),
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
            .rst(rst),
            .clk(clk),
	    .charData(rx_data),      
	    .charDataValid(rx_data_rdy),
            .dicLdMtens(dicLdMtens),
            .dicLdMones(dicLdMones),
            .dicLdStens(dicLdStens),
            .dicLdSones(dicLdSones)
    );
   
endmodule


