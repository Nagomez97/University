import requests
import user_database
import sys

# ___Funciones de interaccion con usuarios del servidor SecureBox___

""" getPublicKey()
Funcion para obtener la clave publica de un usuario

:param user: objeto usuario
:param id: id del usuario a buscar

:return public_key: clave publica del usuario
"""
def getPublicKey(user, id):
	
	url = 'https://vega.ii.uam.es:8080/api/users/getPublicKey'
	args = {
		'userID': id
	}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		public_key = r.json()['publicKey']
		return public_key
	else:
		msg = 'Error: ' + status
		sys.exit(msg)


""" registerUser()
Funcion para registrar un usuario

:param user: objeto usuario

:return name: nombre del usuario creado
:return timestamp: timestamp del usuario
"""
def registerUser(user):

	url = 'https://vega.ii.uam.es:8080/api/users/register'

	args = {
		'nombre': user.name,
		'email' : user.email,
		'publicKey' : user.public_key.decode()
	}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		name = r.json()['nombre']
		timestamp = r.json()['ts']

		return name, timestamp
	else:
		print("Error:", status)

""" searchUser()
Funcion para buscar un usuario por nombre o email

:param data: cadena de datos a busca

:return ret: lista de objetos con los usuarios obtenidos
"""
def searchUser(data, user):
	url = 'https://vega.ii.uam.es:8080/api/users/search'

	args = {
		'data_search': data
	}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		ret = []
		for user in r.json():
			userID = user['userID']
			name = user['nombre']
			email = user['email']
			public_key = user['publicKey']
			timestamp = user['ts']

			usr = user_database.User(userID, name, email, public_key, timestamp)
			ret.append(usr)
		return ret
	else:
		print("Error:", status)

""" deleteUser()
Funcion para eliminar un usuario usando si userID

:param user: objeto usuario con la informacion

:return id: id del usuario borrado
"""
def deleteUser(user):
	url = 'https://vega.ii.uam.es:8080/api/users/delete'

	args = {
		'userID': user.id
	}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		id = r.json()['userID']
		return id
	else:
		print("Error:", status)


#___Funciones para la interaccion con archivos en el servidor SecureBox___

""" uploadFile()
Funcion para subir un archivo

:param user: objeto del usuario actual
:param mes: mensaje a

:return id: id del archivo devuelto por el servidor
:return size: tamanio del fichero
"""
def uploadFile(user, file_path):

	with open(file_path, 'rb') as f:
		url = 'https://vega.ii.uam.es:8080/api/files/upload'

		file = file_path
		args = {'ufile' : file}

		bearer = "Bearer " + user.token

		headers = {
			"Authorization" : bearer
		}

		r = requests.post(url, files={'ufile' : f}, headers=headers)

	status = r.status_code

	if status == 200:
		id = r.json()['file_id']
		size = r.json()['file_size']
		return id, size
	else:
		print("Error:", status)
		print(r.text)



""" uploadFile()
Funcion para descarar un archivo

:param user: objeto del usuario actual
:param file_id: id del archivo a descargar

:return text: contenido binario del archivo
"""
def downloadFile(user, file_id):
	url = 'https://vega.ii.uam.es:8080/api/files/download'

	args = {'file_id' : file_id}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		return r.text
	else:
		print("Error:", status)

""" listFile()
Funcion que devuelve los archivos del servidor

:param user: objeto usuario (solo se usa para obtener el bearer)

:return files: lista de archivos
:return number: numero de archivos de la lista
"""
def listFile(user):
	url = 'https://vega.ii.uam.es:8080/api/files/list'

	bearer = "Bearer " + user.token

	headers = {
		"Authorization" : bearer
	}

	r = requests.post(url, headers=headers)

	status = r.status_code

	if status == 200:
		files = r.json()['files_list']
		number = r.json()['num_files']
		return files, number
	else:
		print("Error:", status)


""" deleteFile()
Funcion para borrar archivo

:param user: objeto del usuario actual
:param file_id: id del archivo a borrar

:return id: id del archivo borrado
"""
def deleteFile(user, file_id):
	url = 'https://vega.ii.uam.es:8080/api/files/delete'

	args = {'file_id' : file_id}

	bearer = "Bearer " + user.token

	headers = {
		"Content-Type" : "application/json",
		"Authorization" : bearer
	}

	r = requests.post(url, json=args, headers=headers)

	status = r.status_code

	if status == 200:
		return r.json()['file_id']
	else:
		print("Error:", status)


