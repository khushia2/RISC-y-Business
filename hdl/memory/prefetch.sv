module prefetcher#(
    parameter s_offset = 6,
    parameter s_index  = 2,
    parameter s_tag    = 32 - s_offset - s_index
)
(
   input logic clk,
   input logic rst,
   input logic [31:0] data_addr,
   input logic [31:0] data_PC,
	input	logic pref_resp,
	output logic pref_read,
	output logic[31:0] pref_addr
);

logic tag_match, state_load, stride_load, pref_read_in;
logic[s_tag-1:0] tag;
logic[31:0] prev_addr, prev_stride, cur_stride, pref_addr_in;
logic[1:0] state, next_state;

////state machine
//enum logic[1:0] {
//   Initial,				//00
//   Transient,			//01
//   Steady,				//10
//	  Fetching				//11
//} state, next_state;

always_ff@(posedge clk)begin
	if(rst) begin
		pref_read <= 1'b0;
		pref_addr <= '0;
	end
	if (pref_read_in && (!pref_read))begin
		pref_read <= 1'b1;
		pref_addr <= pref_addr_in;
	end
	if(pref_resp) begin
		pref_read <= 1'b0;
		pref_addr <= '0;
	end
end

always_comb begin
	
	cur_stride = data_addr - prev_addr;
	
	state_load = 1'b0;
	stride_load = 1'b0;
	
   next_state = state;
	
	pref_read_in = 1'b0;
	pref_addr_in = data_addr + cur_stride;
	
   case (state)
      2'b00: begin	//Initial
			if (tag_match && (cur_stride != 0)) begin
				state_load = 1'b1;
				stride_load = 1'b1;
				next_state = 2'b01;	//Transient
			end	
			end
      2'b01: begin	//Transient
			if (tag_match) begin
				if (cur_stride == prev_stride)begin
					state_load = 1'b1;
					next_state = 2'b10;	//Steady
				end
				else begin
					state_load = 1'b1;
					next_state = 2'b00;	//Initial
				end
			end
			else begin
				state_load = 1'b1;
				next_state = 2'b00;	//Initial
			end
         end
      2'b10: begin	//Steady
			if (tag_match) begin
				if (cur_stride == prev_stride)begin
					pref_read_in = 1'b1; //PREFETCH!
				end
				else begin
					state_load = 1'b1;
					next_state = 2'b00;	//Initial
				end
			end
			else begin
				state_load = 1'b1;
				next_state = 2'b00;	//Initial
			end
         end
   endcase
end

assign tag_match = (tag == data_PC[31:s_offset+s_index]);
array #(s_index,s_tag) tag_arr(
	.clk,
	.rst,
	.load((data_PC!='0)),
	.index(data_PC[s_offset+s_index-1:s_offset]),
	.datain(data_PC[31:s_offset+s_index]),
	.dataout(tag)
);
array #(s_index,32) addr_arr(
	.clk,
	.rst,
	.load((data_PC!='0)),
	.index(data_PC[s_offset+s_index-1:s_offset]),
	.datain(data_addr),
	.dataout(prev_addr)
);
array #(s_index,32) stride_arr(
	.clk,
	.rst,
	.load(stride_load),
	.index(data_PC[s_offset+s_index-1:s_offset]),
	.datain(cur_stride),
	.dataout(prev_stride)
);


array #(s_index,2) state_arr(
	.clk,
	.rst,
	.load(state_load),
	.index(data_PC[s_offset+s_index-1:s_offset]),
	.datain(next_state),
	.dataout(state)
);
endmodule : prefetcher