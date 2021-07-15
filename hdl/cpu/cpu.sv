import rv32i_types::*;

module cpu
(
    input logic clk,
    input logic rst,
    input logic inst_resp,
    input logic data_resp,
    input logic [31:0] inst_rdata,
    input logic [31:0] data_rdata,
    output logic inst_read,
    output logic data_read,
    output logic data_write,
    output logic [31:0] inst_addr,
    output logic [31:0] data_addr,
    output logic [31:0] data_PC,
    output logic [3:0] data_mbe,
    output logic [31:0] data_wdata 
);

localparam bhr_size = 5;

//Monitored Signals
rv32i_mon_word mon_if, mon_id, mon_ex, mon_mem, mon_wb, mon_COMMIT;

//IF Stage Signals
logic is_jalr, br_en, /*loc_predict_taken_if, glob_predict_taken_if,*/ is_jump_if, is_branch_if;
rv32i_word alu_out_ex, pc_plus4_if, pc_out_if;
//logic [bhr_size-1:0] bhr_if;
assign inst_addr = pc_out_if;

//ID Stage Signals
logic /*loc_predict_taken_id, glob_predict_taken_id,*/ is_jump_id, is_branch_id;
rv32i_ctrl_word ctrl_id;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;
rv32i_word i_imm, u_imm, s_imm, b_imm, j_imm, pc_plus4_id, 
           pc_out_id, rs1_out_id, rs2_out_id, imm_id;
rv32i_reg rs1, rs2, rd;
//logic [bhr_size-1:0] bhr_id;

//EX Stage Signals
logic cmp_out_ex, /*loc_predict_taken_ex, glob_predict_taken_ex,*/ is_jump_ex, is_branch_ex;
rv32i_ctrl_word ctrl_ex;
rv32i_word pc_plus4_ex, pc_out_ex, rs1_out_ex, rs2_out_ex, imm_ex, data_wdata_ex, fmux1_out, fmux2_out;
//logic [bhr_size-1:0] bhr_ex;

//Mem Stage Signals
logic cmp_out_mem;
rv32i_ctrl_word ctrl_mem;
rv32i_word pc_plus4_mem, alu_out_mem, imm_mem, pc_out_mem, regfilemux_out_mem;
assign data_PC = ((mon_mem.opcode == op_load)||(mon_mem.opcode == op_store)) ? pc_out_mem : '0;

//WB Stage Signals
logic cmp_out_wb;
rv32i_ctrl_word ctrl_wb;
rv32i_word pc_plus4_wb, alu_out_wb, data_rdata_wb, imm_wb, pc_out_wb, regfilemux_out_wb;

//Forwarding Signals
logic load_use;
logic [1:0] forwardA, forwardB;

//Stall Signals
logic stall_data, stall_inst, br_miss;

//Branch Predictor Signals
logic predict_taken, use_predicted;
rv32i_word predicted_pc, branch_pc_ex, add_out;

assign is_jalr = ctrl_ex.is_jalr;
assign br_en = ctrl_ex.is_jump || (ctrl_ex.is_branch && cmp_out_ex );
assign stall_data = (data_read | data_write) & ~data_resp;
assign stall_inst = inst_read & ~inst_resp;
assign br_miss = (is_branch_ex || is_jump_ex) & (branch_pc_ex !== pc_out_id);

