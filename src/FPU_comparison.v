// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_Comparison(rst_l,opcode,Comparator_Input_IEEE_A,Comparator_Input_IEEE_B,Comparator_Output_IEEE,Min_Max_Output_IEEE);
  //Standard Defination For Parameterization
  
  parameter Std = 31; // Means IEEE754 Std 32 Bit Single Precision -1 for bits
  parameter Exp = 7; // Means IEEE754 8 Bit For Exponents in Single Precision -1 for bits
  parameter Man = 22; // Means IEEE754 23 Bit For Mantissa in Single Precision -1 for bits
  
  input [Std : 0] Comparator_Input_IEEE_A, Comparator_Input_IEEE_B; // Std + 1 is for IEEE754 Hidden Bit inclusion
  input [7:0]opcode;// opcode for selections
  input rst_l;
  output [31 : 0] Comparator_Output_IEEE;
  output[Std:0] Min_Max_Output_IEEE;
  
  reg [31 : 0] Comparator_Output_IEEE_reg;
  reg [Std:0] Min_Max_Output_IEEE_reg;
  wire Comparator_Sign_A, Comparator_Sign_B;
  wire [Exp : 0] Comparator_Exp_A, Comparator_Exp_B;
  wire [Man + 1 : 0] Comparator_Mantissa_A, Comparator_Mantissa_B;
  
  
  //==========OPCODES============
  // opcode [0] = feq
  // opcode [1] = fne
  // opcode [2] = flt
  // opcode [3] = fle
  // opcode [4] = fgt
  // opcode [5] = fge
  // opcode [6] = fmin
  // opcode [7] = fmax
  
 //============INPUTS=============
 // Comparator_Input_IEEE_A 
 // Comparator_Input_IEEE_B
 
 //============OUTPUTS============
 // Comparator_Output_IEEE 
 // Min_Max_Output_IEEE
  
 //=================FLAGS========= 
 // INVALID FLAG (NV)
  
    assign Comparator_Sign_A = (rst_l) ? Comparator_Input_IEEE_A[Std] : 1'b0; // Sign Bit Assigning Std + 1 Because it contain IEEE754 hidden bit also
    assign Comparator_Sign_B = (rst_l) ? Comparator_Input_IEEE_B[Std] : 1'b0; // Sign Bit Assigning Std + 1 Because it contain IEEE754 hidden bit also
    assign Comparator_Exp_A = (rst_l) ? Comparator_Input_IEEE_A[Std - 1 : Std - Exp - 1] : {1'b0,{Exp{1'b0}}};
    assign Comparator_Exp_B = (rst_l) ? Comparator_Input_IEEE_B[Std - 1 : Std - Exp - 1] : {1'b0,{Exp{1'b0}}};
    assign Comparator_Mantissa_A = (rst_l) ? {1'b1,Comparator_Input_IEEE_A[Man : 0]} : {1'b0,{Man{1'b0}}};
    assign Comparator_Mantissa_B = (rst_l) ? {1'b1,Comparator_Input_IEEE_B[Man : 0]} : {1'b0,{Man{1'b0}}};
    
    assign Comparator_Output_IEEE = (rst_l==1'b0) ? 32'h00000000 : (opcode[0] == 1'b1) ? ((Comparator_Input_IEEE_A == Comparator_Input_IEEE_B) ? 32'h00000001 : 32'h00000000) : // Equal
                                                                   (opcode[1] == 1'b1) ? ((Comparator_Input_IEEE_A != Comparator_Input_IEEE_B) ? 32'h00000001 : 32'h00000000) : // Not Equal
                                                                   
                                                                   (opcode[2] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000))) : // less than
                                                                   
                                                                   (opcode[3] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000))) : // less and equal 
                                                                   
                                                                   (opcode[4] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000))) : // greater than
                                                                   
                                                                   (opcode[5] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000))) : // greater and equal
                                                                   
                                                                   32'h00000000;
    
    assign Min_Max_Output_IEEE    = (rst_l==1'b0) ? {Std+1{1'b0}} : (opcode[6] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B) : (Comparator_Sign_A < Comparator_Sign_B) ? Comparator_Input_IEEE_B : (Comparator_Sign_A > Comparator_Sign_B) ? Comparator_Input_IEEE_A : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B))) : // Fmin 
                                                   		     (opcode[7] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B) : (Comparator_Sign_A > Comparator_Sign_B) ? Comparator_Input_IEEE_B : (Comparator_Sign_A < Comparator_Sign_B) ? Comparator_Input_IEEE_A : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B))) : // Fmax
                                                   		     {Std+1{1'b0}};


endmodule
