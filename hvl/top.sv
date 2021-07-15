module mp4_tb;
`timescale 1ns/10ps
`define PRINT_DEBUGGING 0

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2
assign rvfi.commit = dut.cpu.mon_COMMIT.commit; // Set high when a valid instruction is modifying regfile or PC


logic halt_condition, halt = '0;
logic [31:0] halt_pc = '0;
assign halt_condition = dut.cpu.br_en & (dut.cpu.alu_out_ex === dut.cpu.pc_out_ex ? 1'b1 : 1'b0);
always @(posedge itf.clk iff halt_condition) halt <= 1'b1;
always @(posedge halt) halt_pc <= dut.cpu.pc_out_ex;
assign rvfi.halt = halt & ((halt_pc === dut.cpu.pc_out_wb) ? 1'b1 : 1'b0);
                   
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/

always_comb begin
   rvfi.inst = dut.cpu.mon_COMMIT.inst;
   
   rvfi.rs1_addr = dut.cpu.mon_COMMIT.rs1_addr;
   rvfi.rs2_addr = dut.cpu.mon_COMMIT.rs2_addr;
   rvfi.rd_addr = dut.cpu.mon_COMMIT.rd_addr;
   rvfi.rs1_rdata = dut.cpu.mon_COMMIT.rs1_rdata;
   rvfi.rs2_rdata = dut.cpu.mon_COMMIT.rs2_rdata;
   rvfi.rd_wdata = dut.cpu.mon_COMMIT.rd_wdata;
   rvfi.load_regfile = dut.cpu.mon_COMMIT.load_regfile;
   rvfi.pc_rdata = dut.cpu.mon_COMMIT.pc_rdata;
   rvfi.pc_wdata = dut.cpu.mon_COMMIT.pc_wdata;
   
   rvfi.mem_addr = dut.cpu.mon_COMMIT.mem_addr;
   rvfi.mem_rmask = dut.cpu.mon_COMMIT.mem_rmask;
   rvfi.mem_wmask = dut.cpu.mon_COMMIT.mem_wmask;
   rvfi.mem_rdata = dut.cpu.mon_COMMIT.mem_rdata;
   rvfi.mem_wdata = dut.cpu.mon_COMMIT.mem_wdata;
end

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/

assign itf.inst_read = dut.inst_read;
assign itf.inst_addr = dut.inst_addr;
assign itf.inst_resp = dut.inst_resp;
assign itf.inst_rdata = dut.inst_rdata;
assign itf.data_read = dut.data_read;
assign itf.data_write = dut.data_write;
assign itf.data_mbe = dut.data_mbe;
assign itf.data_addr = dut.data_addr;
assign itf.data_wdata = dut.data_wdata;
assign itf.data_resp = dut.data_resp;
assign itf.data_rdata = dut.data_rdata;

/*********************** End Shadow Memory Assignments ***********************/

assign itf.registers = dut.cpu.ID_WB.regfile.data;

/*********************** Instantiate your design here ************************/

mp4 dut(
   .clk(itf.clk),
   .rst(itf.rst), 
   .mem_resp(itf.mem_resp),
   .mem_rdata(itf.mem_rdata),  
   .mem_read(itf.mem_read),
   .mem_write(itf.mem_write),
   .mem_address(itf.mem_addr),
   .mem_wdata(itf.mem_wdata)
);


/***************************** End Instantiation *****************************/

/***************************PERFORMANCE COUNTERS******************************/
int num_inst, tot_br, tot_correct_predict, tot_correct_glob, tot_correct_loc;
int tot_jmp, tot_jmp_correct, inst_hits, inst_misses, data_hits, data_misses;
int l2_hits, l2_misses, inst_stalls, data_stalls, jmp_br_stalls, load_use_stalls;
int num_prefetches_requested, num_prefetches_ex;

initial num_inst = 0;
initial tot_br = 0;
initial tot_correct_predict = 0;
//initial tot_correct_glob = 0;
//initial tot_correct_loc = 0;
initial tot_jmp = 0;
initial tot_jmp_correct = 0;
initial inst_hits = 0;
initial inst_misses = 0;
initial data_hits = 0;
initial data_misses = 0;
initial l2_hits = 0;
initial l2_misses = 0;
initial inst_stalls = 0;
initial data_stalls = 0;
initial jmp_br_stalls = 0;
initial load_use_stalls = 0;
initial num_prefetches_requested = 0;
initial num_prefetches_ex = 0;
 
always @(posedge itf.clk) begin
	if (dut.cpu.mon_COMMIT.commit)
		num_inst++;
   if (dut.cpu.is_branch_ex) begin
      tot_br++;
      if (dut.cpu.branch_pc_ex === dut.cpu.pc_out_id)
         tot_correct_predict++;
