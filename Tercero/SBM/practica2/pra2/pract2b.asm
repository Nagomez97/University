;******************************************************************************* 
; CALCULA LA CODIFICACION HAMMING EDAC
; Autores: José Ignacio Gómez García
;          Óscar Gómez Borzdynski
; Pareja 14
;*******************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

	MATRIZ  DB  1,0,0,0,  0,1,0,0,  0,0,1,0,  0,0,0,1,  1,1,0,1,  1,0,1,1,  0,1,1,1 ; MATRIZ TRASPUESTA
    RESULTADO  DB   7 DUP (?) ; RESULTADO DE LA MULTIPLICACION DE MATRIZ
    PARITY DB 7 DUP (?) ; ALMACENARA EL RESULTADO CON LOS BITS DE PARIDAD EN SU POSICION
    NEW_VECTOR DB 1,0,1,1 ; VECTOR DE ENTRADA (DATO DE LA MULTIPLICACION)
    ; STRINGS DE IMPRESION
    INPUT DB "INPUT: ",'$'
    OUTPUT DB "OUTPUT: ",'$'
    COMPUTATION DB "COMPUTATION:",13,10,'$'
    LINE DB 9,"| P1",9,"| P2",9,"| D1",9,"| P3",9,"| D2",9,"| D3",9,"| D4",13,10,'$'
    WRD_LINE DB 7 DUP ('?')
    P1_LINE DB 7 DUP (' ')
    P2_LINE DB 7 DUP (' ')
    P3_LINE DB 7 DUP (' ')
    WRD DB "WORD",9,'$'
    P1 DB "P1",9,'$'
    P2 DB "P2",9,'$'
    P3 DB "P3",9,'$'

DATOS ENDS 


; DEFINICION DEL SEGMENTO DE PILA 

PILA SEGMENT STACK "STACK" 
    DB   40H DUP (0) 
PILA ENDS 


; DEFINICION DEL SEGMENTO EXTRA 

EXTRA     SEGMENT  

	VECTOR  DB 4 DUP (?) ; AQUI ALMACENAMOS EL VECTOR
	
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
    
	;INICIALIZAMOS NUESTRO VECTOR
    
    ; RECIBIMOS EL VECTOR EN DX:BX
    MOV DH, NEW_VECTOR[0]
    MOV DL, NEW_VECTOR[1]
    MOV BH, NEW_VECTOR[2]
    MOV BL, NEW_VECTOR[3]
    ; POSTERIORMENTE ESTE CODIGO SERA SUSTITUIDO
    ; POR UNA ENTRADA DESDE TERMINAL	

    CALL MATMULT ; CALCULAMOS LA MULTIPLICACION

    CALL IMPRIMIR ; IMPRIME LOS DATOS

    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 

START ENDP 

;_______________________________________________________________ 
; SUBRUTINA PARA IMPRIMIR LOS RESULTADOS DE LA MULTIPLICACION
;_______________________________________________________________ 

IMPRIMIR PROC NEAR 

    ; PRIMERO COLCAMOS LOS BITS DE PARIDAD EN SU LUGAR
    MOV BX, 0
    MOV SI, 4
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 1
    MOV SI, 5
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 2
    MOV SI, 0
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 3
    MOV SI, 6
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 4
    MOV SI, 1
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 5
    MOV SI, 2
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    MOV BX, 6
    MOV SI, 3
    MOV AH, RESULTADO[SI]
    MOV PARITY[BX], AH
    ;_______________________________________________________________

    ; IMPRIMIMOS INPUT
    MOV DX, OFFSET INPUT
    MOV AH, 9
    INT 21H
    MOV CX, 4

    MOV SI, OFFSET NEW_VECTOR
    CALL PRINT_VECTOR

    ;_______________________________________________________________

    ; IMPRIMIMOS OUTPUT (PARITY) ORDENADO
    MOV DX, OFFSET OUTPUT
    MOV AH, 9
    INT 21H
    MOV CX, 7

    MOV SI, OFFSET PARITY
    CALL PRINT_VECTOR

    ;_______________________________________________________________

    ; IMPRIMIMOS COMPUTATION
    MOV DX, OFFSET COMPUTATION
    MOV AH, 9
    INT 21H

    ; IMPRIMIMOS LA PRIMERA LINEA
    MOV DX, OFFSET LINE
    INT 21H
    ;_______________________________________________________________

    ; RELLENAMOS WORD CON CODIGO ASCII
    MOV SI, 0
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 2
    MOV WRD_LINE[SI], BH 

    MOV SI, 1
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 4
    MOV WRD_LINE[SI], BH

    MOV SI, 2
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 5
    MOV WRD_LINE[SI], BH

    MOV SI, 3
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 6
    MOV WRD_LINE[SI], BH  

    ; IMPRIMIMOS LA SEGUNDA LINEA
    MOV DX, OFFSET WRD
    MOV AH, 9
    INT 21H

    MOV SI, OFFSET WRD_LINE
    CALL PRINT_LINE
    ;_______________________________________________________________

    ; RELLENAMOS P1 CON CODIGO ASCII
    MOV SI, 0
    MOV BH, PARITY[SI]
    ADD BH, 30H
    MOV SI, 0
    MOV P1_LINE[SI], BH 

    MOV SI, 0
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 2
    MOV P1_LINE[SI], BH

    MOV SI, 1
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 4
    MOV P1_LINE[SI], BH

    MOV SI, 3
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 6
    MOV P1_LINE[SI], BH  

    ; IMPRIMIMOS LA TERCERA LINEA
    MOV DX, OFFSET P1
    MOV AH, 9
    INT 21H

    MOV SI, OFFSET P1_LINE
    CALL PRINT_LINE
    ;_______________________________________________________________


    ; RELLENAMOS P2 CON CODIGO ASCII
    MOV SI, 1
    MOV BH, PARITY[SI]
    ADD BH, 30H
    MOV SI, 1
    MOV P2_LINE[SI], BH 

    MOV SI, 0
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 2
    MOV P2_LINE[SI], BH

    MOV SI, 2
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 5
    MOV P2_LINE[SI], BH

    MOV SI, 3
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 6
    MOV P2_LINE[SI], BH  

    ; IMPRIMIMOS LA CUARTA LINEA
    MOV DX, OFFSET P2
    MOV AH, 9
    INT 21H

    MOV SI, OFFSET P2_LINE
    CALL PRINT_LINE
    ;_______________________________________________________________


    ; RELLENAMOS P3 CON CODIGO ASCII
    MOV SI, 3
    MOV BH, PARITY[SI]
    ADD BH, 30H
    MOV SI, 3
    MOV P3_LINE[SI], BH 

    MOV SI, 1
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 4
    MOV P3_LINE[SI], BH

    MOV SI, 2
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 5
    MOV P3_LINE[SI], BH

    MOV SI, 3
    MOV BH, VECTOR[SI]
    ADD BH, 30H
    MOV SI, 6
    MOV P3_LINE[SI], BH  

    ; IMPRIMIMOS LA QUINTA LINEA
    MOV DX, OFFSET P3
    MOV AH, 9
    INT 21H

    MOV SI, OFFSET P3_LINE
    CALL PRINT_LINE
    ;_______________________________________________________________





    RET 
