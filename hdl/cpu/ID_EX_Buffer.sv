import rv32i_types::*;

   module ID_EX_Buffer#(parameter bhr_size = 7) (
                        input logic clk,
                        input logic rst,
                        input logic stall,
                        input logic nop,
                        input rv32i_ctrl_word ctrl_id,
                        input rv32i_mon_word mon_id,
                        input rv32i_word pc_plus4_id,
                        input rv32i_word pc_out_id,
                        input rv32i_word rs1_out_id,
                        input rv32i_word rs2_out_id,
                        input rv32i_word imm_id,
                        //input logic loc_predict_taken_id,
                        //input logic glob_predict_taken_id,
                        input logic is_branch_id,
                        input logic is_jump_id,
                        //input logic[bhr_size-1:0] bhr_id,
                        input rv32i_word f1mux_out_ex,
                        input rv32i_word f2mux_out_ex,
                        output rv32i_ctrl_word ctrl_ex,
                        output rv32i_mon_word mon_ex,
                        output rv32i_word pc_plus4_ex,
                        output rv32i_word pc_out_ex,
                        output rv32i_word rs1_out_ex,
                        output rv32i_word rs2_out_ex,
                        output rv32i_word imm_ex,
                       // output logic loc_predict_taken_ex,
                       // output logic glob_predict_taken_ex,
                        output logic is_branch_ex,
                        output logic is_jump_ex
                       // output logic[bhr_size-1:0] bhr_ex
                     );

always_ff @(posedge clk)
begin
   if (rst || (nop && ~stall)) begin
      ctrl_ex       <= '0;
      pc_plus4_ex   <= '0;
      pc_out_ex     <= '0;
      rs1_out_ex    <= '0;
      rs2_out_ex    <= '0;
      imm_ex        <= '0;
     // loc_predict_taken_ex  <= 1'b0;
     // glob_predict_taken_ex <= 1'b0;
      is_branch_ex  <= 1'b0;
      is_jump_ex    <= 1'b0;
     // bhr_ex        <= '0;
      mon_ex        <= '0;
      mon_ex.opcode <= op_imm; //NOP
      mon_ex.inst   <= 'h13; //NOP
   end
   else if (stall) begin
      ctrl_ex     <= ctrl_ex;
      pc_plus4_ex <= pc_plus4_ex;
      pc_out_ex   <= pc_out_ex;
      rs1_out_ex  <= f1mux_out_ex;
      rs2_out_ex  <= f2mux_out_ex;
      imm_ex      <= imm_ex;
      //loc_predict_taken_ex  <= loc_predict_taken_ex;
      //glob_predict_taken_ex <= glob_predict_taken_ex;
      is_branch_ex <= is_branch_ex;
      is_jump_ex  <= is_jump_ex;
     // bhr_ex      <= bhr_ex;
      mon_ex      <= mon_ex;
   end
   else begin
      ctrl_ex          <= ctrl_id;
      pc_plus4_ex      <= pc_plus4_id;
      pc_out_ex        <= pc_out_id;
      rs1_out_ex       <= rs1_out_id;
      rs2_out_ex       <= rs2_out_id;
      imm_ex           <= imm_id;
      //loc_predict_taken_ex  <= loc_predict_taken_id;
      //glob_predict_taken_ex <= glob_predict_taken_id;
      is_branch_ex     <= is_branch_id;
      is_jump_ex       <= is_jump_id;
      //bhr_ex           <= bhr_id;
      mon_ex           <= mon_id;
      mon_ex.imm       <= imm_id;   
      mon_ex.rs1_addr  <= ctrl_id.rs1;
      mon_ex.rs2_addr  <= ctrl_id.rs2;
      mon_ex.rd_addr   <= ctrl_id.rd;
      mon_ex.rs1_rdata <= ctrl_id.rs1 === 5'b00000 ? '0 : rs1_out_id;
      mon_ex.rs2_rdata <= ctrl_id.rs2 === 5'b00000 ? '0 : rs2_out_id;   
   end
end

endmodule : ID_EX_Buffer

