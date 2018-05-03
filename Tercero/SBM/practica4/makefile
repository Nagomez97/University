all: pract4a.com pract4b.exe pract4c.com

pract4a.com: pract4a.obj
	tlink /v /t pract4a

pract4a.obj: pract4a.asm
	tasm /zi pract4a.asm

pract4b.exe: pract4b.obj
 	tlink /v pract4b

pract4b.obj: pract4b.asm
 	tasm /zi pract4b.asm

pract4c.com: pract4c.obj
	tlink /v /t pract4c

pract4c.obj: pract4c.asm
	tasm /zi pract4c.asm
# prueba.exe: prueba.obj
# 	tlink /v prueba

# prueba.obj: prueba.asm
# 	tasm /zi prueba.asm