// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.

module FPU_Top (Operand_A,Operand_B,Operand_C, clk,rst_l, frm, sfpu_op,fpu_sel,FPU_resultant, S_Flags, Exception_flag, interupt_Pin,FPU_Result_rd,Operand_Int);

parameter std= 31;
parameter man = 22;
parameter exp = 7;
parameter Bias = 127;
parameter lzd = 4;


/*opcode activation signals
sfpu[0] = Fadd
sfpu[1] = Fsubb
sfpu[2] = Fmul
sfpu[3] = Fdiv
sfpu[4] = Fsqrt
sfpu[5] = Fmin
sfpu[6] = Fmax
sfpu[7] = Fmvx
sfpu[8] = Fmvf
sfpu[9] = feq
sfpu[10] = flt
sfpu[11] = fle
sfpu[12] = Fmadd
sfpu[13] = Fmsubb
sfpu[14] = FCVT.W.P
sfpu[15] = FCVT.P.W
sfpu[16] = Fnmsubb
sfpu[17] = Fnmadd
sfpu[18] = fsgnj
sfpu[19] = fsgnjn
sfpu[20] = fsgnjx
sfpu[21] = fclass
sfpu[22] = unsign
sfpu[23] = sign
*/


/* CSR flag registers adrsses
CSR[4] = NV invalid
CSR[3] = DZ Div by zero
CSR[2] = OF overflow
CSR[1] = UF underflow
CSR[0] = NX inexact
*/




//inputs
input [std:0] Operand_A,Operand_B,Operand_C;
input clk,rst_l;
input [2:0] frm;
input [23:0] sfpu_op;
input [2:0]  fpu_sel;
input [31:0] Operand_Int;

//output 
output  [std:0]    FPU_resultant;
output  [4:0]   S_Flags;
output  Exception_flag;
output interupt_Pin;  
output [31:0]FPU_Result_rd;

wire [std:0] output_interim_input_validation_temp_storage;
wire output_interim_input_validation_exception_flag_Fadd,output_interim_input_validation_exception_flag_Fsub,output_interim_input_validation_exception_flag_Fmul ,output_interim_input_validation_exception_flag_Fdiv, output_interim_input_validation_exception_flag_Fsqrt, output_interim_input_validation_exception_flag_Fcomp, output_interim_input_validation_exception_flag_Fmadd, output_interim_input_validation_exception_flag_Fmsub;
wire Exception_flag_interim ;
wire output_interim_input_validation_Divide_By_Zero;
wire output_interim_input_validation_interput;
wire output_interim_input_validation_invalid_flag;

wire [std:0] output_interim_Fmove;

wire [std:0] output_interim_FPU_sign;

wire [31:0] output_interim_FLOAT_to_Int;
wire output_interim_Invalid_Flag_Float_To_Int;
wire output_interim_Inexact_Flag_Float_To_Int;

wire [std:0] output_interim_Int_to_Float;
wire output_interim_Invalid_Flag_Int_To_Float;
wire output_interim_Inexact_Flag_Int_To_Float;

wire [31:0] output_interim_Comparison;
wire [7:0] input_Opcode_Fcomp;
wire [std:0] output_interim_Fmax_Fmin;

wire [31:0] output_interim_Fclass;

wire [std:0] output_interim_FMADD,output_interim_Fmul;
wire [2:0] output_interim_S_Flags_Fmul, output_interim_S_Flags_Fmadd;
wire output_FMADD_interim_ready_Flagg;


//interim register
//output registers
reg [std:0]    FPU_resultant_reg;
reg[31:0] FPU_Result_rd_reg;
reg [4:0]   S_Flags_reg;
reg interput_Pin_reg;

