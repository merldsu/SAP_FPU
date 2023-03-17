// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FMADD_ROUND_MUL (FMADD_ROUND_MUL_input_sticky_PN, FMADD_ROUND_MUL_input_no, FMADD_ROUND_MUL_input_rm, FMADD_ROUND_MUL_output_no, FMADD_ROUND_MUL_output_S_Flags);

parameter std  =  31;
parameter man  =  22;
parameter exp  =   7;
parameter biad = 127;

//man+man+exp+6 == sign
//man+man+exp+5 : man+man+4 == 9bit exp
//man+man+exp+4 : man+man+4 == 8bit exp
//man+man+3 : 0 == 48bit mantissa
//man+man+3 : man+2 == 24 bit mantissa

input [man+man+exp+6 : 0]FMADD_ROUND_MUL_input_no;
input [2 : 0] FMADD_ROUND_MUL_input_rm;
input FMADD_ROUND_MUL_input_sticky_PN;

output [std : 0] FMADD_ROUND_MUL_output_no;
output [2 : 0]FMADD_ROUND_MUL_output_S_Flags;


wire FMADD_ROUND_MUL_output_inexact, FMADD_ROUND_MUL_output_underflow, FMADD_ROUND_MUL_output_overflow;
wire FMADD_ROUND_MUL_wire_guard, FMADD_ROUND_MUL_wire_round, FMADD_ROUND_MUL_wire_sticky;
wire FMADD_ROUND_MUL_wire_condition_inf, FMADD_ROUND_MUL_wire_condition_rnte, FMADD_ROUND_MUL_wire_condition_rntmm;
wire FMADD_ROUND_MUL_wire_condition_sticky;
wire FMADD_ROUND_MUL_wire_inc;
wire [man+1 : 0] FMADD_ROUND_MUL_wire_rounded_man;
wire FMADD_ROUND_MUL_wire_carry_man ;
wire [exp : 0] FMADD_ROUND_MUL_wire_rounded_exp;
wire [man : 0] FMADD_ROUND_MUL_wire_final_man;
wire FMADD_ROUND_MUL_wire_overflow_PN;
wire FMADD_ROUND_MUL_wire_exception_cond1;
wire [std : 0] FMADD_ROUND_MUL_wire_output_interim_1;
wire FMADD_ROUND_MUL_wire_exception_cond2;
wire FMADD_ROUND_MUL_wire_inexact;

assign FMADD_ROUND_MUL_wire_guard  =  FMADD_ROUND_MUL_input_no[man+1];
assign FMADD_ROUND_MUL_wire_round  =  FMADD_ROUND_MUL_input_no[man];
assign FMADD_ROUND_MUL_wire_sticky = |FMADD_ROUND_MUL_input_no[man-1 : 0];

assign FMADD_ROUND_MUL_wire_condition_inf   = ((FMADD_ROUND_MUL_wire_round | FMADD_ROUND_MUL_wire_guard | (FMADD_ROUND_MUL_wire_sticky)) & ((FMADD_ROUND_MUL_input_rm == 3'b011 & ~FMADD_ROUND_MUL_input_no[man+man+exp+6])|(FMADD_ROUND_MUL_input_rm == 3'b010 & FMADD_ROUND_MUL_input_no[man+man+exp+6])));  
assign FMADD_ROUND_MUL_wire_condition_rnte  = (FMADD_ROUND_MUL_input_rm == 3'b000 & ((FMADD_ROUND_MUL_wire_guard & (FMADD_ROUND_MUL_wire_round | (FMADD_ROUND_MUL_wire_sticky))) | (FMADD_ROUND_MUL_wire_guard & ((~FMADD_ROUND_MUL_wire_round) & ~(FMADD_ROUND_MUL_wire_sticky)) & FMADD_ROUND_MUL_input_no[man+2])));
assign FMADD_ROUND_MUL_wire_condition_rntmm = (FMADD_ROUND_MUL_input_rm == 3'b100 & ((FMADD_ROUND_MUL_wire_guard & (FMADD_ROUND_MUL_wire_round | (FMADD_ROUND_MUL_wire_sticky))) | (FMADD_ROUND_MUL_wire_guard & ((~FMADD_ROUND_MUL_wire_round) & ~(FMADD_ROUND_MUL_wire_sticky)))));
assign FMADD_ROUND_MUL_wire_condition_sticky = FMADD_ROUND_MUL_input_sticky_PN & (((!FMADD_ROUND_MUL_input_no[man+man+exp+6]) & (FMADD_ROUND_MUL_input_rm == 3'b011)) | (FMADD_ROUND_MUL_input_no[man+man+exp+6] & (FMADD_ROUND_MUL_input_rm == 3'b010)));
//FMADD_ROUND_MUL_wire_condition_sticky logic for rounding on the basis os STICKY bit coming from previous module, inc is done incase sticky_pn == 1 and sign == 0 and rm == 3 OR sticky_pn == 1 and sign ==1 and rm == 10

// Add 1 in case rounding says so. Input_overflow is added so that inc becomes ineffective in case overflow is high
assign FMADD_ROUND_MUL_wire_inc = (FMADD_ROUND_MUL_wire_condition_inf | FMADD_ROUND_MUL_wire_condition_rnte | FMADD_ROUND_MUL_wire_condition_rntmm | FMADD_ROUND_MUL_wire_condition_sticky) & (!FMADD_ROUND_MUL_output_overflow);
assign {FMADD_ROUND_MUL_wire_carry_man, FMADD_ROUND_MUL_wire_rounded_man} = {1'b0, FMADD_ROUND_MUL_input_no[man+man+3 : man+2]} + {{24{1'b0}},FMADD_ROUND_MUL_wire_inc};

