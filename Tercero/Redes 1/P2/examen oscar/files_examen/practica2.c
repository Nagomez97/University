/***************************************************************************
 practica2.c
 Muestra las direciones Ethernet de la traza que se pasa como primer parametro.
 Debe complatarse con mas campos de niveles 2, 3, y 4 tal como se pida en el enunciado.
 Debe tener capacidad de dejar de analizar paquetes de acuerdo a un filtro.

 Compila: gcc -Wall -o practica2 practica2.c -lpcap, make
 Autor: Jose Luis Garcia Dorado, Jorge E. Lopez de Vergara Mendez, Rafael Leira
 2017 EPS-UAM
***************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include <pcap.h>
#include <string.h>
#include <netinet/in.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <signal.h>
#include <time.h>
#include <getopt.h>
#include <inttypes.h>

#include <pcap_magic_open.h>

/*Definicion de constantes *************************************************/
/*Macros Ethernet*/
#define ETH_ALEN      6      /* Tamanio de la direccion ethernet           */
#define ETH_HLEN      14     /* Tamanio de la cabecera ethernet            */
#define ETH_TLEN      2      /* Tamanio del campo tipo ethernet            */
#define ETH_FRAME_MAX 1514   /* Tamanio maximo la trama ethernet (sin CRC) */
#define ETH_FRAME_MIN 60     /* Tamanio minimo la trama ethernet (sin CRC) */
#define ETH_DATA_MAX  (ETH_FRAME_MAX - ETH_HLEN) /* Tamano maximo y minimo de los datos de una trama ethernet*/
#define ETH_DATA_MIN  (ETH_FRAME_MIN - ETH_HLEN)

/*Macros IP*/
#define IP_ALEN 4			 /* Tamanio de la direccion IP					*/
#define IP_TO_LENGHT 2		/*Distancia desde principio de IP hasta Longitud Total*/
#define IP_TO_POSITION 4	/*Distancia desde Longitud hasta Posicion*/
#define IP_TO_LIFE 2 		/*Distancia desde Posicion hasta Tiempo de vida*/
#define IP_TO_PROTOCOL 1 	/*Distancia desde tiempo de vida hasta protocolo*/
#define IP_TO_IP 3 			/*Disntacia desde protocolo hasta ip origen*/
#define IP_STEP 1			/*Un byte para imprimir IPS*/
#define END_IP 20 			/*Longitud hasta el final de la direccion destino*/

/*Macros TCP UDP*/
#define TCP 6				/*Protocolo TCP*/
#define UDP 17				/*Protocolo UDP*/
#define PORT_LENGTH 2		/*Longitud puerto TCP y UDP*/
#define TCP_TO_ACK 11		/*Distancia desde puerto destino hasta ACK*/
#define TCP_TO_VENTANA 1

/*Macros para pcap*/
#define OK 0
#define ERROR 1
#define PACK_READ 1
#define PACK_ERR -1
#define TRACE_END -2

/*Macro para filtro*/
#define NO_FILTER 0

/*Promiscuidad de la interfaz*/
#define PROMISCUO 1
#define NOPROMISCUO 0

/*Timeout*/
#define TIMEOUT 5000

#define ARP_TO_IP_SENDER 14

/*Definición de funciones*/
void analizar_paquete(const struct pcap_pkthdr *hdr, const uint8_t *pack);

void handleSignal(int nsignal);

/*Variables globales*/
pcap_t *descr = NULL;
uint64_t contador = 0; /*Contador de paquetes*/
/*Filtros*/
uint8_t ipsrc_filter[IP_ALEN] = {NO_FILTER};
uint8_t ipdst_filter[IP_ALEN] = {NO_FILTER};
uint16_t sport_filter= NO_FILTER;
uint16_t dport_filter = NO_FILTER;

/*Función que controla la señal CTRL-C, mostrará todos los paquetes leidos*/
void handleSignal(int nsignal)
{
	(void) nsignal; // indicamos al compilador que no nos importa que nsignal no se utilice

	printf("Control C pulsado (%"PRIu64" paquetes leidos)\n", contador);
	pcap_close(descr);
	exit(OK);
}


