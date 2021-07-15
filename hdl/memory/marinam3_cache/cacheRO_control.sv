`define BAD_OP_SEL $fatal("%0t %s %0d: Illegal operand select", $time, `__FILE__, `__LINE__)

/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module cacheRO_control (
   input logic clk,
   input logic rst,
   input logic cache_read,
   input logic memry_resp,
   input logic cache_hit,
   input logic memry_read,
   output logic cache_load,
   output logic lru_load,
   output logic cache_resp,
   output logic pmem_read
);

//state machine
enum logic[0:0] {
   CheckCache,
   MemRead
} state, next_state;

always_ff@(posedge clk) begin
   if (rst)
      state <= CheckCache;
   else
      state <= next_state;
end

always_comb begin
   // Assign next state
   unique case (state)
      CheckCache: begin
         if(cache_read) begin
            if      (memry_read)    next_state = MemRead;
            else                    next_state = CheckCache;
         end
         else                    next_state = CheckCache;
         end
      MemRead: begin
         if (memry_resp)   next_state = CheckCache;
         else              next_state = MemRead;
         end
      default: begin
         next_state = state;
         end
   endcase
   
   // Assign signals based on current state
   //Default signal values
   cache_load = 1'b0;
   cache_resp = 1'b0;
   lru_load = 1'b0;
   pmem_read = 1'b0;
   unique case (state)
      CheckCache: begin
         if(cache_read) begin
            if (cache_hit) begin //cache hit!
               cache_resp = 1'b1;
               lru_load = 1'b1;
            end
         end
			end
      MemRead: begin
         if (memry_resp) begin
            cache_load = 1'b1;
         end
         else begin
            pmem_read = 1'b1;
         end
         end
		default: ;
   endcase
end
endmodule : cacheRO_control
