all: pract2a.exe pract2b.exe prueba.exe

pract2a.exe: pract2a.obj
	tlink /v pract2a

pract2a.obj: pract2a.asm
	tasm /zi pract2a.asm

pract2b.exe: pract2b.obj
	tlink /v pract2b

pract2b.obj: pract2b.asm
	tasm /zi pract2b.asm

prueba.exe: prueba.obj
	tlink /v prueba

prueba.obj: prueba.asm
	tasm /zi prueba.asm