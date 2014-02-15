#!/bin/sh

make scanner.cmo parser.cmo

PARSE='
open Instructions;;\n
\n
let lexbuf = Lexing.from_channel stdin in\n
Parser.top_level Scanner.token lexbuf;;'
(echo -e $PARSE; cat -) | ocaml scanner.cmo parser.cmo | tail -n +3 | head -n -1
