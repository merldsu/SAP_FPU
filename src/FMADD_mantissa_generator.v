// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FMADD_Mantissa_Generator (Mantissa_Generator_input_IEEE_A,Mantissa_Generator_input_IEEE_B,Mantissa_Generator_input_IEEE_C,Mantissa_Generator_input_Activation_signal,Mantissa_Generator_output_IEEE_A,Mantissa_Generator_output_IEEE_B,Mantissa_Generator_output_IEEE_C,Mantissa_Generator_output_A_Sub_norm,Mantissa_Generator_output_B_Sub_norm,Mantissa_Generator_output_A_pos_exp,Mantissa_Generator_output_B_pos_exp,Mantissa_Generator_output_A_neg_exp,Mantissa_Generator_output_B_neg_exp);

//declaration of parameters
parameter std = 31;
parameter man = 22;
parameter exp = 7;


//declaration of input ports
input [std:0]  Mantissa_Generator_input_IEEE_A,Mantissa_Generator_input_IEEE_B,Mantissa_Generator_input_IEEE_C;
input Mantissa_Generator_input_Activation_signal;

//declaration of ouptu ports
output [std+1:0] Mantissa_Generator_output_IEEE_A,Mantissa_Generator_output_IEEE_B,Mantissa_Generator_output_IEEE_C;
output Mantissa_Generator_output_A_Sub_norm,Mantissa_Generator_output_B_Sub_norm,Mantissa_Generator_output_A_pos_exp,Mantissa_Generator_output_B_pos_exp,Mantissa_Generator_output_A_neg_exp,Mantissa_Generator_output_B_neg_exp;

//interim wires
wire A_subnormal,B_subnormal,C_subnormal;
wire C_zero;
//check for subnormal numbers
assign A_subnormal=  (&(~(Mantissa_Generator_input_IEEE_A[std-1:man+1]))) ;
assign Mantissa_Generator_output_A_Sub_norm = A_subnormal & Mantissa_Generator_input_Activation_signal;

assign B_subnormal=  (&(~(Mantissa_Generator_input_IEEE_B[std-1:man+1]))) ;
assign Mantissa_Generator_output_B_Sub_norm = B_subnormal & Mantissa_Generator_input_Activation_signal;

assign C_subnormal=  (&(~(Mantissa_Generator_input_IEEE_C[std-1:man+1]))) ;
assign C_zero  =  (&(~(Mantissa_Generator_input_IEEE_C[std-1:0]))) ; 
//check for positive and negative exponents;
assign Mantissa_Generator_output_A_neg_exp = ( (~(A_subnormal)) & ( ~(Mantissa_Generator_input_IEEE_A[std-1]) )  & (~ ( & (Mantissa_Generator_input_IEEE_A[std-2:man+1]) ) ));
assign Mantissa_Generator_output_A_pos_exp = ( (~(A_subnormal))  &  (~(Mantissa_Generator_output_A_neg_exp))) ;
assign Mantissa_Generator_output_B_neg_exp = ( (~(B_subnormal)) & ( ~(Mantissa_Generator_input_IEEE_B[std-1]) )  & (~ ( & (Mantissa_Generator_input_IEEE_B[std-2:man+1]) ) ));
assign Mantissa_Generator_output_B_pos_exp = ( (~(B_subnormal)) &  (~(Mantissa_Generator_output_B_neg_exp)) );

assign Mantissa_Generator_output_IEEE_A  =  ( Mantissa_Generator_input_Activation_signal ) ? ( (A_subnormal) ? { Mantissa_Generator_input_IEEE_A[std], {exp{1'b0}},1'b1, 1'b0, Mantissa_Generator_input_IEEE_A[man:0] } : {Mantissa_Generator_input_IEEE_A[std], Mantissa_Generator_input_IEEE_A[std-1:man+1], 1'b1, Mantissa_Generator_input_IEEE_A[man:0] }) : {{std{1'b0}},1'b0, 1'b0 } ;
assign Mantissa_Generator_output_IEEE_B  =  ( Mantissa_Generator_input_Activation_signal ) ? ( (B_subnormal) ? { Mantissa_Generator_input_IEEE_B[std], {exp{1'b0}},1'b1, 1'b0, Mantissa_Generator_input_IEEE_B[man:0] } : {Mantissa_Generator_input_IEEE_B[std], Mantissa_Generator_input_IEEE_B[std-1:man+1], 1'b1, Mantissa_Generator_input_IEEE_B[man:0] }) : {{std{1'b0}},1'b0, 1'b0 } ;
assign Mantissa_Generator_output_IEEE_C  =  ( Mantissa_Generator_input_Activation_signal ) ? ( (C_subnormal) ? { Mantissa_Generator_input_IEEE_C[std], {exp{1'b0}},~(C_zero), 1'b0, Mantissa_Generator_input_IEEE_C[man:0] } : {Mantissa_Generator_input_IEEE_C[std], Mantissa_Generator_input_IEEE_C[std-1:man+1], 1'b1, Mantissa_Generator_input_IEEE_C[man:0] }) : {{std{1'b0}},1'b0, 1'b0 } ;
endmodule
