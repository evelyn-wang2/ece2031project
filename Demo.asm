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
                     
                     
WaitForStart:        CALL IncrementRNG
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
                     Load GameDuration ;Set Sub1 countdown to 30 seconds (10 ms tick * 3000 = 30 seconds)
                     Out Sub1
                     
                     Loadi 1
                     Out SubCmd ;enables Sub1 to run, but waits for master
                     Out MasCmd ;Start master and Sub1 at the same time
                     Jump NewRound

; new round/wait
NewRound:            Loadi 0
                     Out LEDs ;Turn off Led
                     Loadi &B00000010001     ; reset Sub2 
                     Out SubCmd
                     CALL GenerateRandomDelay
                     Out Sub2 ; Output to 2nd subtimer
                     Loadi &B00000000011 ; run Sub1 and sub2
                     Out SubCmd
WaitForLed:          Call IncrementRNG
                     Call ClockCheck ;if game is over, ac won't equal zero
                     Jnz GameOver
                     ;check for false starts
                     In Switches        ; read player switches; if either is high, jump to falsestart
                     And BothMask
                     JNZ FalseStart
                     ;check if random delay timer for led is up
                     In Expiry
                     And Sub2Done
                     Jzero WaitForLed

; round start
LedUp:
                     ;Led goes up 
                     Loadi &B0000001000  ;led3  used for gameplay
                     Out LEDs
                     ;reset round values to zero
                     Loadi 0
                     Store Done1 ;reset to zero for each round
                     Store Done2 
                     ;substopwatches for player 1 and player 2 reset and begin
                     Loadi 0    ; revert Sub2 to stopwatch
                     Out Sub2
                     Loadi &B00000110001
                     Out SubCmd
                     Loadi &B00000000111 ;run sub1,sub2,sub3
                     Out SubCmd

; round loop
Round:               Call IncrementRNG
                     Call ClockCheck ;Check to make sure game clock hasn't expired
                     JNZ GameOver   

                     ;Player 1
                     Load Done1     ; check if p1 is done, jump to p2 check (P1Done) if so
                     Jnz P1Done
                     In Switches        ; check if switch is up yet
                     And Player1Mask
                     Jzero P1Done       ; if switch not up yet, check p2
                     In SubCmd          ; read current run bits (Sub3, Sub2, Sub1)
                     And StopSub2Mask   ; clear Sub2's run bit, leave Sub1/Sub3 as they are
                     Out SubCmd         ; pause Sub2 -> p1 stopwatch holds its time
                     Loadi 1 ;if player 1 raises switch, set Done1 to 1
                     Store Done1            
P1Done:              ;Player 2
                     Load Done2    ; check if p2 is done, jump to round check (CheckRound) if so
                     Jnz CheckRound
                     In Switches    ; check if switch is up yet
                     And Player2Mask 
                     Jzero CheckRound   ; if not up yet, skip Done2
                     In SubCmd          ; read current run bits (Sub3, Sub2, Sub1)
                     And StopSub3Mask   ; clear Sub3's run bit, leave Sub1/Sub2 as they are
                     Out SubCmd         ; pause Sub3 -> p2 stopwatch holds its time
                     Loadi 1 ;if player 2 raises switch, set Done2 to 1
                     Store Done2
CheckRound:          Call ShowPlayersTime ; shows/updates times on hex
                     Load Done1
                     And Done2
                     Jzero Round ;check if both have raised sw, otherwise loop
                     ;Jump RoundFinished ;if both raised, round over   ; note: may not be necessary rn since RoundFinished is right after?

; round finish
RoundFinished:
                    ; add this round's scores (Sub2/Sub3 are paused, so they hold each player's time)
                    In Sub2
                    Call Stop255
                    Add Score1
                    Store Score1
                    In Sub3
                    Call Stop255
                    Add Score2
                    Store Score2
                    Loadi 0 
                    Out MasCmd   ;pause game clock
WaitForNRound:      Call IncrementRNG
                    In Switches         ; wait for both switches to go down
                    And BothMask
                    JNZ WaitForNRound
                    Loadi 1
                    Out MasCmd   ;resume game clock
                    Jump NewRound


FalseStart: 
                     Loadi 0
                     Out MasCmd ;keep game clock running, stop p1 and p2 clock
                     Jump PenaltyCheckP1    ; checks which player had false start

GameOver:            Loadi 0
                     Out SubCmd ; stop all subchannels
                     Out MasCmd ; stop master 
                     Loadi &B1111111111
                     Out LEDs ; turn on all LEDs
