#include <pcap.h>
#include "practica1.h"

/*--------------------------------*/
/*VARIABLES GLOBALES*/
pcap_t *desc = NULL, *dead_desc = NULL;
pcap_dumper_t *pdumper=NULL;

int show_help() {
	fprintf(stdout, "MENSAJE DE AYUDA: \n\tpractica1 [N: numero de bytes a mostrar por paquete]\n\tpractica1 [N] [Traza a analizar]\n");
	return EXIT_OK;
}

int live_capture(int num){
	char file_name[NAME_SIZE];
	pcap_t;

	sprintf(file_name, "eth0.%lu.pcap", (unsigned long)time(NULL));



}

int pcap_analyze(int num, const char* trace){
	pcap_t *desc = NULL;
	char* errbuf = NULL;
	pcap_pkthdr *cabeceras = NULL;
	char *data = NULL;
	int ret = PCAP_OK;
	int print;
	
	desc = pcap_open_offline(trace, errbuf);
	if(!desc) return EXIT_ERROR;

	while(ret == PCAP_OK){
		ret = pcap_next_ex(desc, &cabeceras, (const u_char **)&data);
		print = print_N_bytes(num, data);
		if(print != EXIT_OK) ret = PCAP_ERROR;
	}

	if(ret == PCAP_ERROR){
		fprintf(stdout, "Se ha producido un error en la lectura.\n");
		return EXIT_ERROR;
	}

	else if(ret == PCAP_TIMEOUT){
		fprintf(stdout, "Timeout en la lectura.\n");
		return EXIT_ERROR;
	}




}

int print_N_bytes(int num, char* data){
	char* print = NULL;

	if(!data) return EXIT_ERROR;

	print = strcat()

}