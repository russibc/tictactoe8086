;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;										  ;;
;;			     ___   ___   ___    __                                ;;
;;			    / _ \ / _ \ / _ \  / /                                ;;
;;			   | (_) | | | | (_) |/ /_                                ;;
;;			    > _ <| | | |> _ <| '_ \                               ;;
;;			   | (_) | |_| | (_) | (_) |                              ;;
;;			    \___/ \___/ \___/ \___/                               ;;
;;										  ;;
;;	  _______ _____ _____ _______       _____ _______ ____  ______            ;;
;;	 |__   __|_   _/ ____|__   __|/\   / ____|__   __/ __ \|  ____|           ;;
;;	    | |    | || |       | |  /  \ | |       | | | |  | | |__              ;;
;;	    | |    | || |       | | / /\ \| |       | | | |  | |  __|             ;;
;;	    | |   _| || |____   | |/ ____ \ |____   | | | |__| | |____            ;;
;;	    |_|  |_____\_____|  |_/_/    \_\_____|  |_|  \____/|______|           ;;
;;										  ;;
;;			   _____          __  __ ______ 			  ;;
;;			  / ____|   /\   |  \/  |  ____|			  ;;
;;			 | |  __   /  \  | \  / | |__   			  ;;
;;			 | | |_ | / /\ \ | |\/| |  __|  			  ;;
;;			 | |__| |/ ____ \| |  | | |____ 			  ;;
;;			  \_____/_/    \_\_|  |_|______|			  ;;
;;										  ;;								      										              ;;
;;	 Copyright (C) 2017 Bruna Caroline Russi				  ;;
;;                                                                                ;;
;;       This program is free software: you can redistribute it and/or modify     ;;
;;       it under the terms of the GNU General Public License as published by     ;;
;;	 the Free Software Foundation, either version 3 of the License, or        ;;
;;	 (at your option) any later version.                                      ;;
;;                                                                                ;;
;;	 This program is distributed in the hope that it will be useful,          ;;
;;	 but WITHOUT ANY WARRANTY; without even the implied warranty of           ;;
;;	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            ;;
;;	 GNU General Public License for more details.                             ;;
;;                                                                                ;;
;;	 You should have received a copy of the GNU General Public License        ;;
;;	 along with this program.  If not, see <http://www.gnu.org/licenses/>.    ;;
;;                                                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA SEGMENT

	JUMP_LINE DB 13,10,"$"

	TICTACTOE_BOARD DB "---|---|---$"

	MSG_RESTART DB 13,10,"RESTART? Y (YES) / N (NO)$"
	MSG_BEGIN DB 13,10,"               .:: TIC TAC TOE ::.$"
	MSG_POS DB 13,10,"INSERT THE BOARD POSITION FOR YOUR PLAY:$"
	MSG_TIE DB 13,10,"IT WAS A TIE!$"
	MSG_VICTORY DB 13,10,"THE WINNER WAS: PLAYER $"
	MSG_ERROR1 DB 13,10,"YOU ALREADY CHOSE THAT! TRY AGAIN.$"
	MSG_ERROR2 DB 13,10,"INVALID CHARACTER! TRY AGAIN.$"
	MSG_TURN_PLAYER1 DB 13,10,"NOW IS PLAYER 1 TURN (X)!$"
	MSG_TURN_PLAYER2 DB 13,10,"NOW IS PLAYER 2 TURN (O)!$"

	GAME_COUNTER DB 9 DUP(0)
	PLAYER DB 0
	VICTORY DB 0

ENDS
STACK SEGMENT
	DW 128 DUP(0)
ENDS

