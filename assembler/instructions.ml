type addr =
  | AddrLiteral of int
  | AddrLabel of string

type instruction =
  | Get  of int * bool
  | Put  of int * bool
  | Sll  of int * bool
  | Srl  of int * bool
  | Sra  of int * bool
  | Add  of int * bool
  | Adc  of int * bool
  | Sub  of int * bool
  | And  of int * bool
  | Ior  of int * bool
  | Xor  of int * bool
  | Set  of int * bool
  | Slll of int * bool
  | Srll of int * bool
  | Sral of int * bool
  | Addl of int * bool
  | Subl of int * bool
  | Andl of int * bool
  | Iorl of int * bool
  | Xorl of int * bool
  | Goto of addr
  | Call of addr
  | Skeqz of int * bool
  | Sknez of int * bool
  | Skltz of int * bool
  | Skgez of int * bool
  | Skgtz of int * bool
  | Sklez of int * bool
  | Skbs  of int * bool
  | Skbc  of int * bool
  | Ret
  | Retint
  | Clr of int * bool
  | Iget of int * bool
  | Iput of int * bool

type directive =
  | Label of string
  | Org of int
  | Alias of string * int
  | Instruction of instruction
