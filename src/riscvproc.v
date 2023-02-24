/* 
 Author: Téo Biton, Mathis Briard
 Date: 18.02.2023 (v0)
 Description: Simple RISC-V processor (RV32I) for simulation,
			  plus regfile
*/

module system;

// Parameters declaration
parameter 
  step = 10,        	 // execution time of one instruction
  width = 32,       	 // data bus width
  addrsize = 12,    	 // address bus width
  memsize = 1<<addrsize, // memory size
  sbits = 6;        	 // number of status bits

// Local parameters declaration
localparam int unsigned IR_SIZE = 32; // instructions are on 32 bits
localparam int unsigned NREGS = 16;   // number or registers

reg[width-1:0] MEM[0:memsize-1]; 	 // memory declaration
reg[IR_SIZE-1:0]  IR;                // instruction register declaration
reg[sbits-1:0]    SR;                // status register
reg[addrsize-1:0] PC;                // program counter
reg[width-1:0]	  REGS[0:NREGS-1];	 // regfile declaration

//TODO: change instruction fields definition
/*
	Instruction Fields
*/

// instruction identifiers
`define OPCODE  IR[6:0]   		// opcode
`define F3 		IR[14:12]		// funct3
`define F7 		IR[31:25]		// funct7

// register fields
`define RS1 	IR[19:15]		// source register 1
`define RS2 	IR[24:20]		// source register 2
`define RD 		IR[11:7]		// destination register

// immediates
`define I_IMM 	IR[31:12]					// I-type immediate
`define S_IMM 	IR[31:25] << 5 || IR[11:7]  // S-type immediate

/*
	Instruction Declarations
*/

`define ARITHMETIC 	   7'b0110011
`define IMM_ARITHMETIC 7'b0010011
`define LOAD 		   7'b0000011
`define STORE 		   7'b0100011

/* Arithmetic instructions */
`define ADD 	3'b000

//TODO: do we keep this ?
/*
	Status Register
*/
// condition code and status bit position
`define ALWAYS    0             
`define CARRY     1             
`define EVEN      2            
`define PARITY    3            
`define ZERO      4            
`define NEG       5            

// set flags
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

/*
	Reset (start module)
*/
initial begin
	
  PC = 0;            // start program
 end

/*
	Main cycle for one instruction
*/
always begin         // execution time of one instruction
  #step
  IR = MEM[PC];      // instruction fetch
  PC = PC + 1;       // increment program counter
  case(`OPCODE)		 // decode instruction
  `NOP:;             				// nothing to do
  `BRA: if (SR[`CCODE])     		// branch
	PC = `BB;
  `STR: if (`IM)                	// store
	MEM[`BB] = `AA;         		// immediate
	else
	MEM[`BB] = MEM[`AA];    		// direct
  `ADD: begin
	MEM[`BB] = MEM[`AA] + MEM[`BB];
	setcondcode(MEM[`BB]);
	end
  `MUL: begin
	MEM[`BB] = MEM[`AA] * MEM[`BB];
	setcondcode(MEM[`BB]);
	end
  `CPL: begin
	  if (`IM)                 		  // complement store
	  MEM[`BB] = ~`AA;         		  // immediate
	  else
	  MEM[`BB] = ~MEM[`AA];    		  // direct
	  setcondcode(MEM[`BB]);
	  end
  `SHF: begin
	  if (`SHL)                	      // shift 
	  MEM[`BB] = MEM[`BB] << `SHD;    // left
	  else
	  MEM[`BB] = MEM[`BB] >> `SHD;    // right
	  setcondcode(MEM[`BB]);
	  end
  `HLT: $finish ;                  	  // halt
  default: $display("erreur: mauvaise valeur dans op-code");
  endcase
end
endmodule 

