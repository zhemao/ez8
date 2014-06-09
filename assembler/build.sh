if [ "x$1" == "x-byte" ]; then
    BINNAME=encoder.byte
else
    BINNAME=encoder.native
fi

ocamlbuild -use-menhir "$BINNAME"
cp "_build/$BINNAME" ez8asm
