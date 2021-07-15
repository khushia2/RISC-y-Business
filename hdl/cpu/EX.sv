import rv32i_types::*;
`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

module EX ( input logic clk,
            input logic rst,
            input rv32i_ctrl_word ctrl,
            input rv32i_word pc_plus4,
            input rv32i_word pc_out,
            input rv32i_word rs1_out,
            input rv32i_word rs2_out,
            input rv32i_word regfilemux_out_mem,
            input rv32i_word regfilemux_out_wb,
            input logic[1:0] forwardA,
            input logic[1:0] forwardB,
            input rv32i_word imm,
            output logic cmp_out,
            output rv32i_word alu_out,
            output rv32i_word data_wdata,
            output rv32i_word fmux1_out,
            output rv32i_word fmux2_out,
				output rv32i_word add_out
         );

rv32i_word alumux1_out, alumux2_out, cmpmux_out;

assign data_wdata = fmux2_out << (alu_out%4)*8;
assign add_out = alumux1_out + alumux2_out;

always_comb begin : MUXES   
   unique case (forwardA)
      fmux::rs_out:            fmux1_out = rs1_out;
      fmux::regfilemux_out_mem: fmux1_out = regfilemux_out_mem;
      fmux::regfilemux_out_wb:  fmux1_out = regfilemux_out_wb;
      default:                  fmux1_out = 32'b0;
   endcase

   unique case (forwardB)
      fmux::rs_out:            fmux2_out = rs2_out;
      fmux::regfilemux_out_mem: fmux2_out = regfilemux_out_mem;
      fmux::regfilemux_out_wb:  fmux2_out = regfilemux_out_wb;
      default:                  fmux2_out = 32'b0;
   endcase

   unique case (ctrl.cmpmux_sel)
      cmpmux::rs2_out: cmpmux_out = fmux2_out;
      cmpmux::imm:     cmpmux_out = imm;
      default:         cmpmux_out = 32'b0;
   endcase

   unique case (ctrl.alumux1_sel)
      alumux::rs1_out: alumux1_out = fmux1_out;
      alumux::pc_out:  alumux1_out = pc_out;
      default:         alumux1_out = 32'b0;
   endcase

   unique case (ctrl.alumux2_sel)
      alumux::imm:     alumux2_out = imm;
      alumux::rs2_out: alumux2_out = fmux2_out;
      default:         alumux2_out = 32'b0;
   endcase
end

alu ALU(.aluop(ctrl.alu_op),
        .a(alumux1_out),
        .b(alumux2_out),
        .f(alu_out));
   
comparator CMP(.cmpop(ctrl.cmp_op),
               .a(fmux1_out), 
               .b(cmpmux_out),
               .b_en(cmp_out));

endmodule : EX
