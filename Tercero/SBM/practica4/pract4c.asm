;******************************************************************************* 
; Autores: José Ignacio Gómez García
;          Óscar Gómez Borzdynski
; Pareja 14
;*******************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 
	old_60h dw 0,0
	old_70h dw 0,0
	info_pareja DB "Grupo 2301, pareja 14: Jose Ignacio Gomez y Oscar Gomez.",13,10,'$'
	instalado DB "Driver instalado.",13,10,'$'
	no_instalado DB "Driver no instalado.",13,10,'$'
	desinstalado DB "Driver desinstalado.",13,10,'$'
	error_param DB "Error al introducir argumentos.",13,10,'$'
	instruccion DB "Introduzca una instruccion: ",'$'
	instruccion_leida DB 9,0, 9 dup('$')
	string DB 100,0, 100 dup('$')
	introduzca DB "Introduzca String: $"
	resultado DB "Resultado: $"
	fincadena DB 0 ;Flag para fin de cadena
	clave DB 0 ; Clave para cesar
	flag_act DB 0
	fin db "fin"
	cod db "code"
	salto db 13,10,'$'
	decode db "decode"
DATOS ENDS 

; DEFINICION DEL SEGMENTO DE PILA 

PILA SEGMENT STACK "STACK" 
    DB   40H DUP (0) 
PILA ENDS 


EXTRA 	SEGMENT  	
EXTRA ENDS 

CODE SEGMENT
    ASSUME CS:CODE, DS:DATOS, ES:EXTRA, SS:PILA 


main proc
	;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 
    MOV AX, DATOS 
    MOV DS, AX 

    MOV AX, PILA 
    MOV SS, AX 

    MOV AX, EXTRA 
    MOV ES, AX 

    ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO 
    MOV SP, 64 

    ; FIN DE LAS INICIALIZACIONES

	call instalar

buc_main:
	mov ah, 09h
	mov dx, offset instruccion
	int 21H

	mov ah, 0ah
	mov dx, offset instruccion_leida
	int 21h

	add dx, 2
	call check_ins

	mov ah, 09h
    mov dx, offset salto
    int 21h

	cmp al, 3
	je fin_main
	cmp al, 4
	je buc_main

	call string_ini

	mov ah, 09h
	mov dx, offset introduzca
	int 21H

	mov ah, 0ah
	mov dx, offset string
	int 21h

	mov ah, 09h
    mov dx, offset salto
    int 21h

	mov ah, 09h
	mov dx, offset resultado
	int 21H

	mov dx, offset string
	add dx,2
	cmp al, 1
	je code_main

	call descifrar
	mov ah, 09h
    mov dx, offset salto
    int 21h
	jmp buc_main

code_main:
	call cifrar
	mov ah, 09h
    mov dx, offset salto
    int 21h
	jmp buc_main

fin_main:
	call desinstalar
	; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 
main endp

; Rutina RTC
rutina_rtc proc far
	push bx cx dx ax
	sti

	;Leer el registro C del RTC
	mov al, 0Ch
	out 70h,al
	in al, 71h

	mov flag_act, 1

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

	mov bx, dx
	mov al, clave

bucle_infinito:
	cmp flag_act, 1
	jne bucle_infinito

	mov flag_act, 0

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
	mov ah, 02h
	int 21h
	inc bx
	jmp bucle_infinito

ter: ;Salir
	ret
cesar endp

; Nuestro numero de pareja es 14, por lo que usaremos el 17
cifrar proc
	mov clave, 17
	call cesar
	ret
cifrar endp

; Para descifrar se usa el 9 (26-17)
descifrar proc
	mov clave, 9
	call cesar
	ret
descifrar endp

desinstalar proc
	push ax
	push es

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

	xor ax,ax
	mov es,ax
	cli

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
	push es
	xor ax,ax
	mov es,ax

	cli
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
	mov al, 00101111b ;(sabemos que son 2 Hz, pero nose puede a un solo hercio)
	out 71h,al

	;Activar el PIE del RTC
	mov al,0bh
	out 70h,al
	in al,71h
	or al,01000000b
	out 71h,al
	pop es
    ret
instalar endp

; REcibe en DS:DX, Devuelve en al:
; 1 si es code
; 2 si es decode
; 3 si es fin
; 4 si error
check_ins proc
	push cx dx bx si
	mov bx, dx
	mov si, 0

strcmpfin:
	mov cl, fin[si]
	mov ch, [bx]
	cmp cl, ch
	jne strcmpcodeini
	inc bx
	inc si
	cmp si, 3
	jne strcmpfin
	mov al, 3
	jmp finn

strcmpcodeini:
	mov bx, dx
	mov si, 0

strcmpcode:
	mov cl, cod[si]
	mov ch, [bx]
	cmp cl, ch
	jne strcmpdecodeini
	inc bx
	inc si
	cmp si, 4
	jne strcmpcode
	mov al, 1
	jmp finn

strcmpdecodeini:
	mov bx, dx
	mov si, 0

strcmpdecode:
	mov cl, decode[si]
	mov ch, [bx]
	cmp cl, ch
	jne error
	inc bx
	inc si
	cmp si, 6
	jne strcmpdecode
	mov al, 2
	jmp finn

error: 
	mov al, 4
	pop si bx dx cx
	ret

finn:
	pop si bx dx cx
	ret

check_ins endp

string_ini proc
	push bx
	mov bx, 2

string_ini_buc:
	mov string[bx], '$'
	inc bx
	cmp bx, 102
	jne string_ini_buc

	pop bx	
	ret
string_ini endp

CODE ENDS
END main