CODE SEGMENT
START:

	MOV AX, DATA
	MOV DS, AX
	MOV ES, AX

	NEW_GAME:
	CALL INITIALIZE_TEMPLATE

	MOV PLAYER, 10B
	MOV VICTORY, 0
	MOV CX, 9

	RESTART:
		CALL GENERAL_PROC

		LEA DX, MSG_POS
		CALL SHOW

		MOV AL, PLAYER
		CMP AL, 1

		JE TURN_J2

		SHR PLAYER, 1
		LEA DX, MSG_TURN_PLAYER1
		CALL SHOW
		LEA DX, JUMP_LINE
		CALL SHOW
		JMP BREAK_TURNS

	TURN_J2:
		SHL PLAYER, 1
		LEA DX, MSG_TURN_PLAYER2
		CALL SHOW
		LEA DX, JUMP_LINE
		CALL SHOW

	BREAK_TURNS:
		CALL GUESS
		MOV DL, PLAYER
		CMP DL, 1

		JNE PLAY_PLAYER2
		MOV DL, "X"
		JMP CONT_MOV

	PLAY_PLAYER2:
		MOV DL, "O"
	CONT_MOV:
		MOV [BX], DL
		CMP CX, 5
		JG VERIFY_NEW_VICTORY
		CALL VERIFY_WON
		CMP VICTORY, 1
		JE WON
		VERIFY_NEW_VICTORY:
		LOOP RESTART

	 CALL GENERAL_PROC

	 LEA DX, MSG_TIE
	 CALL SHOW
	 LEA DX, JUMP_LINE
	 CALL SHOW
	 JMP SHOW_MSG_RESTART

	 WON:
	 CALL GENERAL_PROC

	 LEA DX, MSG_VICTORY
	 CALL SHOW
	 MOV DL, PLAYER
	 ADD DL, "0"
	 CALL SHOW_CHARACTER
	 LEA DX, JUMP_LINE
	 CALL SHOW

	SHOW_MSG_RESTART:
	 LEA DX, MSG_RESTART
	 CALL SHOW
	 LEA DX, JUMP_LINE
	 CALL SHOW
	 CALL READ_INPUT
	 CMP AL, "S"
	 JNE END_GAME
	 JMP NEW_GAME

	END_GAME:
	MOV AX, 4C00H
	INT 21H

GENERAL_PROC:
    CALL CLEAN_SCREEN
	LEA DX, MSG_BEGIN
	CALL SHOW
	LEA DX, JUMP_LINE
	CALL SHOW
	CALL SHOW_TEMPLATE
	CALL SHOW
	RET

SHOW_CHARACTER:
	MOV AH, 02H
	INT 21H
	RET

SHOW:
	MOV AH, 09H
	INT 21H
	RET

CLEAN_SCREEN:
	MOV AH, 0FH
	INT 10H
	MOV AH, 0H
	INT 10H
	RET

READ_INPUT:
	MOV AH, 01
	INT 21H
	RET

GUESS:
	CALL READ_INPUT
	CALL VERIFY_VALID
	CMP AH, 1
	JE VERIFY_POSITION_ALRDY_GSSD
	MOV DL, 0DH
	CALL SHOW_CHARACTER
	LEA DX, MSG_ERROR2
	CALL SHOW
	LEA DX, JUMP_LINE
	CALL SHOW
	JMP GUESS

	VERIFY_POSITION_ALRDY_GSSD:
	LEA BX, GAME_COUNTER
	SUB AL, "1"
	MOV AH, 0
	ADD BX, AX
	MOV AL, [BX]
	CMP AL, "9"
	JNG END_PALP
	MOV DL, 0DH
	CALL SHOW_CHARACTER
	LEA DX, MSG_ERROR1
	CALL SHOW
	LEA DX, JUMP_LINE
	CALL SHOW
	JMP GUESS
	END_PALP:
	LEA DX, JUMP_LINE
	CALL SHOW
	RET

INITIALIZE_TEMPLATE:
	LEA BX, GAME_COUNTER
	MOV AL, "1"
	MOV CX, 9
	INITIALIZE_PROX_TEMP:
	MOV [BX], AL
	INC AL
	INC BX
	LOOP INITIALIZE_PROX_TEMP
	RET

VERIFY_VALID:
	MOV AH, 0
	CMP AL, "1"
	JL END_GAMEISDIGIT
	CMP AL, "9"
	JG END_GAMEISDIGIT
	MOV AH, 1
	END_GAMEISDIGIT:
	RET

SHOW_TEMPLATE:
	LEA BX, GAME_COUNTER
	CALL SHOW_LINE
	LEA DX, TICTACTOE_BOARD
	CALL SHOW
	LEA DX, JUMP_LINE
	CALL SHOW
	CALL SHOW_LINE
	LEA DX, TICTACTOE_BOARD
	CALL SHOW
	LEA DX, JUMP_LINE
	CALL SHOW
	CALL SHOW_LINE
	RET

