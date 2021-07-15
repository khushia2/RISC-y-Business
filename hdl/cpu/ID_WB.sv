import rv32i_types::*;

module ID_WB
(
    input logic clk,
    input logic rst,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input rv32i_opcode opcode,
    input rv32i_word i_imm,
    input rv32i_word s_imm,
    input rv32i_word b_imm,
    input rv32i_word u_imm,
    input rv32i_word j_imm,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rd,
    input rv32i_ctrl_word ctrl_wb,
    input rv32i_mon_word mon_wb,
    input rv32i_word imm_wb,
    input logic cmp_out,
    input rv32i_word alu_out,
    input rv32i_word pc_plus4,
    input rv32i_word data_rdata,
    output rv32i_word imm,
    output rv32i_word rs1_out,
    output rv32i_word rs2_out,
    output rv32i_ctrl_word ctrl_out,
    output rv32i_mon_word mon_COMMIT,
    output rv32i_word regfilemux_out_wb
);

rv32i_word regfilemux_out, data_rdata_shifted, rs1_reg_out, rs2_reg_out;

assign regfilemux_out_wb = regfilemux_out;
assign data_rdata_shifted = data_rdata >> (alu_out % 4) * 8;

//make transparent regfile
assign rs1_out = (ctrl_wb.regfile_write && ctrl_wb.rd === ctrl_out.rs1) ? ((ctrl_wb.rd === '0) ? '0 : regfilemux_out) : rs1_reg_out;
assign rs2_out = (ctrl_wb.regfile_write && ctrl_wb.rd === ctrl_out.rs2) ? ((ctrl_wb.rd === '0) ? '0 : regfilemux_out) : rs2_reg_out;

control control( .funct3, .funct7, .opcode, .rs1, .rs2, .rd, .ctrl(ctrl_out) );

regfile regfile( .clk, .rst, .load(ctrl_wb.regfile_write), .in(regfilemux_out),
                 .src_a(ctrl_out.rs1), .src_b(ctrl_out.rs2), .dest(ctrl_wb.rd), .reg_a(rs1_reg_out), .reg_b(rs2_reg_out) );
                 
always_comb
begin
   unique case (ctrl_wb.regfilemux_sel)
      regfilemux::alu_out:  regfilemux_out = alu_out;
      regfilemux::cmp_out:  regfilemux_out = {{31{1'b0}},cmp_out};
      regfilemux::imm:      regfilemux_out = imm_wb;
      regfilemux::lw:       regfilemux_out = data_rdata;
      regfilemux::pc_plus4: regfilemux_out = pc_plus4;
      regfilemux::lb:       regfilemux_out = 32'(signed'(data_rdata_shifted[7:0]));
      regfilemux::lbu:      regfilemux_out = 32'(data_rdata_shifted[7:0]);
      regfilemux::lh:       regfilemux_out = 32'(signed'(data_rdata_shifted[15:0]));
      regfilemux::lhu:      regfilemux_out = 32'(data_rdata_shifted[15:0]);
      default:              regfilemux_out = alu_out;
   endcase
end

always_comb
begin
   unique case (opcode)
      op_lui,
      op_auipc: imm = u_imm;
      op_jal:   imm = j_imm;
      op_br:    imm = b_imm;
      op_store: imm = s_imm;
      op_jalr,
      op_load,
      op_imm:   imm = i_imm;
      default:  imm = i_imm;
   endcase
end

always_comb begin
   mon_COMMIT = mon_wb;
   mon_COMMIT.load_regfile = ctrl_wb.regfile_write;
   mon_COMMIT.rd_wdata = (ctrl_wb.regfile_write && mon_wb.rd_addr != '0) ? regfilemux_out : '0;
   mon_COMMIT.mem_rdata = ctrl_wb.data_read ? data_rdata : '0;
   unique case (ctrl_wb.regfilemux_sel)
      regfilemux::lw:  mon_COMMIT.mem_rmask <= 4'b1111;
      regfilemux::lh,
      regfilemux::lhu: mon_COMMIT.mem_rmask <= alu_out[1] ? 4'b1100 : 4'b0011;
      regfilemux::lb,
      regfilemux::lbu: mon_COMMIT.mem_rmask <= 4'b0001 << alu_out[1:0];
      default:         mon_COMMIT.mem_rmask <= 4'b0000;
   endcase
end
endmodule : ID_WB