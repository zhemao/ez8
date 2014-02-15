type addr =
  | AddrLiteral of int
  | AddrLabel of string
  | AddrNone

type instruction =
  | Get  of addr
  | Put  of addr
  | Sll  of addr * bool
  | Srl  of addr * bool
  | Sra  of addr * bool
  | Add  of addr * bool
  | Adc  of addr * bool
  | Sub  of addr * bool
  | And  of addr * bool
  | Ior  of addr * bool
  | Xor  of addr * bool
  | Set  of int
  | Slll of int * bool
  | Srll of int * bool
  | Sral of int * bool
  | Addl of int * bool
  | Adcl of int * bool
  | Subl of int * bool
  | Andl of int * bool
  | Iorl of int * bool
  | Xorl of int * bool
  | Goto of addr
  | Call of addr
  | Skeqz of addr * bool
  | Sknez of addr * bool
  | Skltz of addr * bool
  | Skgez of addr * bool
  | Skgtz of addr * bool
  | Sklez of addr * bool
  | Skbs  of addr * int * bool
  | Skbc  of addr * int * bool
  | Ret
  | Retint
  | Clr of addr * bool
  | Com of addr * bool
  | Iget of int * addr
  | Iput of int * addr

type directive =
  | Label of string
  | Org of int
  | Alias of string * int
  | Instruction of instruction