//Module instantiation for input vlaidation stage of the FPU
FPU_Input_Validation input_Validation (
                                       .INPUT_VALIDATION_input_ieee_A(Operand_A),
                                       .INPUT_VALIDATION_input_ieee_B(Operand_B),
                                       .INPUT_VALIDATION_input_ieee_C(Operand_C),
                                       .INPUT_VALIDATION_input_opcode(sfpu_op),
                                       .INPUT_VALIDATION_input_Frm (frm),
                                       .INPUT_VALIDATION_Output_temp_storage (output_interim_input_validation_temp_storage),
                                       .INPUT_VALIDATION_Output_exception_flag_Fadd (output_interim_input_validation_exception_flag_Fadd),
                                       .INPUT_VALIDATION_Output_exception_flag_Fsub (output_interim_input_validation_exception_flag_Fsub),
                                       .INPUT_VALIDATION_Output_exception_flag_Fmul (output_interim_input_validation_exception_flag_Fmul),
                                       .INPUT_VALIDATION_Output_exception_flag_Fdiv (output_interim_input_validation_exception_flag_Fdiv),
                                       .INPUT_VALIDATION_Output_exception_flag_Fsqrt (output_interim_input_validation_exception_flag_Fsqrt),
                                       .INPUT_VALIDATION_Output_exception_flag_Fcomp (output_interim_input_validation_exception_flag_Fcomp),
                                       .INPUT_VALIDATION_Output_exception_flag_Fmadd (output_interim_input_validation_exception_flag_Fmadd),
                                       .INPUT_VALIDATION_Output_exception_flag_Fmsub (output_interim_input_validation_exception_flag_Fmsub),
                                       .INPUT_VALIDATION_Output_Flag_DZ (output_interim_input_validation_Divide_By_Zero),
                                       .INPUT_VALIDATION_Output_invalid_flag (output_interim_input_validation_invalid_flag),
                                       .interupt_Pin(output_interim_input_validation_interput),
                                       .rst_l(rst_l)
);

assign Exception_flag_interim =  output_interim_input_validation_exception_flag_Fadd | output_interim_input_validation_exception_flag_Fsub | output_interim_input_validation_exception_flag_Fmul | output_interim_input_validation_exception_flag_Fdiv | output_interim_input_validation_exception_flag_Fsqrt |  output_interim_input_validation_exception_flag_Fcomp | output_interim_input_validation_exception_flag_Fmadd |output_interim_input_validation_exception_flag_Fmsub ; 


defparam input_Validation.std=std;
defparam input_Validation.man=man;
defparam input_Validation.exp=exp;
defparam input_Validation.bias=Bias;

//module instantiation for Fmove instruction 

FPU_move Floating_move (
              .rst_l(rst_l),
              .opcode({(sfpu_op[8]),(sfpu_op[7])}),
              .Move_Input_IEEE(Operand_A),
              .Move_Output_IEEE(output_interim_Fmove)
);
defparam Floating_move.Std = std;


//module instantiation of FPU_sign injection instructions

FPU_sign Floating_sign_injection (
              .rst_l(rst_l),
              .op({(sfpu_op[20]),(sfpu_op[19]),(sfpu_op[18])}),
              .IEEE_A(Operand_A),
              .IEEE_B(Operand_B),
              .IEEE_out(output_interim_FPU_sign)
);

defparam Floating_sign_injection.Std=std;
defparam Floating_sign_injection.Man=man;
defparam Floating_sign_injection.Exp=exp;

//module instatiation of Float to int instrution

FPU_Float_to_Int Floating_Float2Int( 
                      .FLOAT_TO_INT_input_float(Operand_A),
                      .FLOAT_TO_INT_input_rm(frm),
                      .FLOAT_TO_INT_input_opcode_FI (sfpu_op[14]),
                      .FLOAT_TO_INT_input_opcode_unsigned(sfpu_op[22]),
                      .FLOAT_TO_INT_input_opcode_signed(sfpu_op[23]),
                      .FLOAT_TO_INT_output_int(output_interim_FLOAT_to_Int),
                      .FLOAT_TO_INT_output_invalid_flag(output_interim_Invalid_Flag_Float_To_Int),
                      .FLOAT_TO_INT_output_inexact_flag(output_interim_Inexact_Flag_Float_To_Int),
                      .rst_l(rst_l)
);
defparam Floating_Float2Int.std=std;
defparam Floating_Float2Int.man=man;
defparam Floating_Float2Int.exp=exp;
defparam Floating_Float2Int.bias=Bias;

//module instantiation of In to FLoat istruction

FPU_Int_to_Float floating_Int2Float (
                      .INT_TO_FLOAT_input_int(Operand_Int),
                      .INT_TO_FLOAT_input_rm(frm),
                      .INT_TO_FLOAT_input_opcode_IF (sfpu_op[15]),
                      .INT_TO_FLOAT_input_opcode_signed (sfpu_op[23]),
                      .INT_TO_FLOAT_input_opcode_unsigned (sfpu_op[22]), 
                      .INT_TO_FLOAT_output_float(output_interim_Int_to_Float), 
                      .INT_TO_FLOAT_output_invalid_flag(output_interim_Invalid_Flag_Int_To_Float), 
                      .INT_TO_FLOAT_output_inexact_flag (output_interim_Inexact_Flag_Int_To_Float),
                      .rst_l(rst_l)
);
defparam floating_Int2Float.std=std;
defparam floating_Int2Float.man=man;
defparam floating_Int2Float.exp=exp;
defparam floating_Int2Float.bias=Bias;


