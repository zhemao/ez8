%{ open Instructions %}

%token GET PUT SLL SRL SRA
%token ADD ADC SUB AND IOR XOR
%token SET SLLL SRLL SRAL
%token ADDL ADCL SUBL ANDL IORL XORL
%token GOTO CALL
%token SKEQZ SKNEZ SKLTZ SKGEZ SKGTZ SKLEZ SKBS SKBC
%token RET RETINT CLR IGET IPUT
%token A M
%token <int> INT_LIT
%token ORG ALIAS
%token <string> LABEL
%token EOL

%%
