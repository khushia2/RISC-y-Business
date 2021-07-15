import rv32i_types::*;

module forwarding
(
   input rv32i_ctrl_word ctrl_ex,
   input rv32i_ctrl_word ctrl_mem,
   input rv32i_ctrl_word ctrl_wb,
   output logic [1:0] forwardA,
   output logic [1:0] forwardB,
   output logic load_use
);

always_comb
begin
   forwardA = fmux::rs_out;
   forwardB = fmux::rs_out;
   load_use = 1'b0;

   //EX-WB Hazard
   if (ctrl_wb.regfile_write && ctrl_wb.rd !== '0) begin
      if(ctrl_wb.rd === ctrl_ex.rs1)
         forwardA = fmux::regfilemux_out_wb;
      if(ctrl_wb.rd === ctrl_ex.rs2)
         forwardB = fmux::regfilemux_out_wb;
   end
   
   //EX-MEM Hazard -> these will "overwrite" EX-WB hazards, giving mem priority
   if (ctrl_mem.regfile_write && ctrl_mem.rd !== '0) begin
      if (ctrl_mem.rd === ctrl_ex.rs1)
         forwardA = fmux::regfilemux_out_mem;
      if (ctrl_mem.rd === ctrl_ex.rs2)
         forwardB = fmux::regfilemux_out_mem;
   end

   //load_use
   if (ctrl_mem.data_read && ctrl_mem.rd !== '0 && (ctrl_mem.rd === ctrl_ex.rs1 || ctrl_mem.rd === ctrl_ex.rs2))
      load_use = 1'b1;
end
  
endmodule : forwarding

