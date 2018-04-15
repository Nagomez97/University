
PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _comprobarNumeroSecreto, _rellenarIntento
ASSUME CS: PRAC3A

; unsigned int comprobarNumeroSecreto(unsigned char* numero);
; Donde unsigned int son 2 bytes (16bits)
; numero son 4 unsigned char (1 byte)

_comprobarNumeroSecreto PROC FAR

	PUSH BP
	MOV BP, SP ; Colocamos el puntero a pila como si estuviese vacia para esta funcion
	PUSH BX CX DX SI ES ; salvar registros a usar
	MOV BX, [BP + 6] ; recuperar datos (Offset de numero)
	MOV AX, [BP + 8] ; recuperar datos (Segmento de numero)
	MOV ES, AX ; Colocamos ES en el dato

	MOV CX, 3 ; Contador a 3 porque es la cantidad de numeros a comparar
			  ; El ultimo no se compara (ya se habria comprobado)

BUCLE: ; Bucle por elemento
	MOV SI, CX
	MOV AL, ES:[BX][SI] ; Guardamos el elemento en AX

	MOV SI, 0 ; Inicializacion por el principio del vector

BUCLE2: ; Bucle para comprobacion

	MOV DL, ES:[BX][SI] ; 
	CMP DL, AL ; Si son iguales es que hay repetidos
	JZ HAYREPETIDOS

	INC SI
	CMP SI, CX ; Si estamos en el mismo elemento hemos acabado de comprobar
	JNZ BUCLE2

	DEC CX ; Si se hace cero seguir
	JNZ BUCLE

NOHAYREPETIDOS:
	MOV AX, 0
	JMP CONTINUE

HAYREPETIDOS:
	MOV AX, 1
	
CONTINUE:

	POP ES SI DX CX BX BP ;recuperar registros usados
	RET

_comprobarNumeroSecreto ENDP


; void rellenarIntento(unsigned int intento, unsigned char* intentoDigitos);
; Donde intento es un entero (2 bytes)
; intento digitos es donde se devuelve y tiene cuatro posiciones

_rellenarIntento PROC FAR

	PUSH BP
	MOV BP, SP ; Colocamos el puntero a pila como si estuviese vacia para esta funcion
	PUSH AX BX CX DX SI ES ; salvar registros a usar
	MOV BX, [BP + 8] ; recuperar datos (Offset de intentoDigitos)
	MOV SI, BX
	MOV AX, [BP + 10] ; recuperar datos (Segmento de intentoDigitos)
	MOV ES, AX ; Colocamos ES en el dato
	MOV AX, [BP + 6]; recuperar datos (intento)

	MOV CX, 4
	mov DL, 0

INIT: ; Bucle para inicializar el vector a ceros
	DEC CX
	MOV BX, CX
	MOV ES:[BX][SI], DL
	CMP CX, 0
	JNZ INIT

	MOV CX, 4 ; Posicion den el vector

DIVI: ; Bucle de division
	DEC CX
	MOV BX, 10
	MOV DX, 0
	DIV BX ; Dividimos AX entre 10 (AX será el cociente y DX el resto (al ser modulo 10 se quedara en DL))

	MOV BX, CX ; Nos colocamos en la posicion del vector
	MOV ES:[BX][SI], DL ; Guardamos el dato

	CMP CX, 0
	JZ SALIR

	CMP AX, 0 ; Comprobamos que no sea ya 0
  	JNZ DIVI

SALIR: 

	POP ES SI DX CX BX AX BP ;recuperar registros usados
	RET

_rellenarIntento ENDP

PRAC3A ENDS ; FIN DEL SEGMENTO DE CODIGO

END ; FIN DE pract3a.asm