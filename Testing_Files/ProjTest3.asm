
LOADI 500       ; testing custom tick
OUT Master
LOADI 7
OUT SubCmd
LOADI 25      ; test if custom tick functionality checks run states. Tick rate will be VERY FAST if fail 
OUT Master
LOADI 5
OUT Sub1
LOADI 10
OUT Sub2

LOADI 7
OUT SubCmd

Loop:   IN Switches     ; test all commands
        ADDI -512
        JPOS SkipSC     ; does not write sub-commands if sw9 is up
        JZERO SkipSC
        IN Switches
        OUT SubCmd      ; sub-commands on lower 6 switches
SkipSC: SHIFT -6
        OUT MasCmd      ; main commands on sw6/7
        IN Sub3         ; Sub3 in left hex display
        OUT Hex1
        IN Sub2         ; Sub2 in middle hex display
        SHIFT 8
        STORE OutMem
        IN Sub1         ; Sub1 in right hex display
        AND Mask
        ADD OutMem
        OUT Hex0
        IN MasCmd       ; test run state
        SHIFT 6
        STORE OutMem
        IN SubCmd
        ADD OutMem
        OUT LEDs
        JUMP Loop

OutMem:	   DW   0
Mask:      DW	&H00FF

Switches:       EQU 000         ; 0x00
LEDs:           EQU 001         ; 0x01
Hex0:           EQU 004         ; 0x04
Hex1:           EQU 005         ; 0x05
Master:         EQU 112         ; 0x70
Sub1:           EQU 113         ; 0x71
Sub2:           EQU 114         ; 0x72
Sub3:           EQU 115         ; 0x73
MasCmd:         EQU 116         ; 0x74
SubCmd:         EQU 117         ; 0x75
Expiry:         EQU 118         ; 0x76
