;reut hakiki 209272251
;Netanel Shiri 315904714

;The program builds the game board like the proper step board
;which is a "snake". The plan is to upgrade the previous task here
;too we will check the appropriate steps in the board
;and check the correctness of the moves.
;If the step is correct and the resulting series is correct.
;The program takes the maximum number of moves and checks the
;minimum series of moves for the given board.
;If we were able to find the right series then
;we finishe successfully with the appropriate score
;and print the series and score we found,
;if we dont print -1 for the two parameters


includelib C:\Irvine\Irvine32.lib
INCLUDE C:\Irvine\Irvine32.inc
INCLUDE hw2_data.inc

.data
student_details1 BYTE "Reut Hakiki, ID: 209272251 ", 13, 10, 0
student_details2 BYTE "Netanel Shiri, ID: 315904714", 13, 10, 0
goodBoard BYTE LENGTHOF board dup(0),0
score DWORD 0
gamefin BYTE '0'
movenum BYTE 0
sizeBoard DWORD 0
endBoard DWORD 0
scoreMSG     BYTE "score		SDWORD  ",0     ;message input
movesMSG     BYTE "moveseries	SBYTE   ",0     ;message input
psikMSG      BYTE "';'" ,0
moveseries   BYTE LENGTHOF BOARD dup(1) , 0


.code
main PROC

	mov edx,OFFSET student_details1
	call WriteString
	mov edx,OFFSET student_details2
	call WriteString
	call CRLF
	push ecx		;uses all registers
	push OFFSET board
	movzx edx,numrows
	push edx
	movzx edx,numcols
	push edx
	call checkboard

	cmp eax,1
	JE print_error

	mov eax,0
	mov al,numrows
	mov bl,numcols
	mul bl
	mov sizeBoard,eax		;AX=numrows*numcols
startCopyBoard:				; the board 
    mov bl,numrows
	dec bl					 ;bl=numrow-1 =index
	mov eax,0
	mov al,numcols
	mul bl        ;ax=12
	mov ecx,OFFSET board	 ;ecx = כתובת ההתחלה של הלוח המקורי
	add ecx,eax
	mov eax,0				;current line in AH
	mov esi,0			

;create Board
	mov bl,0
	mov al,numcols	
	dec al					;al=numcols-1 ,bl=0
	mov edi,OFFSET goodBoard
continueright:
	mov dl,BYTE ptr [ecx]
	mov Byte ptr [edi],dl
	inc edi
	cmp bl,al
	je newrow
	add bl,1
	add ecx,1
	jmp continueright
newrow:
	inc ah
	mov ebx,0
	mov bl,numrows
	cmp ah,bl
	je startGame			;if i finish the goodBoard
	mov ebx,0
	mov bl,numcols
	sub ecx,ebx
	mov bl,0
	mov al,numcols 
	dec al					;al=numcols-1 ,bl=0
	movzx esi,ah
	rcr esi,1
	jc continueleft			;the number line is odd => left
	jmp continueright

continueleft:
	mov dl,BYTE ptr [ecx]
	mov Byte ptr [edi],dl
	inc edi
	cmp bl,al
	je newrow
	sub al,1
	sub ecx,1
	jmp continueleft

startgame:
push offset moveseries
push dword ptr nomoves
push offset goodboard
movzx eax , numrows
push eax
movzx eax , numcols
push eax
call findshortseries


endfunc:
    cmp eax , 0
	JE print_error

	push OFFSET moveseries
	push OFFSET goodBoard
	movzx edx,numcols
	push edx
	movzx edx,numrows
	push edx
	call writescore
	jmp print_success

	print_error:
	mov eax , -1
	mov moveseries , -1

	print_success:
	mov edx, OFFSET scoreMSG
	call writeString
	cmp eax, -1
	JNE print_positive
	call writeInt
	jmp continue_printing
	print_positive:
	call writeDec

	continue_printing:
	call CRLF
	mov edx, OFFSET movesMSG
	call writeString

	cmp eax , -1
	JNE continue_to_series

	call writeInt
	jmp end_of_everything

	continue_to_series:
	mov ecx , 0
	mov esi , offset moveseries

	print_series:
	
	cmp byte ptr [esi + ecx] , ';' 
	JE leave_print

	movzx eax , byte ptr [esi + ecx]
	call writeDec
	mov al , ','
	call writeChar

	inc ecx
	JMP print_series
	
	leave_print:

	mov edx , offset psikMSG
	call writeString
	call CRLF

	end_of_everything:


