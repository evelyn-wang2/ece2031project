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
                
                
WaitForStart:   Load RNG ; iterate RNG before start (for first game)
                Addi 1      ; TODO: REPLACE WITH RNG SUBROUTINE!!!
                Store RNG
                In Switches
                Sub StartBit
                JNZ WaitForStart ;wait until only switch 9 is up for game to begin
                
InitilizeGame: 
                Loadi 2 ;
                Out MasCmd ; resets master + sub-channel counts
                
                Loadi 300
                Out Sub1 ;Set Sub1 countdown to 3 seconds (10 ms tick * 300 = 3 seconds)
                Loadi 3
                Out Hex1 ;Show 3 on game clock
                
                Loadi 1
                Out SubCmd ;enables Sub1 to run, but waits for master
                Out MasCmd ;Start master and Sub1 at the same time
                
CountDown: 
                In Sub1 
                Call ConvertSeconds
                Out Hex1 ;Display countdown in seconds on left-most hex
                
                In Expiry
                And Sub1Done
                Jnz CountDone ;Once countdown is finished, jump to 'CountDone'
                Jump CountDown ;Otherwise repeat
                
CountDone: 
                Loadi 0
                Out SubCmd ;put Sub1 in stop state 
                Out Hex1 ;diplay 0 on game clock
                
                Loadi 2
                Out MasCmd ;resets master + sub-channel counts
                Jump StartGame
                
                
StartGame: 
                Load GameDuration ;Set Sub1 countdown to 30 seconds (10 ms tick * 3000 = 3 seconds)
                Out Sub1
                
                Loadi 1
                Out SubCmd ;enables Sub1 to run, but waits for master
                Out MasCmd ;Start master and Sub1 at the same time
                Jump GameLoop
                
NewRound:       Load RNG                ; Load random timer
                And RNGMask             ; mask to max 5.11s
                Out Sub2                ; Output to 2nd subtimer
                Loadi &B00000010011     ; Reset Sub2, run Sub1 and sub2
                Out SubCmd
; TODO: Pre-LED behavior - false start penalty
; TODO: On-LED behavior - Light up on Sub2 expiry, reset/start subtimers (don't forget to set Sub2 back to stopwatch!!!)
; TODO: Post-LED behavior - stop corresp. subtimer on switch high
; TODO: Post-Response behavior - add subtimer value to each player score
; NOTE: probably ideal if RNG incremented during Pre-LED and Post-LED TODOs (these are likely to have loops where we can put the RNG increment) 

GameLoop:       In Switches ; pause mechanism
                And StartBit
                Shift -9 
                Out MasCmd
                In Sub1
                Call ConvertSeconds
                Out Hex1 ;Displays game clock on left most Hex digits
                In Expiry
                And Sub1Done
                Jnz GameOver ;Game will end once 30 seconds has gone by
                

                ;----------------------------------------------------------------
                ;round logic goes here.
                
                ;1. I haven't dealt with splitting up Hex0 clock
                ;to use both for player 1 and player 2. 
                ;2. I really just wrote the code up until game play. 
                ;3. There is a game clock timer that is counting down from 30 that 
                ;will be displayed on Hex1.
                ;----------------------------------------------------------------
                
                
                Jump GameLoop
                
GameOver: 
                Loadi 0
                Out SubCmd ; stop all subchannels
                Out MasCmd ; stop master 
                Out LEDs ; turn off LEDs

; Displays each player score for 3s then shows winner.
ScoreDisplay:   Loadi 300   ; initialize a 3s timer on Sub1 and start.
                Out Sub1
                Loadi &B00000111001
                Out SubCmd
                Loadi &B00000000011
                Out MasCmd
                Loadi 1     ; display p1 score
                Out Hex1
                Load Score1
                Out Hex0
                Call Wait1
                Loadi &B00000111100 ; reset 3s timer for p2 score
                Out SubCmd
                Loadi 2     ; display p2 score
                Out Hex1
                Load Score2
                Out Hex0
                Call Wait1
                Loadi 0 ; Shows winner on Hex1, 0 on Hex0
                Out Hex0
                Load Score1 
                Sub Score2  
                JNeg Win1
                JZero Win0
                Loadi 2             ; p2 win - accumulator = 2
EndScoreDisp:   Out Hex1            ; display accumulator on hex1
                Jump WaitForRelease
Win1:           Loadi 1             ; p1 win - accumulator = 1
                Jump EndScoreDisp
Win0:           Loadi 0
                Jump EndScoreDisp   ; tie - accumulator = 0

Wait1:          In Expiry ; wait until subchannel 1 expires
                Addi -4
                JNZ Wait1
                Return                
                
WaitForRelease: ; wait for switch 9 to go down before allowing another game
                In Switches
                And StartBit
                JNZ WaitForRelease
                Jump Setup ; clear scores, wait for another start
                
                ; Wait for Start
                
                ; Game
                
                ; Round
                
                ; False 
                
                ; Game End
                
                
                
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
Score1: DW 0
Score2: DW 0
BaseGain: DW 300

; RNG value
RNG:        DW 0
RNGMask:    DW &B0000000111111111 ; limits RNG to within 5.11 secs

                ;Expiri flags
Sub1Done: DW 1 
                
                ;ConvertSeconds sub routine
TicksRemaining: DW 0
Seconds: DW 0 
                
                ;; Variables for Game start
StartBit: DW &B1000000000
GameDuration: DW 3000
                
                
                
                ;; Addresses
                ; Existing Peripherals
Switches: EQU 000 ; 0x00
LEDs: EQU 001 ; 0x01
OldTimer: EQU 002 ; 0x02
Hex0: EQU 004 ; 0x04 ;Player 1 clock in upper two digits (Stopwatch) + Player 2 clock in lower 2 digits (Stopwatch)
Hex1: EQU 005 ; 0x05 ;Game clock (countdown) (leftmost Hex
                ; Timer Peripheral 
Master: EQU 112 ; 0x70 - Master Time/Tick-rate
Sub1: EQU 113 ; 0x71 - Subch1 Time/Expiry-set
Sub2: EQU 114 ; 0x72 - Subch2 Time/Expiry-set
Sub3: EQU 115 ; 0x73 - Subch3 Time/Expiry-set
MasCmd: EQU 116 ; 0x74 - Master Command/State
SubCmd: EQU 117 ; 0x75 - Subchn Command/state
Expiry: EQU 118 ; 0x76 - Expiry Flags
                