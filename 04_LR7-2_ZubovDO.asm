use16
org 100h

call main
jmp exit

main:
	pusha

	reload:
	    call return_card
		cmp ebx,0
		je exit

	    mov si,buff
        add si, 7
		call dump
		
	    cmp ebx,0
	    jne reload
	popa
	ret
	
dump:
	pusha
	mov cx,20
	first_loop:

		call element_getter

        cmp cx, 5
        je calibration1
		cmp cx, 13
		je calibration2
    			
		loop first_loop

    call next_string

	popa
	ret

calibration1:
	call space

	add si,12

	loop first_loop
	
calibration2:
	call space

	add si,16

	loop first_loop

element_getter:	
	push ax
	push dx
	push cx

    mov ah, 0x02
	mov dl, byte[si]
	and dl, 0xf0
	shr dl, 4
	call get_ascii
    int 0x21

	mov dl, byte[si]
	and dl, 0x0f
	call get_ascii
    int 0x21

	dec si

	pop cx
	pop dx
	pop ax
	ret

return_card:
	push ax
	push ecx
	push edx	

    mov ax,0xe820
	mov ecx,20
	mov edx,0x534d4150
	mov di,buff
	int 15h		
	
	pop edx
	pop ecx
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
	xor ax, ax
	mov ah, 0x4C
	int 21h 

space:
    push ax
    push dx

	mov ah,02h
	mov dx,0x20
	int 21h

    pop dx
    pop ax
	ret

next_string:
    push ax
    push dx

	mov ah,0x09
	mov dx, space_temp
	int 21h

    pop dx
    pop ax
	ret

space_temp:
    db 0xd, 0xa, '$'

buff db 20 dup(?)