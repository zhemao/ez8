.org 0
goto main

.org 5
main:
  get 0x08
  srll 4
  put 0x09
  goto main
