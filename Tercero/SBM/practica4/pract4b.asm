;******************************************************************************* 
; Autores: José Ignacio Gómez García
;          Óscar Gómez Borzdynski
; Pareja 14
;*******************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

    string DB 100,0,100 dup('$')
    string2 DB 100,0,100 dup('$')
    intro DB "Introduzca el string a codificar: $"
    cod DB "String codificado: $"
    intro2 DB "Introduzca el string a decodificar: $"
    decod DB "String decodificado: $"
    salto db 13,10,'$'
DATOS ENDS 


; DEFINICION DEL SEGMENTO DE PILA 

PILA SEGMENT STACK "STACK" 
    DB   40H DUP (0) 
PILA ENDS 


; DEFINICION DEL SEGMENTO EXTRA 

EXTRA     SEGMENT  	
EXTRA ENDS 


; DEFINICION DEL SEGMENTO DE CODIGO 

CODE    SEGMENT 
    ASSUME CS:CODE, DS:DATOS, ES: EXTRA, SS:PILA 

; COMIENZO DEL PROCEDIMIENTO PRINCIPAL 

START PROC 
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

    ;COMIENZO DEL PROGRAMA 
    mov ah, 09h
    mov dx, offset intro
    int 21h

    mov ah, 0ah
    mov dx, offset string
    int 21H

    mov ah, 09h
    mov dx, offset salto
    int 21h

    mov dx, offset cod
    int 21H

    mov dx, offset string
    add dx, 2
    mov ah, 11h
    int 60h

    mov ah, 09h
    mov dx, offset salto
    int 21h

    mov dx, offset intro2
    int 21h

    mov ah, 0ah
    mov dx, offset string2
    int 21H

    mov ah, 09h
    mov dx, offset salto
    int 21h

    mov dx, offset decod
    int 21H

    mov dx, offset string2
    add dx, 2
    mov ah, 12h
    int 60h

    mov ah, 09h
    mov dx, offset salto
    int 21h

    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 

START ENDP 

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 