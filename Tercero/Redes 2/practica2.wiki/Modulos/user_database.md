<h1>User_database</h1>
Este módulo permite la instanciación de un usuario, con el objetivo de trabajar con un objeto que contenga todos los campos necesarios para el funcionamiento del cliente (nombre, email, claves...).

La información sobre el usuario actual será leída al iniciar el cliente desde el fichero *Users/current.cfg* con el siguiente formato:
```
userID : e340546
token : 2d697F08Ce4BEA5a
```

Además, se permitirá el cambio de usuario llamando a la función *change_user(id, token)*, que guardará en el fichero de configuración la información sobre el usuario.

Volver a [Modulos](Modulos).