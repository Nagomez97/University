/**
* @brief Implementacion de la libreria para procesar una petición
* @file request.c
* @author Óscar Gómez, José Ignacio Gómez
* @version 1.0
* @date 17/02/2018
*/
#define _GNU_SOURCE

/*Librerias*/
#include "picohttpparser.h"
#include "macros.h"
#include "request.h"

/*Librerias de sistema*/
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <syslog.h>
#include <assert.h>

/**
* get_date()
* @brief Funcion para obtener la cabecera Date
* @param none
* @return char* Cabecera Date, hace falta liberar la memoria fuera
*/
char* get_date(){
	char *date = (char*) malloc (1000 * sizeof(char));
	time_t now = time(0);
	struct tm tm = *gmtime(&now);
	strftime(date, 1000, "Date: %a, %d %b %Y %H:%M:%S %Z\n", &tm);
	return date;
}

/**
* send_error_body()
* @brief Funcion generica para enviar el cuerpo de un mensaje desde fichero
* @param desc: descriptor del socket
* @param complete_path: path del html de error
* @return -1 en caso de error
*/
int send_error_body(int desc, char* complete_path){
	int f; //Fichero a leer
	int rret; //Retorno del read
	char buffer[MAX_MSG]; //Buffer donde almacenar lo leido

	//Apertura de fichero y lectura, en caso de fallo enviar error
	f = open(complete_path, O_RDONLY);
	if(f < 0){
		return ERROR; //TODO error reading file (codigo 418?? codigo 500??)
	}

	while((rret = read(f, buffer, MAX_MSG)) > 0){
		/*Mandamos lo leido parcialmente (8 Mb como maximo)*/
		write(desc, (void*) buffer, rret);
	}

	close(f);

	return OK;
}

/**
* create_error_response()
* @brief Funcion generica para crear una respuesta en caso de error
* @param desc: descriptor del socket
* @param server_signature: nombre del servidor
* @param server_path: path del servidor
* @param errorcode: codigo de error
* @param minor_version: version http.
* @return -1 en caso de error
*/
int create_error_response(int desc, char* server_signature, char* server_path, int errorcode, int minor_version){
	char *msg = (char *) malloc (MAX_MSG * sizeof(char));
	char *time;
	struct stat fileStat;
	char size[10]; //Tamaño del fichero
	char modified_s[1000];
	time_t modified;
	char complete_path[MAX_MSG];
	char text[MAX_MSG];

	switch(errorcode){ // Dependiendo del codigo de error mandamos un archivo u otro
		case BAD_REQ:
			sprintf(text, "HTTP/1.%d 400 Bad Request\r\n", minor_version);
			sprintf(complete_path, "%serrors/parse_error.html", server_path);
			break;
		case NOT_FOUND:
			sprintf(text, "HTTP/1.%d 404 Not Found\r\n", minor_version);
			sprintf(complete_path, "%serrors/not_found.html", server_path);
			break;
		case METHOD_NOT_ALW:
			sprintf(text, "HTTP/1.%d 405 Method Not Allowed\r\n", minor_version);
			sprintf(complete_path, "%serrors/method_error.html", server_path);
			break;
		case TOO_LONG:
			sprintf(text, "HTTP/1.%d 413 Request Entity Too Large\r\n", minor_version);
			sprintf(complete_path, "%serrors/too_long_error.html", server_path);
			break;
		case SERVER_ERROR:
			sprintf(text, "HTTP/1.%d 500 Internal Server Error\r\n", minor_version);
			sprintf(complete_path, "%serrors/internal_error.html", server_path);
			break;
		default:
			return ERROR;
	}

	//algun tipo de error
	if(stat(complete_path, &fileStat) < 0){
			free(msg);
			syslog(LOG_ERR, "Error al abrir el fichero.");
			return ERROR;
	}

	// Conseguimos los datos del fichero
	sprintf(size, "%ld\r\n", fileStat.st_size);
	modified = fileStat.st_mtime;
	struct tm tm = *gmtime(&modified);
	strftime(modified_s, sizeof(modified_s), "Last-Modified: %a, %d %b %Y %H:%M:%S %Z\r\n", &tm);
	time = get_date();
	

	strcpy(msg, text);
	strcat(msg, time);
	strcat(msg, "Server: ");
	strcat(msg, server_signature);
	strcat(msg, "\r\nContent-Length: ");
	strcat(msg, size);
	strcat(msg, "Content-Type: text/html\r\n\r\n");
	
	/*Manda la cabecera del mensaje de error*/
	write(desc, (void *) msg, strlen(msg));

	send_error_body(desc, complete_path);

	free(time);

	return ERROR;
}


