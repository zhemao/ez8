.org 0
goto main

.org 5
main:
  set 0      ; 5
  skeqz      ; 6
  goto error ; 7
  set 1      ; 8
  sknez      ; 9
  goto error ; 10
  skgtz      ; 11
  goto error ; 12
  skgez      ; 13
  goto error ; 14
  set -1     ; 15
  skltz      ; 16
  goto error ; 17
  put 0x21   ; 18
  sklez 0x21 ; 19
  goto error ; 20
  ret 0      ; 21

error:
  ret 1      ; 24
