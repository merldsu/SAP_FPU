// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_Fclass (Classification_Input,rst_l,Classification_Output,opcode);
  
  
  // Parameters
  parameter Std = 15; // Std = Std - 1
  parameter Man = 9; // Mantissa  
  
  // Inputs 
  input [Std:0] Classification_Input;
  input rst_l;
  input opcode;

  // Outputs
   output [31:0] Classification_Output;

  //wires
  wire Classification_Qnan_Output,Classification_Snan_Output,Classification_Pos_Infinity_Output,Classification_Pos_Normal_Output, Classification_Pos_Subnormal_Output,Classification_Pos_Zero_Output,Classification_Neg_Zero_Output,Classification_Neg_Subnormal_Output,Classification_Neg_Normal_Output,Classification_Neg_Infinity_Output; 



  // Check to see if reset is either high or low
  assign Classification_Output = (rst_l & opcode ) ? { {22{1'b0}},  Classification_Qnan_Output,Classification_Snan_Output,Classification_Pos_Infinity_Output,Classification_Pos_Normal_Output, Classification_Pos_Subnormal_Output,Classification_Pos_Zero_Output,Classification_Neg_Zero_Output,Classification_Neg_Subnormal_Output,Classification_Neg_Normal_Output,Classification_Neg_Infinity_Output} : {32{1'b0}};
  
  
  // -ve infinity
  assign Classification_Neg_Infinity_Output = Classification_Input[Std] & (&(Classification_Input[Std-1:Man+1])) & (&(~Classification_Input[Man:0])); 
  
  
  // +ve infinity
  assign Classification_Pos_Infinity_Output = ~Classification_Input[Std] & (&(Classification_Input[Std-1:Man+1])) & (&(~Classification_Input[Man:0]));
  
  
  // -ve 0
  assign Classification_Neg_Zero_Output = Classification_Input[Std] & (&(~Classification_Input[Std-1:0]));
  
  
  // +ve 0
  assign Classification_Pos_Zero_Output = ~Classification_Input[Std] & (&(~Classification_Input[Std-1:0]));
  
  
  // snan
  assign Classification_Snan_Output = &(Classification_Input[Std-1:Man+1]) & (~Classification_Input[Man]) & (|(Classification_Input[Man-1:0]));
  
  
  // qnan
  assign Classification_Qnan_Output = &(Classification_Input[Std-1:Man+1]) & Classification_Input[Man] ;
  
  
  // +ve normal 
  assign Classification_Pos_Normal_Output = ( (~Classification_Input[Std]) & ( |(Classification_Input[Std-1:Man+1]) )   ) & (~(& Classification_Input[Std-1:Man+1]))  ;

  
  // -ve normal
  assign Classification_Neg_Normal_Output =  ( (Classification_Input[Std]) & (|(Classification_Input[Std-1:Man+1]))  ) & (~(& Classification_Input[Std-1:Man+1])) ;
  
  
  // +ve subnormal
  assign Classification_Pos_Subnormal_Output = ~Classification_Input[Std] & (&(~Classification_Input[Std-1:Man+1])) & (|(Classification_Input[Man:0]));
  
  
  // -ve subnormal
  assign Classification_Neg_Subnormal_Output = Classification_Input[Std] & (&(~Classification_Input[Std-1:Man+1])) & (|(Classification_Input[Man:0]));
  
endmodule
