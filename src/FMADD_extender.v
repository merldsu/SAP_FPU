// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FMADD_Extender (Extender_input_A,Extender_input_B,Extender_output_A,Extender_output_B);
parameter std =31;
parameter man = 22;
parameter exp = 7;

//input declaration
input [std+1:0]  Extender_input_A,Extender_input_B;

//output declaration
output [2+exp+2*(man+2):0] Extender_output_A,Extender_output_B;

//main functionlity
assign  Extender_output_A =  {Extender_input_A[std+1],1'b0,Extender_input_A[std:0],{man+2{1'b0}}}  ;
assign  Extender_output_B =  {Extender_input_B[std+1],1'b0,Extender_input_B[std:0],{man+2{1'b0}}}  ;


endmodule