//If hidden bit before rounding is zero and after rounding is one then add one in exponent other wise don't
//this occur only for near subnormal outputs
assign FMADD_ROUND_MUL_wire_rounded_exp = (((!FMADD_ROUND_MUL_input_no[man+man+3]) & (FMADD_ROUND_MUL_wire_rounded_man[man+1])) | FMADD_ROUND_MUL_wire_carry_man )?
FMADD_ROUND_MUL_input_no[man+man+exp+4 : man+man+4]  + 1'b1 : FMADD_ROUND_MUL_input_no[man+man+exp+4 : man+man+4];

//Selection of what exception to output in case of overflow, max normal number or infinity
assign FMADD_ROUND_MUL_wire_exception_cond1 = (FMADD_ROUND_MUL_input_rm == 3'b000 | FMADD_ROUND_MUL_input_rm == 3'b100) | ((!FMADD_ROUND_MUL_input_no[man+man+exp+6]) & (FMADD_ROUND_MUL_input_rm == 3'b011)) | ((FMADD_ROUND_MUL_input_no[man+man+exp+6]) & (FMADD_ROUND_MUL_input_rm == 3'b010));
assign FMADD_ROUND_MUL_wire_output_interim_1 = (FMADD_ROUND_MUL_wire_exception_cond1) ? ({ FMADD_ROUND_MUL_input_no[man+man+exp+6], ({exp+1{1'b1}}), ({man+1{1'b0}}) }) : ({ FMADD_ROUND_MUL_input_no[man+man+exp+6], ({{exp{1'b1}}, 1'b0}), ({man+1{1'b1}}) });
//condition to select output, either exception or result from main, in case 9th bit (single precision) of exp is high or bits from 8:0 are high then it is overflow
assign FMADD_ROUND_MUL_wire_exception_cond2 = FMADD_ROUND_MUL_input_no[man+man+exp+5] | (&FMADD_ROUND_MUL_input_no[man+man+exp+4 : man+man+4]);


//----------OUTPUTS-------------
//Selecting what to output exception or result coming form main
assign FMADD_ROUND_MUL_output_no = (FMADD_ROUND_MUL_wire_exception_cond2) ? (FMADD_ROUND_MUL_wire_output_interim_1) : ({FMADD_ROUND_MUL_input_no[man+man+exp+6], (FMADD_ROUND_MUL_wire_rounded_exp), (FMADD_ROUND_MUL_wire_rounded_man[man:0])}) ;
//In case cond2 is high overflow flag is set to one
assign FMADD_ROUND_MUL_output_overflow = FMADD_ROUND_MUL_wire_exception_cond2;
//uverflow occurs in case the exp after rounding is complete zero. Underflow is only high when inexact is high and overflow in low.
assign FMADD_ROUND_MUL_output_underflow = ((!(|FMADD_ROUND_MUL_wire_rounded_exp)) & FMADD_ROUND_MUL_wire_inexact) & (!FMADD_ROUND_MUL_output_overflow);
//Inexact is high in case any of the GRS are high or if overflow has occured
assign FMADD_ROUND_MUL_wire_inexact = FMADD_ROUND_MUL_wire_guard | FMADD_ROUND_MUL_wire_round | FMADD_ROUND_MUL_wire_sticky | FMADD_ROUND_MUL_input_sticky_PN | FMADD_ROUND_MUL_wire_exception_cond2;
assign FMADD_ROUND_MUL_output_inexact = FMADD_ROUND_MUL_wire_inexact;
//Concatinating all flags
assign FMADD_ROUND_MUL_output_S_Flags = {FMADD_ROUND_MUL_output_overflow,FMADD_ROUND_MUL_output_underflow,FMADD_ROUND_MUL_output_inexact};

endmodule
