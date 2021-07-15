 `ifndef LOCAL_MONITOR
`define LOCAL_MONITOR

module branch_meta_monitor(branch_itf itf);

localparam N = 128;
localparam n = $clog2(N);

logic [1:0] counters[N];
logic [31:0] pcs[N];

function void count(logic[n-1:0] idx, logic glob_correct, loc_correct);
    if ( glob_correct && !loc_correct && counters[idx] != 2'b11 )
        counters[idx]++;
    else if ( loc_correct && !glob_correct && counters[idx] != 2'b00 )
        counters[idx]--;  
endfunction

function void write(logic[n-1:0] idx, logic[32:0] pc, logic glob_correct, logic loc_correct);
    count(idx, glob_correct, loc_correct);
    pcs[idx] = pc;
endfunction

logic predict_taken, tag_match;
assign predict_taken = counters[itf.pc_if[n+1:2]][1] ? itf.glob_predict_taken_if : itf.loc_predict_taken_if;
assign tag_match = pcs[itf.pc_if[n+1:2]] === itf.pc_if;

initial begin
	$display("Start Meta Monitor");
    fork
        begin : read_predictor
            forever begin
                @(negedge itf.clk iff itf.is_branch_if)
                
                if (predict_taken != itf.predict_taken) begin
                    $display("%0t: Meta Predictor Error:", $time,
                        "PC %8h Expected %d, Detected %d", itf.pc_if, predict_taken, itf.predict_taken);
                end
                if (tag_match != itf.valid_branch) begin
                    $display("%0t: Meta Predictor Tag Error:", $time,
                        "PC %8h Expected %d, Detected %d", itf.pc_if, tag_match, itf.valid_branch);
                    itf.err_cnt++;
                end
            end
        end

        begin : write_predictor
            forever begin
                @(posedge itf.clk)
                if (itf.rst) begin
                    itf.err_cnt = '0;
                    for (int i = 0; i < N; i++) begin
                        counters[i] = 2'b01;
                        pcs[i] = '0;
                    end
                end
                else if(itf.is_branch_ex)
                    write(itf.pc_ex[n+1:2], itf.pc_ex, itf.cmp_out_ex === itf.glob_predict_taken_ex, itf.cmp_out_ex === itf.loc_predict_taken_ex);
            end
        end
    join_none
end

endmodule

`endif
