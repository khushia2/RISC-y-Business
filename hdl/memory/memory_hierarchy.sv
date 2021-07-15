//import rv32i_types::*;

module memory_hierarchy
(
   input logic clk,
   input logic rst,
   input logic inst_read,
   input logic data_read,
   input logic data_write,
   input logic mem_resp,
   input logic [3:0] data_mbe,
   input logic [31:0] inst_addr,
   input logic [31:0] data_addr,
   input logic [31:0] data_wdata,
   input logic [63:0] mem_rdata,
	input logic [31:0] data_PC,
	
   output logic inst_resp,
   output logic data_resp,
   output logic mem_read,
   output logic mem_write,
   output logic [31:0] inst_rdata,
   output logic [31:0] data_rdata,
   output logic [31:0] mem_address,
   output logic [63:0] mem_wdata 
);


//icache <-> arbitor
logic i_pmem_resp, i_pmem_read;
logic [31:0] i_pmem_addr;
logic [255:0] i_rdata256;

//dcache <-> arbitor
logic  d_pmem_resp, d_pmem_read, d_pmem_write;
logic [31:0] d_pmem_addr;
logic [255:0] d_rdata256, d_wdata256;

//arbitor <-> cacheline_adaptor
logic cache_resp, cache_read, cache_write;
logic [255:0] cache_rdata, cache_wdata;
logic [31:0] cache_addr;

icache icache(
   .clk,
   .rst,
   .inst_read,
   .pmem_resp(i_pmem_resp),
   .inst_addr,
   .pmem_rdata(i_rdata256),
   .inst_resp,
   .pmem_read(i_pmem_read),
   .inst_rdata,
   .pmem_address(i_pmem_addr)
);

dcache dcache(
   .clk,
   .rst,
   .data_read,
   .data_write,
   .pmem_resp(d_pmem_resp),
   .data_mbe,
   .data_addr,
	.data_PC,
   .data_wdata,
   .pmem_rdata(d_rdata256),
   .data_resp,
   .pmem_read(d_pmem_read),
   .pmem_write(d_pmem_write),
   .data_rdata,
   .pmem_address(d_pmem_addr),
   .pmem_wdata(d_wdata256)
);

arbiter arbiter(
   .clk,
   .i_pmem_read,
   .d_pmem_read,
   .d_pmem_write,
   .cache_resp,
   .i_pmem_addr,
   .d_pmem_addr,  
   .d_wdata256,
   .cache_rdata,
   .i_pmem_resp,
   .d_pmem_resp,  
   .cache_read,
   .cache_write,
   .cache_addr,
   .i_rdata256,
   .d_rdata256,
   .cache_wdata);

cacheline_adaptor cacheline_adaptor(
    .clk,
    .reset_n(~rst),
    .line_i(cache_wdata),
    .line_o(cache_rdata),
    .address_i(cache_addr),
    .read_i(cache_read),
    .write_i(cache_write),
    .resp_o(cache_resp),
    .burst_i(mem_rdata),
    .burst_o(mem_wdata),
    .address_o(mem_address),
    .read_o(mem_read),
    .write_o(mem_write),
    .resp_i(mem_resp)
);
  
endmodule : memory_hierarchy