always_comb
begin
   unique case (ctrl_mem.regfilemux_sel)
      regfilemux::alu_out:  regfilemux_out_mem = alu_out_mem;
      regfilemux::cmp_out:  regfilemux_out_mem = {{31{1'b0}},cmp_out_mem};
      regfilemux::imm:      regfilemux_out_mem = imm_mem;
      regfilemux::pc_plus4: regfilemux_out_mem = pc_plus4_mem;
      default:              regfilemux_out_mem = '0;
   endcase
end

always_comb
begin
   data_read = ctrl_mem.data_read;
   data_write = ctrl_mem.data_write;
   data_addr = {alu_out_mem[31:2],2'b00};
   data_mbe = ctrl_mem.store_len << alu_out_mem % 4;
end

IF IF (
   .clk,
   .rst,
   .stall(stall_data | load_use),
   .inst_resp,
   .alu_out(add_out),
   .br_en(br_en),
   .is_jalr(is_jalr),
   .pc_plus4(pc_plus4_if),
   .pc_out(pc_out_if),
   .inst_read(inst_read),
   .mon_if,
   .use_predicted,
   .predicted_pc,
   .br_miss,
   .branch_pc_ex,
   .pc_out_ex
);

IF_ID_Buffer#(bhr_size)  IF_ID_Buffer (
   .clk,
   .rst, 
   .stall(stall_data | load_use | (stall_inst & br_miss)),
   .nop((stall_inst & !br_miss) | br_miss),
   .pc_plus4_if,
   .pc_out_if,
   .inst_rdata,
   .pc_plus4_id,
   .pc_out_id,
   .funct3,
   .funct7,
   .opcode,
   .i_imm,
   .s_imm,
   .b_imm,
   .u_imm,
   .j_imm,
   .rs1,
   .rs2,
   .rd,
   .mon_if,
   .mon_id,
  // .loc_predict_taken_if,
  // .glob_predict_taken_if,
   .is_branch_if,
   .is_jump_if,
   //.bhr_if,
  // .loc_predict_taken_id,
  // .glob_predict_taken_id,
   .is_branch_id,
   .is_jump_id
  // .bhr_id
);

ID_WB ID_WB (  
   .clk, 
   .rst, 
   .funct3, 
   .funct7, 
   .opcode, 
   .i_imm, 
   .s_imm,
   .b_imm, 
   .u_imm, 
   .j_imm, 
   .rs1, 
   .rs2, 
   .rd,
   .ctrl_wb,
   .imm_wb,
   .cmp_out(cmp_out_wb), 
   .alu_out(alu_out_wb), 
   .pc_plus4(pc_plus4_wb),
   .data_rdata(data_rdata_wb), 
   .imm(imm_id), 
   .rs1_out(rs1_out_id), 
   .rs2_out(rs2_out_id), 
   .ctrl_out(ctrl_id),
   .mon_wb,
   .mon_COMMIT,
   .regfilemux_out_wb
);
      
ID_EX_Buffer#(bhr_size) ID_EX_Buffer (
   .clk,
   .rst,
   .stall(stall_data | load_use | (stall_inst & br_miss)),
   .nop(br_miss),
   .ctrl_id,
   .mon_id,
   .pc_plus4_id,
   .pc_out_id,
   .rs1_out_id,
   .rs2_out_id,
   .imm_id,
   .f1mux_out_ex(fmux1_out),
   .f2mux_out_ex(fmux2_out),
   .ctrl_ex,
   .mon_ex,
   .pc_plus4_ex,
   .pc_out_ex,
   .rs1_out_ex,
   .rs2_out_ex,
   .imm_ex,
   //.loc_predict_taken_id,
   //.glob_predict_taken_id,
   .is_branch_id,
   .is_jump_id,
   //.bhr_id,
   //.loc_predict_taken_ex,
   //.glob_predict_taken_ex,
   .is_branch_ex,
   .is_jump_ex
   //.bhr_ex
);
      
EX EX (
   .clk,
   .rst,
   .ctrl(ctrl_ex),
   .pc_plus4(pc_plus4_ex),
   .pc_out(pc_out_ex),
   .rs1_out(rs1_out_ex),
   .rs2_out(rs2_out_ex),
   .regfilemux_out_mem,
   .regfilemux_out_wb,
   .imm(imm_ex),
   .alu_out(alu_out_ex),
   .forwardA(forwardA),
   .forwardB(forwardB),
   .cmp_out(cmp_out_ex),
   .data_wdata(data_wdata_ex),
   .fmux1_out,
   .fmux2_out,
	.add_out
);
      
EX_MEM_Buffer EX_MEM_Buffer ( 
   .clk,
   .rst,
   .stall(stall_data),
   .nop(load_use | (stall_inst & br_miss)),
   .ctrl_ex,
   .mon_ex,
   .pc_plus4_ex,
   .alu_out_ex,
   .cmp_out_ex,
   .data_wdata_ex,
   .imm_ex,
   .pc_out_ex,
   .fmux1_out,
   .fmux2_out,
   .ctrl_mem,
   .mon_mem,
   .pc_plus4_mem,
   .alu_out_mem,
   .cmp_out_mem,
   .data_wdata_mem(data_wdata),
   .imm_mem,
   .pc_out_mem
);
   
MEM_WB_Buffer MEM_WB_Buffer (
   .clk,
   .rst,
   .stall(1'b0),
   .nop(stall_data),
   .ctrl_mem,
   .mon_mem,
   .pc_plus4_mem,
   .alu_out_mem,
   .data_rdata_mem(data_rdata),
   .cmp_out_mem,
   .imm_mem,
   .pc_out_mem,
   .ctrl_wb,
   .mon_wb,
   .pc_plus4_wb,
   .alu_out_wb,
   .data_rdata_wb,
   .cmp_out_wb,
   .imm_wb,
   .pc_out_wb
);

forwarding forwarding (
   .ctrl_ex,
   .ctrl_mem,
   .ctrl_wb,
   .forwardA,
   .forwardB,
   .load_use
);

branch_predictor branch_predictor(
   .clk,
   .rst,
   .opcode_if(inst_rdata[6:0]),
   .pc_if(pc_out_if),
   .is_branch_ex,
   .is_jump_ex,
   .pc_ex(pc_out_ex),
   .branch_pc_ex,
   .cmp_out_ex,
   //.bhr_ex,
   //.loc_predict_taken_ex,
   //.glob_predict_taken_ex,
   .is_branch_if,
   .is_jump_if,
   .predict_taken,
   //.loc_predict_taken_if,
   //.glob_predict_taken_if,
   .predicted_pc,
   .use_predicted
   //.bhr_if
);
      
endmodule : cpu
