.ORG    0
JMP	ENTRY
VAR1	.BSC 0x0001
VAR2	.BSC 0xFFFF
STACK	.BSS 32
ENTRY:		LHI	$0, 0
		WWD	$0	; TEST #1-1 : LHI (= 0x0000)
		LHI	$1, 0
		WWD	$1	; TEST #1-2 : LHI (= 0x0000)
		LHI	$2, 0
		WWD	$2	; TEST #1-3 : LHI (= 0x0000)
		LHI	$3, 0
		WWD	$3	; TEST #1-4 : LHI (= 0x0000)

		ADI	$0, $1, 1 ; #2b
		WWD	$0	; TEST #2-1 : ADI (= 0x0001)
		ADI	$0, $0, 1 ; #2d
		WWD	$0	; TEST #2-2 : ADI (= 0x0002)

		ORI	$1, $2, 1
		WWD	$1	; TEST #3-1 : ORI (= 0x0001)
		ORI	$1, $1, 2
		WWD	$1	; TEST #3-2 : ORI (= 0x0003)
		ORI	$1, $1, 3
		WWD	$1	; TEST #3-3 : ORI (= 0x0003)

		ADD	$3, $0, $2
		WWD	$3	; TEST #4-1 : ADD (= 0x0002)
		ADD	$3, $1, $2
		WWD	$3	; TEST #4-2 : ADD (= 0x0003)
		ADD	$3, $0, $1
		WWD	$3	; TEST #4-3 : ADD (= 0x0005)

		SUB	$3, $0, $2
		WWD	$3	; TEST #5-1 : SUB (= 0x0002)
		SUB	$3, $2, $0
		WWD	$3	; TEST #5-2 : SUB (= 0xFFFE)
		SUB	$3, $1, $2
		WWD	$3	; TEST #5-3 : SUB (= 0x0003)
		SUB	$3, $2, $1
		WWD	$3	; TEST #5-4 : SUB (= 0xFFFD)
		SUB	$3, $0, $1
		WWD	$3	; TEST #5-5 : SUB (= 0xFFFF)
		SUB	$3, $1, $0
		WWD	$3	; TEST #5-6 : SUB (= 0x0001)

		AND	$3, $0, $2
		WWD	$3	; TEST #6-1 : AND (= 0x0000)
		AND	$3, $1, $2
		WWD	$3	; TEST #6-2 : AND (= 0x0000)
		AND	$3, $0, $1
		WWD	$3	; TEST #6-3 : AND (= 0x0002)

		ORR	$3, $0, $2
		WWD	$3	; TEST #7-1 : ORR (= 0x0002)
		ORR	$3, $1, $2
		WWD	$3	; TEST #7-2 : ORR (= 0x0003)
		ORR	$3, $0, $1
		WWD	$3	; TEST #7-3 : ORR (= 0x0003)

		NOT	$3, $0
		WWD	$3	; TEST #8-1 : NOT (= 0xFFFD)
		NOT	$3, $1
		WWD	$3	; TEST #8-2 : NOT (= 0xFFFC)
		NOT	$3, $2
		WWD	$3	; TEST #8-3 : NOT (= 0xFFFF)

		TCP	$3, $0
		WWD	$3	; TEST #9-1 : TCP (= 0xFFFE)
		TCP	$3, $1
		WWD	$3	; TEST #9-2 : TCP (= 0xFFFD)
		TCP	$3, $2
		WWD	$3	; TEST #9-3 : TCP (= 0x0000)

		SHL	$3, $0
		WWD	$3	; TEST #10-1 : SHL (= 0x0004)
		SHL	$3, $1
		WWD	$3	; TEST #10-2 : SHL (= 0x0006)
		SHL	$3, $2
		WWD	$3	; TEST #10-3 : SHL (= 0x0000)

		SHR	$3, $0
		WWD	$3	; TEST #11-1 : SHR (= 0x0001)
		SHR	$3, $1
		WWD	$3	; TEST #11-2 : SHR (= 0x0001)
		SHR	$3, $2
		WWD	$3	; TEST #11-3 : SHR (= 0x0000)

		LWD	$0, $2, VAR1        ; 6b
		WWD	$0	; TEST #12-1 : LWD (= 0x0001)
		LWD	$1, $2, VAR2        ; 6d
		WWD	$1	; TEST #12-2 : LWD (= 0xFFFF)

		SWD	$1, $2, VAR1        ; 6F
		SWD	$0, $2, VAR2        ; 70

		LWD	$0, $2, VAR1        ; 71
		WWD	$0	; TEST #13-1 : WWD (= 0xFFFF)
		LWD	$1, $2, VAR2        ; 73
		WWD	$1	; TEST #13-2 : WWD (= 0x0001) ;74

		JMP	JMP0
