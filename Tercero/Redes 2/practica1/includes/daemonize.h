/**
* @brief Declaracion de la libreria para demonizar un proceso
* @file daemonize.h
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/
#ifndef DAEMONIZE_H
#define DAEMONIZE_H

/*Macros*/
#define MAX_OPEN 256 //

/**
* daemonize()
* @brief Funcion para demonizar al proceso que la llama
* @param char* nombre para identificar el proceso
* @return OK(0), ERROR(-1)
*/
void daemonize(const char* name);

#endif //DAEMONIZE_H