# coding: utf-8
# import the library
from appJar import gui
from PIL import Image, ImageTk
import numpy as np
import cv2
import socket
import server_connection
# import commands
import call_connection
import threading, time
import datetime
import numpy, random

TCPPORT = random.randrange(8000, 9000, 1)
UDPPORT = random.randrange(8000, 9000, 1)

MAX_TAM = 64000


class VideoClient(object):

	def __init__(self, window_size):
		self.nick = None
		self.password = None
		self.tcpSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.udpSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.vegaSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Socket para comunicarnos con vega
		self.vegaSocket.connect(("vega.ii.uam.es", 8000)) # Nos conectamos al servidor
		self.tcpSocket.bind(("", TCPPORT))
		self.udpSocket.bind(("", UDPPORT))
		self.currentConnection = None # Conexion actual
		
		self.callDuration = 0 # Duracion de la llamada
		self.clockRun = False # Estado del reloj

		self.framesSent = 0
		self.FPS = 0
		self.resolution = "0x0"

		self.frames = 0


		# Llamada actual
		self.currentCall = None


		#---------------------------------------------
		# Pantalla principal
		# Creamos una variable que contenga el GUI principal
		self.app = gui("Redes2 - P2P", window_size)
		self.app.setGuiPadding(10,10)

		# Preparación del interfaz
		self.app.addLabel("title", "Cliente Multimedia P2P - Redes2 ")
		self.app.addImage("video", "imgs/webcam.gif")

		# Registramos la funcióo de captura de video
		# Esta misma función también sirve para enviar un vídeo
		self.cap = cv2.VideoCapture(1)
		# self.app.setPollTime(20)
		# self.app.registerEvent(self.capturaVideo)

		# Añadir los botones
		self.app.addButtons(["Conectar", "Elegir Fuente", "Salir"], self.buttonsCallback)
		
		# Barra de estado
		# Debe actualizarse con información útil sobre la llamada (duración, FPS, etc...)
		self.app.addStatusbar(fields=2)

		self.app.setStatusbar("FPS:", field=0)

		self.app.setStatusbar("00:00:00", field=1)
		#---------------------------------------------

		#---------------------------------------------
		# Pantalla de Login
		self.app.startSubWindow("Login", modal=True)
		self.app.setPadding(10,10)

		# Introducimos el usuario
		self.app.addLabelEntry("Nick")
		self.app.addLabelSecretEntry("Pass")

		# Botones
		self.app.addButtons(["Login", "Cancelar"], self.buttonsCallback)

		self.app.stopSubWindow()
		#---------------------------------------------

		#---------------------------------------------
		# Pantalla de Conexión
		self.app.startSubWindow("Conexion", modal=True)
		self.app.setPadding(10,10)

		# Introducimos el usuario
		self.app.addLabelEntry("Introduce el nick del usuario a buscar")
		self.app.addLabelOptionBox("Nicks", ['-Seleccione uno-'])

		# Botones
		self.app.addButtons(["Llamar", "Atras"], self.buttonsCallback)	

		self.app.stopSubWindow()
		#---------------------------------------------

		#---------------------------------------------
		# Llamada entrante
		self.app.startSubWindow("IncomingWindow", modal=True)
		self.app.setPadding(10,5)
		self.app.addLabel("IncomingAlert", 'Llamada entrante')
		self.app.addButtons(["Aceptar", "Rechazar"], self.buttonsCallback)

		self.app.stopSubWindow()

		#---------------------------------------------


		#---------------------------------------------
		# Elegir Fuente
		self.app.startSubWindow("ChoiceWindow", modal=True)
		self.app.setPadding(10,5)
		self.app.addLabel("ChoceAlert", 'Seleccione la fuente de video')
		self.app.addButtons(["Camara", "Fichero"], self.buttonsCallback)

		self.app.stopSubWindow()

		#---------------------------------------------

		#---------------------------------------------
		# Preparamos la pantalla de llamada

		self.app.startSubWindow("Llamada", modal=False)
		self.app.setPadding(10,10)

		# Preparación del interfaz
		self.app.addLabel("titulo", "Llamada actual")
		self.app.addImage("video_recibido", "imgs/webcam.gif")

		self.app.addButtons(["Pausar/Reanudar", "Colgar"], self.buttonsCallback)

		self.app.stopSubWindow()

		self.fichero = None
		#---------------------------------------------

	# Función que comienza la ejecución
	def start(self):
		self.app.go(startWindow="Login")

	
	# Función que gestiona los callbacks de los botones
	def buttonsCallback(self, button):

		if button == "Salir" or button == "Cancelar":
			# Si estamos en una llamada la colgamos
			if(self.currentCall is not None):
				self.callEnd()
			# Salimos de la aplicación
			self.app.stop()
			server_connection.quit(self.vegaSocket) # Adviertimos al servidor que nos desconectamos
			self.vegaSocket.close() # Cerramos los sockets
			self.tcpSocket.close()
			self.udpSocket.close()
		elif button == "Login":
			# Cogemos los parámetros introducidos
			self.nick = self.app.getEntry("Nick")
			self.password = self.app.getEntry("Pass")

			# Comprobamos que no esten vacíos
			if self.password == "" or self.nick == "":
				self.app.warningBox("Error", "Los campos deben estar rellenos", parent="Login")
			elif server_connection.register(self.nick, self.password, self.tcpSocket, self.vegaSocket) == False:
				self.app.warningBox("Error", "La contraseña es incorrecta", parent="Login")
			else:
				self.app.hideSubWindow("Login") 
				self.app.show()
				

		elif button == "Conectar":
			listUsers = server_connection.listUsers(self.vegaSocket)
			self.refreshNickWindow(['-Seleccione uno-'] + listUsers)
			
		elif button == "Atras":
			self.app.hideSubWindow("Conexion")

		elif button == "Llamar":
			nick = self.getNick() # nick del usuario al que llamamos
			if nick == None:
				self.app.warningBox("Error", "No se ha introducido ningún usuario", parent="Conexion")
			else:
				ip,port,protocolos = server_connection.query(nick, self.vegaSocket)
				if ip == None or port == None or protocolos == None:
					self.app.warningBox("Error", "El usuario introducido no existe", parent="Conexion")
				else:
					# Faltaria mirar los protocolos

					self.app.hideSubWindow("Conexion")
					# Lanzamos la llamada
					self.startCall(self.app, self.nick, nick, port, ip)
					
					#_________________________________________#
					# Realizar una llamada
			

		elif button == "Aceptar":
			self.currentCall.acceptCallV1()
			self.app.thread(self.callListener)
			self.app.thread(self.sendVideo)
			self.app.thread(self.recvVideo)
			self.app.hideSubWindow('IncomingWindow')

		elif button == "Rechazar":
			self.currentCall.rejectCallV1()
			self.currentCall = None
			self.app.hideSubWindow('IncomingWindow')

		elif button == "Colgar":
			self.callEnd()
			self.app.hideSubWindow('Llamada')
			# TODO Acabar llamada: habria que cerrar el socket

		elif button == "Pausar/Reanudar":
			self.callHoldResume()
			# TODO Y cortar la llamada

		elif button == "Elegir Fuente":
			if(self.clockRun == False):
				self.app.showSubWindow("ChoiceWindow")	

		elif button == "Camara":
			self.cap = cv2.VideoCapture(0)
			self.app.hideSubWindow("ChoiceWindow")

		elif button == "Fichero":
			aux = self.app.openBox(title="Fichero", dirName=None, fileTypes=[('video', '*.divx'),('video', '*.mp4'), ('video', '*.mpeg'), ('video', '*.flv'), ('video', '*.avi'), ('video', '*.mkv'), ('video', '*.mov'), ('video', '*.mpg')], asFile=False, parent="ChoiceWindow")
			self.fichero = aux
			if aux != ():
				self.cap = cv2.VideoCapture(aux)
			self.app.hideSubWindow("ChoiceWindow")



	# Función para actualizar la pantalla de selección de nicks
	def refreshNickWindow(self, users):
		self.app.setEntry("Introduce el nick del usuario a buscar", "")
		self.app.clearOptionBox("Nicks")
		self.app.changeOptionBox("Nicks", users) # Actualizamos desplegable
		self.app.showSubWindow("Conexion") # Mostramos la ventana

	# Función para obtener el nick introducido
	def getNick(self):
		introducido = self.app.getEntry("Introduce el nick del usuario a buscar")
		desplegable = self.app.getOptionBox("Nicks")
		if introducido != "":
			return introducido
		else: 
			return desplegable # Si no se ha introducido nada devovleremos lo del desplegable
							   # Ojo, si en el desplegable no se ha seleccionado una opción valida
							   # devolverá None

	# Función que resetea el contador de FPS
	# Como esta función se llamará cada segundo, el numero de FPS
	# es el numero de frames recibidos 
	def calculateFPS(self):
		self.FPS = self.frames
		self.frames = 0



	""" Funcion para realizar una llamada
	:param app: interfaz de la aplicacion
	:param userNick: nick del usuario actual
	:param nick: nick del otro usuario
	:param port: puerto del otro usuario
	:param IP: IP del otro usuario
	"""
	def startCall(self, app, userNick, nick, port, IP):
		self.currentCall = call_connection.Call(app, self.udpSocket, userNick, UDPPORT, nick, port, IP, None)
		self.framesSent = 0
		self.FPS = 0

		ret = self.currentCall.start_callV1()
		if ret == 'OK':
			self.app.thread(self.callListener)
			self.app.thread(self.sendVideo)
			self.app.thread(self.recvVideo)
		elif ret == 'BUSY':
			msg = nick + " no esta conectado."
			self.app.warningBox("Warning", msg, parent="Conexion")

	""" Funcion para escuchar operaciones de la llamada actual
	"""
	def callListener(self):
		while self.currentCall is not None:
			msg = self.currentCall.callSocket.recv(MAX_TAM).decode("utf-8")
			msg = msg.split()

			if not msg or self.currentCall is None:
				break
	
			# Se pausa la llamada
			if (msg[0] == 'CALL_HOLD' or msg[0] == 'CALL_RESUME'): #and msg[1] == self.currentCall.nick:	
				self.app.thread(self.clockStartPause)

			# Se termina la llamada
			elif msg[0] == 'CALL_END':# and msg[1] == self.currentCall.nick:
				self.app.hideSubWindow('Llamada')
				self.clockStop()
				self.currentCall.closeConnections()
				self.currentCall = None
				break
				
	""" Función para enviar video en la llamada con cabeceras
		Además muestra la imagen en local
	""" 
	def sendVideo(self):
		while True:
			order = self.framesSent
			tstamp = time.time()
			resolution = self.resolution
			FPS = self.cap.get(cv2.CAP_PROP_FPS)
			# FPS = 0
			# Capturamos un frame de la cámara o del vídeo
			ret, frame = self.cap.read()
			if(ret == False):
					self.cap = cv2.VideoCapture(self.fichero)
					continue
					# break;
			encode_param = [cv2.IMWRITE_JPEG_QUALITY,30]
			result,encimg = cv2.imencode('.jpg',frame,encode_param)
			if result == False: print('Error al codificar imagen')
			data = numpy.array(encimg)
			stringData = data.tostring()

			frame = cv2.resize(frame, (640,480))
			cv2_im = cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)
			img_tk = ImageTk.PhotoImage(Image.fromarray(cv2_im))		    

			# Lo mostramos en el GUI
			self.app.setImageData("video", img_tk, fmt = 'PhotoImage')

			if self.currentCall is not None:
				if self.clockRun == True:
					msg = (str(order)+'#'+str(tstamp)+'#'+str(resolution)+'#'+str(FPS)+'#').encode('utf-8')
					msg += stringData
					self.currentCall.sendFrame(msg)
					self.framesSent += 1 # Incrementamos el numero de frame
			else:
				break

		self.app.setImage("video", "imgs/webcam.gif")


	""" Funcion para recibir video. Sera llamado desde un thread
	"""
	def recvVideo(self):
		self.lastFrame = 0
		# Iniciamos la cuenta de reloj de la llamada
		self.app.thread(self.clockStartPause)

		self.app.showSubWindow("Llamada")
		while(self.currentCall is not None):
			# Recibimos un paquete
			pckg = self.currentCall.recvFrame()

			headers = pckg.split(b'#',4)

			# Diseccionamos las cabeceras
			frameNumber = int(headers[0])
			ts = headers[1].decode('utf-8')
			res = headers[2].decode('utf-8')
			fps = headers[3].decode('utf-8')
			encimg = numpy.fromstring(headers[4], dtype=np.uint8)
			
			self.frames = self.frames + 1

			# Comprobamos que el frame no llegue con retraso
			if(frameNumber < self.lastFrame):
				continue

			self.lastFrame = frameNumber
			# self.FPS = fps


			decimg = cv2.imdecode(np.frombuffer(encimg,np.uint8), 1)
			cv2_im = cv2.cvtColor(decimg,cv2.COLOR_BGR2RGB)
			img_tk = ImageTk.PhotoImage(Image.fromarray(cv2_im))
			self.app.setImageData("video_recibido", img_tk, fmt = 'PhotoImage')

	""" Funcion que comprueba el estado de la llamada. Si
		esta parada, la reanuda y viceversa.
	"""
	def callHoldResume(self):
		# Si esta parada la llamada, la reanuda
		if self.clockRun == False:
			self.currentCall.resumeCallV1()
		else:
			self.currentCall.holdCallV1()

		self.app.thread(self.clockStartPause)

	""" Funcion que para el reloj y termina la llamada
	"""
	def callEnd(self):
		self.currentCall.endCallV1()
		self.clockStop()
		self.currentCall = None


	""" Funcion para iniciar el reloj y mostrarlo en la interfaz
	"""
	def clockStartPause(self):
		# Si esta parado, lo reanuda a partir del duration almacenado
		if self.clockRun == False:
			# Iniciamos el reloj
			self.clockRun = True

			start = time.localtime()
			start = time.mktime(start)

			# Bucle del reloj
			while self.clockRun:
				time.sleep(1)
				t = time.localtime()
				t = time.mktime(t) - start + self.callDuration
				s = str(time.strftime("%H:%M:%S", time.gmtime(t)))

				self.app.queueFunction(self.app.setStatusbar, s, field=1)
				# Actualizamos los FPS
				self.calculateFPS()
				fps = "FPS: " + str(self.FPS)
				self.app.queueFunction(self.app.setStatusbar, fps, field=0)

				# self.app.setStatusbar(s, field=1)
			self.callDuration = t

		else:
			self.clockRun = False
			time.sleep(1)
			self.app.queueFunction(self.app.setStatusbar, "FPS: 0", field=0)

	
	def clockStart(self):
		start = time.localtime()
		start = time.mktime(start)

		while self.clockRun == True:
			time.sleep(1)
			t = time.localtime()
			t = time.mktime(t) - start
			s = str(time.strftime("%H:%M:%S", time.gmtime(t)))

			self.app.setStatusbar(s, field=1)
	

	""" Funcion para parar el reloj y reiniciar la cuenta
	"""
	def clockStop(self):
		self.callDuration = 0
		self.clockRun = False
		time.sleep(2)

		self.app.queueFunction(self.app.setStatusbar, "00:00:00", field=1)
		self.app.queueFunction(self.app.setStatusbar, "FPS: 0", field=0)
		# self.app.setStatusbar('00:00:00', field=1)


	#--------------------------------------------------

	""" Funcion que se mantiene a la escucha de conexiones tcp
	en un bucle constante.
	Es la encargada de manejar las llamadas entrantes
	"""
	def TCPListener(self):
		self.tcpSocket.listen(1)
		while True:
			self.currentConnection, addr = self.tcpSocket.accept()
			msg = self.currentConnection.recv(MAX_TAM).decode("utf-8")
			msg = msg.split()


			# Se recibe una llamada
			if msg[0] == 'CALLING':	

				self.currentCall = call_connection.Call(self.app, self.udpSocket, self.nick, UDPPORT, msg[1], msg[2], addr[0], self.currentConnection)

				msg = msg[1] + ' te esta llamando.'
				self.app.setLabel('IncomingAlert', msg)
				self.app.showSubWindow('IncomingWindow')

	#---------------------------------------------------

	# Establece la resolución de la imagen capturada
	def setImageResolution(self, resolution):		
		# Se establece la resolución de captura de la webcam
		# Puede añadirse algún valor superior si la cámara lo permite
		# pero no modificar estos
		if resolution == "LOW":
			self.resolution = "160x120"
			self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 160) 
			self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 120) 
		elif resolution == "MEDIUM":
			self.resolution = "320x240"
			self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 320) 
			self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 240) 
		elif resolution == "HIGH":
			self.resolution = "640x480"
			self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640) 
			self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480) 

				

if __name__ == '__main__':

	vc = VideoClient("640x520")

	# Crear aquí los threads de lectura, de recepción y,
	# en general, todo el código de inicialización que sea necesario
	# ...
	vc.app.thread(vc.TCPListener)

	# Lanza el bucle principal del GUI
	# El control ya NO vuelve de esta función, por lo que todas las
	# acciones deberán ser gestionadas desde callbacks y threads
	vc.start()