exit	
main ENDP

;This procedure accepts the board and the dimensions
;of the board and checks whether the board is OK
;and then returns at EAX 0 and otherwise 1.

checkboard PROC USES ESI EBX ECX EDX 

COLSfunc = 24
ROWSfunc = COLSfunc + 4
BOARDfunc = ROWSfunc + 4

push ebp
mov ebp, esp
mov ebx,0
mov eax,0
mov edx, [ebp + BOARDfunc]			;edx=board
mov bl,BYTE ptr [ebp + ROWSfunc]	;ebx=numrows
mov al,BYTE ptr [ebp + COLSfunc]	;eax=numcols
mul bl		
mov bx,ax	
dec bx								;bX=numcols*numrows -1
movzx ecx,bx						;ecx=counter
add edx,ecx
mov bl,BYTE ptr [ebp+ ROWSfunc]	
rcr bl,1
jc bRowsOdd
bRowsEven:
	rcl bl,1
	mov bx,1
	jmp tocount
bRowsOdd:
	rcl bl,1
	mov bx,WORD ptr [ebp+COLSfunc]			;eax=numcols
tocount:
inc ecx		;ecx=numcols*numrows
loopy:
cmp BYTE ptr [edx], 'E'	
	je EcheckproperBoard
cmp BYTE ptr [edx], 'S'
	je ScheckproperBoard
cmp BYTE ptr [edx] , 1
	jge continuedBoard
	jmp errorBoard
continuedBoard:
cmp BYTE ptr [edx] , 40
	jle properBoard
	jmp errorBoard

EcheckproperBoard:
	movzx eax,BYTE ptr [ebp+COLSfunc]		;eax=numcols
	sub edx,eax
	cmp BYTE ptr [edx], 'S'
	je errorboard
	add edx,eax
	jmp properBoard

ScheckproperBoard:
	movzx ebx,bx
	cmp ecx,ebx	;I'm at the end of the arr
	je errorboard
	movzx eax,BYTE ptr [ebp+COLSfunc]		;eax=numcols
	add edx,eax
	cmp BYTE ptr [edx], 'E'	
	je errorboard
	sub edx,eax
	jmp properBoard

properBoard:	
	sub edx,1
loop loopy
mov eax,0		;the board is proper
jmp end_func

errorboard:
	mov eax,1		;the board is not proper
	
end_func:
	mov esp,ebp
	pop ebp

	RET 12
checkboard ENDP

;This procedure accepts the board dimensions of
;the board and the maximum number of moves and
;returns the minimum series of moves that solves 
;the board if there is such a series we will return at EAX 0 and another 1

findshortseries PROC USES ESI EBX ECX

COLSfunc = 20
ROWSfunc = COLSfunc + 4
BOARDADD = ROWSFUNC + 4
MAXLEN = BOARDADD + 4
ARR = MAXLEN + 4


push ebp
mov ebp , esp

movzx ecx , byte ptr [ebp + MAXLEN]
mov esi , [ebp + ARR]
mov ebx , 1

byLen:          ;FOR MAX = 4 WILL LOOP 4 TIMES FOR EACH
				;LEN/OR UNTIL FOUND (6^1 + 6^2 + 6^3 + 6^4)

mov [esi+ebx-1], byte ptr 1
mov [esi+ebx], byte ptr ';'

	iterate_nextmove:


		push esi
		push [ebp + BOARDADD]
		push 4                  
		push 4
		call checkSolved
	
		NOT eax

		cmp eax , 0   ;found the series
		JNE found_series

		push esi
		push ebx
		call nextMove

		cmp eax,1
		JE iterate_big

	jmp iterate_nextmove

iterate_big:
inc ebx
loop byLen

natural_exit:     ;means loop ended naturally which is bad because series NOT_FOUND
mov eax,0
jmp leave_func

found_series:
mov eax,1

cmp ebx,[ebp + MAXLEN]
JE leave_func                ;perfect match (max length is shortest possible)

mov [esi + ebx] , byte ptr ';'

leave_func:
mov esp,ebp
pop ebp
ret 20
findshortseries ENDP

;This procedure accepts the array MOVES and its length
;and returns the next series of moves in line as explained
;in lexical order if this is the last series in the 
;lexical order we return in EAX 1 and another 0