; Displays each player score for 3s then shows winner.
ScoreDisplay:        Loadi 2 ;reset master and subchannels
                     Out MasCmd
                     Loadi 300 ; initialize a 3s timer on Sub1 and start. (after reset)
                     Out Sub1
                     Loadi 1 ; run sub1
                     Out SubCmd
                     Out MasCmd
                     Loadi 1 ; display p1 score
                     Out Hex1
                     Load Score1
                     Out Hex0
                     Call Wait1
                     Loadi 8 ; reset 3s timer for p2 score
                     Out SubCmd
                     Loadi 300
                     Out Sub1
                     Loadi 1
                     Out SubCmd ; start Sub1
                     Loadi 2 ; display p2 score
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
                     Loadi 2 ; p2 win - accumulator = 2 
EndScoreDisp:        Out Hex1 ; display accumulator on hex1
                     Loadi 0
                     Out MasCmd
                     Out SubCmd
                     Jump WaitForRelease
Win1:               Loadi 1 ; p1 win - accumulator = 1
                    Jump EndScoreDisp
Win0:               Loadi 0
                    Jump EndScoreDisp ; tie - accumulator = 0
Wait1:               In Expiry ; wait until subchannel 1 expires
                     And Sub1Done
                     JZero Wait1
                     Return 

WaitForRelease: ; wait for switch 9 to go down before allowing another game
                     In Switches
                     And StartBit
                     JNZ WaitForRelease
                     Jump Setup ; clear scores, wait for another start

                            
;SubRoutines
ShowPlayersTime:
                      In Sub2        ; player 1 stopwatch (running, or paused once p1 responds)
                      Call Stop255
                      Shift 8        ; player 1 in upper two digits
                      Store HexTmp
                      In Sub3        ; player 2 stopwatch
                      Call Stop255
                      Add HexTmp     ; player 2 in lower two digits
                      Out Hex0
                      Return

;make sure player clocks to leak into eachother
;Highest hex digit on 2 nibbles is 255 (0xff)
Stop255:
                      Store StopTmp
                      Addi -255              
                      JPos Above255
                      Load StopTmp
                      Return

Above255:             Loadi 255               
                      Return

PenaltyCheckP1: 
                     In Switches
                     And Player1Mask
                     Jzero PenaltyCheckP2 ; checks p2 if p1 is not the false start
                     Load Score1
                     Addi 300 ;if player 1 false started, add 300 to score
                     Store Score1
                     Load Player1Mask
                     Out LEDs
                     ;Jump PenaltyCheckP2 ; maybe not needed since they are back-to-back
PenaltyCheckP2:      In Switches
                     And Player2Mask
                     Jzero WaitForNRound
                     Load Score2
                     Addi 300 ;if player 2 false started, add 300 to score
                     Store Score2
                     Load Player2Mask
                     Out LEDs
                     Jump WaitForNRound

;check game clock 
ClockCheck:          
                     Call PauseCheck
                     In Sub1
                     Call ConvertSeconds
                     Out Hex1 ;Displays game clock on left most Hex digits
                     In Expiry
                     And Sub1Done
                     Return

;check if game is paused
PauseCheck:          
                     In Switches
                     And StartBit
                     Jnz Running ;if sw9 is up, that means its running
                     Jump Pause
Pause:
                     Loadi 0
                     Out MasCmd ;pause master, which pauses all channels
                     Call IncrementRNG
                     In Switches 
                     And StartBit
                     Jzero Pause ;if equal to zero -> SW9 is down, so repeat loop
                     Jump Running ; if sw9 is up, resume game
Running:      
                     Loadi 1
                     Out MasCmd
                     Return

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
                     
                     
; Increases RNG counter by 1 every time it is called. Will be v. rapid because of 10MHz clock
IncrementRNG: 
                     Load RNG
                     Addi 1
                     Store RNG
                     Return
                     
; Generates random delay
GenerateRandomDelay: 
                     Load RNG
                     And &B00011111111 ; keep 8 low bits (value 0-255)
                     Addi 100          ; add 100 -> random time between 1.00s and 3.55s
                     Store DelayTicks
                     Return
                     
                     
                     
;; Variables
; Score
Score1: DW 0
Score2: DW 0
BaseGain: DW 300
Done1:  DW 0
Done2:  DW 0
StopTmp: DW 0
HexTmp:  DW 0 ; used by ShowPlayersTime to combine both times
StopSub2Mask: DW &B101 ; SubCmd run bits with Sub2 cleared (pause p1 stopwatch)
StopSub3Mask: DW &B011 ; SubCmd run bits with Sub3 cleared (pause p2 stopwatch)
                     
; RNG value
RNG: DW 0
DelayTicks: DW 0
                     
;Expiry flags
Sub1Done: DW 1 ; Sub1 expiry flah
Sub2Done: DW 2 ; Sub2 expiry flah
Player1Mask: DW 64 ; SW6
Player2Mask: DW 1 ; SW0
BothMask:    DW 65 ; SW6 + SW0
                     
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
                     
                     
