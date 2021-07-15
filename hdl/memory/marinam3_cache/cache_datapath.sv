/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

module cache_datapath #(
    parameter num_ways = 2,
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mbe   = 2**s_offset,
    parameter s_line   = 8*s_mbe,
    parameter num_sets = 2**s_index,
	 parameter o_offset   = 2,
    parameter o_mbe      = 2**o_offset,
    parameter o_line     = 8*o_mbe
)
(
   input logic       clk,
   input logic       rst,
   
   input logic       cache_read,
   input logic       cache_write,
   input logic[31:0] mem_address,
   input logic[s_line-1:0] mem_wdata256,
   input logic[s_mbe-1:0] mem_byte_enable256,
   input logic[s_line-1:0] memry_line_i,
   output logic[s_line-1:0] memry_line_o,
   output logic[s_line-1:0] mem_rdata256,
   output logic[31:0] memry_addr,
	output logic[s_mbe-1:0] memry_mbe,
   
   input logic       cache_load,
   input logic       dirty_load,
   input logic       dirty_in,
   input logic       lru_load,
   
   output logic      cache_hit,
   output logic      memry_read,
   output logic      memry_write
);

/************* SIGNALS *******************/
logic cache_miss; 
logic lru_dirty;
logic[s_line-1:0] data_in;

logic[num_ways-1:0] tag_hit, dirtyarr_load, way_load, way_valid, way_hit, way_dirty, way_lru;
logic[s_tag-1:0] tag [num_ways];
logic[s_line-1:0] data [num_ways];
logic[s_mbe-1:0] write_en [num_ways];

assign memry_mbe = signed'(1'b1);

always_comb begin
   way_load = '0;
   if (cache_load)begin
      if ((~way_valid) == '0) begin //if all of the ways are valid, load LRU way
         for (int i=0; i<num_ways; i++)begin
            if(way_lru[i]) begin 
               way_load[i] = 1'b1;
               break;
            end
         end
      end
      else begin                    //else load the first invalid way
         for (int i=0; i<num_ways; i++)begin
            if(!way_valid[i]) begin 
                  way_load[i] = 1'b1;
               break;
            end
         end
      end
   end
end

always_comb begin
   way_hit = way_valid & tag_hit;
   cache_miss = (way_hit == '0);
   cache_hit = !cache_miss;
   
   memry_read = cache_miss && (!lru_dirty);
   memry_write = cache_miss && lru_dirty;
end

always_comb begin
   mem_rdata256 = 0;
   data_in = 0;
   for (int i=0; i<num_ways; i++)begin
      write_en[i] = '0;
   end
   
   if(cache_hit)begin   //CACHE HIT
      data_in = mem_wdata256;
      for(int i=0; i<num_ways; i++) begin
         if(way_hit[i]) begin
            mem_rdata256 = data[i];
            if (cache_write && dirtyarr_load[i]) begin
               write_en[i] =  mem_byte_enable256;
            end
         end
      end
   end
   else begin           //CACHE MISS
      data_in = memry_line_i;
      for(int i=0; i<num_ways; i++) begin
         if(way_load[i]) write_en[i] = signed'(1'b1);
      end
   end
end
always_comb begin
   memry_addr = 0;
   memry_line_o = 0;
   if (memry_read) begin
      memry_addr = mem_address;
   end
   else if (memry_write)begin
      for(int i=0; i<num_ways; i++)begin
         if (way_lru[i])begin
            memry_addr[31:s_offset] = {tag[i],mem_address[s_offset+s_index-1:s_offset]};
				memry_addr[s_offset-1:0] = 'b0;
            memry_line_o = data[i];
            break;
         end
      end
   end
end
always_comb begin
   lru_dirty = 1'b0; 
   dirtyarr_load = '0;
   
   if(cache_hit) begin  //CACHE HIT
      for(int i=0; i<num_ways; i++)begin
         if (way_hit[i]) begin
            dirtyarr_load[i] = dirty_load;
            break;
         end
      end
   end
   else begin           //CACHE MISS
      for(int i=0; i<num_ways; i++)begin
         if(way_lru[i])begin
            dirtyarr_load[i] = dirty_load;
            lru_dirty = way_dirty[i];
         end
      end
   end
end

always_comb begin
   for(int i=0; i<num_ways; i++)begin
      tag_hit[i] = (tag[i]==mem_address[31:s_offset+s_index]);
   end
end

/*****************Generate Modules*******************/
genvar m;
generate
   for(m=0; m<num_ways; m++) begin: generate_modules_identifier
      /********** Valid Array ************/
      array #(s_index,1) valid_arr (
          .clk,
          .rst(rst),
          .load(way_load[m]),
          .index(mem_address[s_offset+s_index-1:s_offset]),
          .datain(1'b1),
          .dataout(way_valid[m])
      );
      /************ Tag Array ***********/
      array #(s_index,s_tag) tag_arr(
          .clk,
          .rst,
          .load(way_load[m]),
          .index(mem_address[s_offset+s_index-1:s_offset]),
          .datain(mem_address[31:s_offset+s_index]),
          .dataout(tag[m])
      );
      /************** DATA ARRAY ****************/
      data_array #(s_offset,s_index) data_arr(
          .clk,
          .rst,
          .write_en(write_en[m]),
          .index(mem_address[s_offset+s_index-1:s_offset]),
          .datain(data_in),
          .dataout(data[m])
      );
      /********** DIRTY Array ************/
      array #(s_index,1) dirty_arr(
          .clk,
          .rst,
          .load(dirtyarr_load[m]),
          .index(mem_address[s_offset+s_index-1:s_offset]),
          .datain(dirty_in),
          .dataout(way_dirty[m])
      );
   end
endgenerate




/**************** LRU ******************/
localparam MAX_WAYS = 4;
logic [MAX_WAYS-2:0] lru_state, lru_state_next;
logic [num_ways-1:0] way_lru_next;

array #(s_index,num_ways) LRU(
    .clk,
    .rst(rst),
    .load(lru_load),
    .index(mem_address[s_offset+s_index-1:s_offset]),
    .datain(way_lru_next),
    .dataout(way_lru)
);

array #(s_index,MAX_WAYS-1) LRU_state(
    .clk,
    .rst(rst),
    .load(lru_load),
    .index(mem_address[s_offset+s_index-1:s_offset]),
    .datain(lru_state_next),
    .dataout(lru_state)
);

plru #(num_ways) pLRU(
   .hit_way(way_hit),
   .lru_curstate(lru_state),
   .lru_updstate(lru_state_next),
   .rep_dec(way_lru_next)
);



endmodule : cache_datapath
