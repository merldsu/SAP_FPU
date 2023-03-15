// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_Int_to_Float(INT_TO_FLOAT_input_int, INT_TO_FLOAT_input_rm, INT_TO_FLOAT_input_opcode_IF, INT_TO_FLOAT_input_opcode_signed, INT_TO_FLOAT_input_opcode_unsigned, INT_TO_FLOAT_output_float, INT_TO_FLOAT_output_invalid_flag, INT_TO_FLOAT_output_inexact_flag, rst_l);


parameter std = 31;
parameter man = 22;
parameter exp = 7;
parameter bias = 127;  // IEEE32 + Bfloat16

parameter lzd = 4; //Constant 4 for all STD since LZD is dealing this INT and INT is always of 32 bit
parameter exp_cal = 31;// parameter is used for exponentt calculation and will be constant for all std


//INPUTS
input [31 : 0] INT_TO_FLOAT_input_int;
input [2 : 0] INT_TO_FLOAT_input_rm;
input INT_TO_FLOAT_input_opcode_IF, INT_TO_FLOAT_input_opcode_signed, INT_TO_FLOAT_input_opcode_unsigned;
input rst_l;

//OUTPUTS
output [std : 0]INT_TO_FLOAT_output_float;
output INT_TO_FLOAT_output_invalid_flag;
output INT_TO_FLOAT_output_inexact_flag;

//WIRES
wire [31 : 0] INT_TO_FLOAT_input_wire_int;
wire [31 : 0]INT_TO_FLOAT_int_magnitude;
wire [lzd : 0]INT_TO_FLOAT_wire_shifts;
wire INT_TO_FLOAT_wire_lzd_valid; 
wire [31 : 0]INT_TO_FLOAT_wire_shifted_int;
wire INT_TO_FLOAT_wire_guard, INT_TO_FLOAT_wire_round, INT_TO_FLOAT_wire_sticky;
wire INT_TO_FLOAT_wire_condition_inf, INT_TO_FLOAT_wire_condition_rnte, INT_TO_FLOAT_wire_condition_rntmm;
wire INT_TO_FLOAT_wire_inc_or_trunc;
wire INT_TO_FLOAT_wire_carry_prediction;
wire [man+1 : 0]INT_TO_FLOAT_rounded_h_man; wire INT_TO_FLOAT_rounded_h_man_carry;
wire [51 : 0] INT_TO_FLOAT_wire_man_output_interim;
wire [lzd+1 : 0]INT_TO_FLOAT_wire_shifts_for_exp_cal;
wire [exp : 0]INT_TO_FLOAT_wire_bias_toadd;
wire [lzd+1 : 0] INT_TO_FLOAT_wire_exp_interm_1;
wire [exp : 0] INT_TO_FLOAT_wire_exp_output;
wire [51 : 0]INT_TO_FLOAT_wire_man_output;
wire INT_TO_FLOAT_wire_sign_output;
wire [63 : 0]INT_TO_FLOAT_wire_64std_output;
wire [std : 0]INT_TO_FLOAT_wire_rest_std_output;

//If rst_l is low and if opcode is low then input is set zero and so is the output.
assign INT_TO_FLOAT_input_wire_int = (INT_TO_FLOAT_input_opcode_IF && rst_l) ? INT_TO_FLOAT_input_int : 32'b0000_0000_0000_0000_0000_0000_0000_0000;

//Checking MSB to check whether the number is -ve or +ve and then converting negative number to magnitude
//Conversion is done only when unsigned opcode is high
assign INT_TO_FLOAT_int_magnitude = (INT_TO_FLOAT_input_wire_int[31] & INT_TO_FLOAT_input_opcode_signed) ?
(~INT_TO_FLOAT_input_wire_int) + 1'b1 : INT_TO_FLOAT_input_wire_int;
//Converting to 2's compliment by taking 2's compliment if sign == 1

//Module instantiation of LZD
FPU_LZD_64 LZD_I2F (.LZD_64_input_int(INT_TO_FLOAT_int_magnitude), .LZD_64_output_pos(INT_TO_FLOAT_wire_shifts));
defparam LZD_I2F.lzd = 4;
defparam LZD_I2F.man = 30;

assign INT_TO_FLOAT_wire_shifted_int = INT_TO_FLOAT_int_magnitude << INT_TO_FLOAT_wire_shifts;

