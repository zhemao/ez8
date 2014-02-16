.alias STATUS 1

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
  set 0xff
  addl 1
  skbs STATUS 1
  goto error
  set 27
  adcl 2
  subl 29
  skbc STATUS 0
  goto error
  set 0x80
  sral 3
  subl 0xf0
  skbs STATUS 0
  goto error
  set 0x80
  srll 3
  slll 1
  put 0x21
  subl 0x20
  skbs STATUS 0
  goto error
  set 0x50
  ior 0x21 M
  set 0x10
  xor 0x21 M
  set 0x0f
  ior 0x21 M
  set 0xfc
  and 0x21
  subl 0x6c
  skbs STATUS 0
  goto error
  set 0
  ret

error
  set 1
  ret
