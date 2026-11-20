; ECE 2031 L03_00
; Alina Zhu, Evelyn Wang, James Ferrolino, Patrick Brislin 

; Setup
Setup:
  Loadi 0
  Out Hex0 ;clear player scores
  Out Hex1 ;clear game clock
  Out LEDs ;turn off LEDs
  Out MasCmd ;Stop master channel
  Out SubCmd ;Stop all subchannels

  ;initilize player scores to zero
  Store Score1 
  Store Score2

  Loadi 10
  Out Master ;sets master tick to 10 ms
  
  
WaitForStart:
  In Switches
  Sub StartBit
  JNZ WaitForStart ;wait until only switch 9 is up for game to begin

InitilizeGame:
  Loadi 2 ;
  Out MasCmd ; resets master + sub-channel counts

  Loadi 300
  Out Sub1  ;Set Sub1 countdown to 3 seconds (10 ms tick * 300 = 3 seconds)
  Loadi 3
  Out Hex1  ;Show 3 on game clock

  Loadi 1
  Out SubCmd ;enables Sub1 to run, but waits for master
  Out MasCmd ;Start master and Sub1 at the same time

CountDown:
  In Sub1
  Call ConvertSeconds
  Out Hex1

  In Expiry
  And Sub1Done
  Jnz CountDone
  Jump CountDown

CountDone:
  Loadi 0
  Out SubCmd ;put Sub1 in stop state 
  Out Hex1   ;diplay 0 on game clock

  Loadi 2
  Out MasCmd ;resets master + sub-channel counts
  Jump StartGame


StartGame:
  Loadi GameDuration ;Set Sub1 countdown to 30 seconds (10 ms tick * 3000 = 3 seconds)
  Out Sub1

  Loadi 1
  Out SubCmd ;enables Sub1 to run, but waits for master
  Out MasCmd ;Start master and Sub1 at the same time
  Jump GameLoop


GameLoop:
  In Sub1
  Call ConvertSeconds
  Out Hex1 ;Displays game clock on left most Hex digits
  In Expiry
  And Sub1Done
  Jnz GameOver  ;Game will end once 30 seconds has gone by

----------------------------------------------------------------
;round logic goes here.

1. I haven't dealt with splitting up Hex0 clock
to use both for player 1 and player 2. 
2. I really just wrote the code up until game play. 
3. There is a game clock timer that is counting down from 30 that 
will be displayed on Hex1.
----------------------------------------------------------------


  Jump GameLoop
  

  
  

; Wait for Start

; Game

; Round

; False 

; Game End
GameOver:

;SubRoutines

;Used for countdowns -> inputed a value from AC in 10 ms ticks ; outputs value to AC in seconds 
ConvertSeconds:
  Store TicksRemaining ;store timer value
  Loadi 0
  Store Seconds ;Start Second count at 0

  ;Subtract 100 ticks (1 second) while adding 1 second to 'Seconds' 
  ;until less than 100 ticks remain, than round up using PartialSec
  ;routine
  ConvertLoop:
    Load TicksRemaining ;Load ticks to convert
    Jzero ConversionDone

    Addi -100 ;Subtract 100 ticks (1 sec)
    JNeg PartialSec ;if negative, less than 1 second remains 

    Store TicksRemaining
    Load Seconds 
    Addi 1 ;Increment 'Seconds' count
    Store Seconds
    Jump ConvertLoop ;repeat process until less than 100 ticks remain

  ;if less than 100 ticks remain round up
  PartialSec:
    Load Seconds
    Addi 1
    Return

  ConversionDone:
    Load Seconds
    Return
    


;; Variables
; Score
Score1:       DW  0
Score2:       DW  0

;Expiri flags
Sub1Done:     DW  1 

;ConvertSeconds sub routine
TicksRemaining: DW 0
Seconds:      DW  0   

;; Variables for Game start
StartBit:    		DW &B1000000000
GameDuration:   DW 3000



;; Addresses
; Existing Peripherals
Switches:       EQU 000     ; 0x00
LEDs:           EQU 001     ; 0x01
OldTimer:       EQU 002     ; 0x02
Hex0:           EQU 004     ; 0x04 ;Player 1 clock in upper two digits (Stopwatch) + Player 2 clock in lower 2 digits (Stopwatch)
Hex1:           EQU 005     ; 0x05 ;Game clock (countdown) (leftmost Hex
; Timer Peripheral   
Master:         EQU 112     ; 0x70 - Master Time/Tick-rate
Sub1:           EQU 113     ; 0x71 - Subch1 Time/Expiry-set
Sub2:           EQU 114     ; 0x72 - Subch2 Time/Expiry-set
Sub3:           EQU 115     ; 0x73 - Subch3 Time/Expiry-set
MasCmd:         EQU 116     ; 0x74 - Master Command/State
SubCmd:         EQU 117     ; 0x75 - Subchn Command/state
Expiry:         EQU 118     ; 0x76 - Expiry Flags
