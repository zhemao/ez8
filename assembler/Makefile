OCAMLYACC=menhir
OCAMLLEX=ocamllex
OCAMLC=ocamlc

encoder: instructions.cmo parser.cmo scanner.cmo encoder.cmo
	$(OCAMLC) $^ -o $@

encoder.cmo encoder.cmi: encoder.ml scanner.cmi parser.cmi instructions.cmi
	$(OCAMLC) -c $<

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
