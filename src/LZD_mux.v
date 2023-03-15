// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_LZD_mux  (in_pos_1, in_val_1, in_pos_2, in_val_2, out_pos, out_val);

//Position of MSB set will be termed as P2
//Position of LSB set will be termed as P1 

parameter layer = 1;

input [layer-1 : 0] in_pos_1, in_pos_2;
input in_val_1, in_val_2;

output [layer : 0]out_pos;
output out_val;

assign out_val = in_val_1 | in_val_2;
assign out_pos = in_val_2 ? {!in_val_2, in_pos_2} : {!in_val_2, in_pos_1} ; 

endmodule