/*Main*/
int main(int argc, char **argv)
{
	uint8_t *pack = NULL;
	struct pcap_pkthdr *hdr;

	char errbuf[PCAP_ERRBUF_SIZE];
	char entrada[256];
	int long_index = 0, retorno = 0;
	char opt;
	
	/*Handler de CTRL-C*/
	if (signal(SIGINT, handleSignal) == SIG_ERR) {
		printf("Error: Fallo al capturar la senal SIGINT.\n");
		exit(ERROR);
	}

	/*Control de argumentos y flags*/
	if (argc > 1) {
		if (strlen(argv[1]) < 256) {
			strcpy(entrada, argv[1]);
		}
		else {
			printf("Argumento demasiado largo.\n");
			printf("Ejecucion: %s <-f traza.pcap / -i eth0> [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]\n", argv[0]);

			exit(ERROR);
		}

	} else {
		printf("Ejecucion: %s <-f traza.pcap / -i eth0> [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]\n", argv[0]);
		exit(ERROR);
	}

	static struct option options[] = {
		{"f", required_argument, 0, 'f'},
		{"i",required_argument, 0,'i'},
		{"ipo", required_argument, 0, '1'},
		{"ipd", required_argument, 0, '2'},
		{"po", required_argument, 0, '3'},
		{"pd", required_argument, 0, '4'},
		{"h", no_argument, 0, '5'},
		{0, 0, 0, 0}
	};

	while ((opt = getopt_long_only(argc, argv, "f:i:1:2:3:4:5", options, &long_index)) != -1) {
		switch (opt) {
		case 'i' :
			if(descr) { // comprobamos que no se ha abierto ninguna otra interfaz o fichero
				printf("Ha seleccionado más de una fuente de datos\n");
				pcap_close(descr);
				exit(ERROR);
			}
			/*Abrimos la interfaz*/
			if ((descr = pcap_open_live(optarg, ETH_FRAME_MAX, PROMISCUO, TIMEOUT, errbuf)) == NULL){
				fprintf(stdout, "Error: No se pudo abrir la interfaz %s.\n", optarg);
				exit(ERROR);
			}
			break;

		case 'f' :
			if(descr) { // comprobamos que no se ha abierto ninguna otra interfaz o fichero
				printf("Ha seleccionado más de una fuente de datos\n");
				pcap_close(descr);
				exit(ERROR);
			}
			/*Abrimos el fichero*/
			if ((descr = pcap_magic_open(optarg, errbuf)) == NULL) {
				printf("Error: pcap_magic_open(): File: %s, %s %s %d.\n", optarg, errbuf, __FILE__, __LINE__);
				exit(ERROR);
			}

			break;

		/*Caso de IPO*/
		case '1' :
			if (sscanf(optarg, "%"SCNu8".%"SCNu8".%"SCNu8".%"SCNu8"", &(ipsrc_filter[0]), &(ipsrc_filter[1]), &(ipsrc_filter[2]), &(ipsrc_filter[3])) != IP_ALEN) {
				printf("Error ipo_filtro. Ejecucion: %s /ruta/captura_pcap [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
				exit(ERROR);
			}

			break;

		/*Caso de IPD*/
		case '2' :
			if (sscanf(optarg, "%"SCNu8".%"SCNu8".%"SCNu8".%"SCNu8"", &(ipdst_filter[0]), &(ipdst_filter[1]), &(ipdst_filter[2]), &(ipdst_filter[3])) != IP_ALEN) {
				printf("Error ipd_filtro. Ejecucion: %s /ruta/captura_pcap [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
				exit(ERROR);
			}

			break;

		/*Caso de PO*/
		case '3' :
			if ((sport_filter= atoi(optarg)) == 0) {
				printf("Error po_filtro.Ejecucion: %s /ruta/captura_pcap [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
				exit(ERROR);
			}

			break;

		/*Caso de PD*/
		case '4' :
			if ((dport_filter = atoi(optarg)) == 0) {
				printf("Error pd_filtro. Ejecucion: %s /ruta/captura_pcap [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
				exit(ERROR);
			}

			break;

		/*Caso help*/
		case '5' :
			printf("Ayuda. Ejecucion: %s <-f traza.pcap / -i eth0> [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
			exit(ERROR);
			break;

		/*Flag desconocido*/
		case '?' :
		default:
			printf("Error. Ejecucion: %s <-f traza.pcap / -i eth0> [-ipo IPO] [-ipd IPD] [-po PO] [-pd PD]: %d\n", argv[0], argc);
			exit(ERROR);
			break;
		}
	}

	/*Comprobar que hay origen de paquetes abierto*/
	if (!descr) {
		printf("No selecciono ningún origen de paquetes.\n");
		return ERROR;
	}

	//Simple comprobacion de la correcion de la lectura de parametros
	printf("Filtro:");
	//if(ipsrc_filter[0]!=0)
	printf("ipsrc_filter:%"PRIu8".%"PRIu8".%"PRIu8".%"PRIu8"\t", ipsrc_filter[0], ipsrc_filter[1], ipsrc_filter[2], ipsrc_filter[3]);
	//if(ipdst_filter[0]!=0)
	printf("ipdst_filter:%"PRIu8".%"PRIu8".%"PRIu8".%"PRIu8"\t", ipdst_filter[0], ipdst_filter[1], ipdst_filter[2], ipdst_filter[3]);

	if (sport_filter!= NO_FILTER) {
		printf("po_filtro=%"PRIu16"\t", sport_filter);
	}

	if (dport_filter != NO_FILTER) {
		printf("pd_filtro=%"PRIu16"\t", dport_filter);
	}

	printf("\n\n");

	/*Bucle que lee paquetes y los manda a la función correspondiente para analizarlos*/
	do {
		retorno = pcap_next_ex(descr, &hdr, (const u_char **)&pack);

		if (retorno == PACK_READ) { //Todo correcto
			contador++;
			analizar_paquete(hdr, pack);
		
		} else if (retorno == PACK_ERR) { //En caso de error
			printf("Error al capturar un paquetes %s, %s %d.\n", pcap_geterr(descr), __FILE__, __LINE__);
			pcap_close(descr);
			exit(ERROR);

		}
	} while (retorno != TRACE_END);

	/*Cuando se acaban los paquetes de la traza se mostrarán los paquetes leidos.*/
	printf("Se procesaron %"PRIu64" paquetes.\n\n", contador);
	pcap_close(descr);
	return OK;
}


/*Funcion que analiza los paquetes capturados en el main*/
void analizar_paquete(const struct pcap_pkthdr *hdr, const uint8_t *pack)
{
	uint8_t aux; /*Auxiliar de 8 bits*/
	uint16_t aux16; /*Auxiliar de 16 bits*/
	uint8_t protocolo; /*Protocolo del paquete*/
	uint16_t posicion; /*Posición del paquete*/
	uint8_t IHL; /*Header length del paquete*/
	int flag = 0; 

	printf("\n--------------------------------------------------------------------\n");
	printf("Nuevo paquete capturado el %s\n", ctime((const time_t *) & (hdr->ts.tv_sec)));

	int i = 0;
	/*Imprimimos ip destino*/
	printf("Direccion ETH destino= ");
	printf("%02X", pack[0]);

	for (i = 1; i < ETH_ALEN; i++) {
		printf(":%02X", pack[i]);
	}

	printf("\n");
	pack += ETH_ALEN;

	/*Imprimimos ip origen*/
	printf("Direccion ETH origen = ");
	printf("%02X", pack[0]);

	for (i = 1; i < ETH_ALEN; i++) {
		printf(":%02X", pack[i]);
	}

	printf("\n");

	pack+=ETH_ALEN;

	/*imprimimos el protocolo de ethernet utilizado*/
	printf("Tipo de Ethernet = 0x");
	printf("%02X%02X ", pack[0], pack[1]); /*El tipo de ehternet en hexadecimal*/

	if(pack[0] != 8 || (pack[1] != 0 && pack[1] != 6)){
		printf("El protocolo no es IPv4 ni ARP\n");
		return;
	}

	printf("\n\n");

	

	if(pack[1] == 6){ /*ARP*/
		pack+=ETH_TLEN;
		pack += ARP_TO_IP_SENDER;

		printf("Direccion IP emisor = ");
		printf("%d", pack[0]);
		pack += IP_STEP;
		for( i = 1; i < IP_ALEN; i++){	
			printf(".%d", pack[0]);
			pack += IP_STEP;
		}
		printf("\n");
		return;


	}	
	pack+=ETH_TLEN;

	/*Protocolo IPv4*/

	/*Version IP*/
	aux = (pack[0] & 0xF0)/16; /*Asi cogemos los 4 bits mas significativos del primer byte*/
	IHL = (pack[0] & 0x0F);
	printf("Version IP = %d\n", aux);

	/*Longitud de cabecera*/
	aux = pack[0] & 0x0F; /*Asi cogemos los 4 menos significativos*/
	printf("Longitud de cabecera = %d\n", aux);

	/*Longitud total*/
	pack += IP_TO_LENGHT;
	aux16 = htons(*(uint16_t*)pack);
	printf("Longitud total = %d\n", aux16);

	/*Posicion del paquete*/
	pack += IP_TO_POSITION;
	posicion = htons(*(uint16_t*)pack) & 0x1FFF;
	printf("Posicion = %d\n", posicion); /* Así cogemos los 13 bits que necesitamos*/

	/*Tiempo de vida del paquete*/
	pack += IP_TO_LIFE;
	printf("Tiempo de vida = %d\n", pack[0]);

	/*Protocolo IP*/
	pack += IP_TO_PROTOCOL;
	protocolo = pack[0];
	printf("Protocolo IP = %d\n", protocolo);

	/*Direccion IP origen con comprobacion de filtros*/
	pack += IP_TO_IP;
	printf("Direccion IP origen = ");
	printf("%d", pack[0]);
	if(pack[0] != ipsrc_filter[0]){
		flag = 1;
	}
	pack += IP_STEP;
	for( i = 1; i < IP_ALEN; i++){
		printf(".%d", pack[0]);
		if(pack[0] != ipsrc_filter[i]){
			flag = 1;
		}
		pack += IP_STEP;
	}
	printf("\n");
	if(ipsrc_filter[0] == NO_FILTER){
		flag = 0;
	}
	if(flag == 1){
		printf("La direccion IP origen no coincide con el filtro.\n");
		return;
	}

	/*Direccion IP destino con comprobacion de filtros*/
	printf("Direccion IP destino = ");
	printf("%d", pack[0]);
	if(pack[0] != ipdst_filter[0]){
		flag = 1;
	}
	pack += IP_STEP;
	for( i = 1; i < IP_ALEN; i++){
		printf(".%d", pack[0]);
		if(pack[0] != ipdst_filter[i]){
		flag = 1;
	}
		pack += IP_STEP;
	}
	printf("\n");
	if(ipdst_filter[0] == NO_FILTER){
		flag = 0;
	}
	if(flag == 1){
		printf("La direccion IP destino no coincide con el filtro.\n");
		return;
	}

	/*Comprobacion de que la posicion sea 0, en caso de que no lo sea no es el primer fragmento*/
	if (posicion != 0){
		printf("El paquete no es el primer fragmento.\n");
		return;
	}
	printf("\n");
	/*Nos situamos en el final de la cabecera IP*/
	pack += (IHL*4) - END_IP;

	/*Si el protocolo es TCP:*/
	if(protocolo == TCP){

		/*Puerto de origen con comprobación de filtros*/
		aux16 = htons(*(uint16_t*)pack);
		printf("Puerto de origen = %d\n", aux16);

		if(aux16 != sport_filter && sport_filter != NO_FILTER){
			printf("El puerto de origen no coincide con el filtro.\n");
			return;
		}

		/*Puerto de destino con comprobación de filtros*/
		pack += PORT_LENGTH;
		aux16 = htons(*(uint16_t*)pack);
		printf("Puerto de destino = %d\n", aux16);

		if(aux16 != dport_filter && dport_filter != NO_FILTER){
			printf("El puerto de destino no coincide con el filtro.\n");
			return;
		}

		/*Flags ACK y SYN*/
		pack += TCP_TO_ACK;
		printf("ACK = %c\n", (pack[0] & 0x10) == 16? '1' : '0');
		printf("SYN = %c\n", (pack[0] & 0x02) == 2? '1' : '0');

		pack += TCP_TO_VENTANA;
		aux16 = htons(*(uint16_t*)pack);
		printf("Ventana = %d\n", aux16);

		return;
	}

	/*Si el protocolo es UDP:*/
	else if(protocolo == UDP){

		/*Puerto de origen con comprobacion de filtros*/
		aux16 = htons(*(uint16_t*)pack);
		printf("Puerto de origen = %d\n", aux16);

		if(aux16 != sport_filter && sport_filter != NO_FILTER){
			printf("El puerto de origen no coincide con el filtro.\n");
			return;
		}

		/*Puerto de destino con comprobacion de filtros*/
		pack += PORT_LENGTH;
		aux16 = htons(*(uint16_t*)pack);
		printf("Puerto de destino = %d\n", aux16);

		if(aux16 != dport_filter && dport_filter != NO_FILTER){
			printf("El puerto de destino no coincide con el filtro.\n");
			return;
		}

		/*Longitud*/
		pack += PORT_LENGTH;
		aux16 = htons(*(uint16_t*)pack);
		printf("Longitud = %d\n", aux16);

		return;
	}

	/*Si el protocolo no es ni TCP ni UDP*/
	else{
		printf("El paquete no utiliza protocolo TCP ni UDP.\n");
		return;
	}
}