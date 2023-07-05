 /*
 Authors: Téo Biton, Mathis Briard
 Date: 18.02.2023 (v0)
 Description: Simple single-cycle RISC-V processor (RV32I) for simulation,
              plus regfile
*/

module system;

  // Parameters declaration
  parameter 
    step     = 10,          // execution time of one instruction
    width    = 32,          // data bus width
    addrsize = 12,          // address bus width
    memsize  = 1<<addrsize, // memory size
    sbits    = 6;           // number of status bits

  // Local parameters declaration
  localparam int unsigned IR_SIZE = 32; // instructions are on 32 bits
  localparam int unsigned NREGS   = 16; // number or registers

  reg[width-1:0]    MEM[0:memsize-1];  // memory declaration
  reg[IR_SIZE-1:0]  IR;                // instruction register declaration
  reg[sbits-1:0]    SR;                // status register
  reg[addrsize-1:0] PC;                // program counter
  reg[width-1:0]    REGS[0:NREGS-1];   // regfile declaration
  reg[addrsize-1:0] ADDR;              // address

  /*
    Instruction Fields
  */

  // instruction identifiers
  `define OPCODE  IR[6:0]     // opcode
  `define F3      IR[14:12]   // funct3
  `define F7      IR[31:25]   // funct7

  // register fields
  `define RS1   IR[19:15]    // source register 1
  `define RS2   IR[24:20]    // source register 2
  `define RD    IR[11:7]     // destination register

  // immediates
  `define I_IMM   IR[31:20]                    // I-type immediate
  `define S_IMM   IR[31:25] << 5 || IR[11:7]   // S-type immediate

  // addresses (for Load and Store instructions)
  `define LOAD_OFFSET    IR[31:20]
  `define STORE_OFFSET   IR[31:25] << 5 || IR[11:7]

  /*
    Instruction Declarations
  */

  `define ARITHMETIC        7'b0110011
  `define IMM_ARITHMETIC    7'b0010011
  `define LOAD              7'b0000011
  `define STORE             7'b0100011
  `define EBREAK            7'b1110011

  /* Arithmetic instructions */
  `define ADD   {3'b000, 7'b0000000}
  `define SUB   {3'b000, 7'b0100000}
  `define SLL   {3'b001, 7'b0000000}  // Shift Left
  `define SRL   {3'b101, 7'b0000000}  // Shift Right

  /* Load instructions */
  `define LW    3'b010  // Load Word

  /* Store instructions */
  `define SW    3'b010  // Store Word

  /* Arithmetic immediates instructions */
  `define ADDI  3'b000  // Add Immediate
  `define ANDI  3'b011  // And Immediate
  `define ORI   3'b100  // Or Immediate

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
    
    PC = 0; // start program

  end

  /*
    Main cycle for one instruction
  */
  always @ (posedge clk) begin // execution time of one instruction
    
    #step;
    PC   <= PC + 1;       // increment program counter
    IR   = MEM[PC];       // instruction fetch
    ADDR = 0;             // address initial value
    
    case(`OPCODE)       // decode instruction
      `ARITHMETIC: begin
        case({`F3, `F7})
          `ADD: REGS[`RD] = REGS[`RS1] + REGS[`RS2];
          `SUB: REGS[`RD] = REGS[`RS1] - REGS[`RS2];
          `SRL: REGS[`RD] = REGS[`RS1] >> REGS[`RS2][4:0];
          `SLL: REGS[`RD] = REGS[`RS1] << REGS[`RS2][4:0];
          default: $display("erreur: mauvaise instruction arithmétique");
        endcase
      end
      `IMM_ARITHMETIC: begin
        case(`F3)
          `ADDI: REGS[`RD] = REGS[`RS1] + `I_IMM;
          `ANDI: REGS[`RD] = REGS[`RS1] & `I_IMM;
          `ORI:  REGS[`RD] = REGS[`RS1] | `I_IMM;
          default: $display("erreur: mauvaise instruction arithmétique immédiate");
        endcase
      end
      `LOAD: begin
        case(`F3)
          `LW: begin
            ADDR      = `LOAD_OFFSET + REGS[`RS1];
            REGS[`RD] = MEM[ADDR];;
          end
          default: $display("erreur: mauvaise instruction load");
        endcase
      end
      `STORE: begin
        case(`F3)
          `SW: begin
            ADDR      = `LOAD_OFFSET + REGS[`RS1];
            MEM[ADDR] = REGS[`RS2];
          end
          default: $display("erreur: mauvaise instruction store");
        endcase
      end
      `EBREAK: $finish ; // halt
      default: $display("erreur: mauvaise valeur dans op-code");
    endcase
  end
  
endmodule 