/*
* send_header()
* @brief Funcion que envia las cabeceras del get
* @param desc: descriptor del socket
* @param filetype: tipo de fichero
* @param server_signature: nombre del servidor
* @param complete_path: path completo del archivo
* @param server_path: path del servidor
* @param minor_version: version HTTP
* @param temp: fichero temporal donde los scripts escriben su salida
* @return -1 en caso de error
*/
int send_header(int desc, char* filetype, char* server_signature, char* complete_path, char* server_path, int minor_version, int temp){
	struct stat fileStat;
	char size[10]; //Tamaño del fichero
	time_t modified; //Fecha de ultima modificacion
	char modified_s[1000], *date; //Fechas
	char *msg = (char *)malloc(sizeof(char)*MAX_MSG); //Mensaje a enviar
	char version[10];

	if(strlen(complete_path) <= 5){
		free(msg);
		create_error_response(desc, server_signature, server_path, NOT_FOUND, minor_version);
		return ERROR;
	}

	//algun tipo de error
	if(stat(complete_path, &fileStat) < 0){
		free(msg);
		create_error_response(desc, server_signature, server_path, NOT_FOUND, minor_version);
		return ERROR;
	}

	// Conseguimos los datos del fichero

	// Size del fichero en el que se guarda la ejecucion del script
	if(temp >= 0){
		sprintf(size, "%ld\r\n", lseek(temp, 0, SEEK_END)); // obtenemos su posicion
		lseek(temp, 0, SEEK_SET);
	}
	else
		sprintf(size, "%ld\r\n", fileStat.st_size);

	modified = fileStat.st_mtime;
	struct tm tm = *gmtime(&modified);
	strftime(modified_s, sizeof(modified_s), "Last-Modified: %a, %d %b %Y %H:%M:%S %Z\r\n", &tm);
	date = get_date();

	//Creamos la cabecera
	sprintf(version, "HTTP/1.%d", minor_version);
	strcpy(msg, version);
	strcat(msg, "200 OK\r\n");
	strcat(msg, date);
	strcat(msg, "Server: ");
	strcat(msg, server_signature);
	strcat(msg, "\r\n");
	strcat(msg, modified_s);
	strcat(msg, "Conection: close\r\n");
	strcat(msg, "Content-Length: ");
	strcat(msg, size);
	strcat(msg, "Content-Type: ");
	strcat(msg, filetype);
	strcat(msg, "\r\n\r\n");

	if(write(desc, (void*) msg, strlen(msg)) < 0){
		free(msg);
		free(date);
		return ERROR;
	}

	free(date);
	free(msg);

	return OK;
}

/**
* get_send_body()
* @brief Funcion para enviar el cuerpo del get
* @param desc: descriptor del socket
* @param temp: archivo temporal de ejcucion
* @return -1 en caso de error
*/
int get_send_body(int desc, int temp){
	int rret; //Retorno del read
	char buffer[MAX_MSG]; //Buffer donde almacenar lo leido

	while((rret = read(temp, buffer, MAX_MSG)) > 0){
		/*Mandamos lo leido parcialmente (8 Mb como maximo)*/
		write(desc, (void*) buffer, rret);
	}
	if(rret < 0){
		return ERROR;
	}

	return OK;
}