JMP0:		WWD	$0	; TEST #14-1 : JMP (= 0xFFFF) ;76
		JMP	JMP1
		HLT
JMP1:		WWD	$1	; TEST #14-2 : JMP (= 0x0001) ;79

		BNE	$2, $3, BNE1 ;7a
		JMP	BNE2
BNE1:		HLT
BNE2:		WWD	$0	; TEST #15-1 : BNE (= 0xFFFF) ;7d

		BNE	$1, $2, BNE3 ;7e
		HLT              ;7f
BNE3:		WWD	$1	; TEST #15-2 : BNE (= 0x0001) ;80

		BEQ	$1, $2, BEQ1        ;81
		JMP	BEQ2                ;82
BEQ1:		HLT
BEQ2:		WWD	$0	; TEST #16-1 : BEQ (= 0xFFFF) ;84

		BEQ	$2, $3, BEQ3        ;85
		HLT
BEQ3:		WWD	$1	; TEST #16-2 : BEQ (= 0x0001) ;87

		BGZ	$0, BGZ1            ;88
		JMP	BGZ2                ;89
BGZ1:		HLT
BGZ2:		WWD	$0	; TEST #17-1 : BGZ (= 0xFFFF) ;8b

		BGZ	$1, BGZ3
		HLT
BGZ3:		WWD	$1	; TEST #17-2 : BGZ (= 0x0001)

		BGZ	$2, BGZ4
		JMP	BGZ5
BGZ4:		HLT
BGZ5:		WWD	$0	; TEST #17-3 : BGZ (= 0xFFFF)

		BLZ	$0, BLZ1
		HLT                     ; #94
BLZ1:		WWD	$1	; TEST #18-1 : BLZ (= 0x0001) ; #95

		BLZ	$1, BLZ2            ; #96
		JMP	BLZ3 	; #97
BLZ2:		HLT
BLZ3:		WWD	$0	; TEST #18-2 : BLZ (= 0xFFFF)

		BLZ	$2, BLZ4
		JMP	BLZ5                ;9b
BLZ4:		HLT                 ;9c
BLZ5:		WWD	$1	; TEST #18-3 : BLZ (= 0x0001) ;9d

		JAL	SIMPLE1 ; #9e
		WWD	$0	; TEST #19-1 : JAL & JPR (= 0xFFFF)

		JAL	SIMPLE2 ; #a0
		HLT
		WWD	$1	; TEST #19-2 : JAL & JPR (= 0x0001)

		LHI	$3, 0
		ORI	$3, $3, STACK

		LHI	$0, 0
		ADI	$0, $0, 5
		JAL	FIB	; #a7
		WWD	$0	; TEST #19-3 : JAL & JPR (= 0x0008)

		JMP	PREFIB1	; #a9
PREFIB2:	ADI	$1, $2, 0
		JRL	$1				   ; #ab
		WWD	$0	; TEST #20 : JAL & JRL & JPR (= 0x0022)

		HLT		; FINISHED #ad

SIMPLE2:	ADI	$2, $2, 1 ; #ae
SIMPLE1:	JPR	$2	  ; #af
		HLT

PREFIB1:	JAL	PREFIB2

FIB:		ADI	$1, $0, -1 ; #b2
		BGZ	$1, FIBRECUR ;#b3
		LHI	$0, 0
		ORI	$0, $0, 1
		JPR	$2	; #b6
		HLT
FIBRECUR:	SWD	$2, $3, 0 ; #b8
		SWD	$0, $3, 1     ; #b9
		ADI	$3, $3, 2     ; #ba
		ADI	$0, $0, -2
		JAL	FIB	; #bc
		LWD	$1, $3, -1
		SWD	$0, $3, -1
		ADI	$0, $1, -1
		JAL	FIB                 ; #c0
		LWD	$1, $3, -1
		LWD	$2, $3, -2          ; #c2
		ADD	$0, $0, $1
		ADI	$3, $3, -2
		JPR	$2 ; #c5
		HLT
	.END
