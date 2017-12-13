/***************************************************************************
 practica4.c
 Inicio, funciones auxiliares y modulos de transmision implmentados y a implementar de la practica 4.
Compila con warning pues falta usar variables y modificar funciones
 
 Compila: make
 Autor: Jose Luis Garcia Dorado
 2014 EPS-UAM v2
***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include "interface.h"
#include "practica4.h"

/***************************Variables globales utiles*************************************************/
pcap_t* descr, *descr2; //Descriptores de la interface de red
pcap_dumper_t * pdumper;//y salida a pcap
uint64_t cont=0;	//Contador numero de mensajes enviados
char interface[10];	//Interface donde transmitir por ejemplo "eth0"
uint16_t ID=1;		//Identificador IP


void handleSignal(int nsignal){
	printf("Control C pulsado (%"PRIu64")\n", cont);
	pcap_close(descr);
	exit(OK);
}

int main(int argc, char **argv){	

	char errbuf[PCAP_ERRBUF_SIZE];
	char fichero_pcap_destino[CADENAS];
	uint8_t IP_destino_red[IP_ALEN];
	uint16_t MTU;
	uint16_t datalink;
	uint16_t puerto_destino;
	char data[IP_DATAGRAM_MAX];
	uint16_t pila_protocolos[CADENAS];
	FILE *f = NULL;


	int long_index=0;
	char opt;
	char flag_iface = 0, flag_ip = 0, flag_port = 0, flag_file = 0;

	static struct option options[] = {
		{"if",required_argument,0,'1'},
		{"ip",required_argument,0,'2'},
		{"pd",required_argument,0,'3'},
		{"f",required_argument,0,'4'},
		{"h",no_argument,0,'5'},
		{0,0,0,0}
	};

		//Dos opciones: leer de stdin o de fichero, adicionalmente para pruebas si no se introduce argumento se considera que el mensaje es "Payload "
	while ((opt = getopt_long_only(argc, argv,"1:2:3:4:5", options, &long_index )) != -1) {
		switch (opt) {

			case '1' :

				flag_iface = 1;
					//Por comodidad definimos interface como una variable global
				sprintf(interface,"%s",optarg);
				break;

			case '2' : 

				flag_ip = 1;
					//Leemos la IP a donde transmitir y la almacenamos en orden de red
				if (sscanf(optarg,"%"SCNu8".%"SCNu8".%"SCNu8".%"SCNu8"",
				                   &(IP_destino_red[0]),&(IP_destino_red[1]),&(IP_destino_red[2]),&(IP_destino_red[3])) != IP_ALEN){
					printf("Error: Fallo en la lectura IP destino %s\n", optarg);
					exit(ERROR);
				}

				break;

			case '3' :

				flag_port = 1;
					//Leemos el puerto a donde transmitir y la almacenamos en orden de hardware
				puerto_destino=atoi(optarg);
				break;

			case '4' :

				if(strcmp(optarg,"stdin")==0) {
					if (fgets(data, sizeof data, stdin)==NULL) {
						  	printf("Error leyendo desde stdin: %s %s %d.\n",errbuf,__FILE__,__LINE__);
						return ERROR;
					}
					sprintf(fichero_pcap_destino,"%s%s","stdin",".pcap");
				} else {
					f=fopen(optarg, "r");
					if(fgets(data, sizeof data, f)==NULL){
						printf("Error leyendo desde fichero: %s %s %d.\n",errbuf,__FILE__,__LINE__);
						return ERROR;
					}	
					sprintf(fichero_pcap_destino,"%s%s",optarg,".pcap");
					//TODO Leer fichero en data [...]
				}

				flag_file = 1;

				break;

			case '5' : printf("Ayuda. Ejecucion: %s -if interface -ip IP -pd Puerto <-f /ruta/fichero_a_transmitir o stdin>: %d\n",argv[0],argc); exit(ERROR);
				break;

			case '?' : printf("Error. Ejecucion: %s -if interface -ip IP -pd Puerto <-f /ruta/fichero_a_transmitir o stdin>: %d\n",argv[0],argc); exit(ERROR);
				break;

			default: printf("Error. Ejecucion: %s -if interface -ip IP -pd Puerto <-f /ruta/fichero_a_transmitir o stdin>: %d\n",argv[0],argc); exit(ERROR);
				break;
        }
    }

	if ((flag_iface == 0) || (flag_ip == 0) || (flag_port == 0)){
		printf("Error. Ejecucion: %s -if interface -ip IP -pd Puerto <-f /ruta/fichero_a_transmitir o stdin>: %d\n",argv[0],argc);
		exit(ERROR);
	} else {
		printf("Interface:\n\t%s\n",interface);
		printf("IP:\n\t%"PRIu8".%"PRIu8".%"PRIu8".%"PRIu8"\n",IP_destino_red[0],IP_destino_red[1],IP_destino_red[2],IP_destino_red[3]);
		printf("Puerto destino:\n\t%"PRIu16"\n",puerto_destino);
	}

	if (flag_file == 0) {
		sprintf(data,"%s","Payload "); //Deben ser pares!
		sprintf(fichero_pcap_destino,"%s%s","debugging",".pcap");
	}

	if(signal(SIGINT,handleSignal)==SIG_ERR){
		printf("Error: Fallo al capturar la senal SIGINT.\n");
		return ERROR;
	}
		//Inicializamos las tablas de protocolos
	if(inicializarPilaEnviar()==ERROR){
      	printf("Error leyendo desde stdin: %s %s %d.\n",errbuf,__FILE__,__LINE__);
		return ERROR;
	}
		//Leemos el tamano maximo de transmision del nivel de enlace
	if(obtenerMTUInterface(interface, &MTU)==ERROR)
		return ERROR;
		//Descriptor de la interface de red donde inyectar trafico
	if ((descr = pcap_open_live(interface,MTU+ETH_HLEN,0, 0, errbuf)) == NULL){
		printf("Error: pcap_open_live(): %s %s %d.\n",errbuf,__FILE__,__LINE__);
		return ERROR;
	}

	datalink=(uint16_t)pcap_datalink(descr); //DLT_EN10MB==Ethernet

		//Descriptor del fichero de salida pcap para debugging
	descr2=pcap_open_dead(datalink,MTU+ETH_HLEN);
	pdumper=pcap_dump_open(descr2,fichero_pcap_destino);

		//Formamos y enviamos el trafico, debe enviarse un unico segmento por llamada a enviar() aunque luego se traduzca en mas de un datagrama
		//Primero un paquete UDP
		//Definimos la pila de protocolos que queremos seguir
	pila_protocolos[0]=UDP_PROTO; pila_protocolos[1]=IP_PROTO; pila_protocolos[2]=ETH_PROTO;
		//Rellenamos los parametros necesario para enviar el paquete a su destinatario y proceso
	Parametros parametros_udp; memcpy(parametros_udp.IP_destino,IP_destino_red,IP_ALEN); parametros_udp.puerto_destino=puerto_destino;
		//Enviamos
	if(enviar((uint8_t*)data,strlen(data),pila_protocolos,&parametros_udp)==ERROR ){
		printf("Error: enviar(): %s %s %d.\n",errbuf,__FILE__,__LINE__);
		return ERROR;
	}
	else	cont++;

	printf("Enviado mensaje %"PRIu64", almacenado en %s\n\n\n", cont,fichero_pcap_destino);

		//Luego, un paquete ICMP en concreto un ping
	pila_protocolos[0]=ICMP_PROTO; pila_protocolos[1]=IP_PROTO; pila_protocolos[2]=ETH_PROTO;
	Parametros parametros_icmp; parametros_icmp.tipo=PING_TIPO; parametros_icmp.codigo=PING_CODE; memcpy(parametros_icmp.IP_destino,IP_destino_red,IP_ALEN);
	if(enviar((uint8_t*)"Probando a hacer un ping1234123412341234",strlen("Probando a hacer un ping"),pila_protocolos,&parametros_icmp)==ERROR ){
		printf("Error: enviar(): %s %s %d.\n",errbuf,__FILE__,__LINE__);
		return ERROR;
	}
	else	cont++;
	printf("Enviado mensaje %"PRIu64", ICMP almacenado en %s\n\n", cont,fichero_pcap_destino);

		//Cerramos descriptores
	pcap_close(descr);
	pcap_dump_close(pdumper);
	pcap_close(descr2);
	return OK;
}


