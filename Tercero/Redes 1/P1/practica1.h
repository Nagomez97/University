/**
* file practica1.h
* author Jose Ignacio Gomez, Óscar Gómez
* date 22/09/17
*/


/*Codigos de salida del programa*/
#define EXIT_OK = 0
#define EXIT_ERROR = -1

/*Codigos de salida de la funcion de lectura de paquetes pcap*/
#define PCAP_OK = 1
#define PCAP_ERROR = -1
#define PCAP_TIMEOUT = 0
#define PCAP_FILE_END = -2

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef PRACTICA1_H
#define PRACTICA1_H

/***************************************************************
Nombre:
    show_help
Descripcion:
    Muestra la ayuda en pantalla
Entrada:
    none
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/
int show_help();

/***************************************************************
Nombre:
    live_capture
Descripcion:
    Captura en vivo los paquetes de la interfaz eth0
Entrada:
    int num: número de bytes a mostrar por paquete, tiene que ser positivo.
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/
int live_capture(int num);

/***************************************************************
Nombre:
    pcap_analyze
Descripcion:
    Analiza la traza de un archivo .pcap
Entrada:
    int num: número de bytes a mostrar por paquete, tiene que ser positivo.
    char* trace: traza pcap a analizar, tiene que ser un archivo .pcap.
Salida:
    int, será el código de error que devolverá el programa completo
************************************************************/
int pcap_analyze(int, char* trace);

#endif
