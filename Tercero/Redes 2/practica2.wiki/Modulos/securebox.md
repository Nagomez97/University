<h1>Securebox</h1>
Este módulo permite la interacción con el servidor vega. Cada función emplea la librería *requests* para crear una petición HTTP-POST y enviarla al servidor.
A continuación se detallan las funciones implementadas:
* **getPublicKey(user, id):** obtiene la clave pública de un usuario consultando su ID.
* **registerUser(user):** registra un usuario en la plataforma, devolviendo su nombre y su timestamp.
* **searchUser(data, user):** busca un usuario por su nombre o su email.
* **deleteUser(user):** elimina un usuario de la plataforma usando su ID.
* **uploadFile(user, file_path):** sube un archivo a la plataforma, devolviendo su ID y su tamaño.
* **downloadFile(user, file_id):** descarga un archivo y devuelve el contenido binario del mismo.
* **listFile(user):** devuelve una lista con los archivos subidos por el usuario al servidor, así como su cantidad.
* **deleteFile(user, file_id):** elimina un archivo del servidor, devolviendo su ID.

Volver a [Modulos](Modulos).