/****************************************************************************************
* Nombre: enviar 									*
* Descripcion: Esta funcion envia un mensaje						*
* Argumentos: 										*
*  -mensaje: mensaje a enviar								*
*  -pila_protocolos: conjunto de protocolos a seguir					*
*  -longitud: bytes que componen mensaje						*
*  -parametros: parametros necesario para el envio (struct parametros)			*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t enviar(uint8_t* mensaje, uint64_t longitud,uint16_t* pila_protocolos,void *parametros){
	uint16_t protocolo=pila_protocolos[0];
	printf("Enviar(%"PRIu16") %s %d.\n",protocolo,__FILE__,__LINE__);
	if(protocolos_registrados[protocolo]==NULL){
		printf("Protocolo %"PRIu16" desconocido\n",protocolo);
		return ERROR;
	}
	else {
		return protocolos_registrados[protocolo](mensaje,longitud,pila_protocolos,parametros);
	}
	return ERROR;
}


/***************************TODO Pila de protocolos a implementar************************************/

/****************************************************************************************
* Nombre: moduloUDP 									*
* Descripcion: Esta funcion implementa el modulo de envio UDP				*
* Argumentos: 										*
*  -mensaje: mensaje a enviar								*
*  -pila_protocolos: conjunto de protocolos a seguir					*
*  -longitud: bytes que componen mensaje						*
*  -parametros: parametros necesario para el envio este protocolo			*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t moduloUDP(uint8_t* mensaje,uint64_t longitud, uint16_t* pila_protocolos,void *parametros){
	uint8_t segmento[UDP_SEG_MAX]={0};
	uint16_t puerto_origen = 0,suma_control=0,len=0;
	uint16_t aux16;
	uint32_t pos=0;
	uint16_t protocolo_inferior=pila_protocolos[1];
	printf("modulo UDP(%"PRIu16") %s %d.\n",protocolo_inferior,__FILE__,__LINE__);

	if (longitud>(pow(2,16)-UDP_HLEN)){
		printf("Error: mensaje demasiado grande para UDP (%f).\n",(pow(2,16)-UDP_HLEN));
		return ERROR;
	}

	Parametros udpdatos=*((Parametros*)parametros);
	uint16_t puerto_destino=htons(udpdatos.puerto_destino);
	len=(uint16_t) htons(longitud);

	if(obtenerPuertoOrigen(&puerto_origen) == ERROR){
		printf("Error al obtener un puerto origen disponible.\n");
		return ERROR;
	}
	aux16=htons(puerto_origen);
	memcpy(segmento+pos,&aux16,sizeof(uint16_t));
	pos+=sizeof(uint16_t);

	memcpy(segmento+pos,&puerto_destino,sizeof(uint16_t));
	pos+=sizeof(uint16_t);

	memcpy(segmento+pos,&len,sizeof(uint16_t));
	pos+=sizeof(uint16_t);

	memcpy(segmento+pos,&suma_control,sizeof(uint16_t));
	pos+=sizeof(uint16_t);

	memcpy(segmento+pos,mensaje,ntohs(len));

	return protocolos_registrados[protocolo_inferior](segmento,longitud+pos,pila_protocolos,&udpdatos);
}


/****************************************************************************************
* Nombre: moduloIP 									*
* Descripcion: Esta funcion implementa el modulo de envio IP				*
* Argumentos: 										*
*  -segmento: segmento a enviar								*
*  -pila_protocolos: conjunto de protocolos a seguir					*
*  -longitud: bytes que componen el segmento						*
*  -parametros: parametros necesario para el envio este protocolo			*
* Retorno: OK/ERROR									*
*
* ***************************************************************************************/



