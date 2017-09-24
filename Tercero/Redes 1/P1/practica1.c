#include "practica1.h"

int main(int argc, char** argv){
	int num;
	char* aux;

	/*Sin argumentos*/
	if(argc <= 1) return show_help();

	/*Cambio del string argv[1] a un número entero*/
	num = atoi(argv[1]);
	if(num < 1) return show_help(); /*Comprobamos que sea positivo y no 0*/

	/*Un argumento*/
	/*if(argc == 2) return live_capture(num);

	/*Comprobamos que el fichero sea un archivo pcap, por lo tanto tiene que acabar con ".pcap"*/
	aux = strrchr(argv[2], '.');
	if(aux == NULL) return show_help();
	if(strcmp(".pcap", aux) != 0) show_help();

	/*Dos argumentos*/
	if(argc == 3) return pcap_analyze(num, argv[2]);

	/*Mas de dos argumentos*/
	else return show_help();
}