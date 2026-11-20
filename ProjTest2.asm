
LOADI 500       ; testing custom tick
OUT Master
LOADI 5
OUT Sub1
LOADI 10
OUT Sub2

LOADI 7
OUT SubCmd

Loop:   IN Switches     ; test master commands
        OUT MasCmd
        IN Sub3         ; test sub stopwatch output
        OUT Hex0
        IN Expiry       ; test flag output
        OUT LEDs
        JUMP Loop

Switches:  EQU 000 ; 0x00
LEDs:   EQU 001 ; 0x01
Hex0:   EQU 004 ; 0x04
Master: EQU 112 ; 0x70
Sub1:   EQU 113 ; 0x71
Sub2:   EQU 114 ; 0x72
Sub3:   EQU 115 ; 0x73
MasCmd: EQU 116 ; 0x74
SubCmd: EQU 117 ; 0x75
Expiry: EQU 118 ; 0x76
