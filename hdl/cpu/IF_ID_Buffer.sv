import rv32i_types::*;

module IF_ID_Buffer#(parameter bhr_size = 7)
(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic nop,
    input rv32i_word pc_plus4_if,
    input rv32i_word pc_out_if,
    input rv32i_word inst_rdata,
    input rv32i_mon_word mon_if,
    //input logic loc_predict_taken_if,
    //input logic glob_predict_taken_if,
    input logic is_branch_if,
    input logic is_jump_if,
    //input logic[bhr_size-1:0] bhr_if,
    output rv32i_word pc_plus4_id,
    output rv32i_word pc_out_id,
    output [2:0] funct3,
    output [6:0] funct7,
    output rv32i_opcode opcode,
    output [31:0] i_imm,
    output [31:0] s_imm,
    output [31:0] b_imm,
    output [31:0] u_imm,
    output [31:0] j_imm,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output rv32i_mon_word mon_id,
    //output logic loc_predict_taken_id,
    //output logic glob_predict_taken_id,
    output logic is_branch_id,
    output logic is_jump_id
    //output logic[bhr_size-1:0] bhr_id
);

logic [31:0] data;

assign funct3 = data[14:12];
assign funct7 = data[31:25];
assign opcode = rv32i_opcode'(data[6:0]);
assign i_imm = {{21{data[31]}}, data[30:20]};
assign s_imm = {{21{data[31]}}, data[30:25], data[11:7]};
assign b_imm = {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
assign u_imm = {data[31:12], 12'h000};
assign j_imm = {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};
assign rs1 = data[19:15];
assign rs2 = data[24:20];
assign rd = data[11:7];

always_ff @(posedge clk)
begin
   if (rst || (nop && ~stall)) begin
      pc_plus4_id   <= '0;
      pc_out_id     <= '0;
      data          <= '0;
      //loc_predict_taken_id  <= 1'b0;
      //glob_predict_taken_id <= 1'b0;
      is_branch_id  <= 1'b0;
      is_jump_id    <= 1'b0;
      //bhr_id        <= '0;
      mon_id        <= '0;
      mon_id.opcode <= op_imm; //NOP
      mon_id.inst   <= 'h13; //NOP
   end
   else if (stall) begin
      pc_plus4_id <= pc_plus4_id;
      pc_out_id   <= pc_out_id;
      data        <= data;
      //loc_predict_taken_id  <= loc_predict_taken_id;
      //glob_predict_taken_id <= glob_predict_taken_id;
      is_branch_id <= is_branch_id;
      is_jump_id  <= is_jump_id;
      //bhr_id      <= bhr_id;
      mon_id      <= mon_id;
   end
   else begin
      pc_plus4_id     <= pc_plus4_if;
      pc_out_id       <= pc_out_if;
      data            <= inst_rdata;  
      //loc_predict_taken_id  <= loc_predict_taken_if;
      //glob_predict_taken_id <= glob_predict_taken_if;
      is_branch_id    <= is_branch_if;
      is_jump_id      <= is_jump_if;
      //bhr_id          <= bhr_if;    
      mon_id          <= mon_if;
      mon_id.commit   <= 1'b1;
      mon_id.inst     <= inst_rdata;
      mon_id.opcode   <= rv32i_opcode'(inst_rdata[6:0]);
      mon_id.mem_addr <= pc_out_if;
      mon_id.pc       <= pc_out_if;
   end
end

endmodule : IF_ID_Buffer

