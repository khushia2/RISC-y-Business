module meta_predictor #(parameter N = 128)
(
   input logic clk,
   input logic rst,
   input logic is_branch_ex,
   input logic cmp_out_ex,
   input logic loc_predict_taken_if,
   input logic glob_predict_taken_if,
   input logic loc_predict_taken_ex,
   input logic glob_predict_taken_ex,
   input logic [31:0] pc_if,
   input logic [31:0] pc_ex,
   output logic valid_branch,
   output logic predict_taken
);

localparam n = $clog2(N);

logic loc_predict_correct, glob_predict_correct, use_global_predict;
logic [1:0] counters[N], cnt_out;
logic [n-1:0] w_idx, r_idx;
logic [32-n-2:0] tags[N], w_tag, r_tag, tag_out;

assign w_idx = pc_ex[n+1:2];
assign r_idx = pc_if[n+1:2];
assign w_tag = pc_ex[31:n+2];
assign r_tag = pc_if[31:n+2];
assign tag_out = tags[r_idx];
assign cnt_out = counters[r_idx];
assign use_global_predict = cnt_out[1];
assign valid_branch = r_tag === tag_out;
assign loc_predict_correct = loc_predict_taken_ex === cmp_out_ex;
assign glob_predict_correct = glob_predict_taken_ex === cmp_out_ex;
assign predict_taken = use_global_predict ? glob_predict_taken_if : loc_predict_taken_if;

always_ff @(posedge clk) begin
   if (rst) begin
      for (int i = 0; i < N; i++) begin
         counters[i] <= 2'b01;
         tags[i] <= '0;
      end
   end
   else if (is_branch_ex) begin
      tags[w_idx] <= w_tag;
      if (counters[w_idx] !== 2'b11 && (glob_predict_correct && !loc_predict_correct))
         counters[w_idx]++;
      else if (counters[w_idx] !== 2'b00 && (!glob_predict_correct && loc_predict_correct))
         counters[w_idx]--;
   end
end

endmodule : meta_predictor
