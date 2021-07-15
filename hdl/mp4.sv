import rv32i_types::*;

module mp4
(
    input logic clk,
    input logic rst, 
    
    input logic mem_resp,
    input logic [63:0] mem_rdata,
    
    output logic mem_read,
    output logic mem_write,
    output logic [31:0] mem_address,
    output logic [63:0] mem_wdata
);

// Memory Hierarchy <-> CPU signals
logic inst_resp, data_resp, inst_read, data_read, data_write;
logic [31:0] inst_rdata, data_rdata, inst_addr, data_addr, data_wdata, data_PC;
logic [3:0] data_mbe;

cpu cpu(.*);

memory_hierarchy mem_hierarchy(.*);
      
endmodule : mp4
