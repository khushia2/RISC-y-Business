import rv32i_types::*;

module control
(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input rv32i_reg rs1,
    input rv32i_reg rs2,
    input rv32i_reg rd,
    input rv32i_opcode opcode,
    output rv32i_ctrl_word ctrl
);

function void set_defaults();
    ctrl.alumux1_sel = alumux::rs1_out;
    ctrl.rs1 = rs1;
    ctrl.alumux2_sel = alumux::imm;
    ctrl.rs2 = 0;
    ctrl.rd = rd;
    ctrl.cmpmux_sel = cmpmux::rs2_out;
    ctrl.alu_op = alu_add;
    ctrl.cmp_op = cmp_eq;
    ctrl.is_branch = 1'b0;
    ctrl.is_jump = 1'b0;
    ctrl.is_jalr = 1'b0;
    ctrl.data_read = 1'b0;
    ctrl.data_write = 1'b0;
    ctrl.store_len = 4'b0000;
    ctrl.regfile_write = 1'b0;
    ctrl.regfilemux_sel = regfilemux::alu_out;
endfunction

always_comb
begin
    set_defaults();
    case (opcode)
        op_lui:
        begin
            ctrl.regfile_write = 1'b1;
            ctrl.regfilemux_sel = regfilemux::imm;
        end
        op_auipc:
        begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.rs1 = 0;
            ctrl.regfile_write = 1'b1;
        end
        op_jal:
        begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.rs1 = 0;
            ctrl.is_jump = 1'b1;
            ctrl.regfile_write = 1;
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
        end
        op_jalr:
        begin
            ctrl.is_jalr = 1'b1;
            ctrl.regfile_write = 1'b1;
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
        end
        op_br:
        begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.rs2 = rs2;
            ctrl.cmp_op = cmp_ops'(funct3);
            ctrl.is_branch = 1'b1;
            ctrl.rd = '0;
        end
        op_load:
        begin
            ctrl.data_read = 1'b1;
            ctrl.regfile_write = 1'b1;
            unique case (load_funct3_t'(funct3))
                lb:  ctrl.regfilemux_sel = regfilemux::lb;
                lh:  ctrl.regfilemux_sel = regfilemux::lh;
                lw:  ctrl.regfilemux_sel = regfilemux::lw;
                lbu: ctrl.regfilemux_sel = regfilemux::lbu;
                lhu: ctrl.regfilemux_sel = regfilemux::lhu;
                default: ctrl.regfilemux_sel = regfilemux::lw;
            endcase
        end
        op_store:
        begin
            ctrl.data_write = 1'b1;
            ctrl.rs2 = rs2;
            ctrl.rd = '0;
            unique case (store_funct3_t'(funct3))
                sb: ctrl.store_len = 4'b0001;
                sh: ctrl.store_len = 4'b0011;
                sw: ctrl.store_len = 4'b1111;
                default: ctrl.store_len = 4'b1111;
            endcase
        end
        op_imm:
        begin
            ctrl.regfile_write = 1'b1;
            ctrl.cmpmux_sel = cmpmux::imm;
            ctrl.cmp_op = cmp_ops'(funct3);
            unique case (arith_funct3_t'(funct3))
                sll:    ctrl.alu_op = alu_sll;
                axor:   ctrl.alu_op = alu_xor;
                sr:     ctrl.alu_op = funct7[5] === 1'b1 ? alu_sra : alu_srl;
                aor:    ctrl.alu_op = alu_or;
                aand:   ctrl.alu_op = alu_and;
                default: ctrl.alu_op = alu_add;
            endcase
            ctrl.regfilemux_sel = ( arith_funct3_t'(funct3) === slt || 
                arith_funct3_t'(funct3) === sltu ) ? regfilemux::cmp_out : regfilemux::alu_out;
        end
        op_reg:
        begin
            ctrl.alumux2_sel = alumux::rs2_out;
            ctrl.rs2 = rs2;
            ctrl.regfile_write = 1'b1;
            ctrl.cmp_op = cmp_ops'(funct3);
            unique case (arith_funct3_t'(funct3))
                add:    ctrl.alu_op = funct7[5] === 1'b1 ? alu_sub : alu_add;
                sll:    ctrl.alu_op = alu_sll;
                axor:   ctrl.alu_op = alu_xor;
                sr:     ctrl.alu_op = funct7[5] === 1'b1 ? alu_sra : alu_srl;
                aor:    ctrl.alu_op = alu_or;
                aand:   ctrl.alu_op = alu_and;
                default: ctrl.alu_op = alu_add;
            endcase
            ctrl.regfilemux_sel = ( arith_funct3_t'(funct3) === slt || 
                arith_funct3_t'(funct3) === sltu ) ? regfilemux::cmp_out : regfilemux::alu_out;
        end
        default: ;
    endcase
end

endmodule : control
