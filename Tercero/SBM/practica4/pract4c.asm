code segment
	assume cs:code
	org 100h
driver_start:
	jmp check_args
	;Variables del driver
	old_60h dw 0,0
	old_70h dw 0,0
	info_pareja DB "Grupo 2301, pareja 14: Jose Ignacio Gomez y Oscar Gomez.",13,10,'$'
	instalado DB "Driver instalado.",13,10,'$'
	no_instalado DB "Driver no instalado.",13,10,'$'
	desinstalado DB "Driver desinstalado.",13,10,'$'
	error_param DB "Error al introducir argumentos.",13,10,'$'
	fincadena DB 0 ;Flag para fin de cadena
	clave DB 0 ; Clave para cesar

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
	jne stop
	call descifrar
	jmp fin
stop:
	cmp ah,13h
	jne fin
	call stopinterrupciones
fin:
	iret
interfaz endp 

; Rutina RTC
rutina_rtc proc far
	push bx cx dx ax
	sti

	;Leer el registro C del RTC
	mov al,0Ch
	out 60,al
	in al,71h

	cmp fincadena, 1 ;Flag para fin de cadena
	je rutina_rtc_fin

	pop ax dx
	call cesar
	inc dx
	push dx ax

rutina_rtc_fin:
	;Enviar el EOI al PIC esclavo
	mov al,20h
	out 0A0h,al
	;Enviar el EOI al PIC maestro
	out 20h,al
	pop ax dx cx bx
	iret
rutina_rtc endp

; Cesar recibe el string en DS:DX y la clave en clave
cesar proc
	
	mov al, clave
	mov bx, dx
	mov ah, 02h

	mov dl, [bx]
	cmp dl, '$'
	je ter ;Fin de cadena

	cmp dl, 20
	je printchar ;Imprimimos el espacio

	cmp dl, 13
	je printchar

	cmp dl, 10
	je printchar

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
	ret

ter: ;Salir
	mov fincadena, 1
	ret
cesar endp

; Nuestro numero de pareja es 14, por lo que usaremos el 17
cifrar proc
	mov clave, 17
	mov fincadena, 0
	ret
cifrar endp

; Para descifrar se usa el 9 (26-17)
descifrar proc
	mov clave, 9
	mov fincadena, 0
	ret
descifrar endp

stopinterrupciones proc
	;Programar PIC esclavo deshabilitando interrupciones del RTC
	in al,0a1h
	or al,00000001b
	out 0a1h,al

	;Desactivar el PIE del RTC
	mov al,0bh
	out 70h,al
	in al,71h
	and al, 10111111b
	out 71h,al

	ret
stopinterrupciones endp

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

	mov ax,old_70h
	mov es:[70h*4],ax
	mov ax,old_70h+2
	mov es:[70h*4+2],ax
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
	mov es:[60h*4+2], cs

	mov ax,es:[70h*4]
	mov old_70h,ax
	mov ax,es:[70h*4+2]
	mov old_70h+2,ax
	mov es:[70h*4],offset rutina_rtc
	mov es:[70h*4+2],cs
	sti

	;Programar PIC esclavo habilitando interrupciones del RTC
	in al,0a1h
	and al,11111110b
	out 0a1h,al

	;Programar frecuencia del RTC
	mov al,0ah
	out 70h,al
	mov al, 00101111b ;(sabemos que son 2 Hz, pero no sabemos hacerlo de un solo hercio)
	out 71h,al

	;Activar el PIE del RTC
	mov al,0bh
	out 70h,al
	in al,71h
	or al,01000000b
	out 71h,al

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