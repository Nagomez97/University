;******************************************************************************* 
; Autores: José Ignacio Gómez García
;          Óscar Gómez Borzdynski
; Pareja 14
;*******************************************************************************

PRAC3B SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _calcularAciertos, _calcularSemiaciertos
ASSUME CS: PRAC3B

; unsigned int calcularAciertos(unsigned char* numSecreto, unsigned char* intentoDigitos);
; Donde unsigned int son 2 bytes (16bits)
; numSecreto y intentoDigitos son 4 unsigned char (1 byte)

_calcularAciertos PROC FAR

	PUSH BP
	MOV BP, SP ; Colocamos el puntero a pila como si estuviese vacia para esta funcion
	PUSH BX CX DX SI ES DS ; salvar registros a usar
	MOV BX, [BP + 6] ; recuperar datos (Offset de numSecreto)
	MOV AX, [BP + 8] ; recuperar datos (Segmento de numSecreto)
	MOV ES, AX ; Colocamos ES en el dato
	MOV SI, BX ; Colocamos SI en el vector
	MOV BX, [BP + 10] ; recuperar datos (Offset de intentoDigitos)
	MOV AX, [BP + 12] ; recuperar datos (Segmento de intentoDigitos)
	MOV DS, AX ; Colocamos DS en el dato

	MOV AX, 0 ; Ponemos el contador de aciertos a 0
	PUSH AX ; y lo guardamos en la pila

	MOV CX, 4 ; Contador a 4 porque es la cantidad de numeros a comparar

BUCLE: ; Bucle por elemento

	MOV AL, ES:[SI]
	MOV DL, DS:[BX]

	CMP AL, DL
	JNZ NEXT ; Si no son iguales 

	POP AX ; Sacamos el contador
	INC AX ; Lo aumentamos
	PUSH AX ; Lo volvemos a guardar

NEXT:
	INC SI ; Siguiente posicion
	INC BX

	DEC CX ; Si hemos acabado
	JNZ BUCLE

	POP AX ; Recuperamos el contador

	POP DS ES SI DX CX BX BP ;recuperar registros usados
	RET

_calcularAciertos ENDP

	
_calcularSemiaciertos PROC FAR

	PUSH BP
	MOV BP, SP ; Colocamos el puntero a pila como si estuviese vacia para esta funcion
	PUSH BX CX DX SI ES DS ; salvar registros a usar
	MOV BX, [BP + 6] ; recuperar datos (Offset de numSecreto)
	MOV AX, [BP + 8] ; recuperar datos (Segmento de numSecreto)
	MOV ES, AX ; Colocamos ES en el dato
	MOV SI, BX ; Colocamos SI en el vector
	MOV BX, [BP + 10] ; recuperar datos (Offset de intentoDigitos)
	MOV AX, [BP + 12] ; recuperar datos (Segmento de intentoDigitos)
	MOV DS, AX ; Colocamos DS en el dato

	MOV AX, 0 ; Ponemos el contador de aciertos a 0
	PUSH AX ; y lo guardamos en la pila

	MOV CX, 0 ; Empezamos en 0 (llegaremos hasta 3)

	DEC SI ; Precondiciones (Empezamos una posicion debajo para empezar sumando 1)

	PUSH SI

BUCLE1: ; Bucle por elemento del primer vector

	POP SI ; Recuperamos el SI que teniamos por argumentos

	INC SI ; Le sumamos uno
	
	MOV AL, ES:[SI] ; Guardamos un elemento en AL

	PUSH SI ; Guardamos SI

	MOV SI, 0 ; Lo ponemos a 0 para comenzar el vector

BUCLE2: ; Bucle por elemento del segundo vector

	CMP SI, CX ; Si estamos en el mismo elemento
	JZ PASS ; No lo comparamos

	MOV DL, DS:[BX][SI] ; Guardamos el elemento
	CMP DL, AL ; Comparamos los dos elementos
	JNZ PASS ; Si no son iguales continuamos comparando

	POP SI AX ; Recuperamos los datos guardados

	INC AX ; Incrementamos el contador de semiaciertos
	PUSH AX SI
	JMP CHECKEND ; Comprobamos si hemos acabado

PASS:

	INC SI ; Incrementamos el contador del segundo bucle
	CMP SI, 4 ; Si no hemos acabado seguimos iterando
	JNZ BUCLE2

CHECKEND:
	INC CX ; Aumentamos el contador de elementos del primer vector
	CMP CX, 4 ; Comparamos que no hayamos llegado al final
	JNZ BUCLE1

	POP SI AX ; Recuperamos el contador de semiaciertos

	POP DS ES SI DX CX BX BP ;recuperar registros usados
	RET

_calcularSemiaciertos ENDP

; unsigned int calcularSemiaciertos(unsigned char* numSecreto, unsigned char* intentoDigitos);


PRAC3B ENDS ; FIN DEL SEGMENTO DE CODIGO

END ; FIN DE pract3b.asm