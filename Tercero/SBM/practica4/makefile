#******************************************************************************* 
# Autores: José Ignacio Gómez García
#          Óscar Gómez Borzdynski
# Pareja 14
#*******************************************************************************

all: pract4a.com pract4b.exe pract4c.exe

pract4a.com: pract4a.obj
	tlink /v /t pract4a

pract4a.obj: pract4a.asm
	tasm /zi pract4a.asm

pract4b.exe: pract4b.obj
 	tlink /v pract4b

pract4b.obj: pract4b.asm
 	tasm /zi pract4b.asm

pract4c.exe: pract4c.obj
	tlink /v pract4c

pract4c.obj: pract4c.asm
	tasm /zi pract4c.asm