/**
* exec_script()
* @brief Funcion para ejecutar un script y mandar el resultado
* @param command: comando completo a ejecutar
* @param temp: file donde se almacena la ejecucion
* @param body: argumentos desde post
*/
void exec_script(char* command, int temp, char* body){
	FILE* stream = NULL; // Stream del pipe
	int fd; // Descriptor del stream
	int rret;
	char buffer[MAX_MSG];
	char pipe[MAX_WORD];

	/*Si el body no esta vacio, venimos de un post.
	En este caso, le metemos los argumentos por stdin a 
	traves de un pipe " | "*/ 
	if(body){
		sprintf(pipe, "echo \"%s\" | ", body);
		strcat(pipe, command);
		command = pipe;
	}

	if((stream = popen(command, "r")) == NULL){
		// Posible error de servidor
		syslog(LOG_ERR, "Error ejecutando el script");
		return;
	}

	fd = fileno(stream);

	while((rret = read(fd, buffer, MAX_MSG)) > 0){
		write(temp, buffer, rret);
	}

	pclose(stream);
}

/**
* filter_url()
* @brief Funcion para procesar una url y obtener todo lo necesario
* @param char* url, de donde se sacará la información, se verá truncado.
* @param char* arguments, aquí se devolveran los argumentos
* @param char* filetype, aqui se devolvera el string con el tipo de fichero segun su extension
* @return PYTHON, PHP or 0 if none of them
*/
int filter_url(char* url, char* arguments, char* filetype){
	char *dot = strrchr(url, '.'); //Puntero al ultimo punto
	char *inter = strchr(url, '?'); //Puntero a la primera interrogacion
	char extension[10];

	if(!inter || inter == url){
		if(dot && dot != url){
			strcpy(extension, dot); //Si no hay interrogaciones y si hay un punto, tenemos la extension
		}
		arguments[0] = '\0';
	}
	else{
		if(dot && dot != url){
			sprintf(extension, "%.*s", (int) (inter - dot), dot);
		}
		strcpy(arguments, inter+1); //Copìamos los argumentos
		inter[0] = '\0'; //Quitamos los argumentos de la url
	}
	if(!dot || dot == url){
		filetype[0] = '\0'; //Si no hay extension
	}
	// comprobacion resto de casos
	else if(strncmp(extension, ".txt", 4) == 0)
		strcpy(filetype, "text/plain");
	else if(strncmp(extension, ".html", 5) == 0 || strcmp(extension, ".htm") == 0)
		strcpy(filetype, "text/html");
	else if(strncmp(extension, ".gif", 4) == 0)
		strcpy(filetype, "image/gif");
	else if(strncmp(extension, ".jpeg", 5) == 0 || strcmp(extension, ".jpg") == 0)
		strcpy(filetype, "image/jpeg");
	else if(strncmp(extension, ".png", 5) == 0 || strcmp(extension, ".png") == 0)
		strcpy(filetype, "image/png");
	else if(strncmp(extension, ".mpeg", 5) == 0 || strcmp(extension, ".mpg") == 0)
		strcpy(filetype, "video/mpeg");
	else if(strncmp(extension, ".doc", 4) == 0 || strcmp(extension, ".docx") == 0)
		strcpy(filetype, "application/msword");
	else if(strncmp(extension, ".pdf", 4) == 0)
		strcpy(filetype, "application/pdf");
	else if(strncmp(extension, ".php", 4) == 0){
		strcpy(filetype, "text/html");
		return PHP;
	}
	else if(strncmp(extension, ".py", 3) == 0){
		strcpy(filetype, "text/html");
		return PYTHON;
	}
	else if(strncmp(extension, ".ico", 4) == 0)
		strcpy(filetype, "image/x-icon");
	else
		strcpy(filetype, "NO FILETYPE");
	return OK;
}

