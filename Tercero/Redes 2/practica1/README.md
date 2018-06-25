# Práctica 1 Redes de Comunicaciones II
## Doble grado en ingeniería informática y matemáticas 2017-18

## Servidor web

## División de directorios
En este proyecto estamos siguiendo el siguiente esquema de directorios para la búsqueda efectiva de recursos:

* __includes/__: Carpeta donde se sitúan las cabeceras realizadas por nosotros, los ficheros son de tipo .h.
* __lib/__: Lugar donde se guardan las librerías compiladas, son de tipo .a.
* __src/__: Lugar donde se encuentran los ficheros de código que generan el programa principal. Deben tener un método main.
* __srclib/__: Lugar donde se encuentran los ficheros de código que generan las librerías.
* __test/__: Lugar donde se encuentran los ficheros de código que generan programas de prueba. Deben tener un método main.
* __www/__: Lugar donde se encuentran los ficheros del servidor al que se podrá acceder mediante peticiones.

## Makefile
El makefile ha sido creado de manera que detecta automáticamente nuevos ficheros a compilar. Para ello es muy importante que se sigan las directivas especificadas en el apartado anterior.

### Funciones:

* __help__: Muestra las opciones del makefile
* __all__: Crea todos los ejecutables, los de pruebas y los del servidor completo
* __exec__: Crea solo los ejecutables del servidor completo
* __test__: Crea solo los ejecutables de prueba
* __libs__: Recompila las librerias, borrándolas previamente.
* __clean__: Borra los ejecutables. ¡OJO! No borra librerias
* __cleanlibs__: Borra las librerias.
* __cleanall__: Borra todo, ejecutables y librerias.


## Librerias y preparación
Para el correcto funcionamiento de esta práctica se deberá tener las librerias _libconfuse-dev_ y _php_. Para ello ejecuta el script __install-dependencies.sh__ con permisos de root.
