;reut hakiki 209272251
;Netanel Shiri 315904714

;The program builds the game board like the proper step board
;which is a "snake". The program then takes a new step with each
;move and goes to the right place on the board.
;If we just got to the last slot and finished the set of steps then
;we finished successfully with the appropriate score.
;If not then we will end up in failure and given a suitable
;score for each failure.

;AL - Holds the next step.
;AH - Checks each time how many steps are left until
	;they reach the end of the current row.
;BL - Holds the current column index.
;ECX - Holds the address of the old BOARD array and then holds
	;the new array we created and advances each step we added.
;DL - Holds the current row index.
;ESI - serves as an auxiliary register with which the appropriate
	;score is added to the SCORE
;EDI - Holds the address of the step board and promotes it each
	;time to the next step.

includelib C:\Irvine\Irvine32.lib
INCLUDE C:\Irvine\Irvine32.inc
INCLUDE hw1_data.inc

.data
student_details1 BYTE "Reut Hakiki, ID: 209272251 ", 13, 10, 0
student_details2 BYTE "Netanel Shiri, ID: 315904714", 13, 10, 0
goodBoard BYTE LENGTHOF board dup(0),0
score DWORD 0
gamefin BYTE '0'
movenum BYTE 0
sizeBoard DWORD 0
endBoard DWORD 0
gamefinMSG   BYTE "gamefin		BYTE  ",0  ;message input
scoreMSG     BYTE "score		DWORD  ",0     ;message input
movesMSG     BYTE "movenum		WORD  ",0     ;message input

.code
main PROC
	mov edx,OFFSET student_details1
	call WriteString
	mov edx,OFFSET student_details2
	call WriteString
	mov eax,0
	mov al,numrows
	mov bl,numcols
	mul bl
	mov sizeBoard,eax	;AX=numrows*numcols
startCopyBorad:         ; the board 
    mov bl,numrows
	dec bl            ;bl=numrow-1 =index
	mov eax,0
	mov al,numcols
	mul bl        ;ax=12
	mov ecx,OFFSET board    ; ecx = כתובת ההתחלה של הלוח המקורי
	add ecx,eax
	mov eax,0			;current line in AH
	mov esi,0			

;create Board
	mov bl,0
	mov al,numcols	
	dec al			;al=3 ,bl=0
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
	je StepsGame		; if i finish the goodBoard
	mov ebx,0
	mov bl,numcols
	sub ecx,ebx
	mov bl,0
	mov al,numcols 
	dec al			;al=3 ,bl=0
	movzx esi,ah
	rcr esi,1
	jc continueleft		;the number line is odd => left
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

StepsGame:		;goodBoard is complete
	mov ecx,OFFSET goodBoard    ; ecx = index of goodBoard
	mov endBoard, OFFSET goodBoard
	mov ebx,sizeBoard
	add endBoard,ebx		;OFFSET+ (numrows*numcols)
	mov bl,0		;bl = col index
	mov dl,0			;dl = row index
	mov edi,OFFSET moves    ; edi = כתובת ההתחלה של לוח הצעדים
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
	je errorE		;error step
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
	add score,esi	;not E and S not legal =>its number
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
	add score,esi	;not E and S not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

errorE:
	mov score,2
	jmp countMovesGame
	
S:
	cmp dl, 0
	je errorS		;error step
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
	add score,esi	;not S and E not legal =>its number
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
	add score,esi	;not S and E not legal =>its number
	inc edi
	mov al, byte ptr [edi]
	jmp checkingcol

errorS:
	mov score,1
	jmp countMovesGame

countMovesGame:
	sub edi, OFFSET moves	;edi = num of moves
	inc edi
	jmp theEnd

checkContinueBoard:
	mov eax, endBoard
	dec eax
	cmp ecx, eax		;if ecx is exactly the last cell
	jb errorShortWay
	mov gamefin, '1'		;in the last cell
	sub edi, OFFSET moves	;edi = num of moves
	jmp theEnd

errorShortWay:
	mov score, 4
	sub edi, OFFSET moves	;edi = num of moves
	jmp theEnd

errorLongWay:
	mov score, 3
	jmp countMovesGame

theEnd:
call CRLF
	mov edx, OFFSET gamefinMSG
	call writeString
	mov al, gamefin
	call WriteChar
	call CRLF
	mov edx, OFFSET scoreMSG
	call writeString
	mov eax, score
	call WriteDec
	call CRLF
	mov edx, OFFSET movesMSG
	call writeString
	mov eax, edi
	call WriteDec


exit	
main ENDP

END main