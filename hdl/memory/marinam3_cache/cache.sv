import rv32i_types::*;
/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cache #(
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
   input logic[o_line-1:0]    mem_wdata,
   input logic          		mem_read,
   input logic          		mem_write,
   input logic[o_mbe-1:0]     mem_byte_enable,
   output logic[o_line-1:0]   mem_rdata,
   output logic         		mem_resp,
   
   //with cacheline adaptor
   input logic[s_line-1:0] 	pmem_rdata,
   input logic          		pmem_resp,
   output rv32i_word   			pmem_address,
   output logic[s_line-1:0]  	pmem_wdata,
   output logic         		pmem_read,
   output logic         		pmem_write,
   output logic[s_mbe-1:0]    pmem_byte_enable
   
);

//timing register for cache_miss
logic pmem_resp_out, pmem_read_in, pmem_write_in;
logic[s_line-1:0] pmem_rdata_out, pmem_wdata_in;
rv32i_word pmem_address_in;
logic[s_mbe-1:0] pmem_byte_enable_in;

always_ff @(posedge clk) begin
	pmem_read 			<= pmem_read_in;
	pmem_write  		<= pmem_write_in;
	pmem_byte_enable 	<= pmem_byte_enable_in;
	pmem_wdata			<= pmem_wdata_in;
	pmem_address		<= pmem_address_in;
end

logic cache_load, lru_load, dirty_load, memry_read, memry_write, dirty_in, cache_hit;
cache_control control
(
   .clk(clk),
   .rst(rst),
   .cache_hit(cache_hit),
   .cache_read(mem_read),
   .cache_write(mem_write),
   .cache_load,
   .lru_load,
   .dirty_load,
   .dirty_in,
   .cache_resp(mem_resp),
   .memry_resp(pmem_resp),
   .memry_read,
   .memry_write,
   .pmem_read(pmem_read_in),
   .pmem_write(pmem_write_in)
);

logic[s_mbe-1:0] mem_byte_enable256;
logic[s_line-1:0] mem_rdata256, mem_wdata256;
cache_datapath 
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
   .cache_write(mem_write),
   .mem_address,
   .mem_byte_enable256,
   .mem_rdata256,
   .mem_wdata256,
   .memry_addr(pmem_address_in),
   .memry_line_i(pmem_rdata),
   .memry_line_o(pmem_wdata_in),
	.memry_mbe(pmem_byte_enable_in),
   
   .cache_load,
   .lru_load,
   .dirty_load,
   .dirty_in,
   .memry_write,
   .memry_read
);

bus_adapter 
#(	.s_offset(s_offset),
	.o_offset(o_offset),
	.isL1(isL1)
) 
bus_adapter
(
    .mem_wdata_ext(mem_wdata256),
    .mem_rdata_ext(mem_rdata256),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_byte_enable,
    .mem_byte_enable_ext(mem_byte_enable256),
    .address(mem_address)
);

endmodule : cache