uint8_t moduloIP(uint8_t* segmento, uint64_t longitud, uint16_t* pila_protocolos,void *parametros){
	uint8_t datagrama[IP_DATAGRAM_MAX]={0};
	uint8_t cabecera[IHL*4]={0};
	uint16_t MTU;
	uint32_t pos=0;
	uint8_t IP_origen[IP_ALEN];
	uint16_t protocolo_superior=pila_protocolos[0];
	uint16_t protocolo_inferior=pila_protocolos[2];
	uint8_t mascara[IP_ALEN],IP_rango_origen[IP_ALEN],IP_rango_destino[IP_ALEN];
	uint8_t IP_gateway[IP_ALEN];
	uint16_t len8, len16, len32;
	
	uint16_t offset;
	
	len8 = sizeof(uint8_t);
	len16 = sizeof(uint16_t);
	len32 = sizeof(uint32_t);

	/*Variables para el datagrama*/
	uint8_t vers_ihl = 0x46; /* 70 es 0x46 en hex. Esto es porque los primeros
							4 bits de esta variable son del tipo de IP (4) mientras
							que los 4 siguientes son del tamanio de cabecera, que sera
							de tamanio 6*/
	uint8_t servicio = 0; /*Dejamos el tipo de servicio a 0*/
	uint16_t total_size;
	uint8_t tiempo = 128;
	uint16_t flags_pos;
	uint16_t inichecksum = 0;
	uint8_t protocol = (uint8_t) protocolo_superior;
	uint32_t opciones_relleno = 0;
	uint16_t identificador; /*Valor aleatorio para el identificador*/
	random_identifier(&identificador);

	obtenerMTUInterface(interface, &MTU);
	printf("MTUMTUMTUMTUMTUMTU: %d", MTU);
	uint16_t max_tam = MTU;

	//BORRARARARARARGJASDFHASFHBAF LZHEAIDNHAOIENHF IANHFAWELDFHKS JRDHFNADUBKGJNFHAMÑIDLNFJ BASDKFAKM 
	max_tam=max_tam-(max_tam%8);

	printf("modulo IP(%"PRIu16") %s %d.\n",protocolo_inferior,__FILE__,__LINE__);

	Parametros ipdatos=*((Parametros*)parametros);
	uint8_t* IP_destino=ipdatos.IP_destino;

	if(longitud > IP_DATAGRAM_MAX){
		printf("Error, datagrama demasiado grande");
		return ERROR;
	}

	if(protocol == ICMP_PROTO){
		if(longitud > max_tam){
			printf("Error, datagrama demasiado grande");
			return ERROR;
		}
	}

	if(obtenerIPInterface(interface, IP_origen)==ERROR){
		printf("Error al obtener la direccion IP origen\n");
		return ERROR;
	}

	if(obtenerMascaraInterface(interface,mascara)==ERROR){
		printf("Error al obtener la mascara de la interfaz.\n");
		return ERROR;
	}

	/*Aplicamos las mascaras para luego ver si estan en la misma subred*/
	aplicarMascara(IP_origen,mascara,IP_ALEN,IP_rango_origen);
	aplicarMascara(IP_destino,mascara,IP_ALEN,IP_rango_destino);

	/*Comprobamos si el destino esta en la misma subred*/
	if(memcmp(IP_rango_destino,IP_rango_origen,(IP_ALEN * sizeof(uint8_t))) == 0){
		/*Se realiza un ARP request y guarda la MAC destino en la estructura de datos*/
		if(ARPrequest(interface,IP_destino,ipdatos.ETH_destino) == ERROR){
			printf("Error en ARP request de la IP destino.\n");
			return ERROR;
		}

	}
	/*En caso de que no se encuentren en la misma subred*/
	else{
		/*Obtenemos la puerta de enlace*/
		if(obtenerGateway(interface,IP_gateway) == ERROR){
			printf("Error al obtener la IP del gateway.\n");
			return ERROR;
		}
		/*Realizamos un ARP request*/
		if(ARPrequest(interface,IP_gateway,ipdatos.ETH_destino) == ERROR){
			printf("Error en ARP request del gateway.\n");
			return ERROR;
		}
	}

	/*Rellenamos la cabecera*/
	/*Version IP y IHL*/
	memcpy(cabecera+pos,&vers_ihl,len8);
	pos += len8;
	
	/*Tipo de servicio*/
	memcpy(cabecera+pos,&servicio,len8);
	pos += len8;
	
	/*Salto debido a total size, se rellenara al fragmentar*/
	pos += len16;

	/*Identificacion*/
	memcpy(cabecera+pos,&identificador,len16);
	pos += len16;

	/*Salto debido a las flags y a posicion, estos campos se rellenan tras calcular la fragmentacion*/
	pos += len16;

	/*Tiempo de vida*/
	memcpy(cabecera+pos,&tiempo,len8);
	pos += len8;
	
	/*Protocolo*/
	memcpy(cabecera+pos,&protocol,len8);
	pos += len8;
	
	/*Salto debido al checksum, se rellenará en la fragmentación*/
	pos += len16;

	/*Direccion ip origen*/
	memcpy(cabecera+pos,IP_origen,IP_ALEN);
	pos += IP_ALEN;
	
	/*Direccion ip destino*/
	memcpy(cabecera+pos,IP_destino,IP_ALEN);
	pos += IP_ALEN;
	

	/*Bucle para fragmentacion*/
	for(offset=0; offset<longitud; offset+=(max_tam-IHL*4)){
		/*No es el ultimo paquete*/
		if(offset + (max_tam-IHL*4) < longitud){
			total_size = htons(max_tam);
			flags_pos = ((offset/8) & 0x1fff) | 0x2000;
		}
		/*Ultimo paquete*/
		else{
			if(protocolo_superior == ICMP_PROTO){
				total_size = htons(longitud - offset + (IHL*4));
				printf("SOY ICMP\n");
				flags_pos = ((offset/8) & 0x1fff) | 0x4000;
			}
			else{
				total_size = htons(longitud - offset + (IHL*4));
				flags_pos = ((offset/8) & 0x1fff) | 0x0000;
			}
		}
		printf("OFFSEEEEEEEEEEEEEEEEEEEt%d\n", offset);
		flags_pos = htons(flags_pos);
		
		/*Rellenamos la cabecera con longitud total*/
		memcpy(cabecera+IP_TO_LEN,&total_size,len16);
		
		/*Rellenamos el campo de las flags y el offset*/
		memcpy(cabecera+IP_TO_FLAGS,&flags_pos,len16);
		
		/*Ponemos el checksum a 0*/
		memcpy(cabecera+IP_TO_CHECKSUM,&inichecksum,len16);
		
		/*Obtenemos el checksum y lo guardamos en la posición correspondiente*/
		calcularChecksum((uint16_t)(IHL)*4,cabecera,cabecera+IP_TO_CHECKSUM);
		
		/*Rellenamos el datagrama para enviarlo*/
		memcpy(datagrama,cabecera,(IHL*4));
		
		/*Rellenamos el datagrama con el fragmento del segmento*/
		memcpy(datagrama+(IHL*4), segmento+offset, ntohs(total_size)-(IHL*4));
		
		/*Pasamos al siguiente nivel de protocolos*/
		if(protocolos_registrados[protocolo_inferior](datagrama,ntohs(total_size),pila_protocolos,&ipdatos) == ERROR) return ERROR;
	}
		
	return OK;



/***************************************************************************
* FALTA RELLENAR EL PROTOCOLO IP 		*
***************************************************************************/

//TODO
//Llamar a ARPrequest(·) adecuadamente y usar ETH_destino de la estructura parametros
//[...] 
//TODO A implementar el datagrama y fragmentación (en caso contrario, control de tamano)
//[...] 
//llamada/s a protocolo de nivel inferior [...]


}


