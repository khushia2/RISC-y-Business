module branch_tb;
`timescale 1ns/10ps

branch_itf itf();
branch_driver driver(itf);
branch_monitor branch_mon(itf);

branch_predictor dut(
    .clk(itf.clk),
    .rst(itf.rst),
    .opcode_if(itf.opcode_if),
    .pc_if(itf.pc_if),
    .is_branch_ex(itf.is_branch_ex),
    .is_jump_ex(itf.is_jump_ex),
    .pc_ex(itf.pc_ex),
    .branch_pc_ex(itf.branch_pc_ex),
    .cmp_out_ex(itf.cmp_out_ex),
    .bhr_ex(itf.bhr_ex),
    .loc_predict_taken_ex(itf.loc_predict_taken_ex),
    .glob_predict_taken_ex(itf.glob_predict_taken_ex),
    .is_branch_if(itf.is_branch_if),
    .is_jump_if(itf.is_jump_if),
    .predict_taken(itf.predict_taken),
    .loc_predict_taken_if(itf.loc_predict_taken_if),
    .glob_predict_taken_if(itf.glob_predict_taken_if),
    .predicted_pc(itf.predicted_pc),
    .use_predicted(itf.use_predicted),
    .bhr_if(itf.bhr_if)
);

assign itf.valid_branch = dut.valid_branch;

int cycle_cnt;
initial cycle_cnt = 0;
always @(posedge itf.clk) begin
   if (cycle_cnt == -1 )begin
		$display("!! cycle count finish !!");
      $finish;
   end

   cycle_cnt = cycle_cnt + 1;
end
endmodule
