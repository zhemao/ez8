OCAMLYACC=menhir
OCAMLLEX=ocamllex
NATIVE=false
OCAMLC=ocamlc
OCAMLOPT=ocamlopt

ifeq ($(NATIVE),true)

ez8asm: instructions.cmx parser.cmx scanner.cmx encoder.cmx
	$(OCAMLOPT) $^ -o $@

encoder.cmx encoder.cmi: encoder.ml scanner.cmi parser.cmi instructions.cmi
	$(OCAMLOPT) -c $<

scanner.cmx scanner.cmi: scanner.ml parser.cmi
	$(OCAMLOPT) -c $<

parser.cmx: parser.ml parser.cmi
	$(OCAMLOPT) -c $<

instructions.cmx instructions.cmi: instructions.ml
	$(OCAMLOPT) -c $<

else

ez8asm: instructions.cmo parser.cmo scanner.cmo encoder.cmo
	$(OCAMLC) $^ -o $@


encoder.cmo encoder.cmi: encoder.ml scanner.cmi parser.cmi instructions.cmi
	$(OCAMLC) -c $<

scanner.cmo scanner.cmi: scanner.ml parser.cmi
	$(OCAMLC) -c $<

parser.cmo: parser.ml parser.cmi
	$(OCAMLC) -c $<

instructions.cmo instructions.cmi: instructions.ml
	$(OCAMLC) -c $<
endif

parser.cmi: parser.mli instructions.cmi
	$(OCAMLC) -c $<

parser.ml parser.mli: parser.mly
	$(OCAMLYACC) $<

scanner.ml: scanner.mll
	$(OCAMLLEX) $<

clean:
	rm -f *.cmi *.cmo *.cmx parser.ml parser.mli scanner.ml ez8asm
