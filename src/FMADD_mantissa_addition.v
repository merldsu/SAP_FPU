// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 


module  FMADD_Mantissa_Addition( Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B,Mantissa_Addition_input_Eff_Sub,Mantissa_Addition_output_Mantissa, Mantissa_Addition_output_Carry,Mantissa_Addition_input_Exp_Diff_Check,Mantissa_Addition_input_A_gt_B );

//declaration of paramters
parameter std =31;
parameter man = 22;
parameter exp = 7;

/*
opcode[0]= fadd;    
opcode[1] = Fsuub
*/

//declaration of input ports
input [man+man+3:0] Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B;
input Mantissa_Addition_input_Eff_Sub;
input Mantissa_Addition_input_Exp_Diff_Check, Mantissa_Addition_input_A_gt_B;

//declartion of output ports
output Mantissa_Addition_output_Carry;
output [man+man+3:0] Mantissa_Addition_output_Mantissa;

wire [man+man+3:0] interim_mantissa_B_adder;
wire Mantissa_Addition_interim_Carry,Mantissa_Addition_interim_Compliment_Carry;
wire [man+man+3:0] Mantissa_Addition_Compliment_B,Mantissa_Addition_Compliment_1_Factor;
wire [man+man+3:0] Mantissa_Addition_Compliment_Lane_input,Mantissa_Addition_Adder_Lane_input_A,Mantissa_Addition_Adder_Lane_input_B;
wire Mantissa_Addition_Compliment_Addend;

//Main functionality

//decision of two operands for the final adders
assign Mantissa_Addition_Compliment_Lane_input = (Mantissa_Addition_input_A_gt_B) ? Mantissa_Addition_input_Mantissa_B : Mantissa_Addition_input_Mantissa_A;
assign Mantissa_Addition_Adder_Lane_input_A = (Mantissa_Addition_input_A_gt_B) ? Mantissa_Addition_input_Mantissa_A : Mantissa_Addition_input_Mantissa_B;

//compliment of the Smaller operand of the two
assign Mantissa_Addition_Compliment_Addend = (~Mantissa_Addition_input_Exp_Diff_Check) ;
assign Mantissa_Addition_Compliment_1_Factor = (~Mantissa_Addition_Compliment_Lane_input);
assign {Mantissa_Addition_interim_Compliment_Carry,Mantissa_Addition_Compliment_B} = ( {1'b0,Mantissa_Addition_Compliment_1_Factor} + {1'b0,Mantissa_Addition_Compliment_Addend}  );

//Opernad two of the Adder lane
assign Mantissa_Addition_Adder_Lane_input_B = (Mantissa_Addition_input_Eff_Sub) ? Mantissa_Addition_Compliment_B : Mantissa_Addition_Compliment_Lane_input ;

assign {Mantissa_Addition_interim_Carry,interim_mantissa_B_adder} = {1'b0, Mantissa_Addition_Adder_Lane_input_A} + {1'b0,Mantissa_Addition_Adder_Lane_input_B};

//------OUTPUTS--------
assign Mantissa_Addition_output_Mantissa = ( (~Mantissa_Addition_interim_Carry) & Mantissa_Addition_input_Eff_Sub & (~Mantissa_Addition_interim_Compliment_Carry) ) ? ( ~(interim_mantissa_B_adder) + (Mantissa_Addition_Compliment_Addend) ) : interim_mantissa_B_adder;
assign Mantissa_Addition_output_Carry = Mantissa_Addition_interim_Carry;



endmodule
