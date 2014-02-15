.org 0
goto main

.org 5
main
  set 25
  put 0x21
  set 5
  add 0x21
  subl 30
  skeqz
  goto error
  set 0
  ret

error
  set 1
  ret
