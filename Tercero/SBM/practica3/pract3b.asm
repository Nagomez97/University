
PRAC3B SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _calcularAciertos
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


PRAC3B ENDS ; FIN DEL SEGMENTO DE CODIGO

END ; FIN DE pract3b.asm