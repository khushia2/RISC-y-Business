//import rv32i_types::*;

module dcache
(
   input logic clk,
   input logic rst,
   input logic data_read,
   input logic data_write,
   input logic pmem_resp,
   input logic [3:0] data_mbe,
   input logic [31:0] data_addr,
   input logic [31:0] data_PC,
   input logic [31:0] data_wdata,
   input logic [255:0] pmem_rdata,
   output logic data_resp,
   output logic pmem_read,
   output logic pmem_write,
   output logic [31:0] data_rdata,
   output logic [31:0] pmem_address,
   output logic [255:0] pmem_wdata 
);

logic l2_resp, l2_read, l2_write;
logic[31:0] l2_address, l2_byte_enable;
logic [255:0] l2_rdata, l2_wdata;

logic l1_resp, l1_read, l1_write;
logic[31:0] l1_address;
logic [255:0] l1_rdata, l1_wdata;
	
cache #(.num_ways(1), .s_index(1), .o_offset(2)) L1ca(
  .clk,
  .rst,

  /* CPU memory signals */
  .mem_read(data_read),
  .mem_write(data_write),
  .mem_byte_enable(data_mbe),
  .mem_address(data_addr),
  .mem_wdata(data_wdata),
  .mem_resp(data_resp),
  .mem_rdata(data_rdata),
  
    /* L2ca memory signals */
//  .pmem_resp,
//  .pmem_rdata,
//  .pmem_address,
//  .pmem_wdata,
//  .pmem_read,
//  .pmem_write,
//  .pmem_byte_enable(l2_byte_enable)
  
  /* L2ca memory signals */
  .pmem_resp(l1_resp),
  .pmem_rdata(l1_rdata),
  .pmem_address(l1_address),
  .pmem_wdata(l1_wdata),
  .pmem_read(l1_read),
  .pmem_write(l1_write),
  .pmem_byte_enable(l2_byte_enable)

);

logic pref_read, pref_resp;
logic[31:0] pref_addr;
prefetcher prefetcher(   
	.clk,
   .rst,
   .data_addr,
   .data_PC,
	.pref_resp,
   .pref_read,
	.pref_addr
);

arbiter l1_pref_arbiter
(
   .clk,
   .i_pmem_read(pref_read),
   .d_pmem_read(l1_read),
   .d_pmem_write(l1_write),
   .cache_resp(l2_resp),
   .i_pmem_addr(pref_addr),
   .d_pmem_addr(l1_address),  
   .d_wdata256(l1_wdata),
   .cache_rdata(l2_rdata),
   .i_pmem_resp(pref_resp),
   .d_pmem_resp(l1_resp),  
   .cache_read(l2_read),
   .cache_write(l2_write),
   .cache_addr(l2_address),
   .i_rdata256(),
   .d_rdata256(l1_rdata),
   .cache_wdata(l2_wdata)
);

cache #(.num_ways(4), .s_index(3), .o_offset(5), .isL1(0)) L2ca(
  .clk,
  .rst,
  
  /* L1ca memory signals */
  .mem_read(l2_read),
  .mem_write(l2_write),
  .mem_byte_enable(l2_byte_enable),
  .mem_address(l2_address),
  .mem_wdata(l2_wdata),
  .mem_resp(l2_resp),
  .mem_rdata(l2_rdata),
  
  /* Physical memory signals */
  .pmem_resp(pmem_resp),
  .pmem_rdata(pmem_rdata),
  .pmem_address(pmem_address),
  .pmem_wdata(pmem_wdata),
  .pmem_read(pmem_read),
  .pmem_write(pmem_write),
  .pmem_byte_enable()
);

  
endmodule : dcache

