<h1>Securebox_client</h1>
Este módulo es el encargado de gestionar nuestro cliente local. En él se define una clase *secure_client* que engloba las funciones de interacción con los demás módulos, así como un parser (que usa la librería *argparse*).

A continuación detallamos las funciones implementadas en este módulo:
<h2>Funciones locales</h2>
* **encrypt(file):** cifra ficheros usando RSA y la clave pública del destinatario.
* **decrypt(file):** descifra ficheros RSA usando la clave privada del destinatario.
* **sign(file):** firma ficheros usando SHA-256 y la clave privada del usuario.
* **check_sign(file):** comprueba la validez de la firma digital de un fichero.
* **enc_sign(file):** firma y cifra un fichero.
* **dec_csign(file):** descifra y comprueba la firma de un fichero.

Todas estas funciones almacenan los ficheros resultantes en el directorio *Archivos/*.

<h2>Interacción con la API</h2>
* **delete_file(id):** elimina un archivo del servidor usando su ID.
* **download(id):** descarga un fichero y lo descifra usando la clave pública del emisor. También comprobará la validez de su firma.
* **upload(file):** cifra y firma un fichero, para después subirlo al servidor.
* **list_files():** imprime los archivos que ha subido el usuario actual al servidor.
* **delete_id(id):** elimina un usuario del servidor.
* **search_id(string):** busca un usuario en el servidor, comparando el string con el nombre y el email.
* **create_id():** registra al usuario actual en la plataforma.

<h2>Uso del cliente</h2>
Para más información acerca de la forma de utilizar este módulo (y el cliente en general), consultar el apartado [Uso](uso)

Volver a [Modulos](Modulos).