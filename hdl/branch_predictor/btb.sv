module btb #(parameter N = 128)
(
   input logic clk,
   input logic rst,
   input logic is_branch_ex,
   input logic is_jump_ex,
   input logic [31:0] pc_if,
   input logic [31:0] pc_ex,
   input logic [31:0] branch_pc_ex,
   output logic valid_pc,
   output logic [31:0] predicted_pc
);

localparam n = $clog2(N);

logic[31:0] target_pcs[N];
logic [n-1:0] w_idx, r_idx;
logic [32-n-2:0] tags[N], w_tag, r_tag, tag_out;

assign w_idx = pc_ex[n+1:2];
assign r_idx = pc_if[n+1:2];
assign w_tag = pc_ex[31:n+2];
assign r_tag = pc_if[31:n+2];
assign tag_out = tags[r_idx];
assign valid_pc = tag_out === r_tag;
assign predicted_pc = target_pcs[r_idx];

always_ff @(posedge clk) begin
   if (rst) begin
      for (int i = 0; i < N; i++) begin
         target_pcs[i] <= '0;
         tags[i] <= '0;
      end
   end
   else if (is_branch_ex || is_jump_ex) begin
      tags[w_idx] <= w_tag;
      target_pcs[w_idx] <= branch_pc_ex;
   end
end

endmodule : btb
