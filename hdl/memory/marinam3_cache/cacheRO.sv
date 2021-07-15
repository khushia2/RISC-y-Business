import rv32i_types::*;
/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cacheRO #(
    parameter num_ways = 4,
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mbe    = 2**s_offset,
    parameter s_line   = 8*s_mbe,
    parameter num_sets = 2**s_index,
	 
    parameter o_offset = 2,
    parameter o_mbe    = 2**o_offset,
    parameter o_line   = 8*o_mbe,
	 
	 parameter isL1	  = 1
)
(
   input logic          clk,
   input logic          rst,
   //with cpu
   input rv32i_word     		mem_address,
   input logic          		mem_read,
   output logic[o_line-1:0]   mem_rdata,
   output logic         		mem_resp,
   
   //with cacheline adaptor
   input logic[s_line-1:0] 	pmem_rdata,
   input logic          		pmem_resp,
   output rv32i_word   			pmem_address,
   output logic         		pmem_read
   
);

//timing register for cache_miss
logic pmem_resp_out, pmem_read_in;
logic[s_line-1:0] pmem_rdata_out;
rv32i_word pmem_address_in;

always_ff @(posedge clk) begin
	pmem_read 			<= pmem_read_in;
	pmem_address		<= pmem_address_in;
end

logic cache_load, lru_load, dirty_load, memry_read, memry_write, dirty_in, cache_hit;
cacheRO_control control
(
   .clk(clk),
   .rst(rst),
   .cache_hit(cache_hit),
   .cache_read(mem_read),
   .cache_load,
   .lru_load,
   .cache_resp(mem_resp),
   .memry_resp(pmem_resp),
   .memry_read,
   .pmem_read(pmem_read_in)
);

logic[s_mbe-1:0] mem_byte_enable256;
logic[s_line-1:0] mem_rdata256, mem_wdata256;
cacheRO_datapath 
#(	.num_ways(num_ways),
   .s_offset(s_offset),
   .s_index(s_index),
   .s_tag(s_tag),
   .s_mbe(s_mbe),
   .s_line(s_line),
   .num_sets(num_sets),
	.o_offset(o_offset))
datapath
(
   .clk,
   .rst,
   
   .cache_hit(cache_hit),
   .cache_read(mem_read),
   .mem_address,
   .mem_rdata256,
   .memry_addr(pmem_address_in),
   .memry_line_i(pmem_rdata),
   
   .cache_load,
   .lru_load,
   .memry_read
);

bus_adapterRO 
#(	.s_offset(s_offset),
	.o_offset(o_offset),
	.isL1(isL1)
) 
bus_adapter
(
    .mem_rdata_ext(mem_rdata256),
    .mem_rdata(mem_rdata),
    .address(mem_address)
);

endmodule : cacheRO
