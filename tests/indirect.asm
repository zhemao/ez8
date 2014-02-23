.org 0
goto main

.alias STATUS 1

.org 5
main:
  set 0x21      ; 5
  put 0x4       ; 6
  put 0x21      ; 7
  clr           ; 8
  iget 0        ; 9
  subl 0x21     ; 10
  skbs STATUS 0 ; 11
  goto error    ; 12
  set 0x22      ; 13
  put 0x22      ; 14
  clr           ; 15
  iget 0 1      ; 16
  subl 0x22     ; 17
  skbs STATUS 0 ; 18
  goto error    ; 19
  set 0x23      ; 20
  iput 0 2      ; 21
  clr           ; 22
  get 0x23      ; 23
  subl 0x23     ; 24
  skbs STATUS 0 ; 25
  goto error    ; 26

  ret 0         ; 27

error:
  ret 1         ; 28
