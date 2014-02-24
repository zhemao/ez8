.alias STATUS 1
.alias INTCON 2

.org 0
goto init

.org 4
retint

.org 5
main:
; test addition and subtractioin
  set 25        ; 5
  put 0x21      ; 6
  set 5         ; 7
  add 0x21      ; 8
  subl 30       ; 9
  skeqz         ; 10
  goto error    ; 11
  set 0xff      ; 12
  addl 1        ; 13
  skbs STATUS 1 ; 14
  goto error    ; 15
  set 27        ; 16
  adcl 2        ; 17
  subl 29       ; 18
  skbc STATUS 0 ; 19
  goto error    ; 20
; test shifting
  set 0x80      ; 21
  sral 3        ; 22
  subl 0xf0     ; 23
  skbs STATUS 0 ; 24
  goto error    ; 25
  set 0x80      ; 26
  srll 3        ; 27
  slll 1        ; 28
  put 0x21      ; 29
  subl 0x20     ; 30
  skbs STATUS 0 ; 31
  goto error    ; 32
; test bitwise operations
  set 0x50      ; 33
  ior 0x21 M    ; 34
  set 0x10      ; 35
  xor 0x21 M    ; 36
  set 0x0f      ; 37
  ior 0x21 M    ; 38
  set 0xfc      ; 39
  and 0x21      ; 40
  subl 0x6c     ; 41
  skbs STATUS 0 ; 42
  goto error    ; 43
; test clr and com
  clr           ; 44
  skeqz         ; 45
  goto error    ; 46
  set 0xa3      ; 47
  put 0x21      ; 48
  com 0x21      ; 49
  get 0x21      ; 50
  subl 0x5c     ; 51
  skbs STATUS 0 ; 52
  goto error    ; 53
  ret 0         ; 54

error:
  ret 1         ; 55

init:
  ; set GIE
  set 0x80
  ior STATUS m
  set 0x01
  ; enable interrupt 0
  put INTCON
  goto main
