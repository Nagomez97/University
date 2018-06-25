/**
* @brief Servidor Completo
* @file server-fun.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.1
* @date 14/02/2018
*/

/*Librerias*/
#include "server-fun.h"
#include "daemonize.h"
#include "macros.h"
#include "request.h"

/*Librerias de sistema*/
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <confuse.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <syslog.h>

typedef struct _Server_Data{
	char server_signature[MAX_WORD];
	char server_root[MAX_WORD];
	int desc;
} Server_Data; //Estructura para almacenar datos del servidor, así como el descriptor de socket

sem_t semaforo; //Semáforo para controlar el número de threads

/**
* thfun(void *arg)
* @brief Función a ejecutar por todos los threads
* @param void* (Será una estructura Server_Data)
*/
void * thfun(void *arg){
	Server_Data *data = (Server_Data *)arg;
	char server_signature[MAX_WORD] ; 
	char server_root[MAX_WORD];
	int desc = data->desc;
	int ret = 1;

	strcpy(server_signature, data->server_signature);
	strcpy(server_root, data->server_root);

	free(data);

	pthread_detach(pthread_self()); 

	while(ret){ // Si es HTTP/1.0 no continuará con el while
		
		ret = process_request(desc, server_signature, server_root);

		if (ret < 0){
			syslog(LOG_ERR, "Error processing request.");
			break;
		}

	}
	close(desc); //Cerramos el socket
	sem_post(&semaforo); 
	return NULL;
}

/*Método main*/
int main(){
	long int max_clients; //Modificado por fichero de configuracion
	long int port; //Modificado por fichero de configuracion
	char *root = NULL; //Modificado por fichero de configuracion
	char *signature = NULL; //Modificado por fichero de configuracion
	int sockfd; //Descriptor de socket
	pthread_t th;
	Server_Data *data = NULL; //Datos para operaciones; 

	/*Estructura para confuse*/
	cfg_opt_t opts[] = {
		CFG_SIMPLE_INT("listen_port", &port),
		CFG_SIMPLE_STR("server_root", &root),
		CFG_SIMPLE_STR("server_signature", &signature),
		CFG_SIMPLE_INT("max_clients", &max_clients),
		CFG_END()
	};
	cfg_t *cfg;

	/*Inicio del cfg*/
	cfg = cfg_init(opts, 0);

	/*Parseo del fichero de configuracion*/
	cfg_parse(cfg, "server.conf");
	
	/*Demonizamos el proceso*/

	daemonize("Servidor-Redes2");

	syslog(LOG_INFO, "Listening on port %ld", port);
	syslog(LOG_INFO, "Server root %s", root);
	syslog(LOG_INFO, "Server Signature %s", signature);
	syslog(LOG_INFO, "Max clients %ld", max_clients);

	/*Creamos un semáforo compartido entre todos los threads, tiene valor inicial el número máximo de threads*/
	sem_init(&semaforo, 0, max_clients);

	/*Iniciamos el servidor*/
	sockfd = init_server(port, max_clients);

	/*Bucle general*/
	while(1){
		sem_wait(&semaforo); // Bajamos en uno el semaforo
		data = NULL;
		data = (Server_Data *) malloc(sizeof(Server_Data));
		if(data == NULL){
			syslog(LOG_ERR, "Error malloc for data");
			continue;
		}
		strcpy(data->server_signature, signature);
		strcpy(data->server_root, root);
		data->desc = accept_connection(sockfd); //Aceptamos una conexion
		pthread_create(&th, NULL, &thfun, (void *) data); //Pasamos la estructura a un nuevo thread
	}

	return OK;
}