.alias STATUS 1
.alias INTCON 2
.alias INTSTATUS 3

.alias KEY_SWITCH 8
.alias LEDS 9
.alias TIMER 10

.alias STATE 0x11
.alias DIRECTION 0x12

goto main

.org 4
goto isrService

main:
; enable interrupts
  set 0x03
  ior INTCON m
  set 0x80
  put STATUS
; setup the timer
  set 100
  put TIMER
; intialize variables
  clr STATE
  set 1
  put DIRECTION

loop:
  set 0x01
  sll STATE
  put LEDS
  goto loop

isrService:
  skbc INTSTATUS 0
  goto handleKeypress
  skbc INTSTATUS 1
  goto handleTimer
  retint

handleKeypress:
  ; check if KEY0 is pressed (= 0)
  skbc KEY_SWITCH 0
  retint
  goto changeState

handleTimer:
  ; reset the timer
  set 100
  put TIMER
  ; only change state on timer interrupt
  ; if SWITCH 0 is off
  skbc KEY_SWITCH 4
  retint

changeState:
  skbs DIRECTION 0
  goto countDown
countUp:
  ; add 1 to STATE
  set 1
  add STATE m
  ; check if STATE == 3
  set 3
  sub STATE
  sknez
  ; if it is, set DIRECTION to 0
  clr DIRECTION
  retint
countDown:
  ; subtract one from the state
  set -1
  add STATE m
  ; check if state is 0
  skeqz STATE
  retint
  ; if it is, set DIRECTION to 1
  set 1
  put DIRECTION
  retint
