/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER.
A module to help your CPU (which likes to deal with 4 bytes
at a time) talk to your cache (which likes to deal with 32
bytes at a time).*/

module bus_adapterRO#(
    parameter s_offset   = 5,
    parameter s_mbe      = 2**s_offset,
    parameter s_line     = 8*s_mbe,
	 parameter o_offset   = 2,
    parameter o_mbe      = 2**o_offset,
    parameter o_line     = 8*o_mbe,
	 parameter isL1		 = 1
)
(
    input logic[s_line-1:0] 	mem_rdata_ext,
    output logic[o_line-1:0] 	mem_rdata,
    input logic[31:0] 			address
);

always_comb begin
	if (isL1==1) begin //ofset for CPU
		mem_rdata = mem_rdata_ext[(32*address[s_offset-1:2]) +: 32];
	end
	else begin
		mem_rdata = mem_rdata_ext;
	end
end

endmodule : bus_adapterRO
