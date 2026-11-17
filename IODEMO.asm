LOADI 3
OUT MasCmd

Loop:   IN Master
        OUT Hex0
        JUMP Loop


Hex0:   EQU 004 ; 0x04
Master: EQU 112 ; 0x70
Sub1:   EQU 113 ; 0x71
Sub2:   EQU 114 ; 0x72
Sub3:   EQU 115 ; 0x73
MasCmd: EQU 116 ; 0x74
SubCmd: EQU 117 ; 0x75
Expiry: EQU 118 ; 0x76