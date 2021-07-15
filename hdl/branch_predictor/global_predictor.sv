module global_predictor #(parameter N = 128)
(
   input logic clk,
   input logic rst,
   input logic is_branch_ex,
   input logic cmp_out_ex,
   input logic[$clog2(N)-1:0] bhr_ex,
   output logic glob_predict_taken,
   output logic[$clog2(N)-1:0] bhr_if
);

localparam n = $clog2(N);

logic[n-1:0] bhr;
logic [1:0] counters[N], cnt_out;

assign cnt_out = counters[bhr];
assign bhr_if = bhr;
assign glob_predict_taken = cnt_out[1];

always_ff @(posedge clk) begin
   if (rst) begin
      bhr = '0;
      for (int i = 0; i < N; i++)
         counters[i] = 2'b01;
   end
   else if (is_branch_ex) begin
      bhr = {bhr[n-2:0],cmp_out_ex};
      if (counters[bhr_ex] !== 2'b11 && cmp_out_ex)
         counters[bhr_ex]++;
      else if (counters[bhr_ex] !== 2'b00 && !cmp_out_ex)
         counters[bhr_ex]--;
   end
end

endmodule : global_predictor
