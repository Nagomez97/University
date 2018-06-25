# video_client.py
Este módulo es el encargado de gestionar el funcionamiento principal de la aplicación, así como toda la interfaz gráfica.

Cuenta con una clase VideoClient que almacena las diferentes ventanas de la interfaz, así como información relacionada con el usuario y la conexión (puertos, sockets...), e información de la llamada (resolución, FPS, duración...). 

A continuación, explicamos brevemente las funciones más importantes:
* **start()**: inicia la ejecución mostrando la pantalla de *login*.
* **buttonsCallBack(button)**: *listener* que gestiona las acciones que se ejecutan al pulsar algún botón.
* **refreshNickWindow(users)**: actualiza la lista de *nicks* de los usuarios de la aplicación, para mostrarlos en la ventana de Conexión.
* **getNick()**: permite obtener el *nick* introducido por el usuario en el campo de búsqueda.
* **startCall(app, userNick, nick, port, IP)**: interactúa con el módulo *call_connection* para enviar el mensaje de inicio de llamada y analiza la respuesta para saber si ha sido aceptada o rechazada.
* **callListener()**: función que será llamada desde un hilo en segundo plano, encargada de escuchar por el socket TCP a la espera de mensajes de control entrantes (CALL_HOLD, CALL_RESUME...)
* **send_video()**: función que gestiona la emisión de video. Añade las cabeceras al *stream* y muestra por pantalla el video emitido.
* **recv_video()**: función que será llamada desde un hilo en segundo plano, encargada de escuchar por el socket UDP de la llamada actual y recibir los frames de video emitidos por el otro usuario.
* **TCPListener()**: función que se mantiene a la escucha de conexiones TCP entrantes (llamadas).

Volver a [Modulos](Modulos).