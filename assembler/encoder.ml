open Instructions
open Printf
open Exceptions

module LabelMap = Map.Make(String);;

let resolve_addr labels = function
  | AddrLiteral(i) -> i
  | AddrLabel(s) ->
        if LabelMap.mem s labels then
            LabelMap.find s labels
        else raise (Label_not_defined s)
  | AddrNone -> 0

let rec concat_bits chunks word_size accum =
    let mask bits size =
        bits land ((1 lsl size) - 1) in
    match chunks with
      | (bits, size) :: rest ->
            if size > word_size then
                raise Too_many_bits
            else
                let shift = word_size - size in
                let accum = accum lor ((mask bits size) lsl shift) in
                concat_bits rest shift accum
      | [] -> if word_size != 0 then raise Not_enough_bits else accum

let encode_instruction labels instruction =
    let assemble_instruction chunks = concat_bits chunks 16 0 in
    let bool_to_bits b = if b then 1, 1 else 0, 1 in
    let addr_to_bits addr = (resolve_addr labels addr), 8 in
    let instr_addr_to_bits addr = (resolve_addr labels addr), 12 in
    let indirect_addr_to_bits addr = (resolve_addr labels addr), 3 in
    match instruction with
      | Get(addr) -> assemble_instruction
            [0, 4; addr_to_bits addr; 0, 4]
      | Put(addr) -> assemble_instruction
            [0, 4; addr_to_bits addr; 1, 4]
      | Sll(addr, dir) -> assemble_instruction
            [1, 4; addr_to_bits addr; 0, 3; bool_to_bits dir]
      | Srl(addr, dir) -> assemble_instruction
            [1, 4; addr_to_bits addr; 4, 3; bool_to_bits dir]
      | Sra(addr, dir) -> assemble_instruction
            [1, 4; addr_to_bits addr; 6, 3; bool_to_bits dir]
      | Add(addr, dir) -> assemble_instruction
            [2, 4; addr_to_bits addr; 0, 3; bool_to_bits dir]
      | Adc(addr, dir) -> assemble_instruction
            [2, 4; addr_to_bits addr; 2, 3; bool_to_bits dir]
      | Sub(addr, dir) -> assemble_instruction
            [2, 4; addr_to_bits addr; 4, 3; bool_to_bits dir]
      | And(addr, dir) -> assemble_instruction
            [3, 4; addr_to_bits addr; 0, 3; bool_to_bits dir]
      | Ior(addr, dir) -> assemble_instruction
            [3, 4; addr_to_bits addr; 2, 3; bool_to_bits dir]
      | Xor(addr, dir) -> assemble_instruction
            [3, 4; addr_to_bits addr; 4, 3; bool_to_bits dir]
      | Set(lit) -> assemble_instruction [4, 4; lit, 8; 0, 4]
      | Slll(lit) -> assemble_instruction [5, 4; lit, 8; 0, 4]
      | Srll(lit) -> assemble_instruction [5, 4; lit, 8; 8, 4]
      | Sral(lit) -> assemble_instruction [5, 4; lit, 8; 12, 4]
      | Addl(lit) -> assemble_instruction [6, 4; lit, 8; 0, 4]
      | Adcl(lit) -> assemble_instruction [6, 4; lit, 8; 4, 4]
      | Subl(lit) -> assemble_instruction [6, 4; lit, 8; 8, 4]
      | Andl(lit) -> assemble_instruction [7, 4; lit, 8; 0, 4]
      | Iorl(lit) -> assemble_instruction [7, 4; lit, 8; 4, 4]
      | Xorl(lit) -> assemble_instruction [7, 4; lit, 8; 8, 4]
      | Goto(addr) -> assemble_instruction [8, 4; instr_addr_to_bits addr]
      | Call(addr) -> assemble_instruction [8, 4; instr_addr_to_bits addr]
      | Skeqz(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 0, 3; bool_to_bits dir]
      | Sknez(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 1, 3; bool_to_bits dir]
      | Skltz(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 2, 3; bool_to_bits dir]
      | Skgez(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 3, 3; bool_to_bits dir]
      | Skgtz(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 4, 3; bool_to_bits dir]
      | Sklez(addr, dir) -> assemble_instruction
            [10, 4; addr_to_bits addr; 5, 3; bool_to_bits dir]
      | Skbs(addr, bitnum, dir) -> assemble_instruction
            [11, 4; addr_to_bits addr; bitnum, 3; bool_to_bits dir]
      | Skbc(addr, bitnum, dir) -> assemble_instruction
            [12, 4; addr_to_bits addr; bitnum, 3; bool_to_bits dir]
      | Ret -> 0xd000
      | Retint -> 0xd008
      | Iget(lit, addr) -> assemble_instruction
            [14, 4; lit, 8; indirect_addr_to_bits addr; 0, 1]
      | Iput(lit, addr) -> assemble_instruction
            [14, 4; lit, 8; indirect_addr_to_bits addr; 1, 1]
      | Clr(addr, dir) -> assemble_instruction
            [15, 4; addr_to_bits addr; 0, 3; bool_to_bits dir]
      | Com(addr, dir) -> assemble_instruction
            [15, 4; addr_to_bits addr; 4, 3; bool_to_bits dir]

let rec second_pass directives cur_addr labels code =
    match directives with
      | Instruction(ln, instr) :: rest ->
            Linenum.linenum := ln;
            code.(cur_addr) <- encode_instruction labels instr;
            second_pass rest (cur_addr + 1) labels code
      | Org(ln, addr) :: rest ->
            Linenum.linenum := ln;
            second_pass rest addr labels code
      | _ :: rest -> second_pass rest cur_addr labels code
      | [] -> code

let rec first_pass directives cur_addr labels =
    match directives with
      | Label(ln, str) :: rest ->
            Linenum.linenum := ln;
            first_pass rest cur_addr (LabelMap.add str cur_addr labels)
      | Org(ln, addr) :: rest ->
            Linenum.linenum := ln;
            first_pass rest addr labels
      | Alias(ln, str, addr) :: rest ->
            Linenum.linenum := ln;
            first_pass rest cur_addr (LabelMap.add str addr labels)
      | Instruction(ln, _) :: rest ->
            Linenum.linenum := ln;
            first_pass rest (cur_addr + 1) labels
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
        try
            let directives = Parser.top_level Scanner.token lexbuf in
            let code_size, labels = first_pass directives 0 LabelMap.empty in
            let code = Array.make code_size 0 in
            let code = second_pass directives 0 labels code in
            let binfilename = Filename.chop_extension asmfilename ^ ".bin" in
            let binfile = open_out_bin binfilename in
            output_code binfile code; close_in asmfile; close_out binfile
        with
          | Parser.Error ->
                printf "Parse error on line %d\n" !Linenum.linenum
          | Unknown_instruction str ->
                printf "Unknown instruction %s on line %d\n" str !Linenum.linenum
          | Label_not_defined str ->
                printf "Label %s not found on line %d\n" str !Linenum.linenum
          | err -> raise err
