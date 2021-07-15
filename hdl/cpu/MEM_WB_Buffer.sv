import rv32i_types::*;

module MEM_WB_Buffer (
                        input logic clk,
                        input logic rst,
                        input logic stall,
                        input logic nop,
                        input rv32i_ctrl_word ctrl_mem,
                        input rv32i_mon_word mon_mem,
                        input rv32i_word pc_plus4_mem,
                        input rv32i_word alu_out_mem,
                        input rv32i_word data_rdata_mem,
                        input logic cmp_out_mem,
                        input rv32i_word imm_mem,
                        input rv32i_word pc_out_mem,
                        output rv32i_ctrl_word ctrl_wb,
                        output rv32i_mon_word mon_wb,
                        output rv32i_word pc_plus4_wb,
                        output rv32i_word alu_out_wb,
                        output rv32i_word data_rdata_wb,
                        output logic cmp_out_wb,
                        output rv32i_word imm_wb,
                        output rv32i_word pc_out_wb
                     );
                  
always_ff @(posedge clk)
begin
   if (rst || (nop && ~stall)) begin
      ctrl_wb       <= '0;
      pc_plus4_wb   <= '0;
      alu_out_wb    <= '0;
      data_rdata_wb <= '0;
      cmp_out_wb    <= '0;
      imm_wb        <= '0;
      pc_out_wb     <= '0;      
      mon_wb        <= '0;
      mon_wb.opcode <= op_imm; //NOP
      mon_wb.inst   <= 'h13; //NOP
   end
   else if (stall) begin
      ctrl_wb       <= ctrl_wb;
      pc_plus4_wb   <= pc_plus4_wb;
      alu_out_wb    <= alu_out_wb;
      data_rdata_wb <= data_rdata_wb;
      cmp_out_wb    <= cmp_out_wb;
      imm_wb        <= imm_wb;
      pc_out_wb     <= pc_out_wb;     
      mon_wb        <= mon_wb;
   end
   else begin
      ctrl_wb          <= ctrl_mem;
      pc_plus4_wb      <= pc_plus4_mem;
      alu_out_wb       <= alu_out_mem;
      data_rdata_wb    <= data_rdata_mem;
      cmp_out_wb       <= cmp_out_mem;
      imm_wb           <= imm_mem;
      pc_out_wb        <= pc_out_mem;    
      mon_wb           <= mon_mem;  
   end
end

endmodule : MEM_WB_Buffer

