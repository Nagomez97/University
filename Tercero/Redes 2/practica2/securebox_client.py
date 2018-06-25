import argparse
from Crypto.PublicKey import RSA
import crypto
import securebox
import user_database
import os
import tempfile
import base64

""" Clase del cliente de SecureBox
"""
class secure_client:

	def __init__(self, user, dest, source):
		self.user = user
		self.dest = dest # id destinatario
		self.source = source # id origen

	''' encrypt()
	Funcion para cifrar un archivo
	:param file: fichero a cifrar
	:param dest_id: id del destinatario (usaremos su clave publica)
	'''
	def encrypt(self, file):
		if self.dest is None:
			print("\nRecuerde introducir el id del destinatario con --dest_id\n")
			return

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Leer fichero
		mes = open(file, 'rb').read()

		# Obtener clave publica del destinatario
		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.dest))

		# Cifraamos el fichero con dicha clave
		enc = crypto.encrypt_file(mes, public_key)

		# Escribimos el fichero cifrado en otro con mismo nombre, acabado en .enc
		filename = file.split('/')[-1]
		name = 'Archivos/' + filename + '.enc'

		r = open(name, 'wb')
		r.write(enc)
		r.close()

		print('\nFichero cifrado guardado en ' + name)

	''' sign()
	Funcion para firmar un archivo
	:param file: fichero a firmar
	'''
	def sign(self, file):

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Obtenemos el filename
		filename = file.split('/')[-1]

		# Leer fichero
		mes = open(file, 'rb').read()

		# Obtener clave privada del origen (en el propio ordenador)
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'r').read())

		# Firmamos el documento
		signature = crypto.digital_signature(mes, self.user.private_key)

		# Guardamos el fichero firmado en otro con el mismo nombre, acabado en .sgn
		name = 'Archivos/' + filename + '.sgn'

		r = open(name, 'wb')
		r.write(signature+mes)
		r.close()

		print('\nFichero firmado guardado en ' + name)

	''' enc_sign()
	Funcion para firmar y cifrar un archivo
	:param file: fichero a firmar y cifrar
	'''
	def enc_sign(self, file):
		if self.dest is None:
			print("\nRecuerde introducir el id del destinatario con --dest_id\n")
			return

		print('\nEl usuario actual es ' + self.user.user_short())

		# Leer el fichero
		message = open(file, 'rb').read()

		# Obtenemos el filename
		filename = file.split('/')[-1]

		# Obtener claves:
		#	Privada del origen (en el propio ordenador)
		#	Publica del destinatario
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'r').read())

		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.dest))

		packet = crypto.encrypt_and_sign(message, self.user.private_key, public_key)

		# Guardamos el fichero firmado y cifrado en un fichero de mismo nombre acabado en .sgn.enc
		name = 'Archivos/' + filename + '.sgn.enc'

		r = open(name, 'wb')
		r.write(packet)
		r.close()

		print('\nFichero firmado y cifrado guardado en ' + name)

	''' decrypt()
	Funcion para cifrar un archivo localmente
	:param file: fichero a descifrar
	'''
	def decrypt(self, file):

		print('\nEl usuario actual es ' + self.user.user_short())

		# Leer fichero
		enc = open(file, 'rb').read()

		# Obtener clave privada del destinatario (en el propio ordenador)
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'r').read())

		# Desciframos el mensaje
		mes = crypto.decrypt_file(enc, self.user.private_key)

		# Lo guardamos con su nombre original
		file = file.split('/')[-1]
		name = 'Archivos/' + file[:-4]

		r = open(name, 'wb')
		r.write(mes)
		r.close()

		print('\nFichero descifrado guardado en ' + name)

	''' check_sign()
	Funcion para comprobar la firma de un archivo
	:param file: fichero a comprobar
	'''
	def check_sign(self, file):
		if self.source is None:
			print("\nRecuerde introducir el id del emisor con --source_id\n")
			return

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Leer dichero
		f = open(file, 'rb').read()

		# Obtener clave publica del origen
		# k = open(source_id+'.pem', 'r').read()
		# user = user_database.User(source_id, None,
		# None, None, 0)
		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.source))

		# Dividmos la firma del cuerpo del mensaje
		signature = f[:256]
		mes = f[256:]

		# Lo guardamos con su nombre original solo si la firma coincide 
		file = file.split('/')[-1]
		name = 'Archivos/' + file[:-4]

		if crypto.verify_signature(mes, public_key, signature) == True:
			print('\nLa firma digital es correcta, fichero guardado en ' + name)
			r = open(name, 'wb')
			r.write(mes)
			r.close()
		else: 
			print('\nLa firma digital no es correcta, el fichero no ha sido guardado\n')

	''' dec_csign()
	Funcion para descifrar y comprobar la firma de un fichero
	:param file: fichero a descifrar y comprobar 
	:param dest_id: id del destinatario (usaremos su clave privada)
	:param source:id: id del origen (usaremos su clave privada)
	'''
	def dec_csign(self, file):
		if self.source is None:
			print("\nRecuerde introducir el id del emisor con --source_id\n")
			return

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Leer fichero
		enc = open(file, 'rb').read()

		# Obtener claves:
		#	Publica del origen
		#	Privada del destinatario (en el propio ordenador)
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'r').read())
		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.source))

		# Desciframos el fichero
		mes, flag = crypto.decrypt_and_check_sign(enc, public_key, self.user.private_key)

		print('\nFichero descifrado, comprobando firma digital\n')

		# Lo guardamos con su nombre original solo si la firma coincide
		file = file.split('/')[-1]
		name = 'Archivos/' + file[:-8]

		if flag == True:
			print('\nLa firma digital es correcta, fichero guardado en ' + name)
			r = open(name, 'wb')
			r.write(mes)
			r.close()
		else: 
			print('\nLa firma digital no es correcta, el fichero no ha sido guardado\n')

	""" delete_file()
	Funcion para borrar un archivo
	:param id: id del archivo a borrar
	"""
	def delete_file(self, id):
		deleted = securebox.deleteFile(self.user, id)
		print("\nSe ha borrado el archivo", deleted)

	""" download()
	Funcion para descargar un archivo
	:param id: id del archivo a borrar
	"""	
	def download(self, id):
		if self.source is None:
			print("\nRecuerde introducir el id del emisor con --source_id\n")
			return

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Obtenemos las claves
		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.source))
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'rb').read())

		# Descargamos el fichero y lo desciframos
		text = securebox.downloadFile(self.user, id)
		# Decodificamos el paquete usando base64
		text = base64.b64decode(text)
		print("\nFichero descargado, descifrando...\n")

		mes, flag = crypto.decrypt_and_check_sign(text, public_key, self.user.private_key)
		
		if flag == True:
			name = 'Archivos/' + id + '.file'
			print('\nLa firma digital es correcta, fichero guardado en ', name, '\n\nRecuerde renombrar el archivo para no perder el formato del fichero\n')
			f = open(name, "wb")
			f.write(mes)
			f.close()
		else: 
			print('\nLa firma digital no es correcta, el fichero no ha sido guardado\n')

	""" upload()
	Funcion para subir un archivo cifrado. Primero lo cifra y luego lo envia

	:param file: archivo a enviar
	:param dest_id: id del destinatario
	"""
	def upload(self, file):
		if self.dest is None:
			print("\nRecuerde introducir el id del destinatario con --dest_id\n")
			return

		print('\nEstá en el sistema como ' + self.user.user_short())

		# Nos quedamos solo con el nombre del fichero y su extension
		filename = file.split('/')[-1]

		mes = open(file, 'rb').read()

		# Obtenemos las claves necesarias
		public_key = RSA.import_key(securebox.getPublicKey(self.user, self.dest))
		self.user.private_key = RSA.import_key(open('Users/'+self.user.id+'/'+self.user.id+'.bin', 'rb').read())

		# Ciframos el archivo
		packet = crypto.encrypt_and_sign(mes, self.user.private_key, public_key)

		name = 'Archivos/' + filename + '.sgn.enc'

		# Usamos base64 para codificar el paquete
		packet = base64.b64encode(packet)

		f = open(name, 'wb')
		f.write(packet)
		f.close()

		id, size = securebox.uploadFile(self.user, name)

		print("\nSe ha subido el archivo con id ", id, "de tamano", size)

	""" list_files()
	Funcion para listar los archivos que hay en el servidor
	"""
	def list_files(self):
		files, number = securebox.listFile(self.user)
		print("\nSe han encontrado", number, "archivos\n")
		for f in files:
			print(f) 

	""" delete_id()
	Funcion para eliminar una entidad del servidor

	:param id: id de la entidad a borrar
	"""
	def delete_id(self, id):
		self.user.id = id
		idd = securebox.deleteUser(self.user)
		print("\nSe ha eliminado el usuario ", idd)
		#Borramos los archivos de claves
		os.remove('Users/'+idd+'/'+idd+".bin")
		os.remove('Users/'+idd+'/'+idd+".pem")

	""" search_id()
	Funcion para buscar una entidad en el servidor.

	:param id: id de la entidad a borrar
	"""
	def search_id(self, search):
		ret = securebox.searchUser(search, self.user)
		print("\nSe han encontrado", len(ret), "usuarios:")
		for i, user in enumerate(ret):
			print('[', i+1, '] ', user.name, ', ', user.email, ', ID: ', user.id, sep='')

	''' create_id()
	Funcion para registrar un nuevo usuario en la plataforma
	:param file: fichero a descifrar y comprobar 
	:param dest_id: id del destinatario (usaremos su clave privada)
	:param source:id: id del origen (usaremos su clave privada)
	'''
	def create_id(self):
		print('\nCreando claves RSA...\n')
		self.user.private_key, self.user.public_key = crypto.key_generator()
		print('\nRegistrando usuario...\n')
		name, timestamp = securebox.registerUser(self.user)
		print('\nUsuario registrado correctamente\n')

		#Obtenemos el id del usuario para guardar las claves
		ret = securebox.searchUser(name, self.user)
		id = '0'
		for i in ret:
			if i.name == name:
				self.user.id = i.id
				break

		print('\nAlmacenando informacion local...\n')
		path = 'Users/'+self.user.id
		if not os.path.exists(path):
			os.makedirs(path)

		print('\nGuardando claves\n')
	   	

		name = path + '/' + self.user.id + '.pem'
		public_file = open(name, "wb")
		public_file.write(self.user.public_key)
		public_file.close()

		name = path + '/' + self.user.id + '.bin'
		private_out = open(name, "wb")
		private_out.write(self.user.private_key)
		private_out.close()


