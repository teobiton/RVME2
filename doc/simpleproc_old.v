// asic processor plus memory
module system;
//declaration of parameters
parameter 
  step = 10,        // execution time of one instruction
  width = 32,       // data bus width
  addrsize = 12,    // address bus width
  memsize = 1<<addrsize,  // memory size
  sbits = 6;        // number of status bits
reg[width-1:0] MEM[0:memsize-1],  // memory declaration
               IR;                // instruction register declaration
reg[sbits-1:0] SR;                // status register
reg[addrsize-1:0] PC;             // program counter

//definition of instruction fields
`define OPCODE IR[31:28]          // opcode
`define AA IR[23:12]              // operand AA
`define BB IR[11:0]               // operand BB
`define IM IR[27]                 // operand type
				  // 1: immediate 
				  // 0: memory 
`define CCODE IR[27:24]           // branch condition
`define SHL IR[27]                // shift direction
				  // 1: left 
				  // 0: right 
`define SHD IR[16:12]             // shift distance

//instruction codes
`define HLT 4'b0000             // halt 
`define BRA 4'b0001             // branch 
`define NOP 4'b0010             // no-op 
`define STR 4'b0011             // store 
`define SHF 4'b0100             // shift 
`define CPL 4'b0101             // complement 
`define ADD 4'b0110             // add 
`define MUL 4'b0111             // multiply

//condition code and status bit position
`define ALWAYS    0             
`define CARRY     1             
`define EVEN      2            
`define PARITY    3            
`define ZERO      4            
`define NEG       5            

//set flags
task setcondcode;
input [width:0] RES;
begin
SR[`ALWAYS]     = 1;
SR[`CARRY]      = RES[width];
SR[`EVEN]       = ~RES[0];
SR[`PARITY]     = ^RES;
SR[`ZERO]       = ~(|RES);
SR[`NEG]        = RES[width-1];
end
endtask

//reset: start module
initial begin
	
  PC = 0;            // start program
 end
//main cycle for one instruction
always begin         // execution time of one instruction
  #step
  IR = MEM[PC];      //instruction fetch
  PC = PC + 1;       //increment program counter
  case(`OPCODE)
  `NOP:;             //nothing to do
  `BRA: if (SR[`CCODE])     //branch
	PC = `BB;
  `STR: if (`IM)                //store
	MEM[`BB] = `AA;         //immediate
	else
	MEM[`BB] = MEM[`AA];    //direct
  `ADD: begin
	MEM[`BB] = MEM[`AA] + MEM[`BB];
	setcondcode(MEM[`BB]);
	end
  `MUL: begin
	MEM[`BB] = MEM[`AA] * MEM[`BB];
	setcondcode(MEM[`BB]);
	end
  `CPL: begin
	  if (`IM)                 //complement store
	  MEM[`BB] = ~`AA;         //immediate
	  else
	  MEM[`BB] = ~MEM[`AA];    //direct
	  setcondcode(MEM[`BB]);
	  end
  `SHF: begin
	  if (`SHL)                 //shift 
	  MEM[`BB] = MEM[`BB] << `SHD;         //left
	  else
	  MEM[`BB] = MEM[`BB] >> `SHD;         //right
	  setcondcode(MEM[`BB]);
	  end
  `HLT: $finish ;                   // halt
  default: $display("erreur: mauvaise valeur dans op-code");
  endcase
  end
endmodule 

