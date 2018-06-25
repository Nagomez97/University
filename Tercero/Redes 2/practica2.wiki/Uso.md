# Uso

Para usar este cliente, hay implementadas ciertas flags, aquí describiremos su funcionalidad y los requisitos de las mismas.

## Auxiliares
* __--dest _ id__ _id_: Indica el id del receptor del fichero
* __--source _ id__ _id_: Induca el id del emisor del fichero

## Cifrado local
* __--encrypt__ _file_: Cifra un fichero, lo guarda en la carpeta Archivos/ con la terminación _.enc_. Necesita el argumento auxiliar _dest _ id_.
* __--decrypt__ _file_: Desifra un fichero, lo guarda en la carpeta Archivos/ con la terminación. Consideramos el receptor como el usuario actual del cliente.
* __--sign__ _file_: Firma un fichero, lo guarda en la carpeta Archivos/ con la terminación _.sgn_. Consideramos el emisor como el usuario actual del cliente
* __--check _ sign__ _file_: Comprueba la firma de un fichero, lo guarda en la carpeta Archivos/. Necesita el argumento auxiliar _source _ id_.
* __--enc_sign__ _file_: Cifra y firma un fichero, lo guarda en la carpeta Archivos/ con la terminación _.sgn.enc_. Consideramos el emisor como el usuario actual del cliente. Necesita el argumento auxiliar _dest _ id_.
* __--dec_sign__ _file_: Desifra y comprueba la firma de un fichero, lo guarda en la carpeta Archivos/. Consideramos el receptor como el usuario actual del cliente. Necesita el argumento auxiliar _source _ id_.

## Gestión de identidades
* __--create _ id__ _nombre email [alias]_: Crea un nuevo usuario, con sus correspondientes claves RSA. Las claves se guardan automáticamente en Users/ con el id generado por el servidor. El usuario se registrará en el servidor.
* __--search _ id__ _cadena_: Busca un usuario que coincida con la cadena y devuelve los datos relativos a él.
* __--delete_ id__ _id_: Elimina el usuario correspondiente al id aportado. Borra las claves RSA guardadas y lo elimina del servidor
* __--change _ user__ _id_: Cambia al usuario especificado en el cliente local. A partir de este comando se considerará dicho usuario para acciones por defecto.

## Gestión de ficheros en el servidor
* __--list _ files__: Muestra todos los archivos subidos por el usuario actual.
* __--upload__ _file_: Sube un archivo al servidor después de cifrarlo y firmarlo.
* __--download__ _id_: Descarga un archivo desde el servidor, lo descifra y comprueba su firma. En caso de que la firma sea correcta, se guardará en Archivos/ con el id del archivo y terminacion _.file_
* __--delete _ file__ _id_: Borra el archivo del servidor correspondiente a ese id.

Volver a [Indice](Indice).