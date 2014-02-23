.org 0
goto main

.alias STATUS 1

.org 5
main:
  set 0x05     ; 5
  put 0x10     ; 6
  set 0x20     ; 7
  ior STATUS m ; 8
  set 0x06     ; 9
  put 0x10     ; 10
  set 0xdf     ; 11
  and STATUS m ; 12
  get 0x10     ; 13
  subl 0x05    ; 14
  skeqz        ; 15
  goto error   ; 16
  set 0x20     ; 17
  ior STATUS m ; 18
  get 0x10     ; 19
  subl 0x06    ; 20
  skeqz        ; 21
  goto error   ; 22
  ret 0        ; 23

error:
  ret 1        ; 24
