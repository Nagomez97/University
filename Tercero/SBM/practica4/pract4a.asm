code segment
	assume cs:code
	org 100h
driver_start:
	jmp check_args
	;Variables del driver
	old_60h dw 0,0
	info_pareja DB "Grupo 2301, pareja 14: Jose Ignacio Gomez y Oscar Gomez.",13,10,'$'
	instalado DB "Driver instalado.",13,10,'$'
	no_instalado DB "Driver no instalado.",13,10,'$'
	desinstalado DB "Driver desinstalado.",13,10,'$'
	error_param DB "Error al introducir argumentos.",13,10,'$'

;Interfaz con el prog. residente
interfaz proc
	cmp ah,00h
	jne desinst
	call detectar
	jmp fin
desinst:
	cmp ah,01h
	jne cif
	call desinstalar
	jmp fin
cif:
	cmp ah,11h
	jne descif
	call cifrar
	jmp fin
descif:
	cmp ah,12h
	jne fin
	call descifrar
	jmp fin
fin:
	iret
interfaz endp 

; Cesar recibe el string en DS:DX y la clave en AL
cesar proc
	
	mov bx, dx
	mov ah, 02h
cifbuc:
	mov dl, [bx]
	inc bx
	cmp dl, '$'
	je ter ;Fin de cadena

	cmp dl, 20
	je printchar ;Imprimimos el espacio

spa:
	cmp dl, 60h ;minuscula
	ja minus

	;-- mayus
	add dl, al
	cmp dl, 5bh
	jb printchar
	sub dl, 26
	jmp printchar

minus:
	add dl, al
	cmp dl, 7bh
	jb printchar
	sub dl, 26
	jmp printchar

printchar:
	int 21h
	jmp cifbuc


ter: ;Imprimir salto de linea y salir
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h

	ret
cesar endp

; Nuestro numero de pareja es 14, por lo que usaremos el 17
cifrar proc
	push ax bx cx dx
	mov al, 17
	call cesar
	pop dx cx bx ax
	ret
cifrar endp

; Para descifrar se usa el 9 (26-17)
descifrar proc
	push ax bx cx dx
	mov al, 9
	call cesar
	pop dx cx bx ax
	ret
descifrar endp

desinstalar proc
	push ax
	push es
	xor ax,ax
	mov es,ax
	cli
	 ;Vector 60h
	mov ax,old_60h
	mov es:[60h*4],ax
	mov ax,old_60h+2
	mov es:[60h*4+2],ax
	sti
	mov es,cs:[2ch]
	mov ah,49h
	int 21h
	mov ax,cs
	mov es,ax
	mov ah,49h
	int 21h
	pop es
	pop ax
	ret
desinstalar endp

detectar proc
	mov ax, 0F0F0h
	ret
detectar endp

instalar proc
	xor ax,ax
	mov es,ax
	 cli
	mov ax,es:[60h*4]
	mov old_60h,ax
	mov ax,es:[60h*4+2]
	mov old_60h+2,ax
	mov es:[60h*4],offset interfaz
	mov es:[60h*4+2],cs
	sti

	; Tras instalarlo, imprimimos un aviso
	mov dx, offset instalado
    mov ah, 9
    int 21h

	mov dx,offset instalar
	int 27h
instalar endp

check_args proc

	xor dh, dh
	mov dl, es:[80h]
	cmp dx, 0
	jne hay_args

	;Sin argumentos, se muestra info de la pareja y estado del driver
	mov ax, 0
	mov es, ax
	cmp word ptr es:[60h*4], 0h
	jnz detectar_int
	cmp word ptr es:[60h*4+2], 0h
	je no_driver

detectar_int:
	mov ah, 00h
	int 60h
	cmp ax, 0F0F0h ; Comprobamos el fingerprint del driver
	jnz no_driver

	mov dx, offset instalado
    mov ah, 9
    int 21h	

    jmp print_info_pareja

no_driver:
	mov dx, offset no_instalado
    mov ah, 9
    int 21h

print_info_pareja:
	mov dx, offset info_pareja
    mov ah, 9
    int 21h

    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H

hay_args:

	cmp dx, 3
	jnz error_args


	mov cl, es:[82h] ;Leemos caracter a caracter
	cmp cl, '/'
	jnz error_args

	inc si
	mov cl, es:[83h]
	cmp cl, 'I'
	jz instalar_args
	cmp cl, 'D'
	jz desinstalar_args

	jmp error_args

instalar_args:

	mov ax, 0
	mov es, ax
	cmp word ptr es:[60h*4], 0h
	jnz detectar_int2
	cmp word ptr es:[60h*4+2], 0h
	je call_instalar

detectar_int2:
	mov ah, 00h
	int 60h
	cmp ax, 0F0F0h ; Comprobamos el fingerprint del driver
	jz ya_instalado ; Si el fingerprint coincide, ya esta instalado

call_instalar:
	call instalar

ya_instalado:
	mov dx, offset instalado
    mov ah, 9
    int 21h
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H

desinstalar_args:
	mov ah, 00h
	int 60h
	cmp ax, 0f0f0h
	jnz no_ya_instalado ; Si el fingerprint no coincide, no esta instalado

	call desinstalar

	mov dx, offset desinstalado
    mov ah, 9
    int 21h
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H


no_ya_instalado:
	mov dx, offset no_instalado
    mov ah, 9
    int 21h
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H

error_args:
	mov dx, offset error_param
    mov ah, 9
    int 21h
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H

check_args endp
code ends
end driver_start