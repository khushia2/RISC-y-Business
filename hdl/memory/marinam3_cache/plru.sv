`define BAD_OP_SEL $fatal("%0t %s %0d: Illegal operand select", $time, `__FILE__, `__LINE__)


module plru #(
	parameter NUM_WAYS = 2
)(
	hit_way,
	lru_curstate,
	lru_updstate,
	rep_dec
);
localparam MAX_NUMWAYS = 4;

input logic [NUM_WAYS-1:0] hit_way;
input logic [MAX_NUMWAYS-2:0] lru_curstate;
output logic [NUM_WAYS-1:0] rep_dec;
output logic [MAX_NUMWAYS-2:0] lru_updstate;

logic[MAX_NUMWAYS-1:0] lru_hitway, lru_repdec;

//BASE WAYS
logic[3:0]	A = 4'b0001,
				B = 4'b0010,
				C = 4'b0100,
				D = 4'b1000;
 
always_comb begin
	
	case(NUM_WAYS)
		1: lru_hitway = {3'b000,hit_way[0]};
		2: lru_hitway = {1'b0,hit_way[1],1'b000,hit_way[0]};
		4: lru_hitway = hit_way;
		default: lru_hitway = '0;
	endcase
	
	//LRU STATE UPDATE !!!!!!!!!!!!!!!FIX THIS!!!!!!!!!!!!!!!
	case(lru_hitway)
		A: lru_updstate = {lru_curstate[2],2'b00};
		B: lru_updstate = {lru_curstate[2],2'b10};
		C: lru_updstate = {1'b0,lru_curstate[1],1'b1};
		D: lru_updstate = {1'b1,lru_curstate[1],1'b1};
		default: lru_updstate = '1;
	endcase
	
	//REPLACEMENT DECISION
	casex(lru_updstate)
		3'bx11:	lru_repdec = A;
		3'bx01:	lru_repdec = B;
		3'b1x0:	lru_repdec = C;
		3'b0x0:	lru_repdec = D;
		default: 	lru_repdec = '0; 
	endcase
	
	//TRANSLATE TO ONEHOT NUM_WAYS
	rep_dec = '0;
	case(NUM_WAYS)
		1: rep_dec = 1'b1;
		2: begin
			case(lru_repdec)
				A, B: rep_dec = 2'b01;
				C, D: rep_dec = 2'b10;
			endcase
			end
		4: rep_dec = lru_repdec;
	endcase
	
end


endmodule : plru