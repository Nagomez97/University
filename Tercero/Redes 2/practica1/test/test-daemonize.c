/**
* @brief Programa de prueba para el demonizador
* @file test-daemonize.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/

/*Librerias*/
#include "daemonize.h"

/*Librerias de sistema*/
#include <stdlib.h>

int main(int argc, char* argv[]){
	const char *name = "Redes_Daemon";

	daemonize(name);

	while(1);

	/*openlog("Redes_Daemon", LOG_PID, LOG_DAEMON);
	syslog(LOG_NOTICE, "Daemon started.");
	closelog();*/

	return EXIT_SUCCESS;

}
