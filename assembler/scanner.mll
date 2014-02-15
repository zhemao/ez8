{ open Parser }

let decdigit = ['0'-'9']
let hexdigit = ['0'-'9' 'a'-'f' 'A'-'F']
let letter = ['a'-'z' 'A'-'Z' '_']

rule token = parse
  | "get" { GET }
  | "put" { PUT }
  | "sll" { SLL }
  | "srl" { SRL }
  | "sra" { SRA }
  | "add" { ADD }
  | "adc" { ADC }
  | "sub" { SUB }
  | "and" { AND }
  | "ior" { IOR }
  | "xor" { XOR }
  | "set" { SET }
  | "slll" { SLLL }
  | "srll" { SRLL }
  | "sral" { SRAL }
  | "addl" { ADDL }
  | "adcl" { ADCL }
  | "subl" { SUBL }
  | "andl" { ANDL }
  | "iorl" { IORL }
  | "xorl" { XORL }
  | "goto" { GOTO }
  | "call" { CALL }
  | "skeqz" { SKEQZ }
  | "sknez" { SKNEZ }
  | "skltz" { SKLTZ }
  | "skgez" { SKGEZ }
  | "skgtz" { SKGTZ }
  | "skglez" { SKGTZ }
  | "skbs" { SKBS }
  | "skbc" { SKBC }
  | "ret" { RET }
  | "retint" { RETINT }
  | "clr" { CLR }
  | "iget" { IGET }
  | "iput" { IPUT }
  | "a" { A }
  | "m" { M }
  | decdigit+ | "0x" hexdigit+
        as lit { INT_LIT(int_of_string lit) }
  | '\n' | "\r\n"{ EOL }
  | "org" { ORG }
  | "alias" { ALIAS }
  | letter (letter | decdigit)* as label { LABEL(label) }
  | [' ' '\t'] { token lexbuf }
and inline_comments = parse
  | '\n' { token lexbuf }
  | _ { inline_comments lexbuf }
