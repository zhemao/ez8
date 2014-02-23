.org 0
goto main

.alias STATUS 1

.org 5
main:
  set 0x05
  put 0x10
  set 0x20
  ior STATUS m
  set 0x06
  put 0x10
  set 0xdf
  and STATUS m
  get 0x10
  subl 0x05
  skeqz
  goto error
  set 0x20
  ior STATUS m
  get 0x10
  subl 0x06
  skeqz
  goto error
  ret 0

error:
  ret 1
