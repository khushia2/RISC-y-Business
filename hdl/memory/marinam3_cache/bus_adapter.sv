/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER.
A module to help your CPU (which likes to deal with 4 bytes
at a time) talk to your cache (which likes to deal with 32
bytes at a time).*/

module bus_adapter#(
    parameter s_offset   = 5,
    parameter s_mbe      = 2**s_offset,
    parameter s_line     = 8*s_mbe,
	 parameter o_offset   = 2,
    parameter o_mbe      = 2**o_offset,
    parameter o_line     = 8*o_mbe,
	 parameter isL1		 = 1
)
(
    output logic[s_line-1:0]  mem_wdata_ext,
    input logic[s_line-1:0] 	mem_rdata_ext,
    input logic[o_line-1:0]	mem_wdata,
    output logic[o_line-1:0] 	mem_rdata,
    input logic[o_mbe-1:0] 	mem_byte_enable,
    output logic [s_mbe-1:0] 	mem_byte_enable_ext,
    input logic[31:0] 			address
);

always_comb begin
	if (isL1==1) begin //ofset for CPU
		mem_rdata = mem_rdata_ext[(32*address[s_offset-1:2]) +: 32];
		mem_byte_enable_ext = {'0, mem_byte_enable} << (address[s_offset-1:2]*4);
	end
	else begin
		mem_rdata = mem_rdata_ext;
		mem_byte_enable_ext = mem_byte_enable;
	end
	mem_wdata_ext = {8{mem_wdata}};
end

endmodule : bus_adapter