#___MAIN___

# Creamos un parseador
parser = argparse.ArgumentParser(description='Client to interact with the securebox api')
# Creamos un grupo excluyente (si se activan dos de las flags dentro del grupo a la vez, da error)
group = parser.add_mutually_exclusive_group()
# Aniadimos elementos al grupo
group.add_argument('--encrypt', metavar='file', help='encrypt a file')
group.add_argument('--sign', metavar='file', help='sign a file')
group.add_argument('--enc_sign', metavar='file', help='encrypt and sign a file')
group.add_argument('--decrypt', metavar='file', help='decrypt a file')
group.add_argument('--check_sign', metavar='file', help='check the sign of a file')
group.add_argument('--dec_csign', metavar='file', help='decrypt and check the sign of a file')
group.add_argument('--delete_file', metavar='id_file', help='delete a file from the server')
group.add_argument('--download', metavar='id_file', help='download a file from the server')
group.add_argument('--upload', metavar='file', help='upload a file to the server')
group.add_argument('--list_files', action='store_true', help='list files in the server')
group.add_argument('--delete_id', metavar='id', help='delete a user with specified id')
group.add_argument('--search_id', metavar='string', help='search for a user that contains te string')
group.add_argument('--create_id', nargs='+', help='creates a new user, needs: name, email, [alias]')
group.add_argument('--change_user', nargs=2, help='changes the user, needs: userID, token')
# Aniadimos elementos fuera del grupo excluyente
parser.add_argument('--dest_id', metavar='id', help='specify the receiver for the file')
parser.add_argument('--source_id', metavar='id', help='specify the sender of the file')
# Parsear
args = parser.parse_args()

