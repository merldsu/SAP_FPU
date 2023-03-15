// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FMADD_Roudning_Block_Addition( Rounding_Block_input_Mantissa,Rounding_Block_input_Exponent,Rounding_Block_input_Sign,Rounding_Block_input_NX_flag_Mul,Rounding_Block_input_Guard,Rounding_Block_input_Round,Rounding_Block_input_Sticky, Rounding_Block_input_Underflow_operand_A,Rounding_Block_input_Frm,Rounding_Block_input_A_eq_B,Rounding_Block_output_Exponent,Rounding_Block_output_Sign,Rounding_Block_output_Mantissa,Rounding_Block_output_S_Flags);

//declaration of paramters
parameter std = 31;
parameter man = 22;
parameter exp = 7;

//declaration of inputs
input [man+1:0] Rounding_Block_input_Mantissa;
input [exp+1:0] Rounding_Block_input_Exponent;
input Rounding_Block_input_Sign,Rounding_Block_input_Guard,Rounding_Block_input_Round,Rounding_Block_input_Sticky;
input [2:0] Rounding_Block_input_Frm;
input Rounding_Block_input_A_eq_B;
input  Rounding_Block_input_Underflow_operand_A;
input Rounding_Block_input_NX_flag_Mul;
//declaration of outputs 
output [man:0] Rounding_Block_output_Mantissa;
output [exp:0] Rounding_Block_output_Exponent;
output Rounding_Block_output_Sign;
output [2:0] Rounding_Block_output_S_Flags;

//interim wires 
wire Rounding_Block_Bit_pos_inf;
wire Rounding_Block_Bit_neg_inf;
wire Rounding_Block_Bit_RNE;
wire Rounding_Block_Bit_RN_MM;
wire Rounding_Block_Bit_Round_up;
wire [man+1:0] Rounding_Block_interim_Mantissa;
wire Rounding_Block_Bit_Carry;
wire [man+1:0] Rounding_Block_Shifter_output;
wire [exp+1:0] Rounding_Block_interim_exponent;
wire [exp:0] Rounding_Block_final_exponent;
wire Roinding_Block_Overflow_check;


//main functionality 
assign Rounding_Block_Bit_pos_inf = ( (Rounding_Block_input_Guard) | (Rounding_Block_input_Round) | (Rounding_Block_input_Sticky) ) & ( ~(Rounding_Block_input_Sign) );
assign Rounding_Block_Bit_neg_inf = ( (Rounding_Block_input_Guard) | (Rounding_Block_input_Round) | (Rounding_Block_input_Sticky) ) & (Rounding_Block_input_Sign);
assign Rounding_Block_Bit_RNE = ( Rounding_Block_input_Guard & ( Rounding_Block_input_Round | Rounding_Block_input_Sticky )) | ( ( Rounding_Block_input_Guard & ( (~Rounding_Block_input_Round) & (~Rounding_Block_input_Sticky) )) & Rounding_Block_input_Mantissa[0] ); 
assign Rounding_Block_Bit_RN_MM = ( Rounding_Block_input_Guard & ( Rounding_Block_input_Round | Rounding_Block_input_Sticky )) | ( Rounding_Block_input_Guard & ( (~Rounding_Block_input_Round) & (~Rounding_Block_input_Sticky) ));

assign Rounding_Block_Bit_Round_up = (Rounding_Block_input_Frm == 3'b011) ? Rounding_Block_Bit_pos_inf : (Rounding_Block_input_Frm == 3'b010) ? Rounding_Block_Bit_neg_inf : (Rounding_Block_input_Frm == 3'b000) ? Rounding_Block_Bit_RNE : (Rounding_Block_input_Frm == 3'b100) ? Rounding_Block_Bit_RN_MM : 1'b0; 

assign { Rounding_Block_Bit_Carry, Rounding_Block_interim_Mantissa} = {1'b0,Rounding_Block_input_Mantissa} + Rounding_Block_Bit_Round_up ;
assign Rounding_Block_Shifter_output = (Rounding_Block_Bit_Carry) ? { Rounding_Block_Bit_Carry , Rounding_Block_interim_Mantissa[man+1:1]} : Rounding_Block_interim_Mantissa[man+1:0]  ;
assign Rounding_Block_interim_exponent = Rounding_Block_input_Exponent + Rounding_Block_Bit_Carry;
assign Roinding_Block_Overflow_check = (Rounding_Block_interim_exponent[exp+1] | (& Rounding_Block_interim_exponent[exp:0]) );


assign Rounding_Block_final_exponent  = (Roinding_Block_Overflow_check) ? ( ((Rounding_Block_input_Frm ==3'b000 | Rounding_Block_input_Frm == 3'b100 | (Rounding_Block_input_Frm == 3'b011 & (~Rounding_Block_input_Sign)) | (Rounding_Block_input_Frm == 3'b010 & (Rounding_Block_input_Sign))  ) ) ? {exp+1{1'b1}} : ((Rounding_Block_input_Frm ==3'b001 | (Rounding_Block_input_Frm == 3'b010 & (~Rounding_Block_input_Sign))) | (Rounding_Block_input_Frm == 3'b011 & (Rounding_Block_input_Sign)) ) ? {{exp{1'b1}},1'b0} : {exp+1{1'b0}} ) : Rounding_Block_interim_exponent[exp:0] ;
assign Rounding_Block_output_Exponent = (Rounding_Block_Shifter_output[man+1] ) ? Rounding_Block_final_exponent : {exp+1{1'b0}} ; 
assign Rounding_Block_output_Mantissa  = (Roinding_Block_Overflow_check) ? ( ((Rounding_Block_input_Frm ==3'b000 | Rounding_Block_input_Frm == 3'b100 | (Rounding_Block_input_Frm == 3'b011 & (~Rounding_Block_input_Sign)) | (Rounding_Block_input_Frm == 3'b010 & (Rounding_Block_input_Sign))  ) ) ? {man+1{1'b0}} : ((Rounding_Block_input_Frm ==3'b001 | (Rounding_Block_input_Frm == 3'b010 & (~Rounding_Block_input_Sign))) | (Rounding_Block_input_Frm == 3'b011 & (Rounding_Block_input_Sign)) ) ? {man+1{1'b1}} : {man+1{1'b0}} ) : Rounding_Block_Shifter_output[man:0];
assign Rounding_Block_output_Sign =  (Rounding_Block_input_A_eq_B)  ?  (  (Rounding_Block_input_Frm == 3'b010) ? 1'b1 : 1'b0 ) : Rounding_Block_input_Sign ;

//delcaration of inexact flag
assign Rounding_Block_output_S_Flags[0] = Rounding_Block_input_Sticky | Rounding_Block_input_Guard | Rounding_Block_input_Round | Roinding_Block_Overflow_check |  Rounding_Block_input_Underflow_operand_A | Rounding_Block_input_NX_flag_Mul  ;
//declaration of overflow flag
assign Rounding_Block_output_S_Flags[1] = Roinding_Block_Overflow_check ;
//declaration of under flow flag
assign Rounding_Block_output_S_Flags[2] = (~Rounding_Block_Shifter_output[man+1]) & ( (Rounding_Block_input_Sticky) | (Rounding_Block_input_Guard) | (Rounding_Block_input_Round  |  Rounding_Block_input_Underflow_operand_A) | Rounding_Block_input_NX_flag_Mul ) ;

endmodule
