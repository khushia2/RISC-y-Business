//import rv32i_types::*;

module icache
(
   input logic clk,
   input logic rst,
   input logic inst_read,
   input logic pmem_resp,
   input logic [31:0] inst_addr,
   input logic [255:0] pmem_rdata,
   output logic inst_resp,
   output logic pmem_read,
   output logic [31:0] inst_rdata,
   output logic [31:0] pmem_address
);

logic l2_resp, l2_read, l2_write;
logic[31:0] l2_address, l2_byte_enable;
logic [255:0] l2_rdata, l2_wdata;

cacheRO #(.num_ways(4), .s_index(3), .o_offset(2)) L1ca(
  .clk,
  .rst,

  /* CPU memory signals */
  .mem_read(inst_read),
  .mem_address(inst_addr),
  .mem_resp(inst_resp),
  .mem_rdata(inst_rdata),
  
    /* Physical memory signals */
  .pmem_resp(pmem_resp),
  .pmem_rdata(pmem_rdata),
  .pmem_address(pmem_address),
  .pmem_read(pmem_read)
  
//  /* L2ca memory signals */
//  .pmem_resp(l2_resp),
//  .pmem_rdata(l2_rdata),
//  .pmem_address(l2_address),
//  .pmem_wdata(l2_wdata),
//  .pmem_read(l2_read),
//  .pmem_write(l2_write),
//  .pmem_byte_enable(l2_byte_enable)

);


//cache #(.num_ways(4), .s_index(3), .o_offset(5), .isL1(0)) L2ca(
//  .clk,
//  .rst,
//  
//  /* L1ca memory signals */
//  .mem_read(l2_read),
//  .mem_write(l2_write),
//  .mem_byte_enable(l2_byte_enable),
//  .mem_address(l2_address),
//  .mem_wdata(l2_wdata),
//  .mem_resp(l2_resp),
//  .mem_rdata(l2_rdata),
//  
//  /* Physical memory signals */
//  .pmem_resp(pmem_resp),
//  .pmem_rdata(pmem_rdata),
//  .pmem_address(pmem_address),
//  .pmem_wdata(),
//  .pmem_read(pmem_read),
//  .pmem_write(),
//  .pmem_byte_enable()
//);
  
endmodule : icache

