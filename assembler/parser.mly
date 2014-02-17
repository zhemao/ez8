%{
    open Instructions;;
    let bool_of_int = function
        | 0 -> false
        | _ -> true
%}

%token GET PUT SLL SRL SRA
%token ADD ADC SUB AND IOR XOR
%token SET SLLL SRLL SRAL
%token ADDL ADCL SUBL ANDL IORL XORL
%token GOTO CALL
%token SKEQZ SKNEZ SKLTZ SKGEZ SKGTZ SKLEZ SKBS SKBC
%token RET RETINT CLR COM IGET IPUT
%token A M
%token <int> INT_LIT
%token ORG ALIAS
%token <string> LABEL
%token EOL EOF COLON

%start top_level
%type <Instructions.directive list> top_level

%%

addr:
  | INT_LIT { AddrLiteral($1) }
  | LABEL { AddrLabel($1) }

direction:
  | A { false }
  | M { true }
  | INT_LIT { bool_of_int $1 }
  | { false }

instruction:
  | GET addr { Get($2) }
  | PUT addr { Put($2) }
  | SLL addr direction { Sll($2, $3) }
  | SRL addr direction { Srl($2, $3) }
  | SRA addr direction { Sra($2, $3) }
  | ADD addr direction { Add($2, $3) }
  | ADC addr direction { Adc($2, $3) }
  | SUB addr direction { Sub($2, $3) }
  | AND addr direction { And($2, $3) }
  | IOR addr direction { Ior($2, $3) }
  | XOR addr direction { Xor($2, $3) }
  | SET INT_LIT { Set($2) }
  | SLLL INT_LIT { Slll($2) }
  | SRLL INT_LIT { Srll($2) }
  | SRAL INT_LIT { Sral($2) }
  | ADDL INT_LIT { Addl($2) }
  | ADCL INT_LIT { Adcl($2) }
  | SUBL INT_LIT { Subl($2) }
  | ANDL INT_LIT { Andl($2) }
  | IORL INT_LIT { Iorl($2) }
  | XORL INT_LIT { Xorl($2) }
  | GOTO addr { Goto($2) }
  | CALL addr { Call($2) }
  | SKEQZ { Skeqz(AddrNone, false) }
  | SKEQZ addr { Skeqz($2, true) }
  | SKNEZ { Sknez(AddrNone, false) }
  | SKNEZ addr { Sknez($2, true) }
  | SKLTZ { Skltz(AddrNone, false) }
  | SKLTZ addr { Skltz($2, true) }
  | SKGEZ { Skgez(AddrNone, false) }
  | SKGEZ addr { Skgez($2, true) }
  | SKGTZ { Skgtz(AddrNone, false) }
  | SKGTZ addr { Skgtz($2, true) }
  | SKLEZ { Sklez(AddrNone, false) }
  | SKLEZ addr { Sklez($2, true) }
  | SKBS addr INT_LIT { Skbs($2, $3, true) }
  | SKBS INT_LIT { Skbs(AddrNone, $2, false) }
  | SKBC addr INT_LIT { Skbc($2, $3, true) }
  | SKBC INT_LIT { Skbc(AddrNone, $2, false) }
  | RET { Ret }
  | RETINT { Retint }
  | CLR { Clr(AddrNone, false) }
  | CLR addr { Clr($2, true) }
  | COM { Com(AddrNone, false) }
  | COM addr { Com($2, true) }
  | IGET addr INT_LIT { Iget($3, $2) }
  | IPUT addr INT_LIT { Iput($3, $2) }

directive:
  | LABEL COLON { Label($1) }
  | ORG INT_LIT { Org($2) }
  | ALIAS LABEL INT_LIT { Alias($2, $3) }
  | instruction { Instruction($1) }

top_level:
  | directive EOL top_level { $1 :: $3 }
  | EOL top_level { $2 }
  | EOF { [] }

%%
