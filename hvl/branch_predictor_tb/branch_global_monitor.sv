 `ifndef LOCAL_MONITOR
`define LOCAL_MONITOR

module branch_global_monitor(branch_itf itf);

localparam N = 128;
localparam n = $clog2(N);

logic [1:0] counters[N];
logic [n-1:0] bhr;

function void count(logic[n-1:0] idx, logic taken);
    if ( taken && counters[idx] != 2'b11 )
        counters[idx]++;
    else if ( !taken && counters[idx] != 2'b00 )
        counters[idx]--;  
endfunction

function void write(logic[n-1:0] idx, logic taken);
    count(idx, taken);
    bhr = bhr << 1;
    bhr[0] = taken;
endfunction

logic predict_taken;
assign predict_taken = counters[bhr][1];

initial begin
	$display("Start Global Monitor");
    fork
        begin : read_predictor
            forever begin
                @(negedge itf.clk iff itf.is_branch_if)            
                if (predict_taken !== itf.glob_predict_taken_if) begin
                    $display("%0t: Global Predictor Error:", $time,
                        "BHR %8h Expected %d, Detected %d", bhr, predict_taken, itf.glob_predict_taken_if);
                    itf.err_cnt++;
                end
                if (bhr !== itf.bhr_if) begin
                    $display("%0t: Global Predictor BHR Mismatch:", $time,
                        "Expected %d, Detected %d", bhr, itf.bhr_if);
                    itf.err_cnt++;
                end
            end
        end

        begin : write_predictor
            forever begin
                @(posedge itf.clk)
                if (itf.rst) begin
                    itf.err_cnt = '0;
                    bhr = '0;
                    for (int i = 0; i < N; i++) begin
                        counters[i] = 2'b01;
                    end
                end
                else if(itf.is_branch_ex)
                    write(itf.bhr_ex, itf.cmp_out_ex);
            end
        end
    join_none
end

endmodule

`endif