SHOW_LINE:

	MOV DL, " "
	CALL SHOW_CHARACTER
	MOV DL, [BX]
	CALL SHOW_CHARACTER
	MOV DL, " "
	CALL SHOW_CHARACTER
	MOV DL, "|"
	CALL SHOW_CHARACTER
	INC BX

	MOV DL, " "
	CALL SHOW_CHARACTER
	MOV DL, [BX]
	CALL SHOW_CHARACTER
	MOV DL, " "
	CALL SHOW_CHARACTER
	MOV DL, "|"
	CALL SHOW_CHARACTER
	INC BX

	MOV DL, " "
	CALL SHOW_CHARACTER
	MOV DL, [BX]
	CALL SHOW_CHARACTER
	INC BX

	LEA DX, JUMP_LINE
	CALL SHOW
	RET

VERIFY_WON:
	LEA SI, GAME_COUNTER
	CALL VERIFY_DIAG
	CMP VICTORY, 1
	JE BREAK_WON_VERIFY
	CALL VERIFY_LINES
	CMP VICTORY, 1
	JE BREAK_WON_VERIFY
	CALL VERIFY_COLUMNS
	BREAK_WON_VERIFY:
	RET

VERIFY_DIAG:

	MOV BX, SI
	MOV AL, [BX]
	ADD BX, 4
	CMP AL, [BX]
	JNE VERIFY_DIAGONAL_PLAY
	ADD BX, 4
	CMP AL, [BX]
	JNE VERIFY_DIAGONAL_PLAY
	MOV VICTORY, 1
	RET

VERIFY_LINES:

	MOV BX, SI
	MOV AL, [BX]
	INC BX
	CMP AL, [BX]
	JNE SEC_LINE
	INC BX
	CMP AL, [BX]
	JNE SEC_LINE
	MOV VICTORY, 1
	RET

	SEC_LINE:
	MOV BX, SI
	ADD BX, 3
	MOV AL, [BX]
	INC BX
	CMP AL, [BX]
	JNE THIRD_LINE
	INC BX
	CMP AL, [BX]
	JNE THIRD_LINE
	MOV VICTORY, 1
	RET

	THIRD_LINE:
	MOV BX, SI
	ADD BX, 6
	MOV AL, [BX]
	INC BX
	CMP AL, [BX]
	JNE END_VALID_LINES
	INC BX
	CMP AL, [BX]
	JNE END_VALID_LINES
	MOV VICTORY, 1
	END_VALID_LINES:
	RET

VERIFY_COLUMNS:

	MOV BX, SI
	MOV AL, [BX]
	ADD BX, 3
	CMP AL, [BX]
	JNE COLUMN_TWO
	ADD BX, 3
	CMP AL, [BX]
	JNE COLUMN_TWO
	MOV VICTORY, 1
	RET

	COLUMN_TWO:
	MOV BX, SI
	INC BX
	MOV AL, [BX]
	ADD BX, 3
	CMP AL, [BX]
	JNE COLUMN_THREE
	ADD BX, 3
	CMP AL, [BX]
	JNE COLUMN_THREE
	MOV VICTORY, 1
	RET

	COLUMN_THREE:
	MOV BX, SI
	ADD BX, 2
	MOV AL, [BX]
	ADD BX, 3
	CMP AL, [BX]
	JNE END_VERIFIC_COLUMNS
	ADD BX, 3
	CMP AL, [BX]
	JNE END_VERIFIC_COLUMNS
	MOV VICTORY, 1
	END_VERIFIC_COLUMNS:
	RET

VERIFY_DIAGONAL_PLAY:
	MOV BX, SI
	ADD BX, 2
	MOV AL, [BX]
	ADD BX, 2
	CMP AL, [BX]
	JNE END_VERIF_DIAG
	ADD BX, 2
	CMP AL, [BX]
	JNE END_VERIF_DIAG
	MOV VICTORY, 1
	END_VERIF_DIAG:
	RET

ENDS
END START
