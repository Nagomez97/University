/**
* @brief Implementacion de la libreria para demonizar un proceso
* @file daemonize.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/

/*Librerias*/
#include "daemonize.h"

/*Librerias de sistema*/
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <syslog.h>

/**
* daemonize()
* @brief Funcion para demonizar al proceso que la llama
* @param char* nombre para identificar el proceso
* @return OK(0), ERROR(-1)
*/
void daemonize(const char* name){
	int fd, fdsize;
	pid_t pid;
	
	/*Caso de error*/
	if((pid = fork()) < 0){
		exit(EXIT_FAILURE);
	}
	/*Proceso padre*/
	else if(pid > 0){
		exit(EXIT_SUCCESS);
	}

	/*El hijo continua*/

	/*Se crea una nueva sesion para el hijo*/
	if(setsid() < 0){
		exit(EXIT_FAILURE);
	}

	/*Se cambia la mascar de modo de creacion de ficheros a 0777 (todo
	 el mundo puede acceder*/
	umask(0777); // Nunca falla

	/* Se cierran todos los descriptores de fichero que pudiesen 
	 * estar abiertos
	 */
	if((fdsize = getdtablesize()) == -1) fdsize = MAX_OPEN;

	for(fd=0; fd<fdsize; fd++) close(fd);

	/* Se abre el system log
	 * Al usar el paramtreo LOG_PID aparecera el PID del demonio en el log
	 * Al usar LOG_DAEMON se especificara en el log que el mensaje es de un demonio*/
	openlog(name, LOG_PID, LOG_DAEMON);

	/*IMensaje inicial de syslog
	 * LOG_NOTICE usado en notificaciones normales
	 * LOG_INFO usado en mensajes informativos
	 * LOG_ERR usado en condiciones de error
	 * LOG_DEBUG iusado en debbuging */
	syslog(LOG_INFO, "Daemon started");

	return;
}