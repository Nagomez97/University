# call_connection.py
Este módulo implementa las funciones del protoclo V1 que hemos creado para la práctica. De cara a futuros cambios en el protocolo, todas las funciones terminan con el nombre del procolo (en este caso, V1). Esta es la parte de la aplicación que realmente envía y recibe paquetes, ya que es desde la que se llaman a las funciones *send* y *recv* de la librería *socket*.

Internamente, cada función se encarga de crear el mensaje adecuado para cada interacción (según el protocolo) y de enviarlo a través del *socket* correspondiente.

Es importante destacar que todos los mensajes tienen que ser codificados (UTF-8) antes de ser enviados, y decodificados al recibirlos. 

Volver a [Modulos](Modulos).

