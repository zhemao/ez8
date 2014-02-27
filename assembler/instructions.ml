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
  | Slll of int
  | Srll of int
  | Sral of int
  | Addl of int
  | Adcl of int
  | Subl of int
  | Andl of int
  | Iorl of int
  | Xorl of int
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
  | Ret of int * bool
  | Retint
  | Clr of addr * bool
  | Com of addr * bool
  | Iget of int * addr
  | Iput of int * addr

type directive =
  | Label of int * string
  | Org of int * int
  | Alias of int * string * int
  | Instruction of int * instruction