//module instatniation of comparision instructions

assign input_Opcode_Fcomp = {(sfpu_op[6]),(sfpu_op[5]),2'b00,(sfpu_op[11]),(sfpu_op[10]),1'b0,(sfpu_op[9])};

FPU_Comparison Floating_Comparison (
                                 .rst_l(rst_l),
                                 .opcode(input_Opcode_Fcomp),
                                 .Comparator_Input_IEEE_A(Operand_A),
                                 .Comparator_Input_IEEE_B(Operand_B),
                                 .Comparator_Output_IEEE(output_interim_Comparison),
                                 .Min_Max_Output_IEEE(output_interim_Fmax_Fmin)
);
defparam Floating_Comparison.Std=std;
defparam Floating_Comparison.Man=man;
defparam Floating_Comparison.Exp=exp;

//module instantiation for FCLASS instruction

FPU_Fclass Floating_Classify (
                            .rst_l (rst_l),
                            .Classification_Output (output_interim_Fclass),
                            .Classification_Input (Operand_A),
                            .opcode (sfpu_op[21])
);

defparam Floating_Classify.Std=std;
defparam Floating_Classify.Man=man;



// module instantiation for Fmadd/fmsub/fnmadd/fnmsub/fadd/fsub/fmul instruction

FPU_FMADD_SUBB_Top Floating_FMADD (
                                   .FMADD_SUBB_input_IEEE_A(Operand_A), 
                                   .FMADD_SUBB_input_IEEE_B(Operand_B),
                                   .FMADD_SUBB_input_IEEE_C(Operand_C),
                                   .FMADD_SUBB_input_opcode( { (sfpu_op[16]),(sfpu_op[17]),(sfpu_op[13]),(sfpu_op[12]),(sfpu_op[2]),(sfpu_op[1]),(sfpu_op[0])}  ),
                                   .rst_l(rst_l),
                                   .FMADD_SUBB_input_Frm(frm),
                                   .FMADD_SUBB_output_IEEE_FMADD (output_interim_FMADD),
                                   .FMADD_SUBB_output_S_Flags_FMADD(output_interim_S_Flags_Fmadd),
                                   .FMADD_SUBB_output_IEEE_FMUL(output_interim_Fmul),
                                   .FMADD_SUBB_output_S_Flags_FMUL(output_interim_S_Flags_Fmul)

);
defparam Floating_FMADD.std=std;
defparam Floating_FMADD.man=man;
defparam Floating_FMADD.exp=exp;
defparam Floating_FMADD.bias=Bias;
defparam Floating_FMADD.lzd=lzd;


//block for declartion of register output port
// THis port is anmed as FPU_reusltant_reg and would be assigned a 0 on reset of the FPU however the asssignent to this would be controlled by the opcode bits if the rsrt condition is not true.

