; ECE 2031 L03_00
; Alina Zhu, Evelyn Wang, James Ferrolino, Patrick Brislin 

; Setup

; Wait for Start

; Game

; Round

; False 

; Game End



;; Variables
; Score
Score1:       DW  0
Score2:       DW  0

;; Addresses
; Existing Peripherals
Switches:       EQU 000     ; 0x00
LEDs:           EQU 001     ; 0x01
OldTimer:       EQU 002     ; 0x02
Hex0:           EQU 004     ; 0x04
Hex1:           EQU 005     ; 0x05
; Timer Peripheral
Master:         EQU 112     ; 0x70 - Master Time/Tick-rate
Sub1:           EQU 113     ; 0x71 - Subch1 Time/Expiry-set
Sub2:           EQU 114     ; 0x72 - Subch2 Time/Expiry-set
Sub3:           EQU 115     ; 0x73 - Subch3 Time/Expiry-set
MasCmd:         EQU 116     ; 0x74 - Master Command/State
SubCmd:         EQU 117     ; 0x75 - Subchn Command/state
Expiry:         EQU 118     ; 0x76 - Expiry Flags