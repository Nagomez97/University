/**
* @brief Implementacion de la libreria de utilidades
* básicas del servidor
* @file server.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/

/*Librerias*/
#include "server-fun.h"

/*Librerias de sistema*/
#include <strings.h>
#include <stdlib.h>
#include <syslog.h>
#include <netinet/ip.h> 

/**
* init_server(int port, int max_connections)
* @brief Funcion para inicializar un socket de servidor
* @param port: puerto al que registrar el socket
* @param max_connections maximo de conexiones
* @return numero del servidor devuelto por socket()
*/
int init_server(int port, int max_connections){
	int sockfd;
	struct sockaddr_in Server;

	syslog(LOG_INFO, "Creating socket");

	/*
	 * Creamos el socket con los siguientes parametros:
	 * AF_INET: familia de direcciones IPv4
	 * SOCK_STREAM: tipo del conector STREAM (TCP)
	 * 0: indica que solo un protocolo (TCP) es valido para nuestro tipo
	 */
	if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
		syslog(LOG_ERR, "Error creating socket");
		exit(EXIT_FAILURE);
	}

	/*Inicializamos la estructura del socket*/
	Server.sin_family = AF_INET; /* Familia IPv4*/
	Server.sin_port = htons(port); /*Asignamos el puerto*/
	Server.sin_addr.s_addr = htonl(INADDR_ANY); /*Aceptamos todas*/
	bzero((void *) &(Server.sin_zero), 8);

	/*Hacemos el bin para registrar el socket en un puerto*/
	syslog(LOG_INFO, "Binding socket");

	/*
	 * Llamamos a bind con los siguientes argumentos:
	 * sockfd: parametro devuelto por socket()
	 * localaddr: struct donde se recibe la direccion del socket
	 * tamaño del struct Server
	 */
	if(bind(sockfd, (struct sockaddr *) &Server, sizeof(Server)) < 0){
		syslog(LOG_ERR, "Error binding socket");
		exit(EXIT_FAILURE);
	}
	
	/*Escuchamos conexiones*/
	syslog(LOG_INFO, "Listening connections");

	if(listen(sockfd, max_connections) < 0){
		syslog(LOG_ERR, "Error listening");
		exit(EXIT_FAILURE);
	}

	return sockfd;
}

/**
* accept_connection(int sockfd)
* @brief Funcion para aceptar conexiones
* @param sockfd numero del socket
* @return descriptor de la conexion aceptada
*/
int accept_connection(int sockfd){
	int desc;
	uint len;
	struct sockaddr Server;

	len = sizeof(Server);
	syslog(LOG_DEBUG, "Accepting connection");
	if((desc = accept(sockfd, &Server, &len)) < 0){
		syslog(LOG_ERR, "Error accepting connection");
		exit(EXIT_FAILURE);
	}

	syslog(LOG_INFO, "Connection accepted");

	return desc;

}