# Compilador usado
CC = gcc

# Carpeta donde se encuentran las librerias desarrolladas por nosotros
SRCLIBDIR = srclib/
SRCDIR = src/
LIBDIR = lib/
INCDIR = includes/
TESTDIR = test/

# Flags de compilacion
CFLAGS_AUX = $(addprefix -I, $(INCDIR) $(TESTDIR))
CFLAGS = $(CFLAGS_AUX) -lpthread -lm -lrt -lconfuse -g -Wall -pedantic

#Modificamos los directorios de búsqueda para nuestro makefile
vpath %.c $(SRCDIR)
vpath %.c $(SRCLIBDIR)
vpath %.c $(TESTDIR)
vpath %.a $(LIBDIR)
vpath %.h $(INCDIR)

# Nombre de todos los ficheros de cabecera
INC = $(shell find $(INCDIR) -name '*.h' -printf "%P\n" | xargs)

# Lista de ejecutables a compilar
EXE_AUX = $(shell find $(SRCDIR) -name '*.c' -printf "%P\n" | xargs)
EXE = $(EXE_AUX:.c=) 

# Lista de ejecutables de pruebas
TEST_AUX = $(shell find $(TESTDIR) -name '*.c' -printf "%P\n" | xargs)
TEST = $(TEST_AUX:.c=)

# Nombres de las dependencias
LIBS_AUX = $(shell find $(SRCLIBDIR) -name '*.c' -printf "%P\n" | xargs)
LIBS = $(LIBS_AUX:.c=.a)

# Lista de dependencias a compilar
CLIBS = $(addprefix $(LIBDIR), $(LIBS))

# Realiza todas las acciones
all: test exec

# Compila solo los ejecutables principales
exec: $(EXE)

# Compila las librerias propias
libs: cleanlibs $(CLIBS)

#Compila los ejecutables de test
test: $(TEST)

#Compilacion de ejecutables
% : %.c $(CLIBS)
	@echo Creando el ejecutable $@
	@$(CC) $(CFLAGS) $^ -o $@ $(CFLAGS)
	@echo [OK]

#Compilacion de librerias
$(LIBDIR)%.a: %.c $(INC)
	@echo Compilando $< a $@
	@$(CC) -c $< $(CFLAGS) -o $@
	@echo [OK]

#Limpieza de ejecutables 
clean: 
	-rm $(EXE) $(TEST)

#Limpieza de librerias
cleanlibs: 
	-rm $(LIBDIR)*.a 

#Limpieza completa
cleanall: clean cleanlibs

#Ayuda del makefile
help:
	@echo "Opciones de este makefile:"
	@echo "all: Compila todo, tanto los ejecutables de entrega como los tests"
	@echo "exec: Compila solo los ejecutables de entrega"
	@echo "test: Compila solo los ejecutables de test"
	@echo "libs: Compila las librerias"
	@echo "clean: Borra los ejecutables (pero no las librerias)"
	@echo "cleanlibs: Borra las librerias"
	@echo "cleanall: Borra todo, ejecutables y librerias."
	@echo "help: Muestra la ayuda"