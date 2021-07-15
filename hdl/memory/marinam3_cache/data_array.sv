/* A special register array specifically for your
data arrays. This module supports a write mask to
help you update the values in the array. */

module data_array #(
    parameter s_offset = 5,
    parameter s_index = 3
)
(
    clk,
    rst,
    write_en,
    index,
    datain,
    dataout
);

localparam s_mask   = 2**s_offset;
localparam s_line   = 8*s_mask;
localparam num_sets = 2**s_index;

input clk;
input rst;
input [s_mask-1:0] write_en;
input [s_index-1:0] index;
input [s_line-1:0] datain;
output logic [s_line-1:0] dataout;

logic [s_line-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

always_comb begin
	 for (int i = 0; i < s_mask; i++) begin
		 dataout[8*i +: 8] = data[index][8*i +: 8];
	 end
end

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
        for (int i = 0; i < s_mask; i++) begin
				if (write_en[i])	data[index][8*i +: 8] <= datain[8*i +: 8];
				else 					data[index][8*i +: 8] <= data[index][8*i +: 8];
		  end
    end
end

endmodule : data_array
