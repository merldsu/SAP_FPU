// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions  

module FMADD_Mantissa_Multiplication (Mantissa_Multiplication_input_A,Mantissa_Multiplication_input_B,Mantissa_Multiplication_input_Activation_Signal,Mantissa_Multiplication_output_Mantissa);
parameter man = 22;
parameter exp = 7;

//declaration of inputs ports
input [man+1:0] Mantissa_Multiplication_input_A,Mantissa_Multiplication_input_B;
input Mantissa_Multiplication_input_Activation_Signal;

//declaration of output ports
output [man+man+3:0] Mantissa_Multiplication_output_Mantissa;

//main functionality
assign Mantissa_Multiplication_output_Mantissa = (Mantissa_Multiplication_input_Activation_Signal) ? Mantissa_Multiplication_input_A * Mantissa_Multiplication_input_B: {2{{2'b00, {man{1'b0}}}}};

endmodule
