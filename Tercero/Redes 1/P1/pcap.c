/**
* file pcap.c
* author Jose Ignacio Gomez, Óscar Gómez
* date 22/09/17
*/
#include <pcap.h>
#include "practica1.h"
#include <netinet/in.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <signal.h>
#include <time.h>

/*************************************/
/*VARIABLES GLOBALES*/
pcap_t *desc = NULL, *descr2
 = NULL;
pcap_dumper_t *pdumper=NULL;
int contador = 0;
char file_name[NAME_SIZE];
/**************************************/


/*************************************/
/*FUNCIONES INTERNAS*/

/***************************************************************
Nombre:
    print_N_bytes
Descripcion:
    función para imprimir los N primeros bytes de un paquete
Entrada:
    int num: número de bytes a mostrar por paquete, tiene que ser positivo.
    char* data: datos del paquete
Salida:
    int, EXIT_ERROR en caso de error
************************************************************/
int print_N_bytes(int num, char* data){
	char print[num];
	int i;

	if(!data) return EXIT_ERROR;

	for(i=0; i<num; i++){
		print[i] = data[i];
	}

	fprintf(stdout, "Nuevo paquete: \n\t%s\n", print);

	return EXIT_OK;

}

/***************************************************************
Nombre:
    show_help
Descripcion:
    Muestra la ayuda en pantalla
Entrada:
    none
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/
int show_help() {
	fprintf(stdout, "MENSAJE DE AYUDA: \n\tpractica1 [N: numero de bytes a mostrar por paquete]\n\tpractica1 [N] [Traza a analizar]\n");
	return EXIT_OK;
}


/***************************************************************
Nombre:
    handle
Descripcion:
    handler para parar la ejecución del live capture
Entrada:
    int signal: señal recibida
Salida:
    void
************************************************************/
void handle(int nsignal){
	printf("Control C pulsado\n");
	if(desc)
		pcap_close(desc);
	if(descr2)
		pcap_close(descr2);
	if(pdumper)
		pcap_dump_close(pdumper);
	fprintf(stdout, "Se han capturado %d paquetes en el archivo %s", contador, file_name);
	exit(EXIT_OK);
 }

/***************************************************************
Nombre:
    live_capture
Descripcion:
    Captura en vivo los paquetes de la interfaz eth0
Entrada:
    int num: número de bytes a mostrar por paquete, tiene que ser positivo.
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/

int live_capture(int num){
	int pcap_err = PCAP_OK;
	char errbuf[PCAP_ERRBUF_SIZE];
	struct pcap_pkthdr *cabeceras = NULL;
	uint8_t *data = NULL;

	if(signal(SIGINT,handle) == SIG_ERR){
		fprintf(stdout, "Error: Fallo al capturar la senal SIGINT.\n");
		return EXIT_ERROR;
	}	

	sprintf(file_name, "eth0.%lu.pcap", (unsigned long)time(NULL));

	if ((desc = pcap_open_live("eth0", ETH_FRAME_MAX, PROMISCUO, TIMEOUT, errbuf)) == NULL){
		fprintf(stdout, "Error: No se pudo abrir la interfaz eth0.\n");
		return EXIT_ERROR;
	}

	descr2=pcap_open_dead(DLT_EN10MB,ETH_FRAME_MAX);
	if (!descr2){
		printf("Error al abrir el pcap dead.\n");
		pcap_close(desc);
		return EXIT_ERROR;
	}

	pdumper=pcap_dump_open(descr2,file_name);
	if(!pdumper){
		fprintf(stdout, "Error: No se ha podido abrir el dumper.\n");
		pcap_close(desc);
		pcap_close(descr2);
		return EXIT_ERROR;
	}

	while(1){
		pcap_err = pcap_next_ex(desc, &cabeceras, (const u_char **)&data);
		if(pcap_err == PCAP_ERROR){
			fprintf(stdout, "Error: PCAP_ERROR durante la lectura de paquetes.\n");
			pcap_close(desc);
			pcap_close(descr2);
			pcap_dump_close(pdumper);
			return EXIT_ERROR;
		}

		else if(pcap_err == PCAP_TIMEOUT){
			fprintf(stdout, "Error: Se ha agotado el tiempo para captura, reintentando.\n");
			continue;
		}
		else{
			cabeceras->ts.tv_sec += 172800;
			pcap_dump((uint8_t *)pdumper, cabeceras, data);
			contador = contador + 1;
			if(print_N_bytes(num, data) == EXIT_ERROR){
				fprintf(stdout, "Error: No se ha podido escribir por pantalla los bytes correspondientes.\n");
				pcap_close(desc);
				pcap_close(descr2);
				pcap_dump_close(pdumper);
				return EXIT_ERROR;
			}
		}
	}

	return EXIT_OK;
}

/***************************************************************
Nombre:
    pcap_analyze
Descripcion:
    Analiza la traza de un archivo .pcap
Entrada:
    int num: número de bytes a mostrar por paquete, tiene que ser positivo.
    char* trace: traza pcap a analizar, tiene que ser un archivo .pcap.
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/
int pcap_analyze(int num, const char* trace){
	pcap_t *desc = NULL;
	char* errbuf = NULL;
	struct pcap_pkthdr *cabeceras = NULL;
	char *data = NULL;
	int ret = PCAP_OK;
	int print;
	
	desc = pcap_open_offline(trace, errbuf);
	if(!desc) return EXIT_ERROR;

	while(ret == PCAP_OK){
		ret = pcap_next_ex(desc, &cabeceras, (const u_char **)&data);
		
		if(ret == PCAP_ERROR){
			fprintf(stdout, "Error al leer un paquete: %s, %s %d.\n",pcap_geterr(desc),__FILE__,__LINE__);
			pcap_close(desc);
			return EXIT_ERROR;
		}

		else if(ret == PCAP_TIMEOUT){
			fprintf(stdout, "Timeout en la lectura.\n");
			continue;
		}

		print = print_N_bytes(num, data);



		if(print != EXIT_OK) ret = PCAP_ERROR;
		contador++;
	}


	return EXIT_OK;

}

