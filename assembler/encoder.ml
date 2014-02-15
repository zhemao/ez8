open Instructions
open Printf

exception Syntax_error of int * int * string

module LabelMap = Map.Make(String);;

let encode_instruction labels = function
  | _ -> 0

let rec second_pass directives cur_addr labels code =
    match directives with
      | Instruction(instr) :: rest ->
            code.(cur_addr) <- encode_instruction labels instr;
            second_pass rest (cur_addr + 1) labels code
      | Org(addr) :: rest -> second_pass rest addr labels code
      | _ :: rest -> second_pass rest cur_addr labels code
      | [] -> code

let rec first_pass directives cur_addr labels =
    match directives with
      | Label(str) :: rest ->
            first_pass rest cur_addr (LabelMap.add str cur_addr labels)
      | Org(addr) :: rest -> first_pass rest addr labels
      | Alias(str, addr) :: rest ->
            first_pass rest cur_addr (LabelMap.add str addr labels)
      | Instruction(_) :: rest -> first_pass rest (cur_addr + 1) labels
      | [] -> (cur_addr + 1), labels

let output_word file word =
    output_byte file ((word lsr 8) land 0xff);
    output_byte file (word land 0xff)

let output_code file code =
    Array.iter (output_word file) code

let () =
    if Array.length Sys.argv < 2 then (
        printf "Usage: %s code.asm\n" Sys.argv.(0);
        exit 1 )
    else
        let asmfilename = Sys.argv.(1) in
        let asmfile = open_in asmfilename in
        let lexbuf = Lexing.from_channel asmfile in
        let directives = try
            Parser.top_level Scanner.token lexbuf
        with except ->
            let curr = lexbuf.Lexing.lex_curr_p in
            let line = curr.Lexing.pos_lnum in
            let col = curr.Lexing.pos_cnum in
            let tok = Lexing.lexeme lexbuf in
            raise (Syntax_error (line, col, tok))
        in
        let code_size, labels = first_pass directives 0 LabelMap.empty in
        let code = Array.make code_size 0 in
        let code = second_pass directives 0 labels code in
        let binfilename = Filename.chop_extension asmfilename ^ ".bin" in
        let binfile = open_out_bin binfilename in
        output_code binfile code;;
