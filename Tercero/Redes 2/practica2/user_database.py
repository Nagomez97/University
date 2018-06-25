import sys
""" class User
Clase para instanciar un usuario, con todos los datos.
Esto nos permite trabajar de forma abstracta con un usuario,
que va a obtener los datos de un fichero
"""
class User:

	def __init__(self, id, name, email, public_key, ts):
		self.name = name
		self.email = email
		self.private_key = None
		self.public_key = public_key
		self.timestamp = ts


		config = open('Users/current.cfg', 'r')

		# Reding the config file
		config_id, config_token = self.config_read()

		if id is None:
			self.id = config_id
		else:
			self.id = id

		self.token = config_token


	def __str__(self):
	 	string = 'ID: ' + self.id + '\n' + 'Nombre: ' + self.name + '\n' +  'Email: ' + self.email + '\n'
	 	return string

	# Funcion que muestra el id de un user
	def user_short(self):
		return 'ID: ' + self.id

	def config_read(self):
		config = {}
		with open('Users/current.cfg') as f:
			content = f.readlines()

			dictionary = {}
			# Lo guardamos en un diccionario
			for ls in content:
				# Borramos los saltos de linea y lo separamos
				ls = ls.strip().split(' : ')
				dictionary[ls[0]] = ls[1]

		try:
			userID = dictionary['userID']
			token  = dictionary['token']
		except(KeyError):
			print('Error al leer el archivo de configuracion')
			sys.exit('KeyError')
		return userID, token


	""" change_user()
	Funcion para cambiar de usuario

	:param userID: id del nuevo usuario
	:param token: toekn del nuevo usuario
	"""
	def change_user(self, userID, token):
		try:
			file = open('Users/current.cfg', 'w')
			if token is None or userID is None:
				print('Parametros de configuracion invalidos.')
				sys.exit('ConfigError')
			id = 'userID : ' + userID
			tok = 'token : ' + token
			file.write(id)
			file.write('\n')
			file.write(tok)
			file.close()

		except:
			print('Error al abrir el archivo de configuracion.')
			sys.exit('IOError')