/**
* get_request()
* @brief Funcion para procesar una petición de tipo GET y enviar el mensaje
* @param desc: descriptor del socket
* @param server_signature: tipo de servidor
* @param complete_path: path completo del fichero
* @param server_path: path del servidor
* @param minor_version: version HTTP
* @return -1 en caso de error
*/
int get_request(int desc, char* server_signature, char* complete_path, char* server_path, int minor_version){
	char arguments[MAX_WORD]; //Argumentos de posibles Scripts
	char filetype[MAX_WORD]; //Cabecera de tipo de fichero enviado
	int temp, type;

	char command[2*MAX_PATH];

	type = filter_url(complete_path, arguments, filetype);

	// Guardaremos la ejecucion en un fichero temporal
	temp = open(".", O_RDWR | O_TMPFILE);

	if(temp < 0){
		syslog(LOG_ERR, "Error abriendo archivo temporal");
		return ERROR;
	}

	if(type == PYTHON){
		sprintf(command, "python %s \"%s\"", complete_path, arguments);
		exec_script(command, temp, NULL);
		if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, temp) < 0) return ERROR;
		get_send_body(desc, temp);
		close(temp);
		return minor_version;
	}
	else if(type == PHP){
		sprintf(command, "php %s \"%s\"", complete_path, arguments);
		exec_script(command, temp, NULL);
		if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, temp) < 0) return ERROR;
		get_send_body(desc, temp);
		close(temp);
		return minor_version;
	}

	close(temp);


	/*Enviamos la cabecera.
	El cliente se quedara esperando hasta leer los bytes que especifique
	la longitud del fichero*/
	if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, -1) < 0) return ERROR;



	/*Enviamos el cuerpo del mensaje.
	Internamente, esta funcion dividira el cuerpo en
	trozos de 8MB*/
	
	temp = open(complete_path, O_RDONLY);
	if(temp < 0){
		return create_error_response(desc, server_signature, server_path, SERVER_ERROR, minor_version);
	}

	get_send_body(desc, temp);

	close(temp);

	return OK;
}

/**
* post_request()
* @brief Funcion para procesar una petición de tipo POST
* @param desc: Descriptor del socket
* @param server_signature: Nombre del servidor
* @param complete_path: Path completo del fichero.
* @param server_path: Path a la carpeta donde se almacenan los archivos del servidor
* @param minor_version: Version HTTP/1.?
* @param body: Cuerpo de la peticion
* @return -1 en caso de error
*/
int post_request(int desc, char* server_signature, char* complete_path, char* server_path, int minor_version, char* body){
	char arguments[MAX_WORD]; //Argumentos de posibles Scripts
	char filetype[MAX_WORD]; //Cabecera de tipo de fichero enviado
	int temp, type;

	char command[2*MAX_PATH];

	type = filter_url(complete_path, arguments, filetype);

	// Guardaremos la ejecucion en un fichero temporal
	temp = open(".", O_RDWR | O_TMPFILE);

	if(temp < 0){
		syslog(LOG_ERR, "Error abriendo archivo temporal");
		return ERROR;
	}

	if(type == PYTHON){
		sprintf(command, "python %s \"%s\"", complete_path, arguments);
		exec_script(command, temp, body);
		if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, temp) < 0) return ERROR;
		get_send_body(desc, temp);
		close(temp);
		return minor_version;
	}
	else if(type == PHP){
		sprintf(command, "php %s \"%s\"", complete_path, arguments);
		exec_script(command, temp, body);
		if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, temp) < 0) return ERROR;
		get_send_body(desc, temp);
		close(temp);
		return minor_version;
	}

	close(temp);


	/*Enviamos la cabecera.
	El cliente se quedara esperando hasta leer los bytes que especifique
	la longitud del fichero*/
	if(send_header(desc, filetype, server_signature, complete_path, server_path, minor_version, -1) < 0) return ERROR;



	/*Enviamos el cuerpo del mensaje.
	Internamente, esta funcion dividira el cuerpo en
	trozos de 8MB*/
	
	temp = open(complete_path, O_RDONLY);
	if(temp < 0){
		return create_error_response(desc, server_signature, server_path, SERVER_ERROR, minor_version);
	}

	get_send_body(desc, temp);

	close(temp);

	return minor_version;
}

/**
* options_request()
* @brief Funcion para procesar una petición de tipo OPTIONS y enviar el mensaje
* @param desc: descriptor del socket
* @param server_signature: tipo de servidor
* @param minor_version: version HTTP
* @return -1 en caso de error
*/
int options_request(int desc, char* server_signature, int minor_version){
	char msg[MAX_MSG], *date;

	date = get_date();
	sprintf(msg, "HTTP/1.%d ", minor_version);
	strcat(msg, "200 OK\r\n");
	strcat(msg, date);
	strcat(msg, "Server: ");
	strcat(msg, server_signature);
	strcat(msg, "\r\n");
	strcat(msg, "Content-Length: 0\r\n");
	strcat(msg, "Allow: OPTIONS, GET, POST\r\n\r\n");

	if(write(desc, (void*) msg, strlen(msg)) < 0){
		free(date);
		return ERROR;
	}

	free(date);

	return minor_version;
}

