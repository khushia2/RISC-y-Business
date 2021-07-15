 `ifndef LOCAL_MONITOR
`define LOCAL_MONITOR

module branch_local_monitor(branch_itf itf);

localparam N = 128;
localparam n = $clog2(N);

logic [1:0] counters[N];
logic [31:0] pcs[N];

function void count(logic[n-1:0] idx, logic taken);
    if ( taken && counters[idx] != 2'b11 )
        counters[idx]++;
    else if ( !taken && counters[idx] != 2'b00 )
        counters[idx]--;  
endfunction

function void write(logic[n-1:0] idx, logic taken, logic[32:0] pc);
    count(idx, taken);
    pcs[idx] = pc;
endfunction

logic predict_taken;
initial begin
	$display("Start Local Monitor");
    fork
        begin : read_predictor
            forever begin
                @(negedge itf.clk iff itf.is_branch_if)
                predict_taken = pcs[itf.pc_if[n+1:2]] === itf.pc_if && counters[itf.pc_if[n+1:2]][1];
                if (predict_taken != itf.loc_predict_taken_if) begin
                    $display("%0t: Local Predictor Error:", $time,
                        "PC %8h Expected %d, Detected %d", itf.pc_if, predict_taken, itf.loc_predict_taken_if);
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
                    write(itf.pc_ex[n+1:2], itf.cmp_out_ex, itf.pc_ex);
            end
        end
    join_none
end

endmodule

`endif