//      if (dut.cpu.cmp_out_ex === dut.cpu.loc_predict_taken_ex)
//         tot_correct_loc++;
//      if (dut.cpu.cmp_out_ex === dut.cpu.glob_predict_taken_ex)
//         tot_correct_glob++;
   end
   if (dut.cpu.is_jump_ex) begin
      tot_jmp++;
      if (dut.cpu.branch_pc_ex === dut.cpu.pc_out_id)
         tot_jmp_correct++;
   end
   if (dut.cpu.stall_data)
      data_stalls++;
   else if (dut.cpu.load_use)
      load_use_stalls++;
   else if (dut.cpu.br_miss)
      jmp_br_stalls += 2;     
   else if (dut.cpu.stall_inst)
      inst_stalls++;
end

always @(posedge dut.mem_hierarchy.dcache.pref_read)
	num_prefetches_requested++;
	
always @(posedge dut.mem_hierarchy.dcache.pref_read iff ~dut.mem_hierarchy.dcache.l1_read) begin
	@(posedge itf.clk)
	@(posedge itf.clk)
	if (!dut.mem_hierarchy.dcache.pref_resp)
		num_prefetches_ex++;
end

always @(posedge dut.data_read or posedge dut.data_write) begin
	@(posedge itf.clk)
	if (dut.data_resp)
		data_hits++;
	else
		data_misses++;
end

always @(posedge dut.inst_read) begin
	@(posedge itf.clk)
	if (dut.inst_resp)
		inst_hits++;
	else
		inst_misses++;
end

always @(posedge dut.mem_hierarchy.dcache.l2_read or posedge dut.mem_hierarchy.dcache.l2_write) begin
	@(posedge itf.clk)
	if (dut.mem_hierarchy.dcache.l2_resp)
		l2_hits++;
	else
		l2_misses++;
end
/***********************END PERFORMANCE COUNTERS******************************/

int cycle_cnt;
initial cycle_cnt = 0;

logic DISPLAY_ALL = 1'b1;

