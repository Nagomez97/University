/**
* @brief Declaracion de la libreria para procesar una petición
* @file request.h
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 17/02/2018
*/

#ifndef REQUEST_H
#define REQUEST_H

#define MAX_HEADERS 20 //Numero maximo de cabeceras por peticion

/* Tipos de scripts*/
#define PYTHON 1
#define PHP 2

/**
* process_request()
* @brief Funcion para procesar una petición
* @param desc: descriptor del socket
* @param server_signature: nombre del servidor
* @param server_path: path del server
* @return -1 en caso de error, version http en caso de acierto
*/
int process_request(int desc, char* server_signature, char* server_path);

#endif //REQUEST_H