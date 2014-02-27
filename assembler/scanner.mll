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
  | "sklez" { SKLEZ }
  | "skbs" { SKBS }
  | "skbc" { SKBC }
  | "ret" { RET }
  | "retint" { RETINT }
  | "clr" { CLR }
  | "com" { COM }
  | "iget" { IGET }
  | "iput" { IPUT }
  | "a" | "A" { A }
  | "m" | "M" { M }
  | '-'? decdigit+ | "0x" hexdigit+
        as lit { INT_LIT(int_of_string lit) }
  | ';' { comments lexbuf }
  | ':' { COLON }
  | '\n' | "\r\n"{ incr Linenum.linenum; EOL }
  | ".org" { ORG }
  | ".alias" { ALIAS }
  | letter (letter | decdigit)* as label { LABEL(label) }
  | [' ' '\t'] { token lexbuf }
  | eof { EOF }
and comments = parse
  | '\n' { incr Linenum.linenum; token lexbuf }
  | [^'\n']+ { EOL }
