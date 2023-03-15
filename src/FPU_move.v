// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_move(rst_l,opcode,Move_Input_IEEE,Move_Output_IEEE);
  //Standard Defination For Parameterization
  
  parameter Std = 31; // Means IEEE754 Std 32 Bit Single Precision -1 for bits
  
  input [Std : 0] Move_Input_IEEE; // Input of IEEE754 32 Move Instruction 
  input [1:0] opcode; // opcode for selection
  input rst_l; // clock & reset for Synchronizations
  output [Std : 0] Move_Output_IEEE; // Output of IEEE754 32 Move Instruction 
  
  wire [Std : 0] Move_Output_IEEE; // Define reg becuase it is Output of IEEE754 32 Move Instruction 
   
  // New logic will  be
  assign Move_Output_IEEE = (rst_l == 1'b0) ? { (Std+1){1'b0} } :  (opcode[0] == 1'b1) ? Move_Input_IEEE : (opcode[1] == 1'b1) ? Move_Input_IEEE : { (Std+1){1'b0} } ;
  
endmodule