current_user = user_database.User(None, None, None, None, None)

client = secure_client(current_user, args.dest_id, args.source_id)

# Comprobacion de flags y llamada a funciones
if args.encrypt is not None:
	client.encrypt(args.encrypt)
elif args.decrypt is not None:
	client.decrypt(args.decrypt)
elif args.sign is not None:
	client.sign(args.sign)
elif args.check_sign is not None:
	client.check_sign(args.check_sign)
elif args.enc_sign is not None:
	client.enc_sign(args.enc_sign)
elif args.dec_csign is not None:
	client.dec_csign(args.dec_csign)
elif args.delete_file is not None:
	client.delete_file(args.delete_file)
elif args.download is not None:
	client.download(args.download)
elif args.upload is not None:
	client.upload(args.upload)
elif args.list_files == True:
	client.list_files()
elif args.delete_id is not None:
	client.delete_id(args.delete_id)
elif args.search_id is not None:
	client.search_id(args.search_id)
elif args.create_id is not None:
	# En este caso, alias es opcional, por lo que tenemos que comprobar el numero de argumentos
	if len(args.create_id) == 3:
		client.user.name = args.create_id[0]
		client.user.email = args.create_id[1]
		client.create_id()
	elif len(args.create_id) == 2:
		client.user.name = args.create_id[0]
		client.user.email = args.create_id[1]
		client.create_id()
	else: # Si falla, muestra la ayuda
		parser.print_help()
elif args.change_user is not None:
	id = args.change_user[0]
	token = args.change_user[1]
	client.user.change_user(id, token)

	print('Cliente cambiado a: ', client.user.user_short())

else: # Si falla, muestra la ayuda
	parser.print_help()