/****************************************************************************************
* Nombre: moduloETH 									*
* Descripcion: Esta funcion implementa el modulo de envio Ethernet			*
* Argumentos: 										*
*  -datagrama: datagrama a enviar							*
*  -pila_protocolos: conjunto de protocolos a seguir					*
*  -longitud: bytes que componen el datagrama						*
*  -parametros: Parametros necesario para el envio este protocolo			*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t moduloETH(uint8_t* datagrama, uint64_t longitud, uint16_t* pila_protocolos,void *parametros){
	//TODO
	//[....]
	//[...] Variables del modulo
	uint8_t trama[ETH_FRAME_MAX]={0};
	uint32_t pos = 0;
	uint16_t protocolo_superior=htons(pila_protocolos[1]);
	int len8 = sizeof(uint8_t);
	int len16 = sizeof(uint16_t);
	int size = longitud + ETH_HLEN;
	uint8_t ETH_origen[ETH_ALEN];
	Parametros ethdatos=*((Parametros*)parametros);
	struct pcap_pkthdr h;
	
	printf("modulo ETH(fisica) %s %d.\n",__FILE__,__LINE__);
	printf("PROTOCOLO SUPERIOR %d\n", protocolo_superior);
	
	obtenerMACdeInterface(interface, ETH_origen);

	/*CONTROL DE TAMANIO*/
	if(longitud > (ETH_FRAME_MAX)){
		printf("Error: datagrama demasiado grande para Ethernet. Longitud = %"PRIu64"\n", longitud);
		return ERROR;
	}
	
	/*CABECERA EHTERNET*/

	/*Rellenamos la MAC destino*/
	memcpy(trama+pos,ethdatos.ETH_destino,ETH_ALEN);
	pos+=ETH_ALEN;
	
	/*Rellenamos la MAC origen*/
	memcpy(trama+pos,ETH_origen,ETH_ALEN);
	pos+=ETH_ALEN;
	
	/*Rellenamos el tipo de Ethernet*/
	memcpy(trama+pos,&protocolo_superior,len16);
	pos+=len16;
	
	/*Rellenamos el datagrama*/
	memcpy(trama+pos,datagrama,longitud);
	
	mostrarPaquete(trama, size);
	/*ENVIAR A CAPA FISICA*/
	if(pcap_sendpacket(descr, trama, size) == -1){
		printf("Error al enviar el paquete.\n");
		return ERROR;
	}
	
	/*Volcamos los datos a un archivo pcap*/

	gettimeofday(&(h.ts), NULL);
	h.len = size;
	h.caplen = size;
	pcap_dump((uint8_t *)pdumper, &h, (const u_char *)trama);
	
	
	
	//TODO
	//[...] Control de tamano
	
	//TODO
	//[...] Cabecera del modulo
	
	//TODO
	//Enviar a capa fisica [...]  
	//TODO
	//Almacenamos la salida por cuestiones de debugging [...]
	
	return OK;
}


