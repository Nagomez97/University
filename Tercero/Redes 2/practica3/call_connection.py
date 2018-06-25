# coding: utf-8
import socket

MAX_TAM = 64000

class Call:

	""" Inicializamos la clase llamada.
	Los parametros userNick y userPort hacen referencia a informacion del
	usuario local. Los demas parametros se obtienen mediante la llamada al query de
	server_connection.
	El puerto de video lo obtendremos tras establecer la conexion TCP de la llamada, como
	respuesta por parte del otro par.

	"""
	def __init__(self, app, udpSocket, userNick, userPort, nick, port, IP, callSocket):
		self.recvSocket = udpSocket
		self.sendSocket = None # Se inicializa en connectCall
		self.userNick = userNick
		self.userPort = userPort
		self.nick = nick
		self.IP = IP
		self.port = port # Al comenzar la llamada, sera el numero de puerto TCP del receptor
						 # Luego cambiará al puerto UDP del receptor (a donde se envía el video)
						 # Al recibir una llamada, será el puerto UDP del emisor
		self.app = app
		self.callSocket = callSocket

	""" Funcion para establecer conexion con un usuario (realizar un llamada)
	Usa protocol V1

	"""
	def start_callV1(self):

		self.callSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Socket para comunicarnos con el usuario
		try:
			self.callSocket.connect((self.IP, int(self.port))) # Nos conectamos al usuario
		except socket.error as e:
			print('Error al conectar la llamada')
			return 'BUSY'

		# El mensaje en el formato de nuestro protocolo V1
		msg = "CALLING " + self.userNick + " " + str(self.userPort)
		# Enviamos un mensaje con la solicitud de llamada
		self.callSocket.send(msg.encode("utf-8"))
		# Esperamos una respuesta a nuestra solicitud
		response = self.callSocket.recv(MAX_TAM)

		response = response.decode("utf-8")


		data = response.split()

		# Estudiamos la respuesta del usuario
		if data[0] == 'CALL_ACCEPTED':
			# Comprobamos que el usuario es el que esperamos
			if data[1] != self.nick:
				# TODO Error por pantalla???
				pass

			else:
				self.port = int(data[2])

				# TODO enviar video
				self.connectCallV1()
				return 'OK'

		# Llamada rechazada
		else:
			msg = self.userNick + " ha rechazado la llamada."


	"""
	Función para aceptar una llamada entrante
	"""
	def acceptCallV1(self):
		# El mensaje en formato V1
		msg = "CALL_ACCEPTED " + self.userNick + ' ' + str(self.userPort)

		# Enviamos el mensaje de llamada aceptada
		self.callSocket.send(msg.encode("utf-8"))
		self.connectCallV1()


	"""
	Función para inicializar el Socket UDP para enviar video
	"""
	def connectCallV1(self):
		self.sendSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	"""
	Función para rechazar una llamada entrante
	"""
	def rejectCallV1(self):
		# El mensaje en formato V1
		msg = "CALL_DENIED " + self.userNick

		# Enviamos el mensaje de llamada aceptada
		self.callSocket.send(msg.encode("utf-8"))

	""" Funcion para reanudar una llamada
	"""
	def resumeCallV1(self):
		msg = "CALL_RESUME " + self.userNick

		self.callSocket.send(msg.encode("utf-8"))

	""" Funcion para pausar una llamada
	"""
	def holdCallV1(self):
		msg = "CALL_HOLD " + self.userNick

		self.callSocket.send(msg.encode("utf-8"))

	""" Funcion para terminar una llamada
	"""
	def endCallV1(self):
		msg = "CALL_END " + self.userNick
		self.callSocket.send(msg.encode("utf-8"))
		# self.closeConnections()

	""" Función para cerrar los sockets que se hayana abierto en la llamada actual
	"""
	def closeConnections(self):
		self.callSocket.close()
		self.sendSocket.close()

	"""
	Función para enviar un frame en la llamada actual
	"""
	def sendFrame(self, pckg):
		self.sendSocket.sendto(pckg, (self.IP, int(self.port)))


	"""
	Función para recibir un frame en la llamada actual
	"""
	def recvFrame(self):
		res = b''
		while(True): # Recibir el paquete completo
			part = self.recvSocket.recv(MAX_TAM)
			res += part
			if(len(part) < MAX_TAM):
				break
		return res