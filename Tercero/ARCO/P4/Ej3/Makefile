LIBS =
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: trans_bucle1 trans_bucle2 trans_bucle3 trans_serie

trans_serie: trans_serie.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

trans_bucle1: trans_bucle1.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

trans_bucle2: trans_bucle2.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

trans_bucle3: trans_bucle3.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ trans_serie trans_bucle1 trans_bucle2 trans_bucle3
