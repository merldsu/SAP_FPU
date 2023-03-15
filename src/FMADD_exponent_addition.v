// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions

module FMADD_Exponent_addition (Exponent_addition_input_A,Exponent_addition_input_B,Exponent_addition_input_Activation_Signal,Exponent_addition_output_exp,Exponent_addition_output_sign);
parameter std=31;
parameter man =22;
parameter exp = 7;

//declaration of inputs
input [exp+1:0] Exponent_addition_input_A,Exponent_addition_input_B;
input Exponent_addition_input_Activation_Signal;

//declaration of putputs
output  [exp+1:0] Exponent_addition_output_exp;
output Exponent_addition_output_sign;
wire [exp+1:0] Exponent_addition_wire_exp;

//functionality 
assign Exponent_addition_wire_exp = (Exponent_addition_input_Activation_Signal) ? (Exponent_addition_input_A[exp:0] + Exponent_addition_input_B[exp:0]): 9'b000000000;
assign Exponent_addition_output_exp = Exponent_addition_wire_exp;
assign Exponent_addition_output_sign = (Exponent_addition_input_Activation_Signal) ? (Exponent_addition_input_A [exp+1] ^ Exponent_addition_input_B[exp+1]) : 1'b0;


endmodule
