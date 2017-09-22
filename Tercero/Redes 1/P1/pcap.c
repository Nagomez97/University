#include <pcap.h>
#include "practica1.h"

int show_help() {
	fprintf(stdout, "MENSAJE DE AYUDA: \n\tpractica1 [N: numero de bytes a mostrar por paquete]\n\tpractica1 [N] [Traza a analizar]\n");
	return 0;
}

int live_capture(int num){

}

int pcap_analyze(int num, char* trace){
	pcap_t *desc = NULL;
	int n = atoi(num);


}