/****************************************************************************************
* Nombre: moduloICMP 									*
* Descripcion: Esta funcion implementa el modulo de envio ICMP				*
* Argumentos: 										*
*  -mensaje: mensaje a anadir a la cabecera ICMP					*
*  -pila_protocolos: conjunto de protocolos a seguir					*
*  -longitud: bytes que componen el mensaje						*
*  -parametros: parametros necesario para el envio este protocolo			*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t moduloICMP(uint8_t* mensaje,uint64_t longitud, uint16_t* pila_protocolos,void *parametros){
	uint8_t datagrama[ICMP_DATAGRAM_MAX]={0};
	uint16_t len=0;
	uint16_t inichecksum = 0;
	uint32_t pos=0;
	uint16_t protocolo_inferior=pila_protocolos[1];
	uint8_t tipo = PING_TIPO;
	uint8_t code = PING_CODE;
	int len8 = sizeof(uint8_t);
	int len16 = sizeof(uint16_t);	
	uint16_t identificador; /*Valor aleatorio para el identificador*/
	random_identifier(&identificador);
	uint16_t seq = htons(1);
	printf("modulo ICMP(%"PRIu16") %s %d.\n",protocolo_inferior,__FILE__,__LINE__);

	if (longitud>(ICMP_DATAGRAM_MAX-ICMP_HLEN)){
		printf("Error: mensaje demasiado grande para ICMP (%d).\n",(ICMP_DATAGRAM_MAX-ICMP_HLEN));
		return ERROR;
	}

	len=(uint16_t) longitud;
	
	/*Copiamos el tipo*/
	memcpy(datagrama+pos,&tipo,len8);
	pos+=len8;
	
	/*Copiamos el codigo*/
	memcpy(datagrama+pos,&code,len8);
	pos+=len8;
	
	/*Inicializamos el checksum a 0*/
	memcpy(datagrama+pos,&inichecksum,len16);
	pos+=len16;
	
	/*Copiamos el identificador*/
	memcpy(datagrama+pos,&identificador,len16);
	pos+=len16;
	
	/*Copiamos numero de secuencia*/
	memcpy(datagrama+pos,&seq,len16);
	pos+=len16;

	/*Copiamos los datos*/
	memcpy(datagrama+pos,mensaje,len);

	/*Hacemos el checksum*/
	calcularChecksum(longitud+pos, datagrama, datagrama+2);

	/*Enviamos a protocolo inferior*/
	return protocolos_registrados[protocolo_inferior](datagrama,longitud+pos,pila_protocolos,parametros);
}