always @ (posedge clk) 
begin
   
 if (~rst_l)
   begin
     FPU_resultant_reg <= {(std+1){1'b0}};
     FPU_Result_rd_reg <= 32'h00000000;
     S_Flags_reg <= 5'b00000;
     interput_Pin_reg<= 1'b0;
   end

else if ( rst_l & Exception_flag_interim ) 
   begin
   
   FPU_resultant_reg <= output_interim_input_validation_temp_storage;
   FPU_Result_rd_reg <= (std==15) ? {16'h0000,output_interim_input_validation_temp_storage[15:0]} : output_interim_input_validation_temp_storage;
   S_Flags_reg  <= { output_interim_input_validation_invalid_flag , output_interim_input_validation_Divide_By_Zero , 3'b000 } ;
   interput_Pin_reg <= output_interim_input_validation_interput ;

   end

else if (rst_l & (~Exception_flag_interim) )
begin

  if ( sfpu_op[0] | sfpu_op[1] | sfpu_op[12] | sfpu_op[13] | sfpu_op[16] | sfpu_op[17])  //output selection for FMADD FMSUB FNMADD FNMSUBB FADD FSUB
    begin
    FPU_resultant_reg <= output_interim_FMADD;
    FPU_Result_rd_reg <= 32'h00000000;
    S_Flags_reg <= {2'b00,output_interim_S_Flags_Fmadd};
    end
  
  else if (sfpu_op[2])   //output selection for FMUL
    begin
    FPU_resultant_reg <= output_interim_Fmul;
    FPU_Result_rd_reg <= 32'h00000000;
    S_Flags_reg <= {2'b00,output_interim_S_Flags_Fmul}; 
    end
  

  else if (sfpu_op[15])   //otuput selection for Int to float intruction FCVT.S.W   
    begin
    FPU_resultant_reg <= output_interim_Int_to_Float;
    FPU_Result_rd_reg <= 32'h00000000;
    S_Flags_reg <= {(output_interim_Invalid_Flag_Int_To_Float),3'b000,(output_interim_Inexact_Flag_Int_To_Float)}; 
    end

  else if (sfpu_op[18] | sfpu_op[19] | sfpu_op[20])   //output selection for sign injection instructions
    begin
    FPU_resultant_reg <= output_interim_FPU_sign;
    FPU_Result_rd_reg <= 32'h00000000;
    S_Flags_reg <= 5'b00000; 

    end    

  else if (sfpu_op[7] | sfpu_op[8])   //output selection for move instruction, FMOVE
    begin
    FPU_resultant_reg <= output_interim_Fmove;
    FPU_Result_rd_reg <= (std==15) ? {16'h0000,output_interim_Fmove[15:0]} : output_interim_Fmove;
    S_Flags_reg <= 5'b00000; 
    end 

  else if (sfpu_op[14])   //output selection logic for Float to int instruction FCVT.W.S
    begin
      FPU_resultant_reg  <= {(std+1){1'b0}};
    FPU_Result_rd_reg <= output_interim_FLOAT_to_Int;
    S_Flags_reg <= {output_interim_Invalid_Flag_Float_To_Int,3'b000,output_interim_Inexact_Flag_Float_To_Int};
    end    

  else if (sfpu_op[9] | sfpu_op[10] | sfpu_op[11]))  //output selection for comparision instructions
    begin
    FPU_resultant_reg  <= {(std+1){1'b0}};
    FPU_Result_rd_reg <= output_interim_Comparison;
    S_Flags_reg <= 5'b00000; 
    end

  else if (sfpu_op[6] | sfpu_op[5])          // otuput sleection for Fmin,Max
    begin
    FPU_resultant_reg <= output_interim_Fmax_Fmin;
    FPU_Result_rd_reg <= 32'h00000000;
    S_Flags_reg <= 5'b00000; 
    end            

  else if (sfpu_op[21])               //output slection for Fclass instructions
    begin
     FPU_resultant_reg <= {(std+1){1'b0}};
     FPU_Result_rd_reg <= output_interim_Fclass;
     S_Flags_reg <= 5'b00000; 
    end

  else 
    begin
     FPU_resultant_reg <= {(std+1){1'b0}};
     FPU_Result_rd_reg <= 32'h00000000;
     S_Flags_reg <= 5'b00000;
     
    end  
end

end  //end 


// assigment of interim register on outptu ports

assign FPU_resultant = (rst_l) ? (FPU_resultant_reg) :{std+1{1'b0}};
assign S_Flags = (rst_l) ? (S_Flags_reg) :5'b00000 ;
// Added by hamza
assign FPU_Result_rd = (rst_l == 1'b0) ? 32'h00000000 : (sfpu_op[21] & ~Exception_flag_interim) ? output_interim_Fclass : ((sfpu_op[9] | sfpu_op[10] | sfpu_op[11]) & ~Exception_flag_interim) ? output_interim_Comparison : (sfpu_op[14] & ~Exception_flag_interim) ? output_interim_FLOAT_to_Int : (Exception_flag_interim  & fpu_sel[1]) ? output_interim_input_validation_temp_storage : (sfpu_op[8] & ~Exception_flag_interim) ? output_interim_Fmove : FPU_Result_rd_reg ;

assign interupt_Pin = (rst_l) ? (interput_Pin_reg) : 1'b0;

//declaration of Asynchornus output of exceptional flag which is used to halt the stall, while working in Scalar mode. 
assign Exception_flag = Exception_flag_interim & fpu_sel[1] & (sfpu_op[3] | sfpu_op[4]);


endmodule
