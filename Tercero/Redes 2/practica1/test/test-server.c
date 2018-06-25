/**
* @brief Servidor
* @file test-server.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/

#include "server-fun.h"
#include "daemonize.h"

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <string.h>
#include <stdlib.h>
#include <syslog.h>
#include <netinet/ip.h> 

int main(){
	int sockfd, desc;
	char str_rcv[1000];
	sockfd = init_server(8888, 20);
	char message[1000];


	while(1){

		desc = accept_connection(sockfd);

		while(1){
			memset(str_rcv,0,sizeof(str_rcv));
			memset(message,0,sizeof(message));
			recv(desc, str_rcv, 1000, 0);
			printf("He recibido %s\n", str_rcv);
			sprintf(message, "He recibido %s", str_rcv);
			write(desc, (void*)message , strlen(message));
		}

		close(desc);
	}
}