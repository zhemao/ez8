OCAMLYACC=menhir
OCAMLLEX=ocamllex
NATIVE=true
OCAMLC=ocamlc
OCAMLOPT=ocamlopt

ifeq ($(NATIVE),true)
ez8asm: linenum.cmx instructions.cmx exceptions.cmx parser.cmx \
		scanner.cmx encoder.cmx
	$(OCAMLOPT) $^ -o $@

encoder.cmx encoder.cmi: encoder.ml scanner.cmi parser.cmi \
		instructions.cmi exceptions.cmi
	$(OCAMLOPT) -c $<

scanner.cmx scanner.cmi: scanner.ml parser.cmi linenum.cmi
	$(OCAMLOPT) -c $<

parser.cmx: parser.ml parser.cmi linenum.cmi exceptions.cmi
	$(OCAMLOPT) -c $<

instructions.cmx instructions.cmi: instructions.ml
	$(OCAMLOPT) -c $<

linenum.cmx linenum.cmi: linenum.ml
	$(OCAMLOPT) -c $<

exceptions.cmx exceptions.cmi: exceptions.ml
	$(OCAMLOPT) -c $<
else
ez8asm: linenum.cmo instructions.cmo linenum.cmo exceptions.cmo parser.cmo \
		scanner.cmo encoder.cmo
	$(OCAMLC) $^ -o $@

encoder.cmo encoder.cmi: encoder.ml scanner.cmi parser.cmi \
		instructions.cmi linenum.cmi exceptions.cmi
	$(OCAMLC) -c $<

scanner.cmo scanner.cmi: scanner.ml parser.cmi linenum.cmi
	$(OCAMLC) -c $<

parser.cmo: parser.ml parser.cmi exceptions.cmi
	$(OCAMLC) -c $<

instructions.cmo instructions.cmi: instructions.ml
	$(OCAMLC) -c $<

linenum.cmo linenum.cmi: linenum.ml
	$(OCAMLC) -c $<

exceptions.cmo exceptions.cmi: exceptions.ml
	$(OCAMLOPT) -c $<
endif

parser.cmi: parser.mli instructions.cmi
	$(OCAMLC) -c $<

parser.ml parser.mli: parser.mly
	$(OCAMLYACC) $<

scanner.ml: scanner.mll
	$(OCAMLLEX) $<

clean:
	rm -f *.cmi *.cmo *.cmx parser.ml parser.mli scanner.ml ez8asm
