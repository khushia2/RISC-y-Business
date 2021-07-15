 `ifndef BRANCH_MONITOR
`define BRANCH_MONITOR

module branch_monitor(branch_itf itf);

branch_local_monitor loc_mon(itf);
branch_global_monitor glob_mon(itf);
branch_meta_monitor meta_mon(itf);

//MonitorBTB:

localparam N = 128;
localparam n = $clog2(N);

logic [31:0] pcs[N], target_pcs[N];

initial begin
	$display("Start BTB Monitor");
    fork
        begin : read_predictor
            forever begin
                @(negedge itf.clk iff itf.is_branch_if)
                if (itf.predicted_pc != target_pcs[itf.pc_if[n+1:2]]) begin
                    $display("%0t: BTB Error:", $time,
                        "PC %8h Expected %8h, Detected %8h", itf.pc_if, target_pcs[itf.pc_if[n+1:2]], itf.predicted_pc);
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
                        target_pcs[i] = '0;
                        pcs[i] = '0;
                    end
                end
                else if(itf.is_branch_ex)
                    pcs[itf.pc_ex[n+1:2]] = itf.pc_ex;
                    target_pcs[itf.pc_ex[n+1:2]] = itf.branch_pc_ex;
            end
        end
    join_none
end

endmodule

`endif
