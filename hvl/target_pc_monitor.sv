`ifndef TARG_PC_MON
`define TARG_PC_MON

module target_pc_monitor( rvfi_itf rvfi, output logic err_detect );

function automatic logic branch_calc(logic [2:0] funct, logic [31:0] rs1, logic [31:0] rs2);
    logic taken;
    unique case(funct)
      3'b000: taken = rs1 === rs2;
      3'b001: taken = rs1 !== rs2;
      3'b100: taken = signed'(rs1) < signed'(rs2);
      3'b101: taken = signed'(rs1) >= signed'(rs2);
      3'b110: taken = unsigned'(rs1) < unsigned'(rs2);
      3'b111: taken = unsigned'(rs1) >= unsigned'(rs2);
      default: begin
         $display("ERROR: INVALID BRANCH FUNCT");
         err_detect = 1'b1;
         taken = 1'b0;
      end
    endcase
    return taken;
endfunction

int errcount;
logic [31:0] expected_nextpc;
logic is_jal, is_jalr, is_br, taken;

initial begin
   errcount = 0;
   expected_nextpc  = 32'h00000060;
   is_jal = 1'b0;
   is_jalr = 1'b0;
   is_br = 1'b0;
   taken = 1'b0;
   err_detect = 1'b0;

   fork
      begin : monitor
         forever begin
            @(posedge rvfi.clk iff rvfi.commit)
            begin
               //check that this PC is correct
               if (rvfi.pc_rdata !== expected_nextpc) begin
                  $display("%0t: TargetPC Error:", $time,
                     " Expected %8h, Detected %8h", expected_nextpc, rvfi.pc_rdata);
                     errcount++;
                     err_detect = 1'b1;
               end
               
               //calculate next pc
               is_jal =  rvfi.inst[6:0] === 7'b1101111;
               is_jalr = rvfi.inst[6:0] === 7'b1100111;
               is_br =   rvfi.inst[6:0] === 7'b1100011;
               if (is_jal)
                  expected_nextpc = rvfi.pc_rdata + {{12{rvfi.inst[31]}}, rvfi.inst[19:12], rvfi.inst[20], rvfi.inst[30:21], 1'b0};
               else if (is_jalr) begin
                  expected_nextpc = rvfi.rs1_rdata + {{21{rvfi.inst[31]}}, rvfi.inst[30:20]};
                  expected_nextpc[1:0] = 2'b00;
               end
               else if (is_br) begin
                  taken = branch_calc(rvfi.inst[14:12], rvfi.rs1_rdata, rvfi.rs2_rdata);
                  expected_nextpc = taken ? (rvfi.pc_rdata + {{20{rvfi.inst[31]}}, rvfi.inst[7], rvfi.inst[30:25], rvfi.inst[11:8], 1'b0}) : (rvfi.pc_rdata + 4);
               end
               else
                  expected_nextpc = rvfi.pc_rdata + 4;
            end
         end
      end
   join_none
end

endmodule

`endif