always @(posedge itf.clk)begin

   if(`PRINT_DEBUGGING) begin
      if (cycle_cnt == -1 )begin
         $display("!! cycle count finish !!");
         $finish;
      end
      
      $display("---------------------------------------");
      $display("cycle: %0d", cycle_cnt, "\ttime: %0d", $time, "\trst: %b", dut.rst);

      if (DISPLAY_ALL) begin
         $display("IF");
         if (dut.cpu.inst_rdata === 'h13)
            $display(" NOP");
         else begin
            $display("\t\t instr_read: %b", dut.cpu.inst_read);
            $display("\t\t i_pmem_read: %b", dut.mem_hierarchy.i_pmem_read);
            $display("\t\t cache_read: %b", dut.mem_hierarchy.cache_read);
            $display("\t\t mem_read: %b", dut.mem_read);
            $display("\t\t tb mem_read: %b", itf.mcb.read);
            $display("\t\t i_pmem_addr: %0d 0x%0h", dut.mem_hierarchy.i_pmem_addr, dut.mem_hierarchy.i_pmem_addr);
            $display("\t\t mem_address: %0d 0x%0h", dut.mem_address, dut.mem_address);
            $display("\t\t mem_resp: %b", dut.mem_hierarchy.mem_resp);
            $display("\t\t i_pmem_resp: %b", dut.mem_hierarchy.i_pmem_resp);
            $display("\t\t i_rdata256:  0x%0h", dut.mem_hierarchy.i_rdata256);
            $display("\t\tinstr: %b", dut.cpu.inst_rdata);
            $display("\t\tpc_load: %b", dut.cpu.IF.pc_load);
            $display("\t\tpc_out: %h", dut.cpu.IF.pc_out);
            $display("\t\tpc_in: %h", dut.cpu.IF.pcmux_out);
            $display("\t\tpcmux_sel: %b", dut.cpu.IF.pcmux_sel);
         end

//         if (dut.cpu.mon_id.inst === 'h13)
//            $display("ID NOP");
//         else begin
//            $display("ID %h",dut.cpu.mon_id.pc,"\t opcode: ", dut.cpu.mon_id.opcode.name());
//            $display("\t\t rs1_id: %h", dut.cpu.ID_WB.rs1);
//            $display("\t\t rs1_out: %h", dut.cpu.ID_WB.rs1_out);
//            $display("\t\t rs2_id: %h", dut.cpu.ID_WB.rs2);
//            $display("\t\t rs2_out: %h", dut.cpu.ID_WB.rs2_out);
//            $display("\t\t imm_id: %h", dut.cpu.ID_WB.imm);
//         end
//
//         if (dut.cpu.mon_ex.inst === 'h13)
//            $display("EX NOP");
//         else begin
//            $display("EX %h",dut.cpu.mon_ex.pc,"\t opcode: ", dut.cpu.mon_ex.opcode.name());
//            $display("\t\t alu_out_ex: %h", dut.cpu.alu_out_ex);
//         end
//
//         if (dut.cpu.mon_mem.inst === 'h13)
//            $display("MEM NOP");
//         else begin
//            $display("MEM %h",dut.cpu.mon_mem.pc,"\t opcode: ", dut.cpu.mon_mem.opcode.name());
//            $display("\t\t d_pmem_read: %b", dut.mem_hierarchy.d_pmem_read);
//            $display("\t\t cache_read: %b", dut.mem_hierarchy.cache_read);
//            $display("\t\t mem_read: %b", dut.mem_read);
//            $display("\t\t d_pmem_addr: %0d 0x%0h", dut.mem_hierarchy.d_pmem_addr, dut.mem_hierarchy.d_pmem_addr);
//            $display("\t\t mem_address: %0d 0x%0h", dut.mem_address, dut.mem_address);
//            $display("\t\t data_addr: %h", dut.cpu.data_addr);
//            $display("\t\t data_rdata_mem: ", dut.cpu.data_rdata);
//            $display("\t\t d_pmem_resp: ", dut.mem_hierarchy.d_pmem_resp);
//            $display("\t\t l2_resp: ", dut.mem_hierarchy.dcache.l2_resp);
//            $display("\t\t l2 mem_rdata: %h", dut.mem_hierarchy.dcache.l2_rdata);
//            $display("\t\t l2 mem_rdata256: %h", dut.mem_hierarchy.dcache.L2ca.mem_rdata256);
//            $display("\t\t l2 pmem_rdata: %h", dut.mem_hierarchy.dcache.pmem_rdata);
//         end
//
//         if (dut.cpu.mon_wb.inst === 'h13)
//            $display("WB NOP");
//         else begin
//            $display("WB %h",dut.cpu.mon_wb.pc,"\t opcode: ", dut.cpu.mon_wb.opcode.name());
//            $display("\t\t regfile load: %b", dut.cpu.ctrl_wb.regfile_write);
//            $display("\t\t rd: %h", dut.cpu.ID_WB.ctrl_wb.rd);
//            $display("\t\t rd_wdata: %h", dut.cpu.ID_WB.regfilemux_out);
//         end
//
//         if(dut.cpu.mon_COMMIT.commit) begin
//            $display("MONITOR");
//            $display("\t PC:        0x%0h", dut.cpu.mon_COMMIT.pc_rdata);
//            $display("\t order:     0x%0h", rvfi.order);
//            $display("\t inst: %b (0x%0h)", dut.cpu.mon_COMMIT.inst, dut.cpu.mon_COMMIT.inst);
//            $display("\t opcode: ", dut.cpu.mon_COMMIT.opcode.name());
//            $display("\t imm:        %0d (0x%0h)", dut.cpu.mon_COMMIT.imm, dut.cpu.mon_COMMIT.imm);
//            $display("\t rs1_addr:  0x%0h", dut.cpu.mon_COMMIT.rs1_addr);
//            $display("\t rs1_rdata: 0x%0h", dut.cpu.mon_COMMIT.rs1_rdata);
//            $display("\t rs2_addr:  0x%0h", dut.cpu.mon_COMMIT.rs2_addr);
//            $display("\t rs2_rdata: 0x%0h", dut.cpu.mon_COMMIT.rs2_rdata);
//            $display("\t load_regfile: %b", dut.cpu.mon_COMMIT.load_regfile);
//            $display("\t rd_addr:   0x%0h", dut.cpu.mon_COMMIT.rd_addr);
//            $display("\t rd_wdata:  0x%0h", dut.cpu.mon_COMMIT.rd_wdata);
//            $display("\t pc_rdata:  0x%0h", dut.cpu.mon_COMMIT.pc_rdata);
//            $display("\t pc_wdata:  0x%0h", dut.cpu.mon_COMMIT.pc_wdata);
//
//            $display("\n\t mem_addr:  0x%0h", dut.cpu.mon_COMMIT.mem_addr);
//            $display("\t mem_rmask:  0x%0h", dut.cpu.mon_COMMIT.mem_rmask);
//            $display("\t mem_wmask:  0x%0h", dut.cpu.mon_COMMIT.mem_wmask);
//            $display("\t mem_rdata:  %0d (0x%0h)", dut.cpu.mon_COMMIT.mem_rdata, dut.cpu.mon_COMMIT.mem_rdata);
//            $display("\t mem_wdata:  %0d (0x%0h)", dut.cpu.mon_COMMIT.mem_wdata, dut.cpu.mon_COMMIT.mem_wdata);
//         end
      end 
   end
   cycle_cnt = cycle_cnt + 1;
end
endmodule
