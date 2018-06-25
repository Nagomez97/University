# coding: utf-8
# Librerias
import socket
import sys

PROTOCOL = 'V1'
MAX_TAM = 1440

try:
    reload(sys)  # Python 2.7
except NameError:
    try:
        from importlib import reload  # Python 3.4+
    except ImportError:
        from imp import reload  # Python 3.0 - 3.3



""" Funcion para registrar un usuario en el servidor
:param nick: nick del usuario
:param password: password del usuario
:param tcpSocket: puerto tcp
:param vegaSocket: informacion del socket de Vega

:return Boolean: True si el login fue correcto
"""
def register(nick, password, tcpSocket, vegaSocket):
	portInfo = tcpSocket.getsockname()[1] # puerto asignado
	ipInfo = vegaSocket.getsockname()[0] # ip de la máquina
	mes = 'REGISTER ' + nick + ' ' + ipInfo  + ' ' + str(portInfo) + ' ' + password + ' ' + PROTOCOL # Hacemos el mensaje
	vegaSocket.send(mes.encode("utf-8")) # Enviamos
	res = vegaSocket.recv(MAX_TAM) # Esperamos respuesta
	res = res.decode("utf-8") # Decodificamos
	return (res[0] == 'O') # Si el servidor devuelve OK, login correcto, en caso contrario, login incorrecto

""" Función para solicitar ip y puerto de un usuario
:param nick: nick del usuario
:param vegaSocket: inforamcion del socket de Vega

:retun ip, puerto y lista de protocolos soportados
"""
def query(nick, vegaSocket):
	mes = 'QUERY ' + nick # Hacemos el mensaje
	vegaSocket.send(mes.encode("utf-8"))
	res = vegaSocket.recv(MAX_TAM)
	res = res.decode("utf-8")
	if(res[0] == 'N'): # Si el servidor devuelve NOK
		return None, None, None
	else:
		data = res.split()
		protocols = data[5].split('#')

		return data[3], data[4], protocols # Devolvemos ip, puerto y lista de protocolos soportados
""" Función para obtener los usuarios registrados en el servidor
:param vegaSocket: inforamcion del socket de Vega

:return lista de usuarios del servidor
"""
def listUsers(vegaSocket):
	mes = b'LIST_USERS'
	vegaSocket.send(mes)
	res = b''
	while(True): # Recibir el paquete completo
		part = vegaSocket.recv(MAX_TAM)
		res += part
		if(len(part) < MAX_TAM):
			break

	res = res.decode("utf-8")
	if(res[0] == 'N'): # Si el servidor devuelve NOK
		return []
	else:
		data = res.split(" ", 3)
		aux = data[3].split("#")
		ret = []
		for a in aux[:-2]: # El ultimo siempre está vacío
			d = a.split() # Queremos solo el nombre
			if d is not None:
				ret.append(d[0])
		return ret # Devolvemos una lista de los usuarios del servidor

""" Funcion para salir de la plataforma
:param vegaSocket: informacion del socket de Vega
"""
def quit(vegaSocket):
	mes = b'QUIT'
	vegaSocket.send(mes)
