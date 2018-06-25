/**
* @brief Declaracion de la libreria de utilidades
* básicas del servidor
* @file server-fun.h
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 14/02/2018
*/
#ifndef SERVER_FUN_H
#define SERVER_FUN_H

/**
* init_server(int port, int max_connections)
* @brief Funcion para inicializar un socket de servidor
* @param port: puerto al que registrar el socket
* @param max_connections maximo de conexiones
* @return numero del servidor devuelto por socket()
*/
int init_server(int port, int max_connections);

/**
* accept_connection(int sockfd)
* @brief Funcion para aceptar conexiones
* @param sockfd numero del socket
* @return descriptor de la conexion aceptada
*/
int accept_connection(int sockfd);


#endif //SERVER_FUN_H