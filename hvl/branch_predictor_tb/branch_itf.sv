`ifndef BRANCH_ITF_SV
`define BRANCH_ITF_SV
`timescale 1ns/10ps

interface branch_itf();

    localparam bhr_size = 7;

    /* Generate Clock */
    bit clk, rst;
    always #5 clk = clk === 1'b0;

    /* Error Reporting */
    int err_cnt;

    /*Ports*/
    logic [6:0] opcode_if; 
    logic is_branch_if;
    logic is_branch_ex;
    logic is_jump_if;
    logic is_jump_ex;
    logic cmp_out_ex;
    logic [31:0] pc_if;
    logic [31:0] pc_ex;
    logic [31:0] predicted_pc;
    logic [31:0] branch_pc_ex;
    logic [bhr_size-1:0] bhr_if;
    logic [bhr_size-1:0] bhr_ex;
    logic glob_predict_taken_if;
    logic loc_predict_taken_if;
    logic glob_predict_taken_ex;
    logic loc_predict_taken_ex;
    logic valid_branch;
    logic predict_taken;
    logic use_predicted;
    

endinterface
`endif
