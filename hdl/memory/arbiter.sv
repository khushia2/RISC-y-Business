//import rv32i_types::*;

module arbiter
(
   input clk,
   input logic i_pmem_read,
   input logic d_pmem_read,
   input logic d_pmem_write,
   input logic cache_resp,
   input logic [31:0] i_pmem_addr,
   input logic [31:0] d_pmem_addr,  
   input logic [255:0] d_wdata256,
   input logic [255:0] cache_rdata,
   output logic i_pmem_resp,
   output logic d_pmem_resp,  
   output logic cache_read,
   output logic cache_write,
   output logic [31:0] cache_addr,
   output logic [255:0] i_rdata256,
   output logic [255:0] d_rdata256,
   output logic [255:0] cache_wdata
);

//CONTROL
/* State Enumeration */
enum int unsigned
{
  check_cache,
  icache,
  dcache
} state, next_state;

/* Next State Assignment */
always_ff @(posedge clk) begin: next_state_assignment
    state <= next_state;
end

/* Next State Logic */
always_comb begin : next_state_logic
   /* Default state transition */
   next_state = state;
   case(state)
      check_cache: begin
         if (d_pmem_read || d_pmem_write) next_state = dcache;
         else if (i_pmem_read)            next_state = icache;
      end
      dcache: begin
         if (cache_resp)   next_state = check_cache;
      end
      icache: begin
         if (cache_resp)   next_state = check_cache;
      end
   endcase
end

logic [31:0] i_pmem_addr_reg, d_pmem_addr_reg;
/* Registers to Improve Timing */
always_ff @(posedge clk) begin: register_assignment
    i_pmem_addr_reg <= i_pmem_addr;
	 d_pmem_addr_reg <= d_pmem_addr;
end

/* State Control Signals */
always_comb begin : state_actions
   /* Defaults */
   i_pmem_resp = 1'b0;
   d_pmem_resp = 1'b0;  
   cache_read = 1'b0;
   cache_write = 1'b0;
   cache_addr = 'b0;
   i_rdata256 = 'b0;
   d_rdata256 = 'b0;
   cache_wdata = 'b0;
   
   case(state)
      check_cache: begin //prioritize d_cache
         d_pmem_resp = cache_resp;  
         cache_read = d_pmem_read;
         cache_write = d_pmem_write;
         cache_addr = d_pmem_addr_reg;
         d_rdata256 = cache_rdata;
         cache_wdata = d_wdata256;
      end
      dcache: begin
         d_pmem_resp = cache_resp;  
         cache_read = d_pmem_read;
         cache_write = d_pmem_write;
         cache_addr = d_pmem_addr_reg;
         d_rdata256 = cache_rdata;
         cache_wdata = d_wdata256;
      end
      icache: begin
         i_pmem_resp = cache_resp;
         cache_read = i_pmem_read;
         cache_addr = i_pmem_addr_reg;
         i_rdata256 = cache_rdata;
      end
   endcase
   
end
  
endmodule : arbiter