//man in case of double precision will be 51 and 31-man will be a negative no (2's compliment) this will be a trash value however it will not be effecting our actual result since for that std 0 will be selected for all G, R, and S
assign INT_TO_FLOAT_wire_guard  = (std==63) ? 1'b0 : (INT_TO_FLOAT_wire_shifted_int[5'b11111 - (man+2'b10)]);
assign INT_TO_FLOAT_wire_round  = (std==63) ? 1'b0 : (INT_TO_FLOAT_wire_shifted_int[5'b11111 - (man+2'b11)]);
assign INT_TO_FLOAT_wire_sticky = (std==63) ? 1'b0 : (|(INT_TO_FLOAT_wire_shifted_int[(5'b11111 - (man+3'b100)) : 0]));


assign INT_TO_FLOAT_wire_condition_inf = ((INT_TO_FLOAT_wire_round | INT_TO_FLOAT_wire_guard | (INT_TO_FLOAT_wire_sticky)) & ((INT_TO_FLOAT_input_rm == 3'b011 & ~(INT_TO_FLOAT_input_wire_int[31] & INT_TO_FLOAT_input_opcode_signed))|(INT_TO_FLOAT_input_rm == 3'b010 & (INT_TO_FLOAT_input_wire_int[31] & INT_TO_FLOAT_input_opcode_signed))));  
assign INT_TO_FLOAT_wire_condition_rnte = (INT_TO_FLOAT_input_rm == 3'b000 & ((INT_TO_FLOAT_wire_guard & (INT_TO_FLOAT_wire_round | INT_TO_FLOAT_wire_sticky)) | (INT_TO_FLOAT_wire_guard & ((~INT_TO_FLOAT_wire_round) & ~(INT_TO_FLOAT_wire_sticky)) & INT_TO_FLOAT_wire_shifted_int[5'b11111 - (man+2'b01)])));
assign INT_TO_FLOAT_wire_condition_rntmm = (INT_TO_FLOAT_input_rm == 3'b100 & ((INT_TO_FLOAT_wire_guard & (INT_TO_FLOAT_wire_round | INT_TO_FLOAT_wire_sticky)) | (INT_TO_FLOAT_wire_guard & ((~INT_TO_FLOAT_wire_round) & (~INT_TO_FLOAT_wire_sticky)))));

assign INT_TO_FLOAT_wire_inc_or_trunc = INT_TO_FLOAT_wire_condition_inf | INT_TO_FLOAT_wire_condition_rnte | INT_TO_FLOAT_wire_condition_rntmm;	

//man in case of double precision will be 51 and 31-man will be a negative no (2's compliment) this will be a trash value however it will not be effecting our actual result since for that std 0 will be selected for carry
assign INT_TO_FLOAT_wire_carry_prediction = (std == 64) ? (1'b0) : ((&INT_TO_FLOAT_wire_shifted_int[31 : 31-(man+1'b1)]) & (INT_TO_FLOAT_wire_inc_or_trunc));

//Extra zero is added to make the size of LHS == RHS
assign {INT_TO_FLOAT_rounded_h_man_carry, INT_TO_FLOAT_rounded_h_man} = {1'b0, INT_TO_FLOAT_wire_shifted_int[31 : 31-(man+1'b1)]} + INT_TO_FLOAT_wire_inc_or_trunc;

// ({(51-man)}{1'b0}) is used to add zero at the end to make the mantissa same size as mantissa of DOUBLE PRECISION
assign INT_TO_FLOAT_wire_man_output_interim = (std == 64) ? 
({INT_TO_FLOAT_wire_shifted_int[30 : 0], 21'b0_0000_0000_0000_0000_0000}) :
({ (INT_TO_FLOAT_rounded_h_man[man : 0]), ({(51-man){1'b0}}) });

//In case data is all zero output of LZD is zero in this case exponent will be 31-0 which is not ok therfore setting the exponent to all 1 so that exp will be 31-31 = 0 
assign INT_TO_FLOAT_wire_shifts_for_exp_cal = (&(~INT_TO_FLOAT_int_magnitude)) ? (exp_cal[lzd+1 : 0]) : {1'b0, INT_TO_FLOAT_wire_shifts};

//Subtracting shifts from 31 and adding carry_prediction in it.
assign INT_TO_FLOAT_wire_exp_interm_1 = exp_cal[lzd+1 : 0] - INT_TO_FLOAT_wire_shifts_for_exp_cal + INT_TO_FLOAT_wire_carry_prediction;

//In case data is all zero than bias is not added
assign INT_TO_FLOAT_wire_bias_toadd = (&(~INT_TO_FLOAT_int_magnitude)) ? ({(exp+1){1'b0}}) : (bias[exp : 0]);

// ({(exp-(lzd+1))}{1'b0}) using this command 7-(4+1) = 2 times zeros are added into the exp_interm_1 to make it of the same size as expoent and bias
assign INT_TO_FLOAT_wire_exp_output = ({ ({(exp-(lzd+1)){1'b0}}) ,INT_TO_FLOAT_wire_exp_interm_1}) + INT_TO_FLOAT_wire_bias_toadd;

// mantissa is set to all 0 in case exp is 11111 mean infinity OV has occured
assign INT_TO_FLOAT_wire_man_output = (&INT_TO_FLOAT_wire_exp_output) ? ({52{1'b0}}) : (INT_TO_FLOAT_wire_man_output_interim) ;

//Calculating sign of the output on the basis on input MSB and opcode, since incase of signed MSB is a negative number and is high only incase of negative number but this is not the case when dealing with unsigned numbers.
assign INT_TO_FLOAT_wire_sign_output = (INT_TO_FLOAT_input_wire_int[31] & INT_TO_FLOAT_input_opcode_signed);

assign INT_TO_FLOAT_output_float = {INT_TO_FLOAT_wire_sign_output, INT_TO_FLOAT_wire_exp_output, (INT_TO_FLOAT_wire_man_output[51 : (51-man)])};

//INT_TO_FLOAT_output_reg_invalid_flag = 1'b0;//valid flag will always be low for single precision as 32 wire int can easily be 
//represented in single precision. flag will only come into play when deailing with IEEE16.
assign INT_TO_FLOAT_output_invalid_flag = (std == 15) & (&INT_TO_FLOAT_wire_exp_output) ;

//Inexact Flag
assign INT_TO_FLOAT_output_inexact_flag = INT_TO_FLOAT_wire_guard | INT_TO_FLOAT_wire_round | INT_TO_FLOAT_wire_sticky;

endmodule
