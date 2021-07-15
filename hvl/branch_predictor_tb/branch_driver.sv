module branch_driver(
    branch_itf itf
);

logic is_branch_id, cmp_out_if, cmp_out_id, glob_predict_taken_id, loc_predict_taken_id, is_jump_id;
logic [31:0] pc_id, branch_pc_id, branch_pc_if;
logic [6:0] bhr_id;

always @(posedge itf.clk) begin
    itf.is_branch_ex <= is_branch_id;
    is_branch_id <= itf.is_branch_if;
    itf.is_jump_ex <= is_jump_id;
    is_jump_id <= itf.is_jump_if;
    itf.pc_ex <= pc_id;
    pc_id <= itf.pc_if;
    itf.bhr_ex <= bhr_id;
    bhr_id <= itf.bhr_if;
    itf.cmp_out_ex <= cmp_out_id;
	cmp_out_id <= cmp_out_if;
    itf.glob_predict_taken_ex <= glob_predict_taken_id;
    glob_predict_taken_id <= itf.glob_predict_taken_if;
    itf.loc_predict_taken_ex <= loc_predict_taken_id;
    loc_predict_taken_id <= itf.loc_predict_taken_if;
    itf.branch_pc_ex <= branch_pc_id;
    branch_pc_id <= branch_pc_if;
end

function logic[6:0] get_opcode(logic[2:0] idx);
    logic[6:0] to_return;
    unique case(idx)
        3'b001: to_return = 7'b1101111;
        3'b010: to_return = 7'b1100111;
        3'b011: to_return = 7'b1100011;
        default: to_return = 7'b0010011;
    endcase
    return to_return;
endfunction

initial begin
    $display("Compilation Successful");
	 
	is_branch_id = 1'b0;
    cmp_out_if = 1'b0;
    cmp_out_id = 1'b0;
    glob_predict_taken_id = 1'b0;
    loc_predict_taken_id = 1'b0;
    is_jump_id = 1'b0;
    pc_id = '0;
    branch_pc_id = '0;
    branch_pc_if = '0;
    bhr_id = '0;
    
    for(int i = 0; i < 1000000; i++) begin
        itf.pc_if = $random;
        itf.pc_if[1:0] = 2'b00;
        itf.pc_if[31:12] = '0;
        itf.opcode_if = get_opcode(itf.pc_if[4:2]);
        itf.is_branch_if = itf.pc_if[10];
        cmp_out_if = $random;
        branch_pc_if = branch_pc_if;
        @(posedge itf.clk);
    end

    if(itf.err_cnt > 0)
        $display("Finished: %d errors", itf.err_cnt);
    else
        $display("Finished: Success!");
		  
	 $finish;
end

endmodule