/***************************Funciones auxiliares a implementar***********************************/

/****************************************************************************************
* Nombre: aplicarMascara 								*
* Descripcion: Esta funcion aplica una mascara a una vector				*
* Argumentos: 										*
*  -IP: IP a la que aplicar la mascara en orden de red					*
*  -mascara: mascara a aplicar en orden de red						*
*  -longitud: bytes que componen la direccion (IPv4 == 4)				*
*  -resultado: Resultados de aplicar mascara en IP en orden red				*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t aplicarMascara(uint8_t* IP, uint8_t* mascara, uint32_t longitud, uint8_t* resultado){
	int i = 0;
	if(IP==NULL || mascara==NULL || longitud<=0 || resultado==NULL){
		printf("Error aplicando la mascara.\n");
		return ERROR;
	}
	for(i=0; i<longitud; i++){
		resultado[i] = IP[i] & mascara[i];
	}
	return OK;
}


/***************************Funciones auxiliares implementadas**************************************/

/****************************************************************************************
* Nombre: mostrarPaquete 								*
* Descripcion: Esta funcion imprime por pantalla en hexadecimal un vector		*
* Argumentos: 										*
*  -paquete: bytes que conforman un paquete						*
*  -longitud: Bytes que componen el mensaje						*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t mostrarPaquete(uint8_t * paquete, uint32_t longitud){
	uint32_t i;
	printf("Paquete:\n");
	for (i=0;i<longitud;i++){
		printf("%02"PRIx8" ", paquete[i]);
	}
	printf("\n");
	return OK;
}


/****************************************************************************************
* Nombre: calcularChecksum							     	*
* Descripcion: Esta funcion devuelve el ckecksum tal como lo calcula IP/ICMP		*
* Argumentos:										*
*   -longitud: numero de bytes de los datos sobre los que calcular el checksum		*
*   -datos: datos sobre los que calcular el checksum					*
*   -checksum: checksum de los datos (2 bytes) en orden de red! 			*
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t calcularChecksum(uint16_t longitud, uint8_t *datos, uint8_t *checksum) {
    uint16_t word16;
    uint32_t sum=0;
    int i;
    // make 16 bit words out of every two adjacent 8 bit words in the packet
    // and add them up
    for (i=0; i<longitud; i=i+2){
        word16 = (datos[i]<<8) + datos[i+1];
        sum += (uint32_t)word16;       
    }
    // take only 16 bits out of the 32 bit sum and add up the carries
    while (sum>>16) {
        sum = (sum & 0xFFFF)+(sum >> 16);
    }
    // one's complement the result
    sum = ~sum;      
    checksum[0] = sum >> 8;
    checksum[1] = sum & 0xFF;
    return OK;
}


/***************************Funciones inicializacion implementadas*********************************/

