# Uso de la interfaz
Nuestra aplicación emplea la librería appJar para gestionar la interfaz. En este apartado explicamos su funcionamiento.

## Login
Al iniciar el cliente se abrirá una pantalla de *login*. Aquí deberá introducir un usuario y una contraseña que, en caso de no existir, será registrado.

![login](/uploads/b98cfdd37d447e248fe99a595968aae6/login.png)

## Pantalla principal
Aquí verá tres botones con distintas funciones:
* **Conectar**: abre una pantalla de Conexión desde la que podremos seleccionar el *nick* del usuario al que queremos llamar
* **Elegir Fuente**: permite elegir el origen del video emitido. En caso de elegir *fichero*, se abrirá una ventana desde la que se podrá buscar un fichero de video compatible.
* **Salir**: cierra la aplicación.

Además, en la parte inferior de la pantalla podrá consultar información sobre los FPS recibidos y la duración de la llamada.

![Main](/uploads/b55d8e02a57f93aa981693acfa5bed0b/Main.png)

## Pantalla de conexión
Tras pulsar el botón **Conectar** de la pantalla principal, deberá elegir el *nick* del usuario al que quiera llamar. Para ello podrá escribir su nombre en el campo correspondiente, o seleccionarlo desde el desplegable. 

![conexion](/uploads/dd97fddfdd4c4c9c58b69d5d913378fa/conexion.png)

Desafortunadamente, no aparecen todos los nicks en el desplegable, ya que no hemos implementado una funcionalidad de *scrolling*. Tras elegir un *nick*, pulsando el botón **Llamar** se iniciará la llamada. En caso de no estar conectado el otro usuario, se mostrará una ventana informativa.

## Llamada
Al iniciar una llamada, se abrirá una segunda ventana en la que se mostrará el video recibido. Desde la ventana principal podrá ver el video emitido, así como la información de la llamada. También aparecerán dos botones:
* **Pausar/Reanudar**: permite pausar y reanudar la llamada. Al pulsarlo se enviará un mensaje de control al otro usuario, permitiendo sincronizar ambos temporizadores.
* **Colgar**: finaliza la llamada. Envía un mensaje de control al otro usuario, finalizando también la llamada en el otro extremo.

Volver al [Indice](Indice)