nextMove PROC USES ESI ECX EBX

LEN = 20
ARR = LEN + 4

push ebp	     	    ;BASE
mov ebp,esp

mov ecx , [ebp + LEN]
mov esi , [ebp + ARR]

mov eax,0
mov ebx,0

mainloop:

iterate:
inc byte ptr [esi + ecx - 1]

cmp [esi+ecx-1],byte ptr 7
JNE endloop

mov [esi+ecx-1],byte ptr 1
inc ebx
loop mainloop


endloop:

cmp ebx , [ebp + LEN]
JNE justLeave

mov eax,1

justLeave:

mov esp,ebp
pop ebp
ret 8
nextMove ENDP

;This procedure accepts the board dimensions of the board 
;and a series of moves and checks whether the series
;solves the board then returns in EAX the score and otherwise -1

checkSolved PROC USES ESI EDI ECX EBX EDX

ROWSfunc = 28
COLSfunc = ROWSfunc + 4
BOARDfunc = COLSfunc + 4
MOVESfunc = BOARDfunc + 4

push ebp	     				  ;BASE
mov ebp,esp

StepsGame:						;goodBoard is complete
	mov ecx,OFFSET goodBoard    ; ecx = index of goodBoard
	mov endBoard, OFFSET goodBoard
	mov score,0
	mov eax,0
	mov al,numrows
	mov bl,numcols
	mul bl
	mov sizeBoard,eax			;AX=numrows*numcols
	mov ebx,sizeboard
	add endBoard,ebx			;OFFSET+ (numrows*numcols)
	mov bl,0					;bl = col index
	mov dl,0					;dl = row index
	mov edi,OFFSET moveseries    ; edi = כתובת ההתחלה של לוח הצעדים
	mov eax,0
	mov al,BYTE ptr [edi] 

checkingcol:
	cmp al, ';'
	je checkContinueBoard
	rcr dl,1
	jc dlodd
	rcl dl,1
	add bl,al
	cmp bl,numcols ;אם העמודה בטווח
	jb maybegoodcol
	sub bl,al
	mov ah,numcols
	sub ah,bl
	cmp ah,0
	je zero
	dec ah
	jmp zero
dlodd:
	rcl dl,1
	sub bl,al
	cmp bl,0 ;אם העמודה בטווח
	jge maybegoodcol
	add bl,al
	mov ah,bl  ;was numcols => bl
zero:
	sub al,ah
	cmp al,0
	jne equal
	mov al,numcols
	dec al
equal:
	inc dl		;inc row
	rcr dl ,1		;check if row odd or even
	jc oddrow
	dec al
	mov bl,0
	rcl dl,1
	jmp checkingcol
oddrow:
	rcl dl,1
	mov bl,numcols
	dec bl
	cmp al,0
	dec al
;noteven:
	sub bl,al
	jmp conti

maybegoodcol:

conti:
	cmp bl,0
	jae goodcol
	mov bl,0
	jmp checkingcol
	
goodcol:
	mov al,BYTE ptr [edi]
	mov ah,0
	add ecx, eax
	cmp ecx, endBoard				;if ecx >= OFFSET goodBoard + numrows*numcols
	jae errorLongWay
	cmp byte ptr [ecx] , 'E'
	je E
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

E:
	mov ah,numrows
	dec ah
	cmp dl, ah      
	je errorE					;error step
	mov ah, 0     
	rcr dl,1
	jc odd
	rcl dl,1
	inc dl
	mov bh, numcols
	dec bh
	sub bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	add ecx,esi
	cmp byte ptr [ecx] , 'E'
	je E
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not E and S not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

odd:
	rcl dl,1
	inc dl
	mov bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	add ecx,esi
	cmp byte ptr [ecx] , 'E'
	je E
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not E and S not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

errorE:
	mov score,2
	mov eax , -1
	jmp countMovesGame
	
S:
	cmp dl, 0
	je errorS					;error step
	rcr dl,1
	jc odd2
	mov bh,bl
	sal bh,1
	inc bh
	rcl dl,1
	dec dl
	movzx esi,bh
	sub ecx,esi
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not S and E not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

odd2:
	rcl dl,1
	dec dl
	mov bh, numcols
	dec bh
	sub bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	sub ecx,esi
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not S and E not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

errorS:
	mov score,1
	mov eax , -1
	jmp countMovesGame

