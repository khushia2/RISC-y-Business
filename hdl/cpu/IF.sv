import rv32i_types::*;
`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

module IF
(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic inst_resp,
    input logic [31:0] alu_out,
    input logic br_en,
    input logic is_jalr,
    input logic use_predicted,
    input logic [31:0] predicted_pc,
    input logic br_miss,
    input logic [31:0] pc_out_ex,
    output logic [31:0] pc_plus4,
    output logic [31:0] pc_out,
    output logic inst_read,
    output logic [31:0] branch_pc_ex,
    output rv32i_mon_word mon_if
);

logic pc_load;
logic [2:0] pcmux_sel;
logic [31:0] next_pc, pcmux_out;

assign inst_read = ~stall;
assign pc_plus4 = pc_out + 4;
assign pcmux_sel = {is_jalr, br_en};
assign pc_load = ~stall && inst_resp;
assign branch_pc_ex = pcmux_out;
assign next_pc = br_miss ? pcmux_out : (use_predicted ? predicted_pc : pc_plus4);

always_comb begin
   mon_if = '0;
   mon_if.pc_rdata = pc_out;
   mon_if.pc = pc_out;
end

pc_register PC (
   .clk (clk),
   .rst (rst),
   .load (pc_load),
   .in (next_pc),
   .out (pc_out)
);

always_comb begin : MUXES
   unique case (pcmux_sel)
      pcmux::pc_plus4: pcmux_out = pc_out_ex + 4;
      pcmux::alu_out:  pcmux_out = alu_out;
      pcmux::alu_mod2: pcmux_out = {alu_out[31:2],2'b00};
      default:         pcmux_out = '0;
   endcase
end

endmodule : IF

