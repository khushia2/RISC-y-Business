import rv32i_types::*;

module EX_MEM_Buffer (
                        input logic clk,
                        input logic rst,
                        input logic stall,
                        input logic nop,
                        input logic cmp_out_ex,
                        input rv32i_ctrl_word ctrl_ex,
                        input rv32i_mon_word mon_ex,
                        input rv32i_word pc_plus4_ex,
                        input rv32i_word alu_out_ex,
                        input rv32i_word data_wdata_ex,
                        input rv32i_word imm_ex,
                        input rv32i_word pc_out_ex,
                        input rv32i_word fmux1_out,
                        input rv32i_word fmux2_out,
                        output logic cmp_out_mem,
                        output rv32i_ctrl_word ctrl_mem,
                        output rv32i_mon_word mon_mem,
                        output rv32i_word pc_plus4_mem,
                        output rv32i_word alu_out_mem,   
                        output rv32i_word data_wdata_mem,
                        output rv32i_word imm_mem,
                        output rv32i_word pc_out_mem
                     );

logic is_jalr, br_en;

assign is_jalr = ctrl_ex.is_jalr;
assign br_en = ctrl_ex.is_jump || (ctrl_ex.is_branch && cmp_out_ex );

always_ff @(posedge clk)
begin
      if (rst || (nop && ~stall)) begin
      ctrl_mem       <= '0;
      pc_plus4_mem   <= '0;
      alu_out_mem    <= '0;
      cmp_out_mem    <= '0;
      data_wdata_mem <= '0;
      imm_mem        <= '0;
      pc_out_mem     <= '0;
      mon_mem        <= '0;
      mon_mem.opcode <= op_imm; //NOP
      mon_mem.inst    <= 'h13; //NOP
   end
   else if (stall) begin
      ctrl_mem       <= ctrl_mem;
      pc_plus4_mem   <= pc_plus4_mem;
      alu_out_mem    <= alu_out_mem;
      cmp_out_mem    <= cmp_out_mem;
      data_wdata_mem <= data_wdata_mem;
      imm_mem        <= imm_mem;
      pc_out_mem     <= pc_out_mem;
      mon_mem        <= mon_mem;
   end
   else begin
      ctrl_mem          <= ctrl_ex;
      pc_plus4_mem      <= pc_plus4_ex;
      alu_out_mem       <= alu_out_ex;
      cmp_out_mem       <= cmp_out_ex;
      data_wdata_mem    <= data_wdata_ex;
      imm_mem           <= imm_ex;
      pc_out_mem        <= pc_out_ex;
      mon_mem           <= mon_ex;
      mon_mem.mem_addr  <= (ctrl_ex.data_read | ctrl_ex.data_write) ? alu_out_ex : '0;
      mon_mem.mem_wmask <= ctrl_ex.data_write ? (ctrl_ex.store_len << alu_out_ex % 4) : '0;
      mon_mem.mem_wdata <= ctrl_ex.data_write ? data_wdata_ex : '0;
      if ( mon_ex.rs1_addr !== '0 )
         mon_mem.rs1_rdata <= fmux1_out;
      if ( mon_ex.rs2_addr !== '0 )
         mon_mem.rs2_rdata <= fmux2_out;
      unique case({is_jalr, br_en}) 
         pcmux::pc_plus4: mon_mem.pc_wdata <= pc_plus4_ex;
         pcmux::alu_out:  mon_mem.pc_wdata <= alu_out_ex;
         pcmux::alu_mod2: mon_mem.pc_wdata <= {alu_out_ex[31:2],2'b00};
         default:         mon_mem.pc_wdata <= '0;
      endcase
   end
end
                     
endmodule : EX_MEM_Buffer
