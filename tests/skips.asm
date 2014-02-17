.org 0
goto main

.org 5
main:
  set 0
  skeqz
  goto error
  set 1
  sknez
  goto error
  skgtz
  goto error
  skgez
  goto error
  set -1
  skltz
  goto error
  put 0x21
  sklez 0x21
  goto error
  set 0
  ret

error:
  set 1
  ret
