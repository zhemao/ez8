OCAMLYACC=menhir
OCAMLLEX=ocamllex
OCAMLC=ocamlc

scanner.cmo scanner.cmi: scanner.ml parser.cmi
	$(OCAMLC) -c $<

parser.cmo: parser.ml parser.cmi
	$(OCAMLC) -c $<

parser.cmi: parser.mli instructions.cmi
	$(OCAMLC) -c $<

instructions.cmo instructions.cmi: instructions.ml
	$(OCAMLC) -c $<

parser.ml parser.mli: parser.mly
	$(OCAMLYACC) $<

scanner.ml: scanner.mll
	$(OCAMLLEX) $<

clean:
	rm -f *.cmi *.cmo *.cmx parser.ml parser.mli scanner.ml