countMovesGame:
	sub edi, OFFSET moveseries	;edi = num of moves
	inc edi
	jmp endfunc

checkContinueBoard:
	mov eax, endBoard
	dec eax
	cmp ecx, eax				;if ecx is exactly the last cell
	jb errorShortWay
	mov gamefin, '1'			;in the last cell
	sub edi, OFFSET moveseries	;edi = num of moves
	jmp endfunc

errorShortWay:
	mov score, 4
	sub edi, OFFSET moveseries	;edi = num of moves
	mov eax , -1
	jmp endfunc

errorLongWay:
	mov score, 3
	mov eax, -1
	jmp countMovesGame

endfunc:

cmp gamefin , '1'
JNE rly_leave

mov eax,0

rly_leave:

mov esi , offset movenum
mov [esi], edi
mov esp,ebp
pop ebp
ret 16

checkSolved ENDP

;This procedure accepts the board dimensions
;and the minimum number of moves and returns thescore
;for this series of moves, we return the score in EAX

writescore PROC USES ESI EDI ECX EBX EDX 
	
	
	ROWSfunc = 28
	COLSfunc = ROWSfunc + 4
	BOARDfunc = COLSfunc + 4
	MOVESfunc = BOARDfunc + 4
	
	push ebp
	mov ebp, esp  ;goodBoard is complete
	mov score,0
	mov ecx, [ebp + BOARDfunc]		 ; ecx = index of goodBoard
	mov bl,0						;bl = col index
	mov dl,0						;dl = row index
	mov edi, [ebp + MOVESfunc]      ;edi =   כתובת ההתחלה של לוח הצעדים המינמלית
	mov eax,0
	mov al,BYTE ptr [edi]  

checkingcol:
	cmp al, ';'
	je theEnd
	rcr dl,1
	jc dlodd
	rcl dl,1
	add bl,al
	cmp bl,[ebp + COLSfunc] ;אם העמודה בטווח
	jb maybegoodcol
	sub bl,al
	mov ah,[ebp + COLSfunc]
	sub ah,bl
	cmp ah,0
	je zero
	dec ah
	jmp zero
dlodd:
	rcl dl,1
	sub bl,al
	cmp bl,0 ;אם העמודה בטווח
	jge maybegoodcol
	add bl,al
	mov ah,bl  ;was numcols => bl
zero:
	sub al,ah
	cmp al,0
	jne equal
	mov al,[ebp + COLSfunc]
	dec al
equal:
	inc dl					;inc row
	rcr dl ,1				;check if row odd or even
	jc oddrow
	dec al
	mov bl,0
	rcl dl,1
	jmp checkingcol
oddrow:
	rcl dl,1
	mov bl,[ebp + COLSfunc]
	dec bl
	cmp al,0
	dec al
;noteven:
	sub bl,al
	jmp conti

maybegoodcol:

conti:
	cmp bl,0
	jae goodcol
	mov bl,0
	jmp checkingcol
	
goodcol:
	mov al,BYTE ptr [edi]
	mov ah,0
	add ecx, eax
	cmp byte ptr [ecx] , 'E'
	je E
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]  
	movzx esi,bh			
	add score,esi		
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

E:
	mov ah, 0     
	rcr dl,1
	jc odd
	rcl dl,1
	inc dl
	mov bh, [ebp + COLSfunc]
	dec bh
	sub bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	add ecx,esi
	cmp byte ptr [ecx] , 'E'
	je E
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not E and S not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

odd:
	rcl dl,1
	inc dl
	mov bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	add ecx,esi
	cmp byte ptr [ecx] , 'E'
	je E
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not E and S not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol
	
S:
	rcr dl,1
	jc odd2
	mov bh,bl
	sal bh,1
	inc bh
	rcl dl,1
	dec dl
	movzx esi,bh
	sub ecx,esi
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not S and E not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

odd2:
	rcl dl,1
	dec dl
	mov bh, [ebp + COLSfunc]
	dec bh
	sub bh,bl
	sal bh,1
	inc bh
	movzx esi,bh
	sub ecx,esi
	cmp byte ptr [ecx] , 'S'
	je S
	mov bh, byte ptr[ecx]
	movzx esi,bh
	add score,esi				;not S and E not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

theEnd:
	mov eax, score
	mov esp,ebp
	pop ebp
	RET 16
writescore ENDP


END main