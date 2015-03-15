`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:34 03/13/2015 
// Design Name: 
// Module Name:    test_lab5 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_lab5(bit_clk,valid,slot0,slot1,slot2,slot3,slot4,count,vdata,lpcm,rpcm,aud_sdata_out);
	input bit_clk;
	output reg [7:0] count;
	output reg valid,slot0,slot1,slot2,slot3,slot4,vdata,lpcm,rpcm;
	//output aud_sdata_in;
	output reg aud_sdata_out;
	//output aud_sync;
	//output aud_reset;
	
	reg [7:0] ac97_regaddr = 7'h02; // master volume register
	reg [7:0] ac97_regdata = {}	//will need to change volume controls
					//will change 

	reg [1:0] cmd_addr;
	reg [1:0] cmd_data;
	
	wire bclk;
	
	//will this come from codec
	IBUFG IBUG1(.O(bclk), .I(bit_clk));
	
	initial begin
		valid = 0;
		vdata =0;
		lpcm=0;
		rpcm=0;
		aud_sdata_out =0;
		slot0 = 0;
		slot1 = 0;
		slot2 = 0;
		slot3 = 0;
		slot4 = 0;
		count = 0;	
	end
	
	always @(posedge bclk)begin
		if(count==255)
			count <= 8'b0000_0000;
		else count <= count + 1;
	end

	
	always @(posedge bclk)begin
		//SLOT0
		//sents valid parts to AC'97
		if(count >= 0 && count <= 15)begin
			if(count == 0) aud_sdata_out <= 1'b1;
			else if(count == 1) aud_sdata_out <= 1'b1;
			else if(count == 2) aud_sdata_out <= 1'b1;
			else if(count == 3) aud_sdata_out <= 1'b1;
			else if(count == 4) aud_sdata_out <= 1'b1;
			else aud_sdata_out <= 1'b0;
		end
		
		//SLOT1
		else if(count >= 16 && count <= 35)begin
			//write = 0
			//read = 1
			if(count == 16)
				aud_sdata_out <= 1'b0;  //a write
			//pass register address -- 7 bits	
			else if(count > 16 && count <= 23)
				aud_sdata_out <= cmd_addr[23-count]; 
// master volume register,seem to display correct addr, 23 constant calc for correct traversal of ac97_regaddr
			else
				aud_sdata_out <= 1'b0;  // last 4 bits should be zero
		end
		
		//SLOT2
		//bit 19-4: 16 bits data to register
		//bit 3-0: put all 0's
		else if(count >= 36 && count <=55)begin
			if(count>= 52 && count <= 55)
				//pack with zeros
				aud_sdata_out <= 1'b0;
			else
				//send register data
				aud_sdata_out <= cmd_data[52-count];
		end
		
		//SLOT3
		//bit 19-4: pcm audio data left
		//is 2s complement
		else if(count >= 56 && count <= 75)begin
			if(count <= 65)
				aud_sdata_out <= 1'b0;
			else
				aud_sdata_out <= 1'b1;
		end
		
		//SLOT4
		//bit:19-4: psm audio data right
		//is 2's complement
		else if(count >= 76 && count <= 95)begin
			if(count <= 85)
				aud_sdata_out <= 1'b0;
			else
				aud_sdata_out <= 1'b1;
				
		end
	
		
	end // end of AC'97 frame making
	
	//controls what addr and data write
	always @(posdege clk)begin
		if(count == 255)begin
			frame <= frame + 1;
		end
		else frame <= frame;
	end

	
	//cycles threw changing reg addr and reg data	
	//not sure what will allow for actual audio sound
	always @(frame)begin
		if(frame == 2'b00) begin
			 cmd_addr = 7'h02; 		// master volume
			 cmd_data = 16'h0000;
		
		end		
		else if(frame== 2'b01)begin 
			cmd_addr = 7'h04;	    // headphone volume
			cmd_data = 16'h0000;
		end		
		else begin
			cmd_addr = 7'h18;	    // PCM Out Volume 
			cmd_data = 16'h8101;
		end		
	end
	
endmodule
