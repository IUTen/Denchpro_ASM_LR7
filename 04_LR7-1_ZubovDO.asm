use16
org 100h

mov cx, 0
mov dx, file_creation
mov ah, 0x3c
int 21h
jc exit

mov bx, mbr_buff
call mbr_return

call dump
call exit
	
dump:
	pusha
	mov cx,32
	first_loop:
		push cx
		
		mov cx,16
		second_loop:			

			call element_getter
			call space
    			
			loop second_loop
		pop cx	
		call tail
		call eos
		loop first_loop

	popa
	jmp exit
	ret

element_getter:	
	push ax
	push dx
	push cx
	push es
	
	mov dl, byte[bx]
	and dl, 0xf0
	shr dl,4
	call get_ascii
	
	pusha
	mov bx, ax
    mov byte[ds:buff], dl
    mov cx, 1
    mov dx, buff
    mov ah, 0x40
    int 0x21
    popa

	mov dl, byte[bx]
	and dl, 0x0f
	call get_ascii
	
	pusha
	mov bx, ax
    mov byte[ds:buff], dl
    mov cx, 1
    mov dx, buff
    mov ah, 0x40
    int 0x21
    popa

	inc bx

	pop es
	pop cx
	pop dx
	pop ax
	ret

mbr_return:
	push ax
	push cx
	push dx	

	mov ah, 0x02
	mov al, 1	
	mov ch, 0	
	mov cl, 1	
	mov dh, 0	
	mov dl, 0x80
	int 13h
	jc exit

	pop dx
	pop cx
	pop ax	
	
	ret	


get_ascii:
  cmp dl,0x09   
  ja word_symbol  
  jmp digit_symbol

word_symbol:
  add dl,0x37
  ret

digit_symbol:
  add dl,0x30
  ret

exit:
	mov bx, ax
	mov ah, 3eh
	int 21h

	xor ax, ax
	mov ah, 0x4C
	int 21h

space:
	pusha

	mov bx, ax
    mov byte[ds:buff], " "             
    mov cx, 1
    mov dx, buff
    mov ah, 0x40
    int 0x21

    popa
	ret

tail:
	pusha
	sub bx, 16

	mov cx, 16
	loop1:
		mov dl, byte[bx]

		pusha
		mov bx, ax
    	mov byte[ds:buff], dl
		cmp dl, 0x20
		jb edit

		continue:
			mov cx, 1
			mov dx, buff
			mov ah, 0x40
			int 0x21
			popa

		inc bx

		loop loop1
	popa
	ret

edit:
	mov byte[ds:buff], "."
	jmp continue

eos:
    pusha

	mov bx, ax
   	mov byte[ds:buff], 0xA
   	mov cx, 1
    mov dx, buff
    mov ah, 0x40
    int 0x21

    popa
	ret

buff db ?
tail_buff db 2 dup(?)
mbr_buff db 512 dup(?)
file_creation db 'output.txt', 0