/**
* process_request()
* @brief Funcion para procesar una petición
* @param desc: descriptor del socket
* @param server_signature: nombre del servidor
* @param server_path: path del server 
* @return -1 en caso de error, version http en caso de acierto
*/
int process_request(int desc, char* server_signature, char* server_path){
	const char *method; //Metodo (GET POST OPTIONS ...)
    size_t method_len;
    const char *path; //Path relativo
    size_t path_len;
    int minor_version; //Version http 1.?
    struct phr_header headers[MAX_HEADERS]; //Cabeceras
    size_t num_headers = MAX_HEADERS;
    char complete_path[MAX_WORD];
    char body[MAX_MSG];

    char str_path[MAX_PATH];
    char aux[MAX_PATH];


    size_t buflen = 0, prevbuflen = 0;
    char buf[MAX_MSG];
    ssize_t rret;
    int pret;

    int flag = 0;

    while(flag == 0) {

    	/*Leemos el request*/
    	while((rret = read(desc, buf+buflen, sizeof(buf) - buflen)) == -1 && errno == EINTR);


    	/*Error de entrada*/
    	if (rret <= 0)
    		return ERROR;
 
    	prevbuflen = buflen;
    	buflen += rret;

    	/*Parseo*/
    	num_headers = MAX_HEADERS;
    	pret = phr_parse_request(buf, buflen, &method, &method_len, &path, &path_len,
                             &minor_version, headers, &num_headers, prevbuflen);

    	
    	sprintf(str_path, "%s", server_path);

    	/*Control de la salida*/
    	if (pret > 0){
    		flag = 1;
    	}
		else if (pret == -1){
			// Error de parseo
			if (create_error_response(desc, server_signature, server_path, BAD_REQ, minor_version) < 0){
				return ERROR;
			}
			return minor_version;
	    }    
	    /* El request esta incompleto, se vuelve al bucle */
	    if (flag == 0) 
	    	assert(pret == -2);
	    
	    if (buflen == sizeof(buf)){
	    	// Error de longitud
	    	if (create_error_response(desc, server_signature, server_path, TOO_LONG, minor_version) < 0){
	    		return ERROR;
	    	}
	    	return minor_version;
	    }    

    }

    // Obtenemos el path completo
    strcpy(complete_path, str_path);
    sprintf(aux, "%.*s", (int) path_len, path);
    sprintf(complete_path, "%s%s", str_path, aux + 1);


	/*En caso de que no falle, ret sera el comienzo del mensaje (importante en POST)*/

    if(strncmp(method, "GET", 3) == 0){ //Metodo GET
    	syslog(LOG_INFO, "Recibida petición GET");
    	if (get_request(desc, server_signature, complete_path, str_path, minor_version) < 0){
    		return ERROR;
    	}
    	return minor_version;
    }
    else if(strncmp(method, "POST", 4) == 0){ //Metodo POST
    	syslog(LOG_INFO, "Recibida petición POST");
    	// Guardamos el body del post
    	sprintf(body, "%.*s", (int)(buflen-pret), buf+pret);
    	
    	if (post_request(desc, server_signature, complete_path, str_path, minor_version, body) < 0){
    		return ERROR;
    	}
    	return minor_version;
    }
    else if(strncmp(method, "OPTIONS", 7) == 0){ //Metodo OPTIONS
    	syslog(LOG_INFO, "Recibida petición OPTIONS");
    	if (options_request(desc, server_signature, minor_version) < 0){
    		return ERROR;
    	}
    	return minor_version;
	}
	else{
	    if (create_error_response(desc, server_signature, server_path, METHOD_NOT_ALW, minor_version) < 0){
	    	return ERROR;
	    }
	    return OK;
		
	}

   	return ERROR;
}