/****************************************************************************************
* Nombre: inicializarPilaEnviar     							*
* Descripcion: inicializar la pila de red para enviar registrando los distintos modulos *
* Retorno: OK/ERROR									*
****************************************************************************************/

uint8_t inicializarPilaEnviar() {
	bzero(protocolos_registrados,MAX_PROTOCOL*sizeof(pf_notificacion));
	if(registrarProtocolo(ETH_PROTO, moduloETH, protocolos_registrados)==ERROR)
		return ERROR;
	if(registrarProtocolo(IP_PROTO, moduloIP, protocolos_registrados)==ERROR)
		return ERROR;
	if(registrarProtocolo(ICMP_PROTO, moduloICMP, protocolos_registrados)==ERROR)
		return ERROR;
	if(registrarProtocolo(UDP_PROTO, moduloUDP, protocolos_registrados)==ERROR)
		return ERROR;
	return OK;
}


/****************************************************************************************
* Nombre: registrarProtocolo 								*
* Descripcion: Registra un protocolo en la tabla de protocolos 				*
* Argumentos:										*
*  -protocolo: Referencia del protocolo (ver RFC 1700)					*
*  -handleModule: Funcion a llamar con los datos a enviar				*
*  -protocolos_registrados: vector de funciones registradas 				*
* Retorno: OK/ERROR 									*
*****************************************************************************************/

uint8_t registrarProtocolo(uint16_t protocolo, pf_notificacion handleModule, pf_notificacion* protocolos_registrados){
	if(protocolos_registrados==NULL ||  handleModule==NULL){		
		printf("Error: registrarProtocolo(): entradas nulas.\n");
		return ERROR;
	}
	else
		protocolos_registrados[protocolo]=handleModule;
	return OK;
}