IMPRIMIR ENDP 

;_______________________________________________________________ 
; SUBRUTINA PARA IMPRIMIR UN VECTOR 
; ENTRADAS:
;   SI: OFFSET DEL VECTOR
;   CX: NUMERO DE ELEMENTOS DEL VECTOR
;_______________________________________________________________ 
PRINT_VECTOR PROC NEAR

PRINT:
    MOV AL, [SI]
    ADD AL, 30H ; TRANSFORMAMOS A ASCII
    MOV DL, AL
    MOV AH, 2H
    INT 21H

    INC SI

    DEC CX
    JNZ PRINT

    ; IMPRIMIMOS SALTO DE LINEA
    MOV DL, 13
    INT 21H

    MOV DL, 10
    INT 21H

    RET

PRINT_VECTOR ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA IMPRIMIR UNA LINEA
; ENTRADAS:
;   SI: OFFSET DE LA LINEA
;_______________________________________________________________ 
PRINT_LINE PROC NEAR

    MOV CX, 7
    MOV AH, 2H

PRINT_LOOP:
    MOV DL, '|'
    INT 21H

    MOV DL, ' '
    INT 21H

    MOV DL, [SI]
    INT 21H

    MOV DL, 9 ; TABULAMOS
    INT 21H

    INC SI

    DEC CX
    JNZ PRINT_LOOP

    ; IMPRIMIMOS SALTO DE LINEA
    MOV DL, 13
    INT 21H

    MOV DL, 10
    INT 21H

    RET

PRINT_LINE ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA MULTIPLICAR UN VECTOR POR UNA MATRIZ 
; ENTRADA DX:BX -> DATO (4 BYTES CORRESPONDIENTES AL VECTOR)
; SALIDA DX:AX -> RESULTADO (POSICION DE MEMORIA)
;_______________________________________________________________ 

MATMULT PROC NEAR 
    
    ; LO CARGAMOS EN VECTOR PARA FACILITAR ACCESO
    MOV VECTOR[0], DH
    MOV VECTOR[1], DL
    MOV VECTOR[2], BH
    MOV VECTOR[3], BL   

    MOV SI, 28 ; ITERA COLUMNAS

BUCLE1:

    MOV CX, 4 ; ITERA FILAS
    SUB SI, 4 ; SIGUIENTE COLUMNA
    MOV DX, 0 ; ALMACENA LA SUMA

BUCLE2:
	DEC CX ; SIGUIENTE ELEMENTO DE LA MATRIZ
	MOV BX, CX 
 	MOV AL, MATRIZ[BX][SI] ; CARGAMOS LA MATRIZ
 	MUL VECTOR[BX] ; MULTIPLICAMOS VECTOR X MATRIZ
 	ADD DX, AX ; ALMACENAMOS SUMANDO
 	CMP CX, 0
 	JNZ BUCLE2 ; BUCLE EN LA FILAS

 	MOV AX, SI
 	MOV BX, 04H
	DIV Bl ; DIVIDIMOS PARA INDEXAR EL RESULTADO, QUE ALMACENA COCIENTE EN AH, RESTO EN AL
	MOV BH, 1
    AND DL, BH ; RESULTADO MODULO 2
    MOV BX, AX
	MOV RESULTADO[BX], DL; ALMACENAMOS EL RESULTADO
 	CMP SI, 0
 	JNZ BUCLE1 ; BUCLE EN LAS COLUMNAS

FIN:
   	; SE DEVUELVE LA DIRECCION DE RESULTADO EN DX:AX
   	MOV DX, SEG RESULTADO
   	MOV AX, OFFSET RESULTADO
 
    RET 
MATMULT ENDP 

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 