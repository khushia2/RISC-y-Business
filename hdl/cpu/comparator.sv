import rv32i_types::*;

module comparator
(
    input logic[2:0] cmpop,
    input [31:0] a, b,
    output logic b_en
);

always_comb
begin
   unique case (cmpop)
      cmp_eq: b_en = a === b ? 1'b1 : 1'b0;  
      cmp_ne: b_en = a !== b ? 1'b1 : 1'b0;  
      cmp_lt2,
      cmp_lt: b_en = signed'({a[31],a}) < signed'({b[31],b}) ? 1'b1 : 1'b0;   
      cmp_ltu2,
      cmp_ltu: b_en = unsigned'(a) < unsigned'(b) ? 1'b1 : 1'b0;  
      cmp_ge: b_en = signed'({a[31],a}) >= signed'({b[31],b}) ? 1'b1 : 1'b0;  
      cmp_geu: b_en = unsigned'(a) >= unsigned'(b) ? 1'b1 : 1'b0; 
      default: b_en = 1'b0;
   endcase 
end

endmodule : comparator
