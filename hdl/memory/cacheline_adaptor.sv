module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

//state machine
enum logic[10:0] {	Halted,
					Read_Address,
					Read_Dram0,
					Read_Dram1,
					Read_Dram2,
					Read_Dram3,
					Write_Contents,
					Write_toDram0,
					Write_toDram1,
					Write_toDram2,
					Write_toDram3	} state, next_state; //internal state logic

reg [255:0] reg_line;
reg [255:0] reg_write;
always_ff@(posedge clk) begin
	if(resp_i)
		reg_line <= {reg_line[191:0],burst_i};
	else
		reg_line <= 255'b0;

	if(write_i)
		reg_write <= line_i;
end

always_ff@(posedge clk) begin
	if (~reset_n)
		state <= Halted;
	else
		state <= next_state;
end

always_comb begin

	// Default signal values
	line_o = 256'b0;
	resp_o = 1'b0;
	burst_o = 64'b0;
	address_o = 32'b0;
	read_o = 1'b0;
	write_o = 1'b0;

	// Assign next state
    unique case (state)
		Halted:
			begin 
				if		(read_i & ~write_i)	next_state = Read_Address;	//?
				else if (write_i & ~read_i)	next_state = Write_Contents;	//?
				else						next_state = state;
			end
		Read_Address:
			begin
				if	(resp_i)next_state = Read_Dram0;	//?
				else			next_state = Read_Address;
			end
		Read_Dram0:
			next_state = Read_Dram1;
		Read_Dram1:
			next_state = Read_Dram2;
		Read_Dram2:
			next_state = Read_Dram3;
		Read_Dram3:
			next_state = Halted;
		Write_Contents:
			begin
				if	(resp_i)	next_state = Write_toDram0;		//?
				else			next_state = Write_Contents;
			end
		Write_toDram0:
			next_state = Write_toDram1;
		Write_toDram1:
			next_state = Write_toDram2;
		Write_toDram2:
			next_state = Write_toDram3;
		Write_toDram3:
			next_state = Halted;
		default: next_state = state;
	endcase

	// Assign signals based on current state
	unique case (state)
		Halted:
			begin
				read_o = 1'b0;
				write_o = 1'b0;
			end
		Read_Address:
			begin
				read_o = 1'b1;
				address_o = address_i;
			end
		Read_Dram0: 
			begin
				read_o = 1'b1;
				address_o = address_i;
			end
		Read_Dram1: 
			begin
				read_o = 1'b1;
				address_o = address_i;
			end
		Read_Dram2: 
			begin
				read_o = 1'b1;
				address_o = address_i;
			end
		Read_Dram3:
			begin
				address_o = address_i;	//?
				line_o = {reg_line[63:0],reg_line[127:64],reg_line[191:128],reg_line[255:192]};
				resp_o = 1'b1;
			end
		Write_Contents:
			begin
				write_o = 1'b1;
				address_o = address_i;
				if (resp_i) begin
					burst_o = reg_write[63:0];
				end
			end
		Write_toDram0:
			begin
				write_o = 1'b1;
				address_o = address_i;
				burst_o = reg_write[127:64];
			end
		Write_toDram1:
			begin
				write_o = 1'b1;
				address_o = address_i;
				burst_o = reg_write[191:128];
			end
		Write_toDram2:
			begin
				write_o = 1'b1;
				address_o = address_i;
				burst_o = reg_write[255:192];
			end
		Write_toDram3:
			begin
				resp_o = 1'b1;
			end
		default : ;
	endcase

end

endmodule : cacheline_adaptor
