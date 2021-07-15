module branch_predictor
(
   input logic clk,
   input logic rst,
   input logic[6:0] opcode_if,
   input logic[31:0] pc_if,
   input logic is_branch_ex,
   input logic is_jump_ex,
   input logic[31:0] pc_ex,
   input logic[31:0] branch_pc_ex,
   input logic cmp_out_ex,
   //input logic[4:0] bhr_ex,
   //input logic loc_predict_taken_ex,
   //input logic glob_predict_taken_ex,
   output logic is_branch_if,
   output logic is_jump_if,
   output logic predict_taken,
   //output logic loc_predict_taken_if,
   //output logic glob_predict_taken_if,
   output logic[31:0] predicted_pc,
   output logic use_predicted
   //output logic[4:0] bhr_if
);

logic /*glob_predict_taken, loc_predict_taken,*/ valid_branch, valid_pc;
logic is_jump, valid_prediction;

//assign loc_predict_taken_if = loc_predict_taken;
//assign glob_predict_taken_if = glob_predict_taken;
assign is_branch_if = opcode_if === 7'b1100011;
assign is_jump_if = is_jump;
assign is_jump = opcode_if === 7'b1101111 || opcode_if === 7'b1100111;
assign use_predicted = valid_pc & ((valid_branch & predict_taken) | is_jump_if);

//global_predictor#(32) global_predictor(.*);

local_predictor#(32) local_predictor(
   .clk,
   .rst,
   .is_branch_ex,
   .cmp_out_ex,
   .pc_if,
   .pc_ex,
   .loc_predict_taken(predict_taken),
	.tag_match(valid_branch)
);

btb#(64) btb(.*);

//meta_predictor#(32) meta_predictor
//(
//   .clk,
//   .rst,
//   .is_branch_ex,
//   .cmp_out_ex,
//   .loc_predict_taken_if(loc_predict_taken),
//   .glob_predict_taken_if(glob_predict_taken),
//   .loc_predict_taken_ex,
//   .glob_predict_taken_ex,
//   .pc_if,
//   .pc_ex,
//   .valid_branch,
//   .predict_taken
//);

endmodule : branch_predictor
